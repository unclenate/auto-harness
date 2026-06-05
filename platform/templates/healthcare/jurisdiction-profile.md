<!--
Copyright [[YEAR]] [[OWNER_NAME]] <[[OWNER_EMAIL]]>
SPDX-License-Identifier: [[SPDX_LICENSE]]
-->

# Jurisdiction Profile — [[PROJECT_NAME]]

> Owner: [[OWNER]]
> Last updated: YYYY-MM-DD

Required artifact for the `healthcare-fhir` domain overlay. Forces an explicit declaration
of the regulatory jurisdiction(s) this system operates under.

> **Bias guardrail.** This module makes no jurisdiction the default. Declare yours below.
> Do not assume US (or any single region) norms, code sets, or legal regimes. FHIR is an
> international standard; profiles such as US Core and the International Patient Summary (IPS)
> are jurisdictional and must be named explicitly.

## Declared Jurisdiction(s)

| Region | Applicable profile | Regulatory regime |
|--------|-------------------|-------------------|
| [[REGION]] | [[PROFILE]] (US Core / IPS / UK Core / AU Base / …) | [[REGIME]] (HIPAA / GDPR / …) |

## Code Systems and Terminologies

Which code systems apply in the declared jurisdiction(s) (e.g., ICD-10-CM vs ICD-10,
SNOMED CT edition, local value sets).
