---
name: qa-headless
description: Headless HTTP integration testing using curl. Derives test cases mechanically from Gherkin acceptance criteria. Zero external dependencies. Depth gated on intent tier. Invoked by /ship after audit-security.
---

# /qa-headless — headless HTTP QA

Derives and executes HTTP test cases from the Gherkin AC in the SRS. No browser. No dependencies beyond curl (pre-installed everywhere).

## Test case derivation

For each Gherkin Given/When/Then:

```
Given [state] → setup: create required state via API or direct DB call
When [HTTP action] → request: curl command with headers, body, method
Then [outcome] → assertion: check HTTP status code + response body
```

Example:
```gherkin
Given a user is logged in
When they POST /api/habits with name="Exercise" and frequency="daily"
Then the response is 201 Created with the habit ID
```

Becomes:
```bash
# Setup: get auth token
TOKEN=$(curl -s -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"testpass"}' \
  | jq -r '.token')

# Test
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST http://localhost:3000/api/habits \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"name":"Exercise","frequency":"daily"}')

HTTP_CODE=$(echo "$RESPONSE" | tail -1)
BODY=$(echo "$RESPONSE" | head -1)

# Assert
[ "$HTTP_CODE" = "201" ] || echo "FAIL: expected 201, got $HTTP_CODE"
echo "$BODY" | jq '.id' > /dev/null || echo "FAIL: response missing habit ID"
```

## Depth calibration

**intent: hackathon**
- Health checks only: `curl http://localhost:3000/health`
- Critical path (1-2 happy path flows only)

**intent: mvp**
- Health checks
- API contract (all endpoints return expected status codes)
- Auth enforcement (protected endpoints return 401 without token)

**intent: production-saas**
- Full suite:
  - Health checks
  - API contract
  - Auth enforcement
  - NFR verification: `curl -w "%{time_total}" -o /dev/null -s [url]` (compare against PERF NFRs)
  - Error handling (malformed input returns 400, not 500)
  - Integration paths (multi-step flows from Gherkin AC)

## Output format

```markdown
## QA Headless — [YYYY-MM-DD]
Intent tier: [hackathon/mvp/production-saas]
Tests run: N
Tests passed: N
Tests failed: N

### Failures
[test name + expected vs actual + curl command that failed]

### NFR verification
[PERF-001: target < 200ms, actual: 145ms ✓]

### Verdict: PASS / FAIL
```
