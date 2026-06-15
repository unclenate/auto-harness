<!--
Copyright [[YEAR]] [[OWNER_NAME]] <[[OWNER_EMAIL]]>
SPDX-License-Identifier: [[SPDX_LICENSE]]
-->

# Dataset Inventory — [[PROJECT_NAME]]

> Owner: [[OWNER]]
> Last updated: YYYY-MM-DD

Required artifact for the `geospatial-foundation` domain overlay. One row per
dataset; each declares its own CRS so silent reprojection cannot hide a mismatch
with the project's declared `spatial-reference-profile.md`.

| Dataset | Source / Authority | License | Format | Declared CRS | Provenance / date |
|---------|--------------------|---------|--------|--------------|-------------------|
| [[DATASET_NAME]] | [[SOURCE]] | [[LICENSE]] | [[FORMAT]] | [[DATASET_CRS]] | [[PROVENANCE]] |

## Notes

Flag any dataset whose declared CRS differs from the project CRS and the
transformation used to align it.
