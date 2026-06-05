<!--
Copyright [[YEAR]] [[OWNER_NAME]] <[[OWNER_EMAIL]]>
SPDX-License-Identifier: [[SPDX_LICENSE]]
-->

# Information Management Plan — [[PROJECT_NAME]]

> Owner: [[OWNER]]
> Last updated: YYYY-MM-DD

Required artifact for the `aec-iso19650-im` domain overlay. Declares how
information is managed across the ISO 19650 Common Data Environment (CDE).

## Common Data Environment (CDE)

Where information containers live and how the CDE is structured (folders, naming
convention, the platform used).

## Information-Container Status Codes

| Code | State | Who may promote into it |
|------|-------|-------------------------|
| S0 | Work in progress (WIP) | [[ROLE]] |
| S1–S6 | Shared / coordinated / authorized | [[ROLE]] |
| Published / As-Built | Contractually binding | Human sign-off required |
| S7 | Archived | [[ROLE]] |

## Actor Model

| ISO 19650 role | This project | Responsibility |
|----------------|--------------|----------------|
| Appointing party | [[PARTY]] | [[RESPONSIBILITY]] |
| Lead appointed party | [[PARTY]] | [[RESPONSIBILITY]] |
| Appointed party | [[PARTY]] | [[RESPONSIBILITY]] |

## Status-Transition Policy

State who may promote a container between status codes, and which transitions
require human sign-off. Promotion to Published / As-Built always requires sign-off.
