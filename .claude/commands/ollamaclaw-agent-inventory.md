# Ollamaclaw Agent Inventory

## Purpose

Project slash command wrapper for agent inventory auditing.

## Behavior

- **Audit-only.** Do not modify files directly.
- Run `./scripts/agent-inventory.sh` and interpret results.
- Summarize:
  - Current agent count
  - Missing metadata (name, description, tools, model)
  - Deprecated `type: subagent` usage
  - Stale README references
- Recommend next smallest fix.
- Recommend `agent-indexer` or `agent-lint-reviewer` when deeper analysis is needed.

## Usage

```
/ollamaclaw-agent-inventory
```

## Example Output

```
=== Agent Inventory Summary ===
Agent count: 26 (excluding README.md)

Frontmatter Status:
- 24 agents pass validation
- 2 agents missing 'model:' field

README Status:
- 2 agents not listed in README.md
- 0 stale README entries

Next Smallest Fix:
Add 'model: inherit' to:
  - example-agent.md
  - another-agent.md

Recommendation:
Run agent-indexer to plan README update.
```
