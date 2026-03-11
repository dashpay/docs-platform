#!/usr/bin/env python3
"""Sync inline code blocks in tutorial docs with platform-tutorials source files.

Usage:
    python scripts/tutorial-sync/sync_tutorial_code.py --source /path/to/platform-tutorials
    python scripts/tutorial-sync/sync_tutorial_code.py --check --source /path/to/platform-tutorials
    python scripts/tutorial-sync/sync_tutorial_code.py --diff  --source /path/to/platform-tutorials

Modes:
    (default)  Update docs in-place with source code
    --check    Exit non-zero if any code block differs (for CI)
    --diff     Like --check but also print unified diffs
"""

import argparse
import difflib
import os
import re
import sys
from pathlib import Path

try:
    import yaml
except ImportError:
    sys.exit("pyyaml is required: pip install pyyaml")

SCRIPT_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = SCRIPT_DIR.parent.parent
DEFAULT_CONFIG = SCRIPT_DIR / "tutorial-code-map.yml"


# ---------------------------------------------------------------------------
# Source file reading
# ---------------------------------------------------------------------------

def read_source(path: Path) -> str:
    """Read a source file, stripping the '// See https://...' header if present."""
    text = path.read_text(encoding="utf-8")
    lines = text.split("\n", 1)
    if lines and re.match(r"^// See https?://", lines[0]):
        text = lines[1] if len(lines) > 1 else ""
    return text.rstrip("\n")


# ---------------------------------------------------------------------------
# Block finders — return (code_start, code_end) byte offsets of the code body
# ---------------------------------------------------------------------------

def find_by_caption(content: str, caption: str, language: str = "javascript"):
    """Find a {code-block} directive with a matching :caption: value.

    Returns (start, end) offsets of the code body between the directive
    header and the closing ``` fence.
    """
    # Match the opening directive + options, then the code body
    # The directive looks like:
    #   ```{code-block} javascript
    #   :caption: connect.mjs
    #   [:name: ...]
    #
    #   <code body>
    #   ```
    pattern = re.compile(
        r"^```\{code-block\}\s+"
        + re.escape(language)
        + r"\s*\n"
        + r"(?::[\w-]+:.*\n)*?"       # options before caption
        + r":caption:\s+"
        + re.escape(caption)
        + r"\s*\n"
        + r"(?::[\w-]+:.*\n)*"        # options after caption
        + r"\n",                       # blank line before code body
        re.MULTILINE,
    )
    m = pattern.search(content)
    if not m:
        return None

    code_start = m.end()

    # Find closing ``` fence
    close = re.compile(r"^```\s*$", re.MULTILINE)
    cm = close.search(content, code_start)
    if not cm:
        return None

    # code_end is the position just before the newline preceding ```
    code_end = cm.start()
    if code_end > code_start and content[code_end - 1] == "\n":
        code_end -= 1

    return (code_start, code_end)


def find_by_sync(content: str, sync_value: str, language: str = "javascript"):
    """Find a fenced code block inside a tab-item with a matching :sync: value.

    When multiple tab-sets use the same sync values (e.g., JSON schemas and
    JS code), the language parameter disambiguates.
    """
    sync_pattern = re.compile(
        r"^:sync:\s+" + re.escape(sync_value) + r"\s*$", re.MULTILINE
    )

    for m in sync_pattern.finditer(content):
        search_start = m.end()

        # Find next fenced block with the target language
        fence_open = re.compile(
            r"^```" + re.escape(language) + r"\s*$", re.MULTILINE
        )
        fm = fence_open.search(content, search_start)
        if not fm:
            continue

        # Ensure we haven't crossed into a different tab-item
        between = content[search_start : fm.start()]
        if ":::{tab-item}" in between or "::::" in between:
            continue

        code_start = fm.end() + 1  # skip the newline after ```language

        fence_close = re.compile(r"^```\s*$", re.MULTILINE)
        cm = fence_close.search(content, code_start)
        if not cm:
            continue

        code_end = cm.start()
        if code_end > code_start and content[code_end - 1] == "\n":
            code_end -= 1

        return (code_start, code_end)

    return None


def find_by_tab(content: str, tab_title: str, language: str = "javascript"):
    """Find a fenced code block inside a tab-item matched by its title."""
    tab_pattern = re.compile(
        r"^:::\{tab-item\}\s+" + re.escape(tab_title) + r"\s*$", re.MULTILINE
    )

    for m in tab_pattern.finditer(content):
        search_start = m.end()

        # Find next fenced block with the target language (skip options, prose)
        fence_open = re.compile(
            r"^```" + re.escape(language) + r"\s*$", re.MULTILINE
        )
        fm = fence_open.search(content, search_start)
        if not fm:
            continue

        # Ensure we haven't crossed into a different tab-item or tab-set
        between = content[search_start : fm.start()]
        if ":::{tab-item}" in between or "::::" in between:
            continue

        code_start = fm.end() + 1

        fence_close = re.compile(r"^```\s*$", re.MULTILINE)
        cm = fence_close.search(content, code_start)
        if not cm:
            continue

        code_end = cm.start()
        if code_end > code_start and content[code_end - 1] == "\n":
            code_end -= 1

        return (code_start, code_end)

    return None


