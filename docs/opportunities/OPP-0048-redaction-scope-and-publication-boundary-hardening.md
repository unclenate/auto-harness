<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0048 — Redaction-Scope & Publication-Boundary Hardening

**Status:** accepted
**Owner:** @unclenate
**Created:** 2026-06-17
**Last Updated:** 2026-06-24 *(`proposed` → `accepted`: [PRD-0026](../requirements/PRD-0026-publication-boundary-marker.md) ratifies the thin wedge — mechanism 1, the always-on file-level `do-not-publish` blocking validator. Mechanism 2 (configurable content-denylist scan-scope) carried forward as a named phase-2 follow-up. Prior: 2026-06-17 filed.)*
**Confidence:** high

---

## Thesis

The redaction guardrail shipped in [OPP-0036](OPP-0036-validate-knowledge-redaction.md)
(`validate-knowledge-redaction.sh`) protects exactly two files —
`docs/knowledge/shared-observations.md` and `docs/operating-principles.md` —
against a **hardcoded** denylist. That is the right primitive but the wrong
*blast radius*. auto-harness is a **public** repository that, in normal use,
parks **untracked private design material** (client/project names, architecture
context) under `docs/superpowers/specs/`. Today nothing machine-checkable stops
that material from being committed: the path is excluded from the placeholder
validator (`.placeholder-ignore`) **and** from markdownlint, the redaction
scanner does not look there, and the denylist does not contain the active
private-project names. A single `git add -A` from any agent (Claude, Codex,
Gemini) would publish it tripping **zero CI guardrails**.

The proposal closes the gap with two complementary mechanisms:

1. **Extend OPP-0036's content scanner** — a wider, *configurable* scan scope
   (include `docs/superpowers/specs/**`) and a denylist sourced from a file
   rather than hardcoded, so the corpus of protected names can grow without
   editing the validator.
2. **Add a file-level publication-boundary marker** — a `do-not-publish: true`
   frontmatter (or sibling `.do-not-publish`) plus a **blocking** validator that
   fails CI / pre-commit if any file bearing that marker is *tracked* in git.
   This needs no name list at all: it protects the whole parked file by
   intent-declaration, and generalizes to any artifact (specs, briefs, exports).

This is the multi-agent-workspace analog of the same declare-then-enforce
contract the harness already runs for modules — except the asset under
protection is *unpublishability* rather than scope.

## Origin / Evidence

- **Live forcing case (2026-06-11 → present).** A 716-line Digital Twin /
  Scenario Runtime seed brief is parked **untracked** at
  `docs/superpowers/specs/2026-06-09-digital-twin-seed-brief.md`. The maintainer's
  standing decision is "leave untracked, do not publish" — it names several
  private/client projects. That decision is currently enforced **only by agent
  memory and manual `git add` discipline**, not by any machine check. This OPP
  exists because that protection is one fat-fingered `git add -A` away from
  failing, irreversibly, against a public remote.
- **OPP-0036 coverage gap (documented at filing time).** The shipped validator
  (a) scans only the two knowledge files, (b) carries a **hardcoded** denylist
  (`Tula`, `OpenEMR`, `YouBase`, `municipal-brain`, `toast-mcp`) that omits the
  active private-project corpus, and (c) is **WARN-only** in diff mode. None of
  those three properties is wrong for *knowledge-file* redaction; all three are
  insufficient for *parked-file* protection.
- **The exclusion stack compounds the risk.** `docs/superpowers/specs/**` is in
  `.placeholder-ignore` **and** the `.markdownlint-cli2.jsonc` ignore globs, so
  the two validators that *do* scan broadly both skip it. The directory is a
  deliberate unpublished working area (good) with **no** publish-time gate (bad).
- **Internal precedent.** `forbiddenPatterns` (companion rules) already hard-fails
  on path patterns; OPP-0036 extended pattern-matching to *content*; this OPP
  extends it again to *file-publication intent*. The `do-not-publish` marker is
  the inverse of `requiredArtifacts` — a "must-NOT-exist-in-tracked-tree" assertion.

## Why Now

- **The risk is active, not hypothetical** — sensitive material is parked in the
  working tree of a public repo *right now*, guarded only by convention.
- **The workspace is multi-agent.** Claude, Codex, and Gemini all commit under the
  same identity in this repo. A convention that depends on every agent remembering
  a per-file rule does not scale with agent count; a blocking validator does.
- **The cost asymmetry is extreme.** The guardrail is small (extend one ~50-line
  validator + add one marker check). The failure it prevents — publishing client
  names to a public, indexed, mirror-able Git remote — is irreversible.
