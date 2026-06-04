<!--
Copyright [[YEAR]] [[OWNER_NAME]] <[[OWNER_EMAIL]]>
SPDX-License-Identifier: [[SPDX_LICENSE]]
-->

# Exchange Requirements — [[PROJECT_NAME]]

> Owner: [[OWNER]]
> Last updated: YYYY-MM-DD

Required artifact for the `aec-openbim-exchange` domain overlay. Declares the
openBIM exchange contract (IDS-style) and the trust-role axis.

## Pinned IFC Version

**IFC version: [[IFC_VERSION]]** (e.g., IFC4 / IFC4.3 / IFC4x3-ADD2). This is an
enforced field — changing it requires human sign-off (tool support is fragmented).

## Required Entities / Properties (IDS-style)

| IFC entity / class | Required properties | Classification |
|--------------------|---------------------|----------------|
| [[ENTITY]] | [[PROPERTIES]] | [[CLASSIFICATION]] |

## Producer / Receiver / Reviewer Role Axis (ISO 19650-4)

| Role | Who | Which containers | Permission |
|------|-----|------------------|------------|
| Producer | [[PARTY]] | [[CONTAINERS]] | author |
| Receiver | [[PARTY]] | [[CONTAINERS]] | consume |
| Reviewer | [[PARTY]] | [[CONTAINERS]] | approve / reject |

State which CDE permissions in the information-management plan reference these roles,
and where a producer↔receiver boundary must not be crossed.
