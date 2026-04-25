# Next Five Build Lanes

## Overview

This document defines Ollamaclaw's next 5 strategic build lanes based on reference synthesis from `claw-code` and `c.src.code`.

**Constraint:** Both references have no LICENSE — reference-only. Emulate concepts, copy nothing.

---

## Lane Selection Rationale

Selected lanes prioritize:

1. **Cloud-first stability** — Strengthen the trusted path
2. **Local model safety** — Detect JSON leakage before documenting fallbacks
3. **Session evolution** — Grow from Phase 1 logs to useful transcript history
4. **Agent orchestration** — Clarify agent-chain invocation patterns
5. **Release discipline** — Audit before commit, document for clients

---

## Lane 1: Model Routing and Compatibility Hardening

### Goal

Strengthen Ollamaclaw's cloud-first model routing and clarify local model fallback boundaries.

### Why It Matters

- Cloud quota exhaustion is a recurring risk
- Local models currently leak JSON in Claude Code workflows
- Users need clear guidance on what works and what doesn't

### Reference Inspiration

| Reference | Concept | Ollamaclaw Interpretation |
|-----------|---------|---------------------------|
| claw-code | Multi-provider auto-routing | Not needed — Ollama Cloud is single router |
| claw-code | Model aliases (`opus`, `sonnet`, `haiku`) | Consider Ollamaclaw aliases for cloud models |
| c.src.code | Provider abstraction layer | Ollama Cloud handles this |

### Ollamaclaw-Native Implementation Approach

- Document cloud model aliases (if Ollama supports them)
- Clarify local helper usage boundaries
- Add quota-exhausted workflow guidance

### First Small Slice

Update `docs/provider-routing.md` with:

- Cloud model alias table (if available)
- Quota-exhausted workflow decision tree
- Local helper "safe uses" vs. "unsafe uses" clarification

### Likely Files to Create/Modify

| File | Action |
|------|--------|
| `docs/provider-routing.md` | Update with aliases and quota guidance |
| `README.md` | Update launch options section |
| `scripts/check-env.sh` | Add model alias check |

### Validation Command

```bash
./scripts/check-env.sh
ollama launch claude --model qwen3.5:397b-cloud --help
```

### Rollback Note

If aliases cause confusion, revert to explicit model names only.

### Recommended Commit Message

```
Add model alias guidance and quota-exhausted workflow

- Documents cloud model aliases (if Ollama supports them)
- Clarifies quota-exhausted decision tree
- Updates local helper safe/unsafe uses
```

### Defer / Do-Not-Do Notes

- **Defer:** Multi-provider sniffing (Ollama Cloud handles this)
- **Do not:** Auto-pull models or manage credentials
- **Do not:** Implement local fallback launchers until models pass smoke tests

---

## Lane 2: Tool Abstraction and JSON-Leak Detection

### Goal

Improve JSON-leak detection and document tool-call behavior expectations.

### Why It Matters

- Local models leak raw tool-call JSON, breaking Claude Code workflows
- Current smoke test requires manual observation
- Automated detection would speed up model evaluation

### Reference Inspiration

| Reference | Concept | Ollamaclaw Interpretation |
|-----------|---------|---------------------------|
| claw-code | `mock-anthropic-service` for deterministic testing | Consider lightweight mock for JSON-leak detection |
| c.src.code | `tools.py` snapshot + execution tracking | Document expected tool behavior, don't reimplement |
| c.src.code | `ToolPermissionContext` for filtering | Inform permission documentation |

### Ollamaclaw-Native Implementation Approach

- Enhance `model-smoke-test.sh` with automated JSON detection
- Document tool-call behavior expectations
- Consider a "tool-call sandbox" for local model testing

### First Small Slice

Add to `scripts/model-smoke-test.sh`:

- Grep for JSON patterns in output
- Auto-fail if raw JSON detected
- Log result to session log automatically

### Likely Files to Create/Modify

| File | Action |
|------|--------|
| `scripts/model-smoke-test.sh` | Add JSON-leak grep detection |
| `docs/model-smoke-tests.md` | Add automated detection docs |
| `docs/tool-abstraction.md` | Document tool-call behavior expectations |

