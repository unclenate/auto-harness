<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Stack Overlay: Node.js / TypeScript

**Depends on:** `kernel/base`.
**Conflicts with:** None.

This overlay activates Node.js and TypeScript-specific interpreter, dependency, and CI
expectations only when composed. It supports multiple package managers (npm, pnpm, yarn)
without forcing a single choice. Framework guidance belongs in architecture or domain
overlays — this module owns the runtime and toolchain layer only.

---

## What This Overlay Governs

**Sensitive paths:** `package.json`, `package-lock.json`, `pnpm-lock.yaml`, `yarn.lock`,
`tsconfig.*`, `.nvmrc`

Changes to any of these paths trigger a companion rule requiring an ADR or architecture
overview update. This enforces the principle that runtime and dependency changes are
intentional decisions, not unreviewed drift.

**Optional artifacts:** `package.json`, `tsconfig.json`, `.nvmrc`, `.github/workflows/stack.yml`
These are optional because not every project needs all of them at declaration time.
The companion rule fires regardless — all lockfile and config changes are treated as
equivalent governance triggers.

---

## Runtime Pinning

Pin the Node.js version using `.nvmrc` or the `engines` field in `package.json`. Both
are acceptable; pick one and be consistent:

- `.nvmrc` — simple file containing the version string (e.g., `22.11.0`)
- `package.json` `engines` field — `{ "engines": { "node": ">=22.0.0" } }`

CI must match the pinned version. A mismatch between local development and CI is the most
common source of "works on my machine" failures.

---

## Package Manager and Lockfile

The overlay is neutral on package manager. What matters is that the approach is consistent
and the lock file is committed:

- Commit the lock file (`package-lock.json`, `pnpm-lock.yaml`, or `yarn.lock`)
- Treat lock file changes as supply-chain events requiring review
- Do not mix package managers across a single project
- If switching package managers, document the decision in an ADR

Lock file changes that are not accompanied by an intentional dependency decision (e.g.,
introduced by an agent auto-installing something) should be flagged in code review.

---

## TypeScript Configuration

The overlay does not prescribe a `tsconfig.json` preset. Common governance expectations:

- `strict: true` is the recommended default — weaker configs require justification in an ADR
- `noUncheckedIndexedAccess` and `exactOptionalPropertyTypes` are worth enabling for
  production services; document the choice
- Path aliases (`@/`, `~/`) are common in web projects — ensure they are consistent across
  `tsconfig.json`, bundler config, and Jest/Vitest config

---

## CI Expectations

A Node/TypeScript project typically needs in CI:

- Node.js setup matching the pinned version
- Dependency installation (`npm ci`, `pnpm install --frozen-lockfile`, `yarn install --immutable`)
- Type checking (`tsc --noEmit`)
- Linting (`eslint`)
- Tests (`jest`, `vitest`, or similar)
- Build verification (`tsc`, `next build`, `vite build`)

The stack overlay does not configure CI directly — that lives in `.github/workflows/`. The
`platform/workflow/ci-integration.md` guide shows how to combine harness checks with stack
checks in a single workflow.

---

## Recommended Skills

The module's `recommendedSkills` field in `module.yaml` lists harness-native and
OpenClaw / ClawHub skills relevant to a Node/TypeScript project:

- **Agent Skills (harness-native):** `harness-governance`
- **OpenClaw / ClawHub slugs:** `next-best-practices`, `next-cache-components`,
  `lb-vercel-skill` (Vercel CLI), `react-perf`, `supabase` (when using Supabase
  as the data layer)

Install harness-native skills by copying the `platform/skills/<name>` directory
into `.agents/skills/` or `.claude/skills/`. OpenClaw skills install via
`clawhub install <slug>`. See `platform/workflow/skills-and-agents.md` for the
full mapping and installation paths.

---

## Polyglot Projects

Node/TypeScript and Python can both be activated in the same manifest. Many real projects
legitimately use multiple runtimes — for example, a Python tooling layer sitting alongside
a Node-based orchestration or frontend. Activating both gives you the companion rules and
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

Dependency installation remains a Tier 4 action. Agents may propose dependency changes and
update lock files locally, but `npm install`, `pnpm add`, or `yarn add` against any shared or
production environment requires human authorization.

---

## See Also

- Module definition: [`module.yaml`](module.yaml)
- Active modules table: [`HARNESS.md`](../../../../HARNESS.md)
- Related module: [`stacks/node-javascript`](../node-javascript/README.md)
