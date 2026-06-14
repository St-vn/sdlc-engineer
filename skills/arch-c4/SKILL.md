---
name: arch-c4
description: Produces C4 model architecture diagrams at levels 1 (System Context), 2 (Container), and 3 (Component) using Mermaid syntax. Use when the user asks for "C4 diagram", "architecture diagram", "system context diagram", "container diagram", "component diagram", "draw the architecture", or when /design reaches this step. Produces diagrams at tier-appropriate depth: level 1 only for hackathon, levels 1-2 for MVP, levels 1-3 for scaling.
---

# /arch-c4 — C4 model diagrams

Produces C4 model diagrams using Mermaid. The C4 model gives four levels of progressive zoom into a software system — each serves a different audience and answers a different question.

Read `sdlc-foundation/decision-frameworks.md` (C4 model section) for level definitions.
Read `sdlc-foundation/maturity-tier-detection.md` for which levels to produce.

## The four levels

| Level | Shows | Audience | Question answered |
| :--- | :--- | :--- | :--- |
| 1 — System Context | Your system + its users + external dependencies | Non-technical stakeholders | What is this system and who uses it? |
| 2 — Container | Deployable units inside the system (apps, databases, APIs) | Technical leadership | What are the major deployable pieces? |
| 3 — Component | Major code components inside one container | Developers | How is this container internally structured? |
| 4 — Code | Classes, interfaces, implementation | Rarely needed | Only for complex/critical modules |

**Level 4 is almost never worth the maintenance cost.** The code itself is the source of truth at that level.

## Mermaid output format

### Level 1 — System Context

```mermaid
C4Context
  title System Context: [System Name]

  Person(user, "End User", "A person who uses the system")
  Person(admin, "Administrator", "Manages system configuration")

  System(system, "[System Name]", "What the system does in one sentence")

  System_Ext(payment, "Payment Provider", "Stripe — processes card payments")
  System_Ext(email, "Email Service", "SendGrid — transactional email delivery")

  Rel(user, system, "Uses", "HTTPS")
  Rel(admin, system, "Administers", "HTTPS")
  Rel(system, payment, "Processes payments via", "HTTPS/REST")
  Rel(system, email, "Sends email via", "HTTPS/REST")
```

### Level 2 — Container

```mermaid
C4Container
  title Container Diagram: [System Name]

  Person(user, "End User")

  System_Boundary(system, "[System Name]") {
    Container(web, "Web Application", "React", "User-facing SPA")
    Container(api, "API Server", "Node.js/Express", "Business logic and data access")
    ContainerDb(db, "Database", "PostgreSQL", "Persistent data store")
    Container(cache, "Cache", "Redis", "Session storage and short-lived caches")
  }

  System_Ext(payment, "Stripe", "Payment processing")

  Rel(user, web, "Uses", "HTTPS")
  Rel(web, api, "API calls", "HTTPS/REST")
  Rel(api, db, "Reads/writes", "SQL")
  Rel(api, cache, "Reads/writes", "Redis protocol")
  Rel(api, payment, "Processes payments", "HTTPS/REST")
```

### Level 3 — Component (inside one container)

```mermaid
C4Component
  title Component Diagram: API Server

  Container_Boundary(api, "API Server") {
    Component(router, "Router", "Express Router", "Routes HTTP requests to handlers")
    Component(authMiddleware, "Auth Middleware", "JWT validation", "Validates bearer tokens")
    Component(userController, "User Controller", "Express Handler", "User CRUD operations")
    Component(orderController, "Order Controller", "Express Handler", "Order management")
    Component(userRepo, "User Repository", "TypeORM", "User data access layer")
    Component(orderRepo, "Order Repository", "TypeORM", "Order data access layer")
  }

  ContainerDb(db, "Database", "PostgreSQL")

  Rel(router, authMiddleware, "Passes requests through")
  Rel(authMiddleware, userController, "Forwards authenticated requests")
  Rel(authMiddleware, orderController, "Forwards authenticated requests")
  Rel(userController, userRepo, "Uses")
  Rel(orderController, orderRepo, "Uses")
  Rel(userRepo, db, "Queries", "SQL")
  Rel(orderRepo, db, "Queries", "SQL")
```

## Procedure

1. **Identify system scope** from prior elicitation/spec output or the user's description
2. **Produce Level 1** — always. Establishes the external boundary unambiguously.
3. **Produce Level 2** at MVP+ tier — identify the major deployable units (web app, API, database, queue, cache, background workers)
4. **Produce Level 3** at scaling tier — for each major container that warrants it; don't Level 3 everything, just the ones with complex internal structure
5. **Add a brief narrative** after each level: what the diagram shows, any architectural patterns visible in it (e.g., "the API is the only component that talks to the database — clean dependency direction"), any concerns

After producing diagrams: recommend `/arch-adr` for any decisions that were implicit in the diagram choices (e.g., which database, which framework).

## Anti-rationalization table
| Common Excuse | Why It's Wrong | What to Do Instead |
|---|---|---|
| "Diagrams get outdated immediately" | Outdated diagrams are still better than no diagrams. The structure rarely changes as fast as the code. | Keep the level 1-2 diagrams current. Update them when architecture changes. |
| "I don't need a diagram, I understand the system" | Understanding in your head doesn't scale to the team. Diagrams communicate structure. | Draw the C4 level 1. If the team can't agree on it, the architecture is unclear. |
| "C4 is overkill for this project" | C4 level 1 is one box with actors. It's never overkill. Level 2-3 is tier-dependent. | Draw the tier-appropriate depth. Hackathon = level 1 only. |
