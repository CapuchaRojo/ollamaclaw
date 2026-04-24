# Ollamaclaw Health Check

Run a lightweight harness health audit for Ollamaclaw.

Target/context: `$ARGUMENTS`

Instructions:
1. Use `scope-lock` to lock the goal: health check only, no edits.
2. Use `env-sentinel` to inspect WSL, Ollama, Claude Code, Git, PATH, versions, and project location.
3. If WSL/Windows path issues appear, use `wsl-mechanic` for diagnosis only.
4. If routing/model issues appear, use `ollama-route-verifier` for diagnosis only.
5. Report blockers, exact commands to fix, and a prevention rule.

Constraints:
- Do not edit files.
- Do not commit.
- Do not run long model tests.
