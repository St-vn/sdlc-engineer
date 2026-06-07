---
name: research-market
description: Executes live market research, competitor landscape audits, Reddit listening, and Product Hunt GraphQL queries.
---

# /research-market — Market Research & Competitor Discovery

This sub-skill gathers market signals, identifies competitor features/ratings, and extracts user pain points from community channels.

## Pre-flight
* Ensure search capability or Product Hunt bearer tokens are configured (or gracefully degraded).
* Inputs: `intent` (from configuration) and target product/domain.

## Mandatory Searches & Queries

### 1. Reddit Listening Loop
* Query subreddits for validated high-intent user complaints and feature gaps.
* **Query templates:**
  * `"competitor_name" (sucks | hate | broke | bad | issue | fail)`
  * `"product_category" (alternative | replacement | better)`
* Target threads with revenue proof (e.g. MRR/ARR metrics) to verify demand.

### 2. Product Hunt V2 GraphQL Audit
* Execute search lookup: `site:producthunt.com/posts "competitor_name"` to resolve the slug (e.g., `linear-5`).
* Perform POST request to `https://api.producthunt.com/v2/api/graphql` using Bearer token:
```graphql
query GetCompetitorMetrics {
  post(slug: "competitor-slug") {
    id
    name
    tagline
    votesCount
    commentsCount
    reviewsRating
    website
    createdAt
  }
}
```

## Outputs
* **Competitor Profiles:** 3-5 players, votes, review rating, and documented product weaknesses (e.g. "Billing-bot: fails under database connection dropouts").
* **TAM / SAM / SOM Calculations:** Fermi-method calculated figures.
* **SWOT Matrix:** Analyzed strengths, weaknesses, opportunities, and threats.
