<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0045 — Geospatial / GIS Domain Family (decomposed `domains/geospatial-*`)

**Status:** proposed
**Owner:** @unclenate
**Created:** 2026-06-12
**Last Updated:** 2026-06-12 *(proposed — wedge contract to be promoted via PRD-0024 in the same cycle; see Disposition)*
**Confidence:** high

---

## Thesis

The harness has no `domains/geospatial-*` (GIS / mapping / spatial-data)
coverage. Geospatial is a large, standards-rich, governance-shaped domain — the
built and natural environment runs on coordinate reference systems, OGC exchange
formats and services, and (where BIM meets GIS) model georeferencing. It is the
**designated fourth built deep-domain vertical** after healthcare, AEC, and the
cross-cutting overlays: a fourth independent instance of the
jurisdiction-neutral-core + forcing-artifact + bias-guardrail + trust-role
primitives, plus two enrichments earlier verticals could not surface — the first
**`domain × domain` composition** and a **temporal axis** on the forcing
artifact.

The vertical is grounded in a real, live workflow: connecting GIS / mapping data
to BIM (Revit / IFC) models. That workflow sits on a seam the catalog governs
from both ends but bridges from neither — the AEC vertical governs the building
side down to IFC exchange; the `management/digital-twin` overlay treats
geospatial data as a sensitivity/publication risk but never as a domain with its
own primitives. The georeferencing handshake between them is ungoverned today.

Apply the harness's per-concern module granularity (as healthcare and AEC did)
and ship geospatial as a **decomposed family**. This OPP ratifies the family
shape; PRD-0024 promotes the thin three-module wedge.

### Sub-modules (each per-activation, each with its own required artifacts)

| Sub-module | What it governs | Required artifact(s) | Disposition |
|---|---|---|---|
| `domains/geospatial-foundation` | The spatial-reference substrate: horizontal datum/CRS + vertical datum + units + epoch declaration; per-dataset source/license/provenance | `spatial-reference-profile.md`, `dataset-inventory.md` | **Wedge (PRD-0024)** |
| `domains/geospatial-exchange` | OGC exchange formats (GeoJSON, GeoPackage, CityGML/CityJSON, shapefile) and services (WMS/WFS/WMTS, OGC API – Features/Tiles); the publisher↔consumer role axis; the CRS-on-the-wire policy | `exchange-profile.md` | **Wedge (PRD-0024)** |
| `domains/geospatial-bim-georeference` | The BIM↔GIS pin: IFC map-conversion parameters + projected CRS, Revit survey-point/shared-coordinates origin, target georeferencing level, linked to the declared CRS | `georeference-map.md` | **Wedge (PRD-0024)** |
| `domains/geospatial-imagery-raster` | Raster/orthophoto/elevation (COG, GeoTIFF) provenance and CRS | `raster-inventory.md` (proposed) | Deferred |
| `domains/geospatial-cadastre-parcel` | Parcel/cadastral/land-records governance (sensitive personal + property data) | `parcel-data-policy.md` (proposed) | Deferred |
| `domains/geospatial-realtime-sensor` | Live sensor/IoT geospatial feeds (ties to digital-twin run-state) | `sensor-feed-policy.md` (proposed) | Deferred |
| `domains/geospatial-routing-network` | Network/routing/transport graph governance | `network-model-map.md` (proposed) | Deferred |

### Templates

A new `platform/templates/geospatial/` directory. Four wedge templates ship with
PRD-0024 (`spatial-reference-profile.md` carrying the bias guardrail,
`dataset-inventory.md`, `exchange-profile.md`, `georeference-map.md`); deferred
sub-modules add their own when promoted.

### Convenience composition

A `platform/compositions/geospatial-bim-twin.yaml` starter that activates the
three wedge modules together with `aec-openbim-exchange` (transitively
`aec-iso19650-im`), `management/digital-twin`, and `management/privacy-by-design`.
This is the catalog's **first 4-way domain × domain × cross-cutting ×
cross-cutting composition** — "a digital twin of a place built from BIM + GIS
with sensitive-location and personal-data governance" — and the first time two
*domain families* compose.

## Origin / Evidence

