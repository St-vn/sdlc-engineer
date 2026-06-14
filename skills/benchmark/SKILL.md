---
name: benchmark
description: Performance benchmarking via curl load simulation and Lighthouse (if Node available). Gated on intent: production-saas. Commits benchmark results as JSON for before/after comparison. Invoked by /ship.
---

# /benchmark — performance benchmarking

Runs performance benchmarks and commits results for longitudinal comparison.

## Gate

```
intent: hackathon or mvp → suppressed
intent: production-saas → runs
```

## curl-based load simulation

```bash
# Warmup (not measured)
for i in {1..10}; do curl -s http://localhost:3000/health > /dev/null; done

# Measure p50, p95, p99 for critical endpoints
measure_endpoint() {
  local url=$1
  local n=100
  local times=()
  for i in $(seq 1 $n); do
    t=$(curl -s -o /dev/null -w "%{time_total}" "$url")
    times+=($t)
  done
  # Sort and extract percentiles
  printf '%s\n' "${times[@]}" | sort -n | awk "NR==int($n*0.50) || NR==int($n*0.95) || NR==int($n*0.99)"
}

measure_endpoint "http://localhost:3000/api/[critical-endpoint]"
```

## Lighthouse (if Node available)

```bash
which npx && npx lighthouse http://localhost:3000 \
  --output json \
  --output-path docs/sdlc-engineer/benchmarks/lighthouse-$(date +%Y%m%d).json \
  --chrome-flags="--headless"
```

Extracts: Performance score, LCP, FCP, TBT, CLS.

## Output format

Commit `docs/sdlc-engineer/benchmarks/YYYY-MM-DD.json`:

```json
{
  "date": "YYYY-MM-DD",
  "commit": "[git rev-parse HEAD]",
  "endpoints": {
    "/api/[endpoint]": {
      "p50_ms": 45,
      "p95_ms": 120,
      "p99_ms": 310
    }
  },
  "lighthouse": {
    "performance": 94,
    "lcp_ms": 1200,
    "fcp_ms": 800,
    "tbt_ms": 45,
    "cls": 0.01
  },
  "nfr_comparison": {
    "PERF-001": {"target": "p95 < 200ms", "actual": "120ms", "status": "PASS"}
  }
}
```

```bash
git add docs/sdlc-engineer/benchmarks/
git commit -m "perf: benchmark YYYY-MM-DD — p95=[actual]ms (target=[nfr]ms)"
```

## Before/after comparison

If a prior benchmark exists:
```bash
ls docs/sdlc-engineer/benchmarks/ | sort | tail -2
# Compare current vs previous
```

Surface regressions: any endpoint where p95 increased > 20% from previous benchmark.