- **OPP-0036's recipe applies directly.** Same diff-extraction shape, same
  exemption-file convention, same WARN/BLOCK posture lever.

## Risks / Open Questions

1. **The denylist cannot live as literals in a tracked public file** — that would
   itself publish the names this OPP exists to protect. Bias: the scanner reads a
   **gitignored local denylist** (e.g. `.knowledge-redaction-denylist.local`)
   merged with the public baseline; the file-level marker mechanism (which needs
   no names) is the primary protection, and the name-denylist is the
   defense-in-depth second layer. Resolve the exact source-of-truth at PRD time.
2. **Warn vs block posture.** Bias: the *file-level publication-boundary* check is
   **BLOCK** (a tracked do-not-publish file is never acceptable — the cost is
   irreversible). The *content denylist extension* stays **WARN** in line with
   OPP-0036, to avoid blocking legitimate doctrine that must cite a consumer.
   Two mechanisms, two postures — classify both explicitly in the PRD §10 table.
3. **Pre-commit vs CI timing.** CI catches a leak only *after* the push that
   already exposed it on the remote. Bias: ship the validator so it can run as a
   **pre-commit hook** as well as in CI, and document the hook in the consumer
   upgrade path. The CI gate is the backstop; the pre-commit hook is the actual
   prevention. (Note: CI diff-mode redaction already runs only on PR — same
   after-the-fact limitation called out in OPP-0036.)
4. **Marker semantics for untracked files.** The blocking check must fire when a
   marked file becomes *tracked* (staged/committed), not merely present untracked.
   The interesting case — an untracked file with the marker — is the desired
   steady state, not a violation. Define the trigger as "marker present AND file
   in `git ls-files`."
5. **Scope of the marker.** Bias: a per-file frontmatter key (`do-not-publish:
   true`) keeps the intent attached to the artifact and travels with it. A
   sibling `.do-not-publish` file or a `.do-not-publish-paths` glob list are
   alternatives — decide at PRD time. The digital-twin overlay's "public/private
   publication boundaries" concept is adjacent and may share the primitive.
6. **Harness-vs-consumer applicability.** The parked-specs risk is most acute on
   *this* repo (the platform itself), but consumers running multi-agent workspaces
   inherit it. Bias: ship as a kernel-level / opt-in validator, not a domain
   module, so any harnessed project can turn it on.

## Disposition

**Proposed (2026-06-17).** Design-only; no PRD this cycle (per § 9, the promoting
PR carries the PRD). Filed as the hardening follow-up to OPP-0036 after the
redaction-coverage gap was re-confirmed live during the 2026-06-17 GitBook /
documentation pass (the parked DT seed brief was, again, the thing the TOC sync
had to be careful not to publish). Recommended next step: a brainstorm → PRD that
ratifies a thin wedge — the file-level `do-not-publish` blocking check first (it
needs no name corpus), with the configurable-denylist scan-scope extension as the
second mechanism.

**Accepted (2026-06-24).** [PRD-0026](../requirements/PRD-0026-publication-boundary-marker.md)
ratifies mechanism 1 as an **always-on, kernel-level** safety validator
(`validate-publication-boundary.sh`) that fails CI / pre-commit if any git-tracked
file declares a `do-not-publish` marker — the check needs no name corpus and
distinguishes the lone untracked unpublishable brief from the **ten already-tracked,
legitimately-published** specs that share `docs/superpowers/specs/` (which is why a
directory glob is wrong and a per-file intent marker is right). Mechanism 2 (the
configurable content-denylist scan-scope extension) is carried forward as a named
**phase-2 follow-up** under this OPP — its gitignored-denylist source-of-truth
design (Open Question 1) is the hard part and is not on the critical path to
closing the live leak. Design-only per § 9; the implementing PR ships the
validator + wiring + the marker on the parked brief.

## Related

- Parent: [OPP-0036](OPP-0036-validate-knowledge-redaction.md) —
  `validate-knowledge-redaction.sh` + CODEOWNERS (the primitive this hardens).
- Roadmap anchor: [ADR-0017](../adr/ADR-0017-safety-hardening-roadmap.md) (Safety
  Hardening Roadmap) — this extends the §8/§9 leakage-pathway closures.
- Declare-then-enforce precedent: OPP-0034 / ADR-0017
  (`validate-sensitive-paths`), the module `companionRules` contract.
- Adjacent concept: the `management/digital-twin` overlay's public/private
  publication-boundary artifacts (ADR-0019 / PRD-0023).
- Multi-agent workspace context: the `project-codex-multiagent` discipline
  (branch-namespace = actor; agents share one git identity, so per-file
  conventions don't scale — machine checks do).
