# Reference Synthesis

## Overview

This document compares two Claw Code references against current Ollamaclaw structure and identifies the simplest Ollamaclaw-native interpretation of each pattern.

**References:**
1. `claw-code` — Rust rewrite (canonical runtime)
2. `c.src.code` — Python predecessor (source archive)

**Constraint:** Both references have no LICENSE — treat as **reference-only**. Emulate concepts, copy nothing.

---

## Reference Status

| Reference | Path | LICENSE | Status |
|-----------|------|---------|--------|
| claw-code | `/mnt/c/Users/mich3/GitHubProjects/_references/claw-code` | Not found | Reference-only |
| c.src.code | `/mnt/c/Users/mich3/GitHubProjects/c.src.code` | Not found | Reference-only |

---

## Overlapping Patterns

Both references share these architectural patterns:

| Pattern | claw-code (Rust) | c.src.code (Python) | Ollamaclaw Status |
|---------|------------------|---------------------|-------------------|
| **CLI binary** | `claw` (9-crate workspace) | `main.py` + REPL | Uses `claude` CLI via Ollama |
| **Tool system** | `tools` crate (Bash, Read, Write, Edit, etc.) | `tools.py` registry | Claude Code built-in tools |
| **Session persistence** | `.claw/sessions/*.jsonl` | `.port_sessions/*.json` | `.ollamaclaw/sessions/*.md` (Phase 1) |
| **Permission system** | `read-only`, `workspace-write`, `danger-full-access` | `ToolPermissionContext` (deny lists) | Claude Code permissions |
| **Plugin architecture** | `plugins` crate + lifecycle hooks | `plugins/` module | `.claude/agents/` subagents |
| **Slash commands** | 40+ commands in REPL | Python slash commands | Claude Code `/` commands + agents |
| **Mock/test harness** | `mock-anthropic-service` + parity scripts | `parity_audit.py` + scenarios | `model-smoke-test.sh` |
| **Container workflow** | `Containerfile` + bind-mount | `Containerfile` | Not implemented |
| **Documentation discipline** | `USAGE.md`, `PARITY.md`, `ROADMAP.md` | Same structure | Ollamaclaw docs growing |

---

## Key Differences

| Aspect | claw-code | c.src.code | Ollamaclaw |
|--------|-----------|------------|------------|
| **Language** | Rust (20K lines) | Python (~10K lines) | Markdown docs + Bash scripts |
| **Runtime** | Self-contained binary | Python interpreter | Claude Code CLI + Ollama Cloud |
| **Provider abstraction** | Multi-provider (Anthropic, xAI, OpenAI) | Anthropic-focused | Ollama Cloud routing only |
| **Session format** | JSONL with rotation | JSON per session | Markdown daily logs |
| **Tool execution** | Native Rust tools | Python tool wrappers | Claude Code built-in tools |
| **Extension model** | Plugins (install/enable/disable) | Plugins + Skills | Subagents (`.claude/agents/`) |
| **Human interface** | Terminal REPL + Discord (clawhip) | Terminal REPL | VS Code terminal + Discord (future) |

---

## Simplest Ollamaclaw-Native Interpretation

### 1. Model Routing

**Reference pattern:** Multi-provider sniffing with auto-routing by model prefix.

**Ollamaclaw approach:** Single Ollama Cloud routing — simpler mental model, no credential management.

**Implementation:** `docs/provider-routing.md` — cloud-first, local helpers only.

---

### 2. Tool Abstraction

**Reference pattern:** Tool registry with execution wrappers and permission filtering.

**Ollamaclaw approach:** Claude Code built-in tools — no wrapper layer needed.

**Implementation:** `docs/tool-abstraction.md` — document JSON leakage issue, smoke-test requirements.

---

### 3. Session Logging

**Reference pattern:** JSONL/JSON session files with rotation and resume support.

**Ollamaclaw approach:** Phase 1 Markdown logs — human-readable, versioned, simple.

