# Threat Modeling Methodology — Best Practices

## Design Principles

1. **Threat modeling is a design activity, not a verification activity** — It identifies risks before code exists, shaping architecture decisions. Do it early, refine it continuously.
2. **Four questions drive the process** — What are we working on? What can go wrong? What are we going to do about it? Did we do a good enough job?
3. **STRIDE categories are prompts, not a checklist** — Use them to systematically explore threat categories in your specific system context.
4. **Focus on trust boundaries** — Every cross-boundary data flow is an attack surface. Data entering or leaving a trust boundary is a control point.
5. **Iterate throughout the lifecycle** — A threat model is not a one-time artifact. Update when features change, architecture shifts, or incidents occur.

## When to Apply

- During architecture/design phase (before writing code)
- When adding a new feature or component
- When integrating third-party services or dependencies
- After a security incident (update existing threat model)
- Before any production deployment of a new system
- Cloud-specific: when designing network topology, IAM policies, and managed service usage

## Process

### Step 1: System Modeling — What Are We Working On?

Create a Data Flow Diagram (DFD) using these symbols:

| Symbol | Represents | Example |
|--------|------------|---------|
| External Entity | User, external system | Customer, Payment Gateway |
| Process | Application component | Auth Service, API Gateway |
| Data Store | Database, file system | PostgreSQL, S3 |
| Data Flow | Data moving between elements | HTTP request, message queue |
| Trust Boundary | Security boundary | Internet → VPC, Public → Private subnet |

**DFD creation approach:**

1. Identify external entities (users, third-party services, admin interfaces)
2. Identify processes (microservices, serverless functions, background jobs)
3. Identify data stores (databases, caches, object storage, message queues)
4. Draw data flows connecting entities → processes → data stores
5. Draw trust boundaries around processes that share security contexts
6. Annotate each data flow with: protocol, auth mechanism, data sensitivity level

For cloud-native systems, also describe:
- Virtual networks, subnets, security groups
- IAM roles and policies
- Managed services and their shared responsibility boundaries
- Container orchestration and service mesh topology

**Tools for DFD creation:**
- OWASP Threat Dragon: `npm install -g threat-dragon`
- Microsoft Threat Modeling Tool: download at aka.ms/threatmodelingtool
- OWASP pytm (as-code): `pip install pytm`
- draw.io with threat modeling stencil

### Step 2: Threat Identification — What Can Go Wrong?

Apply STRIDE systematically to each element in the DFD:

| Letter | Category | Violates | Ask | Example Pattern |
|--------|----------|----------|-----|-----------------|
| **S** | Spoofing | Authentication | Can an attacker impersonate a user, process, or external system? | JWT with `alg: none`; weak OAuth; missing client certs |
| **T** | Tampering | Integrity | Can an attacker modify data in transit or at rest? | Unsigned messages; no checksums; database without audit |
| **R** | Repudiation | Non-repudiation | Can a user deny performing an action without the system proving otherwise? | No audit logs; mutable logs; no user attribution |
| **I** | Information Disclosure | Confidentiality | Can an attacker read data they shouldn't? | Excessive API responses; missing encryption; verbose errors |
| **D** | Denial of Service | Availability | Can an attacker make the system unavailable? | No rate limits; unbounded pagination; single point of failure |
| **E** | Elevation of Privilege | Authorization | Can a user gain capabilities they shouldn't have? | IDOR; admin endpoints accessible to all; privilege escalation |

**For each DFD element, run through STRIDE:**

```
External Entity "Customer":
  S: Can an attacker impersonate a customer? → Check auth strength
  T: Can a customer's request be tampered with? → Check request signing
  R: Can a customer deny placing an order? → Check audit logs
  I: Can a customer see other customers' data? → Check data isolation
  D: Can a customer DOS the system? → Check rate limiting
  E: Can a customer become an admin? → Check role assignment

Process "Auth Service":
  S: Can another service impersonate this service? → Check mTLS
  T: Can tokens be tampered with? → Check JWT signature verification
  R: Can auth events be repudiated? → Check logging
  I: Do error messages leak user existence? → Check error handling
  D: Can auth be overwhelmed? → Check rate limits, captcha
  E: Can a regular user forge tokens? → Check secret strength

Data Store "User Database":
  S: Can an attacker spoof a DB connection? → Check connection auth
  T: Can data be tampered with? → Check RLS, audit triggers
  R: Can changes be denied? → Check database audit logs
  I: Is data encrypted at rest? → Check encryption
  D: Can the DB be overloaded? → Check connection pooling
  E: Can SQL injection elevate privileges? → Check parameterization

Data Flow "Login Request":
  S: Can the request be replayed? → Check nonce/timestamp
  T: Can the request be modified in transit? → Check TLS
  R: N/A (request itself)
  I: Is the request encrypted? → Check TLS
  D: Can the flow be flooded? → Check rate limiting
  E: N/A (request itself)
```

