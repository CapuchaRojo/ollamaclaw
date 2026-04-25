# Approval Gate Blueprint: n8n Workflow

## Purpose

This document describes the n8n workflow for routing VetCan social content through the appropriate approval gates based on risk level.

**Important: V1 Scope — Approval-Queue/Manual Publishing Only**

V1 of this workflow is **approval-queue only**. The routing and notification system is production-ready, but:

- Platform API publishing nodes are **placeholders for future development**
- Manual publishing via platform UI is the **required approach for V1**
- Any live API publishing requires a **separate security review** and documented approval
- Credentials must **never** be stored in workflow definitions or committed to git

**V1 Workflow:**
1. Use this n8n workflow to route content through approval gates
2. Approvers review via Slack/email
3. Human publishes manually via platform UI (LinkedIn, X, Instagram, etc.)
4. Metrics tracked manually or via platform analytics exports

Do not enable any API publishing automation until V2 security review is complete and credentials are properly secured.

## Workflow Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    APPROVAL GATE WORKFLOW                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────┐                                               │
│  │   CONTENT    │                                               │
│  │   SUBMITTED  │                                               │
│  └──────────────┘                                               │
│         │                                                        │
│         ▼                                                        │
│  ┌──────────────┐                                               │
│  │   ASSESS     │                                               │
│  │   RISK       │                                               │
│  │   LEVEL      │                                               │
│  └──────────────┘                                               │
│         │                                                        │
│    ┌────┴────┐                                                  │
│    │  RISK   │                                                  │
│    │ LEVEL?  │                                                  │
│    └────┬────┘                                                  │
│         │                                                        │
│    ┌────┼────┬────┐                                             │
│    ▼    ▼    ▼    │                                             │
│ ┌───┐ ┌───┐ ┌───┐│                                             │
│ │L1 │ │L2 │ │L3 ││                                             │
│ └─┬─┘ └─┬─┘ └─┬─┘│                                             │
│   │     │     │  │                                             │
│   ▼     ▼     ▼  │                                             │
│ ┌────────────────────┐                                         │
│ │   ROUTE TO         │                                         │
│ │   REVIEWERS        │                                         │
│ └─────────┬──────────┘                                         │
│           │                                                      │
│           ▼                                                      │
│  ┌──────────────┐                                               │
│  │   WAIT FOR   │                                               │
│  │   APPROVAL   │                                               │
│  └──────────────┘                                               │
│           │                                                      │
│           ▼                                                      │
│  ┌──────────────┐                                               │
│  │   DECISION   │                                               │
│  │   GATE       │                                               │
│  └──────────────┘                                               │
│         / | \                                                    │
│        /  |  \                                                   │
│       ▼   ▼   ▼                                                  │
│   ┌───┐ ┌───┐ ┌───┐                                             │
│   │OK │ │REV│ │NO │                                             │
│   └─┬─┘ └─┬─┘ └─┬─┘                                             │
│     │     │     │                                                │
│     ▼     ▼     ▼                                                │
│  ┌─────┐ ┌─────┐ ┌─────┐                                        │
│  │PUB  │ │FIX  │ │KILL │                                        │
│  └─────┘ └─────┘ └─────┘                                        │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Risk Assessment Node

**Node Type:** Function

**Purpose:** Automatically assess content risk level

