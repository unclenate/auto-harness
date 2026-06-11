---
name: harness-governance
description: Load the canonical auto-harness governance skill from platform/skills before changing harness governance, validators, trust tiers, companion rules, or repository operating doctrine.
---

# Harness Governance Adapter

This Claude-native skill entry is an adapter, not the source of truth.

Before acting, read the canonical skill at:

```text
platform/skills/harness-governance/SKILL.md
```

Then follow that file completely. Keep durable governance instructions in
`platform/skills/`, `HARNESS.md`, `AGENTS.md`, and the active modules declared in
`harness.manifest.yaml`. Do not maintain an independent copy of harness doctrine
inside `.claude/`.
