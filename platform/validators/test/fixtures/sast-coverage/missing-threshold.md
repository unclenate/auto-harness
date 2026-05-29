---
tool: gosec
scanPaths:
  - ^cmd/
---

# Missing severityThreshold

Frontmatter omits `severityThreshold:`. The validator must reject —
the threshold is what makes the contract gate-able.
