<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0014 — Polyglot Companion-Services Pattern (`domains/polyglot-services`)

**Status:** proposed
**Owner:** @unclenate
**Created:** 2026-05-24
**Last Updated:** 2026-05-24
**Confidence:** medium

---

## Thesis

The harness's polyglot model — captured in `stacks/node-typescript` +
`stacks/python` combinability — assumes one of two shapes: (a) frontend
in one language, backend in another; or (b) microservices each in their
own service repo, independently deployed.

OpenEMR exhibits a third pattern the harness doesn't model: the
**companion service**. A primary-language application (PHP) embeds a
secondary-language helper (Node.js) for a single specific service surface
(C-CDA XML generation), invoked via a thin gateway, run as a separate
process but inside the same deployment unit. Different language, different
runtime, same project, same repo, same deploy target.

Companion services are visible in the wild well beyond OpenEMR — Rails
apps with embedded Node services for esbuild / asset compilation; Django
apps with Python-launched Lua workers for log processing; Go services with
Python sidecar for ML inference. The pattern is common enough to warrant
a domain module that records the contract.

Propose `domains/polyglot-services` — a module that governs:

- The gateway interface (process invocation, IPC channel, error contract)
- The companion service's lifecycle (startup ordering, supervision, restart)
- Build / dependency isolation (the companion has its own
  `package.json` / `requirements.txt` / `Cargo.toml` and its own
  vendor tree)
