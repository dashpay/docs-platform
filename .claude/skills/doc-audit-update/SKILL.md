---
name: doc-audit-update
description: >
  Use this skill to apply documentation updates based on structured audit findings.
  Trigger when the user asks to fix, implement, or apply audit results.
---

## Objective

Apply audit findings to documentation with minimal necessary changes, preserving:

- original tone
- structure
- formatting conventions
- audience level

This is a surgical update pass, not a rewrite.

---

## Non-goals

- Do not rewrite entire sections unless explicitly required
- Do not “improve” writing beyond the finding
- Do not standardize style across files
- Do not fix unrelated issues you notice
- Do not introduce new abstractions or restructure content

---

## Input

- findings.yaml from the audit skill
- Documentation files in repo

Only act on findings where:
- status is open or unspecified
- edit_instructions are present

---

## Core principles

### 1. Minimal diff rule

Make the smallest possible change that resolves the issue.

- Prefer replace over rewrite
- Prefer augment over restructure
- Preserve surrounding text verbatim whenever possible

---

### 2. Inline markup preservation

When applying edits inside Markdown/MyST/rst inline constructs, preserve the existing markup unless the finding explicitly instructs otherwise.

Examples of inline constructs:

- markdown links: [text](url)
- inline code: `value`
- emphasis/bold
- reference-style links
- MyST roles/directives used inline

Rules:

- If correcting linked text, update only the visible label by default.
- Do not replace a link with plain text unless the finding explicitly says to remove the link.
- If the cited source should change, replace the URL while preserving link structure.
- Prefer the smallest edit that keeps surrounding punctuation and markup intact.

### 3. Style preservation

Match the existing doc:

- sentence structure
- terminology
- formatting (MyST, rst, markdown)
- code block style
- heading patterns

If the doc uses inconsistent style, follow the local section, not global consistency.

---

### 4. Locality

Only modify the exact location defined by:

- doc_locator
- edit_instructions.target

Do not move content unless explicitly required.

---

### 5. Deterministic edits

Each finding should result in a clear, traceable change.

No interpretation beyond what is needed to implement:

- expected_behavior
- recommended_update
- edit_instructions

If unclear → skip and flag.

---

## Tool usage

- Read — load doc files
- Grep — locate text_match or fallback targets
- Glob — confirm file paths
- Bash — optional diff/validation

Do not scan unrelated files.

---

## Update process

1. Load findings.yaml
2. Group findings by doc_file
3. For each file:

   a. Open file  
   b. Apply findings sequentially (stable order: by line proximity if possible)

4. For each finding:

   - Resolve locator:
     - anchor → heading → text_match → semantic
   - Locate target text
   - Apply edit_type

---

## Edit type behavior

### replace
Replace only the specified text span.

### insert_before / insert_after
Add text without modifying existing content.

### augment
Extend existing sentence/paragraph (do not rewrite).

### delete
Remove only the incorrect fragment.

---

## Conflict handling

If multiple findings touch the same region:

- Apply in order
- Re-resolve locator after each change

If conflict cannot be safely resolved:

- skip
- record in report

---

## Validation

After applying changes:

- Ensure file still parses (MyST / rst / markdown structure intact)
- Ensure no broken code blocks or directives
- Ensure links and anchors still valid (including GitHub line-specific links)

### GitHub line-link validation

For any GitHub URL that targets specific lines (for example `#L10-L24`):

- Verify the linked lines still contain the referenced symbol, variable, function, or relevant content the documentation is citing.
- Do not treat HTTP success or page existence as sufficient validation.
- If the line range no longer points to the intended content:
  - update the URL to the correct line range if the same source location still exists
- Preserve existing inline markup when updating the URL.

Prefer the smallest change that keeps the citation accurate.

---

## Output

### 1. Updated files (in-place)

Modify files directly in repo.

---

### 2. Change report (required)

Write:

audit-results/{timestamp}/applied-updates.md

Contents:

```markdown
## Update Summary

**Files modified:** X  
**Findings applied:** X  
**Findings skipped:** X  

### Applied

- F-001 — docs/api/authentication.md
- F-002 — docs/tutorials/send-funds.md

### Skipped

- F-005 — locator not found
- F-009 — ambiguous edit_instructions
```

---

### 3. Optional: patch output

If requested:

audit-results/{timestamp}/changes.diff

---

## Safety rules

- Never fabricate missing context
- Never guess correct values without evidence
- If new_text is null:
  - derive text strictly from expected_behavior + recommended_update
- If ambiguity remains:
  - skip and report

---

## Update grouping (optional optimization)

If update_group is present:

- Apply grouped findings together
- Maintain consistency within the group
- Still follow minimal-change rule

---

## When to stop

Stop after all actionable findings are processed.

Do not continue scanning for new issues.

---

## Example behavior

Finding:
- Replace /v1/auth → /v2/auth

Correct action:
- Replace only the endpoint string
- Do not rewrite surrounding paragraph

---

## Mental model

- Audit skill = detect + explain
- Update skill = apply + preserve

If the audit is precise, this should feel almost mechanical.
