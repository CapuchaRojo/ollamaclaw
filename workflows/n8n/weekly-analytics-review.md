# Weekly Analytics Review: n8n Workflow

## Purpose

This document describes the n8n workflow for automated weekly analytics collection, aggregation, and reporting across all VetCan social media platforms.

## Workflow Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                 WEEKLY ANALYTICS REVIEW WORKFLOW                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────┐                                               │
│  │   SCHEDULE   │                                               │
│  │   MONDAY     │                                               │
│  │   6:00 AM    │                                               │
│  └──────────────┘                                               │
│         │                                                        │
│         ▼                                                        │
│  ┌──────────────┐   ┌──────────────┐   ┌──────────────┐        │
│  │   LINKEDIN   │   │   X/TWITTER  │   │   INSTAGRAM  │        │
│  │   ANALYTICS  │   │   ANALYTICS  │   │   ANALYTICS  │        │
│  └──────────────┘   └──────────────┘   └──────────────┘        │
│         │                  │                  │                 │
│         └──────────────────┼──────────────────┘                 │
│                            │                                     │
│                   ┌────────┴────────┐                           │
│                   │                  │                           │
│                   ▼                  ▼                           │
│            ┌──────────────┐  ┌──────────────┐                   │
│            │   TIKTOK     │  │   YOUTUBE    │                   │
│            │   ANALYTICS  │  │   ANALYTICS  │                   │
│            └──────────────┘  └──────────────┘                   │
│                            │                                     │
│                            ▼                                     │
│                   ┌──────────────┐                              │
│                   │   AGGREGATE  │                              │
│                   │   METRICS    │                              │
│                   └──────────────┘                              │
│                            │                                     │
│                            ▼                                     │
│                   ┌──────────────┐                              │
│                   │   GENERATE   │                              │
│                   │   REPORT     │                              │
│                   └──────────────┘                              │
│                            │                                     │
│                   ┌────────┴────────┐                           │
│                   │                  │                           │
│                   ▼                  ▼                           │
│            ┌──────────────┐  ┌──────────────┐                   │
│            │   SLACK      │  │   GOOGLE     │                   │
│            │   SUMMARY    │  │   SHEET      │                   │
│            └──────────────┘  └──────────────┘                   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Schedule Configuration

**Node Type:** Schedule Trigger

**Schedule:** Every Monday at 6:00 AM

**Timezone:** Local (campaign team timezone)

**Data Range:** Previous week (Monday 12:00 AM - Sunday 11:59 PM)

---

## Platform API Nodes

### LinkedIn Analytics

**Node Type:** HTTP Request

**API Endpoint:** `https://api.linkedin.com/v2/metrics`

**Configuration:**
```json
{
  "method": "GET",
  "url": "https://api.linkedin.com/v2/organizationAcls?q=roleAssignee&role=ADMINISTRATOR",
  "headers": {
    "Authorization": "Bearer {{ $credentials.linkedin_token }}",
    "X-Restli-Protocol-Version": "2.0.0"
  }
}
```

**Metrics Collected:**
| Metric | API Field | Type |
|--------|-----------|------|
| Impressions | `totalPageViews` | Count |
| Clicks | `clicks` | Count |
| Engagement | `engagement.engagementCount` | Count |
| Comments | `engagement.commentCount` | Count |
| Shares | `engagement.shareCount` | Count |
| Followers gained | `followerGains` | Count |

**Date Range:** `timePeriod.start` and `timePeriod.end` (previous week)

---

### X/Twitter Analytics

**Node Type:** HTTP Request

**API Endpoint:** `https://api.twitter.com/2/tweets/:id`

**Configuration:**
```json
{
  "method": "GET",
  "url": "https://api.twitter.com/2/tweets/{{ $json.tweet_id }}",
  "headers": {
    "Authorization": "Bearer {{ $credentials.twitter_token }}"
  },
  "query": {
    "tweet.fields": "public_metrics,created_at"
  }
}
```

**Metrics Collected:**
| Metric | API Field | Type |
|--------|-----------|------|
| Impressions | `public_metrics.impression_count` | Count |
| Likes | `public_metrics.like_count` | Count |
| Retweets | `public_metrics.retweet_count` | Count |
| Replies | `public_metrics.reply_count` | Count |
| Link Clicks | `public_metrics.url_link_clicks` | Count |
| Profile Visits | `public_metrics.user_profile_clicks` | Count |

**Note:** Requires Twitter API v2 Elevated access

---

### Instagram Analytics

**Node Type:** HTTP Request

**API Endpoint:** `https://graph.facebook.com/v18.0/{ig-user-id}/insights`

**Configuration:**
```json
{
  "method": "GET",
  "url": "https://graph.facebook.com/v18.0/{{ $credentials.instagram_user_id }}/insights",
  "query": {
    "metric": "impressions,reach,engagement,follower_count",
    "period": "day",
    "access_token": "{{ $credentials.facebook_token }}"
  }
}
```

**Metrics Collected:**
| Metric | API Field | Type |
|--------|-----------|------|
| Impressions | `impressions` | Count |
| Reach | `reach` | Count |
| Engagement | `engagement` | Count |
| Saves | `saved` | Count |
| Profile Visits | `profile_views` | Count |
| Followers | `follower_count` | Count |

