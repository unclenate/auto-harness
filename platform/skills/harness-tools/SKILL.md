---
name: harness-tools
description: "Use when invoking MCP developer tools (Linear, Slack, Google Calendar, Gmail, Canva, Ahrefs, Similarweb) in a harness-governed project. Covers trust tier requirements per tool, Linear as the artifact backing store for harness governance docs, Slack as the companion-rule notification surface, and analytics tools under read-only tier policy."
license: Apache-2.0
compatibility: "For Claude Code and OpenClaw sessions with MCP tool integrations active. For projects with agents/openclaw declared in harness.manifest.yaml."
metadata:
  harness-module: agents/openclaw
  format-version: "1.0"
---

# Harness Tools

This skill governs how MCP developer tools are used within a harness-governed project.
Tool use is not exempt from the trust tier model — every action taken via an MCP integration
falls into a tier and must be authorized accordingly.

## Trust Tier Map

| Tool | Tier 0 (read) | Tier 2 (workspace write) | Tier 3 (shared state / externally visible) |
| ---- | ------------- | ------------------------ | ------------------------------------------- |
| Linear | Read issues, projects, milestones, docs, labels | Create/edit issues, docs, comments | Change status affecting team, close/archive, reassign |
| Slack | Read channels, threads, search | — | Send messages, create canvases, schedule sends |
| Google Calendar | Read events, find free time | — | Create/modify events, send invites |
| Gmail | Read email | — | Send email |
| Canva | Read designs, brand kits, thumbnails | Create/edit designs in workspace | Publish or share designs externally |
| Ahrefs | All API reads | — | — |
| Similarweb | All API reads | — | — |

**Rule:** Tier 3 actions affect other people or are permanently visible. Never take Tier 3
actions without explicit human instruction in the current session. "I think the human would
want this sent" is not authorization.

## Linear as the Harness Artifact Backend

Linear documents and milestones can serve as the live backing store for harness governance
artifacts. Use this mapping when a project tracks work in Linear:

| Harness artifact | Linear equivalent |
| ---------------- | ----------------- |
| `docs/project/milestones.md` | Linear milestones on the project |
| `docs/adr/ADR-NNNN-slug.md` | Linear document in the project |
| `docs/requirements/PRD-NNNN-slug.md` | Linear document in the project |
| `docs/project/change-log.md` | Linear issue or document with change history |
| `docs/product/requirements.md` | Linear project description or linked document |

**Sync discipline:** The checked-in file in `docs/` is the canonical record. Linear is the
working surface. When a decision is made in Linear, update the corresponding `docs/` artifact
and commit it. The harness validates `docs/` — not Linear.

**Creating a Linear document for an ADR:**

1. Read the current ADR template (`platform/templates/adr.md`)
2. Draft the content locally and fill all `[[PLACEHOLDER_NAME]]` fields
3. Create the Linear document (Tier 2 — workspace write)
4. Write the filled ADR to `docs/adr/ADR-NNNN-slug.md` (Tier 2 — file edit)
5. The companion rule requires `docs/project/change-log.md` to also be updated

**Creating a Linear milestone:**

1. Milestones in Linear should match the milestone names in `docs/project/milestones.md`
2. Creating the Linear milestone is Tier 2 (workspace write)
3. Keep the `docs/project/milestones.md` file as the committed record

## Slack as Companion-Rule Notification Surface

Slack is useful for notifying the team when a harness companion rule fires — when a
sensitive path changes and a companion artifact must also change.

**Pattern:**

1. Detect that a companion rule trigger path has changed (e.g., `AGENTS.md` was edited)
2. Identify the required companion (e.g., an ADR or `docs/operating-principles.md`)
3. Surface the requirement to the human in the current session first
4. If the human directs you to notify the team in Slack, compose the message and show it
   for approval before sending (Tier 3)

**Never:**
- Auto-send Slack notifications without human approval
- Post diffs or code snippets to channels without explicit instruction
- Send to channels you haven't confirmed are appropriate for this project

