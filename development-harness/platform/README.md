# Modular Meta-Harness Platform

`platform/` is the new source-of-truth layout for the development harness framework.

## Front Door

Projects can start from a raw idea, a set of mockups, a Vercel prototype, or a detailed spec —
the intake questionnaire meets the project wherever it is and extracts what is needed to produce
product artifacts and select the right module composition.

**Start here:** [`platform/workflow/discovery-to-composition.md`](workflow/discovery-to-composition.md)
— walks from first idea to a running `harness.manifest.yaml` in eight steps.

**Intake questionnaire:** [`platform/templates/discovery/intake-questionnaire.md`](templates/discovery/intake-questionnaire.md)
— a structured 8-section instrument for use with clients, stakeholders, or as a self-interview.

**Starter composition for the discovery phase:** [`platform/compositions/new-product-discovery.yaml`](compositions/new-product-discovery.yaml)
— use this manifest before your stack is chosen; replace it after Step 6 of the workflow.

## Documentation

This platform is organized as a GitBook. The full table of contents is at
[`SUMMARY.md`](SUMMARY.md). The `.gitbook.yaml` at the platform root configures GitBook
to serve the `platform/` directory directly.

For projects using the harness that want GitBook navigation for their own docs, activate
the `domains/gitbook` module. It requires `docs/SUMMARY.md` and provides guidance on
chapter structure, TOC maintenance, and the human/agent documentation split.

## Structure

- `core/`: universal doctrine, lifecycle rules, schemas, and kernel metadata
- `profiles/`: stack, architecture, data, delivery, management, and domain overlays
- `agents/`: AI-tool operating packs and compatibility fragments
- `templates/`: reusable artifact skeletons
- `validators/`: module-driven validation entrypoints
- `compositions/`: recommended module bundles
- `examples/`: sample outputs and sample project layouts

## Operating Model

Each module declares its own:

- identity and type
- dependencies and conflicts
- required and optional artifacts
- sensitive path patterns
- companion artifact rules
- validators
- human review gates
- agent adapters
- compatibility fragments

Projects compose modules through `harness.manifest.yaml`.
