# OC Self-Test Workflow

## Why Self-Test Exists

Ollamaclaw has grown to include many operational scripts and a unified command center (`scripts/oc`). After major harness changes, you need a fast, non-destructive way to validate:

1. The command center itself is working correctly
2. Core diagnostic scripts execute without errors
3. Slice queue and closeout workflows are functional
4. Parallel/worktree safety checks are operational
5. Artifact hygiene and JSON leak detection tools are present

The **OC Self-Test** suite provides automated acceptance testing without launching Claude Code, creating packages, or mutating state.

## What Self-Test Is NOT

| Concept | Self-Test | Reality |
|---------|-----------|---------|
| **Doctor** | Runs doctor as one check | `ollamaclaw-doctor.sh` validates project structure, agents, settings |
| **Release Readiness** | Runs release as one check | `release-readiness.sh` validates pre-commit/push/package safety |
| **OC Status** | Runs status-like checks | `oc status` shows git, slice queue, doctor summary |
| **Model Smoke Test** | Confirms script exists | Does NOT pull models or run actual smoke tests by default |
| **Package Test** | Does NOT create packages | Package creation requires explicit `PACKAGE_TEST_MODE=1` |
| **Integration Test** | Does NOT launch Claude Code | Self-test never invokes Claude Code or calls network |

## When to Run

Run `./scripts/oc self-test` in these situations:

| Situation | Mode | Why |
|-----------|------|-----|
| **After every committed slice** | default | Confirm command center and core scripts still work |
| **Before packaging/uploading ZIP** | default | Verify harness health before creating artifacts |
| **After changing `scripts/oc`** | default or full | Validate command dispatch and help output |
| **After changing `.claude/commands/`** | default | Confirm slash command routing is intact |
| **Before using parallel/worktree workflows** | default | Verify safety checks are operational |
| **After adding new operational scripts** | full | Test JSON leak detector samples, deeper validation |
| **Before client handoff** | full | Full acceptance suite for confidence |

## Default vs Full Mode

### Default Mode

```bash
./scripts/oc self-test
```

Runs non-mutating checks only:

- Command center existence and help output
- Core diagnostics (toolchain, doctor, truth, agents, release)
- Slice queue list/next operations
- Closeout dry-run (if slices exist)
- Parallel/worktree safety checks
- Artifact hygiene check
- Confirms model-smoke-test.sh and json-leak-detector.sh exist

### Full Mode

```bash
./scripts/oc self-test full
```

Includes all default checks PLUS:

- JSON leak detector sample tests (leak detection + clean input)
- Deeper validation of script outputs

**Neither mode:**
- Launches Claude Code
- Creates packages (unless `PACKAGE_TEST_MODE=1` explicitly set)
- Creates worktrees
- Commits or pushes
- Pulls models
- Runs sudo
- Calls network

## How to Run

### Basic Usage

```bash
# Default mode: fast, non-destructive
./scripts/oc self-test

# Full mode: adds sample checks
./scripts/oc self-test full

# Via command center
./scripts/oc self-test
./scripts/oc self-test full
```

### Slash Command

```bash
/ollamaclaw-self-test
```

The slash command runs default mode and summarizes results. Use `./scripts/oc self-test full` for deeper validation.

## Interpreting Results

### PASS

```
RESULT: PASS - All self-test checks passed.
```

All checks passed. The command center and core workflows are functional.

**Action:** Safe to proceed with packaging, closeout, or next slice.

### WARN

```
RESULT: WARN - Warnings detected. Safe to proceed with caution.
```

Warnings detected but no hard failures. Common acceptable warnings:

- Root ZIP file present (`ollamaclaw.zip` at project root)
- `_bootstrap_junk` directory exists
- Uncommitted changes in working tree
- No planned slices in queue

**Action:** Review warnings. Safe to proceed if warnings are expected.

### FAIL

```
RESULT: FAIL - Hard failures detected. Fix before proceeding.
```

