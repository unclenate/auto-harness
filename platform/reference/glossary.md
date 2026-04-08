# Glossary

Shared terminology for the Development Harness platform. Definitions here are normative —
if a README or workflow guide uses a term differently, this glossary takes precedence.

---

## Core Concepts

### Development Harness

The modular governance framework itself — the `platform/` directory tree, its modules,
validators, templates, and workflows. When documentation says "the harness," it means
this framework.

A **harnessed project** (or **consumer project**) is a software project that uses the
harness by declaring a `harness.manifest.yaml` at its root. The harness is the tool;
the consumer project is the thing being governed.

### harness.manifest.yaml

The declaration file at a project's root. It names the project, sets its maturity and
criticality, and lists which modules are active. Validators read this file to determine
what governance applies.

### Composition

A starter `harness.manifest.yaml` for a common project type, stored under
`platform/compositions/`. You copy one to your project root and adjust it — it is a
starting point, not a runtime dependency.

### Module

A directory containing a `module.yaml` file that declares a governance contract: required
artifacts, sensitive paths, companion rules, validators, review gates, agent adapters,
compiled fragments, and recommended skills. Modules live under `platform/core/`,
`platform/profiles/`, or `platform/agents/` depending on their family.

### Module Family

The classification that determines where a module lives and what kind of governance it
provides. Eight families exist: **core**, **stacks**, **architectures**, **data**,
**delivery**, **management**, **domains**, **agents**. See
[Module Types](../core/registry/module-types.md) for definitions.

### module.yaml

The machine-readable contract inside every module directory. It declares the module's
identity, dependencies, conflicts, required artifacts, companion rules, and everything
else validators need to enforce the governance contract. The companion `README.md` in
the same directory provides human-readable documentation for the same module.

---

## Governance Mechanisms

### Validator

A shell script (with inline Ruby) that checks one dimension of the governance contract.
Six validators exist: manifest schema, module graph, required artifacts, placeholders,
agent pack, and companion rules. Each exits 0 on pass, 1 on failure. Validators run
locally and in CI.

### Companion Rule

A rule declared in `module.yaml` that links file changes together: when a file matching
a `triggerPaths` pattern changes in a PR, at least one file matching a `requiredAny`
pattern must also be in the diff. This enforces the principle that documentation is part
of the change.

### Compiled Fragment

A platform document listed in a module's `compiledFragments` field. These are loaded into
agent context at every session start — they form the always-on governance floor. Unlike
skills, compiled fragments are mandatory context, not on-demand.

### Skill (Agent Skill)

A document in [Agent Skills](https://agentskills.io/specification) format (`SKILL.md`
with YAML frontmatter) that provides deeper domain guidance. Skills are loaded on demand
when a task matches their domain — they cost ~100 tokens at startup and expand to full
content only when activated. See `platform/skills/` for harness-native skills.

### Review Gate

A condition declared by a module that requires human review before merge. Review gates
are higher-level than companion rules — they govern entire categories of change (e.g.,
"any change to sensitive paths requires a named reviewer").

### Trust Tier

One of six escalation levels (0 through 5) that classify agent actions by risk. Tier 0
is read-only; Tier 5 is production / irreversible. Agents may always operate at a lower
tier; they may never self-elevate. Defined in
[Trust Model](../core/kernel/base/trust-model.md).

---

## Artifact Concepts

### Required Artifact

A file path declared in a module's `requiredArtifacts` array. The
`validate-required-artifacts` validator checks that every required artifact exists on
disk. If it doesn't, the validator fails.

### Template

A skeleton file in `platform/templates/` with `[[PLACEHOLDER]]` tokens. Templates map
to required artifacts — you copy a template to the artifact destination path and fill in
the placeholders. The `validate-placeholders` validator fails if any token remains
unfilled.

### Canonical Record

A durable source of truth. ADRs, PRDs, product requirements, risk registers, incident
records, and other governed artifacts are canonical. Session logs, scratchpads, and
convenience summaries are derivative — useful but not authoritative. See
[Canonical Records](../core/kernel/base/canonical-records.md).

### ADR (Architecture Decision Record)

A numbered record (`ADR-NNNN`) capturing an architectural decision, its context,
alternatives considered, and consequences. Stored at `docs/adr/ADR-NNNN-slug.md`.

### PRD (Product Requirements Document)

A numbered record (`PRD-NNNN`) capturing a product decision, its rationale, user stories,
functional requirements, and alternatives considered — the product counterpart to ADRs.
Stored at `docs/requirements/PRD-NNNN-slug.md`.

---

## Document Tiers

The harness distinguishes three tiers of documentation by authority and purpose:

| Tier | What | Authority | Examples |
|------|------|-----------|----------|
| **Canonical** | Platform guides, kernel docs, module READMEs, module.yaml contracts | Normative — validators enforce these | `doctrine.md`, `trust-model.md`, any `module.yaml` |
| **Illustrative** | Examples, sample projects, composed entrypoints | Informational — shows how to use the canonical layer | `examples/sample-projects/`, `examples/composed-entrypoints/` |
| **Test-only** | Validator test fixtures | Not documentation — exists solely to exercise validators | `validators/test/fixtures/` — never treat as canonical |

---

## Naming Collisions

### SUMMARY.md

Two files named `SUMMARY.md` exist in the repository:

- **Root `SUMMARY.md`** — the GitBook table of contents for the entire harness
  documentation. This is the navigation structure for the published book.
- **`platform/templates/docs/SUMMARY.md`** — a template titled "Project GitBook Stub"
  that consumer projects copy to their own `docs/SUMMARY.md`. It is not part of the
  harness book; it is a starter file for the consumer's book.

`platform/SUMMARY.md` exists as a redirect note pointing to the root.

### README.md (root vs platform)

- **Root `README.md`** — the repository front door and GitBook landing page. Comprehensive
  overview aimed at someone discovering the project for the first time.
- **`platform/README.md`** — the platform overview page. Focused on the `platform/`
  directory structure, operating model, and quick links to key reference pages.
