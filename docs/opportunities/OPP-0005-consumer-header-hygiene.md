<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0005 — Consumer Header Hygiene (Stop Template Headers from Propagating to Consumer Files)

**Status:** exploring
**Owner:** @unclenate
**Created:** 2026-05-22
**Last Updated:** 2026-05-22 *(promoted to exploring; PRD-0005 drafted same day)*
**Confidence:** high

---

## Thesis

Auto-harness ships 61 template files and 10+ sample-project files that
carry literal SPDX/copyright headers attributing every file to
`Copyright 2026 Nate DiNiro <UncleNate@gmail.com>` under
`MIT OR Apache-2.0`. When a consumer project (a) copies a template to
scaffold their own ADR/PRD/risk-register/observation, or (b) starts from
a sample-project file as a reference, the resulting file is **born with
the wrong attribution** — the consumer's own architectural decision
ends up legally attributed to UncleNate and dual-licensed MIT/Apache,
regardless of the consumer's actual ownership or licensing intent.

There is no machinery on either side of the boundary that catches this:
no validator detects misattributed headers, no bootstrap helper sets
consumer-specific headers, and templates ship pre-populated rather than
tokenized. The harness has the *capability* to enforce header hygiene
(`add-license-headers.sh` exists for auto-harness's own use;
`validate-placeholders.sh` already gates `[[…]]`-style fills) but
none of it is composed into a consumer-facing contract.

Close the gap by tokenizing template headers so the existing placeholder
validator catches the issue at PR boundary, and ship a small bootstrap
helper that sets consumer headers project-wide on onboarding.

## Origin / Evidence

- **Maintainer observation, 2026-05-22.** *"I noticed that some newly
  authored files in a repo using auto-harness seem to inherit the
  headers from the repo; seems like we need to check and set headers
  and ownership up early if no headers exist, or that we need to
  conform or improve current headers."* Surfaced in conversation after
  the PR #34 merge; immediately verifiable in the codebase.

- **Mechanical confirmation:**
  - `grep -l "UncleNate@gmail.com" platform/templates/ -r | wc -l` → 61
    template files literally carry auto-harness's attribution.
  - Every sample-project file under
    `platform/examples/sample-projects/*/` ships with the same header.
  - The template at `platform/templates/opportunity/opp-template.md`
    (used to scaffold *this very OPP*) ships with
    `Copyright 2026 Nate DiNiro <UncleNate@gmail.com>` as line 2 — a
    consumer who scaffolds their first OPP from this template gets a
    file that legally attributes their own opportunity record to
    UncleNate.

- **Asymmetric tooling.** `platform/bootstrap/add-license-headers.sh`
  exists but operates only on auto-harness's own tree (its purpose
  statement: *"Inserts SPDX/copyright headers into tracked auto-harness
  source files"*). There is no consumer-side equivalent.
  `validate-placeholders.sh` already exists, scans for `[[…]]`
  patterns, and fails CI on unfilled tokens — the enforcement machinery
  for a tokenized-header solution is **already built**, just not
  composed with the templates.

- **Pre-existing internal drift, surfaced during this investigation:**
  `platform/bootstrap/add-license-headers.sh` line 2 attributes itself
  to `nate@bdits.io` (a work email), not `UncleNate@gmail.com` (the
  rule per [[feedback_attribution]] and observed everywhere else in the
  repo). One file out of conformance with the project's own attribution
  policy. Worth fixing in the same pass as any header-hygiene work.

- **Genre fit.** Per [[project_harness_genre]], auto-harness is a
  governance-harness — its job is to gate the consumer-coding loop on
  correctness. Letting templates ship with wrong attribution is exactly
  the kind of silent-correctness-loss that governance-harnesses exist
  to prevent.

## Why Now

- **Legal pressure builds with adoption.** Every consumer that imports
  auto-harness as a submodule today and scaffolds documentation from
  templates is accumulating files with the wrong copyright header. The
  remediation cost scales with how long this goes uncaught.

