# Ollamaclaw Route Check

Check whether Claude Code is routed through the intended Ollama model.

Target/context: `$ARGUMENTS`

Instructions:
1. Use `ollama-route-verifier` to inspect intended model route, `ollama list`, `ollama ps`, and launch command.
2. Use `model-route-advisor` to recommend cloud vs local/direct-helper strategy based on quota and task type.
3. Clearly distinguish cloud Claude Code work from local `ollama run` helper usage.

Constraints:
- Do not pull models.
- Do not delete models.
- Do not edit files.
- Do not run long Claude Code sessions.
