# Visual Reference and Screenshot Documentation Plan

**Status:** Documentation workflow defined; initial capture completed
**Last updated:** 2026-11-08

This page defines how screenshots and visual inspections should become part of the Galaxy Game UI wiki. The goal is a durable visual record of the current prototype, useful patterns from the EVE Dashboard reference, and the decisions that translate those references into Galaxy Game.

Screenshots are evidence and design references. They do not, by themselves, establish approved requirements.

## Completion Status (2026-11-08)

| Step | Description | Status |
|------|-------------|--------|
| Step 1 — Inspect and report | Branch sync, wiki review, environment check | ✅ Completed |
| Step 2 — Capture current Galaxy Game UI | Landing page, sign-in, dashboard, admin console, about page | ✅ Completed (5 screenshots) |
| Step 3 — Document EVE Dashboard | Code-based observations from previously examined JS files | ⚠️ Partially completed (no live access; code-derived only) |
| Step 4 — Reconcile the wiki | Link screenshots to screen concepts and porting plans | ✅ Completed |
| Step 5 — Report back | This document's completion section | ✅ Completed |

## 1. Two visual reference collections

Maintain two clearly separated collections.

### A. Galaxy Game UI — current implementation

Capture what the prototype actually renders and how it behaves. These images answer:
- What exists today?
- What does the current shell, navigation, page, or component look like?
- Which parts are complete, placeholder, inconsistent, or broken?
- What changes between relevant states or viewport sizes?

Suggested location:

    docs/wiki/assets/screenshots/galaxy-game-ui/

### B. EVE Dashboard — external interaction reference

Document the EVE Dashboard experience as a reference for interaction and information architecture. These images and notes answer:
- How does the dashboard organize information?
- How does a user navigate between major activities?
- How are context, filters, selected objects, and detail panels presented?
- Which patterns could be useful in Galaxy Game?
- Which EVE-specific concepts should not be carried over?

Suggested location:

    docs/wiki/assets/screenshots/eve-dashboard/

Keep EVE reference material distinct from Galaxy Game implementation screenshots. Clearly identify it as an external product reference and record source and capture date. Before committing screenshots of a third-party product, check repository visibility and applicable usage rights. If redistribution is not appropriate, document the observations and use links or locally retained, non-committed references instead.

## 2. Screenshot standards

For each useful screenshot:

1. Capture the actual running application or authorized reference environment. Do not recreate a screenshot or present a mockup as a real capture.
2. Capture a meaningful, named state rather than an arbitrary page.
3. Use a consistent desktop viewport for comparisons; record the exact viewport dimensions.
4. Capture a narrow/mobile viewport only where responsive behavior is relevant.
5. Avoid personal information, credentials, private messages, account identifiers, and unrelated browser content.
6. Do not crop away context needed to understand navigation or layout. Make a separate close-up if detail matters.
7. Use annotations only when they clarify a point. Keep an unannotated original as the evidence image.
8. Prefer a small set of informative screenshots over dozens of nearly identical captures.
9. Never imply that a button or interaction works based solely on its appearance. Record whether the behavior was actually tested.
10. Do not commit secrets, session cookies, tokens, or environment configuration with screenshots.

### Suggested file naming

Use lowercase, descriptive names:

    <product>-<area>-<state>-<viewport>-<YYYY-MM-DD>.png

Examples:

    galaxy-game-player-home-default-desktop-2026-11-08.png
    galaxy-game-sign-in-validation-error-desktop-2026-11-08.png
    eve-dashboard-home-overview-desktop-2026-11-08.png
    eve-dashboard-navigation-expanded-desktop-2026-11-08.png

Do not overwrite an earlier evidence image when a screen changes. Add a new dated capture and update the relevant page/manifest.

## 3. Screenshot manifest

Maintain a short manifest alongside each collection, for example:

    docs/wiki/assets/screenshots/galaxy-game-ui/README.md
    docs/wiki/assets/screenshots/eve-dashboard/README.md

Each entry should record:

