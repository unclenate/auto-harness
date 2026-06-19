<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Starter Compositions

Pre-built `harness.manifest.yaml` files for common project types. Copy the closest match
to your project root and adjust the `project` fields and module list.

```bash
cp platform/compositions/node-web-saas-postgres.yaml harness.manifest.yaml
```

---

## Available Compositions

| Composition | Stack | Use When |
|-------------|-------|----------|
| [agentic-ui-saas.yaml](agentic-ui-saas.yaml) | Node / TS | SaaS web app with an in-product copilot or generative-UI surface (CopilotKit / A2UI feature bolted onto a web product). For conversational-primary products, also add `architectures/agentic-ui` |
| [brownfield-lite.yaml](brownfield-lite.yaml) | Any | Existing codebase — assessment pending |
| [interview-driven-discovery.yaml](interview-driven-discovery.yaml) | Any | Monolithic-docs project (one PRD, one plan, one interview prompt) — small teams and hackathon-tier work |
| [mcp-server-typescript.yaml](mcp-server-typescript.yaml) | TypeScript | Projects that ship a Model Context Protocol (MCP) server in TypeScript (producer-side `architectures/mcp-server` + interview-driven management) |
| [mcp-server-typescript-oss.yaml](mcp-server-typescript-oss.yaml) | TypeScript | OSS-released MCP server in TypeScript (producer-side `architectures/mcp-server` + `delivery/self-hosted-oss` + project-standard + knowledge-capture management) |
| [new-product-discovery.yaml](new-product-discovery.yaml) | Stack TBD | Discovery phase — idea to first manifest |
| [node-web-saas-postgres.yaml](node-web-saas-postgres.yaml) | Node / TS | Web app with PostgreSQL |
| [python-api-service-postgres.yaml](python-api-service-postgres.yaml) | Python | API service with PostgreSQL |
| [research-pipeline-python-object-storage.yaml](research-pipeline-python-object-storage.yaml) | Python | Data / ML pipeline |
| [web3-risk-analytics.yaml](web3-risk-analytics.yaml) | Python | Blockchain-integrated platform |
| [healthcare-fhir-app.yaml](healthcare-fhir-app.yaml) | Any | FHIR + SMART-on-FHIR application — healthcare data layer + SMART app-launch/scopes, provider-launch + patient-access roles |
| [aec-bim-project.yaml](aec-bim-project.yaml) | ISO 19650 IM + openBIM exchange + ISO 19650-5 security + privacy-by-design | Delivering built-environment information under ISO 19650 with openBIM model exchange |
| [digital-twin-prototype.yaml](digital-twin-prototype.yaml) | digital-twin + privacy-by-design + ISO 19650 IM | Scenario-driven digital-twin / decision-support project (municipal, real-estate, datacenter, civic) |
| [geospatial-bim-twin.yaml](geospatial-bim-twin.yaml) | geospatial foundation + exchange + BIM↔GIS georeference + openBIM exchange + digital-twin + privacy-by-design | BIM + GIS digital twin — first 4-way domain × domain × cross-cutting × cross-cutting composition |
| [work-package-lane.yaml](work-package-lane.yaml) | work-package + node-typescript | Parallel multi-agent delivery — per-task lane (allowedFiles / readOnlyFiles) checked against the agent's actual diff |

---

## How to Use

1. Pick the composition closest to your project type.
2. Copy it to your project root as `harness.manifest.yaml`.
3. Edit the `project` block (id, name, maturity, criticality).
4. Add or remove modules to match your actual stack.
5. Run `validate-manifest.sh` and `validate-module-graph.sh` to confirm the composition is valid.

See [Bootstrap Quickstart](../workflow/bootstrap-quickstart.md) for the full walkthrough.
