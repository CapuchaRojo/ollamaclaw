# Artifact Hygiene Workflow

## Why This Workflow Exists

Ollamaclaw produces source packages for:
- Uploading to new worktrees or machines
- Sharing with collaborators
- Client handoffs
- Backup archives

Without disciplined packaging, it is easy to leak:
- Secrets (`.env*`, API keys, tokens, PEM/key files)
- Local settings (`.claude/settings.local.json`)
- Git internals (`.git/`)
- Bootstrap junk (`_bootstrap_junk/`)
- Nested archives (accidental ZIPs inside ZIPs)
- Caches and build artifacts (`node_modules/`, `__pycache__/`, `dist/`, `build/`)
- Session logs that should stay local

This workflow provides a safe, repeatable way to create source packages without manual ZIP creation or root-level clutter.

## Key Distinctions

| Concept | Definition | Where It Lives |
|---------|------------|----------------|
| **Source repo** | The Git working tree with all project files | Project root (`/mnt/c/Users/mich3/githubprojects/ollamaclaw`) |
| **Release ZIP** | A packaged source snapshot for upload/sharing | `.ollamaclaw/artifacts/ollamaclaw-YYYYMMDD-HHMMSS.zip` |
| **Uploaded source package** | A ZIP created by `package-ollamaclaw.sh` | Same as release ZIP; uploaded manually |
| **Reference archive** | Read-only reference material (Claw Code, c.src.code) | External; never modified by Ollamaclaw |

## What `package-ollamaclaw.sh` Includes

### Included (Intentional Project Files)

```
.claude/agents/
.claude/commands/
docs/
scripts/
.ollamaclaw/sessions/
.ollamaclaw/slices/
README.md
CLAUDE.md
.gitignore
```

### Excluded (Safety / Hygiene)

```
.git/
.claude/settings.local.json
.env, .env.*, *.pem, *.key
node_modules/
__pycache__/
.venv/, venv/
_bootstrap_junk/
*.tar, *.tar.gz, *.tar.zst
root-level *.zip
.ollamaclaw/artifacts/
.ollamaclaw/tmp/
*.log
.DS_Store, Thumbs.db
.vscode/, .idea/
dist/, build/
*.pyc
```

## How to Package

### Step 1: Run Artifact Hygiene Check

```bash
./scripts/artifact-hygiene-check.sh
```

Review output:
- **PASS**: Safe to package
- **WARN**: Warnings detected (root ZIPs, bootstrap junk) but safe to proceed
- **FAIL**: Hard safety risks (tracked secrets) — fix before packaging

### Step 2: Create the Package

```bash
# Default filename with timestamp
./scripts/package-ollamaclaw.sh

# Custom filename
./scripts/package-ollamaclaw.sh my-package.zip
```

Output:
- Package path: `.ollamaclaw/artifacts/my-package.zip`
- Package size
- Preview of first 80 entries
- Recommended next steps

### Step 3: Audit the Package

```bash
# Invoke zip-auditor agent
claude "Audit this package: .ollamaclaw/artifacts/my-package.zip"
```

Or manually inspect:

```bash
unzip -l .ollamaclaw/artifacts/my-package.zip | head -80
```

### Step 4: Run Release Readiness

```bash
./scripts/release-readiness.sh
```

Confirm no FAIL items. Review WARN items.

### Step 5: Upload Manually

Copy the ZIP from `.ollamaclaw/artifacts/` to your destination:
- New worktree
- Client handoff
- Backup storage

**Do not** commit the ZIP to the repo unless it is an intentional release artifact.

## Why Root ZIPs Are Discouraged

Root-level ZIP files (e.g., `ollamaclaw.zip` at project root) are warning signs because:

1. **Clutter**: They pollute the project root with transient artifacts
2. **Accidental commits**: Easy to stage and commit by mistake
3. **Unclear purpose**: May be outdated snapshots with no versioning
4. **Leak risk**: Manual ZIP creation often misses exclusion patterns

**Exception**: Intentional release ZIPs kept outside the repo for client handoff.

## zip Utility Required

The `zip` utility is required for `package-ollamaclaw.sh` to function. If packaging fails:

```bash
./scripts/toolchain-doctor.sh   # Diagnose missing zip
```

Install manually if missing:

```bash
sudo apt-get install -y zip
```

See [Toolchain Bootstrap Workflow](./toolchain-bootstrap-workflow.md) for full details.

## Why `_bootstrap_junk` Is Excluded

The `_bootstrap_junk/` directory contains:
- Temporary scaffolding from project initialization
- Files kept for historical reference only
- Structural artifacts not needed for runtime

It is excluded from packages to:
- Reduce package size
- Avoid confusion about what is canonical
- Keep packages focused on intentional project files

## How `zip-auditor` Fits

The `zip-auditor` agent:
- Inspects archive contents without extracting
- Compares against expected files
- Flags secrets, local config, nested archives, junk
- Reports PASS / WARN / BLOCKER verdict

Invoke after packaging:

```bash
claude "Audit this package: .ollamaclaw/artifacts/my-package.zip"
```

## How to Upload the Generated ZIP

1. Locate the package: `.ollamaclaw/artifacts/<filename>.zip`
2. Copy manually to destination:
   ```bash
   cp .ollamaclaw/artifacts/my-package.zip /path/to/destination/
   ```
3. Or upload via browser/SFTP/scp as needed

**Do not** use the package script to upload — it only creates the ZIP.

## Rule: Artifacts Directory Is Ignored

The `.ollamaclaw/artifacts/` directory is git-ignored (via `.gitignore`):

```
.ollamaclaw/artifacts/
.ollamaclaw/tmp/
```

This means:
- Packages are not committed to the repo
- Packages are local/transient by design
- Upload packages manually when needed
- Keep packages out of version control unless intentional release artifact

## Quick Reference

```bash
# Check hygiene
./scripts/artifact-hygiene-check.sh

# Create package
./scripts/package-ollamaclaw.sh [filename.zip]

# Audit package
unzip -l .ollamaclaw/artifacts/filename.zip | head -80

# Run release readiness
./scripts/release-readiness.sh

# Invoke zip-auditor agent
claude "Audit this package: .ollamaclaw/artifacts/filename.zip"
```