**Code:**
```javascript
const content = $('Input').first().json.content_text;
const claims = $('Input').first().json.claims || [];

let riskLevel = 1;
let requiresLegal = false;
let requiresCustomer = false;
let requiresLeadership = false;

// Level 2 triggers
const level2Triggers = [
  /%\b/,  // Percentage symbols
  /\d+\s*(percent|percentage)/i,
  /reduced by/i,
  /increased by/i,
  /competitive/i,
  /pricing|offer|discount/i
];

// Level 3 triggers
const level3Triggers = [
  /HIPAA|HITECH|privacy\s*act/i,
  /PCI|payment\s*card|financial\s*compliance/i,
  /customer\s*name|testimonial|case\s*study/i,
  /Dr\.|Medical|clinical\s*outcome/i,
  /partner|integration\s*announcement/i
];

// Check content for triggers
for (const trigger of level2Triggers) {
  if (trigger.test(content)) {
    riskLevel = Math.max(riskLevel, 2);
    requiresLegal = true;
  }
}

for (const trigger of level3Triggers) {
  if (trigger.test(content)) {
    riskLevel = 3;
    requiresLegal = true;
    requiresCustomer = true;
    requiresLeadership = true;
  }
}

// Check explicit claims
for (const claim of claims) {
  if (claim.risk_level === 2) {
    riskLevel = Math.max(riskLevel, 2);
    requiresLegal = true;
  } else if (claim.risk_level === 3) {
    riskLevel = 3;
    requiresLegal = true;
    requiresCustomer = true;
    requiresLeadership = true;
  }
}

return {
  risk_level: riskLevel,
  requires_legal: requiresLegal,
  requires_customer: requiresCustomer,
  requires_leadership: requiresLeadership,
  reviewers_needed: buildReviewerList(riskLevel)
};

function buildReviewerList(level) {
  const reviewers = ['Marketing Lead'];
  if (level >= 2) reviewers.push('Legal/Compliance');
  if (level === 3) reviewers.push('Customer', 'Leadership');
  return reviewers.join(', ');
}
```

---

## Routing Node

**Node Type:** Switch

**Purpose:** Route content to appropriate reviewer channels

### Route Configuration

| Route | Condition | Destination |
|-------|-----------|-------------|
| Level 1 | `risk_level === 1` | Marketing Lead Slack |
| Level 2 | `risk_level === 2` | Marketing Lead + Legal Slack |
| Level 3 | `risk_level === 3` | Full review chain Slack + Email |

### Slack Message Templates

#### Level 1 (Standard)

```
📝 New Content for Approval (Level 1)

Content ID: {{ $json.content_id }}
Type: {{ $json.content_type }}
Platform: {{ $json.platform }}

Reviewer: @Marketing Lead

Content Preview:
"""
{{ $json.content_text.substring(0, 200) }}...
"""

Approval Packet: {{ $json.packet_link }}

Reply with: APPROVE, REVISE, or REJECT
```

#### Level 2 (Claims)

```
⚠️ New Content for Approval (Level 2)

Content ID: {{ $json.content_id }}
Type: {{ $json.content_type }}
Platform: {{ $json.platform }}

Reviewers: @Marketing Lead @Legal/Compliance

Claims Requiring Review:
{{ $json.claims_summary }}

Content Preview:
"""
{{ $json.content_text.substring(0, 200) }}...
"""

Approval Packet: {{ $json.packet_link }}

Reply with: APPROVE, REVISE, or REJECT
```

#### Level 3 (Sensitive)

```
🚨 New Content for Approval (Level 3)

Content ID: {{ $json.content_id }}
Type: {{ $json.content_type }}
Platform: {{ $json.platform }}

Reviewers: @Marketing Lead @Legal/Compliance @Customer @Leadership

SENSITIVE CONTENT - Requires full review chain

Claims Requiring Review:
{{ $json.claims_summary }}

Content Preview:
"""
{{ $json.content_text.substring(0, 200) }}...
"""

Approval Packet: {{ $json.packet_link }}

Reply with: APPROVE, REVISE, or REJECT
```

---

## Wait for Approval Node

**Node Type:** Wait

**Purpose:** Pause workflow until approval response received

**Configuration:**
```json
{
  "wait_type": "webhook",
  "webhook_path": "/webhook/approval-response-{{ $json.content_id }}",
  "timeout": "7 days",
  "timeout_action": "alert"
}
```

**Timeout Alert:**
```
⏰ Approval Timeout Alert

Content ID: {{ $json.content_id }}
Submitted: {{ $json.submitted_date }}
Days Pending: {{ $json.days_pending }}

Current Reviewer: {{ $json.current_reviewer }}

@channel Please follow up on pending approval
```

---

## Decision Gate Node

**Node Type:** Switch

**Purpose:** Process approval decision

### Decision Routes

| Route | Decision | Action |
|-------|----------|--------|
| Approved | `decision === "APPROVE"` | Continue to publish |
| Revise | `decision === "REVISE"` | Route back to content creation |
| Reject | `decision === "REJECT"` | Archive and notify |