| Field | What to record |
|---|---|
| Image | Relative image path |
| Product/source | Galaxy Game prototype or EVE Dashboard reference |
| Capture date | Date captured |
| Revision | Git commit/branch for prototype; version or source context for external reference when known |
| Screen/state | Page and exact state shown |
| Viewport | Width × height |
| Interaction tested | What was clicked/changed and observed result; otherwise "visual only" |
| Notes | What the image demonstrates and what remains uncertain |
| Related wiki page | Screen concept, workflow, or JS pattern it supports |

Use VERIFIED for behavior observed directly, VISUAL ONLY for appearance without interaction testing, and OPEN for interpretation or uncertain behavior.

## 4. Galaxy Game prototype capture plan

Qwen should first inspect the current local checkout and running app. Do not assume the GitHub main branch contains all recent local work. Record the actual branch and commit used for the capture.

Suggested initial capture set, adjusted to what currently exists:

| Capture | What it should show | Why it matters |
|---|---|---|
| Player sign-in | Default sign-in page | Branding, form hierarchy, and entry experience |
| Landing page | Full landing page at desktop | Public-facing identity and entry points |
| Player shell | Header, navigation, context area, main content | Establish current application structure |
| Player home/dashboard | Full visible workspace | Compare actual implementation to proposed home concept |
| Navigation states | Expanded/collapsed or selected states if supported | Understand discoverability and navigation behavior |
| Admin sign-in/access boundary | Only if separately implemented | Show player/admin separation |
| Admin overview | Actual admin console screen | Establish current admin capabilities |
| Representative responsive views | Sign-in, shell, and one complex page at narrow width | Identify layout behavior and breakage |

For each page, capture only states that exist. If a proposed screen does not exist, do not fabricate a "current" screenshot; leave it as a wireframe or mark it as not implemented.

Qwen should add a short observation below each image or in a linked gallery page:
- what is present;
- what works and was tested;
- what is placeholder or static;
- what is visually inconsistent;
- what the screen suggests for the next design iteration.

## 5. EVE Dashboard documentation plan

Qwen can contribute useful documentation without copying the EVE product design. Focus on observable interaction and information architecture.

### A. Dashboard structure and navigation

Document:
- global navigation and how primary destinations are grouped;
- dashboard/home organization;
- navigation hierarchy versus contextual navigation;
- how users return to common workspaces;
- how selected context is displayed;
- whether navigation changes the active workspace, selected object, or current location;
- how the interface exposes secondary navigation within a feature.

Deliverable: a concise navigation map or annotated screenshot series. Do not infer the meaning of a feature from its label alone; inspect the destination where possible.

### B. Workspace anatomy

For each relevant EVE workspace, record:
- page title and purpose;
- primary actions;
- secondary actions;
- search/filter/sort controls;
- summary or status regions;
- tables, maps, charts, and detail panels;
- how selection affects other parts of the page;
- empty, loading, error, or unavailable states if observable.

Prioritize the dashboard and the specific areas represented by the JS references Tracy has already shown. Do not attempt to document every EVE feature.

### C. Interaction pattern catalogue

Use the supplied JS reference files as a starting index:

| Reference | What Qwen should document from code and/or live UI |
|---|---|
| fleet_map.js | Map navigation, pan/zoom, markers, routes, hover/selection, contextual actions |
| market.js | Search, filtering, sorting, table selection, summary updates, refresh behavior |
| chain.js | Network layout, node/edge selection, pan/zoom, detail context, editing affordances |
| assets.js | Multiselect filters, select all/none, indeterminate state, typeahead |
| wealth.js | Chart controls, grouping, filters, linked selection, drill-down |
| structures.js | Delegated actions, clipboard interaction, confirmation/feedback |

For each pattern, capture or reference:
- one screenshot showing the pattern in context;
- a short behavior description;
- the relevant source file and function/event handler, where known;
- dependencies and assumptions;
- whether behavior was confirmed in the live UI or inferred from code;
- possible Galaxy Game use;
- EVE-specific behavior that must not be copied.

If Qwen cannot access the live EVE environment, it can still document the supplied source files and any screenshots already available. It must label code-derived observations separately from live-UI verification.

### D. Reusable design observations

Ask Qwen to identify patterns such as:
- persistent global navigation versus page-specific navigation;
- information density and visual grouping;
- table-to-detail workflows;
- map-to-object inspection;
- filters that remain visible while data changes;
- contextual action menus;
- status and notification presentation;
- use of tabs, panels, drawers, and split views;
- responsive adaptations, if observable.

