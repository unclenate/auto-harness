<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0072 — Govern agent access to AWS through the AWS MCP Server: an IAM-anchored `agents/aws-mcp` binding

**Status:** proposed
**Owner:** @unclenate
**Created:** 2026-11-17
**Last Updated:** 2026-11-17
**Confidence:** medium (the tool surface, IAM context keys, and audit events below were re-read from AWS's current documentation and a live tool listing on 2026-11-17, and the harness-side findings were checked against the validators on disk; medium not high because several AWS behaviors remain unverified — listed under Risks — and because there is no AWS consumer yet to test the contract against)

---

## Revision note

This record was rewritten before merge, on its filing branch, after a three-reviewer adversarial pass on the first draft. The first draft proposed a `domains/aws` module with a per-operation tier-policy YAML that classified each `service:Action` at the agent host. The review found that design unbuildable and unsafe:

- **Its central tool no longer exists.** The first draft was built around a generic `call_aws` tool. AWS removed that tool on 2026-08-31. The draft's research relied on the May 2026 general-availability announcement, which is stale on the tool surface.
- **Nothing would have enforced it.** No component in any realistic deployment reads a policy YAML. Under operating-principles § 10 that is Asserted-only, not the Half-enforced the draft claimed.
- **Its classification model failed open.** A verb-prefix default left every unlisted verb without a tier and rated privilege escalation, sensitive reads, and audit-log tampering as approvable.
- **It failed this repo's own validators.** The proposed `tier.declared: 3` fails `validate-trust-tier.sh` against the proposed sensitive paths, and a `domains/` module's path-regex machinery never sees a tool call.

The design below replaces it. The thesis that AWS leaves per-action approval to the agent host survives; the mechanism changes from "classify at the host" to "enforce in IAM, prove by conformance."

## Thesis

AWS ships an official agent toolkit, [`aws/agent-toolkit-for-aws`](https://github.com/aws/agent-toolkit-for-aws) (Apache-2.0), whose core is the managed **AWS MCP Server**. An agent that connects to it can act across AWS under the caller's own IAM credentials.

### What the server exposes (verified 2026-11-17)

| Tool | Annotated read-only | What it does |
| --- | --- | --- |
| `aws___run_script` | no (marked destructive) | Runs a Python script server-side; the script calls AWS APIs through a `call_boto3` helper |
| `aws___get_presigned_url` | no | Issues S3 upload and download URLs |
| `aws___get_tasks` | yes | Reads the status of long-running tasks |
| `aws___search_documentation` | yes | Searches AWS documentation |
| `aws___read_documentation` | yes | Reads AWS documentation |
| `aws___retrieve_skill` | yes | Fetches AWS-maintained skill instructions at runtime |
| `aws___list_regions` | yes | Lists regions |
| `aws___get_regional_availability` | yes | Reports service availability by region |

Three facts about this surface drive the design:

- **`aws___run_script` is the only tool that executes AWS APIs, and its input is one free-form Python `code` string.** The agent host sees opaque code, not an operation name. The script can build its API calls dynamically, so static inspection of the code is defeatable. AWS's own `secret-safety` hook has an open bypass for this reason.
- **AWS provides no per-call human approval and says so.** Its guidance for approval before sensitive use is to "configure client-side hooks or permission rules in your MCP client." What AWS does provide is coarse: tool annotations, a proxy `--read-only` flag that removes every non-read-only tool (which today removes all AWS API access), an OAuth consent page, a profile allow-list, and one blocking hook shipped in the `aws-core` plugin.
- **AWS stamps every downstream request made through the server with IAM context keys.** `aws:ViaAWSMCPService` is a Boolean, and `aws:CalledViaAWSMCP` carries the service principal (`aws-mcp.amazonaws.com`). Both are usable in identity policies and service control policies. The server defines no IAM actions of its own.

### The gap

Per-action control over what an agent may do in AWS exists only where the consumer writes IAM policy by hand. The agent host cannot supply it, because the host cannot see operations. Nothing connects a project's declared intent ("this agent reads metadata in the sandbox account and nothing else") to the policy that would make it true, and nothing checks the two against each other.

### The proposal

Govern the AWS MCP Server as an external target, in the reference-tool posture `agents/acp` established ([PRD-0037](../requirements/PRD-0037-acp-governance-bridge.md), [PRD-0038](../requirements/PRD-0038-acp-governance-proxy-reference.md)): the harness ships a contract, reference material, and a conformance check, and does not vendor or run the toolkit. The binding has eight parts. Full specification is deferred to a PRD on acceptance.

1. **An agents-family module, `platform/agents/aws-mcp/`.** The repo's taxonomy puts tool-seam governance under Agents ("AI-tool operating packs"); the only existing tier-policy lives in `platform/agents/acp/`. Governance of IaC and deploy file paths stays with `delivery/production-saas`, which already owns `^terraform/`, `^deploy/`, and `^infra/`. The module declares its trust tier honestly — expected to be 5, since it governs production-reaching operations — and the PRD must settle what that requires of a consumer's `project.criticality`.

2. **A declared posture artifact, `docs/aws/aws-mcp-posture.md`.** Frontmatter declares: each AWS account with an environment class (sandbox, non-production, production); permitted regions; the connection path (OAuth direct or SigV4 proxy); the agent's role per environment; the separate human-assumed role used for writes; the proxy version pin where a proxy is used; and the toolkit plugins installed.

3. **Enforcement anchored in IAM.** The harness ships reference policy templates for the agent role's permission boundary, conditioned on the MCP context keys:
   - **Default deny.** Anything not positively allowed is denied, including actions AWS adds later.
   - **Allow-list from AWS's own access-level metadata** (the Service Authorization Reference's List, Read, Write, Permissions management, and Tagging levels), pinned by snapshot. List-level actions are allowed. Read-level actions are allowed only for control-plane metadata, minus a curated set of secret-bearing and data-plane reads.
   - **A curated never-allow set** on the agent role regardless of environment: permissions management, credential minting, role passing, compute launched with a role, resource-policy and cross-account sharing edits, audit-plane tampering (CloudTrail, Config, GuardDuty, log deletion), irreversible deletion, public exposure, spend commitments, and DNS and certificate changes.
   - **Writes run through a separate human-assumed role.** That role assumption is the human gate for Tier 4 and Tier 5 work. The agent role cannot modify its own boundary or policies.
   - **Environment is a first-class input.** One role per environment, with `aws:RequestedRegion` and `aws:ResourceAccount` conditions. An undeclared account or region is denied.

4. **Flat tool tiering at the host.** The module declares a tier per tool, with no attempt to classify script content:
   - `aws___run_script` takes the tier of the credentials it runs under. The default is Tier 5. It is lowered only when the posture declares a credential path whose policy has passed the conformance check as read-only, and never on the basis of what the script appears to do.
   - `aws___get_presigned_url` is a data-movement path and is tiered as a write.
   - The documentation, skill, region, and task tools are Tier 0, and their output is untrusted input.

5. **A conformance validator, `validate-aws-mcp-posture.sh`.** Opt-in and requiredArtifact-gated, modeled on `validate-foundry-target.sh`. It asserts the posture frontmatter's shape, and it checks the policy document the posture names (committed in the consumer's repo) against the never-allow set: every action in the set must be denied for the agent role. A second, operator-run mode checks the deployed role using IAM policy simulation, in the way `validate-agent-bus.sh` is operator-run against live state.

