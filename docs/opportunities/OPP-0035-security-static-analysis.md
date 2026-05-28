<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0035 — Security Static Analysis Module (`management/security-static-analysis`)

**Status:** exploring
**Owner:** @unclenate
**Created:** 2026-05-27
**Last Updated:** 2026-05-28
**Confidence:** medium

**Promotion candidate:** [PRD-0016](../requirements/PRD-0016-security-static-analysis-module.md) — design pass (2026-05-28).

---

## Thesis

Add an optional `management/security-static-analysis` overlay module
that lists required SAST configs by stack (Semgrep for polyglot, CodeQL
for GH-native, Bandit for Python, gosec for Go, etc.) and ships
`validate-sast-coverage.sh` — a companion-rule-bearing validator that
asserts "any new source file under guarded paths triggers a 'SAST report
attached' satisfier."

**This addresses the single largest mission-relative gap in the entire
safety sweep.** Per safety-security-sweep §11: the harness governs AI
agents that generate code, but there is **zero machinery in the harness
that inspects agent-generated code in the consumer project** for
security smells. The harness ships governance scaffolding around an
AI agent's *changes*, but no structural check on whether the *code
produced* contains underhanded patterns — off-by-one bugs, TOCTOU races,
integer truncation, sign-flip in security predicates.

Anchored under [ADR-0017](../adr/ADR-0017-safety-hardening-roadmap.md)
Wave 5.4. **Filed explicitly as a child OPP under
[OPP-0020](OPP-0020-evaluation-tooling-in-harness-toolchain.md)**
(Evaluation & Safety Tooling in Harness Toolchain — Tula) per
execution-roadmap §8: OPP-0020 is the maintainer's named umbrella for
eval/safety tooling, and SAST coverage is a natural child of that work
rather than a parallel track.

Opt-in design: existing consumers are unaffected; new adopters get the
option. Same opt-in shape as `management/eval-gated-testing`
(OPP-0019 / PRD-0009).

## Origin / Evidence

- **safety-security-sweep.md § 11** ("Underhanded-Code Risk in Governed
  Software"): *"This is the largest mission-relative gap in the entire
  safety sweep. The harness governs AI agents that generate code. There
  is zero machinery in the harness that inspects agent-generated code
  in the consumer project for security smells."* Recommendation 1 of
  §11 specifies the module shape directly.
- **safety-security-sweep.md § 16 ("If you do only five things")** lists
  this as priority #4: *"Ship the SAST recommendation module
  (`management/security-static-analysis`). Addresses §11 — the largest
  mission-relative gap."*
- **Existing modules cite SAST descriptively, not structurally.**
  `harness-mcp/SKILL.md` cites MCP Security Best Practices but only as
  advice — no validator asserts the advice was followed.
  `harness-agentic-interfaces/SKILL.md` mentions "sandbox-permitted-
  but-dangerous" patterns once, descriptively. No skill instructs
  agents to flag their own potentially-risky outputs. The risk-register
  template lists SAST as a common control but does not require it.
  No "agent reviewing agent" mechanism exists; human review is the
  sole defense for code-output quality.
- **Parent OPP-0020** ("Evaluation & Safety Tooling in Harness Toolchain
  — Tula") is the maintainer's named eval/safety tooling umbrella.
  Sweep §16's recommendation explicitly anchors SAST coverage under
  OPP-0020: *"the existing OPP-0020 (eval/safety tooling) is the
  natural parent. This sub-item can be filed as an explicit child OPP
  under 0020."* This OPP adopts that framing.
- **`management/eval-gated-testing` (OPP-0019 / PRD-0009)** is the
  precedent for opt-in management overlay modules with companion-rule-
  bearing validators. This OPP follows the same shape: required
  artifacts when activated, validator that enforces the contract, opt-in
  for consumers that aren't ready.
- **Tula's `agent-backup.sh secret-scan gate`** is a *project-specific*
  shape of the SAST pattern at the smaller "secrets in commits"
  granularity. This OPP generalizes the pattern from secrets to all
  static-analysis findings, with stack-appropriate tool selection.

## Why Now

- **Sweep §16's #4 priority is unaddressed.** The other four priorities
  have closure paths in flight: #1 (list-completeness) shipped Wave 1;
  #2 (PRD-0006) drafted; #3 (validate-skill-content) is OPP-0033; #5
  (repo hardening verification) is a maintainer-terminal task. Without
  #4 filed, the safety hardening roadmap has a visible gap.
- **SAST tool maturity has consolidated.** Semgrep, CodeQL, Bandit,
  gosec, ESLint security plugins, Snyk Code — the per-stack SAST
  ecosystem is stable enough that the module can recommend specific
  tools without significant risk of churn over the next 12 months.
- **The "agent generates code that ships to production" pattern is
  becoming normal.** Frameworks like auto-harness exist precisely
  because agent-generated code is becoming pervasive. The framework's
  catalog must include a primitive for "review the agent's code, not
  just the agent's process."

## Risks / Open Questions

1. **Tool selection per stack is non-trivial.** Bias: v1 lists 2–3
   tools per stack with explicit "pick one" guidance; consumer projects
   activate the tool that matches their existing CI investment. Avoid
   the failure mode of "module recommends 8 tools and consumer picks
   none."
2. **Required artifacts: SAST config file? SAST report? Both?** Bias:
   v1 requires (a) `docs/security/sast-coverage.md` declaring what
   tool is configured and what paths it scans, (b) a CI-job-attached
   SAST run that fails on findings above a threshold. The artifact
   names what's enforced; the CI run does the enforcement. Mirror of
   how `management/eval-gated-testing` requires `eval-strategy.md`
   and an eval-run-on-CI.
3. **Companion rule scope: which paths trigger "SAST report attached"?**
   Bias: v1 starts narrow — `src/`, `lib/`, `app/`, the consumer's
   primary source root. Configurable per-project via the artifact. v2
   can broaden to all code paths or per-stack-conventional locations.
4. **What about secrets scanning?** Bias: out of scope for v1 —
   secrets scanning is GitHub repo-level (already enabled per L3-04
   resolution from PR #74's audit-folder followup) and is structurally
   different from SAST. v1 of this module focuses on SAST findings
   specifically; secrets is a parallel concern.
5. **Cross-cutting agent-self-review reviewGate.** Sweep §11
   Recommendation 2 names an "Agent Self-Review" reviewGate to
   `agents/base/module.yaml` requiring agents to enumerate non-obvious
   risk surfaces in their PR description. Bias: file as a separate OPP
   under OPP-0031 (defense-in-depth) — distinct surface from SAST
   coverage. This OPP focuses on the static-analysis layer; agent self-
   review is the human/agent-collaborative layer.
6. **Largest item in Wave 5.** Per execution-roadmap §8: 1–2 weeks of
   work. v1 PRD-pass should explicitly carve scope reduction options if
   timeboxing pressure surfaces (e.g., ship the artifact-and-companion-
   rule without the CI integration in a "v1a" and add CI in "v1b").
