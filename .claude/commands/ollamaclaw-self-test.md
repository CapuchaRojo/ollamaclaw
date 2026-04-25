# Ollamaclaw Self-Test

Run the OC self-test acceptance suite to validate the command center and core workflows after major changes.

## Usage

```bash
./scripts/oc self-test       # Default mode: non-mutating checks
./scripts/oc self-test full  # Full mode: adds safe sample checks
```

## What This Does

- Validates `scripts/oc` command center exists and help output is complete
- Runs core diagnostics (toolchain, doctor, truth, agents, release)
- Confirms slice queue operations work
- Runs closeout dry-run if slices exist
- Checks parallel/worktree safety scripts
- Verifies artifact hygiene check works
- Confirms model-smoke-test.sh and json-leak-detector.sh exist

## What This Does NOT Do

- Does NOT launch Claude Code
- Does NOT create packages
- Does NOT create worktrees
- Does NOT commit or push
- Does NOT pull models
- Does NOT run sudo

## When to Run

- After every committed slice
- Before packaging/uploading ZIP
- After changing `scripts/oc` or `.claude/commands/`
- Before using parallel/worktree workflows

## Interpreting Results

| Result | Meaning | Action |
|--------|---------|--------|
| PASS | All checks passed | Safe to proceed |
| WARN | Warnings detected | Review; safe if expected (root ZIP, _bootstrap_junk, uncommitted) |
| FAIL | Hard failures | Fix before proceeding |

## Known Acceptable Warnings

- Root ZIP file (`ollamaclaw.zip` at project root)
- `_bootstrap_junk` directory exists
- Uncommitted changes during active slice

## Next Steps

If self-test passes:

1. Run `./scripts/oc release` for final pre-commit check
2. Run `./scripts/oc package` if creating upload package
3. Run `./scripts/oc closeout done <slice> "Summary"` to mark slice complete

If self-test fails:

1. Review FAIL output to identify issue
2. Run specific diagnostic (e.g., `./scripts/oc doctor`)
3. Fix issue before proceeding
