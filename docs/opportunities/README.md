# auto-harness — Opportunity Capture

**Version:** 1.0 | **Owner:** @unclenate | **Last Updated:** 2026-05-12

This directory is the auto-harness project's durable, reviewable surface for
forward-looking candidate records — pre-PRD opportunities filed by participants
(human and agent).

One policy file plus one record per candidate:

- `README.md` — policies and structure for this project's opportunity capture (this file)
- `OPP-NNNN-slug.md` — one structured record per candidate

Agents read this README on each heartbeat to know how to behave when filing
candidates. Humans update this README to tune the Write Policy as the project
evolves.

---

## Record Structure (FOUNDATIONAL)

**Choice:** Structured Record
**Locked:** 2026-05-12 via ADR-0004

Per-candidate records (`OPP-NNNN-slug.md`) MUST follow this structure. Changes
to this choice require an ADR because the structure shapes companion-rule
enforcement, reviewer verification, and the promotion contract.

Each record includes:

- **Metadata block:** `Status` (proposed | exploring | accepted | declined | superseded), `Owner`, `Created`, `Last Updated`, `Confidence` (low | medium | high)
- **Thesis:** One to three sentences — what the opportunity is, in plain language
- **Origin / Evidence:** Links to observations (docs/knowledge/shared-observations.md), external signals, or an explicit `thesis-only` marker with stated reason
- **Why Now:** Timing signal or `n/a`
- **Risks / Open Questions:** What would have to be true; what could kill it
- **Disposition:** Empty while proposed; populated on status change with rationale
- **Promotion:** Empty until accepted; then a link to the spawned PRD-NNNN

See ADR-0004 for the rationale and rejected alternatives. The per-candidate
template is at `platform/templates/opportunity/opp-template.md`.

---

## Write Policy (ADJUSTABLE)

**Current mode:** heartbeat-only
**Last changed:** 2026-05-12 (initial)
**Rationale:** We're early. Signal over volume. Heartbeat-only plays nicely
with token-exhaustion concerns — if the heartbeat fails, no rogue candidates
get filed. Also enforces reflection: agents file candidates only after
dreaming has distilled their daily logs, so entries reflect considered
judgment rather than in-the-moment reactions. Matches the policy choice made
for knowledge-capture (see docs/knowledge/README.md § Write Policy).

Options available:

- **autonomous** — any agent files a candidate anytime (fast capture, noise risk)
- **heartbeat-only** — agents file only during Knowledge Contribution step after dreaming (current)
- **draft-to-promote** — agents stage in memory, humans promote to docs/opportunities/ (highest quality, slowest)

Adjust this value when signal-to-noise conditions warrant it. Log the change
and its rationale.

---

## Status Definitions and Transition Requirements

| Status | What it means | Required when transitioning into this state |
|--------|--------------|-----|
| `proposed` | Newly captured candidate; no active investigation | Audit-trail entry on file creation (companion rule floor) |
| `exploring` | Owner is actively investigating or weighing it | Disposition field populated with current thinking |
| `accepted` | Decision to pursue; PRD has been or will be created in the same commit | **PRD file created/referenced in same commit**; Promotion field populated; Disposition captures rationale for acceptance |
| `declined` | Decision not to pursue | Substantive rationale in Disposition (not a one-line "no") |
| `superseded` | Merged into / replaced by another candidate | Pointer to superseding OPP-NNNN in Disposition |

The companion rule layer enforces audit-trail presence on any OPP edit. The
`humanReview` text on the companion rule covers what the regex cannot — that
the rationale is substantive, that `accepted` is accompanied by a real PRD,
that `declined`/`superseded` aren't drive-by status flips.

---

## References

- Module definition: `platform/profiles/management/opportunity-capture/module.yaml`
- Foundational choice: `docs/adr/ADR-0004-opportunity-capture-record-structure.md`
- Per-candidate template: `platform/templates/opportunity/opp-template.md`
- Spec: `docs/requirements/PRD-0003-opportunity-capture-module.md`
- Related modules: `management/knowledge-capture` (observations the Origin /
  Evidence field links to), `management/product-lite` (the PRD module that
  accepted candidates spawn)

---

**Document Owner:** @unclenate
