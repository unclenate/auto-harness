<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Domain Overlay: BIM↔GIS Georeference (Bridge)

**Depends on:** `kernel/base`, `geospatial-foundation`, `aec-openbim-exchange`.
**Conflicts with:** None.

This overlay governs the **BIM↔GIS georeferencing handshake** — the map conversion
that pins a federated IFC/BIM model into a declared real-world coordinate reference
system. It is the catalog's **first cross-family dependency**: it depends on
`domains/aec-openbim-exchange` (the BIM exchange side) as well as
`domains/geospatial-foundation` (the CRS side), because the seam it governs only
exists when both are present.

A wrong or absent map conversion silently mislocates the entire federated model —
every discipline model agrees with itself but sits in the wrong place on Earth.

## Cross-family dependency rationale

The bridge is **incoherent without both sides**, so the dependency is a hard
`dependsOn` (not a compose-with). Activating this module transitively activates the
AEC exchange substrate (`aec-openbim-exchange → aec-iso19650-im`) and inherits its
required artifacts — intended, because you cannot govern the BIM↔GIS pin without
the BIM exchange governance. This is distinct from optional concerns (e.g.
sensitivity), which stay compose-with.

## When To Activate

Activate when a project pins a Revit/IFC model to real-world coordinates (survey
point / shared coordinates / `IfcMapConversion`). Requires both
`domains/geospatial-foundation` and `domains/aec-openbim-exchange`.

## What This Overlay Requires

| Artifact | Purpose |
|----------|---------|
| `docs/geospatial/georeference-map.md` | The BIM↔GIS pin: map-conversion parameters (eastings, northings, orthogonal height, rotation, scale), survey-point origin, target georeferencing level, linked to the declared CRS |

The template lives in `platform/templates/geospatial/`.

## Sensitive Paths and Companion Rules

Sensitive paths cover georeferencing and map-conversion surfaces (`georef/`, and
paths containing `mapconversion`, `projectedcrs`, `surveypoint`,
`sharedcoordinates`). One companion rule: `georeference-map.md` (or any
georeferencing surface) changes require an ADR or a change-log entry.

## Review Gate

Human review is required to change the georeferencing (datum, origin, rotation, or
scale) or the target CRS.

## See Also

- Module definition: [`module.yaml`](module.yaml)
- Active modules table: [`HARNESS.md`](../../../../HARNESS.md)
- Built on: [`domains/geospatial-foundation`](../geospatial-foundation/README.md), [`domains/aec-openbim-exchange`](../aec-openbim-exchange/README.md)
- Templates: `platform/templates/geospatial/`
- Origin: [`OPP-0045`](../../../../docs/opportunities/OPP-0045-domain-family-geospatial-decomposed.md), [`PRD-0024`](../../../../docs/requirements/PRD-0024-geospatial-gis-wedge.md)
