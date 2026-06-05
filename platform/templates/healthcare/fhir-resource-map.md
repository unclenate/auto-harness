<!--
Copyright [[YEAR]] [[OWNER_NAME]] <[[OWNER_EMAIL]]>
SPDX-License-Identifier: [[SPDX_LICENSE]]
-->

# FHIR Resource Map — [[PROJECT_NAME]]

> Owner: [[OWNER]]
> Last updated: YYYY-MM-DD

Required artifact for projects using the `healthcare-fhir` domain overlay. Records which
FHIR resources and version this system implements, and which jurisdictional profiles apply
(see the companion `jurisdiction-profile.md`).

## FHIR Version

[[FHIR_VERSION]]  (e.g., R4 / R4B / R5)

## Implemented Resources

| Resource | Profile(s) | Read | Write | Notes |
|----------|-----------|------|-------|-------|
| [[RESOURCE]] | [[PROFILE]] | yes/no | yes/no | [[NOTES]] |

## PHI Exposure

Which resources carry PHI, and how access is bounded.
