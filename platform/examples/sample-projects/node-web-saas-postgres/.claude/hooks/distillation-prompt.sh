#!/usr/bin/env bash
# NOTE: This is an auto-harness sample-project file (reference implementation).
# If you copy this file into your own project, replace the SPDX/copyright
# header below with your own — running
# `bash platform/bootstrap/set-consumer-headers.sh` from your project root
# after the copy will do this for you.
#
# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
# Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
#
# distillation-prompt.sh — Claude Code Stop hook for cycle-end distillation.
#
# Reference implementation of PRD-0004 FR-006/FR-007, upgraded per PRD-0035
# (OPP-0053 Layer 2). Emits a structured distillation prompt when the current
# branch carries distillation-worthy work (new/modified ADR, OPP, module
# manifest, or active-module catalog change relative to main) and no knowledge
# destination has been touched in the same branch yet. Silent otherwise — so it
# does not fire on every Stop turn, only at end-of-session-on-a-feature-branch-
# with-work.
#
# PRD-0035 advances the hook from *remind* to *scaffold*: alongside the prompt it
# emits an ADR-0002-shaped INERT stub (six fields, Context + Contributed-by date
# pre-filled from git context, judgement fields left as [[TOKEN]] fill-points),
# and — Option B — persists a copy to a gitignored .claude/drafts/ file. The stub
# is inert by construction: its [[CONFIDENCE]]/[[SEVERITY]] tokens are non-enum
# (so validate-observation-hygiene rejects an unfilled stub) and strict-uppercase
# (so validate-placeholders rejects it too). See the SYNC NOTE by the stub.
#
# Installation:
#   1. Copy this script to .claude/hooks/distillation-prompt.sh in your
#      consumer project and `chmod +x` it.
#   2. Register it in .claude/settings.json under hooks.Stop:
#
#        "hooks": {
#          "Stop": [
#            {
#              "matcher": "*",
#              "hooks": [{ "type": "command", "command": ".claude/hooks/distillation-prompt.sh" }]
#            }
#          ]
#        }
#
#   3. The hook fires on every Stop event but only emits when the
#      branch-vs-main diff actually warrants distillation — see
#      `should_prompt` below.
#
# Behavior:
#   - Exits 0 always (informational; never blocks the agent)
#   - Writes the prompt to stdout in a format Claude Code surfaces in the
#     conversation
#   - Writes a one-line audit entry to .claude/logs/distillation.log
#     each time the prompt fires (for traceability)
#   - Falls back gracefully when git or the expected refs are unavailable
#     (e.g., shallow checkouts, detached HEAD) — exits silent rather than
#     emitting noise
#
# Trigger signal set (matches knowledge-capture/module.yaml companion
# rule #4 — keep these in sync if the rule's triggerPaths change):
#   - ^docs/adr/ADR-                              (new/modified ADR)
#   - ^docs/opportunities/OPP-                    (new/modified OPP)
#   - ^platform/.+/module\.yaml$                  (new/modified module
#                                                  anywhere under
#                                                  platform/ — profiles/,
#                                                  agents/, or kernel/)
#   - ^harness\.manifest\.yaml$                   (catalog change)
#
# Satisfier signal set (silent if any are touched on the branch):
#   - ^docs/knowledge/shared-observations\.md$
#   - ^docs/operating-principles\.md$
# (Pre-ADR-0014 the set also included ^docs/knowledge/distilled-learnings\.md$;
#  that destination was sunset 2026-05-25 and consolidated into
#  operating-principles.md.)
#
# Workflow reference:
#   platform/workflow/cycle-end-distillation.md
#
# Spec source:
#   docs/requirements/PRD-0004-distillation-triggers.md (FR-006/FR-007)

set -euo pipefail

# Resolve base branch. Most projects use 'main'; allow override via env.
BASE_BRANCH="${HARNESS_BASE_BRANCH:-main}"

# Silent-exit helper for any case where we cannot reliably determine
# branch state (detached HEAD, shallow clone without base, non-git dir).
silent_exit() { exit 0; }

# Must be inside a git work tree.
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  silent_exit
fi

# Must have a current branch (skip if detached HEAD).
CURRENT_BRANCH="$(git symbolic-ref --quiet --short HEAD 2>/dev/null || true)"
if [[ -z "$CURRENT_BRANCH" ]]; then
  silent_exit
fi

# If we're already on the base branch, nothing to distill (no PR scope).
if [[ "$CURRENT_BRANCH" == "$BASE_BRANCH" ]]; then
  silent_exit
fi

# Verify the base ref exists locally; bail silently if not (e.g., shallow
# clone without the base branch fetched).
if ! git rev-parse --verify --quiet "$BASE_BRANCH" >/dev/null 2>&1; then
  silent_exit
fi

# Collect changed files on this branch relative to base.
CHANGED_FILES="$(git diff --name-only "$BASE_BRANCH"...HEAD 2>/dev/null || true)"
if [[ -z "$CHANGED_FILES" ]]; then
  silent_exit
fi

# Detect distillation-worthy triggers in the changed-files list.
TRIGGERS="$(echo "$CHANGED_FILES" | grep -E \
  '^(docs/adr/ADR-|docs/opportunities/OPP-|platform/.+/module\.yaml$|harness\.manifest\.yaml$)' \
  || true)"

if [[ -z "$TRIGGERS" ]]; then
  # No distillation-worthy work on this branch — quiet exit.
  silent_exit
fi

# Detect whether any satisfier has already been touched (rule pre-satisfied).
# Pre-ADR-0014 this regex also matched docs/knowledge/distilled-learnings.md;
# that destination was sunset and consolidated into operating-principles.md.
SATISFIERS="$(echo "$CHANGED_FILES" | grep -E \
  '^docs/(knowledge/shared-observations\.md|operating-principles\.md)$' \
  || true)"