### Validation Command

```bash
./scripts/model-smoke-test.sh qwen2.5-coder:14b 2>&1 | grep -E "FAIL|PASS"
```

### Rollback Note

If auto-detection produces false positives, revert to manual observation only.

### Recommended Commit Message

```
Add automated JSON-leak detection to smoke test

- Grep for raw JSON patterns in model output
- Auto-fail on JSON leakage detection
- Log results to session log automatically
```

### Defer / Do-Not-Do Notes

- **Defer:** Full mock service implementation (too complex for current needs)
- **Do not:** Reimplement tool wrappers (Claude Code handles this)
- **Do not:** Test all tools — focus on Read, Bash, Write as canaries

---

## Lane 3: Session Logging and Transcript Evolution

### Goal

Evolve session logging from Phase 1 Markdown logs to useful transcript history.

### Why It Matters

- Phase 1 logs capture work notes but not conversation detail
- Users need to resume past sessions
- Transcript history helps debug agent behavior

### Reference Inspiration

| Reference | Concept | Ollamaclaw Interpretation |
|-----------|---------|---------------------------|
| claw-code | `.claw/sessions/*.jsonl` with rotation | Consider JSONL option for Phase 2 |
| c.src.code | `session_store.py` + `transcript.py` | Simple append/compact/replay pattern |
| claw-code | `--resume latest|<session-id>` flag | Consider `--resume` for `ollamaclaw` script |

### Ollamaclaw-Native Implementation Approach

- Phase 2: JSONL option for structured logging
- Phase 3: Hook-based auto-logging
- Phase 3: `--resume` flag for `ollamaclaw` wrapper

### First Small Slice

Add to `scripts/session-log.sh`:

- `--json` flag for structured output
- Session naming convention (`YYYY-MM-DD-context.md`)

### Likely Files to Create/Modify

| File | Action |
|------|--------|
| `scripts/session-log.sh` | Add `--json` flag, session naming |
| `scripts/session-summary.sh` | Add `--json` parsing |
| `docs/session-log-workflow.md` | Document Phase 2 features |
| `docs/session-design.md` | Update with Phase 2 implementation |

### Validation Command

```bash
./scripts/session-log.sh --json "Test JSON output"
./scripts/session-summary.sh --json
```

### Rollback Note

If JSONL proves unnecessary, keep Markdown-only approach.

### Recommended Commit Message

```
Add Phase 2 session logging: JSONL option and session naming

- Adds --json flag for structured output
- Introduces session naming convention
- Updates workflow docs with Phase 2 guidance
```

### Defer / Do-Not-Do Notes

- **Defer:** Hook-based auto-logging (requires `.claude/settings.json` changes)
- **Defer:** `--resume` flag (depends on hook integration)
- **Do not:** Implement full transcript capture (Claude Code handles this internally)

---

## Lane 4: Slash-Command and Agent-Chain Orchestration

### Goal

Clarify agent-chain invocation patterns and document slash-command equivalents.

### Why It Matters

- 15+ subagents defined, invocation patterns need clarification
- Users need clear "which agent for which task" guidance
- Claw Code's 40+ slash commands suggest demand for command-style invocation

### Reference Inspiration

| Reference | Concept | Ollamaclaw Interpretation |
|-----------|---------|---------------------------|
| claw-code | 40+ slash commands in REPL | Claude Code `/` commands + agent tool |
| claw-code | `/subagent`, `/plugin`, `/hooks` | `.claude/agents/` system |
| c.src.code | Python slash commands | Claude Code built-in |

### Ollamaclaw-Native Implementation Approach

- Document agent-chain invocation patterns clearly
- Create "command cheat sheet" for common workflows
- Consider custom slash commands via `.claude/commands/`

### First Small Slice

Update `docs/agent-team-playbook.md`:

- Add "Quick Command Reference" section
- Document which agent chains for which scenarios
- Add troubleshooting flowchart

### Likely Files to Create/Modify