- **Framework-harvest origin.** This is the fourth concrete deep-domain instance
  the framework harvest set out to gather (see the `project-deep-industry-domains`
  memory and the healthcare design spec's harvest plan). Healthcare gave the base
  primitives; privacy and AEC added cross-cutting reuse, a compound forcing
  artifact, and the first domain × cross-cutting composition; geospatial adds the
  first domain × domain composition and a temporal forcing-artifact axis.
- **Live workflow grounding.** Unlike AEC (standards-only), geospatial is grounded
  in an active GIS + Revit + mapping-data workflow, giving the wedge a real
  consumer shape to validate sensitive-path regexes and the georeferencing
  artifact against.
- **Design provenance.** The three-module wedge ("wedge B"), the compound +
  temporal spatial-reference-profile, and the compose-don't-build sensitivity
  decision were settled through a brainstorming pass and are captured directly in
  this OPP and the PRD-0024 design contract (the harness-native design home),
  rather than a separate brainstorming spec.
- **Standards research brief.** A `geospatial-gis-research-brief.md` grounding the
  CRS/datum/epoch, OGC exchange, IFC georeferencing (IfcMapConversion /
  IfcProjectedCRS, LoGeoRef levels), and sensitivity (CARE Principles) facts —
  web-grounded and committed with PRD-0024 (the AEC-pattern evidence artifact).
- **Structural analog (grounding, not speculation).** The wedge mirrors the
  proven healthcare/AEC shape one-to-one: `geospatial-foundation` ≈
  `healthcare-fhir` ≈ `aec-iso19650-im` (substrate); `geospatial-exchange` ≈
  `smart-on-fhir` ≈ `aec-openbim-exchange` (access layer carrying the trust-role
  axis); sensitivity is **composed** (Digital-Twin + privacy) rather than a built
  spine. The intra-family dependency (`exchange → foundation`) is the same pattern
  as `smart-on-fhir → fhir` and `openbim-exchange → iso19650-im`.
- **Internal precedent for module granularity.** As with the `healthcare-*` and
  `aec-*` families, a consumer doing CRS + exchange work does not need the
  georeferencing module; bundling would force irrelevant required-artifact debt.
  The decomposition matches observable subsystem boundaries (spatial reference /
  exchange / model-georeferencing are distinct concerns).

## Why Now

- **The harvest benefits from a fourth, purest instance.** The
  jurisdiction-profile primitive appears in geospatial in its most undeniable
  form — a CRS is geodetically and temporally bound, and assuming the wrong one
  silently misplaces every feature by metres. This is the strongest evidence
  instance for promoting the primitive to a deep-domain operating-principle.
- **The BIM↔GIS seam is a real, unmodeled boundary.** The catalog governs the
  building side (AEC/IFC) and the place/twin side (digital-twin) but not the pin
  between them. The georeference module produces that boundary as the first
  domain × domain composition.
- **Grounded in active work.** A real GIS + Revit workflow needs this governance
  now, which both motivates the wedge and gives it a consumer to refine against.

## Risks / Open Questions

- **WGS84 / EPSG:4326 default bias (cross-cutting, architectural).** The most
  common silent error is assuming WGS84 lon/lat when data is in NAD83, ETRS89, or
  a local/national grid; GeoJSON (RFC 7946) even drops non-WGS84 CRS on the wire.
  **Required before freezing any artifact:** the `spatial-reference-profile.md`
  template default-denies an assumed CRS and forces an explicit
  `{horizontal datum/CRS} × {vertical datum} × {epoch} × {units}` declaration,
  and the `exchange-profile.md` carries a CRS-on-the-wire preservation policy. A
  geospatial-bias observation is slated for `shared-observations.md`.
- **Compose-don't-build sensitivity.** The wedge has no `geospatial-sensitivity`
  module; sensitivity (critical-infrastructure location, precise geolocation as
  personal data, indigenous data sovereignty / CARE Principles, cadastral
  privacy) is governed by composing Digital-Twin + privacy. Risk: a consumer
  needing sensitivity *outside* a twin context. Mitigation: a dedicated module
  stays deferred until such a consumer surfaces.
- **Standards version volatility (verify-at-implementation, not wedge-blocking).**
  Confirm at PRD/research-brief time: EPSG dataset usage; CityGML 3.0 vs.
  CityJSON; OGC API – Features/Tiles part numbers; GeoPackage version;
  `IfcMapConversion` / `IfcProjectedCRS` parameter list and IFC 4.3
  georeferencing; LoGeoRef level definitions; Revit survey-point → IFC export
  mapping.
- **Vendor SDK surfaces deferred.** Esri ArcGIS and Autodesk Platform Services
  are vendor APIs; the wedge governs the open standards/exchange/georeferencing
  layer, not vendor SDKs (mirrors the deferred `aec-aps-tooling` decision).

## Disposition

**Proposed 2026-06-12.** The three wedge sub-modules
(`domains/geospatial-foundation`, `domains/geospatial-exchange`,
`domains/geospatial-bim-georeference`) are slated for promotion to a v1 wedge via
PRD-0024 in the same cycle; on PRD acceptance this OPP updates to
*accepted — partial promotion*. The deferred sub-modules
(`geospatial-imagery-raster`, `geospatial-cadastre-parcel`,
`geospatial-realtime-sensor`, `geospatial-routing-network`) stay `proposed`
pending consumer demand.

## Promotion

Pending. On PRD-0024 acceptance: promoted sub-modules =
`domains/geospatial-foundation`, `domains/geospatial-exchange`,
`domains/geospatial-bim-georeference`. The first domain × domain composition and
the temporal forcing-artifact axis are the two enrichments contributed to the
deep-domain framework harvest (a separate later cycle; see
`project-deep-industry-domains` memory).

## Related

- Predecessor vertical (third built domain): [OPP-0039](OPP-0039-domain-family-aec-decomposed.md)
- First built domain: [OPP-0013](OPP-0013-domain-family-healthcare-decomposed.md)
- Cross-family dependency target: `domains/aec-openbim-exchange` (PRD-0019, shipped)
- Cross-cutting overlays reused by the composition: `management/digital-twin` (PRD-0023, shipped), `management/privacy-by-design` (PRD-0018, shipped)
- Wedge design contract: PRD-0024 *(authored same cycle — the design home)*
