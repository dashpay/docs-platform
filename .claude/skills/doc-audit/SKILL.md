---
name: doc-audit
description: >
  Use this skill whenever auditing, reviewing, or checking documentation against a codebase or source of truth.
  Trigger on phrases like "audit our docs", "are our docs up to date", "check docs against code",
  "find doc drift", "stale documentation", "docs out of sync", "review the docs for accuracy",
  "find broken examples", or any request to systematically compare documentation to implementation.
  Also trigger when the user shares a doc repo + code repo and asks what's wrong or outdated.
---

## Objective

Identify discrepancies, omissions, stale content, broken examples, and documentation structure problems while preserving the original documentation style and audience.

---

## Non-goals

- Do not rewrite documentation during the audit.
- Do not silently fix files.
- Do not change tone, structure, or style unless the issue is explicitly about those.
- Do not invent discrepancies without evidence.
- Do not create findings for stylistic preferences, phrasing improvements, or rewrites unless they materially affect correctness, usability, or audience fit.

---

## Pre-audit scope inference

Infer audit scope from the user's message and the repo structure. Proceed immediately unless genuinely ambiguous. Only ask the user to clarify if you cannot determine:

- Which doc paths to audit (and any exclusions)
- Which code repo(s) are the source of truth
- Audit type: baseline (full) or incremental (since a version/commit)

---

## Tool usage

Use these Claude Code tools to access docs and code:

- `Read` — read files from the filesystem (docs, source files, configs, tests)
- `Glob` — find files by name pattern (e.g. `**/*.md`, `src/**/*.ts`)
- `Grep` — search file contents for patterns (e.g. function names, API paths)
- `Bash` — run commands like `git log`, `git diff`, schema generation
- `WebFetch` — fetch hosted docs or external references if needed
- `Agent` — delegate sub-tasks (see Scaling strategy below)

Work from the filesystem when repos are available locally. If they aren't, ask the user how to access them before proceeding.

---

## Scaling strategy

For larger audits (multiple pages or sections), use subagents to avoid context window exhaustion:

1. **Discovery pass** — Use `Glob` and `Grep` to inventory all doc files and their topics.
2. **Per-page audit** — Launch an `Agent` (subagent_type: "general-purpose") for each doc page or small group of related pages. Provide the agent with:
   - The doc file path(s) to audit
   - The relevant code paths to check against
   - The finding schema (required fields only)
   - Instructions to return findings as YAML
3. **Aggregation** — Collect all agent results, merge duplicates, assign finding IDs, and produce the final summary + findings output.

For small or focused audits, work directly without subagents.

---

## Audit dimensions

- correctness
- completeness
- currency
- usability
- audience fit
- terminology consistency
- navigability / information architecture
- source link accuracy

---

## Page classification

Before auditing a page, classify its primary purpose. Judge it against that purpose — do not apply reference-level expectations to tutorials.

- tutorial — step-by-step learning path
- how_to — task completion for a known goal
- explanation — conceptual understanding
- reference — precise factual lookup
- guide — broader workflow or orientation
- end_user_guide — product usage for non-developers
- operator_admin_guide — deployment, maintenance, operations

---

## Issue taxonomy

- incorrect_behavior
- outdated_api
- missing_feature
- missing_explanation
- broken_example
- incomplete_steps
- wrong_path_or_name
- terminology_mismatch
- audience_mismatch
- structural_gap
- unclear_prerequisites
- ambiguous_language
- missing_cross_reference
- stale_version_reference
- misleading_output_or_result
- unsupported_claim
- obsolete_workflow
- config_gap
- outdated_source_link
- inconsistent_format_or_convention

---

## Severity

- critical — dangerous, impossible, or highly misleading; likely causes failure or serious misuse
- high — important mismatch or missing content that blocks successful use
- medium — meaningful clarity/completeness issue, but work is still possible
- low — polish, structure, terminology, minor inconsistency
- info — note for tracking, not really a defect

---

## Source-of-truth precedence

When sources disagree, prefer evidence in this order unless project-specific instructions say otherwise:

1. Current implementation code
2. Public API/schema/protocol definitions
3. Tests validating intended behavior
4. Official examples in the codebase
5. Config defaults / CLI help / generated outputs
6. Existing documentation

If behavior is ambiguous, record the ambiguity as a finding rather than guessing.

---

## Evidence requirements

Each finding should include:

- doc file/path
- section/anchor if available
- code/source-of-truth reference
- clear discrepancy statement
- impact explanation
- recommended update direction

---

## Audit process

