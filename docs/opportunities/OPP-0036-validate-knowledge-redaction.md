<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0036 — Knowledge-Redaction Validator + CODEOWNERS on `docs/knowledge/`

**Status:** proposed
**Owner:** @unclenate
**Created:** 2026-05-27
**Last Updated:** 2026-05-27
**Confidence:** medium-high

---

## Thesis

Ship `validate-knowledge-redaction.sh` — a regex denylist scanner that
warns (and optionally blocks) when new lines in `docs/knowledge/
shared-observations.md` or `docs/operating-principles.md` match a
configurable list of consumer-name patterns. Pair with a CODEOWNERS
rule that routes reviews of `docs/knowledge/` and
`docs/operating-principles.md` separately through the maintainer.

Together, these address the **cross-pollination / data-contamination
risk** (safety-security-sweep §8) and the **reverse-direction prompt
leakage pathways 1–4** (safety-security-sweep §9): consumer-name
leakage into framework doctrine, distillation reflux of consumer-
specific observations into upstream-tracked knowledge files, and the
absence of a redaction review gate before merge.

The validator is small (~50 lines), the CODEOWNERS rule is one line.
Together they convert two structurally-built-in upstream-leakage
pathways from "human review only" to "machine-flagged + maintainer-
gated."

Anchored under [ADR-0017](../adr/ADR-0017-safety-hardening-roadmap.md)
Wave 5.5. Composes with the §8 healthcare-bias guardrail already
documented in `shared-observations.md:1056-1098` (extends the per-domain
remedy to structural enforcement).

## Origin / Evidence

- **safety-security-sweep.md § 8** ("Cross-Pollination / Data
  Contamination Risk"): the audit found Tula referenced 15+ times in
  `shared-observations.md`, named in ADR-0013, PRD-0012, PRD-0009,
  PRD-0010; OPP-0027 quotes verbatim from `unclenate/tula`; OPP-0028
  enumerates Tula/Microsoft vendor-tech specifics. The maintainer owns
  Tula, which softens the third-party-PII concern, but the structural
  pattern remains: *durable framework doctrine is grounded in evidence
  that originated in one specific external consumer project.* If Tula
  were re-licensed, taken private, or restructured, the framework's
  own learning-trace would still cite it. Recommendation 3 of §8
  names this OPP: *"Ship `validate-knowledge-redaction.sh` that scans
  new lines in `shared-observations.md` and `operating-principles.md`
  against a small denylist of consumer-name patterns (configurable in
  `.knowledge-redaction-ignore`) and warns on PR if any match."*
- **safety-security-sweep.md § 9** ("Prompt Leakage & Hijacking —
  Context Window Integrity (Reverse-Direction)"): enumerates four
  upstream-propagation pathways — (1) cycle-end distillation rule
  pushes maintainers to write upstream-visible observations from
  consumer-context work; (2) consumer-PR upstream propagation (no
  CODEOWNERS guard on `docs/knowledge/`); (3) sample-project content
  as upstream template; (4) skill outputs writing upstream. *Severity:
  high. The upstream-propagation path is built in by design.*
  Recommendations 1 and 2 of §9 specify both halves of this OPP
  directly: CODEOWNERS protection + redaction validator.
- **Existing precedent — `forbiddenPatterns` already exists** as a
  hard-fail enforcement mechanism for paths in companion rules. This
  OPP's validator extends the same pattern-matching infrastructure to
  *content* in knowledge files.
- **Existing precedent — `.placeholder-ignore`, `.doc-reference-ignore`,
  `.markdownlint-cli2.jsonc` ignores** all establish the per-validator
  per-project exclusion-file pattern. The new `.knowledge-redaction-
  ignore` follows the same shape.
- **Healthcare-bias guardrail at `shared-observations.md:1056-1098`**
  is evidence the maintainer noticed the symptom and authored a per-
  domain remedy. The remedy is currently per-domain; this OPP
  generalizes it to structural enforcement so future domains (whatever
  the next consumer is) get the same coverage by default.

## Why Now

- **The §8/§9 leakage pattern is currently active.** Each new
  observation or operating-principle entry written from consumer-
  context work re-enacts the pathway. The current cycle-end-
  distillation discipline (PRD-0004) requires maintainers to land
  upstream observations from distillation-worthy work — without a
  redaction gate, every firing of that discipline is a potential
  leakage event.
- **CODEOWNERS coverage is currently coarse-grained** (per safety-
  security-sweep §10 medium finding): `docs/`, `platform/profiles/`,
  `platform/agents/`, `platform/skills/` fall through to the `*`
  default. Adding a `docs/knowledge/` and
  `docs/operating-principles.md` rule is one of the smallest possible
  structural improvements with one of the largest leakage-pathway
  closures.
- **The denylist is bounded and known.** Today's consumer corpus
  (Tula, OpenEMR, YouBase, `bdits/municipal-brain`) is small enough
  to enumerate as v1 denylist entries. Future consumers get added as
  they onboard. The maintenance cost is bounded.
- **Wave 1's `validate-list-completeness.sh` pattern applies.**
  Discover entities (new-lines-since-base in two specific files),
  iterate, scan against denylist, warn-or-fail with structured
  stderr. Same recipe.

## Risks / Open Questions

1. **Warn vs block as default posture.** Bias: v1 ships as WARN
   (validator exits 1 only if a blocking flag is set, otherwise exits
   0 with a warning surface). This avoids the failure mode of
   blocking legitimate doctrine work that needs to reference a
   consumer (e.g., the existing healthcare-bias guardrail itself
   references Tula). v2 can flip to default-block once the corpus of
   "legitimate citations" is well-understood.
2. **Diff-based scanning, not whole-file scanning.** v1 scans only
   the *new lines* added in the PR diff vs base, not the entire file.
   This means the validator doesn't re-flag historical citations
   every PR. Same diff-extraction shape as `validate-companions.sh`
   already uses.
3. **The cycle-end-distillation rule's interaction.** PRD-0004 fires
   the distillation requirement on ADR/OPP/module work; this OPP's
   validator fires the redaction check on new knowledge-file content.
   Both rules can fire on the same PR — they compose orthogonally.
   v1 should NOT auto-strip; surfacing-only.
4. **`.knowledge-redaction-ignore` exemption semantics.** Bias: line-
   regex match exempts the line from flagging. The exemption file
   should be small and explicitly maintained; not a "growing pile of
   ignored consumer mentions." Reviewer pushback on growing exemption
   files is part of the discipline.
5. **CODEOWNERS rule scope.** Bias: cover `docs/knowledge/**` and
   `docs/operating-principles.md` exactly. Do NOT cover
   `docs/adr/`, `docs/requirements/`, `docs/opportunities/` — those
   are already-maintainer-authored surfaces; over-scoping CODEOWNERS
   adds friction without adding signal.
6. **Two-stage commit pattern (sweep §9 Recommendation 3).** Sweep
   recommends restructuring the cycle-end-distillation rule as a
   two-stage commit: write locally first, redact + land upstream as
   follow-up. Bias: out of scope for v1 of this OPP. v1 ships the
   validator + CODEOWNERS as the structural-enforcement layer; the
   discipline-restructure is a parallel operating-principle change
   that can land separately if v1's surfacing reveals it's needed.