- Deployment shape (single container vs sidecar vs separate process)
- Audit / log integration (the companion's logs flow back into the
  primary app's audit trail)

Required artifact: `docs/companion-services/inventory.md` — a table of
companion services with their language, purpose, gateway pattern, and
restart policy.

## Origin / Evidence

- **Consumer project: OpenEMR (`https://github.com/openemr/openemr`).**
  Brownfield onboarding session 2026-05-24 produced a gap analysis at
  `docs/knowledge/harness-coverage-gap-analysis.md` § G4 in the
  consumer project tree.

- **Code-level evidence in OpenEMR — `ccdaservice/`:**

  ```text
  ccdaservice/
  ├── package.json              # name: "ccdaservice", workspaces, npm start → node serveccda.js
  ├── package-lock.json
  ├── serveccda.js              # the service entry point
  ├── ccda_gateway.php          # PHP-side gateway invoking the service
  ├── oe-blue-button-generate/  # workspace package
  ├── oe-blue-button-meta/      # workspace package
  ├── oe-blue-button-util/      # workspace package
  ├── data-stack/
  ├── packages/                 # additional npm workspaces
  └── utils/
  ```

  Dependencies include `libxmljs2` (XML parsing), `oe-schematron-service`
  (referenced via `github:openemr/oe-schematron-service#v2.0.2`), `xml2js`,
  `uuid`, `body-parser`. Scripts include `start`, `start:cqm`
  (`node packages/oe-cqm-service/server.js`), `start:schematron`
  (`node oe-schematron-service/app.js`). This is unambiguously a
  multi-service Node.js workspace, not a build tool.

- **OpenEMR's onboarding session bootstrap observation explicitly named
  the gap.** From the cycle-end distillation observation filed during
  the strategic-pause gap-analysis session (2026-05-24): *"ccdaservice/
  is a self-contained Node.js service with its own package.json
  (workspaces, libxmljs2, oe-schematron-service dependency, npm start
  invoking serveccda.js). It runs as a separate process and the PHP
  main app delegates to it via a gateway (ccda_gateway.php). This is a
  companion service pattern — one language per service surface — that
  the harness's polyglot model (currently: 'frontend in JS, backend in
  another language') doesn't account for."*

- **The pattern recurs outside healthcare.** Rails projects routinely
  vendor a small Node service for esbuild / jsbundling-rails. Python
  data-engineering projects often vendor a Go binary for fast
  encoding. Multi-language workspaces are common in monorepos. The
  module captures a pattern the broader ecosystem already exhibits.

- **The pattern is structurally different from microservices.** A
  microservice has its own deploy unit, its own release cadence, its
  own scaling policy. A companion service shares all of those with the
  primary application — it's a *language choice* within a single
  service, not a service boundary. The harness's existing
  `architectures/event-driven` and `architectures/api-service` modules
  cover microservice topology; neither covers companion-services.

## Why Now

- **Anchoring OpenEMR's CCDA canonization OPP.** OPP-0006 (in the
  consumer project's `candidates.md`) profiles OpenEMR's CCDA exporter
  as a downstream component. The CCDA exporter *is* the companion
  service. Without `domains/polyglot-services`, that OPP has no
  vocabulary for what the consumer is actually adopting — is it a
  library, a service, a build tool, a sidecar? "Companion service" is
  the right name once the module exists.

- **Confidence is medium because external evidence is limited.** The
  pattern is observable in OpenEMR with high confidence; the broader
  claim ("Rails + Node, Python + Go, Django + Lua") rests on common
  knowledge rather than catalogued evidence. Filing now lets the OPP
  age — if a second or third consumer project hits the same pattern
  during the next quarter, confidence upgrades and the module gets
  designed. If only OpenEMR ever exhibits it, the OPP gets disposed
  as "OpenEMR-specific, absorb into healthcare-ccda instead."

## Risks / Open Questions

- **`domains/polyglot-services` may be the wrong family.** The pattern
  is partly architectural (process topology) and partly stack-related
  (multiple languages). Whether it lives under `domains/`,
  `architectures/`, or a hybrid is a design decision deferred to PRD.

- **The pattern may already be covered by `architectures/event-driven`
  with an interpretive stretch.** A companion service invoked via
  IPC is process-boundary communication; some teams might naturally
  classify it as event-driven. Validation: read the actual
  `event-driven/module.yaml` contract and see whether companion-
  services exhibit it. Initial bias: no — event-driven implies
  queue/topic/bus topology, companion-services are direct gateway
  calls.

- **Confidence-Medium signal:** the gap is real (OpenEMR exhibits
  it; the harness has no name for it), but the priority is lower
  than the P0 gaps (G1 PHP stack, G2 SQL generalization, G3
  healthcare family). Reasonable to file now and defer
  prioritization until a second consumer project surfaces the
  pattern from a different language perspective.

- **Inventory required-artifact may be too lightweight.** A single
  `inventory.md` table may not capture the substantive concerns
  (IPC channel discipline, restart policy, supervision, log
  integration). PRD should weigh whether the module also requires
  a `docs/companion-services/contract.md` describing the gateway
  invariants, or whether that's sub-module-overhead the harness
  shouldn't impose.

## Disposition

<!-- Empty: status is proposed -->

## Promotion

<!-- Empty: not yet accepted -->

## Related

- Gap analysis source: consumer project (`openemr`) at
  `docs/knowledge/harness-coverage-gap-analysis.md` § G4
- Origin observation: consumer project (`openemr`) at
  `docs/knowledge/shared-observations.md` — "ccdaservice is a Node.js
  companion service, not a frontend build artifact" (2026-05-24)
- Pairs with: [OPP-0013](OPP-0013-domain-family-healthcare-decomposed.md)
  — the `domains/healthcare-ccda` sub-module references this pattern
- Companion OPPs filed in the same session (OpenEMR canonization):
  [OPP-0011](OPP-0011-stack-module-php.md),
  [OPP-0012](OPP-0012-data-module-relational-sql-engine-generalization.md),
  [OPP-0013](OPP-0013-domain-family-healthcare-decomposed.md),
  [OPP-0015](OPP-0015-regulated-compliance-test-kits.md),
  [OPP-0016](OPP-0016-specialist-healthcare-review-skills.md),
  [OPP-0017](OPP-0017-legacy-coexistence-template-family.md)