### Approved Path

**Actions:**
1. Update approval packet status to `approved`
2. Record approver name and date
3. Schedule content for publishing
4. Notify content creator

**Slack Notification:**
```
✅ Content Approved

Content ID: {{ $json.content_id }}
Approved by: {{ $json.reviewer }}
Publish Date: {{ $json.publish_date }}

Ready for publishing!
```

### Revise Path

**Actions:**
1. Update approval packet status to `revision_requested`
2. Record feedback from reviewer
3. Route back to content creator
4. Create revision task

**Slack Notification:**
```
📝 Revision Requested

Content ID: {{ $json.content_id }}
Requested by: {{ $json.reviewer }}
Feedback: {{ $json.feedback }}

Content creator: Please revise and resubmit
```

### Reject Path

**Actions:**
1. Update approval packet status to `rejected`
2. Record rejection reason
3. Archive content
4. Notify stakeholders

**Slack Notification:**
```
❌ Content Rejected

Content ID: {{ $json.content_id }}
Rejected by: {{ $json.reviewer }}
Reason: {{ $json.rejection_reason }}

Content archived. No further action needed.
```

---

## Approval Tracking

### Status Transitions

```
draft → pending_approval → [approved | revision_requested | rejected]
                                ↓              ↓              ↓
                            published       revise         archived
```

### Tracking Schema

**Google Sheet or Airtable:**

| Field | Type | Description |
|-------|------|-------------|
| content_id | string | Unique identifier (SOC-2026-###) |
| content_type | string | Post, video, script, etc. |
| platform | string | Target platform |
| risk_level | number | 1, 2, or 3 |
| status | string | Current approval status |
| submitted_date | datetime | When sent for approval |
| current_reviewer | string | Who has it now |
| marketing_approved | boolean | Marketing Lead decision |
| legal_approved | boolean | Legal decision (if required) |
| customer_approved | boolean | Customer decision (if required) |
| leadership_approved | boolean | Leadership decision (if required) |
| approved_date | datetime | When fully approved |
| publish_date | datetime | When published |
| rejection_reason | string | Why rejected (if applicable) |

---

## Escalation Rules

### Automatic Escalation

| Scenario | Escalation Path | Timeline |
|----------|-----------------|----------|
| Level 1 pending > 48h | Escalate to Marketing Director | +24h |
| Level 2 pending > 5 days | Escalate to General Counsel | +2 days |
| Level 3 pending > 7 days | Escalate to CEO | +3 days |

### Escalation Node

**Node Type:** Schedule Trigger

**Purpose:** Check for stuck approvals daily

**Schedule:** Daily at 8:00 AM

**Code:**
```javascript
const pendingItems = await getPendingApprovals();
const now = new Date();

for (const item of pendingItems) {
  const daysPending = (now - item.submitted_date) / (1000 * 60 * 60 * 24);
  
  if (item.risk_level === 1 && daysPending > 2) {
    await escalate(item, 'Marketing Director');
  } else if (item.risk_level === 2 && daysPending > 5) {
    await escalate(item, 'General Counsel');
  } else if (item.risk_level === 3 && daysPending > 7) {
    await escalate(item, 'CEO');
  }
}
```

---

## Manual Override

### Emergency Approval Bypass

**Use Case:** Time-sensitive content requiring immediate publish

**Process:**
1. Marketing Lead sends manual approval via Slack
2. Workflow triggered via manual webhook
3. Content published immediately
4. Approval packet updated retroactively

**Manual Webhook Payload:**
```json
{
  "content_id": "SOC-2026-001",
  "bypass_reason": "Time-sensitive announcement",
  "approved_by": "Marketing Lead",
  "approved_date": "2026-05-01T10:00:00Z",
  "emergency": true
}
```

---

## Related Documents

- [Stellar Social Pipeline](./stellar-social-pipeline.md)
- [Weekly Analytics Review](./weekly-analytics-review.md)
- [Approval and Risk Rules](../../docs/stellar/approval-and-risk-rules.md)
