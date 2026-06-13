<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Research Brief — Geospatial & BIM Coordinate Governance (grounds OPP-0045 / PRD-0024)

**Status:** Evidence artifact (web-grounded, primary sources cited)
**Date:** 2026-06-12
**Grounds:** [OPP-0045](../../opportunities/OPP-0045-domain-family-geospatial-decomposed.md),
[PRD-0024](../../requirements/PRD-0024-geospatial-gis-wedge.md)

This brief grounds the geospatial / GIS deep-domain wedge in the published
standards that govern *where a thing is on Earth* and *who may know it*. The
recurring governance hazard across all four areas is **silent coordinate loss**:
data that looks correct but is metre-to-kilometre mislocated because a CRS,
datum, epoch, unit, or map conversion was dropped, assumed, or mismatched on the
wire. Each wedge module exists to force a declaration that closes one of these
loss channels.

## A. Coordinate Reference Systems / Datums — grounds `spatial-reference-profile.md`

- The **EPSG Geodetic Parameter Dataset** (maintained by IOGP) assigns a unique
  numeric code to every published CRS, datum, projection, and transformation; an
  `authority:code` such as `EPSG:4326` unambiguously identifies how coordinates
  are interpreted. <https://epsg.org/>
- `EPSG:4326` = **WGS 84** geographic CRS (lat/lon, degrees); `EPSG:4269` =
  **NAD83** geographic CRS, the datum most U.S. federal agencies use.
  <https://epsg.io/4269>
- **WGS84 vs NAD83(2011) vs ETRS89** are distinct datums that drift apart over
  time; treating one as another causes metre-scale (and growing) horizontal
  misplacement — WGS84 and NAD83 differ ~1–2 m across North America, and ETRS89
  is fixed to the Eurasian plate.
  <https://www.ngs.noaa.gov/datums/newdatums/index.shtml>
- **Static vs dynamic datums:** NAD83/ETRS89 are plate-fixed (static); ITRF
  realizations let coordinates drift with crustal motion, so a coordinate is
  meaningless without its **epoch**.
  <https://geodesy.noaa.gov/datums/newdatums/index.shtml>
- **2022 datum modernization:** NGS will replace NAD83 with four plate-named
  frames including **NATRF2022**, each defined relative to **ITRF2020**, dynamic,
  with an explicit plate-motion model. Epoch handling becomes mandatory.
  <https://beta.ngs.noaa.gov/NATRF2022/>
- **Vertical datums:** a horizontal CRS alone is insufficient — height needs its
  own datum. **NAVD88** is the orthometric vertical datum; **GEOID18** converts
  GNSS **ellipsoidal height (h)** to **orthometric height (H)**. Mixing the two
  produces ~20–30 m blunders.
  <https://www.ngs.noaa.gov/GEOID/GEOID18/geoid18_tech_details.shtml>
- **Units as an error source:** the **US survey foot** (1200/3937 m) was
  deprecated 31 Dec 2022 in favor of the **international foot** (0.3048 m
  exactly); the 2 ppm difference accumulates into silent project misregistration.
  <https://www.ngs.noaa.gov/web/news/us-survey-foot.shtml>

## B. Geospatial Exchange Formats & Services — grounds `exchange-profile.md`

- **GeoJSON RFC 7946 (IETF, Aug 2016):** Section 4 fixes all coordinates to
  **WGS 84, longitude-then-latitude, decimal degrees** (`urn:ogc:def:crs:OGC::CRS84`).
  Appendix B.1 lists as a normative change that *"the 'crs' member of [GJ2008] is
  no longer used."* **Governance hazard:** any non-WGS84 GeoJSON carries no CRS on
  the wire and is silently mislocated.
  <https://datatracker.ietf.org/doc/html/rfc7946>
- **OGC GeoPackage** (SQLite-based, OGC 12-128r19) retains CRS per-layer via
  `gpkg_spatial_ref_sys` / `gpkg_contents.srs_id` — CRS travels with the data.
  <https://docs.ogc.org/is/12-128r19/12-128r19.html>
- **Esri Shapefile** stores CRS in an *optional* `.prj` sidecar, frequently
  missing — a classic silent-loss vector.
  <https://desktop.arcgis.com/en/arcmap/latest/manage-data/shapefiles/fundamentals-of-a-shapefiles-coordinate-system.htm>
- **CityGML 3.0** (OGC conceptual model, encodable in GML/JSON/DB); **CityJSON**
  is a JSON encoding of a subset of the CityGML 3.0.0 model.
  <https://www.ogc.org/standards/cityjson/>
- **OGC services / APIs (server publishes, client consumes):** **WMS** = rendered
  map images; **WFS** = raw vector features; **WMTS** = pre-cached tiles; **OGC
  API – Features** = modern REST+JSON successor to WFS; **OGC API – Tiles** =
  tiles with OpenAPI discovery. <https://ogcapi.ogc.org/>

