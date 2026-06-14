---
name: sync-docs
description: Syncs documentation with implementation at the end of /ship. Detects drift (implemented things not in spec; specced things not in diff), updates README/ARCHITECTURE/CONTRIBUTING/CHANGELOG, marks plan file SHIPPED, updates RTM status. Always runs as the last step of /ship.
---

# /sync-docs — documentation sync

Keeps documentation synchronized with implementation. Runs last in /ship.

## Drift detection (always runs)

**Forward drift (implemented but not specced):**
```bash
# Compare git diff of this feature branch vs spec artifacts
git diff main...HEAD --name-only | grep -v "docs/sdlc-engineer/"
# Find files changed that are not mentioned in any SRS story or AC
```
Finding: "File [X] was modified but is not covered by any AC in the SRS. Options: (1) add a new story to cover it, (2) remove the change if it's scope creep."

**Backward drift (specced but not implemented):**
```bash
# Check each AC in the SRS against git diff
# Any Gherkin scenario with no corresponding test → flag
```
Finding: "AC [US-003 scenario 2] has no test in the diff. Options: (1) add the test, (2) mark as deferred in the RTM."

**ADR drift:**
```bash
# Find decisions made in this feature that don't have an ADR
git log main...HEAD --oneline | grep -i "switch\|migrate\|replace\|use.*instead"
```
Finding: "Commit [hash] suggests an architectural decision was made without an ADR. Create one with /arch-adr."

## Document updates

**README.md:**
- Update features section with new capabilities from this feature
- Update installation/setup section if new dependencies added
- Update environment variables section if new vars required

**ARCHITECTURE.md (if exists):**
- Update component descriptions if components changed
- Add new components introduced in this feature
- Update data model section if schema changed

**CONTRIBUTING.md (if exists):**
- Add any new development commands introduced
- Update test instructions if test approach changed

**CHANGELOG.md:**
```markdown
## [Unreleased] — YYYY-MM-DD

### Added
- [feature description from plan goal]
  
### Changed  
- [any behavior changes]

### Fixed
- [any bugs fixed in this feature]
```

## Plan file update

Mark plan file as SHIPPED:
```markdown
<!-- At top of plan file, add: -->
**Status: SHIPPED — [YYYY-MM-DD]**
**Commit:** [git log -1 --oneline]
```

## RTM update

For each AC in the plan:
- Mark implementation status: IMPLEMENTED
- Link to commit hash
- Mark test status: PASSING (if suite is green)

```markdown
| AC ID | Story | Implementation | Test | Status |
|---|---|---|---|---|
| AC-001 | US-001 | src/api/users.ts:42 | tests/api/users.test.ts:15 | IMPLEMENTED ✓ |
```