# Stellar Social Pipeline: n8n Workflow Blueprint

## Purpose

This document describes the n8n workflow for automating VetCan social media content creation, approval routing, and publishing orchestration.

**Important: V1 Scope — Approval-Queue/Manual Publishing Only**

V1 of this workflow is **approval-queue and manual publishing only**. The platform API integration nodes shown in this document are **placeholders for future development** and must NOT be enabled.

Any live platform API publishing requires ALL of the following:
- Separate security review (documented in repo)
- Credential setup in secure vault (n8n credentials or external secrets manager)
- Legal/compliance sign-off on API terms of service
- Explicit written approval from leadership

**Default for V1:**
1. Content generated via workflow
2. Approval packet routed via Slack/email
3. Human publishes manually via platform UI
4. Metrics tracked manually or via platform analytics exports

Do not enable API publishing nodes without completing the security review and credential setup.

## Workflow Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    STELLAR SOCIAL PIPELINE                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────┐   ┌──────────────┐   ┌──────────────┐        │
│  │   TRIGGER    │──▶│   EXTRACT    │──▶│   GENERATE   │        │
│  │              │   │   TRUTH      │   │   CONTENT    │        │
│  └──────────────┘   └──────────────┘   └──────────────┘        │
│         │                  │                  │                 │
│         ▼                  ▼                  ▼                 │
│  ┌──────────────┐   ┌──────────────┐   ┌──────────────┐        │
│  │   SCHEDULE   │   │   VETCAN     │   │   PLATFORM   │        │
│  │   CAMPAIGN   │   │   FEATURES   │   │   ADAPT      │        │
│  └──────────────┘   └──────────────┘   └──────────────┘        │
│                                                                  │
│  ┌──────────────┐   ┌──────────────┐   ┌──────────────┐        │
│  │   PUBLISH    │◀──│   APPROVE    │◀──│   CREATE     │        │
│  │   CONTENT    │   │   CONTENT    │   │   PACKET     │        │
│  └──────────────┘   └──────────────┘   └──────────────┘        │
│         │                                                          │
│         ▼                                                          │
│  ┌──────────────┐                                                 │
│  │   TRACK      │                                                 │
│  │   METRICS    │                                                 │
│  └──────────────┘                                                 │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Trigger Options

### Manual Trigger

| Field | Value |
|-------|-------|
| Trigger Type | Manual (button press) |
| Input | Campaign ID, content type, platform |
| Use Case | One-off content creation |

### Schedule Trigger

| Field | Value |
|-------|-------|
| Trigger Type | Cron schedule |
| Schedule | Daily at 9:00 AM |
| Use Case | Daily content generation |

### Webhook Trigger

| Field | Value |
|-------|-------|
| Trigger Type | POST webhook |
| Endpoint | `/webhook/stellar-social` |
| Use Case | External campaign tool integration |

---

## Node Configuration

### Node 1: Campaign Input

**Node Type:** Set

**Purpose:** Capture campaign parameters

**Fields:**
```json
{
  "campaign_id": "VETCAN-LAUNCH-2026-Q2",
  "content_type": "linkedin_post",
  "platform": "linkedin",
  "pillar": "problem|solution|proof|cta",
  "risk_level": "1|2|3",
  "target_publish_date": "2026-05-01"
}
```

---

### Node 2: Extract Truth

**Node Type:** HTTP Request (Claude API via Ollama)

**Purpose:** Call `01_vetcan_truth_extractor` prompt

**Configuration:**
```json
{
  "method": "POST",
  "url": "http://localhost:11434/api/generate",
  "body": {
    "model": "qwen3.5:397b-cloud",
    "prompt": "{{ $json.truth_extractor_prompt }}",
    "context": {
      "campaign_id": "{{ $json.campaign_id }}",
      "pillar": "{{ $json.pillar }}"
    }
  }
}
```

**Output:** Extracted capabilities, benefit statements, proof language

---

### Node 3: Generate Content

**Node Type:** HTTP Request (Claude API via Ollama)

**Purpose:** Call `02_platform_copy_agent` or `03_heygen_script_agent`

**Configuration:**
```json
{
  "method": "POST",
  "url": "http://localhost:11434/api/generate",
  "body": {
    "model": "qwen3.5:397b-cloud",
    "prompt": "{{ $json.platform_copy_prompt }}",
    "context": {
      "platform": "{{ $json.platform }}",
      "content_type": "{{ $json.content_type }}",
      "extracted_truth": "{{ $nodes['Extract Truth'].output }}"
    }
  }
}
```

**Output:** Platform-optimized content draft

---

### Node 4: Create Approval Packet

**Node Type:** HTTP Request (Claude API via Ollama)

**Purpose:** Call `04_approval_packet_agent`

**Configuration:**
```json
{
  "method": "POST",
  "url": "http://localhost:11434/api/generate",
  "body": {
    "model": "qwen3.5:397b-cloud",
    "prompt": "{{ $json.approval_packet_prompt }}",
    "context": {
      "content": "{{ $nodes['Generate Content'].output }}",
      "risk_level": "{{ $json.risk_level }}",
      "source_refs": "{{ $nodes['Extract Truth'].output.source_refs }}"
    }
  }
}
```

**Output:** Approval packet markdown document

---

### Node 5: Route for Approval

**Node Type:** Switch

**Purpose:** Route based on risk level

**Routes:**
| Route | Condition | Action |
|-------|-----------|--------|
| Level 1 | `risk_level === "1"` | Send to Marketing Lead Slack |
| Level 2 | `risk_level === "2"` | Send to Marketing Lead + Legal Slack |
| Level 3 | `risk_level === "3"` | Send to full review chain |

