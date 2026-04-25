# Ollamaclaw Package Command

## Purpose

Project slash command for safe package creation and artifact hygiene auditing.

## Behavior

**Audit-first posture.** This command checks before creating.

### When Invoked Without Explicit "Create" Request

If the user runs `/ollamaclaw-package` without explicitly asking to create a package:

1. Run artifact hygiene check:
   ```bash
   ./scripts/artifact-hygiene-check.sh
   ```
2. Report current state:
   - Root-level ZIPs
   - _bootstrap_junk presence
   - .ollamaclaw/artifacts/ contents
   - Tracked secrets (FAIL if found)
3. Ask before creating a package:
   - "Do you want to create a new package now?"
   - If yes: proceed to package creation
   - If no: stop after reporting

### When Invoked With Explicit "Create" Request

If the user explicitly asks to create a package (e.g., "create a package", "zip for upload"):

1. Run artifact hygiene check first:
   ```bash
   ./scripts/artifact-hygiene-check.sh
   ```
2. If FAIL: stop and report hard blockers
3. If WARN or PASS: proceed to create package:
   ```bash
   ./scripts/package-ollamaclaw.sh [filename]
   ```
4. After creation:
   - Report package path and size
   - Show preview (first 80 entries)
   - Recommend running `zip-auditor`
   - Recommend running `./scripts/release-readiness.sh`

## Constraints

- Do not upload files
- Do not commit or push
- Do not delete existing files
- Do not create root-level ZIPs
- Packages go to `.ollamaclaw/artifacts/` only

## Example Invocations

```bash
# Audit only
/ollamaclaw-package

# Create package with default filename
/ollamaclaw-package create

# Create package with custom filename
/ollamaclaw-package create my-release.zip

# Audit and report without creating
/ollamaclaw-package check
```

## Output After Packaging

Always recommend:

1. Run `zip-auditor` to audit package contents
2. Run `./scripts/release-readiness.sh` for final safety check
3. Upload manually from `.ollamaclaw/artifacts/`

## Files Involved

| Script | Purpose |
|--------|---------|
| `./scripts/artifact-hygiene-check.sh` | Non-destructive hygiene audit |
| `./scripts/package-ollamaclaw.sh` | Safe ZIP creation |
| `./scripts/release-readiness.sh` | Final release gate |

## See Also

- [Artifact Hygiene Workflow](../../docs/artifact-hygiene-workflow.md)
- [Package Audit Checklist](../../docs/package-audit-checklist.md)
- [Release Readiness Workflow](../../docs/release-readiness-workflow.md)
