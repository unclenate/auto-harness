<!--
Copyright [[YEAR]] [[OWNER_NAME]] <[[OWNER_EMAIL]]>
SPDX-License-Identifier: [[SPDX_LICENSE]]
-->

# Jurisdiction Profile — [[PROJECT_NAME]]

> Owner: [[OWNER]]
> Last updated: YYYY-MM-DD

Required artifact for the `aec-iso19650-im` domain overlay. Forces an explicit
declaration of the regulatory context this project is delivered under.

> **Bias guardrail.** This module makes no jurisdiction the default. Declare yours
> below. **Do not assume the UK BS EN ISO 19650 + Uniclass path** — it is the most
> heavily documented, and that over-documentation is precisely the bias to guard
> against. ISO 19650 is an international standard; the National Annex, the Authority
> Having Jurisdiction (AHJ) + code edition, and the classification system are
> jurisdictional and must be named explicitly.

## Declared Jurisdiction (compound: three axes)

| Axis | Declaration |
|------|-------------|
| ISO 19650 National Annex | [[NATIONAL_ANNEX]] (e.g., UK BS EN 19650 NA; none; other) |
| AHJ + code edition | [[AHJ]] + [[CODE_EDITION]] (e.g., local building authority + IBC 2021) |
| Classification system | [[CLASSIFICATION]] (Uniclass 2015 / OmniClass / MasterFormat / UniFormat / none) |

## Notes

Record any realm-specific mandates (e.g., a public-sector BIM mandate) and the
information-protocol clauses that bind this project.
