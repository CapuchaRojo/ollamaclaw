# Approval and Risk Rules

## Purpose

This document defines the approval workflow for VetCan social media content. All content must pass through appropriate review gates before publishing to ensure compliance, accuracy, and brand safety.

## Risk Classification

### Level 1: Standard Content (Low Risk)

**Examples:**
- General product announcements
- Feature explanations without claims
- Educational content
- Team/culture posts

**Approval Path:**
```
Draft → Marketing Lead Review → Publish
```

**Turnaround:** 24-48 hours

---

### Level 2: Claims Content (Medium Risk)

**Examples:**
- Performance metrics or statistics
- Before/after comparisons
- Competitive comparisons
- Pricing or offer announcements

**Approval Path:**
```
Draft → Marketing Lead → Legal/Compliance Review → Publish
```

**Turnaround:** 3-5 business days

**Requirements:**
- Source truth reference required
- Metrics must be aggregated and anonymized
- Competitive claims must be verifiable

---

### Level 3: Sensitive Content (High Risk)

**Examples:**
- Customer testimonials or case studies
- Compliance claims (HIPAA, PCI, etc.)
- Medical or clinical statements
- Partnership or integration announcements

**Approval Path:**
```
Draft → Marketing Lead → Legal/Compliance → Customer Approval (if applicable) → Leadership Sign-off → Publish
```

**Turnaround:** 5-10 business days

**Requirements:**
- Signed release forms for customer content
- Legal documentation for compliance claims
- Written partner approval for integrations

---

## Approval Packet Structure

Every piece of content requires an approval packet with:

### Required Fields

| Field | Description |
|-------|-------------|
| Content ID | Unique identifier (e.g., `SOC-2026-001`) |
| Content Type | Post, video, image, article |
| Platform(s) | LinkedIn, X, Instagram, TikTok, YouTube |
| Risk Level | Level 1, 2, or 3 |
| Draft Content | Full text, script, or visual mockup |
| Source Truth Refs | Links to supporting documentation |
| Claims Summary | List of all claims made |
| Reviewers Needed | Names/roles of required approvers |
| Target Publish Date | When content should go live |

### Optional Fields

| Field | Description |
|-------|-------------|
| A/B Variant | Alternative version for testing |
| Budget | Paid promotion spend (if applicable) |
| Targeting | Audience segmentation notes |
| Success Metrics | KPIs for this content piece |

---

## Approval Status Definitions

| Status | Meaning | Next Action |
|--------|---------|-------------|
| `draft` | Content being created | Complete draft |
| `internal_review` | Marketing team reviewing | Address feedback |
| `legal_review` | With legal/compliance | Wait for approval |
| `customer_review` | With external party | Wait for sign-off |
| `approved` | Cleared for publishing | Schedule or publish |
| `rejected` | Not approved | Revand resubmit or kill |
| `published` | Live on platform | Track metrics |
| `archived` | Killed or expired | No action |

---

## Red Flags That Require Legal Review

### Automatic Legal Review Triggers

- [ ] Any mention of HIPAA, HITECH, or privacy regulations
- [ ] Any mention of PCI, payment security, or financial compliance
- [ ] Specific performance numbers or percentages
- [ ] Customer names, logos, or identifiable information
- [ ] Competitive claims or comparisons
- [ ] Medical or clinical outcome statements
- [ ] Partnership or integration claims
- [ ] Pricing, discount, or offer language
- [ ] Testimonials or endorsements
- [ ] Before/after claims

### Quick Reference: What Needs Legal Review

| Content Element | Legal Review Required? |
|-----------------|------------------------|
| "VetCan reduces no-shows" | ✅ Yes (performance claim) |
| "VetCan handles booking" | ❌ No (feature statement) |
| "40% reduction in phone tag" | ✅ Yes (specific metric) |
| "Clinics report faster booking" | ⚠️ Maybe (generalized, check with marketing lead) |
| "Dr. Smith says..." | ✅ Yes (customer testimonial) |
| "Veterinary clinics say..." | ❌ No (generalized) |
| "HIPAA-compliant platform" | ✅ Yes (compliance claim) |
| "Built with compliance in mind" | ⚠️ Maybe (vague, check with marketing lead) |

---

## Reviewer Responsibilities

### Marketing Lead

- Brand voice and tone
- Message clarity and impact
- Platform fit and formatting
- CTA effectiveness
- Campaign alignment

### Legal/Compliance

- Regulatory risk assessment
- Claim substantiation
- Privacy and PHI concerns
- Contractual obligations
- Trademark and copyright

### Customer (when applicable)

- Accuracy of quoted material
- Comfort with public association
- Brand alignment (their side)
- Release form execution

### Leadership

- Strategic alignment
- High-risk content approval
- Partnership announcements
- Crisis communications

---

## Escalation Paths

### If Reviewer Is Unavailable

| Reviewer | Backup | Escalation Timeline |
|----------|--------|---------------------|
| Marketing Lead | Marketing Director | 24 hours |
| Legal | External counsel | 48 hours |
| Customer | Account manager | 48 hours |
| Leadership | CEO/Founder | 72 hours |

### If Content Is Rejected

1. Document reason for rejection
2. Identify what would change the decision
3. Decide: revise, escalate, or kill
4. If revising, resubmit as new version (v2)
5. Track rejection reasons for pattern analysis

---

## Audit Trail Requirements

All approvals must be documented with:

- Reviewer name and role
- Date of approval
- Version approved
- Any conditions or notes
- Stored in approval packet record

**Format:** Email, Slack (saved), approval tool, or signed document

**Retention:** Minimum 2 years from publish date

---

## Emergency Takedown Protocol

### When to Takedown Content

- Legal identifies regulatory risk
- Customer requests removal
- Factual error discovered
- Crisis or sensitive event makes content tone-deaf
- Platform flags or removes content

### Takedown Process

1. Document reason for takedown
2. Remove from all platforms immediately
3. Notify reviewers of action
4. Create incident record
5. Conduct post-mortem if required

---

## Related Docs

- [VetCan Social Source Map](./vetcan-social-source-map.md)
- [Campaign Measurement Plan](./campaign-measurement-plan.md)
- [Approval Packet Template](../../campaigns/vetcan-launch/approval-packet.md)
