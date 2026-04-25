# OC Command Center Workflow

## Why the Command Center Exists

Ollamaclaw has grown to include many operational scripts:

- `ollamaclaw-doctor.sh` — Health checks
- `toolchain-doctor.sh` — Tool prerequisites
- `source-truth-check.sh` — Docs/scripts/agents consistency
- `agent-inventory.sh` — Agent governance
- `release-readiness.sh` — Pre-commit/push verification
- `artifact-hygiene-check.sh` — Artifact safety
- `package-ollamaclaw.sh` — Safe ZIP packaging
- `slice-queue.sh` / `slice-closeout.sh` — Slice management
- `worktree-slice.sh` — Parallel work isolation
- `model-smoke-test.sh` / `json-leak-detector.sh` — Model validation

The **OC Command Center** (`scripts/oc`) provides a single safe wrapper to discover and run these scripts without remembering every path.

## What OC Is Not

**`scripts/oc` is NOT the Claude Code launcher.**

| Script | Purpose |
|--------|---------|
| `scripts/oc` | Operational command center — run health checks, queue slices, package artifacts |
| `scripts/ollamaclaw` | Claude Code launcher — routes Claude through Ollama Cloud |
| Individual scripts | Direct access to specific workflows |
| `.claude/commands/` | Slash commands for Claude Code interaction |

Use `scripts/oc` for operational workflows. Use `scripts/ollamaclaw` (or `oc launch-cloud`) to start Claude Code sessions.

## Command Table

| Command | Delegates To | Purpose |
|---------|--------------|---------|
| `oc help` | — | Show usage |
| `oc status` | git, slice-queue, toolchain-doctor, ollamaclaw-doctor | Fast summary |
| `oc doctor` | `ollamaclaw-doctor.sh` | Health check |
| `oc toolchain` | `toolchain-doctor.sh` | Tool prerequisites |
| `oc truth` | `source-truth-check.sh` | Docs/scripts/agents consistency |
| `oc agents` | `agent-inventory.sh` | Agent governance |
| `oc release` | `release-readiness.sh` | Pre-commit/push verification |
| `oc hygiene` | `artifact-hygiene-check.sh` | Artifact safety |
| `oc package [file]` | `package-ollamaclaw.sh` | Create safe ZIP |
| `oc queue [args]` | `slice-queue.sh` | Slice management |
| `oc closeout [args]` | `slice-closeout.sh` | Slice finalization |
| `oc worktree [args]` | `worktree-slice.sh` | Parallel work isolation |
| `oc parallel` | `parallel-safety-check.sh` | Parallel work safety |
| `oc model-smoke <model>` | `model-smoke-test.sh` | Model validation |
| `oc json-leak <file>` | `json-leak-detector.sh` | Detect raw tool-call JSON |
| `oc launch-cloud [...]` | `ollamaclaw` | Launch Claude Code |

## Safe Usage Examples

### Status Check

```bash
./scripts/oc status
```

Shows git status, next slice, and runs doctor checks without mutating state.

### Health Checks

```bash
./scripts/oc doctor
./scripts/oc toolchain
./scripts/oc truth
./scripts/oc agents
```

### Slice Queue

```bash
./scripts/oc queue list
./scripts/oc queue next
./scripts/oc queue add my-slice "Goal description"
```

### Packaging

```bash
./scripts/oc hygiene
./scripts/oc package
./scripts/oc package my-release.zip
```

After packaging, run `oc release` to verify readiness.

### Slice Closeout

```bash
./scripts/oc closeout dry-run toolchain-bootstrap-doctor
./scripts/oc closeout done toolchain-bootstrap-doctor "Summary"
```

### Launch Claude Code

```bash
./scripts/oc launch-cloud
./scripts/oc launch-cloud --model qwen3.5:397b-cloud
```

## Safety Rules

The OC Command Center enforces these constraints by design:

1. **Does not commit or push** — You must run git commands manually
2. **Does not run sudo** — No system modifications
3. **Does not create worktrees automatically** — Must explicitly invoke `oc worktree create`
4. **Does not launch Claude Code by default** — Only `oc launch-cloud` launches Claude
5. **Does not call network** — Except when delegated commands already do
6. **Does not install packages** — Use `toolchain-doctor.sh` for manual install guidance

## Workflow Integration

1. Start session: `oc status`
2. Check prerequisites: `oc toolchain`
3. Run health check: `oc doctor`
4. Verify truth: `oc truth`
5. Check agents: `oc agents`
6. Do work...
7. Before commit: `oc release`
8. Package if needed: `oc package`
9. Closeout slice: `oc closeout done <slice> "Summary"`
