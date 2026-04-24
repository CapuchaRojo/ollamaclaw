# VetCan Release Audit

Run an audit-only VetCan release chain from Ollamaclaw.

Target path/context: `$ARGUMENTS`

Instructions:
1. Use `scope-lock` to lock target repo/path, release scope, and stop condition.
2. Use `repo-scout` to map target structure and surfaces.
3. Use relevant domain auditors as applicable:
   - `studio-drift-auditor`
   - `voice-safety-auditor`
   - `payment-safe-reviewer`
   - `medical-boundary-reviewer`
4. Use `test-commander` to recommend the smallest relevant tests only.
5. Use `release-scribe` to produce commit notes, rollback notes, validation notes, and client-safe summary.

Constraints:
- Audit-only unless the user explicitly approves edits.
- Missing canonical truth in VetCan is BLOCKER.
- Do not widen medical, PHI, payment, voice, or deployment claims.
