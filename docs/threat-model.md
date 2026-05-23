<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Threat Model — auto-harness

Companion document to [`SECURITY.md`](../SECURITY.md). `SECURITY.md`
covers *how to report* vulnerabilities. This document covers *what
auto-harness is designed to protect against, what it isn't, and how*.

---

## Scope and Asset Inventory

Auto-harness is a **governance framework**, not runtime infrastructure.
It influences security primarily by shaping the development process
of consumer projects. Its own attack surface is small:

| Asset | Why it matters |
|-------|----------------|
| `harness.manifest.yaml` parser | A malformed manifest could in principle exploit the YAML reader (currently Ruby's stdlib YAML — broadly safe) |
| `module.yaml` files (in-tree + consumer-side) | These declare regex patterns that validators compile and run; a malicious regex could ReDoS the validator |
| Validator scripts (bash) | Run on developer machines and in CI — malicious code here propagates to every consumer |
| Bootstrap scripts (`install.sh`, `set-consumer-headers.sh`) | Run on consumer machines during onboarding — same concern |
| Templates (`platform/templates/**`) | Consumed via `cp`; any malicious content gets copied into consumer projects |
| Skills (`platform/skills/**`) | Loaded by AI clients; influences agent behavior in consumer projects |
| Agent packs (`platform/agents/**`) | Same as skills, plus they modify consumer `.claude/`, `.cursor/`, etc. config |
| GitHub Actions workflows (`.github/workflows/`) | Run on every PR; a workflow injection vulnerability could leak repo secrets |

The harness explicitly does *not* protect:

- The consumer's runtime infrastructure (the harness doesn't run there)
- The consumer's CI secrets (the harness shapes the workflow file but doesn't store secrets)
- AI agents' upstream LLM safety (the harness configures agents; it doesn't run them)
- The consumer's network, dependencies, or supply chain (out of scope —
  these are the consumer's concerns)

---

## Adversary Models

### A1 — Curious open-source consumer (LOW intent, LOW capability)

A developer evaluating auto-harness for adoption. They will: read the
code, run validators against their own manifest, possibly modify
templates locally to fit their project.

