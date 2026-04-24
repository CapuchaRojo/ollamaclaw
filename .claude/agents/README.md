# Ollamaclaw Agent Library

Ollamaclaw hosts reusable project-local subagents for auditing external repos. These agents do not assume Ollamaclaw is the target — they audit **VetCan** or other specified repos.

## Primary Target

**VetCan** is the primary audit target. Other repos may be audited using the same agents.

## Available Agents

| Agent | Purpose | When to Invoke |
|-------|---------|----------------|
| [`repo-scout`](repo-scout.md) | Maps structure, dependencies, entry points, API/UI surfaces, risk coupling | First step for any unknown repo or before major changes |
| [`studio-drift-auditor`](studio-drift-auditor.md) | Checks Studio wording against A21/A22 canonical truth | Before Studio UI changes, launch copy edits, onboarding updates |
| [`voice-safety-auditor`](voice-safety-auditor.md) | Audits voice/call features against preview-only posture | Before voice, ElevenLabs, audio, or call-related changes |
| [`payment-safe-reviewer`](payment-safe-reviewer.md) | Reviews payment/billing/PCI claims | Before payment copy, checkout, billing, or invoice changes |
| [`medical-boundary-reviewer`](medical-boundary-reviewer.md) | Detects medical/vet/PHI boundary drift | Before medical, vet, intake, or eligibility-related changes |
| [`test-commander`](test-commander.md) | Runs smallest relevant test group | After code changes, before commits |
| [`release-scribe`](release-scribe.md) | Generates commit notes, rollback notes, client-safe summaries | Before commits and releases |

## Invocation Examples

### Scout an Unknown Repo

```
@repo-scout Scout the VetCan repo at /path/to/vetcan
```

### Audit Studio Wording

```
@studio-drift-auditor Audit /path/to/vetcan for Studio wording drift against A21/A22 truth
```

### Voice Safety Check

```
@voice-safety-auditor Review /path/to/vetcan voice features for preview-only compliance
```

### Payment Copy Review

```
@payment-safe-reviewer Check /path/to/vetcan payment copy for PCI-safe language
```

### Medical Boundary Audit

```
@medical-boundary-reviewer Audit /path/to/vetcan for medical advice or PHI scope drift
```

### Run Tests

```
@test-commander Run minimal tests for /path/to/vetcan after changing src/checkout
```

### Generate Release Notes

```
@release-scribe Document changes in /path/to/vetcan for commit
```

## Default Orchestration Order

1. **Repo Scout** — understand the target
2. **Relevant Domain Auditor** — studio, voice, payment, or medical
3. **Test Commander** — validate changes
4. **Release Scribe** — document for commit

## Missing Truth Protocol

If canonical truth docs (A21/A22, voice scope, payment scope, medical boundaries) are **missing from the target repo**, domain auditors will report **BLOCKER** instead of guessing. This is intentional — do not widen capability claims without explicit truth.
