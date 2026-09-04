# Development Squad Starter

> A lightweight Multica Squad for software development: the Leader dynamically staffs Architect, FrontendDev, and BackendDev.
> **Copy. Paste. Run.**

## Positioning

This Starter focuses on the development phase:

```text
Issue
  ↓
Leader judges complexity and scope
  ↓
Activate Architect / FrontendDev / BackendDev as needed
  ↓
Implement and verify
  ↓
Development handoff package
```

It does not default to product, design, QA, or deployment/operations roles. After handoff, give the package to the existing `software-development` flow, a QA Squad, or a deployment/operations Squad.

## Team

| Logical role | Reused Agent | Main responsibility |
| --- | --- | --- |
| DevelopmentLeader | `agents/development-leader.md` or Squad Instructions | Triage, dynamic staffing, coordination, gates, escalation |
| Architect | `agents/architect.md` | Technical analysis and architecture design, on demand |
| FrontendDev | `agents/frontend-developer.md` | Frontend implementation and verification, on demand |
| BackendDev | `agents/backend-developer.md` | Backend implementation, API contract, and verification, on demand |

DevelopmentLeader is a required logical role but does not always need a separate Agent. When Multica injects Squad Instructions into the Leader, use `squad.md` directly. When a standalone Leader Agent is used, use [`../../agents/development-leader.md`](../../agents/development-leader.md).

## Dynamic staffing

| Complexity | Signals | Default combination |
| --- | --- | --- |
| L1 simple | One end, local module, no public contract or architecture change | Leader + one relevant engineer |
| L2 medium | Multiple modules, frontend/backend coordination, public API change | Leader + relevant engineer(s), Architect as needed |
| L3 high risk | Core architecture, migration, security, performance, cross-service, or major compatibility | Leader + Architect + relevant engineer(s) |

Complexity is not a fixed headcount chosen in the Issue. The Leader reads the requirement and code during T0 and makes the decision. If risk changes during execution, the Leader can add or release members and record why.

## Skills

| Skill | Mount to | Purpose |
| --- | --- | --- |
| `multica-verification` | Leader | Independent rerun and development gate |
| `multica-requirement-analysis` | Leader / Architect | Requirement and scope structuring, as needed |
| `multica-technical-design` | Architect | Technical design and verification approach |
| `multica-implementation` | FrontendDev / BackendDev | Implementation method |
| `multica-artifact-design-sync` | Architect | Land technical design artifacts, as needed |
| `multica-artifact-api-sync` | BackendDev | Land API contracts, as needed |

Production URLs, credentials, and concrete platforms remain only in the relevant `multica-platform-*` shells.

## 5-minute setup

### Step 1: Create or reuse Agents

Reuse these existing Agent Instructions; this Starter uses the dedicated `DevelopmentLeader`:

```text
DevelopmentLeader
Architect
FrontendDev
BackendDev
```

The Leader is configured by the Squad. If the Multica workspace needs a standalone Leader Agent, copy [`../../agents/leader.md`](../../agents/leader.md).

Use the naming convention in [`docs/en_US/naming-conventions.md`](../../../../docs/en_US/naming-conventions.md):

```text
Architect-<project>-<member-id>
FrontendDev-<project>-<member-id>
BackendDev-<project>-<member-id>
```

### Step 2: Mount Skills

Create or reuse the Skills in the table above and assign them by mount target. Skills are referenced by name; do not put repository paths into Agent Instructions.

### Step 3: Create the Squad

Create a Squad and copy the code block from [`squad.md`](./squad.md) into the Squad Instructions.

### Step 4: Create the Issue

Copy [`issue.md`](./issue.md) into a new Issue and fill in the goal, scope, and testable acceptance criteria. Do not hard-code the number of Agents; the Leader triages it.

### Step 5: Run

Assign the Issue to the Squad. The Leader completes T0 first, then dispatches as needed:

```text
T0 triage → T1 technical readiness (as needed) → T2 API contract (as needed) → T3 implementation → T4 development handoff
```

## Definition of development handoff complete

The handoff must include:

- complexity level and active members;
- changed-file list;
- item-by-item acceptance mapping;
- technical design or API contract references, when applicable;
- actual verification commands and results;
- known limitations, risks, and uncovered areas;
- follow-up notes for QA and deployment/operations.

This means development is complete. QA pass, deployment success, and business acceptance remain with the corresponding Squad or a Human.

## When to use

- A requirement or bug is already clear and needs focused implementation;
- frontend and backend should be independently or concurrently activated by scope;
- the Leader should control context and Agent count based on complexity;
- development should be composable with separate QA and operations Squads.

## When not to use

- The goal and acceptance criteria are not ready;
- The task needs product discovery, user research, or UI design;
- The task requires independent QA acceptance or production release;
- The task is an urgent production incident; use [`bug-fix`](../bug-fix/README.md) instead.

## Why this works

This Starter treats the Squad as a development capability pool and places complexity judgment in the Leader's T0 phase. One reusable development Squad can handle a single-ended small task or a full-stack feature, while keeping downstream QA and operations composable.

## Common failure modes

- Treating all four members as mandatory for every task;
- Letting an engineer decide product scope or approve their own implementation;
- Judging complexity without reading the code;
- Skipping the API contract and making frontend guess the interface;
- Returning only a verbal completion claim instead of reproducible evidence.

## Directory

| File | Purpose |
| --- | --- |
| `squad.md` | Copy-ready Squad Instructions with dynamic triage and development gates |
| `issue.md` | Development-task Issue template |
| `README.md` | Positioning, staffing, Skills, and setup |
| [`../../agents/`](../../agents/) | Shared Agent Instructions |
| [`../../skills/`](../../skills/) | Shared Skills |
