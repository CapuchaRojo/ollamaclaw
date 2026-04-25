# VetCan Social Media Source Map

## Purpose

This document maps **where marketing truth lives** for VetCan social content creation. All social posts, HeyGen scripts, and campaign materials must trace back to these source documents.

## Source Truth Hierarchy

### Tier 1: Product Capability Truth

| Source | File | What It Defines | Update Cadence |
|--------|------|-----------------|----------------|
| VetCan Build | `vetcan.zip` | Actual implemented features | Per release |
| Build Notes | Inside `vetcan.zip` | Changelog, capabilities | Per release |
| Architecture | VetCan repo docs | System boundaries | Per major change |

**Use for:**
- Feature claims
- Capability statements
- Technical specifications
- Integration claims

**Do NOT claim:**
- Features not in `vetcan.zip`
- Capabilities marked "planned" or "TODO"
- Integrations not documented in build notes

---

### Tier 2: Messaging and Positioning Truth

| Source | File | What It Defines | Update Cadence |
|--------|------|-----------------|----------------|
| Demo Narrative | `launchpad.pptx` | Product story, positioning | Per campaign |
| Elevator Pitch | In `launchpad.pptx` | 30-second positioning | Stable |
| Problem Statement | In `launchpad.pptx` | Market pain being solved | Stable |
| Solution Story | In `launchpad.pptx` | How VetCan solves it | Per campaign |

**Use for:**
- Hook language
- Problem/solution framing
- Competitive differentiation
- Category positioning

**Key positioning:**
> VetCan is NOT a chatbot. It is an AI operations layer and control surface for calls, chat, booking, reminders, payment-safe next steps, workflow orchestration, evidence, approvals, exports, demos, and launch readiness.

---

### Tier 3: Offer and Campaign Truth

| Source | File | What It Defines | Update Cadence |
|--------|------|-----------------|----------------|
| Active Offer | Ads image / A17 docs | Current promotion | Per campaign |
| Campaign Brief | `campaigns/vetcan-launch/campaign-brief.md` | Campaign goals, timing | Per campaign |
| Content Pillars | `campaigns/vetcan-launch/content-pillars.md` | Theme areas | Per campaign |

**Use for:**
- CTA language
- Offer details
- Campaign-specific messaging
- Landing page alignment

---

### Tier 4: Social Proof and Evidence

| Source | File | What It Defines | Restrictions |
|--------|------|-----------------|--------------|
| Redacted Case Studies | Approved docs only | Generalized results | No raw transcripts |
| Testimonials | Approved quotes only | Customer voices | Must be signed release |
| Metrics | Aggregated, anonymized | Performance numbers | No client-specific data |

**Use for:**
- Before/after comparisons
- Customer quote snippets
- Aggregate performance claims

**Do NOT use:**
- Raw call transcripts (PHI risk)
- Unredacted customer names
- Specific clinic performance data
- Unapproved testimonial quotes

---

## Content Claim Validation Matrix

| Claim Type | Required Source | Approval Level |
|------------|-----------------|----------------|
| Feature exists | `vetcan.zip` or build notes | Standard |
| Performance metric | Aggregated, anonymized data | Legal review |
| Customer quote | Signed release form | Legal review |
| HIPAA compliance | Explicit legal documentation | Legal + Compliance |
| PCI compliance | Explicit certification docs | Legal + Compliance |
| Live deployment | Production release notes | Standard |
| Automation capability | Documented in build | Standard |
| Integration with X | Documented integration | Standard |

---

## Redaction Rules for Social Proof

### Acceptable Proof Language

```
✅ "Veterinary clinics using VetCan report reduced no-show rates"
✅ "Early adopters saw faster booking confirmation times"
✅ "Operations teams spend less time on manual follow-ups"
```

### Unacceptable Proof Language

```
❌ "Dr. Smith's clinic in Austin saw 40% reduction in no-shows"
❌ "Call transcript from March 15: 'I need to reschedule my dog'"
❌ "ABC Veterinary Hospital increased revenue by $50,000"
```

### Why These Rules Exist

1. **PHI Protection**: Call transcripts may contain protected health information
2. **Privacy Compliance**: Customer names require signed releases
3. **Accuracy**: Specific numbers require verification and context
4. **Legal Risk**: Unverified claims create liability exposure

---

## Source Update Triggers

| Event | What to Update | Who Approves |
|-------|----------------|--------------|
| New VetCan release | Tier 1 (capabilities) | Dev team |
| New campaign | Tier 3 (offer) | Marketing lead |
| New case study | Tier 4 (proof) | Legal + customer |
| Positioning pivot | Tier 2 (messaging) | Leadership |

---

## Related Docs

- [HeyGen Production Rules](./heygen-production-rules.md)
- [Approval and Risk Rules](./approval-and-risk-rules.md)
- [Source Truth Workflow](../source-truth-workflow.md)
