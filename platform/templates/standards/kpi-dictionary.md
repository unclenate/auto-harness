<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# [[PROJECT_NAME]] — KPI Dictionary

**Version:** 1.0 | **Owner:** [[OWNER]] | **Last Updated:** YYYY-MM-DD | **Review Cycle:** [[REVIEW_CYCLE]]

**Single source of truth for:** All KPI definitions used across requirements,
reporting, dashboards, and external communications. PRDs and engine plans
reference this dictionary rather than defining KPIs inline.

---

## KPI Entry Format

Each KPI includes:

- **Name:** Canonical name used across all documents
- **Definition:** What the KPI measures (one sentence, unambiguous)
- **Formula:** How it is calculated (explicit, reproducible)
- **Data Source:** Where the raw data comes from (system, table, API endpoint)
- **Reporting Frequency:** How often it is reported
- **Applicability:** Which projects, tiers, or domains track this KPI
- **Baseline-Setting Protocol:** How the initial baseline is established

---

## Usage Rules

- **Define once, reference everywhere.** When a PRD, milestone, or report
  mentions a KPI, it references this dictionary by name — not a re-definition.
- **Changes require review.** Modifying a KPI definition is a breaking change
  for everything that references it. Treat updates like an API change.
- **New KPIs require justification.** Before adding a KPI, confirm it can't
  be expressed as a variant of an existing one.
- **Retired KPIs stay documented.** Don't delete retired KPIs — mark them
  `Status: Retired` with the date and replacement (if any).

---

## KPIs

### [[METRIC]]

- **Definition:** [[KPI_DEFINITION]]
- **Formula:** [[KPI_FORMULA]]
- **Data Source:** [[KPI_DATA_SOURCE]]
- **Reporting Frequency:** [[KPI_FREQUENCY]]
- **Applicability:** [[KPI_APPLICABILITY]]
- **Baseline-Setting Protocol:** [[KPI_BASELINE_PROTOCOL]]

<!-- Duplicate the above block for each additional KPI. Group by engine,
domain, or product area with ## sub-headings when the list grows. -->

---

## Cross-references

- PRDs that reference these KPIs: [[RELATED_DOCUMENT]]
- Related standards: `docs/standards/sla-definitions.md`,
  `docs/standards/attribution-model.md`
- Attribution and measurement context: [[RELATED_ADR]]

---

**Document Owner:** [[OWNER]]
