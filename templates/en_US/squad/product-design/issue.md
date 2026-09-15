# Issue Template

> Copy into a new Issue, fill it in, then hand it to the Product Design Squad.

```markdown
# Product Feature Design

## Issue source (required, pick one)
- [ ] External system link (lightweight)
      - Link: https://jira.example.com/browse/<ISSUE-KEY>
      - Summary: <!-- one line describing the product problem or opportunity -->
- [ ] Fully self-contained (default)

## Background
<!-- Why handle this now? What does the current product or process look like? -->

## Target users
<!-- Who has the problem? Do roles have different permissions or goals? -->

## Problem / opportunity
<!-- Describe the problem to solve, not only a proposed solution. -->

## Desired outcome
<!-- What observable user or business change indicates success? -->

## Known scope
- In scope:
- Out of scope:

## Success metrics or acceptance signals
<!-- Business metrics, behavior changes, or checkable product outcomes. -->
- 

## Known constraints
<!-- Time, compliance, data, permissions, platform, brand, compatibility, and so on. -->

## Existing materials
<!-- Current screens, PRDs, feedback, data, competitors, or external links. -->

## Known open questions
<!-- State uncertainty explicitly instead of assuming. -->
- 

## Squad loop tracking (maintained by the Squad)
- Current stage: P0 / P1 / P2 / P3 / P4 / Awaiting Human / Handed off
- Active members:
- Latest stable knowledge-base PRD link:
- `artifact_requirement_internal_link` in Issue metadata:
- Final `multica-verification`: PASS / FAIL; evidence or comment link:
- Blocking OP items: none / <id and owner>
- Human product-scope confirmation: pending / confirmed (confirmer, date:)
- Handoff target: Development Squad / Software Development Squad / N/A
```

---

## Why this shape

- The Issue starts with the problem, users, and outcome so an unvalidated solution does not go directly to Designer or development.
- It does not preselect Agent count; the Leader combines product impact and available evidence to judge L1 / L2 / L3.
- Success signals and known constraints help ProductManager create a reviewable, testable definition.
- Open questions become visible early, while ProductManager maintains the formal OP list in the PRD.
- Loop-tracking fields keep the knowledge-base PRD link, final verdict, Human confirmation, and development handoff in one Issue, preventing a design from finishing without a consumable version.

## Common failure modes

- Writing only "build a page" without the user problem or desired outcome;
- Treating competitor screenshots as confirmed requirements;
- Starting every role and making a small definition pay full-Squad coordination cost;
- Hiding critical constraints until after review;
- Having a design-platform link but no latest knowledge-base PRD link or final-review evidence in the Issue.
