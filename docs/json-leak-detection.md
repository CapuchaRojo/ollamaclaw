# JSON Leak Detection

## Why This Detector Exists

Ollamaclaw uses a **cloud-first** model strategy with `qwen3.5:397b-cloud` as the trusted path for Claude Code workflows.

Local models have been tested as potential fallbacks, but several have **leaked raw tool-call JSON** when used with Claude Code, breaking the agent workflow.

### Tested Failure Examples

| Model | Date | Failure Mode |
|-------|------|--------------|
| `qwen2.5-coder:7b` | 2026-04 | Leaked raw tool-call JSON on simple README read tasks |
| `qwen2.5-coder:14b` | 2026-04 | Leaked raw tool-call JSON on file read operations |

### What Is JSON Leakage?

When a model cannot properly format tool calls for Claude Code, it outputs **raw JSON as text** instead of structured tool invocations:

**Expected behavior (Claude Code executes tool silently):**
```
Ollamaclaw is a WSL + VS Code project for running Claude Code through Ollama cloud models...
```

**JSON leakage (FAIL - model prints tool call as text):**
```json
{"name": "Read", "arguments": {"file_path": "README.md"}}
```

This breaks the workflow because:
1. Tool calls are printed as text, not executed
2. Conversation context becomes corrupted
3. Model may try to "interpret" its own leaked JSON

## How to Use the Detector

### Save Claude Code Output Manually

1. Run your Claude Code session with the model under test:
   ```bash
   ollama launch claude --model <model-name>
   ```

2. Copy the full output (including any JSON that appears) to a text file:
   ```bash
   # Option A: Redirect output if running in script
   ollama launch claude --model <model-name> > /tmp/claude-output.txt

   # Option B: Copy/paste from terminal into a file
   ```

3. Scan the output for leaks:
   ```bash
   ./scripts/json-leak-detector.sh /tmp/claude-output.txt
   ```

### Pipe Output Directly

```bash
cat /tmp/claude-output.txt | ./scripts/json-leak-detector.sh -
```

## Understanding Results

### PASS

```
[PASS] No leak patterns detected
```

**Meaning:** No raw tool-call JSON patterns were found in the output.

**Action:** Model may be safe for Claude Code workflows, but manual review is still recommended.

### FAIL

```
[FAIL] Likely raw tool-call JSON detected

Matched patterns:
  - Pattern: "name":\s*"Read"
  - Pattern: "arguments":\s*\{
  - Raw JSON tool-call object detected
```

**Meaning:** The output contains patterns consistent with raw tool-call JSON leakage.

**Action:** This model is **NOT safe** for Claude Code workflows. Do not use it for agent-based tasks.

### WARN

```
[WARN] Empty input
```

**Meaning:** No content was provided to scan.

**Action:** Provide a non-empty file or stdin input.

## False Positive Limitations

This detector is **heuristic** and may produce false positives:

1. **Legitimate JSON discussion**: If Claude Code output includes JSON examples in documentation or code samples, these may trigger patterns.

2. **Partial matches**: The detector looks for suspicious patterns but cannot fully understand context.

3. **Escaped JSON**: JSON strings that appear in normal conversation (e.g., explaining a concept) may trigger detection.

**Recommendation:** Always review flagged output manually. The detector is a screening tool, not a definitive judge.

## Relation to Model Smoke Tests

The JSON leak detector is part of the broader [Model Smoke Tests](./model-smoke-tests.md) workflow:

1. Run smoke test prompts manually with a model
2. Save the Claude Code output to a file
3. Scan with the JSON leak detector
4. Record PASS/FAIL result in session logs

### Integration Point

```bash
# After running smoke test prompts:
./scripts/json-leak-detector.sh /tmp/smoke-test-output.txt

# Log the result:
./scripts/session-log.sh "JSON leak test: <model> = PASS/FAIL because ..."
```

## Logging Outcomes

Use the session log script to record test outcomes:

```bash
# Pass example
./scripts/session-log.sh "JSON leak test: qwen3.5:397b-cloud = PASS (no raw tool-call JSON detected)"

# Fail example
./scripts/session-log.sh "JSON leak test: qwen2.5-coder:14b = FAIL because leaked raw tool-call JSON on README read task"
```

View logged results:

```bash
./scripts/session-summary.sh
```

## Detected Patterns

The detector scans for these patterns:

| Pattern | Indicates |
|---------|-----------|
| `"name": "Read"` | Read tool call as text |
| `"name": "Bash"` | Bash tool call as text |
| `"name": "Write"` | Write tool call as text |
| `"name": "Edit"` | Edit tool call as text |
| `"name": "ReadFile"` | ReadFile tool call as text |
| `"name": "WriteFile"` | WriteFile tool call as text |
| `"name": "EditFile"` | EditFile tool call as text |
| `"name": "Glob"` | Glob tool call as text |
| `"name": "Grep"` | Grep tool call as text |
| `"arguments": {` | Tool arguments object |
| `{"name": "...", "arguments": ...}` | Complete raw tool-call JSON object |

## Related Docs

- [Model Smoke Tests](./model-smoke-tests.md) — Full smoke test procedure
- [Tool Abstraction](./tool-abstraction.md) — Why JSON leakage breaks Claude Code
- [Session Log Workflow](./session-log-workflow.md) — How to log test results
