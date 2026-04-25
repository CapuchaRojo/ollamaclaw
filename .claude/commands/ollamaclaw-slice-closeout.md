# Ollamaclaw Slice Closeout

Audit-first wrapper for the slice closeout workflow.

## Usage

```bash
./scripts/slice-closeout.sh dry-run <slice-name>
./scripts/slice-closeout.sh done <slice-name> "<summary>"
./scripts/slice-closeout.sh blocked <slice-name> "<reason>"
./scripts/slice-closeout.sh deferred <slice-name> "<reason>"
```

## Behavior

- **Audit-first**: Run `dry-run` before marking done to verify diagnostics pass
- **No commit/push**: Closeout updates queue status and logs, but does not commit
- **Recommend, don't act**: Suggest whether to mark done/blocked/deferred; do not mark done unless explicitly asked

## Recommended Flow

1. Run dry-run to verify diagnostics:
   ```bash
   ./scripts/slice-closeout.sh dry-run <slice-name>
   ```

2. Review diagnostic results:
   - If all PASS: Recommend `done <slice-name> "<summary>"`
   - If blocked by external dependency: Recommend `blocked <slice-name> "<reason>"`
   - If lower priority: Recommend `deferred <slice-name> "<reason>"`

3. Execute closeout only when user explicitly confirms

## See Also

- [Slice Closeout Workflow](../docs/slice-closeout-workflow.md)
- [Slice Queue Workflow](../docs/slice-queue-workflow.md)
