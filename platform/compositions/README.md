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
| [new-product-discovery.yaml](new-product-discovery.yaml) | Stack TBD | Discovery phase — idea to first manifest |
| [node-web-saas-postgres.yaml](node-web-saas-postgres.yaml) | Node / TS | Web app with PostgreSQL |
| [python-api-service-postgres.yaml](python-api-service-postgres.yaml) | Python | API service with PostgreSQL |
| [research-pipeline-python-object-storage.yaml](research-pipeline-python-object-storage.yaml) | Python | Data / ML pipeline |
| [web3-risk-analytics.yaml](web3-risk-analytics.yaml) | Python | Blockchain-integrated platform |

---

## How to Use

1. Pick the composition closest to your project type.
2. Copy it to your project root as `harness.manifest.yaml`.
3. Edit the `project` block (id, name, maturity, criticality).
4. Add or remove modules to match your actual stack.
5. Run `validate-manifest.sh` and `validate-module-graph.sh` to confirm the composition is valid.

See [Bootstrap Quickstart](../workflow/bootstrap-quickstart.md) for the full walkthrough.
