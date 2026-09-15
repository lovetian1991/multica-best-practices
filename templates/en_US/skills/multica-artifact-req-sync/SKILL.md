---
name: multica-artifact-req-sync
description: Land product requirement / PRD artifacts to the requirement knowledge platform (default Confluence). Used by @ProductManager, @Designer, and @Architect to update the shared PRD and return a stable link for downstream consumption. Swappable platform.
---

# Artifact · Requirement Sync

## Purpose

Land product requirement artifacts to the team's unified requirement platform and let downstream retrieve them via a stable reference.

The Product Design Squad maintains one final feature-named PRD file, `prd-<feature-name>.md`. This skill lands and updates that document, including later UI / UX and technical-constraint additions, without creating separate final documents for different roles.

> This skill decouples "platform integration" from "role prompt": the role prompt only says "produce PRD", not which platform. Changing companies (Wiki / Yuque / Feishu / internal KB) means editing only this skill, not the @ProductManager prompt.

## Single PRD rule

- ProductManager creates `prd-<feature-name>.md` first and completes the detailed feature inventory, requirement design, business rules, and ACs. The feature name must be a short, stable, readable Chinese name, such as `用户邀请` or `订单退款`; do not use the generic `prd.md`.
- Designer and Architect append their assigned sections to the same feature PRD in the sequence chosen by ProductLeader, using stable references for UI / UX and technical additions.
- On later syncs, update the existing PRD page or its version instead of creating parallel final documents such as "UI PRD", "Technical PRD", or a synonym PRD for the same feature.
- The stable link returned to ProductLeader must point to the merged feature PRD; standalone design or technical drafts may only be references inside it.

## Default platform: Confluence

- Output: PRD (or MRD / dashboard spec / cross-system spec / acceptance checklist, by type).
- Upload: create / update a page in Confluence, keeping G-/FR-/BR-/AC-/KPI-/OP-/RISK- ids and stable headings (see `docs/en_US/gates-and-evidence.md` AI-readable discipline).
- Retrieve: downstream @Architect / @Designer / @FrontendDev / @BackendDev / @Tester read via the **page link** — the link is the stable reference.

## Content spec (platform-independent part)

PRD at least contains (see @ProductManager role instruction): one-line definition, background, goals G- + KPI-, users & permissions, scope, detailed feature inventory, FR-/BR-/AC-, preconditions, main / branch / error flows, boundary conditions, UI / UX, technical constraints, field definitions, empty/error/no-permission states, RISK-/OP-, and revision log.

## Usage (role side writes only this line)

> @ProductManager / @Designer / @Architect: "Update the shared feature PRD, land the latest version via `multica-artifact-req-sync` skill to the team requirement platform, and return the latest stable link."

After Designer or Architect appends a section, the role must write any UI / technical reference back into the same PRD and run this Skill again. A design-platform link or standalone technical draft alone does not complete the product-design handoff.

Fixed append-sync order: re-read the latest Issue status and metadata → fetch the current PRD through the latest `internal_link` → append only the assigned section → preserve the original filename and update it with `--reference` → write the returned metadata/comment back to the Issue. Any failure returns `BLOCKED`; do not start final review or handoff.

## Swap platform (no role-prompt change)

Replace this skill's "default platform" section with your tool (Yuque / Feishu / Notion / internal Wiki), keeping the "upload + return stable link" interface unchanged.

## Why it works

Platforms differ greatly across teams; hard-coding the platform name into the role prompt freezes it. Sinking it into the skill keeps the role's "what to produce" description stable while the platform swaps with the skill.
