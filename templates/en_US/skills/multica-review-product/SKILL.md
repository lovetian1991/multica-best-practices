---
name: multica-review-product
description: Requirements/PRD dedicated review framework. Called by ProductReviewer to professionally analyze ProductManager's PRD (scope clear/goal explicit/acceptance testable/constraints complete/open items), output PASS/FAIL + fix list, report to Leader.
---

# Requirements (PRD) Professional Review (ProductReviewer)

Structured professional review framework for **PRD / requirement artifacts**. Called by `ProductReviewer`; reviews the PRD link `ProductManager` returns via `multica-artifact-req-sync`.

## When to use
- ProductReviewer receives a "review PRD" dispatch from Leader.
- Entering a re-review round after PRD changes (check previous round's fix list item by item).

## Review dimensions (conclusion per item)
1. **Scope clear**: boundaries unambiguous, splittable, no implied scope.
2. **Goal explicit**: problem measurable, no vagueness.
3. **Acceptance testable**: every AC- objectively verifiable, no "good experience" vagueness.
4. **Constraints complete**: permissions, exceptions, compliance, dependencies, data口径 listed.
5. **Open items**: OP- items are complete and correctly classified as blocking or non-blocking follow-ups. Only an OP- that affects current scope, business rules, permission / data definitions, AC-, or security/compliance may block.

## OP- decision rules

- **Blocking item**: if unresolved, the current scope, a material business rule, permission / data definition, AC-, or security/compliance cannot be decided or accepted, or downstream design / development would face material rework. An open blocking item may cause FAIL.
- **Non-blocking follow-up**: ordinary preferences, copy details, implementation choices, information that can be supplied later, or anything that does not affect current scope or acceptance. Record an owner and follow-up timing when applicable, but it must not cause FAIL or block downstream work that already has enough definition.
- ProductReviewer must not FAIL the whole artifact merely because "all OP- items are not closed." Check whether the classification is justified and list non-blocking follow-ups separately.

## Output format
```
【PRD Review】<PRD link>
Conclusion: PASS / FAIL
Blocking items (required on FAIL, each: rationale / involved point / fix direction):
- ...
Non-blocking follow-ups (do not block PASS; include owner / timing when applicable):
- ...
Previous fix-list check (re-review): resolved X / unresolved Y
Round: N / 3
```
Conclusion + fix list **reported to Leader**; don't modify PRD or notify ProductManager yourself.

## Boundaries
- Review only PRD/requirements, not design, code, test cases, or UI.
- Don't replace Leader's generic gate (multica-verification skill).
- Technical feasibility goes to ArchReviewer; you own requirement-layer quality.
- Still FAIL at round 3 → mark "escalate to human", hand to Leader, stop looping.
