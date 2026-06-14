---
name: launch-readiness
description: Pre-launch verification checklist. Every checklist item was already required by /spec or /tasks — this skill verifies, does not discover for the first time. Gated on launch-tier: standard or full (hackathon: suppressed). Invoked by /ship.
---

# /launch-readiness — pre-launch verification

This skill verifies that all launch requirements (previously captured in /spec and planned in /tasks) are actually implemented. Nothing new is discovered here — if something appears new, it's a /spec gap.

## Gate

```
launch-tier: minimal (hackathon) → suppressed entirely
launch-tier: standard → auth + legal + feedback sections
launch-tier: full → all sections
```

## Proactive integration note

Items in this checklist SHOULD have already been surfaced during /spec (as NFRs or ACs) and /tasks (as implementation tasks). If this checklist reveals something new: flag it as a spec gap and add it as a task before launch.

## launch-tier: standard — checklist

**Auth and session (gate: auth: email+)**
- [ ] Signup flow: email verification required before access
- [ ] Password reset: works end-to-end (email delivered, link valid, token expires)
- [ ] Session timeout: enforced (configurable, not infinite)
- [ ] "Remember me": cookie expiry correct
- [ ] Auth errors: no credential enumeration (same error for "user not found" and "wrong password")

**Legal (gate: intent: mvp or production-saas)**
- [ ] Privacy policy: linked from footer, content appropriate for data collected
- [ ] Terms of service: linked from signup flow, must-accept gate
- [ ] Cookie consent: banner shown on first visit (gate: audience: eu-consumers)
- [ ] Data deletion: user can delete their account and all associated data

**Feedback loop**
- [ ] Error reporting: user-facing errors are friendly (not stack traces)
- [ ] Feedback mechanism: at minimum, an email address or form users can contact
- [ ] Analytics: basic page view tracking configured (if opted into)

## launch-tier: full — additional sections

**GDPR/privacy (gate: audience: eu-consumers)**
- [ ] DPA (Data Processing Agreement): signed with all processors
- [ ] Cookie consent: granular (analytics/functional/necessary categories)
- [ ] Data export: user can download their data (GDPR Article 20)
- [ ] Data deletion: fulfilled within 30 days (GDPR Article 17)
- [ ] Privacy policy: mentions lawful basis for each data type

**Payment lifecycle (gate: monetization: subscription+)**
- [ ] Subscription created: webhook received and processed
- [ ] Payment failed: user notified, grace period implemented
- [ ] Subscription cancelled: access revoked at period end, not immediately
- [ ] Refund flow: documented and tested
- [ ] Invoice: generated and emailed on successful charge

**SEO/discoverability (gate: intent: mvp+public or production-saas)**
- [ ] `<title>` and `<meta description>`: set on all key pages
- [ ] `robots.txt`: exists and correct
- [ ] `sitemap.xml`: exists and submitted to search console
- [ ] Open Graph tags: correct for social sharing

**Monitoring and incident response**
- [ ] Uptime alert: configured (pagerduty/SMS)
- [ ] On-call: someone has the alert → knows what to do
- [ ] Runbook: at minimum, "how to restart the service"
- [ ] Status page: exists (even a simple static page)