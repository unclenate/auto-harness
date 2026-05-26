# Consumer (No Platform Dir) — Broken Fixture

Simulates a submodule consumer (no top-level `platform/` tree) whose own docs
contain a broken relative link. The validator must scan consumer docs and catch
this — exit 1, not exit 2 (which would mean "couldn't scan at all").

Broken relative link: [missing guide](docs/does-not-exist.md).