1. Identify doc scope and content type.
2. **Restrict to tracked files only** — run `git ls-files <doc_paths>` to get the list of files to audit. Do not audit untracked or ignored files.
3. Infer the task(s) the page supports.
4. Locate relevant source-of-truth (code, schema, tests, examples, config).
5. Compare behavior, names, flows, prerequisites, outputs, and limitations.
6. Check source code links (see Source link validation below).
7. Record each discrepancy as a discrete finding.
8. Merge duplicates when they represent the same underlying issue.
9. Write output files (see Output destination below).

---

## Source link validation

Documentation often links to source code on GitHub (or similar hosts). When links point to a specific version, tag, branch, or commit, verify that the version in the URL matches the version being audited.

### What to check

- Extract GitHub links from doc pages using patterns like `github.com/{org}/{repo}/blob/{ref}/...` or `github.com/{org}/{repo}/tree/{ref}/...`.
- The `{ref}` component may be a branch name, tag, or commit SHA.
- Compare the `{ref}` in the link to the version/branch the audit is validating against.
- If they differ, flag the link as `outdated_source_link`.

### What to ignore

- Links to `main`, `master`, or other default branches (these are intentionally unpinned).
- Links to non-code resources (issues, pull requests, discussions, releases pages).
- Links to external repositories not part of the audit scope.

### Severity guidance

- **high** — link points to a version where the referenced file/symbol has materially changed (moved, renamed, deleted, or has different behavior).
- **medium** — link points to an old version but the referenced content is unchanged at the current version.
- **low** — version mismatch exists but the link is supplementary (e.g. "for historical context").

When the local repo is available, use `git log` or `git show` to check whether the linked file has changed between the linked ref and the audit ref.

---

## Finding quality rules

- One finding per distinct actionable issue.
- Do not combine unrelated issues.
- Merge duplicates where appropriate.
- Prefer specific, evidence-backed findings over general statements.
- Do not create high or critical findings without clear, direct evidence from both documentation and source of truth.
- Mark uncertainty explicitly via confidence.
- If an issue spans multiple pages:
  - use related_findings, or
  - create a canonical finding and link others.

---

## Summary report requirements

The summary markdown must include:

- audit scope
- repositories and paths reviewed
- exclusions
- total pages reviewed
- total findings
- findings by severity
- findings by issue type
- highest-risk sections/pages
- recurring patterns
- recommended next actions
- known uncertainties or incomplete coverage

---

## Actionability requirements

Findings must enable a downstream agent to:

- locate the issue precisely
- understand what is wrong
- understand the correct behavior/content
- understand why it matters
- update docs without changing tone or audience

---

## Coverage and uncertainty

If the audit cannot fully verify something:

- do not guess
- record partial coverage in summary
- create findings only with evidence
- mark confidence appropriately
- note missing tests, unclear behavior, or ambiguity

---

## Update phase compatibility

Each finding MUST include a `doc_locator`, `edit_type`, `edit_instructions`, and optionally `update_group`. These fields are what make findings automatable — without them the output is reports-only.

### Locator guidance

Use the most stable locator available, in order of preference:

1. `anchor` — most stable, use when the doc has named anchors
2. `heading` — use the section heading text
3. `text_match` — exact string present in the doc
4. `semantic` — last resort, describe the location in plain language

Always include `fallback_text_match` when the primary type is `anchor` or `heading`.

---

## Output destination

Write audit output to files, not inline. Use a timestamped directory to avoid overwriting previous audits:

- Summary: `audit-results/{timestamp}/summary.md`
- Findings: `audit-results/{timestamp}/findings.yaml`

Where `{timestamp}` is the audit start time formatted as `YYYYMMDD-HHmmss` (e.g. `audit-results/20260319-143012/`).

Create the directory under the project root. If a different output location is specified by the user, use that instead.

---

## Output formatting rules

- Summary must be valid Markdown.
- Findings must be valid YAML.
- Do not include extra prose outside the summary and findings outputs.
- Do not omit required sections: audit_run, scope, summary, findings.
- Use null explicitly for empty nullable fields.

---

## Schema field notes

- `audit_id` — generate a short unique ID, e.g. `audit-2024-001`
- `agent_version` — use `unknown` if not determinable
- `skill_version` — `2026-04-06`
- `generated_at` — ISO 8601 timestamp

---

## Finding schema

### Required fields (must be present on every finding)

