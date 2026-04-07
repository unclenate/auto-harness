#!/usr/bin/env bash
# log-command.sh — Claude Code audit trail hook
#
# This hook fires before every tool call Claude Code makes. It writes a
# timestamped log entry to .claude/logs/audit.log for traceability.
#
# Installation:
#   Reference this script in .claude/settings.json under hooks.preToolUse:
#
#     "hooks": {
#       "preToolUse": [
#         {
#           "matcher": "*",
#           "hooks": [{ "type": "command", "command": ".claude/hooks/log-command.sh" }]
#         }
#       ]
#     }
#
# Environment variables provided by Claude Code at hook invocation:
#   CLAUDE_TOOL_NAME     — the tool being called (e.g., "Bash", "Edit", "Write")
#   CLAUDE_SESSION_ID    — unique session identifier
#   CLAUDE_HOOK_EVENT    — event type (preToolUse | postToolUse)
#
# The hook exits 0 to allow the tool call to proceed. To block a tool call,
# exit non-zero with a message on stderr.
#
# Harness trust tier context:
#   This hook provides a Tier 3 audit trail (workspace-level traceability).
#   Tier 4+ operations (git push, env changes) require human confirmation
#   separately — this hook logs them but does not gate them.

set -euo pipefail

LOG_DIR=".claude/logs"
LOG_FILE="$LOG_DIR/audit.log"

mkdir -p "$LOG_DIR"

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
TOOL="${CLAUDE_TOOL_NAME:-unknown}"
SESSION="${CLAUDE_SESSION_ID:-unknown}"
EVENT="${CLAUDE_HOOK_EVENT:-preToolUse}"

echo "$TIMESTAMP  session=$SESSION  event=$EVENT  tool=$TOOL" >> "$LOG_FILE"

exit 0
