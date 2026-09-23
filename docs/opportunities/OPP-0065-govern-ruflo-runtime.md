<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0065 — Govern the ruvnet/claude-flow (`ruflo`) runtime as a non-native adapter + positioning artifact

**Status:** proposed
**Owner:** @unclenate · **Created/Updated:** 2026-09-23
**Confidence:** high (the layer classification and the license/footprint facts are agent-verified against
ruflo's own repo, README, LICENSE, and package.json); medium (the exact adapter scope and whether to publish
the positioning artifact externally are review choices)
**Parent:** OPP-0060 (non-native local-CLI adapter) / OPP-0056 (ACP governance-positioning precedent) / PRD-0039

## Thesis

`ruflo` (ruvnet/rUv) is **`claude-flow` rebranded and rebuilt** — the npm package is literally `claude-flow`
(v3.44.0, MIT), the CLI binary is `claude-flow`, docs invoke `npx ruflo@latest`. It is a **runtime agent
meta-harness**: it spawns and coordinates swarms of 100+ agents around Claude Code / Codex, with vector memory
(AgentDB/HNSW), neural self-learning (SONA / ReasoningBank), federation (mTLS / ed25519), WASM sandboxes, and
an MCP server (~210–314 tools). Its own framing: *"Agent = Model + Harness."* This is the
LangGraph / CrewAI / AutoGen genre — a **runtime execution layer**, the deliberate opposite of auto-harness's
**governance** genre ([[project_harness_genre]]).

Classifying by LAYER before judging competitor-vs-complement (the doctrine that resolved the ACP analysis in
[[project_acp_integration]]) resolves this the same way: **ruflo is a governed *target*, not a competitor and
not a dependency to absorb.** ruflo's own "governance-flavored" features — *behavioral trust scoring* (a
numeric success/uptime/threat/integrity reputation), *compliance audit modes* (HIPAA/SOC2/GDPR), an AIDefence
prompt-injection plugin — are **algorithmic / security-oriented, with no evident human-ratified policy or
human-approval gate.** That is precisely the Layer-4 governance auto-harness supplies and ruflo does not
([[project_protocol_layer_governance]]).

This OPP proposes two moves, and explicitly scopes OUT a third.

## The two proposed moves

### Move 1 — govern `ruflo` as a non-native runtime (near-zero new primitives)

ruflo's surfaces are the exact shapes auto-harness already drives:

- Its **headless CLI** (`claude-flow` / `npx ruflo`, ~26 commands) is the same shape the **non-native CLI
  adapter** (OPP-0060, `cli_invokers.py` / `cli_runner.py`) already drives for Codex / Copilot / Grok — so
  `build_argv` gates a `ruflo` invocation under the trust-tier ceiling, Tier ≥4 human-gated, the task bound as
  un-shell-interpreted data.
- Its **MCP server** (`claude mcp add … npx ruflo mcp start`, ~210–314 tools) is what the **ACP governance
  bridge** (OPP-0056 / PRD-0037/0038) fronts — classify each ruflo tool call → trust tier → the
  `request_permission` option set, block Tier 5 at the seam.

So "govern ruflo" is a *reference adapter + a tier-policy mapping*, not new machinery. It **dogfoods the whole
Layer-4 thesis**: auto-harness supplying the human-authorization governance a popular runtime lacks.

### Move 2 — a positioning artifact (analog of OPP-0056)

A shareable artifact — *"auto-harness governs the ruvnet/claude-flow runtime"* — positioning the harness as
the policy/trust/audit layer the ruvnet ecosystem (large, influential, fast-moving) does not natively provide
with human authorization. Ecosystem-inducement, exactly like the ACP/JetBrains positioning play.

## Explicitly OUT of scope (the anti-goal)

**Do NOT integrate ruflo *into* auto-harness** — do not vendor it, build on it, or adopt its governance
plugins. Two reasons:

1. **Footprint inversion.** ruflo requires Node ≥20 + a WASM binary + a live web server (`express`/`ws`) +
   outbound LLM API keys, and pins several core `@claude-flow/*` deps to *alpha* builds with ~daily releases.
   auto-harness is **dependency-free at runtime** (submodule + shell/Ruby CI); absorbing ruflo would destroy
   that posture. Governance stays dependency-free; ruflo is a *governed target*, never a dependency.
2. **Duplication pocket.** ruflo ships an **ADR plugin** ("living repository" of decision records) and a
   `metaharness` that *grades agent setup 1–100* — a direct but weaker (algorithmic, not human-ratified)
   overlap with auto-harness's ADR/PRD/OPP + governance identity. Adopting those would duplicate the core with
   the inferior mechanism. auto-harness governs ruflo's *execution*; it does not import ruflo's *governance*.

## Risk notes that shape the adapter

- **Single-owner bus factor** (rUv) + **~daily alpha releases** ⇒ a fast-moving target. If pursued, govern a
  **pinned `ruflo` version**, never `main`/`@latest` — the same consumer-compat discipline OPP-0063 (F2)
  argues for renames, applied to an upstream dependency-as-target.
- All ruflo speed/accuracy figures (e.g. "1.3×–1953× faster," "89% routing") are **unverified vendor
  benchmarks** — do not cite them normatively.
- Repo popularity metrics (stars/issues) were single-sourced during analysis and conflicted across surfaces —
  treat as approximate.

## Open questions

1. **Sequence** — ship Move 1 (the governed adapter) first, Move 2 (positioning) first, or bundle? (The
   positioning artifact can precede the adapter, as OPP-0056 preceded the ACP proxy.)
2. **Tier-policy for ruflo's MCP tools** — which of the ~200+ tools map to which tiers; does swarm-spawning or
   federation cross a sensitive-path / Tier-4 boundary by default?
3. **Pin strategy** — given ~daily alpha releases, what version-pinning + upgrade-preflight cadence does the
   adapter declare (ties to the `consumer-upgrade-runbook.md` and OPP-0063)?
4. **External publication** — is the positioning artifact internal-only, or shared into the ruvnet/claude-flow
   community as an interop proposal?

## Provenance & verification note

Analysis performed 2026-09-23 via three parallel research agents (repo facts; architectural-layer positioning;
integration-risk + capability-overlap), **web-verified against ruflo's own repository, README, `LICENSE`
(MIT), `package.json` (v3.44.0), and release history.** The layer classification (runtime-execution, not
governance) and the license/footprint facts are high-confidence; vendor benchmark and popularity figures are
carried as reported and not relied upon. Internal analysis; no external claims are pending, and no private
names/hostnames are carried into this record.

## Neighbors

- **OPP-0060** (parent) — the non-native local-CLI adapter Move 1 reuses; ruflo is another governed headless
  CLI under the same gate.
- **OPP-0056 / PRD-0037/0038** (ACP) — the governance-positioning + reference-proxy precedent Move 2 and the
  MCP-seam mapping follow.
- [[project_protocol_layer_governance]] — the Layer-4 governance thesis (a runtime with algorithmic
  trust/audit but no human-authorization gate is a governed target).
- [[project_harness_genre]] — governance-not-runtime; the genre boundary that makes ruflo a complement.
- **OPP-0063** — the consumer-compat / pin-don't-track-main discipline the risk notes reuse.

## Disposition

Design-only, `proposed`. No transport, trust-tier, or control-schema change; no runtime dependency added.
Advancing to `accepted` requires a decision on the four open questions — above all the sequence (positioning
vs adapter first) and confirmation that governance stays dependency-free with ruflo as a governed target.