**Slack Integration:**
```json
{
  "channel": "#vetcan-social-approvals",
  "message": "New content awaiting approval: {{ $json.content_id }}\nRisk Level: {{ $json.risk_level }}\nReviewers: {{ $json.reviewers }}\nLink: {{ $json.packet_link }}"
}
```

---

### Node 6: Wait for Approval

**Node Type:** Wait

**Purpose:** Pause workflow until approval received

**Configuration:**
```json
{
  "wait_type": "webhook",
  "webhook_path": "/webhook/approval-response",
  "timeout": "7 days"
}
```

**Approval Webhook Input:**
```json
{
  "content_id": "SOC-2026-001",
  "decision": "approved|approved_with_changes|rejected",
  "reviewer": "Marketing Lead",
  "feedback": "Optional feedback notes"
}
```

---

### Node 7: Process Approval Decision

**Node Type:** Switch

**Purpose:** Handle approval decision

**Routes:**
| Route | Condition | Action |
|-------|-----------|--------|
| Approved | `decision === "approved"` | Continue to publish |
| Changes | `decision === "approved_with_changes"` | Revise content |
| Rejected | `decision === "rejected"` | Archive and notify |

---

### Node 8: Publish Content

**Node Type:** HTTP Request (Platform API)

**Purpose:** Publish to target platform

**Configuration (LinkedIn Example):**
```json
{
  "method": "POST",
  "url": "https://api.linkedin.com/v2/ugcPosts",
  "headers": {
    "Authorization": "Bearer {{ $credentials.linkedin_token }}",
    "Content-Type": "application/json"
  },
  "body": {
    "author": "urn:li:person:{{ $credentials.linkedin_person_id }}",
    "lifecycleState": "PUBLISHED",
    "specificContent": {
      "com.linkedin.ugc.ShareContent": {
        "shareCommentary": {
          "text": "{{ $json.content_text }}"
        },
        "shareMediaCategory": "NONE"
      }
    },
    "visibility": {
      "com.linkedin.ugc.MemberNetworkVisibility": "PUBLIC"
    }
  }
}
```

**Note: V1 Manual Publishing**

Platform API integrations shown above are **placeholders for future development**. V1 uses manual publishing:
1. Content generated via workflow
2. Approval packet routed via Slack/email
3. Human publishes manually via platform UI
4. Metrics tracked manually or via platform analytics exports

Do not enable API publishing without a separate security review and credential setup.

---

### Node 9: Track Metrics

**Node Type:** Schedule Trigger

**Purpose:** Pull metrics from platforms on schedule

**Schedule:** Daily at 6:00 AM

**Platforms:**
| Platform | API Endpoint | Metrics |
|----------|--------------|---------|
| LinkedIn | `/v2/metrics` | Impressions, engagement, clicks |
| X/Twitter | `/2/tweets/:id` | Impressions, likes, retweets |
| Instagram | `/insights` | Reach, impressions, saves |
| TikTok | `/analytics/videos` | Views, likes, comments |
| YouTube | `/youtube/analytics` | Views, watch time, CTR |

**Output:** Google Sheet or Airtable record

---

## Error Handling

### Node-Level Error Handling

| Node | Error Handler | Action |
|------|---------------|--------|
| Extract Truth | Retry 3x, then alert | Log error, notify Marketing Lead |
| Generate Content | Retry 3x, then alert | Log error, notify Marketing Lead |
| Create Packet | Retry 3x, then alert | Log error, notify Marketing Lead |
| Publish | Retry 3x, then alert | Log error, notify + manual publish |
| Track Metrics | Retry 3x, then skip | Log error, continue |

### Alert Configuration

**Slack Channel:** `#vetcan-social-alerts`

**Alert Format:**
```
🚨 Stellar Social Pipeline Error

Workflow: {{ $workflow.name }}
Node: {{ $node.name }}
Error: {{ $error.message }}
Time: {{ $now }}

@channel for immediate attention
```

---

## Data Flow

### Input Schema

```json
{
  "campaign_id": "string (required)",
  "content_type": "string (linkedin_post|twitter_post|instagram_post|tiktok_script|heygen_script)",
  "platform": "string (linkedin|twitter|instagram|tiktok|youtube)",
  "pillar": "string (problem|solution|proof|cta)",
  "risk_level": "string (1|2|3)",
  "target_publish_date": "string (ISO date)"
}
```

### Output Schema

```json
{
  "content_id": "string (SOC-2026-###)",
  "status": "string (draft|pending_approval|approved|published|archived)",
  "content_text": "string",
  "approval_packet_link": "string",
  "publish_date": "string (ISO date)",
  "metrics_link": "string"
}
```

---

## Manual Fallback

If automation fails or is unavailable:

1. **Content Creation:** Use prompts directly via Claude Code
2. **Approval Routing:** Share approval packet via email/Slack
3. **Publishing:** Manual publish via platform UI
4. **Metrics:** Manual pull from platform analytics

---

## Security Considerations

### Credentials

| Credential | Storage | Access |
|------------|---------|--------|
| Platform API tokens | n8n credentials vault | Workflow only |
| Claude/Ollama API | Environment variable | Workflow only |
| Slack webhook | n8n credentials vault | Alert workflow only |

### Data Handling

- No customer PII stored in workflow
- No raw call transcripts processed
- No credentials logged or exposed
- Approval packets stored in secure location (Google Drive/Notion)

---

## Related Documents

- [Approval Gate Blueprint](./approval-gate-blueprint.md)
- [Weekly Analytics Review](./weekly-analytics-review.md)
- [Campaign Measurement Plan](../../docs/stellar/campaign-measurement-plan.md)
