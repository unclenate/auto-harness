---
# Copyright [[YEAR]] [[OWNER_NAME]] <[[OWNER_EMAIL]]>
# SPDX-License-Identifier: [[SPDX_LICENSE]]
---

# Digital Twin Overview & Maturity Ladder — [[PROJECT_NAME]]

Classify the project honestly. The ladder discourages overclaiming.

1. **Digital model** — static representation of assets/places/systems.
2. **Digital shadow** — model updated from real/periodic data; not interactive.
3. **Digital twin prototype** — scenario-capable, explainable; not closed-loop.
4. **Operational twin** — live/synchronized, governed, auditable; used for decisions.
5. **Closed-loop / control twin** — can influence real-world systems; highest controls.

Required-artifact depth scales with the declared level (see `twin-profile.md`).

## Three states you must distinguish

- **Canonical world state** — the best-known current representation of reality.
- **Scenario state** — a branch/fork of world state with changed assumptions.
- **Run state** — the execution trace and outputs of one simulation/evaluation.

> Do not mutate canonical world state to test a scenario. Branch it, run against
> the branch, and log the run.

## Anti-patterns this overlay guards against

A dashboard masquerading as a twin · LLM-generated truth · unversioned datasets ·
unreproducible runs · hidden assumptions · fake precision · public/private leakage ·
no model registry · no run log · no uncertainty statement · no review gate before
public or high-impact outputs.
