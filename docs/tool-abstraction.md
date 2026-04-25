# Tool Abstraction

## Overview

This document explains how Claude Code tool calls flow through Ollama, documents the raw JSON leakage issue with local models, and defines smoke-test requirements for local model compatibility.

## Tool Call Flow: Cloud Mode

In cloud mode (`qwen3.5:397b-cloud`), tool calls follow this path:

```
┌─────────────┐     ┌──────────────┐     ┌─────────────────┐     ┌──────────────┐
│  Claude     │────▶│  Ollama CLI  │────▶│  Ollama Cloud   │────▶│  Anthropic   │
│  Code CLI   │     │  (local)     │     │  (proxy)        │     │  API         │
└─────────────┘     └──────────────┘     └─────────────────┘     └──────────────┘
       │                                                                │
       │  Tool call JSON                                                │
       │◀───────────────────────────────────────────────────────────────┤
       │  (parsed by Claude Code)                                       │
       ▼
┌─────────────┐
│  Tool       │
│  Execution  │
└─────────────┘
```

**Key property:** The model returns properly structured tool calls that Claude Code parses and executes. The user never sees raw tool-call JSON.

## The JSON Leakage Problem

### What Is JSON Leakage?

When a model cannot properly format tool calls, it may output **raw tool-call JSON** as text instead of structured tool invocations. Example:

```
Instead of executing: [TOOL: ReadFile path="README.md"]
The model outputs: {"name": "ReadFile", "arguments": {"path": "README.md"}}
```

This is a **Claude Code compatibility failure** — the model is printing tool invocations as text rather than executing them through the Claude Code agent protocol.

This breaks the agent workflow because:

1. Tool calls are not executed — they're printed as text
2. The conversation continues with broken context
3. The model may then try to "interpret" its own leaked JSON

To detect this issue in saved output, use the JSON leak detector:

```bash
./scripts/json-leak-detector.sh <path-to-output.txt>
```

See [JSON Leak Detection](./json-leak-detection.md) for full details.

### Observed Behavior

| Model | JSON Leakage? | Claude Code Compatible? |
|-------|---------------|-------------------------|
| `qwen3.5:397b-cloud` | No | Yes — trusted path |
| `qwen2.5-coder:14b` | Yes | No — direct helper only |
| `qwen2.5-coder:7b` | Yes | No |
| `qwen3-coder:30b` | Not fully tested | Unknown — too slow for practical use |

## Smoke Test Requirements

Before any local model can be considered Claude Code-compatible, it must pass these tests:

### 1. Basic Tool Call Test

**Prompt:** "Read the file README.md and tell me what it says"

**Pass criteria:**
- File is actually read (not hallucinated)
- No raw JSON appears in output
- Tool executes silently, result is used

### 2. Multi-Turn Tool Chain Test

**Prompt:** "List all .md files in docs/, read the first one, then summarize it"

**Pass criteria:**
- Glob tool executes correctly
- ReadFile tool executes correctly
- Summary is coherent and uses actual file content
- No JSON leakage at any turn

### 3. Write/Edit Safety Test

**Prompt:** "Create a test file called test.txt with content 'hello'"

**Pass criteria:**
- WriteFile tool executes (file is created)
- No raw JSON in output
- Model confirms the action in natural language

### 4. Error Handling Test

**Prompt:** "Read a file that doesn't exist"

**Pass criteria:**
- Error is caught and reported
- Model adapts gracefully (doesn't crash or loop)
- No JSON leakage under error conditions

### 5. Session Continuity Test

**Prompt:** Multi-turn conversation with 5+ tool calls

**Pass criteria:**
- Context is maintained across turns
- Tool results are correctly referenced later
- No degradation in tool formatting over time

## Why qwen3.5:397b-cloud Is the Trusted Path

1. **Passes all smoke tests** — Tool calls are properly structured and executed
2. **No JSON leakage observed** — Claude Code receives parsable tool invocations
3. **Full agent workflows work** — Multi-turn, multi-tool conversations succeed
4. **Managed by Ollama Cloud** — Model behavior is consistent and monitored

## Local Model Guidance

### Safe Uses

- Direct coding questions: `ollama run qwen2.5-coder:14b`
- Code explanation and review
- Algorithm design and pseudocode
- Learning and experimentation

### Unsafe Uses

- Claude Code agent workflows
- Multi-turn tool conversations
- File read/write operations via Claude Code
- Any workflow requiring reliable tool execution

## Smoke Test Harness

A repeatable smoke-test script is available for evaluating local models:

```bash
./scripts/model-smoke-test.sh <model-name>
```

This script:
- Verifies `ollama` and `claude` commands exist
- Confirms the model is installed
- Prints the exact launch command
- Provides 5 test prompts (no-tool baseline, read tool, repo inspection, agent awareness, failure detection)
- Does **NOT** launch Claude Code automatically (manual testing required)

See [Model Smoke Tests](./model-smoke-tests.md) for full procedure and recorded results.

## Future Considerations

If a local model passes all smoke tests:

1. Document it in [Model Smoke Tests](./model-smoke-tests.md) with test results
2. Add to [Provider Routing](./provider-routing.md) as an approved fallback
3. Update CLAUDE.md model guidance
4. Consider auto-test harness for repeatable validation

## Related Docs

- [Provider Routing](./provider-routing.md) — Cloud vs local model strategy
- [Launcher Patterns](./launcher-patterns.md) — How to launch different models
- [Session Design](./session-design.md) — How tool calls are logged
- [JSON Leak Detection](./json-leak-detection.md) — How to detect raw tool-call JSON leakage