if [[ -n "$SATISFIERS" ]]; then
  # Rule already satisfied on this branch — no nag.
  silent_exit
fi

# Gather session context to embed in the prompt.
COMMIT_LOG="$(git log --oneline "$BASE_BRANCH"..HEAD 2>/dev/null | head -10 || true)"
TIMESTAMP="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
SESSION="${CLAUDE_SESSION_ID:-unknown}"

# Audit-log the firing so reviewers can correlate prompts with outcomes.
mkdir -p .claude/logs
echo "$TIMESTAMP  session=$SESSION  branch=$CURRENT_BRANCH  triggers=$(echo "$TRIGGERS" | wc -l | tr -d ' ')" \
  >> .claude/logs/distillation.log

# ---- Ambient auto-capture (PRD-0035): scaffold a schema-shaped INERT stub ----
# Advance this hook from *remind* to *scaffold*: pre-pour the ADR-0002 shape so
# the agent fills judgement fields into a correct skeleton instead of recalling
# the schema. The stub is inert by construction — its [[CONFIDENCE]]/[[SEVERITY]]
# tokens are non-enum values (so validate-observation-hygiene.sh rejects an
# unfilled stub) AND strict-uppercase [[A-Z0-9_]] tokens (so validate-placeholders.sh
# rejects it too) — it can never satisfy the very check it stands in for.
#
# SYNC NOTE: the field set + enum hints below mirror ADR-0002 and
# validate-observation-hygiene.sh (Confidence ∈ {low, medium, high};
# Severity ∈ {informational, governance-relevant, architectural, risk-bearing}).
# Keep them aligned if either changes — same discipline as the trigger-set
# sync note against knowledge-capture/module.yaml above.
DATE_ONLY="$(date -u +%Y-%m-%d)"
TRIGGERS_INLINE="$(echo "$TRIGGERS" | awk '{printf "%s%s", sep, $0; sep=", "}')"

STUB="$(cat <<STUB_EOF
<!-- AUTO-CAPTURE STUB (PRD-0035). Replace every [[TOKEN]]. Confidence is one of: low, medium, high. Severity is one of: informational, governance-relevant, architectural, risk-bearing. Move the filled block into docs/knowledge/shared-observations.md. Until filled it fails validate-observation-hygiene and validate-placeholders by design. -->
### [[OBSERVATION_HEADING]]

- **Context:** On branch $CURRENT_BRANCH this session changed: $TRIGGERS_INLINE (refine as needed).
- **Observation:** [[OBSERVATION]]
- **Implication:** [[IMPLICATION]]
- **Confidence:** [[CONFIDENCE]]
- **Severity:** [[SEVERITY]]
- **Contributed by:** [[YOUR_NAME_OR_HANDLE]], $DATE_ONLY
STUB_EOF
)"

# Option B: also persist the stub to a gitignored draft file (best-effort —
# degrades to stdout-only if .claude/ is unwritable, preserving exit-0-always).
# In a consumer project the standard .claude/ gitignore covers .claude/drafts/;
# in this sample project the harness root .gitignore re-ignores
# platform/examples/sample-projects/*/.claude/drafts/.
DRAFT_POINTER="(no draft file written — .claude/ was not writable; copy the stub above)"
if mkdir -p .claude/drafts 2>/dev/null; then
  DRAFT_FILE=".claude/drafts/distillation-$(date -u +%Y%m%dT%H%M%SZ).md"
  if printf '%s\n' "$STUB" > "$DRAFT_FILE" 2>/dev/null; then
    DRAFT_POINTER="A copy was scaffolded to \`$DRAFT_FILE\` — fill it and move it into the ledger."
  fi
fi

# Emit the structured prompt. Format is human-readable markdown so it
# reads well when Claude Code surfaces it in the conversation context.
cat <<EOF
---

## Cycle-end distillation prompt (PRD-0004)

This branch (\`$CURRENT_BRANCH\`) carries **distillation-worthy work** but
no knowledge destination has been touched yet. Before opening the PR, run
the cycle-end distillation pass.

### Trigger signals on this branch

\`\`\`
$TRIGGERS
\`\`\`

### Recent commits on this branch

\`\`\`
$COMMIT_LOG
\`\`\`

### What to distill

Pick the destination that matches the shape of the learning:

- **\`docs/knowledge/shared-observations.md\`** — single-data-point
  insight from this specific work (default; most common choice)
- **\`docs/operating-principles.md\`** — durable how-this-project-works
  truth applicable to all future work (also the curated longitudinal
  destination per ADR-0014)

### Decision tree + anti-patterns

See \`platform/workflow/cycle-end-distillation.md\` for the satisfier
decision tree, composition with existing rules, and anti-patterns
(cargo-cult observations, distillation-fatigue avoidance).

### Note

The cycle-end companion rule on \`management/knowledge-capture\` will
also fire at PR boundary if the satisfier is missing — this hook is the
in-session reminder; the rule is the floor.

### Or start from this pre-shaped stub (PRD-0035 auto-capture)

Fill every \`[[TOKEN]]\` — all six ADR-0002 fields — then move the block
into \`docs/knowledge/shared-observations.md\`. It is **inert until filled**:
the \`[[CONFIDENCE]]\` / \`[[SEVERITY]]\` tokens fail both
\`validate-observation-hygiene\` (non-enum values) and \`validate-placeholders\`
(strict-uppercase tokens), so it cannot merge or masquerade as a real
observation until you complete it.

\`\`\`markdown
$STUB
\`\`\`

$DRAFT_POINTER

---
EOF

exit 0
