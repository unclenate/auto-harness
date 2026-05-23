<!--
Copyright [[YEAR]] [[OWNER_NAME]] <[[OWNER_EMAIL]]>
SPDX-License-Identifier: [[SPDX_LICENSE]]
-->

# MCP Tool Registry

**Owner:** [[REGISTRY_OWNER]]
**Last updated:** YYYY-MM-DD
**Module:** `architectures/mcp-server`
**Companion artifact:** `docs/mcp/server-spec.md` (server identity), `docs/mcp/risk-register.md` (risk pairing)

This document is the canonical record of every tool the MCP server exposes via
`tools/list` and `tools/call`. It is the producer-side contract with every
consumer. Adding, modifying, or removing an entry triggers the companion rule
declared in `platform/profiles/architectures/mcp-server/module.yaml` — pair the
change with a risk-register update, an ADR, or an architecture-overview refresh.

---

## Why Tier Mapping Matters Here

Auto-harness's `TOOLS.md` declares the trust tier a *consumer* should treat each
inbound MCP dev tool as. This document does the inverse: it declares, per tool
the server *exposes*, the tier the consumer should treat that tool as. That
mapping is a producer-side commitment — when the server's author writes
"Tier 3" next to a `broadcast_team_message` tool, the author is telling every
consumer "this tool is externally visible / affects shared state; do not invoke
it without explicit human authorization."

The trust-tier vocabulary:

| Tier | Name | Examples (consumer perspective when calling this tool) |
| ---- | ---- | ----------------------------------------------------- |
| 0 | Read-only | Pure reads with no side effects; results visible only to the model |
| 1 | Local analysis | Compute/derivation that touches no external state |
| 2 | Workspace mutation | Writes to the project's private workspace; reversible |
| 3 | Git-writing / shared-state | Writes to shared systems; affects other people; externally visible |
| 4 | Environment-altering | Installs, migrations, irreversible local environment changes |
| 5 | Remote / production | Production deploys, destructive operations, secrets rotation |

See `platform/core/kernel/base/trust-model.md` and the `harness-governance`
skill for the authoritative tier definitions.

**Reviewer obligation:** every tool entry must carry a one-line rationale for
its tier. Defaulting every tool to Tier 2 is a placeholder, not a tier mapping;
the review gate in the module rejects placeholder fills.

---

## Tools

### Tool: `[[TOOL_NAME]]`

| Field | Value |
|-------|-------|
| Tool name (wire) | `[[TOOL_NAME]]` |
| Display title | [[Human-readable title]] |
| Intent (one line) | [[What the tool does in plain language]] |
| Input schema | [[link to schema in src/ or inline JSON Schema]] |
| Output content types | [[text / image / resource_link / etc.]] |
| Side effects | [[none / writes to internal DB / sends external message / etc.]] |
| Consumer trust tier | **Tier [[N]]** — [[one-line rationale for this tier]] |
| Approval gating expectation | [[none / consumer-side per-call approval recommended / consumer-side allowlist required]] |
| Idempotency | [[idempotent / not idempotent — re-calling produces a new effect]] |
| Audit log expectation | [[server logs the call with arguments / consumer responsible for audit / both]] |
| Rate limit | [[none / N calls per minute per session / etc.]] |
| Out-of-scope failure mode | [[returns isError:true / throws / returns UNKNOWN content]] |

**Description shown to model (matches `tools/list` response):**

> [[Detailed natural-language description the model sees. Must be accurate
> enough that the model picks the right tool, and must not contain
> instructions that could be interpreted as prompt injection if a tool
> result is later fed back into the model.]]

**Threat-class notes:**

- **Tool poisoning risk:** [[How could this tool's description or schema be
  used to inject instructions into the model? E.g. "description names trusted
  third-party brand names — if those brand strings end up in a tool result,
  guard against the model treating the result as an instruction from that
  brand."]]
- **Prompt-injection-through-result risk:** [[If this tool returns
  attacker-controlled strings (user input, third-party API content), what is
  the project's mitigation? E.g. "the tool wraps text-content in a
  `<untrusted>` envelope and instructs the consumer's system prompt to treat
  it as data, not instructions"]]

---

### Tool: `[[ANOTHER_TOOL_NAME]]`

*(Repeat the block above for each tool the server exposes.)*

---

## Summary Table

A compact view for review. Update whenever a tool block changes.

| Tool | Tier | Side effects | Idempotent | Approval gating |
|------|------|--------------|------------|-----------------|
| `[[TOOL_NAME]]` | [[N]] | [[summary]] | [[Yes / No]] | [[summary]] |

---

## Discovery and Dynamic-Tools Posture

| Field | Value |
|-------|-------|
| Does the server declare `tools.listChanged: true`? | [[Yes / No]] |
| When does the tool list change at runtime? | [[never / on user permission change / on upstream service availability / etc.]] |
| Notification policy on change | [[server emits `notifications/tools/list_changed` within N seconds / does not emit]] |

If the tool list can change after `initialize`, the consumer needs to know
*why* it changes — silent shrinkage of the tool list during a session is a
class of bug that confuses both human users and the model.

---

## Deprecation and Removal

| Tool removal pattern | [[describe — e.g. "deprecated tools remain listed for one minor version with description prefix DEPRECATED: and are removed in the next minor"]] |

Removing a tool without warning is a breaking change for any consumer's prompt
templates or agent graphs that referenced the tool by name.

---

## References

| Resource | Path |
|----------|------|
| Server spec | `docs/mcp/server-spec.md` |
| Risk register | `docs/mcp/risk-register.md` |
| Prompt-injection test plan | `docs/mcp/prompt-injection-test-plan.md` |
| Trust tier model | `platform/core/kernel/base/trust-model.md` |
| Consumer-side tool registry pattern | `TOOLS.md` (repo root) |
| `harness-tools` skill | `platform/skills/harness-tools/SKILL.md` |
| `harness-mcp` skill | `platform/skills/harness-mcp/SKILL.md` |
| MCP server concepts (spec) | <https://modelcontextprotocol.io/docs/learn/server-concepts> |
