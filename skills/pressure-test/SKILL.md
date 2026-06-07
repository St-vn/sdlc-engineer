---
name: pressure-test
description: Orchestrates automated load generation (pressure-test-load) and chaos injection (pressure-test-chaos) under a unified gate validation loop.
---

# /pressure-test — Environmental Stress Orchestrator

This skill orchestrates system performance evaluation under concurrent traffic loads and network/infrastructure failures.

## 1. Execution Pipeline
1. Boot up the local test environment (Docker/Compose configurations).
2. Configure **Toxiproxy** links to map upstream datastores.
3. Trigger **k6 load test run** (`/pressure-test-load`) in the background.
4. Concurrently trigger **Pumba/Toxiproxy failures** (`/pressure-test-chaos`) during the peak load window:
   * Inject $1200\text{ms}$ PG database latency.
   * Sever 30% of active connections mid-transaction.
   * Pause the primary API process for 10 seconds.
5. Clean up proxies/toxics, restore normal states, and wait for k6 completion.

## 2. Gate Verification Rules
Execute the metrics evaluator script to calculate if the run passed or failed:
* $P(95) \text{ Latency} \le 500\text{ms}$
* $\text{Failed requests rate} < 1\%$
* $\text{Recovery Time Objective (RTO)} \le 30\text{s}$

Output verification results to `docs/sdlc-engineer/pressure-test-report.md`. If thresholds are breached, terminate with exit code `99` to block deployment.
