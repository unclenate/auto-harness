<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0072 — Govern the AWS agent toolkit as a trust-tiered target: a `domains/aws` binding

**Status:** proposed
**Owner:** @unclenate
**Created:** 2026-11-17
**Last Updated:** 2026-11-17
**Confidence:** medium (the harness-side pattern is well-precedented — `domains/supabase` shape, `agents/acp` tier-policy seam, the reference-tool genre — and the governance gap is confirmed from AWS's own primary sources; medium not high because several external-toolkit behaviors are marked pending primary confirmation, and the per-operation classification of ~15,000 AWS actions is a heuristic whose default/override split needs a PRD to settle)

---

## Thesis

AWS now ships an official agent toolkit — [`aws/agent-toolkit-for-aws`](https://github.com/aws/agent-toolkit-for-aws) (Apache-2.0), whose core is the GA **AWS MCP Server** reached through a local SigV4 **MCP proxy** ([`aws/mcp-proxy-for-aws`](https://github.com/aws/mcp-proxy-for-aws)). It exposes a tiny fixed tool set over the *entire* AWS API: **`call_aws`** (any of AWS's ~15,000+ API operations), **`run_script`** (sandboxed server-side Python, no network, inherits the caller's IAM), and **`search_documentation` / `read_documentation`**. It authenticates with the caller's own IAM credentials and records every call to CloudTrail plus a CloudWatch `AWS-MCP` namespace.

**The toolkit delivers breadth and omits governance.** It has **no built-in approval, consent, write-gating, dry-run, or human-in-the-loop**: its `--read-only` flag filters whole tools (not individual API operations), and AWS's own guidance *deliberately pushes all read/write classification and approval down to IAM / SCP*. One generic `call_aws` tool therefore spans the full risk range — a Tier-0 `ec2:DescribeInstances` and a Tier-5 `iam:CreateRole` enter through the same door with no distinction the agent host can see without classifying the operation itself.

**That omission is exactly the Layer-4 gap auto-harness exists to fill.** This OPP proposes a governance **binding** (not a vendor, not a runtime): govern the AWS toolkit as an external **target** via a declarative contract + reference material (Half-enforced per operating-principles § 10), dependency-free, against a **pinned** proxy version — the same genre posture the harness already uses for ACP (OPP-0056) and the ruflo runtime (OPP-0065, *"govern the target's execution; do not import its governance"*). The binding has six parts (full spec deferred to a PRD on acceptance):

1. **A `domains/aws` module** (provider-operations overlay, modeled on `domains/supabase`) — declares `tier.declared: 3` + rationale, `sensitivePaths` for IAM / IaC (`\.tf$`, CDK, CloudFormation/SAM) / `\.aws/credentials` / secrets / KMS / deploy configs (so `validate-trust-tier.sh`'s inference table polices under-declaration), a `companionRules` floor (AWS IAM/infra edits require a `docs/security/risk-register.md` entry or an ADR), a `requiredArtifact` `docs/aws/aws-posture.md`, and `recommendedSkills: [harness-aws, harness-tools]`.

2. **A per-operation tier-policy** — `platform/profiles/domains/aws/aws-tier-policy.yaml`, modeled on `platform/agents/acp/tier-policy.yaml`: a two-step declarative function that **classifies** an AWS `service:Action` to a trust tier (a verb-prefix default — `Describe|List|Get|Search` → Tier 0–1; `Create|Put|Update|Modify|Attach|Start|Run|Invoke` → Tier 4; `Delete|Terminate|Detach|Revoke|Disable` → Tier 4–5 — plus an explicit **high-risk override set** forcing Tier 5 regardless of verb: `iam:*`, privileged `sts:AssumeRole*`, `kms:*`, `secretsmanager:*`, SecureString `ssm:PutParameter`, `organizations:*`, `account:*`, billing/`ce:*`, `cloudformation:*`/`cloudcontrol:*` deploy, VPC/network teardown — and sensitive *reads* like `secretsmanager:GetSecretValue` / `sts:GetSessionToken`), then maps tier to the ACP-style posture ladder (Tier 0 auto; Tier 3 no `allow_always`; Tier 4 `requiresHumanAuthorization`; Tier 5 `blockAtSeam` + `routeTo`). The policy only *caps* an action's own tier; IAM stays the independent floor, the tier gate is the added human ceiling (caps-never-grants).

3. **`validate-aws-posture.sh`** — the opt-in / predict-clean content-validator skeleton of `validate-sast-coverage.sh`: gated on the module being active (or `docs/aws/aws-posture.md` present), `--scan-file` mode, module-inactive → exit 0, shape/presence only. Asserts the posture doc's frontmatter (declared accounts/regions, a read/write default, an allowed-services or boundary mode, an IAM-context-key strategy, an approval-posture enum) and conformance-checks `aws-tier-policy.yaml`'s own shape. Validator count 27 → 28, propagated per the catalog discipline.

4. **A `harness-aws` skill** — on-demand guidance: the tier-policy table; the **IAM context-key** least-privilege pattern (an IAM policy that lets a human role write but restricts the MCP-server call path to read-only, distinguishing agent calls from human calls); CloudTrail + CloudWatch `AWS-MCP` as the audit/verification plane; the untrusted-data discipline (`call_aws` results, `run_script` output, and AWS docs are untrusted input — no self-elevation); the Tier 4/5 human gate; and "pin the proxy, never vendor."

5. **Agent-side registration (dogfood)** — a `TOOLS.md` entry for the AWS MCP tools whose tier mapping **points at `aws-tier-policy.yaml`** (flagged tier-variable, classified per operation — not a single per-tool tier), wired into an agent pack (`agents/openclaw` and/or `agents/claude-code`) under the existing reviewGate that tool entries declare explicit tier requirements and adapters claim no permission above the kernel.

6. **A positioning artifact** (OPP-0056 analog) framing the AWS MCP server as a governed target: auto-harness supplies the classification + approval + consent the toolkit pushes to IAM; govern a pinned version; bind CloudTrail/CloudWatch as the verification surface; do not vendor the proxy.

Scope guard: stay on the **operate-against-AWS** axis. `architectures/ai-foundry-target` + `validate-foundry-target.sh` already own `aws-bedrock-agentcore` as a *deployment-landing-zone* enum value — this OPP must not duplicate that axis.

## Origin / Evidence

- **Three-agent exploration this session (2026-11-17).** Primary external sources: the [toolkit repo](https://github.com/aws/agent-toolkit-for-aws), the [AWS GA announcement](https://aws.amazon.com/blogs/aws/the-aws-mcp-server-is-now-generally-available), the [MCP proxy repo](https://github.com/aws/mcp-proxy-for-aws), and PyPI. Established: the toolkit is an umbrella (managed remote MCP server + local proxy + on-demand skills + per-domain plugins), `call_aws` is a generic "any AWS API" tool (AWS cites 15,000+ operations), there is **no in-band approval/write-gate**, and the audit plane is CloudTrail + a CloudWatch `AWS-MCP` namespace.
- **Codebase precedents (reuse, do not reinvent):** `platform/profiles/domains/supabase/module.yaml` (provider-overlay shape); `platform/agents/acp/tier-policy.yaml` + `platform/agents/acp/module.yaml` (the declarative classify-then-posture seam, Half-enforced); [`OPP-0065`](OPP-0065-govern-ruflo-runtime.md) (govern-the-target-don't-vendor-it); [`OPP-0056`](OPP-0056-agent-client-protocol-governance-bridge.md) (reference-tool positioning); `platform/validators/validate-sast-coverage.sh` + `validate-trust-tier.sh` + `validate-agent-bus.sh` (the opt-in validator + reference-linter patterns); `TOOLS.md` + `platform/skills/harness-tools/SKILL.md` + `harness-mcp/SKILL.md` (per-tool tier registry).
- **The governance thesis this instantiates:** the Layer-4 position (human-ratified policy + human-approval gate the runtime layer "cannot express"). The AWS toolkit is a near-perfect worked target — maximal breadth, zero native governance.

## Why Now

The AWS MCP Server reached GA and the toolkit is AWS's official **consolidation point** — the older `awslabs/mcp` servers are named predecessors folding in over time, so binding to this umbrella now tracks where AWS agent tooling is centralizing rather than a transient library. Agents are increasingly pointed at AWS, and the no-governance gap is live the moment a consumer wires the server in. The binding reuses existing harness machinery (trust tiers, the reference-tool genre, the opt-in validator skeleton) at near-zero new primitives. No external pressure or deadline.

## Risks / Open Questions

- **Half-enforced, not Enforced — be honest in § 10 terms.** The harness cannot force the AWS MCP server to honor the tier gate; it *declares* the classification and binds the audit plane (CloudTrail), while the host/proxy/IAM enforce at runtime — exactly the ACP seam posture. The positioning and skill must state this plainly; overclaiming "enforced AWS governance" would be the very doc-honesty failure OPP-0071 just corrected elsewhere.
- **Per-operation classification is a heuristic.** A verb-prefix default mis-classifies both directions — sensitive *reads* (`secretsmanager:GetSecretValue`, `sts:GetSessionToken`, `s3:GetObject` on a secret bucket) and benign *writes* (`Tag*`, `cloudwatch:PutMetricData`). The design must treat the classifier as a **default with an explicit override set**, keep IAM as the independent floor, and leave the WARN-vs-BLOCK posture and the enforced-vs-declarative boundary to the PRD. The 15,000-operation surface cannot be exhaustively curated — this is a boundary-plus-overrides design, not an allow-list.
- **`run_script` is tier-indeterminate.** It can call any AWS API server-side via boto3 under the caller's IAM, so it can do anything `call_aws` can — it cannot be statically classified. Default it to a high tier (Tier 4 floor, Tier 5 if the credentials can reach override services) or require a read-only credential path; open question for the PRD.
- **External-toolkit claims pending primary confirmation (verify before any impl binds to them):** whether `--read-only` blocks write *operations* inside `call_aws` or only hides whole tools (sources lean tool-level only → assume IAM is the real control); STS/AssumeRole handling via the proxy; the regional-endpoint set (us-east-1 confirmed, others inconsistent); the lineage to `awslabs/aws-api-mcp-server` (functionally parallel, not stated). Follow the OPP-0062 discipline: mark pending, confirm against AWS docs, do not cite normatively until verified.
- **Module shape: single vs family.** Start with one `domains/aws` module; a later split into `aws-core` / `aws-iam` / `aws-data` is a noted follow-on, not this scope.
- **Dependency-free posture.** Govern a pinned proxy version; never vendor the proxy or import the toolkit's plugins/skills as harness governance (OPP-0065 footprint-inversion + duplication-pocket anti-goals).

## Disposition

<!--
Empty while Status: proposed. Populated when status flips to exploring,
accepted, declined, or superseded — on acceptance, a pointer to the spawned PRD.
-->

## Promotion

<!--
Empty until accepted. Then a link to PRD-NNNN (breadth > half-day → PRD, not
OPP-direct), whose staged impl PRs build parts 1–6 above, each held at the gate.
-->
