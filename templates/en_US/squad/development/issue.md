# Issue Template

> Copy into a new Issue, fill it in, then hand it to the Development Squad.

```markdown
# Development Task

## Issue source (required, pick one)
- [ ] External system link (lightweight)
      - Link: https://jira.example.com/browse/<ISSUE-KEY>
      - Summary: <!-- one line on what to build -->
- [ ] Fully self-contained (default)

## Background
<!-- Why are we doing this? -->

## Goal
<!-- What problem should this development solve? -->

## Scope
<!-- Describe the business or technical area to change. The Leader confirms frontend, backend, architecture, and API scope during T0. -->
- What should change:
- Related modules / services:

## Non-goals
<!-- What explicitly will not be done? -->
- 

## Acceptance criteria (must be testable)
- [ ] 
- [ ] 
- [ ] 

## Constraints and references
<!-- Existing APIs, compatibility requirements, code locations, design, or external docs. -->

## Notes
<!-- Anything the Leader, Architect, or engineers need to know. -->
```

---

## Why this shape

- The Issue provides goals, scope, non-goals, and acceptance criteria; the Leader combines them with the existing code to judge complexity and staffing.
- The Issue does not force a fixed frontend / backend / Architect headcount, so small tasks stay small.
- Acceptance criteria must be testable for the Leader to run the development gate.
- Technical design, API contracts, changed files, and verification evidence are produced during execution rather than fabricated up front.

## Common failure modes

- Writing only "please finish this feature" without a goal or acceptance criteria;
- Hard-coding an implementation plan before Architect and engineers inspect the repository;
- Treating complexity and Agent count as requirement content for the Issue author to decide;
- Omitting non-goals and allowing scope to expand during implementation.
