<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Release and Versioning

## Versioning Policy and Release Process for auto-harness Itself

Consumer projects govern their code with auto-harness. **Auto-harness
itself needs to be versioned** so consumers can talk about which
governance baseline they run, plan upgrades, and understand
compatibility. This document defines the policy and the operational
release process.

> **Status:** policy document (Wave 2 of the 2026-05-23 audit
> trajectory). Implementation — first version tag, automated release
> notes, CHANGELOG.md restructure — is Wave 3 work that follows this
> policy.

---

## Versioning Scheme

Auto-harness uses **semantic versioning** (`MAJOR.MINOR.PATCH`) with
the project-specific interpretation below.

### What counts as a MAJOR bump

Any change that breaks consumers who pin to the previous major version.
Specifically:

- Removing or renaming a module from the catalog (without a
  superseding-OPP alias)
- Changing the `module.yaml` schema in ways that invalidate existing
  manifests
- Changing validator exit code contracts (e.g., flipping `2` and `1`
  semantics)
- Removing a validator
- Renaming any of the harness entry-point files
  (`HARNESS.md`/`AGENTS.md`/`CLAUDE.md`/`TOOLS.md`/`SUMMARY.md`)
- Changing the trust tier numbering or escalation rules
- Removing or renaming companion rule satisfier types in widely-used
  modules
- Anything that requires consumer manifest edits to keep validation
  passing

### What counts as a MINOR bump

Backward-compatible additions:

- New modules (consumers can opt in but aren't forced to)
- New validators (consumers' existing manifests still pass)
- New skills, templates, workflows, compositions, agent packs
- New companion rules that didn't previously exist
- New `module.yaml` fields with sensible defaults

### What counts as a PATCH bump

- Documentation fixes (the catalog-count drift this audit closed
  would be a patch)
- Bug fixes in validators that don't change their public contract
- Template wording improvements that don't change tokens
- ADR / PRD / OPP additions (these are records, not behavior)
- Internal refactoring of `harness_registry.rb` and tooling
- Changes to CI workflow that don't affect consumer experience

### Pre-1.0 policy

Auto-harness is currently pre-1.0. During this phase:

- The MINOR digit may include occasional breaking changes if the
  alternative is shipping a bad design. These will be called out
  *explicitly* in CHANGELOG.md under a `### Breaking Changes` heading
  for that release.
- Consumers pinning during 0.x.y should expect to read CHANGELOG.md
  on every upgrade.
- Auto-harness will tag `1.0.0` once the foundational machinery gaps
  from the 2026-05-23 audit (trust-tier enforcement, knowledge
  curation tooling, consumer module operations) are addressed *or*
  explicitly scoped as out-of-1.0.

---

## Release Cadence

Auto-harness releases when there is value to release, not on a fixed
schedule. Two operational rhythms:

- **Patch releases** ship whenever a non-trivial bug fix or doc
  correction lands on `main` — typically same-day or within a week.
- **Minor releases** ship when 3–6 weeks of accumulated additions are
  ready for consumer adoption — typically monthly during active
  development.

Major releases are deliberate and rare. Each major version cuts a
fresh CHANGELOG section with an *Upgrade Guide* sub-section.

---

## Release Operational Process

A release is a git-tagged commit on `main` with a corresponding
CHANGELOG.md entry. Steps for the maintainer:

### 1. Determine the version bump

Walk the diff from the last release tag to `main` (`git log v0.X.Y..main`).
For each commit, classify it as MAJOR / MINOR / PATCH per the policy
above. The release version is the highest bump in the set.

### 2. Update CHANGELOG.md

Move the `## [Unreleased]` section's contents into a new dated section
`## [vX.Y.Z] — YYYY-MM-DD`. Subdivide by:

```markdown
## [vX.Y.Z] — 2026-MM-DD

### Breaking Changes
(MAJOR-only; explicit upgrade steps consumer must take)

### Added
(New modules, validators, skills, templates, workflows, etc.)

### Changed
(Backward-compatible behavior shifts)

### Fixed
(Bug fixes)

### Deprecated
(Forewarning — still works in this release, will be removed in next major)

### Removed
(MAJOR-only; what is gone)

### Security
(Security-relevant fixes; cross-reference SECURITY.md disclosure if applicable)
```

Replace `## [Unreleased]` at the top of the file (it never goes away;
it just becomes empty until the next contribution adds something).

### 3. Verify the release is shippable

Run the full validator chain locally. CI must be green on the commit
being tagged. Sample projects (when validated by CI per future work)
must pass.

### 4. Tag the release

```bash
git tag -a v0.X.Y -m "auto-harness v0.X.Y"
git push origin v0.X.Y
```

Annotated tags (`-a`) carry metadata; lightweight tags are not
acceptable for releases.

### 5. Create the GitHub release

Use `gh release create v0.X.Y --notes-from-tag` or paste the
CHANGELOG section as the release notes. Attach no binaries (the
release is the source repo at that tag).

### 6. Announce (when relevant)

For MAJOR releases or MINOR releases with new capability:

- Update `README.md`'s "Maturity" claim if changed
- If a documented upgrade path is needed, link it from the release
  notes
- Consider a short note in `docs/knowledge/shared-observations.md`
  if the release captures a milestone-worthy moment

PATCH releases do not need announcement beyond the GitHub release.

---

## Consumer-Side Upgrading

Consumers using auto-harness as a git submodule pin to a tag (preferred)
or a commit. Upgrade flow:

```bash
cd .harness
git fetch --tags
git checkout v0.X.Y       # the new version
cd ..
git add .harness
git commit -m "chore: upgrade auto-harness to v0.X.Y"
```

Then run the validator chain to surface any required scaffolding for
modules whose contracts changed. Reference
[`maintenance-operations.md`](maintenance-operations.md) for the
detailed flow.

### Pinning strategies

- **Tag pinning** (`v0.5.0`) — explicit version, intentional upgrades.
  Recommended for production consumers.
- **Branch pinning** (`main`) — always latest; only appropriate for
  experimental adoption or auto-harness contributors.
- **Commit-hash pinning** — fine-grained but un-versionable. Only when
  consuming pre-release work between tags.

---

## Deprecation Policy

When auto-harness deprecates a capability (a module, validator,
template, etc.):

1. **In the deprecating release:** mark deprecated in the artifact
   (e.g., `version: 1.2.0-deprecated` in `module.yaml`, or a
   prominent banner in the README), AND in CHANGELOG.md under
   `### Deprecated`, AND in `docs/project/change-log.md` as a Scope
   entry.
2. **For at least one MAJOR cycle:** the capability continues to work
   but emits deprecation warnings where possible.
3. **In a subsequent MAJOR release:** the capability is removed, with
   the upgrade path documented in the release's Breaking Changes
   section.

Consumers get one MAJOR cycle of forewarning before any removal.

---

## Yanked Releases

If a release contains a critical defect, mark the tag *yanked* — do
not delete it (deletion breaks pinned consumers more than yanking).
The yank is signaled by:

- Editing the GitHub release notes with a `**⚠️ YANKED**` banner
- Adding a CHANGELOG.md note for the next release explaining the yank
- Continuing to honor consumers pinned to the yanked tag (they're not
  broken, they're just on a tagged-as-flawed version)

The next patch / minor release fixes whatever caused the yank and
documents the recovery in its CHANGELOG entry.

---

## Versioning of Sub-Artifacts

Individual modules carry their own `version` field in `module.yaml`.
This is independent of the harness's overall version. Module
versioning rules:

- New module: `1.0.0`
- New companion rule, new optional artifact, new field: minor bump
  (`1.0.0` → `1.1.0`)
- Schema change requiring consumer manifest edits: major bump (`1.x.y`
  → `2.0.0`) — also triggers a harness major release per the policy
  above

Sub-artifact version bumps appear in the harness's CHANGELOG under
`### Changed` for the release that includes them.

---

## References

- [`CHANGELOG.md`](../../CHANGELOG.md) — the human-readable release history
- [`docs/project/change-log.md`](../../docs/project/change-log.md) — the
  granular per-decision audit log (different artifact from
  CHANGELOG.md; covers scope/governance decisions even when no
  release ships)
- [`maintenance-operations.md`](maintenance-operations.md) — consumer
  upgrade flow
- [`docs/operating-principles.md`](../../docs/operating-principles.md) § 1
  (Ownership) — release ownership currently sits with @unclenate
- [Semantic Versioning](https://semver.org/) — the underlying scheme