**What auto-harness must do:** be safe to read and run on a developer
laptop. No code execution beyond what's clearly invited (`bash
install.sh`, etc.). No network calls from validators.

**Status:** strong. All validators are pure-shell + Ruby with no
network access. `install.sh` and bootstrap helpers only touch the
consumer's own filesystem.

### A2 — Malicious contributor (LOW intent, MEDIUM capability)

A would-be contributor opens a PR with subtly malicious content —
e.g., a validator script that exfiltrates env vars, a template with
embedded shell escape sequences, a skill that instructs agents to
deploy backdoor code.

**What auto-harness must do:** require human review of all
contributions; surface suspicious changes; have a small enough trust
surface that human review can catch the malicious change.

**Mitigations in place:**

- Repository has `CODEOWNERS` enforcing maintainer review
- Branch protection on `main` requires PR + approval
- Shellcheck CI catches some obvious shell injection patterns
- Companion rules catch unexpected file modifications (e.g., editing
  a sensitive path without the required satisfier)
- Dependabot + secret scanning catch known-bad dependencies and
  leaked credentials

**Gaps:** no signing of contributors; no formal threat-modeling
review for new modules; no provenance attestation on releases (planned
under the release/versioning work).

### A3 — Compromised maintainer (HIGH intent, HIGH capability)

The most dangerous adversary class for any open-source project. A
maintainer (or someone with maintainer credentials) ships a malicious
change. Defenses are partial by definition: maintainers approve their
own commits in single-maintainer projects.

**What auto-harness can do:** publish reproducible release artifacts,
practice transparent changelogs, encourage adopters to pin to specific
tags and review diffs between tags they adopt.

**Mitigations in place:**

- All releases will be git-tagged (Wave 3 work)
- CHANGELOG.md will document every release's contents
- The PR template + companion-rule machinery + audit trail in
  `docs/project/change-log.md` make silent changes harder to land
  without a paper trail
- The harness governs its own development with the same machinery it
  exposes to consumers — self-dogfooding reduces the "one rule for me,
  another for thee" pattern

**Acknowledged gaps:**

- Currently a single-maintainer project. Until @unclenate has a
  co-maintainer, compromise of the maintainer's GitHub credentials is
  a single point of failure.
- No reproducible builds (the project is text-based, so this is
  largely moot — a reader can audit the tagged commit directly).
- No SLSA-style provenance attestation.

### A4 — Adversarial input through manifest/regex

A consumer or attacker provides a `module.yaml` with a pathological
regex that causes the validator to hang (ReDoS), or a manifest with
malformed YAML that crashes the parser in a way that exposes other
problems.

**Mitigations in place:**

- `Regexp.timeout = 1.0` set unconditionally in
  `platform/validators/lib/harness_registry.rb` (defends against ReDoS
  in `companionRules.{triggerPaths,requiredAny,forbiddenPatterns}`
  and `.doc-reference-ignore` patterns)
- YAML parsing uses Ruby's safe loader (no arbitrary object
  instantiation)
- Validators run with `set -euo pipefail` so crashes don't cascade
  silently

### A5 — Compromised AI agent

An AI agent (Claude Code, Cursor, etc.) is configured via the
harness's skills and agent packs. If an agent is compromised or
prompt-injected, it might attempt actions outside its trust tier.

**Mitigations in place:**

- The trust tier doctrine documents what each tier may do (limited)
- The PR template explicitly requires human checkbox for Tier 4 / 5
  operations
- Companion rules at the file-system level catch many shapes of
  unauthorized change (e.g., modifying a sensitive path without the
  required satisfier)

**Acknowledged gaps (audit finding 2026-05-23):**

- **No machine-checked trust-tier enforcement.** The tiers are
  doctrine without machinery. An agent that *chooses* to perform a
  Tier 4 action is caught only by the maintainer reviewing the PR.
  Closing this gap is highest-priority Wave 3 work.
- Skills and agent packs are loaded by clients; the harness can't
  guarantee the client honors them.

---

## Specific Attack Surfaces

### S1 — Workflow injection via GitHub Actions

CI workflows run with repo-level permissions. Untrusted input
interpolated into a `run:` block can execute arbitrary code. Auto-
harness's `.github/workflows/harness.yml` uses no
`github.event.issue.*` or other adversary-controllable inputs in
`run:` commands.

**Status:** safe by construction; no untrusted interpolation surface.

### S2 — Template content injection

If a consumer copies a malicious template into their project, the
template content lands verbatim. The template SVG covers (PR #39)
and structured Markdown templates are text-only with no executable
content.

**Status:** safe by inspection. Future templates that include shell
recipes or executable content should be reviewed against this
surface.

### S3 — Validator script injection

If a malicious validator landed on `main`, it would run against every
consumer's manifest during their CI runs. Shellcheck CI catches many
shapes of injection. Code review by maintainers is the primary
defense.

**Status:** defended by review + shellcheck; review-quality is the
bottleneck. New validator additions should be scrutinized for shell
construction patterns.

### S4 — Submodule attack on consumers

Consumers mounting auto-harness as a submodule will pull whatever the
upstream `main` (or pinned tag) points at. A malicious force-push to
a tag they're pinned to would deliver malicious code.

**Status:** defended by GitHub's tag immutability defaults; consumers
should pin to tags (not branches) for production use.

---

## Mitigations Not Yet Deployed

Future-work items relevant to threat coverage:

- **Trust-tier enforcement validator** (highest priority; OPP candidate)
- **Reproducible / signed releases** with attestation
- **Co-maintainer model** to remove single-point-of-failure
- **Dependency-pinning policy** documentation for consumer projects
- **Skill content scanning** to flag agent-prompt-injection patterns
  in skills shipped by the harness

These are tracked in [`docs/opportunities/candidates.md`](opportunities/candidates.md)
as they get filed.

---

## When to Update This Document

- After every security disclosure handled per `SECURITY.md`
- When a new attack surface is introduced (new validator, new agent
  pack, new external integration)
- When a mitigation in the "Not Yet Deployed" list ships
- After any postmortem that surfaces an unconsidered adversary or
  attack
- At least quarterly, even if no triggering event occurred

The threat-model update belongs in the same PR as the underlying
change. A change that introduces a new attack surface without
updating this document is missing its companion artifact.

---

## References

- [`SECURITY.md`](../SECURITY.md) — disclosure process and supported versions
- [`platform/validators/lib/harness_registry.rb`](../platform/validators/lib/harness_registry.rb) — `Regexp.timeout` ReDoS defense site
- [`platform/core/kernel/base/trust-model.md`](../platform/core/kernel/base/trust-model.md) — trust tier doctrine
- [`docs/operating-principles.md`](operating-principles.md) — including § 5 (Self-Governance) and § 6 (AI-Assisted Development)
- [`platform/workflow/incident-response.md`](../platform/workflow/incident-response.md) — operational incident workflow (distinct from security disclosure)
