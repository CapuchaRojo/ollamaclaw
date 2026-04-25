# Campaign Measurement Plan

## Purpose

This document defines how VetCan social media campaigns are measured, tracked, and optimized. Clear metrics enable data-driven decisions about content, channels, and spend.

## Campaign Goals Hierarchy

### Primary Goal (North Star)

**Demo Requests:** Number of qualified demo requests attributed to social channels

### Secondary Goals

| Goal | Metric | Target Cadence |
|------|--------|----------------|
| Awareness | Impressions, reach | Weekly |
| Engagement | Likes, comments, shares, saves | Weekly |
| Traffic | Clicks to website/landing page | Weekly |
| Leads | Email signups, contact form submissions | Weekly |
| Pipeline | Demo requests, sales conversations | Bi-weekly |

---

## Platform-Specific KPIs

### LinkedIn

| Metric | Definition | Benchmark | Measurement Tool |
|--------|------------|-----------|------------------|
| Impressions | Times content displayed | Track trend | LinkedIn Analytics |
| CTR | Clicks / Impressions | 0.5-2% | LinkedIn Analytics |
| Engagement Rate | (Reactions + Comments + Shares) / Impressions | 2-5% | LinkedIn Analytics |
| Followers Gained | New followers from content | Track trend | LinkedIn Analytics |
| Demo Requests | Form submissions from LinkedIn | Track absolute | CRM + UTM tracking |

### X/Twitter

| Metric | Definition | Benchmark | Measurement Tool |
|--------|------------|-----------|------------------|
| Impressions | Times content displayed | Track trend | X Analytics |
| Engagement Rate | (Likes + Retweets + Replies) / Impressions | 1-3% | X Analytics |
| Link Clicks | Clicks to external links | Track trend | X Analytics + UTM |
| Profile Visits | Views of profile page | Track trend | X Analytics |
| Demo Requests | Form submissions from X | Track absolute | CRM + UTM tracking |

### Instagram

| Metric | Definition | Benchmark | Measurement Tool |
|--------|------------|-----------|------------------|
| Reach | Unique accounts reached | Track trend | Instagram Insights |
| Engagement Rate | (Likes + Comments + Saves + Shares) / Reach | 3-6% | Instagram Insights |
| Saves | Times content saved | High intent signal | Instagram Insights |
| Website Clicks | Link in bio clicks | Track trend | Instagram Insights + UTM |
| Demo Requests | Form submissions from Instagram | Track absolute | CRM + UTM tracking |

### TikTok

| Metric | Definition | Benchmark | Measurement Tool |
|--------|------------|-----------|------------------|
| Views | Times video played | Track trend | TikTok Analytics |
| Watch Time | Average view duration | 50%+ of video | TikTok Analytics |
| Engagement Rate | (Likes + Comments + Shares) / Views | 5-10% | TikTok Analytics |
| Profile Visits | Views of profile page | Track trend | TikTok Analytics |
| Demo Requests | Form submissions from TikTok | Track absolute | CRM + UTM tracking |

### YouTube

| Metric | Definition | Benchmark | Measurement Tool |
|--------|------------|-----------|------------------|
| Views | Times video played | Track trend | YouTube Studio |
| Watch Time | Total minutes viewed | Track trend | YouTube Studio |
| Average View Duration | How long viewers watch | 40-60% | YouTube Studio |
| CTR (Thumbnails) | Clicks / Impressions | 4-10% | YouTube Studio |
| Demo Requests | Form submissions from YouTube | Track absolute | CRM + UTM tracking |

---

## UTM Tracking Standard

All social links must use UTM parameters:

```
Base URL: https://vetcan.com/landing-page
?utm_source=linkedin           # Platform: linkedin, twitter, instagram, tiktok, youtube
&utm_medium=social            # Always "social" for organic posts
&utm_campaign=vetcan-launch   # Campaign identifier
&utm_content=post-001         # Specific content piece
&utm_term=demo-cta            # CTA or theme variant
```

### UTM Naming Conventions

| Parameter | Format | Examples |
|-----------|--------|----------|
| `utm_source` | lowercase, platform name | `linkedin`, `twitter`, `instagram` |
| `utm_medium` | lowercase, channel type | `social`, `paid_social`, `video` |
| `utm_campaign` | lowercase, campaign-id | `vetcan-launch`, `q2-awareness` |
| `utm_content` | lowercase, content-id | `post-001`, `video-003`, `carousel-a` |
| `utm_term` | lowercase, theme or audience | `demo-cta`, `vet-owner-targeting` |

---

## Measurement Cadence

### Daily Checks (Automated)

- [ ] Platform analytics sync to dashboard
- [ ] Alert on significant drops (>50% engagement decline)
- [ ] Comment/notification monitoring

### Weekly Review (Manual)

