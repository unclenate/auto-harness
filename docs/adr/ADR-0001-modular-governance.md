<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# ADR-0001: Modular Governance Architecture

**Status:** Accepted
**Date:** 2026-04-07
**Author:** @unclenate
**Reviewers:** @unclenate

## Context

The original governance harness was a single monolith prompt (~1000 lines) that tried to
cover every stack, domain, and delivery model in one file. This was unmaintainable: adding
Web3 support meant editing the same file that controlled Node.js CI, and a prototype project
inherited production SaaS ceremony it didn't need.

The project needed an architecture where governance rules could be composed per-project,
where modules could declare dependencies and conflicts, and where validators could enforce
the composition at CI time.

## Decision

Decompose the monolith into a modular system with:

- A **kernel** (`kernel/base`) that defines durable, universal rules (doctrine, trust tiers,
  lifecycle controls, canonical records, enforcement model)
- **Overlay modules** organized by family (stacks, architectures, data, delivery, management,
  domains, agents) that add domain-specific governance
- A **manifest** (`harness.manifest.yaml`) where projects declare which modules are active
- **Validators** that enforce the manifest, module graph, required artifacts, placeholders,
  agent packs, and companion rules
- **Templates** for every required artifact, with placeholder tokens

## Consequences

### Positive

- Projects compose exactly the governance they need — a prototype skips production ops,
  a Web3 project adds chain-specific rules
- New modules can be added without touching existing ones
- Validators catch drift at CI time, not during code review
- Templates make bootstrapping fast — copy and fill, not write from scratch

### Negative

- More files to maintain than a single prompt (24 module.yaml + 24 README + 35 templates)
- Cross-module documentation drift is a real risk (mitigated by gap analysis process)
- The naming convention for templates is non-obvious (flattening pattern)

### Watch

- If module count exceeds ~40, consider a registry or search tool
- If template maintenance becomes a bottleneck, consider generation from module.yaml
- If consumer projects struggle with composition, add a guided CLI wizard

## Alternatives Considered

| Alternative | Why rejected |
|-------------|--------------|
| Keep the monolith prompt | Unmaintainable at scale; can't compose per-project |
| Use a JSON/YAML DSL without human-readable docs | Governance needs to be readable by humans, not just machines |
| Build a CLI tool that generates governance files | Too much tooling for alpha; copy-based adoption has lower friction |
