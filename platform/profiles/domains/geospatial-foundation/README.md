<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Domain Overlay: Geospatial Foundation (Spatial Reference)

**Depends on:** `kernel/base`.
**Conflicts with:** None.

This overlay governs the **spatial-reference substrate** of a geospatial project —
the coordinate reference system (horizontal datum, vertical datum, epoch, and
units) and the provenance of each dataset. It is the foundation of the geospatial
domain family; `domains/geospatial-exchange` and
`domains/geospatial-bim-georeference` build on it.

The overlay's core is **CRS-agnostic**. It makes no coordinate reference system
the default — it forces the consumer to declare theirs in a required artifact.
Assuming WGS84 / EPSG:4326 when the data is in NAD83, ETRS89, or a local grid
silently misplaces every feature by metres.

## When To Activate

Activate when a project handles geospatial / mapping data — GIS layers, survey
data, basemaps, or any coordinates tied to the real world. Pairs with
`domains/geospatial-exchange` (OGC exchange) and
`domains/geospatial-bim-georeference` (BIM↔GIS pinning).

## What This Overlay Requires

| Artifact | Purpose |
|----------|---------|
| `docs/geospatial/spatial-reference-profile.md` | The compound, temporal forcing artifact — declares horizontal datum/CRS × vertical datum × epoch × units; carries the bias guardrail |
| `docs/geospatial/dataset-inventory.md` | Each dataset's source, license, format, declared CRS, and provenance |

Templates for both live in `platform/templates/geospatial/`.

## Sensitive Paths and Companion Rules

Sensitive paths cover spatial-data, coordinate, and projection surfaces (`geo/`,
`gis/`, `data/spatial/`, and paths containing `coordinate`, `projection`, `crs`).
Two companion rules:

- `spatial-reference-profile.md` (or any CRS/datum/projection surface) changes
  require an ADR or a change-log entry.
- `dataset-inventory.md` changes require a change-log entry or an ADR.

## Review Gate

Human review is required to change the declared authoritative CRS, datum, vertical
datum, or epoch — it silently relocates all spatial data.

## See Also

- Module definition: [`module.yaml`](module.yaml)
- Active modules table: [`HARNESS.md`](../../../../HARNESS.md)
- Built on by: [`domains/geospatial-exchange`](../geospatial-exchange/README.md), [`domains/geospatial-bim-georeference`](../geospatial-bim-georeference/README.md)
- Templates: `platform/templates/geospatial/`
- Origin: [`OPP-0045`](../../../../docs/opportunities/OPP-0045-domain-family-geospatial-decomposed.md), [`PRD-0024`](../../../../docs/requirements/PRD-0024-geospatial-gis-wedge.md)
