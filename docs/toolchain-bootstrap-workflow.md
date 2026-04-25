# Toolchain Bootstrap Workflow

## Why This Workflow Exists

Ollamaclaw depends on a set of WSL tools for packaging, model routing, and Claude Code orchestration. When a required tool is missing, workflows fail in confusing ways:

- `package-ollamaclaw.sh` fails silently if `zip` is missing
- `ollama` or `claude` commands fail if not installed or not in PATH
- Scripts break if `curl`, `unzip`, or `zstd` are absent

This workflow provides:

1. A fast diagnostic to detect missing tools **before** deep work begins.
2. Safe, manual install guidance — **no sudo auto-execution**.
3. Clear separation between required vs recommended tools.

## Required vs Recommended Tools

### Required (Hard Dependency)

These tools must be present for Ollamaclaw to function:

| Tool | Purpose |
|------|---------|
| `bash` | Script runtime |
| `git` | Version control |
| `curl` | Downloads, model installs |
| `unzip` | Extract archives |
| `zip` | Create source packages |
| `zstd` | Compressed archives |
| `ollama` | Model routing |
| `claude` | Claude Code CLI |

### Recommended (Soft Dependency)

These tools improve the workflow but are not strictly required:

| Tool | Purpose |
|------|---------|
| `node` / `npm` | JavaScript tooling |
| `python3` | Python scripts |
| `jq` | JSON processing |
| `gh` | GitHub CLI |
| `code` | VS Code CLI |

## Why OC Should NOT Run sudo Automatically

The toolchain doctor **prints** install commands but **never executes them**. This is intentional:

1. **Security**: sudo requires an interactive password — automating it would require storing credentials.
2. **Transparency**: Users should see and understand each command before running it.
3. **Safety**: Auto-install could break existing setups or install unwanted packages.
4. **WSL Complexity**: WSL may have different PATH, snap vs apt conflicts, or enterprise restrictions.

**Rule:** Ollamaclaw agents and scripts must never run `sudo` or package-manager commands automatically.

## How to Run

```bash
./scripts/toolchain-doctor.sh
```

This script:

- Checks required and recommended tool availability
- Prints version info where safe
- Reports WSL context (path, memory)
- Prints manual install commands if tools are missing
- Exits non-zero if required tools are missing

## Manual Install Commands

If the doctor reports missing tools, run these manually:

### Ubuntu/WSL Base Tools

```bash
sudo apt-get update
sudo apt-get install -y curl unzip zip zstd git jq python3 nodejs npm
```

### Ollama

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

### Claude Code

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

**Important:** Review each command before running. Do not copy-paste blindly.

## Relationship to Other Workflows

### ollamaclaw-doctor.sh

The doctor checks project structure, agent integrity, settings safety, and tooling presence. It confirms `ollama` and `claude` exist but does not check the full toolchain.

**Run toolchain-doctor when:**
- Doctor reports tooling warnings
- Packaging fails due to missing `zip` or `zstd`
- Starting on a fresh WSL install

### artifact-hygiene-check.sh

This script checks for root-level ZIPs, bootstrap junk, and nested archives. It assumes `zip` is available.

**If `zip` is missing:**
1. Run `toolchain-doctor.sh`
2. Install `zip` manually
3. Re-run `artifact-hygiene-check.sh`

### package-ollamaclaw.sh

The packaging script requires `zip`. If `zip` is missing, the script will fail.

**Before packaging:**
1. Run `toolchain-doctor.sh`
2. Confirm `zip` and `zstd` are present
3. Run `package-ollamaclaw.sh`

### model-smoke-test.sh

Smoke tests require `ollama` and a working model route. If `ollama` is missing or broken:

1. Run `toolchain-doctor.sh`
2. Install `ollama` manually
3. Run `ollama --version` to confirm
4. Proceed with smoke test

### release-readiness.sh

The release readiness wrapper runs doctor, source-truth, and agent inventory. If tooling checks fail:

1. Run `toolchain-doctor.sh` for detailed diagnosis
2. Install missing tools
3. Re-run `release-readiness.sh`

## Troubleshooting

### zip missing

**Symptom:** `package-ollamaclaw.sh` fails with "zip: command not found"

**Fix:**
```bash
sudo apt-get install -y zip
```

### zstd missing

**Symptom:** Archive extraction fails or `zstd` command not found

**Fix:**
```bash
sudo apt-get install -y zstd
```

### claude installed but not in PATH

**Symptom:** `claude --version` fails but Claude Code was installed

**Fix:**
```bash
# Check if installed in ~/.local/bin
ls -la ~/.local/bin/claude

# Add to PATH if needed
export PATH="$HOME/.local/bin:$PATH"

# Make permanent in ~/.bashrc
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### ollama snap vs official install

**Symptom:** `ollama` exists but behaves unexpectedly or version mismatches

**Diagnosis:**
```bash
which ollama
# /snap/bin/ollama = snap install
# /usr/local/bin/ollama = official install
```

**Recommendation:** Use the official install script for WSL:
```bash
curl -fsSL https://ollama.com/install.sh | sh
```

### PowerShell vs WSL command confusion

**Symptom:** Commands work in PowerShell but not WSL, or vice versa

**Explanation:**
- PowerShell and WSL have separate PATH environments
- Tools installed in Windows (`C:\Program Files\...`) may not be visible in WSL
- Tools installed in WSL (`/usr/bin/...`) are not visible in PowerShell

**Fix:**
- Install tools inside WSL for WSL workflows
- Use `wsl` prefix from PowerShell to run WSL commands
- Use `/mnt/c/...` paths in WSL to access Windows files

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | All required tools present (warnings allowed for recommended) |
| 1 | Required tools missing — install before proceeding |

## Example Output

```
=== A. Required Tools ===
[PASS] bash found: GNU bash, version 5.1.16(1)-release
[PASS] git found: git version 2.34.1
[PASS] curl found: curl 7.81.0 (x86_64-pc-linux-gnu)
...
[FAIL] zip missing (required)

=== B. Recommended Tools ===
[PASS] node found: v18.19.0
[WARN] jq missing (recommended)
...

=== C. WSL Context ===
uname -a:
Linux hostname 6.6.87.2-microsoft-standard-WSL2 #1 SMP PREEMPT_DYNAMIC ...
pwd: /mnt/c/Users/mich3/githubprojects/ollamaclaw
[INFO] Running under /mnt/c — Windows-mounted path is expected for this project.

Available memory:
              total        used        free      shared  buff/cache   available
Mem:            15Gi       1.2Gi        11Gi       128Mi       3.1Gi        14Gi

=== D. Manual Install Guidance ===
Missing tools detected. Run these commands manually (DO NOT auto-execute):

Missing REQUIRED tools: zip

=== Ubuntu/WSL ===
  sudo apt-get update
  sudo apt-get install -y curl unzip zip zstd git jq python3 nodejs npm

=== Ollama ===
  curl -fsSL https://ollama.com/install.sh | sh

=== Claude Code ===
  curl -fsSL https://claude.ai/install.sh | bash

IMPORTANT: Do NOT execute these commands automatically.
Review each command, understand what it does, then run manually if needed.

=== TOOLCHAIN DOCTOR SUMMARY ===
  PASS: 14
  WARN: 1
  FAIL: 1

RESULT: Hard failures detected. Install missing required tools before proceeding.
```
