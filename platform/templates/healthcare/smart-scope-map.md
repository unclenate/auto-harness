<!--
Copyright [[YEAR]] [[OWNER_NAME]] <[[OWNER_EMAIL]]>
SPDX-License-Identifier: [[SPDX_LICENSE]]
-->

# SMART Scope Map — [[PROJECT_NAME]]

> Owner: [[OWNER]]
> Last updated: YYYY-MM-DD

Required artifact for the `healthcare-smart-on-fhir` domain overlay. Declares the SMART
scopes this system grants, separated by trust role.

## Provider-Launch Scopes

The EHR launches the app and supplies context. List the launch contexts and provider-scoped
grants (e.g., `launch/patient`, `user/Observation.read`).

| Scope | Purpose | Tier |
|-------|---------|------|
| [[SCOPE]] | [[PURPOSE]] | [[TIER]] |

## Patient-Access Scopes

The patient authorizes the app to read their own records. List patient-scoped grants
(e.g., `patient/*.read`).

| Scope | Purpose | Tier |
|-------|---------|------|
| [[SCOPE]] | [[PURPOSE]] | [[TIER]] |

## Trust Model

State who owns the resource in each role. In provider-launch the operator governs access;
in patient-access the patient is the resource owner. Note where the two boundaries must not
be crossed (a patient-access token must never receive provider-launch scopes).
