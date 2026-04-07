# Modular Harness Platform

`platform/` is the source of truth for the development harness framework.

See the top-level [`README.md`](../README.md) for the full introduction, trust tier model,
companion rules explainer, module system overview, and getting-started guide.

---

## Front Door

Projects can start from a raw idea, a set of mockups, a Vercel prototype, or a detailed spec.

| Starting point | Guide |
| -------------- | ----- |
| Raw idea, no stack chosen | [`workflow/discovery-to-composition.md`](workflow/discovery-to-composition.md) |
| Know your stack | [`workflow/bootstrap-quickstart.md`](workflow/bootstrap-quickstart.md) |
| Web3 project | [`workflow/bootstrap-web3-quickstart.md`](workflow/bootstrap-web3-quickstart.md) |

**Intake questionnaire:** [`templates/discovery/intake-questionnaire.md`](templates/discovery/intake-questionnaire.md)
— an 8-section instrument usable with clients, stakeholders, or as a self-interview.

**Starter compositions:** [`compositions/`](compositions/) — copy the closest match to
`harness.manifest.yaml` and adjust. Use `new-product-discovery.yaml` if your stack isn't
chosen yet.

---

## Documentation

This platform is organized as a GitBook. Full table of contents: [`SUMMARY.md`](SUMMARY.md).

For projects using the harness that want GitBook navigation for their own docs, activate
the `domains/gitbook` module.

---

## Structure

```text
platform/
├── core/           # Kernel doctrine, trust model, lifecycle controls, schemas
├── profiles/       # Stack, architecture, data, delivery, management, domain overlays
├── agents/         # AI-tool operating packs: base, claude-code, generic-llm
├── skills/         # Harness-native Agent Skills: harness-governance, harness-web3
├── templates/      # Artifact skeletons — see templates/README.md for placeholder reference
├── validators/     # validate-*.sh scripts + Ruby harness_registry library
├── compositions/   # Starter manifests for common project types
├── examples/       # Sample project with all artifacts filled in
└── workflow/       # Guides: bootstrap, discovery, CI, troubleshooting
```

---

## Operating Model

Each module (`module.yaml`) declares its own governance contract:

- identity, type, version, dependencies, conflicts
- required and optional artifacts
- sensitive path patterns and companion artifact rules
- validator IDs and human review gates
- agent adapter paths and compiled fragments
- recommended skills (Agent Skills format + OpenClaw/ClawHub)

Projects compose modules through `harness.manifest.yaml`. The validator chain enforces
the contract at development time and in CI.
