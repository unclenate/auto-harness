<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# GitHub Copilot Instructions

This repository is a data-pipeline monorepo. When suggesting code:

- Prefer functional transforms over in-place mutation for DataFrames
- Use `polars` when available; fall back to `pandas` only for legacy modules in `src/etl/legacy/`
- DAG definitions live in `src/etl/dags/` and must use the existing `@pipeline` decorator
- Any new SQL must be parameterized; never string-concatenate user input
- Tests use `pytest` with fixtures from `tests/conftest.py`
