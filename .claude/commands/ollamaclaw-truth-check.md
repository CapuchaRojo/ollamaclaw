# Ollamaclaw Truth Check

Run the Ollamaclaw source truth consistency check.

## Usage

```bash
./scripts/source-truth-check.sh
```

## Purpose

This script performs a fast, non-destructive consistency check for common truth drift patterns in the Ollamaclaw harness.

## What It Checks

| Check | Type | Description |
|-------|------|-------------|
| **A. Route Wording** | FAIL if incorrect | Detects claims like "routes to Anthropic API" without Ollama Cloud clarification |
| **B. Local Fallback Claims** | WARN if risky | Flags docs claiming local models are "stable fallbacks" |
| **C. Script References** | WARN if missing | Verifies documented scripts exist and are executable |
| **D. Settings Safety** | FAIL if unsafe | Checks for dangerous auto-allow rules |
| **E. Agent Frontmatter** | FAIL if deprecated | Detects deprecated `type: subagent` and missing fields |

## Behavior

- **Audit-only**: Does not modify files
- **No cloud calls**: Only local file and git inspection
- **Non-destructive**: Does not delete, commit, or push

## Interpreting Results

| Result | Meaning | Action |
|--------|---------|--------|
| PASS | Check passed | None |
| WARN | Non-critical issue | Review, safe to proceed with caution |
| FAIL | Hard contradiction | Fix before proceeding |

## Exit Codes

- `0` — All checks passed (warnings allowed)
- `1` — Hard contradictions detected

## When to Run

- After editing docs, scripts, or agents
- Before committing changes
- Before uploading a ZIP package
- Before adding new agents

## Next Steps

After running the truth check:

1. **Review FAIL items first** — these are blockers
2. **Review WARN items** — these are non-critical but should be addressed
3. **Invoke specialist agents if needed:**
   - `source-truth-librarian` — for deep doc-to-doc contradiction audit
   - `docs-to-code-syncer` — for deep docs-vs-code sync audit
   - `git-guardian` — for pre-commit review

## Documentation

See [docs/source-truth-workflow.md](../docs/source-truth-workflow.md) for full details.
