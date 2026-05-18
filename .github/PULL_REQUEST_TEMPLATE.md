<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

<!--
Thanks for opening a pull request. This template embeds auto-harness's own
companion-rule discipline. Fill in each section; delete the sections that
genuinely do not apply (and say why in a sentence).
-->

## What changed

<!-- A short, factual description of the change. One or two paragraphs. -->

## Why

<!-- The motivation. What problem does this solve, or what improvement does it
make? Link to the issue, observation, ADR, or PRD that originated the work. -->

Closes #

## Companion artifacts

<!-- The harness enforces companion rules: when one path changes, a paired
artifact must change in the same PR. Check the boxes that apply, or explain
why a rule was not triggered. -->

- [ ] If `HARNESS.md`, `AGENTS.md`, or another governance entrypoint changed → ADR or `docs/operating-principles.md` updated
- [ ] If `docs/product/requirements.md` changed → `docs/project/change-log.md` updated or new ADR
- [ ] If a module YAML under `platform/profiles/**/` changed → catalog references (`README.md`, `SUMMARY.md`, relevant skill files) updated
- [ ] If a template under `platform/templates/` changed → template README and module `requiredArtifacts` lists updated
- [ ] No companion rule was triggered (explain briefly):

## Validator run

<!-- Paste output or summary. If any validator was intentionally skipped or
disabled, name it and say why. -->

```bash
bash platform/validators/validate-manifest.sh harness.manifest.yaml
bash platform/validators/validate-module-graph.sh harness.manifest.yaml
bash platform/validators/validate-required-artifacts.sh harness.manifest.yaml .
bash platform/validators/validate-placeholders.sh .
bash platform/validators/validate-agent-pack.sh harness.manifest.yaml .
bash platform/validators/validate-companions.sh harness.manifest.yaml . main
```

- [ ] All validators exit 0 locally
- [ ] Ruby unit tests pass (`ruby -I platform/validators/lib platform/validators/test/test_harness_registry.rb`)
- [ ] Ruby integration tests pass (`ruby -I platform/validators/lib platform/validators/test/test_validators_integration.rb`)

## Trust tier of changes

<!-- See platform/core/kernel/base/trust-model.md. Tier 4 and Tier 5 changes
require explicit human authorization. -->

- [ ] Tier 0 (read-only / docs only)
- [ ] Tier 1 (local analysis additions — tests, lint)
- [ ] Tier 2 (workspace mutation — file edits, scaffolding)
- [ ] Tier 3 (git-writing — branch / commit conventions)
- [ ] Tier 4 (environment-altering — installer, migrations) — authorization in issue/discussion linked above
- [ ] Tier 5 (remote / production) — second sign-off required, named in description

## Notes for reviewer

<!-- Anything specific you'd like reviewers to focus on, or known limitations
that should be raised but not blocking. -->
