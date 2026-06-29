<!--
Copyright [[YEAR]] [[OWNER_NAME]] <[[OWNER_EMAIL]]>
SPDX-License-Identifier: [[SPDX_LICENSE]]
-->

# CI Templates

Ready-to-copy CI configurations that run the auto-harness validator chain
on consumer projects. Pick the one matching your CI provider.

| File | Provider | Copy to |
|------|----------|---------|
| [`github-actions.yml`](github-actions.yml) | GitHub Actions | `.github/workflows/harness.yml` in your project root |
| [`gitlab-ci.yml`](gitlab-ci.yml) | GitLab CI | `.gitlab-ci.yml` in your project root |

After copying, replace the tokenized header (`[[YEAR]]`, `[[OWNER_NAME]]`,
etc.) by running:

```bash
bash .harness/platform/bootstrap/set-consumer-headers.sh
```

If you already have a `.harness-headers.yaml` config in your project,
re-run with `--non-interactive` and the tokens fill from the config.

## What These Templates Do

Both templates run the same eight-validator chain:

1. `validate-manifest` — schema correctness of `harness.manifest.yaml`
2. `validate-module-graph` — module dependency / conflict consistency
3. `validate-required-artifacts` — every required file exists
4. `validate-placeholders` — no unfilled `[[…]]` tokens in tracked files
5. `validate-agent-pack` — agent adapter files consistent
6. `validate-doc-references` — markdown links resolve + render-safely
7. `validate-companions` — PR diff satisfies companion rules (PR-only)

`validate-catalog-counts` is omitted from consumer CI by default — that
validator's recipes and assertions are specific to the auto-harness
repository structure. Consumers can add it if their project also makes
catalog-count claims.

## Submodule Smoke Test

Both templates also include a **separate `submodule-smoke-test` job** that
guards the consumer-side of the submodule integration (OPP-0025). It runs on a
clean runner and:

1. Checks out the repo with recursive submodules (fresh-clone semantics).
2. Asserts `.harness/` actually materialized — failing with an actionable
   message if the submodule is empty or its pinned SHA is unreachable upstream.
3. Smoke-runs one validator against your manifest to prove the integration is live.

It is a *separate* job (not a step in the validator chain) on purpose: a failure
here means "the submodule integration is broken" — distinct from "a validator
found drift" — and the clean-checkout semantics are what give the smoke test its
value. These are the two failure modes that are silent on the first developer's
machine and only surface for the second developer or in a teammate's clone; the
harness's own CI cannot see them, because the harness *is* the upstream. See
[`platform/workflow/submodule-integration.md`](../../workflow/submodule-integration.md)
§ 6 for the manual one-liner version.

## Customization

| Need | How |
|------|-----|
| Different mount path (not `.harness/`) | Update validator paths in the workflow |
| Skip specific validators | Comment out the corresponding step |
| Add custom validators | Append additional `run:` steps after the harness chain |
| Run on different branches | Adjust the `on:` / `rules:` triggers |
| Use Node.js for `markdownlint-cli2` | Add a markdownlint job alongside the validators |

## Companion Rule Validation Caveat

`validate-companions.sh` is PR-diff-based and requires:

1. Full git history (`fetch-depth: 0` or equivalent) so it can diff
   against the base branch
2. Knowledge of the base branch (the templates use
   `github.base_ref` / `CI_MERGE_REQUEST_TARGET_BRANCH_NAME` respectively)

If your project uses a non-standard base branch name (anything other than
`main`), adjust the validator invocation. The third positional arg is the
base-branch name.

## References

- [`platform/workflow/ci-integration.md`](../../workflow/ci-integration.md) — full CI integration guide
- [`platform/validators/README.md`](../../validators/README.md) — validator overview
- [`platform/bootstrap/set-consumer-headers.sh`](../../bootstrap/set-consumer-headers.sh) — fill template headers
- The auto-harness repo's own [`.github/workflows/harness.yml`](https://github.com/unclenate/auto-harness/blob/main/.github/workflows/harness.yml) — reference implementation
