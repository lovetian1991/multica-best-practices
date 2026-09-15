# Product Design Squad Starter

> A Multica Squad for designing many kinds of product features, turning an idea, problem, or improvement request into a product definition package reviewed by ProductLeader.
> **Copy. Paste. Run.**

## Positioning

This Starter owns the product-design phase:

```text
Idea / problem / improvement request
  ↓
ProductLeader dispatches ProductManager first
  ↓
ProductManager product analysis and product definition / PRD
  ↓
ProductLeader decides whether more design is needed
  ↓
Designer / Architect as needed (no intermediate review)
  ↓
ProductLeader performs the final unified review
  ↓
Human confirmation → product definition handoff
```

It can design new features, improve existing features, define workflows and approvals, permissions and state machines, dashboards, cross-system collaboration, and multi-device experiences. It does not implement code, perform formal QA, deploy, or release.

## Team

| Logical role | Reused Agent | Activation |
| --- | --- | --- |
| ProductLeader | `agents/product-leader.md` or Squad Instructions | Required; product triage, orchestration, general gates, escalation |
| ProductManager | `agents/product-manager.md` | Required; product definition and PRD |
| Designer | `agents/designer.md` | Activate for pages, interactions, or multi-device experiences |
| Architect | `agents/architect.md` | Activate for cross-system, data, permissions, performance, or costly decisions |

ProductLeader is the only reviewer in this Squad. ProductLeader owns the final unified gate, rework decision, and final release, but does not replace ProductManager, Designer, or Architect as an author. After ProductManager finishes, ProductLeader only decides whether more roles are needed; there is no intermediate formal review.

## Dynamic staffing

| Complexity | Signals | Default combination |
| --- | --- | --- |
| L1 lightweight product definition | One bounded feature, a small change to an existing page, or a local improvement | ProductLeader + ProductManager; produce a compact change note |
| L2 experience design | New page, key interaction, multi-role flow, or multi-device experience | L1 + Designer |
| L3 complex product | Cross-system work, data definitions, permission state machines, core flows, or costly constraints | L1 + Designer and/or Architect as needed |

ProductLeader decides complexity and later active members during P0 after reading the input and existing materials, but ProductManager must be the first downstream dispatch. Even with a clear existing PRD / Issue, dispatch ProductManager for lightweight reuse and delta validation instead of requesting the full checklist again or bypassing ProductManager. L1 fills only the problem / goal, change scope, and acceptance criteria needed for the task; unrelated permissions, KPIs, state machines, and data definitions are not blockers.

## Cost control

The Product Design Squad uses a lightweight path by default. A member's presence in the Squad does not mean the member is called for every task:

| Mode | Default calls | Use for |
| --- | --- | --- |
| L1 lightweight | ProductLeader + ProductManager | One feature, local optimization, or a small existing-page change |
| L2 standard | L1 + Designer | New pages, key interactions, multi-role, or multi-device experience |
| L3 high risk | L1 + Designer and/or Architect as needed | Cross-system work, complex data / permissions, core flows, or costly decisions |

Each dispatch carries only a task capsule, stable artifact references, and the current delta. Do not default to copying the full chat history, full PRD, or unrelated artifacts. L1 reviews only the current delta and affected ACs; reuse existing artifacts and verdicts when there is no semantic change. Rework is limited to one round for L1, two for L2, and three for L3, then escalates to a Human.

## Unified review

Formal review happens once, at the end, after all required outputs are complete:

1. After ProductManager finishes, ProductLeader decides whether Designer / Architect are needed, without producing an intermediate PASS / FAIL.
2. When additional roles are needed, dispatch them directly and wait for their outputs; do not call another Reviewer Agent.
3. Use `multica-verification` for one final consistency review. PASS releases the package; FAIL returns a concrete fix list to the author, and rework returns to the final review.

Rework follows the complexity budget: one round for L1, two for L2, and three for L3; a failure after the applicable limit escalates to a Human. Author self-checks do not replace ProductLeader review.

## Skills

