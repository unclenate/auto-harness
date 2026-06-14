<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Domain Overlay: Geospatial Exchange (OGC Formats & Services)

**Depends on:** `kernel/base`, `geospatial-foundation`.
**Conflicts with:** None.

This overlay governs how geospatial data is **exchanged** — the OGC formats
(GeoJSON, GeoPackage, CityGML / CityJSON, shapefile) and services (WMS, WFS, WMTS,
OGC API – Features / Tiles) a project publishes or consumes, the **publisher ↔
consumer** role axis (who is the authoritative source vs. a derived consumer), and
an explicit **CRS-on-the-wire** policy.

The CRS-on-the-wire policy exists because some formats silently drop the declared
CRS: GeoJSON (RFC 7946) fixes coordinates to WGS84 and removed the `crs` member, so
any non-WGS84 GeoJSON carries no CRS on the wire. The `exchange-profile.md` must
state how the foundation's declared CRS is preserved across each declared format.

## When To Activate

Activate when a project publishes or consumes geospatial data through files or OGC
services. Requires `domains/geospatial-foundation` (the declared CRS it preserves).

## What This Overlay Requires

| Artifact | Purpose |
|----------|---------|
| `docs/geospatial/exchange-profile.md` | Declared formats and services, the publisher/consumer role axis, and the CRS-on-the-wire preservation policy |

The template lives in `platform/templates/geospatial/`.

## Sensitive Paths and Companion Rules

Sensitive paths cover exchange and service surfaces (`exchange/`, `services/`,
`api/geo`, and paths containing `wfs`, `wms`, `geojson`, `tiles`). Two companion
rules:

- `exchange-profile.md` (or any exchange/service surface) changes require an ADR or
  a change-log entry.
- Publishing a new authoritative dataset or service endpoint requires a
  risk-register update or an ADR (publication = exposure).

## Review Gate

Human review is required to widen a published service grant or change the
CRS-on-the-wire policy.

## See Also

- Module definition: [`module.yaml`](module.yaml)
- Active modules table: [`HARNESS.md`](../../../../HARNESS.md)
- Built on: [`domains/geospatial-foundation`](../geospatial-foundation/README.md)
- Templates: `platform/templates/geospatial/`
- Origin: [`OPP-0045`](../../../../docs/opportunities/OPP-0045-domain-family-geospatial-decomposed.md), [`PRD-0024`](../../../../docs/requirements/PRD-0024-geospatial-gis-wedge.md)
