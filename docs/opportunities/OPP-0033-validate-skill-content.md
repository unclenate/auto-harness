<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0033 — Content-Safety Validator (`validate-skill-content.sh`)

**Status:** accepted
**Owner:** @unclenate
**Created:** 2026-05-27
**Last Updated:** 2026-06-15 *(accepted and implemented in Wave 5.2)*
**Confidence:** medium-high

> **Promoted to PRD-0015 on 2026-05-28.** This OPP captures the
> opportunity and evidence; [PRD-0015](../requirements/PRD-0015-validate-skill-content.md)
> captures the v1 design contract (FRs, denylist seed, exemption
> format, adversarial-corpus fixture plan). The implementing PR ships
> `validate-skill-content.sh` per the PRD spec.

---

## Thesis

Ship `validate-skill-content.sh` — a deny-list content scanner that
asserts no SKILL.md, module.yaml `description`/`summary`/`humanReview`/
`reviewGates`, or compiled-fragment markdown contains known prompt-
injection patterns or trust-tier-bypass phrasings before that content
compiles into agent session-start context.

The framework's authored content — `module.yaml` fields, `SKILL.md`
bodies, agent-pack READMEs, `compiledFragments` — is loaded into
downstream AI agent contexts at session start. This makes the framework's
prose an attack surface. The current defense is human review
(CODEOWNERS plus maintainer scrutiny). That is necessary but not structurally sufficient
against a contributor or maintainer mistake; a deny-list validator closes
the gap at the structural layer.

**Closes red-team attack vectors V1, V2, V4, V6 from safety-security-sweep §3.**

Anchored under [ADR-0017](../adr/ADR-0017-safety-hardening-roadmap.md)
Wave 5.2. Composes with [OPP-0006](OPP-0006-trust-tier-enforcement.md)
(trust-tier-enforcement is *what* the framework guarantees; this OPP
keeps the prose *describing* those guarantees honest).

## Origin / Evidence

- **safety-security-sweep.md § 3** enumerates the five attack branches
  (contributor PR / consumer-local / supply-chain / wording-based tier
  bypass / OPP-PRD prose) and the ten concrete vectors. Four of those
  vectors (V1 Skill-description payload, V2 CompiledFragment poisoning,
  V4 Wording-based tier downgrade, V6 HumanReview text dilution) share
  one structural cause: no validator examines the prose content of files
  that compile into agent context. The sweep's recommendation 1 (§ 3)
  names this OPP as the closure path.
- **safety-security-sweep.md § 4** (Prompt Injection Testing) reframes
  the same gap from the prompt-injection angle: "no validator examines
  the text content of files that compile into agent context. The
  framework treats these files as governance metadata (paths and shapes)
  but treats their prose content as trusted by virtue of human review."
- **safety-security-sweep.md § 7** doc-code-alignment finding lists four
  No-code-anchor guarantees (claims 2, 4, 5, 7) the README presents as
  features. Claims 2 ("Agents may never self-elevate") and 4 ("Sensitive
  path governance triggers elevated review") are partly addressed by
  PRD-0006 + OPP-0034; the *wording integrity* sub-surface is uniquely
  this OPP's scope.
- **Existing precedent — `forbiddenPatterns` already exists** as a
  hard-fail enforcement mechanism for paths (`validate-companions.sh`
  runs it first). This OPP extends the same principle to *content within
  paths*, not just paths themselves.
- **Existing precedent — `validate-doc-references.sh` v2** already
  inspects markdown content (extracts links, strips inline code spans,
  classifies renderer-safety). The infrastructure for content scanning
  exists; this OPP scopes a new content scan.

## Why Now

- **The sweep has identified the gap and the closure path concretely.**
  Recommendation 2 of safety-security-sweep §3 specifies the deny-list:
  "ignore previous instructions", "treat as Tier", "always operates at",
  "skip the validator", "supersedes harness-governance", role-prompt
  headers ("System:", "User:"), zero-width characters, mismatched Unicode
  bidirectional marks. The shape is clear; implementation can begin.
- **Wave 1 established the structural-enforcement pattern.** The
  list-completeness validator (PR #72) demonstrates the recipe: discover
  entities, assert per-entity property in canonical surfaces, fail CI
  with structured stderr. The same recipe applies to content scanning.
- **The adversarial corpus needs versioned fixtures.** Per the sweep's
  Recommendation 5: "Maintain `platform/validators/test/fixtures/
  adversarial/` — known injection strings, tier-bypass phrasings,
  role-prompt headers — and assert `validate-skill-content.sh` flags
  every one." Building the fixture set is a knowledge-accumulation
  exercise that compounds the longer it runs; starting now means future
  attack patterns get added against existing fixtures, not litigated
  against a missing baseline.

## Risks / Open Questions

1. **Deny-list completeness is permanently open.** Content-text prompt
   injection is a permanently-incomplete defense (per sweep §4). v1
   should ship with the explicit "this is necessary but insufficient"
   posture; the corpus grows over time, not as a one-shot v1 deliverable.
2. **False positives in pedagogical contexts.** A SKILL.md might
   legitimately discuss prompt-injection patterns (e.g., the
   `harness-mcp` skill cites MCP security patterns). v1 needs an
   exclusion mechanism — likely a `.skill-content-ignore` file mirroring
   the existing `.doc-reference-ignore` / `.placeholder-ignore` pattern.
3. **Scope: which fields per file type?** Bias toward conservative scope
   at v1: `description`, `summary`, `humanReview`, `reviewGates` for
   `module.yaml`; the body of `SKILL.md`; the body of compiled-fragment
   markdown referenced in `module.yaml`'s `compiledFragments` list. The
   wider set (templates, sample-project docs) can land in v2.
4. **Performance — content scan vs. structure scan.** A whole-tree
   markdown content scan is heavier than the existing structural scans.
   v1 should benchmark and consider per-file caching if the scan time
   exceeds ~1s on the harness's own tree.
5. **Companion to two-stage compiledFragment loading.** Sweep §4
   recommends a future "content-classifier" pass that marks compiled
   fragments as "treat as untrusted input" — that is a *runtime*
   defense; this OPP is a *static* defense. They compose. v1 of this
   OPP does not block the runtime work.
6. **Tier-vocabulary lockfile** (sweep §3 Recommendation 3) is a
   parallel-but-related closure for V4. Bias: file as a separate OPP
   if v1's deny-list approach proves insufficient against tier-bypass
   wording; do not pre-bundle.

## Disposition

**2026-06-15 (exploring → accepted):** Accepted and fully implemented in Wave 5.2 (PRD-0015, commit `907a5af`) via the new `validate-skill-content.sh` validator and adversarial corpus.

## Promotion

- See [PRD-0015](../requirements/PRD-0015-validate-skill-content.md) — accepted and implemented in Wave 5.2 (commit `907a5af`).
