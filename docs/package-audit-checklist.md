# Package Audit Checklist

Use this checklist before uploading, sharing, or applying a source ZIP or manual patch package.

## 0. Run the Doctor

Before zipping or releasing, run:

```bash
./scripts/ollamaclaw-doctor.sh
```

Confirm no FAIL items. Review WARN items. Proceed only when harness is healthy.

---

## 1. Identify the package purpose

- Source snapshot
- Manual patch
- Release artifact
- Evidence/archive handoff

## 2. Inspect without applying

Use commands like:

```bash
unzip -l path/to/package.zip | sed -n '1,200p'
```

Do not unzip directly into the live project root until the package is trusted.

## 3. Confirm expected contents

Check for:

- Required source files
- Required docs
- Required scripts
- Required `.claude/agents/` or `.claude/commands/` files when relevant
- No accidental nested project folder mismatch

## 4. Block unsafe contents

Do not share or apply packages containing:

- `.env` or `.env.*`
- API keys, tokens, PEM/key files, credentials
- `.claude/settings.local.json`
- nested junk archives unless intentional
- build/cache folders such as `node_modules/`, `dist/`, `build/`, `__pycache__/`
- bootstrap leftovers such as `_bootstrap_junk/`

## 5. Verify after applying

Run:

```bash
git status --short --branch
find .claude/agents -maxdepth 1 -type f | sort 2>/dev/null || true
find .claude/commands -maxdepth 1 -type f | sort 2>/dev/null || true
./scripts/check-env.sh 2>/dev/null || true
```

## 6. Commit guidance

Use a narrow commit message matching the package purpose, for example:

```bash
git commit -m "Add zip audit workflow"
```
