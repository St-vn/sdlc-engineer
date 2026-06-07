---
name: pressure-test-chaos
description: OS process lifecycle manipulation (Pumba) and connection-level network degradation (Toxiproxy) chaos testing.
---

# /pressure-test-chaos — Local Chaos Engineering & Resiliency

This skill runs automated chaos tests inside localized Docker/container environments using **Pumba** and **Toxiproxy** to verify circuit breakers, connection pools, and automatic rollback triggers.

## 1. Pumba: Container Lifecycle Disruption
* **Graceful process termination:** `pumba kill --signal SIGTERM api-service` (verifies health checks and traffic migration).
* **Frozen process simulation:** `pumba pause --duration 30s api-service` (simulates stop-the-world GC pauses).
* **Network namespaces latency sidecar:** `pumba netem --tc-image ghcr.io/alexei-led/pumba-alpine-nettools:latest delay --time 500 my-app` (injects packet latency into minimal distroless containers).
* **Cgroup stress OOM simulation:** Uses `stress-ng` sharing the cgroup directory of the target container to trigger real kernel-driven OOM-Killed events.

## 2. Toxiproxy: Database Connection Degradation
* Links Toxiproxy as a middleman proxy between the app database pools and Postgres/Redis ports.
* **Toxic A: Downstream Latency Injection:**
  ```bash
  curl -X POST http://localhost:8474/proxies/postgres_proxy/toxics \
    -H "Content-Type: application/json" \
    -d '{"name": "pg_latency", "type": "latency", "stream": "downstream", "attributes": {"latency": 1200, "jitter": 200}}'
  ```
* **Toxic B: Peer Connection Resets (Random Drop Rate):**
  ```bash
  curl -X POST http://localhost:8474/proxies/postgres_proxy/toxics \
    -H "Content-Type: application/json" \
    -d '{"name": "pg_reset", "type": "reset_peer", "stream": "downstream", "toxicity": 0.3, "attributes": {"timeout": 500}}'
  ```

## Resilience Gating & RTO
* **Recovery Time Objective (RTO):**
  Asserts $T_{recovery} - T_{disconnect} \le 30\text{s}$.
  Verify that retry parameters and database connection reconnect loops recover the system within 30 seconds after network conditions are restored (`DELETE http://localhost:8474/proxies/postgres_proxy/toxics/pg_latency`).