| Skill | Mount to | Purpose |
| --- | --- | --- |
| `multica-verification` | ProductLeader | General gates and cross-artifact consistency |
| `multica-requirement-analysis` | ProductManager | Structure the problem and idea into a product definition |
| `multica-artifact-req-sync` | ProductManager, Designer, Architect | Initially land and subsequently update the same PRD in the knowledge base, returning the latest stable reference |
| `multica-artifact-ui-sync` | Designer | Land UI / interaction design |
| `multica-technical-design` | Architect | Technical feasibility and constraints |
| `multica-artifact-design-sync` | Architect | Land technical design |

Concrete platforms, URLs, and credentials remain only in the relevant `multica-platform-*` shells.

## 5-minute setup

### Step 1: Reuse Agents

Reuse ProductManager, Designer, and Architect. ProductLeader is configured by the Squad. If the workspace requires a standalone Leader Agent, use [`../../agents/product-leader.md`](../../agents/product-leader.md).

Follow [`docs/en_US/naming-conventions.md`](../../../../docs/en_US/naming-conventions.md).

### Step 2: Mount Skills

Mount Skills according to the table above. Reference Skills by name; keep repository paths and company platform settings out of Agent Instructions.

### Step 3: Create the Squad

Copy the code block from [`squad.md`](./squad.md) into Squad Instructions and add the roles above.

### Step 4: Create an Issue

Copy [`issue.md`](./issue.md) into a new Issue. Prefer the problem, goal, change scope, and acceptance criteria; when an external PRD already exists, provide its link and the delta. Do not fix the Agent count or solution in advance.

### Step 5: Run

```text
P0 triage
  → P1 ProductManager product definition
  → ProductLeader decides whether Designer / Architect are needed
  → UI / interaction and/or technical feasibility work as needed, updating the same PRD in the knowledge base (no intermediate review)
  → P4 ProductLeader final unified review
  → Human confirmation and handoff
```

## Product definition handoff

The completed package includes at least:

- product goals, users, scope, and non-goals;
- user stories, functional requirements, business rules, and acceptance criteria;
- permissions, states, and field / metric definitions;
- normal, empty, error, and no-permission states;
- UI / interaction references when applicable;
- technical feasibility, dependencies, and constraints when applicable;
- the latest stable knowledge-base link to the same PRD;
- final ProductLeader verdict on the product definition, UI / interaction, and technical design;
- closed OP items and items still awaiting Human decisions;
- development split suggestions, risks, and verification concerns.

Only a Human confirms product scope and sends the package into development. Review PASS does not mean implementation, testing, or release is complete.

## When to use

- Design a new feature from an idea, business problem, or user feedback;
- Improve an existing flow, page, permission model, state machine, or dashboard;
- Compose product, experience, and feasibility capabilities based on complexity;
- Require a unified quality review before development starts.

## When not to use

- The PRD and design are already confirmed and only code is needed: use [`development`](../development/README.md);
- The task needs the full implementation, QA, and deployment chain: use [`software-development-reviewed`](../software-development-reviewed/README.md);
- The task is an urgent production incident: use [`bug-fix`](../bug-fix/README.md).

## Why this works

- ProductManager defines the feature before Designer or engineers can guess business rules.
- UI and technical feasibility are activated only when needed; when only one role is enabled it starts directly, and when both are enabled they append to the shared PRD in Designer → Architect order.
- ProductLeader checks every applicable artifact against the acceptance criteria, reducing Reviewer Agents and repeated context.
- The Squad hands development one coherent product definition package instead of conflicting PRDs, mockups, and technical opinions.

## Common failure modes

- Drawing screens before defining the user problem, scope, and business rules;
- Letting ProductManager, Designer, and Architect edit the same product decisions;
- Reusing an old PASS after UI or technical constraints change;
- Returning only a design-platform link after design, without writing the updated PRD back to the knowledge base;
- Sending development a requirement while blocking OP items remain open.

## Directory

| File | Purpose |
| --- | --- |
| `squad.md` | Copy-ready Squad Instructions with dynamic triage and ProductLeader unified review |
| `issue.md` | Product-feature-design Issue template |
| `README.md` | Positioning, team, review model, and setup |
| [`../../agents/`](../../agents/) | Shared Agent Instructions |
| [`../../skills/`](../../skills/) | Shared Skills |
