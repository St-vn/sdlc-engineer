---
name: pressure-test-load
description: Headless load generation and stress testing using k6 scripting and jq JSON metric parsing.
---

# /pressure-test-load — Performance & Load Generation

This skill configures, runs, and monitors headless load generation using **k6** to verify that p95 response latencies and error rates remain within production limits.

## Why k6?
* Lightweight Go engine runs localized JavaScript VM.
* Supports multi-step state scripts (obtaining tokens, DB validations) that standard load generators (like vegeta, hey, autocannon) lack.

## k6 Metric Aggregation
* Stream real-time metrics using command flags: `k6 run --out json=test_results.json script.js`.
* Output streams two lines: `Metric` (declares threshold params) and `Point` (timestamped measurements).
* **Live parsing with JQ:**
  ```bash
  # Calculate average latency of successful requests from active JSON logs
  jq '. | select(.type=="Point" and .metric=="http_req_duration" and .data.tags.status=="200") | .data.value' test_results.json | jq -s 'add/length'
  ```

## Gating Thresholds
At the end of a run, target metrics must be validated using `handleSummary(data)` output reports:
1. **Latency Gate:** $P(95) \le 500\text{ms}$ (the 95th percentile latency of request duration).
2. **Error Rate Gate:** $Rate < 0.01$ (failing status codes or assertion fails must represent less than 1% of transactions).

If any gate is violated, trigger exit code `99` in the automation check script to block the CI/CD deployment pipeline.