## Analytics Tools — Ahrefs and Similarweb

Both are Tier 0 read-only tools. They inform product and requirements documents but do
not directly modify any harness artifact.

**Ahrefs:**
- Monetary values (traffic value, cost metrics) are returned in USD cents — divide by 100
  before displaying
- Use site explorer metrics to inform competitive landscape sections in
  `docs/product/problem-statement.md`
- Use keyword data to inform audience and use-case sections in `docs/product/requirements.md`
- Run the `doc` tool before using an Ahrefs endpoint for the first time in a session

**Similarweb:**
- Requires an authentication flow before first use in a session
- Traffic and audience data belongs in persona documents (`docs/product/personas.md` or
  equivalent) and competitive analysis sections of requirements

## Calendar and Email — Scheduling Review Gates

Google Calendar and Gmail are Tier 3 tools — externally visible.

**Google Calendar use cases:**
- Schedule review gate windows as calendar blocks
- Invite stakeholders to milestone reviews
- Find free time for unblocking conversations

**Gmail use cases:**
- External stakeholder notifications about milestone changes or review gate outcomes
- Follow-up on decisions made outside the project's communication channels

**Rule for both:** Show the human the composed event or email for review before sending.
Do not infer that because a milestone date exists in `docs/project/milestones.md`, the human
wants a calendar event created — ask first.

## Canva — Diagrams and Presentation Assets

Canva is Tier 2 for workspace creation and Tier 3 for publishing or sharing.

**Use cases:**
- Architecture diagrams to accompany an architecture overview artifact (e.g., `docs/architecture/overview.md` if the project has one)
- Slide decks for milestone reviews and stakeholder reports
- Visual assets for product documents

**Design governance:**
- Designs created in Canva are not harness artifacts — they are supporting material
- The harness artifact (the `.md` file) is canonical; the Canva design is a visual rendering
- When exporting or sharing a Canva design externally, treat it as Tier 3 — get explicit
  human sign-off before publishing, as exports may be cached or indexed

## Stop Conditions

Halt and surface to a human when:

- A Tier 3 action (send message, create event, send email, publish design) is about to
  execute without explicit instruction in the current session
- A tool call would expose project content (code, decisions, unreleased plans) outside the
  project team
- A tool returns an error that could indicate a permission, auth, or rate-limit issue —
  do not retry blindly
- An analytics result (Ahrefs, Similarweb) is being used to make a product or scope
  decision — surface the data to the human rather than deciding autonomously

## Producer vs Consumer Roles

This skill governs the **consumer** role — projects that use third-party MCP
developer tools (the seven curated in `TOOLS.md`: Linear, Slack, Calendar,
Gmail, Canva, Ahrefs, Similarweb).

When a project **ships its own MCP server** (an npm/pip package, a hosted
service, an internal MCP endpoint), the producer-side discipline lives in a
sibling module and skill:

- Architecture overlay: `platform/profiles/architectures/mcp-server/`
- Template family: `platform/templates/mcp/`
- Producer-side skill: `platform/skills/harness-mcp/SKILL.md`
- Operator workflow: `platform/workflow/mcp-server-build.md`
- Reference layout: `platform/examples/sample-projects/mcp-server-starter/`

The two roles use the same trust-tier vocabulary applied to opposite sides
of the wire: this skill helps you reason about the tier of a tool *you call*;
`harness-mcp` helps you reason about the tier consumers should treat tools
*you expose* as. A project can be in both roles simultaneously — load both
skills when the same project ships an MCP server AND consumes the developer
MCP subset.

Decision rationale and the exposed-governance path (auto-harness governance
itself reachable via MCP) are in `docs/adr/ADR-0008-mcp-awareness.md` and
`docs/opportunities/OPP-0003-mcp-producer-and-exportable-governance-via-mcp.md`.

## Installing This Skill

```bash
cp -r platform/skills/harness-tools .agents/skills/
# or for Claude Code specifically:
cp -r platform/skills/harness-tools .claude/skills/
```
