<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Domain Overlay: GitBook

This overlay activates when a project publishes its documentation through GitBook — either
GitBook's hosted service (gitbook.com) or a self-hosted instance. It ensures the table of
contents stays current, chapter structure reflects how the team navigates docs, and the
GitBook configuration is treated as a governance artifact rather than a throwaway config file.

The overlay exists because human and AI team members navigate documentation differently.
Humans rely on tables of contents, chapter groupings, and indexes. AI agents work from
flat file paths and compiled fragments. Both modes are legitimate. This overlay facilitates
the human mode without breaking the AI mode.

---

## What This Overlay Requires

**`docs/SUMMARY.md`**

The master table of contents for the project's documentation. Every page that should be
reachable by human readers must appear here. GitBook uses this file to generate navigation,
search indexes, and the sidebar.

The SUMMARY.md is a governance artifact — not an auto-generated file. It represents an
editorial decision about how the documentation is organized and what hierarchy makes sense
for *this project's participants*. It must be maintained alongside the docs themselves.

**Optional: `.gitbook.yaml`**

GitBook configuration. The minimal useful configuration points to the docs root:

```yaml
root: docs/

structure:
  readme: README.md
  summary: SUMMARY.md
```

If omitted, GitBook defaults to looking for `README.md` and `SUMMARY.md` at the repository
root. Use `.gitbook.yaml` when docs live in a subdirectory (the standard harness pattern).

**Optional: `docs/README.md`**

The landing page for the documentation. GitBook renders this as the first page visitors see.
If omitted, GitBook uses the repository root `README.md`.

---

## SUMMARY.md Format

GitBook's SUMMARY.md uses a simple nested list format:

```markdown
# Project Documentation

## Getting Started

* [Introduction](README.md)
* [Setup Guide](setup.md)

## Product

* [Problem Statement](product/problem-statement.md)
* [Requirements](product/requirements.md)
  * [API Requirements](product/requirements/api.md)
* [Personas](product/personas.md)

## Architecture

* [Overview](architecture/overview.md)
* [ADRs](adr/README.md)
  * [ADR-0001: Stack Choice](adr/ADR-0001-stack-choice.md)
```

**Key rules:**
- The `#` header is the book title — appears in the GitBook sidebar header
- `##` headers are section groups — appear as collapsible sections in the sidebar
- `*` items are pages — the link text becomes the page title in navigation
- Nested `*` items create chapter hierarchies
- Every `.md` file you want reachable must have an entry

---

## Organizing Chapters for Human Navigation

The harness generates a specific set of canonical artifacts across discovery, product,
architecture, and ops directories. GitBook's sidebar should reflect how participants
actually navigate these — not just mirror the directory structure.

**Recommended chapter groupings for a harness project:**

| Chapter | Artifacts |
|---------|----------|
| Getting Started | README, operating principles |
| Discovery | intake-questionnaire, mvp-scope, starting-assets |
| Product | problem-statement, personas, requirements, release-intent |
| Architecture | overview, ADRs |
| Database | migration-readiness, migration-records |
| Security | risk-register |
| Operations | environment-inventory, release-checklist, rollback-checklist |
| Project | scope-plan, milestones, change-log, dependency-log |
| Program *(if active)* | workstream-map, stakeholder-report, governance-cadence |

This grouping separates concerns by audience: product stakeholders read the Discovery and
Product chapters; engineers read Architecture and Database; ops teams read Operations.

**Avoid mirroring the filesystem directly.** A SUMMARY.md that reads:

```markdown
* [docs/product/requirements.md](docs/product/requirements.md)
```

is worse than useless — the path is the title and the hierarchy communicates nothing.

---

## Keeping SUMMARY.md Current

SUMMARY.md drifts when:
- A new doc page is created but not added to SUMMARY.md
- A doc page is renamed but SUMMARY.md still points to the old path
- A section is restructured but SUMMARY.md retains the old hierarchy

The companion rule enforces that changes to SUMMARY.md are recorded in the change-log or
an ADR. But it does not catch the reverse — a new doc page added without updating SUMMARY.md.

That gap is closed by the review gate: human reviewers must verify SUMMARY.md is current
before merging any PR that adds or renames documentation.

**Agent guidance:** Agents that create new documentation files must also update SUMMARY.md
in the same commit. Adding a doc page without adding its SUMMARY.md entry is an incomplete
change and should be flagged as such.

---

## GitBook and AI Agents

This overlay supports the same docs being consumed by both humans (via GitBook navigation)
and AI agents (via compiled fragments and flat file reads). The two modes do not conflict.

**Humans navigate via:**
- GitBook sidebar (SUMMARY.md-driven)
- Search (GitBook-indexed)
- Chapter groupings
- Cross-page links

**Agents navigate via:**
- `compiledFragments` declared in module.yaml
- Direct file path reads from `AGENTS.md` reading list
- Flat doc structure — no sidebar needed

The SUMMARY.md is a human navigation artifact. Agents do not need to read it to operate
correctly — they use compiled fragments. But agents must maintain it when creating docs,
because human team members depend on it.

---

## Connecting to the Platform

The harness platform itself uses this same GitBook structure. The platform's SUMMARY.md at
`platform/SUMMARY.md` and `.gitbook.yaml` at `platform/.gitbook.yaml` are the reference
implementation of this overlay applied to the platform's own documentation.

Use the template at `platform/templates/docs/SUMMARY.md` as a starting point for your
project's table of contents.

---

## Reference

| Resource | Path |
|----------|------|
| Platform SUMMARY.md (reference) | `platform/SUMMARY.md` |
| Platform .gitbook.yaml (reference) | `platform/.gitbook.yaml` |
| Project SUMMARY.md template | `platform/templates/docs/SUMMARY.md` |
| GitBook official docs | https://docs.gitbook.com |
