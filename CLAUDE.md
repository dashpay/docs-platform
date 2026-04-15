# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the Dash Platform documentation repository - a Sphinx-based documentation site that covers Dash Platform features, APIs, SDKs, and developer guides. The documentation is written in Markdown with MyST parser extensions and built with Sphinx.

## Build Commands

```bash
# Set up development environment
python -m venv venv
source venv/bin/activate  # or venv\Scripts\activate on Windows
pip install -r requirements.txt

# Build documentation
make html

# Clean build
make clean

# Sync sidebar after building (recommended after adding new pages)
python scripts/sync_sidebar.py

# Sync tutorial code from platform-tutorials repo
python3 scripts/tutorial-sync/sync_tutorial_code.py --source /path/to/platform-tutorials

# Check for tutorial code drift (CI mode)
python3 scripts/tutorial-sync/sync_tutorial_code.py --check --source /path/to/platform-tutorials

# View built documentation
# Open _build/html/index.html in browser
```

## Architecture

- **conf.py**: Main Sphinx configuration with extensions, theme settings, and intersphinx mappings
- **docs/**: Main documentation content organized by sections:
  - `intro/`: Background and platform overview
  - `tutorials/`: Step-by-step guides
  - `explanations/`: Feature descriptions and concepts
  - `reference/`: API documentation and technical specs
  - `protocol-ref/`: Platform protocol reference
  - `sdk-js/`, `sdk-rs/`: SDK documentation
- **_templates/**: Custom Jinja2 templates for sidebar and layout
- **_static/**: CSS, JavaScript, and image assets
- **scripts/**: Utility scripts including sidebar synchronization

## Documentation Structure

The site uses a hierarchical structure with:

- Main index.md linking to Platform docs
- docs/index.md as Platform documentation entry point
- Sections organized with toctree directives in MyST format
- Cross-references using intersphinx to Core and User documentation

## Key Development Notes

- Uses MyST parser for enhanced Markdown features with reStructuredText compatibility
- Custom sidebar template requires syncing via `scripts/sync_sidebar.py` after structural changes
- Intersphinx links to related Dash documentation (user and core docs)
- GitHub integration for edit links and source references
- Google Analytics tracking configured
- Uses pydata-sphinx-theme with custom CSS overrides

## Editing Guidelines

When updating documentation values that include GitHub source links:

- Preserve the existing link markup — do not replace `[value](url#Lnn)` with plain text
- Update the URL if the file path has changed (e.g. directory renames)
- Update the line anchor (`#L`) to match the correct line **in the branch the link points to**
- When available, use the local platform repository checkout to verify line numbers against the correct branch

## File Patterns

- Documentation files: `docs/**/*.md`
- Configuration: `conf.py`, `requirements.txt`
- Templates: `_templates/*.html`
- Assets: `_static/**/*`
- Build output: `_build/html/` (excluded from git)