6. **Governed off-switches.** The module's sensitive paths cover the things that can disable the control: the posture document, the policy document, and MCP client configuration (`.mcp.json`, `.claude/settings*.json`, `.cursor/mcp.json`, `.vscode/mcp.json`), where an edit could add a second ungoverned AWS server, change the profile, or unpin the proxy. A companion rule requires a risk-register entry or an ADR when they change. The posture must also state that shell access to the `aws` CLI uses the same restricted role, since the context-key conditions apply only to calls made through the MCP server.

7. **Governance of what the toolkit installs on the agent side.** The toolkit is more than a server. Its plugins install hooks; one plugin sends opt-in telemetry; its rules files and the server's own instructions tell the agent to prefer the MCP tools over Bash for AWS work; `aws___retrieve_skill` pulls AWS-updatable instructions at runtime; `aws configure agent-toolkit` installs skills globally into every detected agent's configuration; and some plugins bind to other endpoints with a different authentication model. The module treats all of this as untrusted input: declared in the posture, pinned where pinning is possible, reviewed on change, and unable to alter tier posture.

8. **A `harness-aws` skill and templates.** The skill carries the tool tiers, the two-role model, the untrusted-input rules, and the audit plane. Templates live under `platform/templates/aws/` (posture, policy skeletons, risk register), plus an AWS entry in the consumer-facing `platform/templates/tools.md`. The repo-root `TOOLS.md` is not changed: this repo has no AWS surface, and that file's own rule is to list only tools active in the project.

### What makes the § 10 label honest

The binding is **Asserted-only** until part 5 exists. It becomes **Half-enforced** when the conformance validator ships with these tests:

- A canary corpus: a fixed set of known-dangerous actions that must be denied by any conforming agent policy. The safe configuration must pass and each canary must fail a policy that allows it.
- A default-deny test: an action absent from the pinned access-level snapshot is treated as denied, and a snapshot bump fails CI until new actions are triaged.
- A test that `aws___run_script` is never assigned a lower tier on the basis of script content.
- Fixtures for a malformed or missing policy document resolving to failure, not to a pass.

IAM is the enforcement point; the harness's contribution is the declared posture, the reference policy, and the check that the two agree.

## Origin / Evidence

