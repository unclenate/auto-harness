<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Stack Overlay: Python

**Depends on:** `kernel/base`.
**Conflicts with:** None.

This overlay activates Python-specific interpreter, dependency, and CI expectations only when
composed. It supports multiple packaging approaches (pip, Poetry, uv, conda) without forcing a
single framework. Framework guidance belongs in architecture or domain overlays.

---

## What This Overlay Governs

**Sensitive paths:** `pyproject.toml`, `requirements.txt`, `poetry.lock`, `uv.lock`, `.python-version`

Changes to interpreter pinning or dependency files trigger a companion rule requiring an ADR
or architecture overview update. This enforces the principle that supply-chain changes are
intentional decisions, not unreviewed drift.

**Optional artifacts:** `pyproject.toml`, `requirements.txt`, `poetry.lock`, `uv.lock`, `.python-version`
These are optional because the overlay supports all packaging approaches. The companion rule
fires regardless of which file changes — all are treated as equivalent governance triggers.

---

## Packaging Approach

The overlay is neutral on packaging tool. What matters is that the approach is consistent
and the lock file is committed. Whichever tool is used:

- Pin the interpreter version (`.python-version` or `python-requires` in `pyproject.toml`)
- Commit the lock file (`poetry.lock`, `uv.lock`, `requirements.txt` with pinned versions)
- Treat lock file changes as supply-chain events requiring review

---

## CI Expectations

A Python project typically needs in CI:

- Interpreter setup matching the pinned version
- Dependency installation (`pip install`, `poetry install`, `uv sync`)
- Type checking (`mypy`, `pyright`)
- Linting (`ruff`, `flake8`)
- Tests (`pytest`)

The stack overlay does not configure CI directly — that lives in `.github/workflows/`. The
`platform/workflow/ci-integration.md` guide shows how to combine harness checks with stack
checks in a single workflow.

---

## Polyglot Projects

Python and Node/TypeScript can both be activated in the same manifest. Many real projects
legitimately use multiple runtimes — for example, Python tooling sitting alongside a
Node-based orchestration or frontend. Activating both gives you the companion rules and
sensitive-path governance for both sets of files, which is what a polyglot project needs.

**When activating multiple stacks:**

- Designate a **primary stack** — the runtime most central to the project's build, deploy,
  and operational story. Declare the primary stack and rationale in `docs/architecture/overview.md`.
- Secondary stacks carry the same companion rules as primary — dependency changes in any
  active stack still require ADR or architecture-overview updates. The distinction is
  editorial: the primary stack is what you lead with when describing the project.
- If the two surfaces are genuinely independent services with separate deployments, prefer
  two separate manifests over one polyglot manifest. Separate services = separate governance.

The older convention was to pick exactly one stack. That constraint was removed when it
became clear it forced artificial choices for legitimately polyglot projects. A future
harness version may add primary/secondary semantics at the manifest-schema level
(see deferred finding L-13 in `docs/project/revision-tracker.md`).

---

## Review Gate

Dependency installation and migration commands are Tier 4 actions. Agents may propose
dependency changes and update lock files locally, but `pip install`, `poetry install`, or
`uv sync` against any shared or production environment requires human authorization.

---

## See Also

- Module definition: [`module.yaml`](module.yaml)
- Active modules table: [`HARNESS.md`](../../../../HARNESS.md)
