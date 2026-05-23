<!--
NOTE: This is an auto-harness sample-project file (reference implementation).
If you copy this file into your own project, replace the SPDX/copyright
header below with your own — running
`bash platform/bootstrap/set-consumer-headers.sh` from your project root
after the copy will do this for you.
-->

<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# AGENTS.md

Cross-agent operating rules are derived from the kernel trust model and the `agents/base`
agent pack declared in `harness.manifest.yaml`. This sample co-exists with other AI platforms
(Cursor, Windsurf, GitHub Copilot, OpenAI Codex) — `install.sh` writes the harness-managed
section between `<!-- harness-managed-section -->` markers and leaves the rest of `AGENTS.md`
to the consumer.

When the PRD or the interview/spec prompt changes, follow the companion-rule contract from
the `interview-driven` overlay: refresh the downstream plan or prompt in the same commit
so AI agents do not work from a stale derivation.
