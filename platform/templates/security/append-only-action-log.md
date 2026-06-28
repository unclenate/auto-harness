<!--
Copyright {{YEAR}} {{AUTHOR}} <{{AUTHOR_EMAIL}}>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of {{PROJECT_NAME}} — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Append-Only Action Log

> The operator-owned audit log that substantiates **pattern #4 (agent identity)** for
> **{{PROJECT_NAME}}**. Part of the `architectures/agent-defense-in-depth` overlay
> (PRD-0030 / OPP-0031). **Required-by-convention** when the project declares any
> autonomous (non-draft) action; a non-autonomous product may mark this not-applicable.

## Log shape

Declare the shape of the operator-owned action log. It must be append-only and
identity-tagged so every action is attributable and the history is tamper-evident.

- **Location / ownership:** <!-- TODO: where the log lives and that the operator (not the agent) owns it -->
- **Append-only mechanism:** <!-- TODO: how append-only is enforced (e.g. write-once store, hash-chained entries, no in-place edits) -->
- **Entry schema:** <!-- TODO: the fields per entry — at minimum: timestamp, agent identity, action type, target, draft-or-autonomous, outcome -->

## Identity tagging

- **Attribution:** <!-- TODO: how each entry names the agent that took the action (ties to the identity-binding section of agent-defense-in-depth.md) -->

## Snapshot & reproducibility

- **Snapshot mechanism:** <!-- TODO: how the log/state is snapshot-able so any change is reproducible (e.g. an agent-backup snapshot routine) -->

## Secret-scan gate

- **Secret-scan:** <!-- TODO: the gate that prevents secrets from landing in the log (e.g. a regex secret-scan on every snapshot/commit) -->

## Update policy

Append every autonomous action to this log with its identity attribution. When a new
action type becomes autonomous, ensure it is logged here. (Enforcement that the log is
truly append-only and complete is the `architectures/agent-defense-in-depth` v2
follow-up; v1 is the declared contract.)
