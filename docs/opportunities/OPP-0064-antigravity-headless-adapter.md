<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0064 — AntiGravity headless (`agy`) CLI: correct the stale "no headless CLI" claim + a non-native adapter

**Status:** proposed
**Owner:** @unclenate · **Created/Updated:** 2026-09-16
**Confidence:** high (F1 — the doc staleness is confirmed against AntiGravity's own headless docs and the
`google-antigravity/antigravity-cli` issue tracker); medium (F2/F3 framing is sound); low-to-medium (F4 — the
exact adapter argv is a live-run detail, and the official docs already **contradict** several of the reported
specifics; must be confirmed against a live `agy` before implementation)
**Parent:** PRD-0039 / OPP-0060 (`management/agent-coordination` non-native local-CLI adapter)

## Thesis

The `management/agent-coordination` reference material uses **AntiGravity as its canonical "no headless CLI /
IDE-only" example** in at least five tracked places. That is now **factually false**: AntiGravity ships a
headless CLI, `agy`, with a non-interactive print mode (`agy -p "<prompt>"` / `--print` / `--prompt`),
documented on AntiGravity's own site and maintained in the public `google-antigravity/antigravity-cli`
repository. The stale claim should be corrected (a §10-inward doc-honesty fix — the docs assert an external
fact that has changed), the headless-permission taxonomy it anchored should be enriched, and a non-native
`agy` adapter should be *designed* — but the adapter's exact invocation is a live-CLI detail this record does
**not** pretend to have verified, because the vendor's own docs conflict with the field report on several
points (see the verification table below).

## Findings

### F1 — the "AntiGravity has no headless CLI (IDE-only)" claim is stale *(DOC-HONESTY FIX — confirmed)*

Confirmed on disk, the claim appears at:

- `reference/agent-coordination/README.md:70` — "**Antigravity** — no headless CLI (IDE-only)"
- `reference/agent-coordination/README.md:55` — the verified-CLI matrix dated "headless `--help`, 2026-08-31"
- `docs/coordination/adapter-contract.md:99` — "No headless CLI → no adapter (e.g. an IDE-only [vendor])"
- `docs/opportunities/OPP-0060-cli-transport-adapter.md:49` — "Antigravity — ❌ no headless CLI found (IDE-only)"
- `docs/knowledge/shared-observations.md:3595` — "one vendor (IDE-only) has no headless CLI at all"

**Proposed fix:** replace "no headless CLI" with the accurate statement that `agy` has a headless `-p` mode
whose *permission model collapses headlessly* (F2), so reach is bounded not by the absence of a CLI but by how
the CLI models permissions without a TTY. Re-date the verified matrix. This is a §10-inward correction of the
kind #207 shipped (the harness's own docs must not carry a stale external claim).

### F2 — a third headless-permission archetype for the constraint-1 taxonomy *(ENRICHMENT — sound)*

The adapter-contract's permission taxonomy currently cites two archetypes; `agy` is a clean third:

1. **Sandbox-tiered** (Codex) — `-s read-only` / `-s workspace-write` map ~1:1 to trust tiers.
2. **Forced-broad** (Copilot) — non-interactive forces `--allow-all-tools`; no read-only headless tier.
3. **Prompt-collapsing** (AntiGravity) — a permission-*prompt* model that cannot prompt headlessly collapses
   to deny-all (default) or allow-all (`--dangerously-skip-permissions`). A `permissions.allow` allowlist
   exists in config but is reported finicky, and issue [#548] documents `--print` ignoring it entirely.

The value of recording all three is that **the mitigation differs**: forced-broad has no lever;
prompt-collapsing has a partial one (the config allowlist, once it works). Like Copilot, `agy` has no scoped
read-only headless tier — the same "declare the gap via `capabilities`" conclusion, a different mechanism.

### F3 — judge headless success on OUTPUT, not exit code *(ROBUSTNESS RULE — sound, and bug-motivated)*

AntiGravity's headless docs state a run that fails to produce a response exits **non-zero**. In practice the
issue tracker documents the opposite failure mode: [#408] — `--print` exits **0 while writing nothing to
stdout** when output is piped/redirected (non-TTY), and [#318] — `-p` **hangs indefinitely** in non-TTY
environments. So the documented contract and the real behavior disagree, which is exactly why a runner must
not trust the exit code.
**Proposed rule** (for the non-native adapter section + the `cli_runner` contract): *a runner treats an empty
or error-only capture as a `block` regardless of exit status; some vendors exit 0 on failure, and some hang —
bound every headless invocation with a timeout.*

### F4 — an `agy` non-native adapter *(DESIGN-ONLY — implementation deferred pending a live run)*

Propose an `agy` branch in `reference/agent-coordination/cli_invokers.py`, parallel to Copilot: a
tier-2-floored CLI (below tier 2, `build_argv` refuses rather than emit a broad-permission command for a
read-only cap), `--dangerously-skip-permissions` as the only reliable headless tool mode, optional `--model
<slug>`, Tier ≥4 human-gated/refused; and flip the existing `test_cli_invokers.py:119` assertion that
`build_argv("antigravity", …)` refuses.

**This finding is NOT ready to implement.** The field report specified the print flag as `--print=<task>`
(=-bound, greedy), but AntiGravity's official headless docs show the value is **space-separated**
(`agy -p "<prompt>"` — `-p` / `--print` / `--prompt` take a following value). The report's `--mode plan`
headless-stall and `--add-dir <cwd>` are **not documented** in the headless section. The C1-safe argument
binding (how the untrusted task is kept from separating into a flag — the whole point of the
[[project_agent_coordination]] `build_argv` gate) depends on which form is real. **Resolve against a live
`agy` run before writing the adapter**, then choose the binding (`=`-join vs an explicit end-of-options
`--` vs the vendor's own prescribed form).

## Verification table (peer report vs AntiGravity's own docs / issue tracker)

| Reported specific | Primary-source finding | Status |
| ----------------- | ---------------------- | ------ |
| Headless `agy -p`/`--print` exists | Documented on AntiGravity's headless docs page; `google-antigravity/antigravity-cli` repo | **Confirmed** |
| `--dangerously-skip-permissions` auto-approves all | Documented | **Confirmed** |
| `--model <slug>` | Documented | **Confirmed** |
| `permissions.allow` config allowlist | Documented; issue [#548] `--print` ignores it | **Confirmed (+ known bug)** |
| Exit 0 on failure / no output | Docs say fail→non-zero; issue [#408] shows exit-0-empty when piped | **Bug-confirmed, contradicts docs** |
| `--print=<task>` (=-bound) | Docs show space-separated `-p "<prompt>"` | **Contradicted — resolve live** |
| `--mode plan` stalls headless | Not documented in headless section | **Unconfirmed** |
| `--add-dir <cwd>` | Not documented in headless section | **Unconfirmed** |

## Provenance & independent-verification note

**Field-reported 2026-09-16** via a peer coordinator session that drove a live `agy`, relayed here. **The
peer's draft was not used as a source** (it resided under a do-not-publish path); instead the load-bearing
fact was **independently web-verified against AntiGravity's own headless documentation and the public
`google-antigravity/antigravity-cli` issue tracker** (issues [#318], [#408], [#548] corroborate the
hang / exit-0-empty / permissions-ignored behavior). The core claim (F1) is confirmed; several of the peer's
exact adapter specifics are **contradicted by the vendor docs** (tabulated above) and are carried as pending a
live run, per [[feedback_peer_handoff_verification]] and the OPP-0060 / OPP-0062 precedent (a peer's live-run
details are re-derived, not trusted). Credited generically; no private names/hostnames carried into this
record.

## Open questions

1. **Bundle or split** — ship the F1 doc-correction now (it is confirmed) and defer F4, or hold F1 until F4's
   live-run confirmation so the corrected text and the adapter land coherently?
2. **Argv form** (F4) — `=`-bound vs space-separated vs `--` end-of-options; resolve against a live `agy`.
3. **Existence of `--mode plan` / `--add-dir`** headless — confirm or drop from the adapter surface.
4. **Exit-code posture** — make "empty/error-only capture ⇒ block, ignore exit status" the `cli_runner`
   default for all vendors, or an `agy`-specific note?

## Neighbors

- **PRD-0039 / OPP-0060** (parent) — the non-native local-CLI adapter this extends; `agy` fills the slot
  OPP-0060 explicitly left open for AntiGravity ("keep Antigravity out until a headless surface exists" — the
  surface now exists).
- **OPP-0062** — sibling record whose external-spec claims are likewise held pending primary confirmation; the
  same verify-against-the-primary discipline.
- [[project_agent_coordination]] — the `build_argv` caps-never-grants gate F4's argument binding must satisfy.
- [[project_protocol_layer_governance]] — the cross-vendor CLI landscape this adapter participates in.

## Disposition

Design-only, `proposed`. The F1 doc-correction may proceed on acceptance (confirmed); F2/F3 are documentation
enrichments to the adapter-contract; **F4 implementation is deferred pending a live-`agy` confirmation of the
argv form and the undocumented flags.** Advancing to `accepted` requires a decision on the four open
questions, above all the bundle-or-split call.

<!-- Reference links (AntiGravity's own issue tracker, cited as primary-source corroboration) -->
[#318]: https://github.com/google-antigravity/antigravity-cli/issues/318
[#408]: https://github.com/google-antigravity/antigravity-cli/issues/408
[#548]: https://github.com/google-antigravity/antigravity-cli/issues/548
