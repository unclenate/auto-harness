# Stack Overlay: Python

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

## Conflicts with `node-typescript`

A project can only use one primary language stack. Python and Node/TypeScript cannot coexist
in the same manifest. If the system genuinely uses both, each surface should be a separate
service with its own manifest.

---

## Review Gate

Dependency installation and migration commands are Tier 4 actions. Agents may propose
dependency changes and update lock files locally, but `pip install`, `poetry install`, or
`uv sync` against any shared or production environment requires human authorization.
