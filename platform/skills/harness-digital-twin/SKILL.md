---
name: harness-digital-twin
description: "Use for tasks involving digital twins, simulation, scenarios, world state, run logs, model/agent registries, data provenance, geospatial/city/infrastructure models, AI-datacenter or operational twins, or scenario manifests. Enforces maturity honesty, world/scenario/run separation, provenance, uncertainty disclosure, and publication boundaries for projects governed by the management/digital-twin overlay."
license: Apache-2.0
compatibility: For any Agent Skills-compatible client. The target project should activate management/digital-twin and carry docs/twin/twin-profile.md.
metadata:
  harness-module: management/digital-twin
  format-version: "1.1"
---

> For human developers: this skill guides agents working on scenario-driven /
> digital-twin projects. It does not run simulations; it governs them.

---

## Role and Goal

Govern a digital-twin / scenario-runtime project so it is reproducible,
honest about maturity, and safe to publish. Do not let visualization substitute
for simulation; do not treat LLM output as simulation source-of-truth.

## Always do, in order

1. **Classify maturity** (model → shadow → prototype → operational → control-loop)
   and record it in `docs/twin/twin-profile.md`. Do not overclaim.
2. **Separate world / scenario / run state.** Never mutate canonical world state
   to test a scenario — branch it, run against the branch, log the run.
3. **Require source-data provenance** (version, asOf, confidence) — an unversioned
   dataset is not reproducible.
4. **Require a scenario manifest** carrying datasets, assumptions (confidence +
   sensitivity), models/agents, outputs, uncertainty, and provenance.
5. **Require a model/agent registry** — declare deterministic/probabilistic/
   LLM-assisted and whether LLM is allowed; LLMs are not source-of-truth.
6. **Require a run log** (append-only JSONL minimum).
7. **Require uncertainty disclosure** — prefer "likely range X–Y; sensitivity Z;
   confidence medium" over single-point predictions.
8. **Require a publication boundary + review gate** before any public or
   high-impact output (Gemini Trust + Purpose).

## Standards

Conform to the interoperability/digital-thread spine (ISO 23247, ISO/IEC 30173,
Asset Administration Shell, DTDL, W3C WoT, ISO 10303 STEP/AP242, QIF) and the
Gemini Principles. Cite published standards as normative, emerging as emerging.
