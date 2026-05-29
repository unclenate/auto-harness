---
tool: semgrep
scanPaths:
  - ^src/
  - ^lib/
severityThreshold: high
---

# Valid SAST coverage fixture

Names a recommended tool, declares scanPaths, declares severityThreshold.
The validator should exit 0 in `--scan-file` mode against this file.