For each observation, write:
1. What EVE does.
2. Why it appears useful (or what drawback it has).
3. Whether Galaxy Game has an equivalent workflow.
4. A proposed adaptation, not a direct copy.
5. The relevant Galaxy Game wiki page.

### E. What not to import from EVE

Do not treat EVE's game-domain hierarchy, terminology, factions, objects, mechanics, permissions, economic rules, navigation labels, visual styling, information density, or feature grouping as Galaxy Game requirements. The reference is for interaction and presentation patterns only. Galaxy Game workflows and established game behavior remain authoritative.

## 6. Proposed EVE documentation outputs

Keep the deliverables focused and link them from the existing wiki rather than creating a large unstructured research dump.

| Proposed page | Contents |
|---|---|
| eve-dashboard-overview.md | Product reference scope, dashboard structure, global navigation, annotated screenshots |
| eve-dashboard-interaction-patterns.md | Pattern catalogue linked to the six JS files, evidence, adaptation notes |
| eve-dashboard-workspace-notes.md | Short notes on only the relevant workspaces represented by the references |
| Screenshot collection README files | Image manifest, source/revision, capture metadata, related wiki pages |

These pages should only be created when Qwen has evidence to put in them. Do not create empty pages or fill gaps with assumptions.

## 7. Suggested Qwen work sequence

This is a documentation assignment, not an implementation task.

### Step 1 — Inspect and report

- Read the Galaxy Game UI project guardrails and current wiki.
- Inspect the current local branch, commit, and working tree.
- Locate the EVE JS reference files and any existing copies/adaptations in the prototype.
- Identify which environments are available for screenshot capture.
- Report any missing access or source material before assuming it exists.

### Step 2 — Capture current Galaxy Game UI

- Run the current app using the established project workflow.
- Capture the available pages and representative states.
- Record branch/commit, viewport, and state for every capture.
- Add images and a manifest to the proposed screenshot directory.
- Link captures to the corresponding screen concepts and current-baseline documentation.
- Do not alter application code to make a screenshot look better.

### Step 3 — Document EVE Dashboard

- Inspect the supplied EVE JS files and trace their behavior.
- Capture relevant live UI examples only if the reference environment is available and access is authorized.
- Create the overview and interaction-pattern notes from observable evidence.
- Separate live-verified facts from source-code observations and interpretation.
- Identify reusable patterns and Galaxy Game adaptation opportunities.

### Step 4 — Reconcile the wiki

- Link screenshots from the screen-concepts, interface-pattern, and JavaScript-porting pages.
- Update the roadmap with completed documentation references.
- Record open questions and missing evidence.
- Avoid duplicating long descriptions across pages; link to the canonical pattern/screen page.

### Step 5 — Report back

Provide a concise report listing:
- files and screenshots added;
- what was directly verified;
- what was inferred from code;
- any access or capture limitations;
- suggested corrections to existing wireframes or porting priorities;
- any decisions that require owner input.

Do not draft implementation tasks, modify application code, change branches, or push changes outside the documentation branch unless separately authorized.

## 8. How screenshots should inform the roadmap

A screenshot can support a design decision, but it does not make the decision automatically.

For example:

- EVE screenshot: a map with a persistent object list and selected-object details.
- Observation: map selection and object inspection are integrated in one workspace.
- Galaxy Game question: should system-map selection open a detail panel or navigate to a separate celestial-body workspace?
- Wiki decision: record the selected approach and rationale after owner review.
- Future task: link to the approved wiki section and implement only the agreed interaction.

This keeps the chain of evidence and decisions visible:

**Reference evidence → observation → Galaxy Game proposal → owner decision → implementation task → verified result.**

## 9. Definition of done

The visual-reference effort is useful when:
- screenshots are genuine, named, and traceable to a revision/state;
- current Galaxy Game screens are visually documented;
- the EVE Dashboard structure and relevant JS patterns are documented with evidence;
- code-derived and live-verified behavior are clearly distinguished;
- useful patterns are mapped to Galaxy Game screens and workflows;
- wireframes and porting priorities are updated where evidence warrants it;
- unresolved decisions remain visibly OPEN;
- no implementation task is drafted prematurely.
