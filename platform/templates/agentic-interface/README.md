<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Agentic Interface Templates

Templates for the `domains/agentic-interfaces` module. Copy the files you need into the
project's `docs/agentic-interface/` directory and fill in the `[[PLACEHOLDER]]` fields
before committing.

## Files

| Template | Copy to | Required by module? |
|----------|---------|---------------------|
| `design.md` | `docs/agentic-interface/design.md` | **Yes** |
| `risk-register.md` | `docs/agentic-interface/risk-register.md` | **Yes** |
| `prompt-tool-registry.md` | `docs/agentic-interface/prompt-tool-registry.md` | Optional, strongly recommended once the agent has more than 2-3 tools |
| `renderer-contract.md` | `docs/agentic-interface/renderer-contract.md` | Optional, required in practice for Declarative and Open-ended flavors |

A `component-manifest.md` template is intentionally omitted in v1 — when the Controlled
flavor has many agent-renderable components, model the manifest on the existing
`platform/templates/web3/contract-registry.md` row-per-entity pattern.

## Order to Fill

1. **`design.md`** first — names the flavor and bounds everything else
2. **`renderer-contract.md`** (if Declarative or Open-ended) — the concrete catalog, schema, or sandbox boundary
3. **`prompt-tool-registry.md`** — the tools the agent can call, one row per tool
4. **`risk-register.md`** — review the pre-seeded rows, mark each Open/Mitigated/Closed, add product-specific rows

## References

- `platform/profiles/domains/agentic-interfaces/README.md` — the module that requires these artifacts
- `docs/adr/ADR-0007-agentic-interface-awareness.md` — design rationale
