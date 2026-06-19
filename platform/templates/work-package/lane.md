<!--
Copyright [[YEAR]] [[OWNER_NAME]] <[[OWNER_EMAIL]]>
SPDX-License-Identifier: [[SPDX_LICENSE]]
-->

# Work-Package: [[WORK_PACKAGE_TITLE]]

> One dispatched task, one isolated worktree, one lane. Fill the prose so an
> executing agent knows *what* to build; fill the lane block so its diff can be
> checked against *where* it may build.

## Objective

[[WHAT_THIS_WORK_PACKAGE_DELIVERS]]

## Acceptance criteria

- [[ACCEPTANCE_CRITERION_1]]
- [[ACCEPTANCE_CRITERION_2]]

## Lane

The fenced block below is the machine-readable lane. `validate-lane-integrity.sh`
parses it and checks the branch's actual diff against `allowedFiles` /
`readOnlyFiles`.

```yaml
lane:
  branch: [[FEATURE_BRANCH]]          # e.g. feat/widget-export
  base: main                          # ref the branch is cut from and diffed against
  prMode: draft                       # draft | ready
  allowedFiles:                       # every changed file MUST match at least one glob
    - "[[ALLOWED_GLOB_1]]"            # e.g. "src/widget/**"
    - "[[ALLOWED_GLOB_2]]"            # e.g. "docs/widget/*.md"
  readOnlyFiles:                      # readable but MUST NOT be modified
    - "[[READONLY_GLOB_1]]"          # e.g. "src/core/**"
  requiredChecks:                     # must pass before prMode flips to ready
    - "[[REQUIRED_CHECK_1]]"         # e.g. "npm test"
  forbiddenCommands:                  # declared; honored by the agent (Asserted-only in v1)
    - "[[FORBIDDEN_COMMAND_1]]"      # e.g. "git push --force"
```

## Conflict protocol

If an acceptance criterion or a named symbol requires a file **outside**
`allowedFiles`, **stop and report** to the dispatcher — do not silently widen
the lane or skip the criterion. Re-scoping the lane is a reviewed change to this
file, not an in-flight decision by the executing agent.
