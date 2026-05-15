<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# auto-harness — KPI Dictionary

**Version:** 1.0 | **Owner:** @unclenate | **Last Updated:** 2026-04-13 | **Review Cycle:** Quarterly

**Single source of truth for:** All KPIs used to measure auto-harness platform
health, adoption, and governance discipline. PRDs, release intents, and
retrospectives reference this dictionary rather than defining KPIs inline.

---

## KPI Entry Format

Each KPI includes:

- **Name:** Canonical name used across all documents
- **Definition:** What the KPI measures (one sentence, unambiguous)
- **Formula:** How it is calculated (explicit, reproducible)
- **Data Source:** Where the raw data comes from (system, file, validator output)
- **Reporting Frequency:** How often it is reported
- **Applicability:** Which projects, module compositions, or domains track this KPI
- **Baseline-Setting Protocol:** How the initial baseline is established

---

## Usage Rules

- **Define once, reference everywhere.** When a PRD, milestone, or retrospective
  mentions a KPI, it references this dictionary by name — not a re-definition.
- **Changes require review.** Modifying a KPI definition is a breaking change
  for everything that references it. Treat updates like an API change.
- **New KPIs require justification.** Before adding a KPI, confirm it can't
  be expressed as a variant of an existing one.
- **Retired KPIs stay documented.** Don't delete retired KPIs — mark them
  `Status: Retired` with the date and replacement (if any).
- **No aspirational metrics.** A KPI is only in this dictionary if it is
  computable from data that exists today or is committed to exist by a
  specific date.

---

## Platform Health KPIs

### Finding Resolution Velocity

- **Definition:** Average number of days from a finding's entry into
  `docs/project/revision-tracker.md` to its status becoming `Resolved`.
- **Formula:** `mean(resolution_date - entry_date)` across findings with
  status `Resolved` in the current reporting window.
- **Data Source:** `docs/project/revision-tracker.md` (finding rows with
  Status and Date columns).
- **Reporting Frequency:** Monthly (rolling 30-day window).
- **Applicability:** All auto-harness projects that activate
  `management/project-standard`.
- **Baseline-Setting Protocol:** Computed at end of first full month after
  the revision tracker is populated. Baseline = initial 30-day mean.

### Active Module Count per Manifest

- **Definition:** Number of distinct modules activated in a project's
  `harness.manifest.yaml`, broken down by module family.
- **Formula:** `count(modules.*)` grouped by family (core, stacks,
  architectures, data, delivery, management, domains, agents).
- **Data Source:** `harness.manifest.yaml` of each project adopting the
  harness.
- **Reporting Frequency:** On-change (report when a manifest updates).
- **Applicability:** Measured per project; aggregated across the
  auto-harness-managed portfolio.
- **Baseline-Setting Protocol:** Baseline established at project bootstrap
  (first passing `validate-manifest.sh`).

### Brownfield Artifact Coverage

- **Definition:** Percentage of required artifacts (declared by active
  modules) that actually exist on disk and pass
  `validate-required-artifacts.sh`.
- **Formula:** `(passing_artifacts / total_required_artifacts) * 100`,
  where totals are derived from active module.yaml `requiredArtifacts`
  fields.
- **Data Source:** `validate-required-artifacts.sh` output and
  `platform/profiles/**/module.yaml` declarations.
- **Reporting Frequency:** On-commit (CI) and weekly (drift detection).
- **Applicability:** All auto-harness projects; most useful for brownfield
  adoption tracking where coverage grows over time.
- **Baseline-Setting Protocol:** First run of the validator establishes
  baseline; target state is 100%.

---

## Cross-references

- Revision tracker (finding-level data): `docs/project/revision-tracker.md`
- Active module composition: `harness.manifest.yaml`
- Validator chain: `platform/validators/README.md`
- Product decisions referencing these KPIs: `docs/requirements/`

---

**Document Owner:** @unclenate
