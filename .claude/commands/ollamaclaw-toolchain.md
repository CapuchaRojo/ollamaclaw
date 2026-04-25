# Ollamaclaw Toolchain Check

## Purpose

Slash command wrapper for toolchain prerequisite checks.

## Behavior

**Audit-only.** This command runs or interprets `./scripts/toolchain-doctor.sh`.

**Never:**
- Run `sudo` commands
- Install packages automatically
- Pull models
- Launch Claude Code
- Commit or push changes

## Usage

```bash
/ollamaclaw-toolchain
```

## What This Command Does

1. Runs `./scripts/toolchain-doctor.sh`
2. Summarizes missing required vs recommended tools
3. Prints manual install commands for the user to run
4. Reports exit code and interpretation

## Manual Next Commands

If tools are missing, run these manually:

```bash
# Ubuntu/WSL base tools
sudo apt-get update
sudo apt-get install -y curl unzip zip zstd git jq python3 nodejs npm

# Ollama
curl -fsSL https://ollama.com/install.sh | sh

# Claude Code
curl -fsSL https://claude.ai/install.sh | bash
```

**Do not** ask Claude to run these commands — they require your password and should be reviewed before execution.

## When to Use

| Situation | Why |
|-----------|-----|
| Fresh WSL install | Confirm all tools present |
| Packaging fails | Check if `zip` or `zstd` missing |
| `ollama` or `claude` not found | Diagnose tool availability |
| Before deep work | Fast prerequisite check |

## Relationship to Other Commands

| Command | Relationship |
|---------|--------------|
| `/ollamaclaw-doctor` | Doctor checks project structure; toolchain checks tool availability |
| `/ollamaclaw-release` | Release readiness includes toolchain as a prerequisite |
| `/ollamaclaw-artifact` | Packaging requires `zip` — toolchain confirms it |

## Output Interpretation

| Result | Action |
|--------|--------|
| PASS (exit 0) | All tools present — proceed with work |
| WARN (exit 0) | Recommended tools missing — optional install |
| FAIL (exit 1) | Required tools missing — install before proceeding |