**Per-data flow STRIDE is especially important** — data flows are where most attacks happen.

### Step 3: Cloud-Native Threat Modeling Extensions

For cloud architectures, augment STRIDE with these considerations:

| Concern | What to Add to STRIDE Analysis |
|---------|---------------------------------|
| Shared Responsibility Model | What does the provider secure vs. what does the customer secure? Map each component to its responsible party. |
| IAM Misconfiguration | Check S: Can roles be assumed by unauthorized entities? E: Can privilege escalation happen via IAM? |
| Managed Service APIs | Check I: Do managed service APIs expose internal metadata? D: Are there API rate limits per service? |
| Data Residency | Check I: Is data stored in approved regions? Are backup copies in the same region? |
| Container Orchestration | Check E: Can a compromised container escape to the host? T: Can container images be tampered with? |
| Serverless | Check D: Can cold-start flooding cause DoS? I: Do function logs contain secrets? |
| IaC (Infrastructure as Code) | Check T: Can Terraform state be tampered with? S: Can CI/CD pipelines be impersonated? |

### Step 4: Risk Ranking

For each identified threat, rank by likelihood × impact:

| Impact → ↓ Likelihood | Low | Medium | High | Critical |
|----------------------|-----|--------|------|----------|
| High | Medium | High | Critical | Critical |
| Medium | Low | Medium | High | Critical |
| Low | Low | Low | Medium | High |

**Likelihood factors:** Accessibility from internet, authentication bypass possible, exploit complexity, existing controls
**Impact factors:** Data sensitivity, user count affected, regulatory exposure, business continuity

### Step 5: Response and Mitigations — What Are We Going to Do About It?

For each threat, select one response:

| Response | When to Use | Example |
|----------|-------------|---------|
| **Mitigate** | Threat is real and actionable | Add rate limiting, implement RLS, add auth |
| **Eliminate** | Feature/component is non-critical | Remove unused API endpoint |
| **Transfer** | External party can handle it | Use a WAF/CDN for DDoS protection |
| **Accept** | Low likelihood + low impact, or mitigation cost exceeds risk | Accept risk of rate-limiting on internal admin endpoints |

When mitigating, formulate actionable requirements referencing ASVS:

```markdown
## Threat: T003 - Information Disclosure via User Enumeration
- Element: Auth Service → Login Response
- Description: Login endpoint returns different errors for "user not found" vs "wrong password".
- Impact: Attacker can enumerate valid usernames.
- Mitigation: Return generic "Invalid credentials" for all login failures. (ASVS V2.1.1)
- Status: To Do
- Owner: @auth-team
```

### Step 6: Review and Validation — Did We Do a Good Enough Job?

Checklist for completing a threat model:

- [ ] DFD accurately reflects the current system (no drift from actual architecture)
- [ ] All trust boundaries are identified and annotated
- [ ] Every data flow has been analyzed using STRIDE
- [ ] Each identified threat has a response (mitigate/eliminate/transfer/accept)
- [ ] Mitigations are actionable (specific implementation steps, not vague)
- [ ] Accepted risks are documented with business owner sign-off
- [ ] Threat model is stored in a shared location accessible by the team
- [ ] Mitigations can be verified by automated tests or manual review
- [ ] Threat model update trigger events are defined (feature release, incident, infra change)

## Anti-patterns

- **Threat modeling after implementation** — Reversing architecture into DFDs is harder than building the DFD first. Do it during design.
- **One-and-done** — Threat models that aren't updated become dangerously misleading. Stale threat models are worse than no threat model.
- **Only using STRIDE as a checklist** — STRIDE is a brainstorming tool. Checking boxes without thinking about your specific system context misses real threats.
- **Not including non-technical stakeholders** — Product owners and business analysts understand business logic threats that engineers miss.
- **Too much detail too early** — Start high-level with the full system, then drill into components. Don't get lost in one sub-system.
- **Ignoring data flows in favor of component lists** — Threats occur at data flows, not within components. Focus on the lines between boxes, not the boxes themselves.
- **No validation of mitigations** — A mitigation that isn't implemented is a false sense of security. Test each one.

## Tools with Install Commands

```bash
# OWASP Threat Dragon (desktop app)
npm install -g threat-dragon
threat-dragon

# OWASP Threat Dragon (web)
# Go to: https://threatdragon.org/

# OWASP pytm (threat modeling as code)
pip install pytm
# Create threat model in Python, generate DFD + report

# Microsoft Threat Modeling Tool
# Download: https://aka.ms/threatmodelingtool

# draw.io with threat modeling stencil
# Use: https://draw.io and enable threat modeling library

# Cairis (advanced threat modeling platform)
pip install cairis
# Full threat modeling with attack patterns

# IriusRisk (community edition)
# Web-based, free tier available

# STRIDE per-element reference:
# Download: https://learn.microsoft.com/en-us/azure/security/develop/threat-modeling-tool-threats
```