| File | Action |
|------|--------|
| `docs/agent-team-playbook.md` | Add quick command reference |
| `.claude/commands/` | Add missing workflow commands |
| `docs/agent-protocol.md` | Clarify invocation patterns |

### Validation Command

```bash
ls -la .claude/commands/
cat docs/agent-team-playbook.md | grep -A5 "Quick Command"
```

### Rollback Note

If command proliferation causes confusion, consolidate into fewer, clearer agents.

### Recommended Commit Message

```
Add agent-chain quick command reference

- Documents common invocation patterns
- Adds troubleshooting flowchart
- Clarifies which agent for which task
```

### Defer / Do-Not-Do Notes

- **Defer:** Custom slash command implementation (Claude Code built-in may suffice)
- **Do not:** Reimplement Claw Code's 40+ commands — focus on Ollamaclaw's ~15 agents
- **Do not:** Add agents without clear purpose and boundaries

---

## Lane 5: Package/Reference Audit and Release Readiness

### Goal

Establish release audit discipline before commits and client handoffs.

### Why It Matters

- Ollamaclaw hosts cross-repo audit agents for VetCan and others
- Internal release discipline should match external audit standards
- Reference audits need clear "reference-only" documentation

### Reference Inspiration

| Reference | Concept | Ollamaclaw Interpretation |
|-----------|---------|---------------------------|
| claw-code | `PARITY.md`, `ROADMAP.md`, release notes | Ollamaclaw release notes + audit summaries |
| claw-code | `release-scribe` agent | Already exists — enhance for Ollamaclaw |
| c.src.code | `parity_audit.py` | Model smoke-test harness |

### Ollamaclaw-Native Implementation Approach

- Enhance `release-scribe` for Ollamaclaw releases
- Document reference-only status clearly
- Add pre-release audit checklist

### First Small Slice

Update `docs/package-audit-checklist.md`:

- Add "reference-only" verification step
- Add LICENSE check requirement
- Add "copy nothing" confirmation

### Likely Files to Create/Modify

| File | Action |
|------|--------|
| `docs/package-audit-checklist.md` | Add reference-only verification |
| `.claude/agents/release-scribe.md` | Enhance for Ollamaclaw releases |
| `docs/reference-synthesis.md` | Already created — link from checklist |

### Validation Command

```bash
cat docs/package-audit-checklist.md | grep -A5 "reference-only"
```

### Rollback Note

If audit checklist becomes burdensome, trim to essential checks only.

### Recommended Commit Message

```
Add reference-only verification to package audit checklist

- Requires LICENSE check before using references
- Documents "copy nothing" confirmation step
- Links reference-synthesis.md for context
```

### Defer / Do-Not-Do Notes

- **Defer:** Full release automation (manual discipline sufficient for now)
- **Do not:** Publish releases to external registries yet
- **Do not:** Audit nested archives unless explicitly needed

---

## Lane Priority and Sequencing

| Lane | Priority | Estimated Effort | Dependencies |
|------|----------|------------------|--------------|
| 1. Model routing hardening | High | Low | None |
| 2. JSON-leak detection | High | Low | Lane 1 |
| 3. Session logging evolution | Medium | Medium | None |
| 4. Agent-chain orchestration | Medium | Low | None |
| 5. Release audit discipline | High | Low | None |

**Recommended order:** 1 → 2 → 5 → 3 → 4

Rationale: Strengthen cloud-first foundation (1, 2), establish release discipline (5), then evolve sessions (3) and orchestration (4).

---

## Summary

| Lane | Goal | First Slice | Files |
|------|------|-------------|-------|
| 1 | Model routing hardening | Update provider-routing.md | `docs/provider-routing.md` |
| 2 | JSON-leak detection | Auto-detect in smoke test | `scripts/model-smoke-test.sh` |
| 3 | Session logging evolution | JSONL option | `scripts/session-log.sh` |
| 4 | Agent-chain orchestration | Quick command reference | `docs/agent-team-playbook.md` |
| 5 | Release audit discipline | Reference-only verification | `docs/package-audit-checklist.md` |

---

**Next action:** Select Lane 1 for implementation, or adjust lane definitions based on review feedback.
