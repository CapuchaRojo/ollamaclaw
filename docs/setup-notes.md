# Setup Notes

The intended workflow is:

1. Install Ollama outside Snap.
2. Sign in with `ollama signin`.
3. Pull the cloud model with `ollama pull qwen3.5:397b-cloud`.
4. Launch Claude Code through Ollama with `ollama launch claude --model qwen3.5:397b-cloud`.

Use `scripts/check-env.sh` to verify the local environment.

## Tested Fallback Reality

- **Cloud quota limits exist.** When exhausted, pause cloud agent work or switch to local helper mode.
- **Local models can help with direct coding questions** via `ollama run <model>`, but are not stable Claude Code fallbacks.
- **Local Claude Code fallback remains experimental/unreliable** on this machine due to tool-call JSON leakage in testing.
- **WSL memory requirement:** `qwen3-coder:30b` required increased WSL memory (~16GB) and did run, but was too slow for practical Claude Code use.
