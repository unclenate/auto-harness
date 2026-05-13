<!--
Copyright 2026 Nate DiNiro <nate@bdits.io>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Contributing to auto-harness

Thanks for your interest in contributing. auto-harness is a governance harness — a modular contract framework that AI agents and human collaborators adopt to keep development disciplined under acceleration. Contributions of any size are welcome: new modules, validator improvements, documentation clarifications, structured observations about how the harness behaves in real projects, or pre-PRD candidate ideas.

This document covers the practical mechanics. The harness's own governance discipline applies to changes against this repository, so contributing here doubles as a working tour of how the harness operates.

---

## Licensing & Contributor Agreement

auto-harness is dual-licensed under the [MIT License](LICENSE-MIT) and the [Apache License 2.0](LICENSE-APACHE), at the consumer's option.

**By submitting a contribution to this project, you agree that your contribution is dual-licensed under both the MIT License and the Apache License 2.0 on the same terms as the project itself.** This is the standard inbound-equals-outbound convention used by the Rust ecosystem and by many CNCF-adjacent projects.

No separate Contributor License Agreement (CLA) is required at this time. The dual-license acceptance above is established by the act of opening a pull request.

If your contribution incorporates or derives from third-party source that is licensed differently (especially under copyleft licenses like GPL or AGPL), please flag this explicitly in the pull request description so we can verify the dual-license property is preserved.

---

## Where to Start

| You want to... | Open... |
| -------------- | ------- |
| Report a bug or unexpected validator behavior | A **Bug Report** issue ([`.github/ISSUE_TEMPLATE/bug_report.yml`](.github/ISSUE_TEMPLATE/bug_report.yml)) |
| Propose a new feature, module, or workflow | A **Feature Request** issue ([`.github/ISSUE_TEMPLATE/feature_request.yml`](.github/ISSUE_TEMPLATE/feature_request.yml)) |
| Share a structured observation from real-world use | An **Observation** issue ([`.github/ISSUE_TEMPLATE/observation.yml`](.github/ISSUE_TEMPLATE/observation.yml)) — these feed the harness's own [knowledge-capture flow](platform/profiles/management/knowledge-capture/README.md) |
| Ask a usage question | An issue using the **Feature Request** template, prefixed `[Question]` in the title |
| Submit a fix or improvement | A pull request against `main` (read this document first) |

If you are unsure which template fits, open a Feature Request and we will reclassify together.

---

## Local Development Setup

auto-harness is a documentation-and-validator project, not a compiled application. The only runtime requirements are:

- **Bash 4+** (macOS users: install GNU Bash via Homebrew — `brew install bash` — because macOS ships Bash 3.2)
- **Ruby 3.0+** (required by every validator and the bootstrap installer)
- **ripgrep (`rg`)** (used by validators for fast file scanning)

```bash
git clone https://github.com/unclenate/auto-harness.git
cd auto-harness
```

No dependency-installation step is required beyond having Bash, Ruby, and ripgrep on `PATH`.

---

## Running the Validator Chain

Before submitting any change, run the full validator chain locally. Every validator must exit 0.

```bash
bash platform/validators/validate-manifest.sh harness.manifest.yaml
bash platform/validators/validate-module-graph.sh harness.manifest.yaml
bash platform/validators/validate-required-artifacts.sh harness.manifest.yaml .
bash platform/validators/validate-placeholders.sh .
bash platform/validators/validate-agent-pack.sh harness.manifest.yaml .
bash platform/validators/validate-companions.sh harness.manifest.yaml . main
ruby -I platform/validators/lib platform/validators/test/test_harness_registry.rb
ruby -I platform/validators/lib platform/validators/test/test_validators_integration.rb
```

If a validator fails, see [`platform/workflow/troubleshooting.md`](platform/workflow/troubleshooting.md) for the per-error solver guide.

---

## Companion-Rule Discipline

This repository enforces its own companion rules. The most common ones contributors will encounter:

| If you change... | You must also change... in the same PR |
| ---------------- | -------------------------------------- |
| `HARNESS.md`, `AGENTS.md`, governance entrypoints | An ADR in `docs/adr/` OR `docs/operating-principles.md` |
| `docs/product/requirements.md` | `docs/project/change-log.md` OR a new ADR |
| Module YAML files in `platform/profiles/**/module.yaml` | Catalog references (`README.md` directory tree, `SUMMARY.md`, relevant skill files) |
| A platform template under `platform/templates/` | The template README index and any module that lists it in `requiredArtifacts` |

The `validate-companions.sh` validator checks these on every PR. If your change touches a trigger path and you do not include the companion, the validator will fail with a specific message.

If you genuinely need to weaken or remove a companion rule, that is a decision worth recording in an ADR, not silently bypassing.

---

## Pull Request Workflow

1. **Fork the repository** and create a feature branch off `main`. Branch names should be descriptive and lower-case-kebab: `feat/new-validator-name`, `docs/maintenance-section`, `fix/companion-rule-regex`.

2. **Make focused changes.** A pull request should do one thing. If you find yourself making two unrelated improvements, split them into two PRs — the review surface stays small and the change-log entry stays clear.

3. **Run the validator chain locally** (see above) before pushing. CI will run the same checks; failing locally first saves a round-trip.

4. **Open a pull request** using the [PR template](.github/PULL_REQUEST_TEMPLATE.md). Fill in:
   - What changed and why
   - Which companion artifacts were updated (or why none were needed)
   - Validator confirmation (a copy-paste of the local run is fine)

5. **Reference related artifacts.** If your change resolves an issue, an Observation, or implements a PRD or ADR, link them in the PR description.

6. **Respond to review.** Maintainers will review for governance correctness, documentation clarity, and validator-suite green. Iterate until both reviewers and validators are satisfied.

7. **Squash-merge.** This repository uses squash-merge so the commit history on `main` reads as a sequence of complete, reviewable changes rather than work-in-progress increments.

---

## Documentation Contributions

Documentation changes follow the same workflow as code changes. A few specifics:

- **The README.md and `platform/README.md` have distinct roles.** The root README is the GitBook and GitHub front door; `platform/README.md` is the focused platform overview. If you update one, check whether the other needs a corresponding update — they should complement, not duplicate.
- **SUMMARY.md is the GitBook table of contents.** Adding a new doc means adding it to `SUMMARY.md` in the right section. The TOC and the README narrative should align.
- **Templates use `[[PLACEHOLDER_NAME]]` tokens.** Never commit a tracked file with an unfilled token — the placeholder validator will fail.
- **Use the harness-native `Observation` issue template** for structured field notes. These feed directly into the knowledge-capture surface and are the primary mechanism for forward-flowing lessons learned.

---

## Reporting Security Issues

Do not file public issues for security vulnerabilities. See [SECURITY.md](SECURITY.md) for coordinated-disclosure instructions.

---

## Code of Conduct

This project follows the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md). By participating, you agree to abide by its terms. Concerns should be raised privately to nate@bdits.io.

---

## Questions

If something in this document is unclear, that is itself worth raising — open an issue using the Feature Request template prefixed `[Docs]` and we will improve the guidance.

Thanks again for contributing.