Hard failures detected. Examples:

- `scripts/oc` missing or not executable
- Core diagnostic scripts report FAIL
- Command center help output missing expected commands
- JSON leak detector missing or not executable

**Action:** Fix failures before proceeding. Script exits with code 1.

## Known Acceptable Warnings

These warnings are expected and do not block progress:

| Warning | Why Acceptable | When to Fix |
|---------|----------------|-------------|
| `Root ZIP file found: ollamaclaw.zip` | May be intentional local artifact | If unintentional, remove or move to `.ollamaclaw/artifacts/` |
| `_bootstrap_junk directory exists` | Historical scaffolding kept for reference | If cleaning up, use `artifact-hygiene-check.sh` guidance |
| `Uncommitted changes in working tree` | Expected during active slice work | Commit before release/package |
| `No planned slices` | Queue may be empty between slices | Add slices via `oc queue add` |

## What Self-Test Intentionally Does NOT Do

| Constraint | Rationale |
|------------|-----------|
| Does NOT launch Claude Code | Self-test should work without quota or model access |
| Does NOT create packages | Package creation is a separate, intentional action |
| Does NOT create worktrees | Worktrees are for parallel implementation |
| Does NOT commit or push | Git operations are auditable, separate actions |
| Does NOT pull models | Model pulls are slow and quota-consuming |
| Does NOT run sudo | No system modifications needed |
| Does NOT call network | Self-test should work offline |

## Output Format

Self-test prints:

```
OC Self-Test Suite
Mode: default
Project Root: /path/to/ollamaclaw

=== A. Command Center ===
[PASS] scripts/oc exists and is executable
[PASS] oc help contains 'status'
...

=== B. Core Diagnostics ===
--- toolchain ---
[PASS] toolchain-doctor reported PASS
...

============================================
OC SELF-TEST SUMMARY
============================================
  PASS: 25
  WARN: 2
  FAIL: 0

RESULT: WARN - Warnings detected. Safe to proceed with caution.
```

## Integration with Other Workflows

| Workflow | Integration Point |
|----------|-------------------|
| **Doctor** | Self-test runs `oc doctor` as check B |
| **Release Readiness** | Self-test runs `oc release` as check B |
| **Slice Closeout** | Self-test runs closeout dry-run as check D |
| **Artifact Hygiene** | Self-test runs `oc hygiene` as check F |
| **Command Center** | Self-test validates command center as check A |

## Recommended Sequence

After a committed slice:

```
1. Run self-test
   ./scripts/oc self-test

2. If WARN, review warnings
   # Known acceptable: root ZIP, _bootstrap_junk, uncommitted

3. If FAIL, fix before proceeding
   # Fix hard failures first

4. Run release readiness
   ./scripts/oc release

5. Package if needed
   ./scripts/oc package

6. Closeout slice
   ./scripts/oc closeout done <slice-name> "Summary"
```

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | PASS or WARN (safe to proceed) |
| 1 | FAIL (hard failures detected) |

## Troubleshooting

### "scripts/oc missing or not executable"

Ensure the command center script exists and has execute permission:

```bash
ls -la scripts/oc
chmod +x scripts/oc
```

### "oc help missing 'command'"

The command center help output is missing an expected command. This may indicate:

- Recent edit to `scripts/oc` removed a command
- Help text is out of sync with actual commands
- Typo in help output

Fix by updating `scripts/oc` help function.

### "Core diagnostic reported FAIL"

Run the specific diagnostic to see details:

```bash
./scripts/oc doctor    # For doctor failure
./scripts/oc toolchain # For toolchain failure
./scripts/oc truth     # For truth failure
./scripts/oc release   # For release failure
```

### "JSON leak detector missing"

Ensure `scripts/json-leak-detector.sh` exists and is executable:

```bash
ls -la scripts/json-leak-detector.sh
chmod +x scripts/json-leak-detector.sh
```