---

### TikTok Analytics

**Node Type:** HTTP Request

**API Endpoint:** `https://open.tiktokapis.com/v2/research/video/`

**Configuration:**
```json
{
  "method": "GET",
  "url": "https://open.tiktokapis.com/v2/research/video/",
  "headers": {
    "Authorization": "Bearer {{ $credentials.tiktok_token }}"
  },
  "query": {
    "fields": "video_id,video_view_count,like_count,comment_count,share_count",
    "start_date": "{{ $json.week_start }}",
    "end_date": "{{ $json.week_end }}"
  }
}
```

**Metrics Collected:**
| Metric | API Field | Type |
|--------|-----------|------|
| Views | `video_view_count` | Count |
| Likes | `like_count` | Count |
| Comments | `comment_count` | Count |
| Shares | `share_count` | Count |
| Watch Time | `watch_time_seconds` | Duration |

**Note:** TikTok API access requires business account approval

---

### YouTube Analytics

**Node Type:** HTTP Request

**API Endpoint:** `https://youtubeanalytics.googleapis.com/v2/reports`

**Configuration:**
```json
{
  "method": "GET",
  "url": "https://youtubeanalytics.googleapis.com/v2/reports",
  "query": {
    "ids": "channel=={{ $credentials.youtube_channel_id }}",
    "startDate": "{{ $json.week_start }}",
    "endDate": "{{ $json.week_end }}",
    "metrics": "views,estimatedMinutesWatched,averageViewDuration,likes,comments",
    "access_token": "{{ $credentials.google_token }}"
  }
}
```

**Metrics Collected:**
| Metric | API Field | Type |
|--------|-----------|------|
| Views | `views` | Count |
| Watch Time | `estimatedMinutesWatched` | Minutes |
| Avg View Duration | `averageViewDuration` | Seconds |
| Likes | `likes` | Count |
| Comments | `comments` | Count |
| Subscribers gained | `subscribersGained` | Count |

---

## Aggregation Node

**Node Type:** Function

**Purpose:** Combine metrics from all platforms into unified schema

**Code:**
```javascript
const weekData = {
  week_start: $('Input').first().json.week_start,
  week_end: $('Input').first().json.week_end,
  platforms: {}
};

// LinkedIn
weekData.platforms.linkedin = {
  impressions: $('LinkedIn').first().json.totalPageViews || 0,
  engagement: $('LinkedIn').first().json.engagement?.engagementCount || 0,
  clicks: $('LinkedIn').first().json.clicks || 0,
  followers_gained: $('LinkedIn').first().json.followerGains || 0
};

// X/Twitter
weekData.platforms.twitter = {
  impressions: $('Twitter').first().json.impressions || 0,
  engagement: $('Twitter').first().json.likes + 
              $('Twitter').first().json.retweets + 
              $('Twitter').first().json.replies || 0,
  clicks: $('Twitter').first().json.link_clicks || 0,
  profile_visits: $('Twitter').first().json.user_profile_clicks || 0
};

// Instagram
weekData.platforms.instagram = {
  impressions: $('Instagram').first().json.impressions || 0,
  reach: $('Instagram').first().json.reach || 0,
  engagement: $('Instagram').first().json.engagement || 0,
  saves: $('Instagram').first().json.saved || 0,
  followers_gained: $('Instagram').first().json.follower_change || 0
};

// TikTok
weekData.platforms.tiktok = {
  views: $('TikTok').first().json.video_view_count || 0,
  engagement: $('TikTok').first().json.like_count + 
              $('TikTok').first().json.comment_count + 
              $('TikTok').first().json.share_count || 0,
  watch_time: $('TikTok').first().json.watch_time_seconds || 0
};

// YouTube
weekData.platforms.youtube = {
  views: $('YouTube').first().json.views || 0,
  watch_time: $('YouTube').first().json.estimatedMinutesWatched * 60 || 0,
  avg_view_duration: $('YouTube').first().json.averageViewDuration || 0,
  subscribers_gained: $('YouTube').first().json.subscribersGained || 0
};

// Calculate totals
weekData.totals = {
  impressions: weekData.platforms.linkedin.impressions + 
               weekData.platforms.twitter.impressions + 
               weekData.platforms.instagram.impressions,
  engagement: Object.values(weekData.platforms).reduce((sum, p) => sum + (p.engagement || 0), 0),
  video_views: weekData.platforms.tiktok.views + weekData.platforms.youtube.views
};

return weekData;
```

---

## Report Generation Node

**Node Type:** Function

**Purpose:** Generate human-readable weekly summary

**Code:**
```javascript
const data = $('Aggregation').first().json;
const weekNum = getWeekNumber(new Date(data.week_start));

let report = `## VetCan Social Media Weekly Report\n\n`;
report += `**Week:** ${weekNum} (${data.week_start} to ${data.week_end})\n\n`;

