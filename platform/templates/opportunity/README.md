# [[PROJECT_NAME]] — Opportunity Capture

**Version:** 1.0 | **Owner:** [[OWNER]] | **Last Updated:** YYYY-MM-DD

This directory is the project's durable, reviewable surface for forward-looking
candidate records — pre-PRD opportunities filed by participants (human and agent).

One policy file plus one record per candidate:

- `README.md` — policies and structure for this project's opportunity capture (this file)
- `OPP-NNNN-slug.md` — one structured record per candidate

Agents read this README on each heartbeat to know how to behave when filing
candidates. Humans update this README to tune the Write Policy as the project
evolves.

---

## Record Structure (FOUNDATIONAL)

**Choice:** Structured Record
**Locked:** YYYY-MM-DD via [[LOCKING_ADR]]

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

See the locking ADR for the rationale and rejected alternatives. The
per-candidate template is at `platform/templates/opportunity/opp-template.md`.

---

## Write Policy (ADJUSTABLE)

**Current mode:** [[WRITE_POLICY]]
**Last changed:** YYYY-MM-DD (initial)
**Rationale:** [[WRITE_POLICY_RATIONALE]]

Options available:

- **autonomous** — Any agent may file a new candidate at any time during normal
  work or heartbeats. Fastest capture; highest noise risk.
- **heartbeat-only** — Agents may only file candidates during the Knowledge
  Contribution step of their heartbeat, after dreaming has distilled their
  daily logs. Paced and reflective. Recommended default.
- **draft-to-promote** — Agents stage candidates in their own daily memory;
  a human reviewer promotes them to `docs/opportunities/`. Highest quality;
  requires active curation.

Change this value when the signal-to-noise ratio warrants it. Note the change
and its rationale in the metadata above.

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
- Foundational choice: [[LOCKING_ADR]]
- Per-candidate template: `platform/templates/opportunity/opp-template.md`
- Related modules: `management/knowledge-capture` (observations the Origin /
  Evidence field links to), `management/product-lite` (the PRD module that
  accepted candidates spawn)

---

**Document Owner:** [[OWNER]]