- **No active firefight.** No specific consumer has filed an issue
  about misattribution yet — but the maintainer noticed the pattern,
  which (per OPP-0004's observation that *"Maintainer 'I thought that
  was already happening' is the highest-signal gap-discovery pattern"*)
  is itself the P0 signal. Filing now closes the gap before the first
  external complaint, which for a legal/attribution issue is
  qualitatively better than reacting after one.

- **Cheap-satisfier discipline (ADR-0010) is available.** The cheapest
  viable v1 (tokenizing the templates) rides existing
  `validate-placeholders.sh` machinery with zero new validator code —
  the same discipline that made PRD-0004's v1 cheap and shippable.

- **Companion to PRD-0004's lesson.** The just-shipped PRD-0004 produced
  a meta-observation in `shared-observations.md`: *"Paired-mechanism
  implementation is a free correctness check on the governance side of
  the pair."* OPP-0005 is the next instance of that dynamic: writing a
  consumer-side header helper will force re-derivation of what
  auto-harness's own `add-license-headers.sh` covers, which has already
  surfaced the `nate@bdits.io` drift in that script — discovered before
  the implementation pass even started.

## Risks / Open Questions

### Risks

- **Tokenizing templates makes them slightly less pedagogical** —
  consumers reading the templates as reference no longer see the
  "finished" header shape, only `Copyright [[`YEAR`]] [[`OWNER_NAME`]]
  <[[`OWNER_EMAIL`]]>`. Mitigated by README guidance and the bootstrap
  helper that fills tokens.

- **`validate-placeholders.sh` already runs against the auto-harness
  repo itself.** If we tokenize the templates without exempting them,
  the validator will fail on the auto-harness repo. Two options: (a)
  exempt `platform/templates/**` from the placeholder scan (already done
  for fixtures? — verify); (b) accept that tokenized templates will
  always need the exemption and codify it explicitly.

- **Sample-projects are a different shape from templates.** Templates
  are *meant to be copied with edits*; sample-projects are *meant to be
  read as reference*. Tokenizing sample-project files (where each file
  is a complete worked example) loses too much pedagogical value. The
  header treatment should differ: templates tokenized, sample-projects
  retain attribution but with a leading comment explaining that
  consumer-derived copies must re-attribute.

- **Existing consumer projects have already inherited bad headers.**
  Fixing the harness templates doesn't fix files already in consumer
  repos. Needs a consumer-facing migration helper or at minimum
  documentation of the bug + manual remediation pattern.

### Open Questions

- **Should SPDX be tokenized too, or only copyright + email?** Arguments
  both ways: tokenizing SPDX lets the consumer choose their own license
  (genuinely correct); keeping SPDX literal means consumers see a
  default and have to actively change it (lower friction; risk of
  silent inheritance).

- **Should the bootstrap helper write a config file** (e.g.,
  `.harness-headers.yaml` with owner/email/year/license) so subsequent
  template scaffolds can be auto-filled, or should each template-copy
  prompt? Config-driven is lower-friction; per-prompt is more
  deliberate.

- **Module placement.** If we ship a `validate-headers.sh`, does it
  belong in `kernel/base` (cross-cutting, like other validators) or in
  a new `management/header-hygiene` module (opt-in, follows the pattern
  of `management/knowledge-capture` and `management/opportunity-
  capture`)? Argues for kernel-base because attribution is universal,
  not a project-flavor choice.

- **Should the v1 explicitly *not* fix consumer-side state**, deferring
  consumer migration to a follow-up (PRD-NNNN: header-bulk-rewrite tool)?
  Scope discipline says yes; user-pain argument says provide at least a
  pointer-to-the-helper in CHANGELOG.

- **Does the existing `validate-placeholders.sh` accept template files
  with tokens, or does the dogfood scan reject them?** Needs
  verification before tokenizing 61 files. If the scan currently passes,
  templates must already be exempt; if not, exemption must be added in
  the same PR.

### Design Options Under Consideration

| Option | Mechanism | Friction | Coverage | New machinery |
|--------|-----------|----------|----------|---------------|
| **A — Tokenize templates** | Replace literal headers with `[[…]]`-style tokens; rely on existing `validate-placeholders.sh` to fail CI on unfilled tokens | Lowest — sed pass + maybe a template-exemption tweak | Templates only | Zero |
| **B — Bootstrap helper for consumers** | Ship `platform/bootstrap/set-consumer-headers.sh` that prompts for owner/email/year/license once at onboarding and rewrites template-derived files project-wide | Medium — new script, one-time consumer flow | Templates + any file the consumer points it at | One small bash helper |
| **C — `management/header-hygiene` module** | Full governance primitive: policy doc, `validate-headers.sh`, companion rules, bootstrap helper | Highest — full module + validator + companion rules | Consumer project end-to-end | New module + new validator |
| **D — Strip headers from templates entirely** | Templates ship with no headers; consumer manages headers via their own equivalent of `add-license-headers.sh` | Low — mechanical deletion | Templates only | Zero — but loses pedagogical value |

**Initial bias (subject to PRD validation): A + B.** Tokenize the
templates so the existing validator gates new files; ship a small
bootstrap helper to fill tokens project-wide; defer (C) to a follow-up
OPP if a second header-related pain point shows up; defer (D) because
templates lose too much by stripping. Fix the
`add-license-headers.sh` `nate@bdits.io` drift in the same PR.

## Disposition

**2026-05-22 (proposed → exploring):** Same-day flip driven by maintainer
priority signal (the legal-correctness shape — consumer attribution
misrouting — is the kind of governance gap auto-harness exists to close,
and remediation cost scales with continued silence). Direction set on
**Option A + B** from the four candidates in the OPP — *tokenize template
headers so the existing `validate-placeholders.sh` machinery gates new
files, plus a small consumer-facing bootstrap helper that fills tokens
project-wide on onboarding*. Option C (full `management/header-hygiene`
module) deferred as premature primitive-creation given that A+B closes
the gap with the primitives already in-tree. Option D (strip headers
entirely) declined — templates lose too much pedagogical value when they
no longer show the finished-header shape. Sample-projects keep their
attribution (they're worked examples, not scaffolding sources) but gain
a leading-comment marker explaining derivative copies must re-attribute.
Internal drift in `platform/bootstrap/add-license-headers.sh` (line 2
attributes to `nate@bdits.io`, not `UncleNate@gmail.com`) folded into the
PRD-spawned implementation work. PRD-0005 drafted same day, paired with
this Disposition update.

## Promotion

- See [PRD-0005](../requirements/PRD-0005-consumer-header-hygiene.md) —
  drafted 2026-05-22; status `Proposed` (acceptance contingent on landing
  the v1 implementation: tokenized templates + bootstrap helper +
  validator composition + `add-license-headers.sh` attribution-drift fix).