```yaml
findings:
  - finding_id: string           # e.g. F-001
    title: string                # concise description of the issue
    severity: critical | high | medium | low | info
    confidence: high | medium | low
    issue_type: string           # from issue taxonomy above
    doc_file: string             # path to the doc file
    content_type: tutorial | how_to | explanation | reference | guide | end_user_guide | operator_admin_guide | unknown
    summary: string              # what is wrong
    current_doc_behavior: string # what the doc currently says/shows
    expected_behavior: string    # what it should say based on source of truth
    discrepancy: string          # the specific difference
    evidence:
      doc_refs:
        - file: string
          lines: string | null
      code_refs:
        - repo: string
          file: string
          lines: string | null
    impact: string               # why this matters to the reader
    recommended_update: string   # direction for the fix
    doc_locator:
      type: anchor | heading | text_match | semantic
      value: string
      fallback_text_match: string | null
    edit_type: replace | insert_before | insert_after | delete | augment
    edit_instructions:
      - target: string
        action: string
        new_text: string | null
```

Use `new_text` only when the correct replacement is precise and clearly supported by evidence. Otherwise set it to null and describe the required change in `action`.

### Optional fields (include when relevant)

```yaml
    tags:
      - string
    canonical_topic: string | null
    doc_site_section: string
    doc_anchor: string | null
    doc_lines: string | null
    audience: developer | end_user | operator | mixed | unknown
    user_risk: breakage | incorrect_usage | confusion | inefficiency | none
    placement_context: string | null   # in edit_instructions
    update_group: string | null
    implementation_notes:
      - string
    style_guidance: string
    affected_code_paths:
      - string
    fix_priority: immediate | next_cycle | backlog
    related_findings:
      - string
    duplicate_of: string | null
    status: open | planned | in_progress | resolved | wont_fix
    introduced_in_version: string | null
    last_verified_in_version: string | null
    notes: string | null
```

### Envelope schema (wraps findings)

```yaml
audit_run:
  audit_id: string
  doc_site: string
  docs_repo: string
  docs_branch: string           # branch audited
  docs_commit: string           # HEAD commit hash at audit time
  code_repos:
    - repo: string
      branch: string            # branch audited
      commit: string            # HEAD commit hash at audit time
  audit_type: baseline | incremental | verification
  generated_at: string
  agent_version: string
  skill_version: string

scope:
  doc_paths:
    - string
  code_paths:
    - string
  exclusions:
    - string
  untracked_skipped: boolean   # true if git ls-files was used to filter scope
  notes: string | null

summary:
  pages_reviewed: number
  findings_total: number
  by_severity:
    critical: number
    high: number
    medium: number
    low: number
    info: number
  by_issue_type:
    # one entry per issue taxonomy item, value is count

findings:
  - # ... (see required + optional fields above)
```

---

## Example output (truncated)

### Summary (markdown)

```markdown
## Audit Summary

**Scope:** `docs/` in `my-org/my-repo`
**Code repos:** `my-org/my-repo` (main branch)
**Pages reviewed:** 12
**Total findings:** 7 (1 critical, 2 high, 3 medium, 1 low)

### Highest-risk pages
- `docs/api/authentication.md` — 3 findings, 1 critical

### Recurring patterns
- API parameter names in docs lag behind code renames
- Several examples reference deprecated endpoint `/v1/auth`

### Recommended next actions
1. Fix authentication docs immediately (critical finding)
2. Audit remaining API reference pages for similar endpoint drift
```

### Example finding (YAML)

```yaml
# audit_run, scope, and summary follow the envelope schema above

findings:
  - finding_id: F-001
    title: Auth endpoint /v1/auth should be /v2/auth
    severity: critical
    confidence: high
    issue_type: outdated_api
    doc_file: docs/api/authentication.md
    content_type: reference
    summary: Docs reference removed /v1/auth endpoint
    current_doc_behavior: POST /v1/auth for token exchange
    expected_behavior: POST /v2/auth (since v2.0.0)
    discrepancy:  Endpoint path differs (/v1/auth vs /v2/auth)
    evidence:
      doc_refs:
        - file: docs/api/authentication.md
          lines: "42-45"
      code_refs:
        - repo: my-org/my-repo
          file: src/auth/routes.py
          lines: "12-18"
    impact: Readers get 404s on auth
    recommended_update: Update endpoint path to /v2/auth
    doc_locator:
      type: anchor
      value: "#endpoint"
      fallback_text_match: "POST /v1/auth"
    edit_type: replace
    edit_instructions:
      - target: "POST /v1/auth"
        action: Replace endpoint path and update any references to v1
        new_text: "POST /v2/auth"
    # optional fields (tags, update_group, fix_priority, etc.) as needed
```
