# Setup Notes

The intended workflow is:

1. Install Ollama outside Snap.
2. Sign in with `ollama signin`.
3. Pull the cloud model with `ollama pull qwen3.5:397b-cloud`.
4. Launch Claude Code through Ollama with `ollama launch claude --model qwen3.5:397b-cloud`.

Use `scripts/check-env.sh` to verify the local environment.
