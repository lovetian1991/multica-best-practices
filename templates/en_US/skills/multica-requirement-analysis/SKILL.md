---
name: multica-requirement-analysis
description: Turn an Issue into a clear, actionable engineering task. Used for requirement clarification, scope confirmation, and acceptance-criteria definition.
---

# Requirement Analysis

## Purpose

Turn an Issue into a clear, actionable product definition in the Product Design Squad's one official feature-named deliverable, `prd-<feature-name>.md`.

## Process

1. Identify the business goal.
2. Identify the expected behavior.
3. Identify the explicit scope.
4. Identify the non-goals.
5. Identify the constraints.
6. Identify the acceptance criteria.
7. Identify ambiguities and classify them as blocking items or follow-ups.
8. Identify dependencies.

## Fixed feature inventory

The detailed feature inventory must use these columns rather than prose alone:

`ID | module | feature | user/role | trigger | input | processing logic | output | priority | dependency | mapped AC-`

Every feature must trace to at least one FR-, BR- (when applicable), and AC-. Requirement design must also state preconditions, the main flow, branch flows, error flows, and boundary conditions.

## Single-document collaboration

- ProductManager creates or updates `prd-<feature-name>.md` first, covering the product definition, feature inventory, requirement design, business rules, and ACs. The feature name must be a short, stable, readable Chinese name, such as `用户邀请` or `订单退款`; do not use the generic `prd.md`, and update the existing file for later changes to the same feature.
- Designer appends only the UI / UX sections to the same feature PRD after ProductLeader dispatches the role.
- Architect appends the technical constraints / feasibility sections after ProductManager completes when needed; Architect waits for Designer's released document only when both roles are enabled.
- Designer and Architect must not edit the same feature PRD concurrently. Standalone UI or technical documents are references or working drafts only and never replace the feature PRD.
- ProductLeader performs the only final review of this same feature PRD; no separate final document is required.

## Output

During execution, create or update the feature's `prd-<feature-name>.md`; do not return only a temporary analysis in chat.

- **Goal**: what problem to solve
- **Scope**: what will change
- **Non-goals**: what explicitly won't change
- **Acceptance criteria**: testable check items
- **Constraints**: compatibility / performance / security / time
- **Dependencies**: prerequisites
- **Open questions**: items needing clarification

## Rule

Don't silently digest ambiguous requirements.

If an ambiguity would materially affect the current scope, business rules, permission / data semantics, acceptance, or safety / compliance:

→ BLOCKED
→ State what is missing and ask for clarification.

If it is an implementation preference, copy detail, deferrable source material, or does not affect current acceptance criteria:

→ Record it as a non-blocking follow-up with an owner.
→ Continue the current product definition.

## Handoff

After the structure is ready, use `multica-artifact-req-sync` to update the reference to this same feature PRD on the team requirement platform (Confluence page + JIRA Story + optional DingTalk). Do not create separate final documents for UI or technical sections; return the stable reference to ProductLeader.

## Why this works

Ambiguity at the requirement stage gets amplified at every later stage. Blocking ambiguity with BLOCKED is far cheaper than letting 5 Agents each guess differently.
