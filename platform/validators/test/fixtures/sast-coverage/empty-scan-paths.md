---
tool: bandit
scanPaths: []
severityThreshold: high
---

# Empty scanPaths list

`scanPaths:` is present but empty. The validator must reject this —
declaring SAST coverage without any path is a vacuous contract.
