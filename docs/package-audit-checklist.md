# Package Audit Checklist

Use this checklist before uploading, sharing, or applying a source ZIP or manual patch package.

## 0. Run Release Readiness (First)

Before zipping or releasing, run the release readiness check:

```bash
./scripts/release-readiness.sh
```

Confirm no FAIL items. Review WARN items. Proceed only when harness is healthy.

## 0a. Run the Doctor

```bash
./scripts/ollamaclaw-doctor.sh
```

Confirm no FAIL items. Review WARN items.

## 0b. Run Source Truth Check

```bash
./scripts/source-truth-check.sh
```

Confirm no FAIL items (wording drift, missing scripts, deprecated agent frontmatter). Fix any contradictions before packaging.

## 0c. Reference-Only / LICENSE Verification

Before packaging any reference-derived work:

- [ ] Confirm `docs/reference-synthesis.md` states reference-only / copy-nothing stance.
- [ ] Confirm `docs/c-src-reference-map.md` states reference-only / copy-nothing stance.
- [ ] If LICENSE is missing from referenced sources (Claw Code, c.src.code), verify docs say "reference-only / concept emulation / no copying".
- [ ] Never package code copied from Claw Code or c.src.code unless license explicitly allows it.
- [ ] Current Ollamaclaw stance: references are concept-only, not code-derived.

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

## 7. Safe to Zip/Share Checklist

Final confirmation before packaging or handoff:

- [ ] `./scripts/artifact-hygiene-check.sh` reports PASS (or acceptable WARNs)
- [ ] `./scripts/release-readiness.sh` reports PASS (or acceptable WARNs)
- [ ] `./scripts/ollamaclaw-doctor.sh` reports no FAIL items
- [ ] `./scripts/source-truth-check.sh` reports no FAIL items
- [ ] `./scripts/agent-inventory.sh` reports all agents valid
- [ ] Reference-only docs confirm copy-nothing stance for Claw Code / c.src.code
- [ ] No `.env*`, `.claude/settings.local.json`, `*.pem`, `*.key` files in package
- [ ] No nested ZIP files unless intentional
- [ ] No `_bootstrap_junk/` or build/cache folders
- [ ] `zip-auditor` agent reports PASS or PASS WITH NOTES

## 8. Creating the Package

**Use the package script instead of manual ZIP creation:**

```bash
./scripts/package-ollamaclaw.sh [filename.zip]
```

This creates a safe source package with proper exclusions:
- Secrets and local settings excluded
- Git internals excluded
- Bootstrap junk excluded
- Nested archives excluded
- Output goes to `.ollamaclaw/artifacts/` (git-ignored)

**Do not** create root-level ZIPs manually. Use `./scripts/package-ollamaclaw.sh` for all upload packages.

## 9. After Packaging

1. Run `zip-auditor` to audit the package:
   ```bash
   claude "Audit this package: .ollamaclaw/artifacts/filename.zip"
   ```

2. Run final release readiness check:
   ```bash
   ./scripts/release-readiness.sh
   ```

3. Upload manually from `.ollamaclaw/artifacts/` as needed
