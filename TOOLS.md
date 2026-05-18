<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# TOOLS.md — auto-harness

Environment-specific tool registry for OpenClaw and other AI agents. Each entry declares
what the tool does in this project's context, the trust tier required for each class of
action, and any invocation notes specific to this environment.

This file is loaded on demand, not on every turn. Keep entries accurate and concise.
Remove tools that are not active in this project.

---

## MCP Developer Tools

### Linear

- **Tier 0** — read issues, projects, milestones, documents, labels, users, teams
- **Tier 2** — create or edit issues, documents, comments, milestones (private workspace actions)
- **Tier 3** — change issue status visible to team, close/archive, assign to others (affects shared state)
- **Key uses:** issue tracking, milestone sync with harness milestones, document backing for
  ADRs and PRDs, label-based triage
- **Harness mapping:** Linear milestones ↔ `docs/project/milestones.md`; Linear documents ↔
  `docs/adr/` and `docs/requirements/`; Linear projects ↔ scope plan
- **Stop condition:** do not reassign, close, or change status on issues that affect other
  team members without explicit human direction

### Slack

- **Tier 0** — read channels, threads, user profiles, search messages
- **Tier 3** — send messages, create canvases, schedule messages (visible to others)
- **Key uses:** companion-rule change notifications, review gate pings, stakeholder updates
- **Stop condition:** never send a message without explicit human instruction; Slack actions
  are immediately visible and not reversible

### Google Calendar

- **Tier 0** — read calendars, list events, find free time
- **Tier 3** — create, update, or delete events; send invites (affects others' calendars)
- **Key uses:** schedule review gate windows, milestone target dates, stakeholder meetings
- **Stop condition:** do not create or modify events that include external attendees without
  explicit human instruction

### Gmail

- **Tier 0** — read email (after authentication)
- **Tier 3** — compose and send email (externally visible)
- **Key uses:** external stakeholder notifications, follow-up on review gate decisions
- **Stop condition:** never send email without explicit human instruction

### Canva

- **Tier 0** — read designs, thumbnails, export formats, brand kits
- **Tier 2** — create or edit designs within the workspace (private until published)
- **Tier 3** — export and publish or share designs externally
- **Key uses:** architecture diagrams, presentation assets, stakeholder reports
- **Stop condition:** do not publish or share designs externally without explicit human
  instruction; exported assets may be cached or indexed

### Ahrefs

- **Tier 0** — all API reads (site explorer, keywords, rank tracker, brand radar, GSC data)
- **Key uses:** domain metrics, keyword research, SEO health checks, competitive analysis;
  data informs `docs/product/requirements.md` and `docs/product/problem-statement.md`
- **Note:** monetary values returned in USD cents; divide by 100 for display

### Similarweb

- **Tier 0** — all API reads (web analytics, traffic sources, audience data)
- **Key uses:** competitive traffic benchmarks, audience profile for persona docs
- **Note:** requires authentication flow before first use

---

## Local Environment

<!-- Fill in environment-specific details for this machine as you discover them. -->

### SSH

<!-- Example: Main server: `ssh user@hostname` -->

### TTS

<!-- Example: Provider: Edge | Voice: en-US-GuyNeural -->

### Devices and Nodes

<!-- Example: Camera 0: node-id `abc123`, device `camera-0` -->

### Aliases and Shortcuts

<!-- Any local aliases or shortcuts not obvious from the project itself -->

---

## MCP — Producer Posture

The entries above govern MCP servers this project *consumes*. When a project
*ships* its own MCP server (npm/pip package, hosted endpoint, internal
service), see the producer-side architecture overlay
`architectures/mcp-server` (`platform/profiles/architectures/mcp-server/`),
the template family at `platform/templates/mcp/`, the `harness-mcp` skill at
`platform/skills/harness-mcp/`, and the operator workflow at
`platform/workflow/mcp-server-build.md`. A reference layout lives at
`platform/examples/sample-projects/mcp-server-starter/`. Rationale and
exposed-governance scope: `docs/adr/ADR-0008-mcp-awareness.md` and
`docs/opportunities/OPP-0003-mcp-producer-and-exportable-governance-via-mcp.md`.
