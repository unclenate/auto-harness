<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Runbook: [[OPERATION_NAME]]

<!-- Copy this template for each runbook entry. -->
<!-- Store completed runbooks in docs/ops/runbooks/. -->
<!-- Register each runbook in docs/ops/runbook-index.md. -->

**Operation:** [[OPERATION_NAME]]
**Runbook ID:** RB-[[NNN]]
**Owner:** [[OWNER]]
**Last tested:** YYYY-MM-DD
**Estimated duration:** [[DURATION]]
**Tier required:** [[TIER]] (see trust model — Tier 3+ requires human confirmation)

---

## When to Use This Runbook

Describe the specific condition or trigger that should lead an operator to this runbook.
Be precise — a runbook that is used for the wrong situation can cause damage.

> Example: "Use this runbook when the background job queue depth exceeds 10,000 items
> for more than 5 minutes, as observed on the ops dashboard."

[[TRIGGER_CONDITION]]

**Do NOT use this runbook when:**

- [[EXCLUSION_1]] — use [[OTHER_RUNBOOK]] instead
- [[EXCLUSION_2]]

---

## Prerequisites

What must be true before starting:

- [ ] You have [[REQUIRED_ACCESS]] access
- [ ] [[DEPENDENCY_SERVICE]] is healthy (check [[HEALTH_CHECK_URL_OR_COMMAND]])
- [ ] A second operator is available for Tier 4+ operations
- [ ] You have reviewed the rollback plan (Step 6 below)

---

## Impact

| Dimension | Description |
| --------- | ----------- |
| User-facing impact | [[NONE / DEGRADED_FEATURE / DOWNTIME]] |
| Data risk | [[NONE / READ_ONLY / WRITE / DESTRUCTIVE]] |
| Reversible | Yes / No — [[IF_NO_EXPLAIN]] |
| Blast radius | [[SCOPE_OF_AFFECTED_SYSTEMS]] |

---

## Steps

Execute steps in order. Do not skip steps. If a step fails, stop and go to the Escalation
section — do not improvise.

### Step 1 — [[STEP_NAME]]

[[DESCRIPTION_OF_WHAT_THIS_STEP_DOES]]

```bash
# Command to run
[[COMMAND]]
```

**Expected output:**

```text
[[EXPECTED_OUTPUT]]
```

**If this fails:** [[WHAT_TO_DO_IF_THIS_STEP_FAILS]]

---

### Step 2 — [[STEP_NAME]]

[[DESCRIPTION]]

```bash
[[COMMAND]]
```

**Expected output:**

```text
[[EXPECTED_OUTPUT]]
```

**If this fails:** [[WHAT_TO_DO]]

---

### Step 3 — Verify

After completing the operation, verify the expected state:

```bash
[[VERIFICATION_COMMAND]]
```

**Success looks like:** [[SUCCESS_CRITERIA]]

---

## Rollback Plan

If the operation must be reversed, follow these steps.

**Rollback available:** Yes / No

### Rollback Step 1 — [[STEP_NAME]]

```bash
[[ROLLBACK_COMMAND]]
```

**Expected outcome:** [[WHAT_SHOULD_HAPPEN]]

---

## Escalation

If any step fails and cannot be resolved with the rollback plan:

1. **Stop** — do not continue with remaining steps
2. **Preserve state** — capture logs and current system state before taking further action
3. **Notify:** [[ESCALATION_CONTACT]] via [[CHANNEL]] (e.g., PagerDuty, Slack `#on-call`)
4. **Document** — open an incident record at `docs/ops/incidents/` using `platform/templates/incident.md`

---

## Post-Operation Checklist

- [ ] Verification step passed
- [ ] Incident record created (if anything went wrong)
- [ ] Runbook updated if steps were incorrect or missing
- [ ] `docs/ops/runbook-index.md` reflects "last tested" date update

---

## Reference

| Resource | Path / URL |
| -------- | ---------- |
| Runbook index | `docs/ops/runbook-index.md` |
| Incident template | `platform/templates/incident.md` |
| Ownership map | `docs/security/ownership-map.md` |
| Trust model | `platform/core/kernel/base/trust-model.md` |
| [[RELEVANT_DASHBOARD]] | [[URL]] |
