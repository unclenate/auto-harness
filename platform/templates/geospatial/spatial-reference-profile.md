<!--
Copyright [[YEAR]] [[OWNER_NAME]] <[[OWNER_EMAIL]]>
SPDX-License-Identifier: [[SPDX_LICENSE]]
-->

# Spatial Reference Profile — [[PROJECT_NAME]]

> Owner: [[OWNER]]
> Last updated: YYYY-MM-DD

Required artifact for the `geospatial-foundation` domain overlay. Forces an
explicit declaration of the coordinate reference system this project's data is in.

> **Bias guardrail.** This module makes no coordinate reference system the default.
> Declare your horizontal datum/CRS, vertical datum, epoch, and units below.
> **Do not assume WGS84 / EPSG:4326** — assuming it when the data is in NAD83,
> ETRS89, or a local/national grid silently misplaces every feature by metres. A
> CRS is bound to *place and time*: dynamic datums drift, so the epoch matters.

## Declared Spatial Reference (compound: four axes)

| Axis | Declaration |
|------|-------------|
| Horizontal datum / CRS | [[HORIZONTAL_CRS]] (authority:code, e.g. EPSG:6318 NAD83(2011); EPSG:4326 WGS84; a local grid) |
| Vertical datum | [[VERTICAL_DATUM]] (e.g. NAVD88 + GEOID18; ellipsoidal; none) |
| Epoch | [[EPOCH]] (e.g. 2010.0; n/a for a static datum) |
| Linear units | [[UNITS]] (metre / international foot / US survey foot — note the US survey foot was deprecated 2022) |

## Notes

Record the source of the declared CRS (survey control, agency mandate), any
transformation/reprojection applied to incoming data, and the accuracy budget.