- **First research pass and adversarial review (2026-11-17).** Three exploration agents produced the first draft; three review agents then re-derived the AWS facts from primary sources, checked the design against this repo's validators, and red-teamed the classification model. The revision note above summarizes what they overturned.
- **Primary sources read for this revision:** the [toolkit repository](https://github.com/aws/agent-toolkit-for-aws) (file tree, plugin manifests, MCP configuration, hooks, rules files); the [proxy repository](https://github.com/aws/mcp-proxy-for-aws) (argument handling, tool filter, changelog); the [AWS user guide for the toolkit](https://docs.aws.amazon.com/agent-toolkit/latest/userguide/) (tool reference, IAM, logging, multi-account access); and an unauthenticated tool listing from the server's public endpoint.
- **Evidence that `call_aws` was removed:** the live tool listing and the current tool reference do not include it; the proxy changelog records replacing its tests with `run_script` tests; and an open issue in the toolkit repository quotes the server's "has been removed" error. No AWS announcement of the removal was found.
- **Evidence from this repo:** `validate-trust-tier.sh` infers Tier 5 from a `\.tf$` or secrets pattern and fails a lower declared tier; `platform/agents/acp/` pairs its policy file with a reference engine, a conformance test, and two accepted PRDs; `delivery/production-saas` already governs IaC paths; `architectures/ai-foundry-target` already owns `aws-bedrock-agentcore` as a deployment landing zone.
- **Related proposals:** [OPP-0065](OPP-0065-govern-ruflo-runtime.md) (proposed, not yet built) names the anti-goals this binding also observes — do not take on the target's runtime footprint, and do not import its governance plugins. [OPP-0062](OPP-0062-a2a-agent-card-descriptor-layer.md) set the practice of marking external claims pending until confirmed.

## Why Now

AWS has named this toolkit the successor to the AWS Labs MCP servers and recommends moving to it, so it is where AWS agent tooling is consolidating. Its surface is also moving quickly: the tool the first draft was designed around was removed within four months of general availability, and a local proxy became optional in July 2026. A binding that anchors in IAM and declared posture, rather than in the shape of any one tool, is the kind that survives that churn. There is no external deadline.

## Risks / Open Questions

- **No AWS consumer exists yet.** Operating-principles § 9 says to ship a contract and validate it against real adoption before building enforcement on it. The PRD should stage the posture contract and reference policies first, and the validator second.
- **Unverified AWS behaviors (confirm before any implementation depends on them):**
  - Whether the MCP context keys survive transitive calls (for example, a Lambda function invoked through the server making its own calls). One third-party report says they do not.
  - Whether the server's CloudTrail events, which are data events (`eventSource` `aws-mcp.amazonaws.com`, `CallReadOnlyTool` and `CallReadWriteTool`), require explicit trail configuration to be captured.
  - Whether an authenticated tool listing differs from the unauthenticated one.
  - Whether the Service Authorization Reference is machine-readable and complete enough to drive the allow-list without large manual gaps. AWS's access levels are also known to be imperfect: some secret-bearing reads are labeled Read, which is why the curated set in part 3 is needed.
  - The specific action names in the never-allow set, which were drafted from memory during review and must be checked against current AWS documentation.
- **The managed server cannot be pinned.** A proxy version can be pinned; the server changes underneath every client, as the `call_aws` removal showed. The OAuth direct path has no proxy and no `--read-only` flag. The binding must not depend on any one tool's shape, and the posture should record the tool listing it was last verified against.
- **Hosts without a permission hook.** A headless agent has no prompt to answer. On such hosts the IAM boundary is the only control, which is the reason it is the anchor.
- **Trust-tier consequences for consumers.** If the module declares Tier 5, `validate-trust-tier.sh` may require `project.criticality` of `high` or `critical`; no current sample project has that. The PRD must confirm how the rule treats agent-family modules and add a sample project if needed.
- **Registration surface.** A new validator, skill, and template directory touch roughly twenty count and enumeration surfaces across the repo, several of them governance entrypoints whose edits require an ADR or an operating-principles update. The PRD must enumerate them; the first draft named two.
- **Prompt injection.** AWS-returned content (tags, log lines, object contents, documentation, retrieved skills) is attacker-influenceable model input. The IAM boundary limits the damage a successful injection can do; it does not prevent the injection. Whether the harness can require more than a skill-level discipline here is open.
- **Scope of the family.** Other AWS-managed MCP servers (EKS, ECS) carry the same context keys with different service principals. Whether one module covers them or each gets its own is left to the PRD.

## Disposition

<!--
Empty while Status: proposed. Populated when status flips to exploring,
accepted, declined, or superseded — on acceptance, a pointer to the spawned PRD.
-->

## Promotion

<!--
Empty until accepted. Then a link to PRD-NNNN. The breadth is well over a
half-day, so acceptance promotes to a PRD with staged implementation PRs,
each held at the merge gate.
-->
