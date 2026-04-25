# C.Src.Code Reference Map

## License/Reference-Only Status

**LICENSE:** Not found — **reference-only** artifact.

**Constraint:** Do not copy source code. Emulate concepts only.

---

## Overview

The `c.src.code` reference is the full Python source archive that preceded the Rust rewrite (`claw-code`). It contains:

- Python runtime implementation (~10K+ lines)
- Tool system, session management, permissions
- CLI entrypoints and REPL
- Plugin architecture
- Voice/skills/components submodules

**Key insight:** This is the "before" picture — the Python codebase that was ported to Rust in `claw-code`.

---

## Top-Level Structure

```
c.src.code/
├── .claude/              # Claude Code config
├── .claw/                # Claw runtime config
├── rust/                 # Rust port workspace (separate reference)
├── src/                  # Python source (~100+ files)
├── tests/                # Test helpers
├── docs/                 # Documentation
├── assets/               # Images, branding
├── c.src.code.zip        # Nested archive (ignore)
├── README.md
├── PHILOSOPHY.md         # Project intent and system design
├── USAGE.md              # Task-oriented usage guide
├── PARITY.md             # Rust port parity status
├── ROADMAP.md            # Active roadmap
├── CLAUDE.md             # Project instructions
├── Containerfile         # Docker/Podman container guidance
└── install.sh            # Installation script
```

---

## Major Runtime Surfaces

### Python Source (`src/`)

| Category | Files | Purpose |
|----------|-------|---------|
| Core runtime | `runtime.py`, `main.py`, `system_init.py` | Main event loop, CLI entry, initialization |
| Query engine | `query_engine.py`, `query.py` | Prompt processing, response handling |
| Tools | `tools.py`, `tool_pool.py`, `Tool.py` | Tool registry, execution, filtering |
| Session | `session_store.py`, `history.py`, `transcript.py` | Session persistence, transcript logging |
| Permissions | `permissions.py` | Tool permission contexts, deny lists |
| State | `state/`, `models.py` | Data models, state management |
| Components | `components/`, `screens/` | UI components, terminal rendering |
| Voice | `voice/` | Voice/audio feature modules |
| Skills | `skills/` | Skill definitions and loading |
| Plugins | `plugins/` | Plugin lifecycle and registration |
| Server | `server/`, `services/` | Backend services, API layers |
| Remote | `remote/`, `remote_runtime.py` | Remote execution support |
| migrations/ | Database/schema migrations | Data evolution |

---

## CLI Surfaces

### Main Entrypoint

```python
# src/main.py (~10K lines)
# Primary CLI and REPL coordinator
```

### Commands (`src/commands.py`, `src/cli/`)

| Command | Purpose |
|---------|---------|
| `prompt <text>` | One-shot prompt execution |
| `repl` | Interactive REPL mode |
| `status` | Runtime status display |
| `session` | Session management |
| `tools` | Tool inventory |
| `skills` | Skill listing/installation |
| `plugins` | Plugin management |

### REPL Slash Commands

The Python runtime supports slash commands similar to the Rust port:

- `/help`, `/status`, `/session`
- `/tools`, `/skills`, `/plugins`
- `/compact`, `/clear`, `/config`
- `/mcp`, `/agents`, `/doctor`

---

## Tool Surfaces

### Tool Registry (`src/tools.py`)

```python
# Tool snapshot loaded from reference_data/tools_snapshot.json
PORTED_TOOLS = load_tool_snapshot()

# Available tools include:
# - BashTool
# - FileReadTool, FileWriteTool, FileEditTool
# - GlobSearch, GrepSearch
# - WebSearch, WebFetch
# - Agent, TodoWrite, NotebookEdit
# - Skill, ToolSearch
# - MCP-related tools
```

### Tool Execution

```python
def execute_tool(name: str, payload: str = '') -> ToolExecution:
    # Returns: name, source_hint, payload, handled, message
```

### Tool Filtering

```python
def filter_tools_by_permission_context(tools, permission_context):
    # Filters tools based on deny_names and deny_prefixes
```

