# Model Smoke Tests

## Why This Exists

Ollamaclaw uses a **cloud-first** model strategy:

- **Trusted path:** `qwen3.5:397b-cloud` for full-stack Claude Code workflows
- **Local models:** Reserved for direct coding help only (not Claude Code agent workflows)

**Reason:** Local models tested so far have leaked raw tool-call JSON when used with Claude Code, breaking the agent workflow.

This document defines the smoke-test procedure to evaluate whether a local model can safely be used with Claude Code.

## Tested Results So Far

| Model | Status | Reason |
|-------|--------|--------|
| `qwen3.5:397b-cloud` | **PASS** (Trusted) | No JSON leakage, full agent workflows work |
| `qwen2.5-coder:7b` | **FAIL** | Leaked raw tool-call JSON on simple tasks |
| `qwen2.5-coder:14b` | **FAIL** | Leaked raw tool-call JSON on README read |
| `qwen3-coder:30b` | **FAIL** (practical) | Technically ran after WSL memory tuning (~16GB + 16GB swap), but too slow for practical workflows |

## JSON Leak Detector

For automated scanning of Claude Code output, use:

```bash
./scripts/json-leak-detector.sh <path-to-output.txt>
```

**Usage:**
```bash
# Scan a file
./scripts/json-leak-detector.sh /tmp/claude-output.txt

# Or pipe from stdin
cat /tmp/claude-output.txt | ./scripts/json-leak-detector.sh -
```

**Results:**
- **PASS** (exit 0) - No raw tool-call JSON patterns detected
- **FAIL** (exit 1) - Raw tool-call JSON detected

See [JSON Leak Detection](./json-leak-detection.md) for full details, false positive limitations, and how to log outcomes.

## What Is JSON Leakage?

When a model cannot properly format tool calls, it outputs **raw tool-call JSON as text** instead of structured tool invocations:

**Expected behavior:**
```
[Model executes ReadFile tool silently, then responds:]
"Ollamaclaw is a WSL + VS Code project for running Claude Code through Ollama cloud models..."
```

**JSON leakage (FAIL):**
```
{"name": "ReadFile", "arguments": {"path": "README.md"}}
```

This breaks the agent workflow because:
1. Tool calls are printed as text, not executed
2. Conversation context breaks
3. Model may try to "interpret" its own leaked JSON

## Pass/Fail Criteria

### Pass Requirements

A model must pass **all** tests to be considered Claude Code-compatible:

| Test | Pass Criteria |
|------|---------------|
| A. No-Tool Baseline | Replies with exactly "READY", no tool usage |
| B. Read Tool Test | File is read, summary uses actual content, **no raw JSON** |
| C. No-Edit Repo Inspection | `git status` runs, accurate summary, **no raw JSON** |
| D. Agent Awareness | Reads file, lists categories accurately, **no raw JSON** |
| E. Error Handling | Graceful error reporting, **no JSON leakage under errors** |

### Fail Conditions

A model **fails** if it:

- Prints raw JSON like `{ "name": "ReadFile", "arguments": {...} }`
- Hallucinates file contents instead of reading
- Refuses to use tools entirely
- Crashes or loops on error conditions
- Degrades to JSON leakage after multiple turns

## Manual Test Procedure

### Step 1: Run the Smoke Test Script

```bash
./scripts/model-smoke-test.sh <model-name>
```

This verifies prerequisites and prints the test prompts.

### Step 2: Launch Claude Code Manually

```bash
ollama launch claude --model <model-name>
```

### Step 3: Run Each Test Prompt

Copy/paste each prompt from the script output. Observe:

- Does the model use tools correctly?
- Does raw JSON appear in output?
- Does the model hallucinate or read accurately?
- Does behavior degrade over multiple turns?

### Step 4: Scan for JSON Leaks

Save the Claude Code output to a file and scan it:

```bash
./scripts/json-leak-detector.sh <path-to-output.txt>
```

See [JSON Leak Detection](./json-leak-detection.md) for details.

### Step 5: Record the Result

```bash
./scripts/session-log.sh "Model smoke test: <model> = PASS/FAIL because <reason>"
```

**Example:**
```bash
./scripts/session-log.sh "Model smoke test: qwen2.5-coder:14b = FAIL because leaked raw tool-call JSON on README read task"
```

## How to Use This Script

### Check a Model Before Documenting It

```bash
./scripts/model-smoke-test.sh qwen2.5-coder:14b
```

### Verify Prerequisites

The script checks:
- `ollama` command exists
- `claude` command exists
- Model is installed locally

### What the Script Does NOT Do

- Does **NOT** launch Claude Code automatically (manual testing required)
- Does **NOT** pull models (you must install first)
- Does **NOT** delete models
- Does **NOT** call cloud APIs (local checks only)
- Does **NOT** pass/fail automatically (human observation required)

## Recording Results

Use session logging to track test outcomes:

```bash
# Pass example
./scripts/session-log.sh "Model smoke test: qwen3.5:397b-cloud = PASS (cloud model, no JSON leakage)"

# Fail example
./scripts/session-log.sh "Model smoke test: qwen2.5-coder:14b = FAIL because leaked raw tool-call JSON on README read"

# Slow-but-technical-pass example
./scripts/session-log.sh "Model smoke test: qwen3-coder:30b = FAIL (practical) — technically ran but too slow for workflows after WSL memory tuning"
```

View results:

```bash
./scripts/session-summary.sh
```

## Future Considerations

If a local model passes all smoke tests:

1. **Document it here** with test date and results
2. **Add to Provider Routing docs** as an approved fallback
3. **Update CLAUDE.md** model guidance
4. **Consider auto-test harness** for repeatable validation

### Potential Auto-Test Enhancements (Not Implemented)

| Enhancement | Status |
|-------------|--------|
| Structured JSONL output | Future consideration |
| Automated pass/fail detection | Future consideration |
| Multi-turn stress test | Future consideration |
| Tool-call latency measurement | Future consideration |

## Related Docs

- [Tool Abstraction](./tool-abstraction.md) — Full explanation of JSON leakage problem
- [Provider Routing](./provider-routing.md) — Cloud vs local model strategy
- [Session Log Workflow](./session-log-workflow.md) — How to log test results
- [Launcher Patterns](./launcher-patterns.md) — How to launch different models
