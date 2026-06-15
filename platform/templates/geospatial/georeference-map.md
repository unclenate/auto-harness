<!--
Copyright [[YEAR]] [[OWNER_NAME]] <[[OWNER_EMAIL]]>
SPDX-License-Identifier: [[SPDX_LICENSE]]
-->

# Georeference Map — [[PROJECT_NAME]]

> Owner: [[OWNER]]
> Last updated: YYYY-MM-DD

Required artifact for the `geospatial-bim-georeference` domain overlay. Records the
map conversion that pins the federated BIM/IFC model into the real-world CRS
declared in `spatial-reference-profile.md`.

## Target CRS

| Field | Declaration |
|-------|-------------|
| Target CRS (IfcProjectedCRS) | [[TARGET_CRS]] (authority:code; must match the declared spatial-reference-profile) |

## Map conversion (IfcMapConversion)

| Parameter | Value |
|-----------|-------|
| Eastings | [[EASTINGS]] |
| Northings | [[NORTHINGS]] |
| Orthogonal height | [[ORTHOGONAL_HEIGHT]] |
| X-axis abscissa / ordinate (rotation) | [[XAXIS_ABSCISSA]] / [[XAXIS_ORDINATE]] |
| Scale | [[SCALE]] (default 1.0) |

## Model origin and georeferencing level

| Field | Declaration |
|-------|-------------|
| Revit survey-point / shared-coordinates origin | [[SURVEY_POINT]] |
| Target georeferencing level (LoGeoRef 0–50) | [[LOGEOREF_LEVEL]] |

## Notes

A wrong map conversion silently mislocates the whole federated model. Record how
the parameters were derived and verified.