report += `### Highlights\n`;
report += `- Total impressions: ${data.totals.impressions.toLocaleString()}\n`;
report += `- Total engagement: ${data.totals.engagement.toLocaleString()}\n`;
report += `- Total video views: ${data.totals.video_views.toLocaleString()}\n\n`;

report += `### Platform Breakdown\n\n`;

report += `**LinkedIn**\n`;
report += `- Impressions: ${data.platforms.linkedin.impressions.toLocaleString()}\n`;
report += `- Engagement: ${data.platforms.linkedin.engagement.toLocaleString()}\n`;
report += `- Clicks: ${data.platforms.linkedin.clicks.toLocaleString()}\n\n`;

report += `**X/Twitter**\n`;
report += `- Impressions: ${data.platforms.twitter.impressions.toLocaleString()}\n`;
report += `- Engagement: ${data.platforms.twitter.engagement.toLocaleString()}\n`;
report += `- Profile Visits: ${data.platforms.twitter.profile_visits.toLocaleString()}\n\n`;

report += `**Instagram**\n`;
report += `- Impressions: ${data.platforms.instagram.impressions.toLocaleString()}\n`;
report += `- Reach: ${data.platforms.instagram.reach.toLocaleString()}\n`;
report += `- Saves: ${data.platforms.instagram.saves.toLocaleString()}\n\n`;

report += `**TikTok**\n`;
report += `- Views: ${data.platforms.tiktok.views.toLocaleString()}\n`;
report += `- Engagement: ${data.platforms.tiktok.engagement.toLocaleString()}\n\n`;

report += `**YouTube**\n`;
report += `- Views: ${data.platforms.youtube.views.toLocaleString()}\n`;
report += `- Watch Time: ${Math.round(data.platforms.youtube.watch_time / 60)} minutes\n`;
report += `- Avg View Duration: ${Math.round(data.platforms.youtube.avg_view_duration)}s\n\n`;

report += `### Week-over-Week Comparison\n`;
report += `[Compare with previous week data from Google Sheet]\n\n`;

report += `### Actions Needed\n`;
report += `- [ ] Review top performing content\n`;
report += `- [ ] Identify underperforming platforms\n`;
report += `- [ ] Adjust content calendar if needed\n`;

return { report, weekData: data };
```

---

## Output Nodes

### Slack Summary

**Node Type:** Slack

**Purpose:** Send weekly summary to team channel

**Configuration:**
```json
{
  "channel": "#vetcan-social-analytics",
  "text": "{{ $json.report }}",
  "username": "Analytics Bot"
}
```

---

### Google Sheet Update

**Node Type:** Google Sheets

**Purpose:** Store weekly metrics for trend analysis

**Configuration:**
```json
{
  "operation": "append",
  "sheet_id": "{{ $credentials.analytics_sheet_id }}",
  "range": "A1:Z1000",
  "columns": [
    "week_start",
    "week_end",
    "total_impressions",
    "total_engagement",
    "total_video_views",
    "linkedin_impressions",
    "linkedin_engagement",
    "twitter_impressions",
    "twitter_engagement",
    "instagram_impressions",
    "instagram_engagement",
    "tiktok_views",
    "tiktok_engagement",
    "youtube_views",
    "youtube_watch_time"
  ]
}
```

---

## Alert Conditions

### Automatic Alerts

| Condition | Threshold | Action |
|-----------|-----------|--------|
| Impression drop | >50% vs. previous week | Slack alert |
| Engagement drop | >50% vs. previous week | Slack alert |
| Platform API error | Any failure | Retry + alert |
| Zero metrics | Any platform returns 0 | Investigate |

### Alert Node

**Node Type:** Slack

**Configuration:**
```json
{
  "channel": "#vetcan-social-alerts",
  "text": "🚨 Analytics Alert\n\nPlatform: {{ $json.platform }}\nIssue: {{ $json.issue }}\nThreshold: {{ $json.threshold }}\nActual: {{ $json.actual }}\n\n@channel Please investigate"
}
```

---

## Demo Request Tracking

### UTM Tracking Integration

**Node Type:** HTTP Request (Google Analytics)

**Purpose:** Pull demo requests attributed to social channels

**Configuration:**
```json
{
  "method": "GET",
  "url": "https://analytics.google.com/analytics/v4/reports",
  "body": {
    "viewId": "{{ $credentials.ga_view_id }}",
    "dateRanges": [{ "startDate": "{{ $json.week_start }}", "endDate": "{{ $json.week_end }}" }],
    "metrics": [{ "expression": "ga:goalCompletionsAll" }],
    "dimensions": [
      { "name": "ga:source" },
      { "name": "ga:medium" },
      { "name": "ga:campaign" }
    ],
    "dimensionFilter": {
      "filters": [
        { "dimensionName": "ga:source", "operator": "IN_LIST", "expressions": ["linkedin", "twitter", "instagram", "tiktok", "youtube"] }
      ]
    }
  }
}
```

**Output:** Demo requests by platform for the week

---

## Related Documents

- [Stellar Social Pipeline](./stellar-social-pipeline.md)
- [Approval Gate Blueprint](./approval-gate-blueprint.md)
- [Campaign Measurement Plan](../../docs/stellar/campaign-measurement-plan.md)
