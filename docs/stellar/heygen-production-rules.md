# HeyGen Production Rules

## Purpose

This document defines the rules for generating HeyGen video scripts and assets for VetCan social media content. HeyGen is used for creating short-form video content for LinkedIn, X/Twitter, Instagram, and TikTok.

## What HeyGen Is For

- **Explainer videos**: 30-90 second product overviews
- **Feature highlights**: 15-30 second feature spotlights
- **Social ads**: 15-30 second promotional content
- **Thought leadership**: 60-120 second industry insights
- **Tutorial snippets**: 30-60 second how-to clips

## What HeyGen Is NOT For

- Live customer-facing communications
- PHI-containing content
- Medical advice or guidance
- Real-time personalization
- Dynamic content generation

---

## Script Structure Rules

### Standard HeyGen Script Format

```markdown
[HOOK: 0-3 seconds]
- Attention-grabbing opener
- Problem statement or question
- Visual: Bold text overlay

[SETUP: 3-10 seconds]
- Context for the problem
- Relatable scenario
- Visual: Scenario illustration

[SOLUTION: 10-25 seconds]
- Introduce VetCan
- Key benefit (not feature)
- Visual: Product UI or benefit graphic

[PROOF: 25-35 seconds]
- Generalized result or testimonial snippet
- Redacted, anonymized language only
- Visual: Results graphic or quote card

[CTA: 35-45 seconds]
- Clear next step
- Low-friction action
- Visual: CTA button or URL
```

### Timing Guidelines

| Platform | Ideal Duration | Hook Window | CTA Placement |
|----------|----------------|-------------|---------------|
| TikTok | 15-30s | 0-2s | Last 5s |
| Instagram Reels | 15-30s | 0-3s | Last 5s |
| X/Twitter | 15-45s | 0-3s | Last 10s |
| LinkedIn | 30-90s | 0-5s | Last 15s |
| YouTube Shorts | 15-60s | 0-3s | Last 10s |

---

## Content Rules

### DO

- Use conversational, human tone
- Lead with problem, not product
- Show benefit before feature
- Use redacted proof language only
- Include clear, low-friction CTA
- Match platform aspect ratios (9:16 vertical for short-form)

### DO NOT

- Lead with "AI" as the hook (feature, not benefit)
- Use jargon without explanation
- Make HIPAA, PCI, or compliance claims without approval
- Show raw UI screenshots without polish
- Use customer names without signed releases
- Include phone numbers, addresses, or specific locations

---

## Avatar and Voice Selection

### Avatar Guidelines

| Use Case | Recommended Avatar Type |
|----------|------------------------|
| Professional/LinkedIn | Business casual, neutral background |
| Social/Instagram | Friendly, approachable, warm tones |
| X/Twitter | Clean, modern, tech-forward |
| TikTok | Casual, energetic, younger skew |

### Voice Guidelines

- Use clear, professional voice
- Avoid overly formal or robotic tones
- Match energy to platform (higher for TikTok, measured for LinkedIn)
- Test voice with script before finalizing

---

## Visual Asset Requirements

### Required Assets Per Video

| Asset | Format | Purpose |
|-------|--------|---------|
| Script | `.md` or `.txt` | HeyGen input |
| Avatar selection | HeyGen preset | On-screen presenter |
| Voice selection | HeyGen preset | Audio narration |
| Background | Image or color | Scene setting |
| Text overlays | Short phrases | Emphasis points |
| Logo | PNG with transparency | Branding |
| CTA graphic | PNG or text | Final action prompt |

### Asset Storage

```
campaigns/vetcan-launch/
├── heygen-video-manifest.json    # Video metadata
├── assets/
│   ├── logos/                     # Brand assets
│   ├── backgrounds/               # Scene backgrounds
│   └── overlays/                  # Text overlay templates
```

---

## Approval Workflow

### Pre-Production Checklist

- [ ] Script follows standard format
- [ ] All claims trace to source truth
- [ ] Proof language is redacted
- [ ] CTA is clear and low-friction
- [ ] Duration matches platform target
- [ ] Avatar and voice selected

### Production Checklist

- [ ] HeyGen video generated
- [ ] Audio quality verified
- [ ] Visual alignment verified
- [ ] Text overlays readable
- [ ] Logo placement correct

### Post-Production Checklist

- [ ] Approval packet completed
- [ ] Legal review if required
- [ ] Platform-specific formatting
- [ ] Captions added (accessibility)
- [ ] Thumbnail selected

---

## HeyGen Video Manifest

Each video must have an entry in `campaigns/vetcan-launch/heygen-video-manifest.json`:

```json
{
  "video_id": "vetcan-launch-001",
  "title": "VetCan Launch Announcement",
  "platform": "LinkedIn",
  "duration_seconds": 45,
  "script_file": "scripts/001-launch.md",
  "avatar": "business-casual-01",
  "voice": "professional-us-en",
  "status": "draft|review|approved|published",
  "approval_date": null,
  "published_date": null,
  "source_truth_refs": ["vetcan.zip:features", "launchpad.pptx:slide-5"]
}
```

---

## Related Docs

- [VetCan Social Source Map](./vetcan-social-source-map.md)
- [Platform Channel Matrix](./platform-channel-matrix.md)
- [Approval and Risk Rules](./approval-and-risk-rules.md)