| Metric | Owner | Action |
|--------|-------|--------|
| Impressions by platform | Marketing | Identify top performers |
| Engagement rate by content | Marketing | Double down on winners |
| Click-through rates | Marketing | Optimize CTAs |
| Follower growth | Marketing | Assess brand building |
| Top content pieces | Marketing | Create more like this |

### Bi-Weekly Deep Dive (Manual)

| Analysis | Owner | Output |
|----------|-------|--------|
| Platform comparison | Marketing Lead | Resource allocation recs |
| Content theme performance | Marketing | Content calendar adjustments |
| CTA effectiveness | Marketing | Messaging optimization |
| Audience insights | Marketing | Targeting refinements |

### Monthly Executive Summary (Manual)

| Metric | Format | Audience |
|--------|--------|----------|
| Demo requests by source | Table + chart | Leadership |
| Pipeline influenced | Dollar value | Sales + Leadership |
| Cost per lead (if paid) | Calculation | Finance + Marketing |
| Month-over-month growth | Trend chart | All stakeholders |

---

## Analytics Dashboard Requirements

### Minimum Viable Dashboard

| Section | Metrics | Refresh Cadence |
|---------|---------|-----------------|
| Overview | Total impressions, engagement, clicks, demo requests | Daily |
| Platform Breakdown | Per-platform metrics from above | Daily |
| Content Performance | Top 10 posts by engagement | Weekly |
| Conversion Funnel | Impressions → Clicks → Demos | Weekly |
| Trends | Week-over-week, month-over-month | Weekly |

### Tool Options

| Tool | Cost | Best For |
|------|------|----------|
| Native platform analytics | Free | Single-platform deep dives |
| Google Analytics | Free | Website traffic attribution |
| Looker Studio | Free | Custom dashboards |
| Sprout Social | Paid | Multi-platform management |
| HubSpot | Paid | CRM integration |

---

## Attribution Model

### First-Touch Attribution (Default)

Credit goes to the first social touchpoint that introduced the user:

```
User journey:
1. Sees LinkedIn post → Clicks to website (FIRST TOUCH)
2. Returns via Google search
3. Submits demo request

Attribution: LinkedIn gets credit for demo request
```

### Multi-Touch Attribution (Advanced)

Credit is distributed across all touchpoints:

```
User journey:
1. Sees LinkedIn post → No click
2. Sees X/Twitter post → Clicks to website
3. Returns via direct URL → Submits demo request

Attribution: LinkedIn (20%), X (30%), Direct (50%)
```

---

## Success Thresholds

### Campaign Launch Benchmarks

| Metric | Minimum Acceptable | Target | Stretch Goal |
|--------|-------------------|--------|-------------|
| LinkedIn CTR | 0.5% | 1.0% | 2.0% |
| X Engagement | 1% | 2% | 4% |
| Instagram Engagement | 2% | 4% | 6% |
| TikTok Watch Time | 40% | 60% | 80% |
| YouTube CTR (thumbnail) | 3% | 6% | 10% |

### When to Kill Underperforming Content

- CTR below 50% of benchmark for 3+ posts
- Engagement rate below 50% of benchmark for 5+ posts
- Zero demo requests after 1000+ clicks (for direct response content)

---

## Reporting Templates

### Weekly Social Report

```markdown
## Week of [Date]

### Highlights
- Top performing post: [Link]
- Biggest win: [Metric improvement]
- Key learning: [Insight]

### Metrics Summary
| Platform | Impressions | Engagement | Clicks | Demo Requests |
|----------|-------------|------------|--------|---------------|
| LinkedIn | | | | |
| X/Twitter | | | | |
| Instagram | | | | |
| TikTok | | | | |
| YouTube | | | | |

### Content Calendar
- Published this week: [List]
- Planned next week: [List]

### Actions Needed
- [ ] [Decision or task]
```

### Monthly Executive Summary

```markdown
## Month: [Month Year]

### Executive Summary
- Total demo requests from social: [Number]
- Pipeline influenced: [$ Value]
- Month-over-month growth: [Percentage]

### Platform Performance
[Chart: Impressions by platform]
[Chart: Engagement rate by platform]

### Top Content
1. [Post 1] - [Engagement metric]
2. [Post 2] - [Engagement metric]
3. [Post 3] - [Engagement metric]

### Investment
- Organic: [Hours spent]
- Paid: [$ Spend]
- Tools: [$ Software]

### Next Month Focus
- [Priority 1]
- [Priority 2]
- [Priority 3]
```

---

## Related Docs

- [Platform Channel Matrix](./platform-channel-matrix.md)
- [Approval and Risk Rules](./approval-and-risk-rules.md)
- [Weekly Analytics Review Workflow](../../workflows/n8n/weekly-analytics-review.md)
