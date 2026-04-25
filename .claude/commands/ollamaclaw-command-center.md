# Ollamaclaw Command Center

**Slash command for the unified OC command center.**

## Behavior

When invoked, this slash command should:

1. **Remain audit-first** — Inspect before editing
2. **Run or interpret** `./scripts/oc status` to show current state
3. **Recommend exact `oc` subcommands** for the user's requested workflow
4. **NOT** package, launch, closeout, or create worktrees unless explicitly requested

## Usage

When the user asks about Ollamaclaw operations, health checks, or workflow guidance:

1. Run `./scripts/oc status` to show current state
2. Recommend the appropriate `oc` subcommand:
   - Health check → `./scripts/oc doctor`
   - Tool issues → `./scripts/oc toolchain`
   - Docs/scripts drift → `./scripts/oc truth`
   - Agent governance → `./scripts/oc agents`
   - Pre-commit/push → `./scripts/oc release`
   - Packaging → `./scripts/oc hygiene` then `./scripts/oc package`
   - Slice queue → `./scripts/oc queue list`
   - Slice closeout → `./scripts/oc closeout dry-run <slice>`
   - Parallel work → `./scripts/oc parallel`
   - Model testing → `./scripts/oc model-smoke <model>`
   - JSON leak check → `./scripts/oc json-leak <file>`
   - Launch Claude → `./scripts/oc launch-cloud`

## Safety

- Do not run `oc package` without explicit request
- Do not run `oc launch-cloud` without explicit request
- Do not run `oc closeout done` without explicit request
- Do not run `oc worktree create` without explicit request

## Note

`scripts/oc` is for operational workflows. `scripts/ollamaclaw` is the Claude Code launcher.
