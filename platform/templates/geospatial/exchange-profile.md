<!--
Copyright [[YEAR]] [[OWNER_NAME]] <[[OWNER_EMAIL]]>
SPDX-License-Identifier: [[SPDX_LICENSE]]
-->

# Exchange Profile — [[PROJECT_NAME]]

> Owner: [[OWNER]]
> Last updated: YYYY-MM-DD

Required artifact for the `geospatial-exchange` domain overlay. Declares the
formats and services this project exchanges, the role it plays, and how the
declared CRS is preserved on the wire.

## Role on the publisher ↔ consumer axis

| Role | Declaration |
|------|-------------|
| This project is | [[ROLE]] (authoritative publisher / derived consumer / both) |

## Declared formats and services

| Channel | Format / service | CRS-on-the-wire policy |
|---------|------------------|------------------------|
| [[CHANNEL]] | [[FORMAT_OR_SERVICE]] (e.g. GeoPackage; OGC API – Features; GeoJSON) | [[CRS_POLICY]] (how the declared CRS is carried/recovered) |

> **CRS-on-the-wire hazard.** GeoJSON (RFC 7946) fixes coordinates to WGS84 and
> dropped the `crs` member — non-WGS84 GeoJSON carries no CRS. State for each
> channel how the `spatial-reference-profile.md` CRS is preserved (sidecar,
> GeoPackage `gpkg_spatial_ref_sys`, documented reprojection).

## Notes

List published service endpoints and any access controls.