---

## Permission/Safety Surfaces

### Permission Context (`src/permissions.py`)

```python
@dataclass(frozen=True)
class ToolPermissionContext:
    deny_names: frozenset[str]
    deny_prefixes: tuple[str, ...]

    def blocks(self, tool_name: str) -> bool:
        # Returns True if tool is blocked by name or prefix
```

### Permission Modes

The Python runtime supports:

- **Simple mode:** Limited tool set (Bash, Read, Edit)
- **Full mode:** All tools available
- **MCP filtering:** Optional MCP tool exclusion

---

## Session/Transcript Surfaces

### Session Store (`src/session_store.py`)

```python
@dataclass(frozen=True)
class StoredSession:
    session_id: str
    messages: tuple[str, ...]
    input_tokens: int
    output_tokens: int

def save_session(session, directory) -> Path
def load_session(session_id, directory) -> StoredSession
```

### Transcript (`src/transcript.py`)

```python
@dataclass
class TranscriptStore:
    entries: list[str]
    flushed: bool

    def append(entry: str)
    def compact(keep_last: int)
    def replay() -> tuple[str, ...]
    def flush()
```

### Session Directory

```
.clang/sessions/*.json  # Per-session JSON files
```

---

## Docs/Parity/Test Surfaces

### Parity Audit (`src/parity_audit.py`)

Python script for comparing Python vs. Rust feature parity.

### Mock Harness

```
rust/MOCK_PARITY_HARNESS.md
rust/scripts/run_mock_parity_harness.sh
rust/scripts/run_mock_parity_diff.py
rust/mock_parity_scenarios.json
```

Deterministic mock service for testing CLI behavior without API calls.

### Tests

```
tests/
├── parity_scenarios.json   # Test scenario definitions
└── ...                     # Test helpers
```

---

## What Is Useful to Emulate Conceptually

| Concept | Ollamaclaw Interpretation |
|---------|---------------------------|
| Tool snapshot + filtering | Document tool behavior expectations, not implementation |
| Session JSON format | Use similar structure for future session logs |
| Permission context (deny lists) | Inform Ollamaclaw permission design |
| Transcript append/compact/replay | Pattern for session log rotation |
| CLI slash command registry | Inform agent-chain command design |
| Mock parity harness | Adapt for cloud/local model testing |
| Plugin lifecycle | Inform `.claude/agents/` extension model |

---

## What Must Not Be Copied

| Item | Reason |
|------|--------|
| Python source files | Reference-only, no LICENSE |
| Tool implementation code | Emulate behavior, don't copy logic |
| Session store implementation | Design Ollamaclaw-native approach |
| Permission system code | Concepts OK, code is not |
| CLI/REPL implementation | Ollamaclaw uses Claude Code CLI |
| Voice/skills/components | Product-specific, not harness-relevant |

---

## Reference Summary

**c.src.code** is the Python predecessor to the Rust `claw-code` port. It demonstrates:

1. **Full runtime implementation** — Python CLI with REPL, tools, sessions
2. **Permission system** — Tool filtering via deny lists and prefixes
3. **Session persistence** — JSON files with message history and token counts
4. **Transcript management** — Append, compact, replay lifecycle
5. **Plugin architecture** — Install, enable, disable, update flows
6. **Parity testing** — Mock service + scenario harness

**Ollamaclaw's approach:** Use these concepts as design inspiration, not implementation templates. Build Ollamaclaw-native solutions that leverage Claude Code's existing tool system and session management.

---

**Files inspected (representative sample):**
- `README.md`, `PHILOSOPHY.md`, `USAGE.md`, `PARITY.md`, `ROADMAP.md`
- `rust/README.md` (crate layout, CLI surface)
- `src/tools.py`, `src/permissions.py`, `src/session_store.py`, `src/transcript.py`
- `src/main.py`, `src/runtime.py`, `src/query_engine.py`

**Status:** Reference-only. No LICENSE. Concepts emulated, code not copied.
