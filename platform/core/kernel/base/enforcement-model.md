<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Enforcement Model

The modular harness keeps five categories of enforcement distinct. Each
category does a *different kind of work* — and collapsing them into one
catch-all policy file destroys the differentiation that makes them
load-bearing.

The separation is deliberate. A team that treats doctrine, templates,
generated artifacts, validators, review gates, and runtime controls as
interchangeable ends up with policies that don't work because they don't
distinguish *what the team must think about* (doctrine) from *what a
script can check* (validator) from *what only a human can judge* (review
gate). The harness names the categories so the team can match each
governance concern to the right mechanism.

## The Five Categories

### Doctrine

**Human-readable operating rules that define intent and constraints.**

Doctrine answers *"what does this team value, and why?"* Examples: the
ownership principle, the trust-tier model, the rule that documentation
is part of the change. Doctrine is the layer above any specific
enforcement — it tells humans what to *do*, and the other categories
make sure they did it.

Doctrine fails when it's left as the *only* enforcement. A team that
believes "ownership is explicit" without any mechanism that asks
"who owns this?" at review time will drift back to unowned files
within a quarter.

### Template

**Reusable artifact skeletons with expected structure.**

Templates capture *the right shape* of an artifact — what sections an
ADR has, what fields a PRD requires, what placeholders need filling.
Templates live in `platform/templates/`. They are *not* themselves
enforcement; they are *the inputs* to enforcement (the validators
check that copies match the template's placeholder contract).

The template/validator pairing is the cheap-satisfier pattern: a
template makes the right thing easy; the validator makes the wrong
thing detectable.

### Generated or Instantiated Artifact

**Project-facing files required by active modules.**

These are the artifacts that consumers ship: `HARNESS.md`,
`AGENTS.md`, `docs/architecture/overview.md`, ADRs, PRDs, risk
registers. Each module declares which artifacts it requires; the
project produces them. The artifact is the *evidence* that the
governance contract was satisfied — not the contract itself.

This category exists separately from templates because the *instance*
in a specific project is different from the *skeleton*. The skeleton
is normative across projects; the instance is normative for one
project's audit history.

### Validator

**Executable checks that can verify presence, consistency, or
path-based policy.**

Validators do *mechanical work*. They check whether files exist
(`validate-required-artifacts`), whether tokens are resolved
(`validate-placeholders`), whether companion rules fired
(`validate-companions`), whether catalog counts match reality
(`validate-catalog-counts`), and so on. The harness ships eight
validators today; each does one thing well.

Validators fail when used for the wrong kind of check. A validator
cannot judge "is this ADR substantive?" or "does this risk register
reflect actual risks?" — those questions require human judgment.
Validators check *form*; humans judge *substance*.

### Review Gate

**Human checkpoints that validate semantics, quality, and risk beyond
machine checks.**

Review gates capture *what only a human can judge*. The
review-gate field in `module.yaml` declares conditions: "any change
to authentication code requires a named security reviewer," "any
production deployment requires second-human sign-off." The reviewer
applies judgment that no script can encode.

The review gate is where the harness explicitly *refuses* to
automate. Automating these gates would mean encoding the team's
judgment into rules — and the moment you can encode the judgment,
it's no longer a review gate, it's a validator. Real review gates
are the cases that resist that compression.

### Runtime or Operational Control

**Tool permissions, CODEOWNERS, CI jobs, deployment gates, hooks, or
secret-management controls.**

These are the *execution-time* enforcement: who can merge to main
(CODEOWNERS, branch protection), which CI workflows run when, which
deployment paths require approvals, where secrets come from. They
live outside the harness's module system but compose with it — the
harness recommends specific controls (e.g., the CI template
`templates/ci/github-actions.yml`), and the consumer wires them.

Operational controls fail when treated as the only enforcement. A
team that relies solely on CODEOWNERS without companion rules ends up
with reviews that fire on every PR regardless of substance, which
trains reviewers to skim — defeating the purpose of the review gate.

## Why the Categories Stay Separate

The pattern under the separation: **each category handles a kind of
work the others cannot do.**

- Doctrine handles *intent*. The team has to want the thing.
- Templates handle *shape*. The artifact has to be the right kind of
  thing.
- Generated artifacts handle *instances*. The specific thing must
  exist in the project.
- Validators handle *mechanical correctness*. Form-checkable rules
  are checked mechanically.
- Review gates handle *judgment*. Substance-checkable rules are
  judged by named humans.
- Operational controls handle *execution-time enforcement*. The
  merge, deploy, secret access either happens or doesn't.

Collapsing them puts the wrong category in charge of the wrong work.
A "policy file" that conflates doctrine with validator config ends up
with: doctrine that no script reads, validator config humans can't
understand, and a vague middle ground that doesn't enforce anything.
The harness's discipline is to keep the separation visible — so each
governance concern can find the right home.

## Related

- [Doctrine](doctrine.md) — the intent layer that the other
  categories operationalize
- [Audit Model](audit-model.md) — what counts as audit evidence
  produced by these enforcement categories
- [Trust Model](trust-model.md) — the trust-tier model is doctrine
  (the rules) + (eventually, per PRD-0006) a validator (the check)
- [Cheap Satisfiers for Routine Governance](../../../../docs/adr/ADR-0010-cheap-satisfiers-for-routine-governance.md)
  — the template/validator pairing pattern as a design discipline