# ---------------------------------------------------------------------------
# Dispatcher
# ---------------------------------------------------------------------------

def find_block(content: str, block_id: dict, language: str):
    """Dispatch to the correct finder based on block_id keys."""
    if "caption" in block_id:
        return find_by_caption(content, block_id["caption"], language)
    elif "sync" in block_id:
        return find_by_sync(content, block_id["sync"], language)
    elif "tab" in block_id:
        return find_by_tab(content, block_id["tab"], language)
    else:
        raise ValueError(f"Unknown block_id type: {block_id}")


# ---------------------------------------------------------------------------
# Main logic
# ---------------------------------------------------------------------------

def process_mappings(config: dict, source_root: Path, mode: str):
    """Process all mappings. Returns (matched, mismatched, errors) counts."""
    docs_root = PROJECT_ROOT / config["docs_root"]
    matched = 0
    mismatched = 0
    errors = 0

    for entry in config["mappings"]:
        source_path = source_root / entry["source"]
        doc_path = docs_root / entry["doc"]
        block_id = entry["block_id"]
        language = entry.get("language", "javascript")
        label = f"{entry['source']} -> {entry['doc']}"

        # Validate files exist
        if not source_path.is_file():
            print(f"  ERROR  {label}: source file not found: {source_path}")
            errors += 1
            continue
        if not doc_path.is_file():
            print(f"  ERROR  {label}: doc file not found: {doc_path}")
            errors += 1
            continue

        # Read source code
        source_code = read_source(source_path)

        # Read doc and find the block
        doc_content = doc_path.read_text(encoding="utf-8")
        result = find_block(doc_content, block_id, language)

        if result is None:
            print(f"  ERROR  {label}: code block not found (block_id: {block_id})")
            errors += 1
            continue

        code_start, code_end = result
        existing_code = doc_content[code_start:code_end]

        # Compare
        if existing_code.rstrip() == source_code.rstrip():
            print(f"  MATCH  {label}")
            matched += 1
        else:
            mismatched += 1
            if mode == "diff":
                print(f"  DIFF   {label}")
                diff = difflib.unified_diff(
                    existing_code.splitlines(keepends=True),
                    source_code.splitlines(keepends=True),
                    fromfile=f"docs: {entry['doc']}",
                    tofile=f"src: {entry['source']}",
                )
                sys.stdout.writelines("         " + line for line in diff)
                print()
            elif mode == "check":
                print(f"  DRIFT  {label}")
            else:
                # sync mode: replace in-place
                updated = doc_content[:code_start] + source_code + doc_content[code_end:]
                doc_path.write_text(updated, encoding="utf-8")
                print(f"  SYNCED {label}")

    return matched, mismatched, errors


def main():
    parser = argparse.ArgumentParser(
        description="Sync tutorial code blocks with platform-tutorials source files."
    )
    parser.add_argument(
        "--source",
        type=Path,
        help="Path to platform-tutorials repo root",
    )
    parser.add_argument(
        "--config",
        type=Path,
        default=DEFAULT_CONFIG,
        help="Path to mapping config YAML (default: scripts/tutorial-code-map.yml)",
    )
    group = parser.add_mutually_exclusive_group()
    group.add_argument(
        "--check",
        action="store_true",
        help="Compare only, exit non-zero if any drift (for CI)",
    )
    group.add_argument(
        "--diff",
        action="store_true",
        help="Compare and show unified diffs",
    )
    args = parser.parse_args()

    # Determine mode
    if args.check:
        mode = "check"
    elif args.diff:
        mode = "diff"
    else:
        mode = "sync"

    # Load config
    with open(args.config, encoding="utf-8") as f:
        config = yaml.safe_load(f)

    # Resolve source root: CLI > env var > None
    source_root = args.source or os.environ.get("PLATFORM_TUTORIALS_PATH")
    if source_root:
        source_root = Path(source_root).resolve()
    else:
        sys.exit(
            "Error: platform-tutorials path required.\n"
            "Use --source /path/to/platform-tutorials or set PLATFORM_TUTORIALS_PATH"
        )

    if not source_root.is_dir():
        sys.exit(f"Error: source directory not found: {source_root}")

    print(f"Source: {source_root}")
    print(f"Mode:   {mode}")
    print(f"Config: {args.config}")
    print()

    matched, mismatched, errors = process_mappings(config, source_root, mode)

    print()
    print(f"Summary: {matched} matched, {mismatched} drifted, {errors} errors")
    print(f"Total:   {matched + mismatched + errors} / {len(config['mappings'])} mappings")

    if mode in ("check", "diff") and (mismatched > 0 or errors > 0):
        sys.exit(1)
    elif errors > 0:
        sys.exit(1)


if __name__ == "__main__":
    main()
