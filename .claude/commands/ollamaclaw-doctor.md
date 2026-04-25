# Ollamaclaw Doctor

Run the Ollamaclaw preflight health check.

## Usage

```bash
./scripts/ollamaclaw-doctor.sh
```

## Purpose

This script performs a fast, non-destructive health check for the Ollamaclaw harness. It validates:

- Project structure (core files and directories)
- Agent integrity (frontmatter fields, no deprecated types)
- Settings safety (no dangerous auto-allow rules)
- Tooling availability (ollama, claude)
- Script executability
- Documentation presence
- Session log directory

## Behavior

- **Audit-only**: Does not modify files
- **No cloud calls**: Only local `ollama` CLI inspection
- **Non-destructive**: Does not delete, commit, or push

## Interpreting Results

| Result | Meaning |
|--------|---------|
| PASS | Check passed |
| WARN | Non-critical issue (safe to proceed with caution) |
| FAIL | Hard failure (fix before proceeding) |

## When to Run

- Before cloud work
- After applying patches
- Before commit
- Before uploading a zip
- After changing agents/settings/scripts

## Next Steps

After running the doctor:

1. Review any FAIL items first
2. Review WARN items
3. Proceed with specialist agents if needed:
   - `env-sentinel` for WSL/Ollama/Claude diagnosis
   - `settings-warden` for deep settings review
   - `git-guardian` for pre-commit review

## Related Checks

### Source Truth Check

If doctor reports docs/scripts drift, run:

```bash
./scripts/source-truth-check.sh
```

This checks for wording contradictions, missing scripts, and deprecated agent frontmatter. See [docs/source-truth-workflow.md](../docs/source-truth-workflow.md).

## Documentation

See [docs/doctor-workflow.md](../docs/doctor-workflow.md) for full details.