**Implementation:** `scripts/session-log.sh`, `scripts/session-summary.sh`, `docs/session-log-workflow.md`.

**Future:** JSONL option, hook-based auto-logging, resume support.

---

### 4. Agent/Plugin Orchestration

**Reference pattern:** Plugin lifecycle (install/enable/disable/update) + slash commands.

**Ollamaclaw approach:** `.claude/agents/` subagents — Markdown definitions, no runtime code.

**Implementation:** `.claude/agents/README.md`, `docs/agent-protocol.md`, `docs/agent-team-playbook.md`.

---

### 5. Mock/Test Harness

**Reference pattern:** `mock-anthropic-service` + parity scenario scripts.

**Ollamaclaw approach:** `model-smoke-test.sh` — manual prompts, human observation for JSON leakage.

**Implementation:** `scripts/model-smoke-test.sh`, `docs/model-smoke-tests.md`.

**Future:** Automated pass/fail detection, multi-turn stress tests.

---

### 6. Container Workflow

**Reference pattern:** `Containerfile` with bind-mount, `CARGO_TARGET_DIR=/tmp/claw-target`.

**Ollamaclaw approach:** Not implemented — WSL-native workflow sufficient for now.

**Future:** If reproducibility becomes critical, add `Containerfile` for Ollamaclaw harness.

---

## Build Risks

| Risk | Severity | Mitigation |
|------|----------|------------|
| **Copying reference code** | High | Enforce "concepts only" rule, audit PRs |
| **Over-engineering** | Medium | Prefer Markdown + Bash over Rust/Python rewrites |
| **License ambiguity** | Medium | Both references lack LICENSE — reference-only status enforced |
| **Feature creep** | Medium | Stick to 5-lane roadmap, defer non-essential work |
| **Cloud quota exhaustion** | Low | Local helper fallback for non-agent work |
| **Agent overlap** | Low | `agent-lint-reviewer` checks for redundancy |

---

## "Copy Nothing, Emulate Concepts" Rule

**Enforced constraint:** Neither reference has a LICENSE file.

**What this means:**

| Allowed | Not Allowed |
|---------|-------------|
| Concept emulation | Source code copying |
| Architecture inspiration | Direct file transplantation |
| Behavior documentation | Implementation replication |
| Pattern adaptation | Binary/script transplantation |

**Audit discipline:**

1. Before implementing, ask: "Is this inspired by or copied from the reference?"
2. If copying is tempting, ask: "What is the simplest Ollamaclaw-native version?"
3. Prefer Markdown docs + Bash scripts over Rust/Python rewrites.
4. When in doubt, document the concept and defer implementation.

---

## Current Ollamaclaw Position

| Layer | Ollamaclaw Status |
|-------|-------------------|
| **Model routing** | Cloud-first (`qwen3.5:397b-cloud`), local helpers only |
| **Tool system** | Claude Code built-in (no wrapper needed) |
| **Session logging** | Phase 1 Markdown logs (`.ollamaclaw/sessions/`) |
| **Agent system** | `.claude/agents/` subagents (15+ defined) |
| **Test harness** | `model-smoke-test.sh` (manual observation) |
| **Documentation** | 12+ docs covering architecture, workflows, audits |
| **Container workflow** | Not implemented (WSL-native sufficient) |

---

## Next Strategic Lanes

See `docs/next-five-lanes.md` for the detailed 5-lane roadmap.

**Summary:**

1. **Lane 1:** Model routing and compatibility hardening
2. **Lane 2:** Tool abstraction and JSON-leak detection
3. **Lane 3:** Session logging and transcript evolution
4. **Lane 4:** Slash-command and agent-chain orchestration
5. **Lane 5:** Package/reference audit and release readiness

---

**Synthesis complete.** Both references are reference-only (no LICENSE). Ollamaclaw will emulate concepts, not copy code.
