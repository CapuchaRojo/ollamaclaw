# Stellar Branch Charter: HeyGen + Social Media Marketing Sidecar

## Branch Name

`stellar/heygen-social-ops`

## Mission

Create a **marketing-ops sidecar** for VetCan that enables:

1. HeyGen video script generation for social content
2. Platform-specific copy adaptation (LinkedIn, X/Twitter, Instagram, TikTok)
3. Approval workflow blueprints for compliance review
4. Campaign measurement and analytics tracking

## What This Branch IS

- A **documentation and prompt library** for social media operations
- A **workflow blueprint** for n8n automation pipelines
- A **campaign brief repository** for VetCan marketing launches
- A **prompt chain** for extracting VetCan truth and generating platform-optimized content
- An **approval packet generator** for compliance review before publishing

## What This Branch IS NOT

- NOT a modification to VetCan runtime code
- NOT a booking, payment, or PHI handling system
- NOT a Twilio, Acuity, or production routing change
- NOT a medical logic or automation implementation
- NOT a live API integration with HeyGen or social platforms

## Scope Boundaries

| In Scope | Out of Scope |
|----------|--------------|
| HeyGen script prompts | HeyGen API integration code |
| Platform copy templates | Social platform API integrations |
| Approval workflow docs | Live approval system implementation |
| Campaign briefs | Ad spend or budget management |
| Measurement plans | Analytics dashboard code |
| n8n workflow blueprints | n8n instance configuration |

## Source Truth Dependencies

| Source | File/Location | Purpose |
|--------|---------------|---------|
| VetCan build | `vetcan.zip` | Product capability truth |
| Demo narrative | `launchpad.pptx` | Messaging and positioning |
| Active offer | Ads image / A17 docs | Current offer details |
| Redacted proof | Approved case studies | Social proof language |

## Guardrails

### DO
- Use only redacted, generalized proof language
- Reference documented VetCan capabilities only
- Route all content through approval packet workflow
- Keep credentials and secrets out of this repo

### DO NOT
- Invent product capabilities
- Use raw call transcripts as public content
- Claim HIPAA, PCI, or live deployment capability unless documented
- Publish directly to platforms from this repo
- Add API keys, tokens, or credentials

## Files to Create

### Docs (`docs/stellar/`)
- [ ] `STELLAR_BRANCH_CHARTER.md` (this file)
- [ ] `vetcan-social-source-map.md`
- [ ] `heygen-production-rules.md`
- [ ] `platform-channel-matrix.md`
- [ ] `approval-and-risk-rules.md`
- [ ] `campaign-measurement-plan.md`

### Prompts (`prompts/stellar/`)
- [ ] `00_social_director.md`
- [ ] `01_vetcan_truth_extractor.md`
- [ ] `02_platform_copy_agent.md`
- [ ] `03_heygen_script_agent.md`
- [ ] `04_approval_packet_agent.md`
- [ ] `05_social_qa_auditor.md`

### Campaigns (`campaigns/vetcan-launch/`)
- [ ] `campaign-brief.md`
- [ ] `content-pillars.md`
- [ ] `heygen-video-manifest.json`
- [ ] `approval-packet.md`

### Workflows (`workflows/n8n/`)
- [ ] `stellar-social-pipeline.md`
- [ ] `approval-gate-blueprint.md`
- [ ] `weekly-analytics-review.md`

## Success Criteria

1. All files created with consistent formatting
2. Prompt chain is logically ordered and composable
3. Approval workflow clearly separates draft vs. approved content
4. Measurement plan defines clear KPIs and tracking cadence
5. No credentials, secrets, or live integrations added
6. All claims reference source truth documents

## Validation Commands

```bash
# Verify all files exist
ls -la docs/stellar/*.md
ls -la prompts/stellar/*.md
ls -la campaigns/vetcan-launch/*
ls -la workflows/n8n/*.md

# Verify no secrets in added files
./scripts/source-truth-check.sh

# Review git status
git status --short
```

## Related Docs

- [Source Truth Workflow](../source-truth-workflow.md)
- [Agent Team Playbook](../agent-team-playbook.md)
- [Package Audit Checklist](../package-audit-checklist.md)