## C. BIM ↔ GIS Georeferencing — grounds `georeference-map.md`

- **IFC4** introduced explicit georeferencing via **`IfcProjectedCRS`** (target
  CRS named from the EPSG namespace) + **`IfcCoordinateReferenceSystem`**, with
  **`IfcMapConversion`** mapping local IFC engineering coordinates to that CRS.
  Parameters: **Eastings, Northings, OrthogonalHeight** (origin), **XAxisAbscissa
  + XAxisOrdinate** (XY rotation), **Scale** (default 1.0).
  <https://standards.buildingsmart.org/IFC/RELEASE/IFC4_3/HTML/lexical/IfcMapConversion.htm>
- **IFC 4.3** extends georeferencing toward infrastructure (alignment geometry);
  known remaining gaps include a separate horizontal scale factor.
  <https://ifc43-docs.standards.buildingsmart.org/IFC/RELEASE/IFC4x3/HTML/lexical/IfcCoordinateReferenceSystem.htm>
- **LoGeoRef (Levels of Georeferencing 0/10/20/30/40/50)** — Clemen & Görne
  (buildingSMART, 2019); higher levels specify progressively stronger
  georeferencing, each standing on its own IFC-schema attributes (higher does not
  auto-include lower). <https://jgcc.geoprevi.ro/docs/2019/10/jgcc_2019_no10_3.pdf>
- **Revit** has internal origin, **Project Base Point**, **Survey Point** (the
  real-world anchor), and **Shared Coordinates**; IFC export uses Shared
  Coordinates offset to the Survey Point and aligned to True North to carry
  correct real-world values.
  <https://thinkmoult.com/ifc-coordinate-reference-systems-and-revit.html>
- **Core failure mode:** a federated model whose `IfcMapConversion` is wrong or
  absent is silently mislocated — every discipline model agrees with itself but
  sits in the wrong place on Earth.

## D. Geospatial Sensitivity — grounds the *compose-don't-build* decision

The wedge governs geospatial sensitivity by composing the existing
`management/digital-twin` and `management/privacy-by-design` overlays rather than
building a new sensitivity module. The evidence:

- **Precise geolocation as personal data (GDPR):** geolocation identifies
  individuals; precise location revealing sensitive attributes becomes sensitive —
  argues for routing through the privacy overlay, not a bespoke module.
  <https://iapp.org/news/a/making-the-case-for-a-new-geolocation-data-privacy-paradigm>
- **Critical-infrastructure location sensitivity:** precise asset locations are
  security-sensitive and warrant access controls beyond ordinary attribute data
  (Digital-Twin `security-boundaries.md` / `publication-policy.md` already govern
  this). <https://www.ogc.org/>
- **CARE Principles for Indigenous Data Governance** — Collective benefit,
  Authority to control, Responsibility, Ethics; published 2019 by the Global
  Indigenous Data Alliance as a people-and-purpose complement to the data-centric
  FAIR principles. Cadastral/territorial geodata over Indigenous lands implicates
  authority-to-control. <https://www.gida-global.org/care>
- **Cadastral/parcel privacy:** parcel ownership and boundary records tie precise
  location to identifiable persons; treat as sensitive PII-bearing geodata under
  the privacy overlay.
  <https://datascience.codata.org/articles/10.5334/dsj-2020-043>

## VERIFY-AT-IMPLEMENTATION flags

- **NATRF2022 timeline/status** is on an NGS *beta* page; rollout has historically
  slipped — re-verify live status and any assigned `EPSG` codes before pinning
  them in module content.
- **EPSG codes for the NATRF2022 frames** — not yet confirmed; verify exact
  `authority:code` at implementation.
- **LoGeoRef per-level attribute sets (10/20/30/40/50)** — confirmed in concept;
  pull the exact per-level attribute lists from the primary Clemen/Görne paper
  before encoding a checklist in `georeference-map.md`.
- **`IfcProjectedCRS` `MapUnit` / vertical-CRS handling** and the precise IFC 4.3
  delta over IFC4 — confirm against the IFC 4.3.2 schema, not secondary summaries.
- **GeoPackage CRS sentinels** (`srs_id` = -1 / 0 "undefined") — verify handling,
  since they reintroduce silent-loss risk.
- **GDPR "special category" status of location** is context-dependent (not
  inherently special-category) — have privacy/legal confirm the exact regime
  classification before asserting it normatively.
- **CARE canonical citation** — confirm the gida-global.org and CODATA
  (10.5334/dsj-2020-043) links live at implementation.

---

*Provenance: facts in Sections A–C verified against primary sources (IETF RFC
7946, NGS/NOAA, OGC, buildingSMART) during a 2026-06-12 web-research pass. Section
D legal/ethical framings are directionally verified; normative assertions are
flagged above for legal sign-off.*
