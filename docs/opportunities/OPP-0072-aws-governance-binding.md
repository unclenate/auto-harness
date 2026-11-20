<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0072 — Govern agent access to AWS through the AWS MCP Server: an IAM-anchored `agents/aws-mcp` binding

**Status:** proposed
**Owner:** @unclenate
**Created:** 2026-11-17
**Last Updated:** 2026-11-19
**Confidence:** low (the design is in its third revision and the third is untested: no policy has been generated from it, nothing has been run under the proposed role, and there is no AWS consumer to try the contract against. The factual base is firmer than the design. The tool surface, IAM context keys, and audit events were re-read from AWS's current documentation and a live tool listing on 2026-11-17; a verification pass the same day settled the access-level data source, the seed action names, the limits of AWS's MCP condition keys, and the trust-tier mechanics; and a test in a sandbox AWS account the same day recorded what CloudTrail captures for `aws___run_script` calls, in one region and on the proxy path only)

---

## Revision note

This record was rewritten before merge, on its filing branch, after a three-reviewer adversarial pass on the first draft. The first draft proposed a `domains/aws` module with a per-operation tier-policy YAML that classified each `service:Action` at the agent host. The review found that design unbuildable and unsafe:

- **Its central tool no longer exists.** The first draft was built around a generic `call_aws` tool. AWS removed that tool between 2026-08-27 and 2026-09-03; no announcement or exact date was found. The draft's research relied on the May 2026 general-availability announcement, which is stale on the tool surface.
- **Nothing would have enforced it.** No component in any realistic deployment reads a policy YAML. Under operating-principles § 10 that is Asserted-only, not the Half-enforced the draft claimed.
- **Its classification model failed open.** A verb-prefix default left every unlisted verb without a tier and rated privilege escalation, sensitive reads, and audit-log tampering as approvable.
- **It failed this repo's own validators.** The proposed `tier.declared: 3` fails `validate-trust-tier.sh` against the proposed sensitive paths, and a `domains/` module's path-regex machinery never sees a tool call.

The design below replaces it. The thesis that AWS leaves per-action approval to the agent host survives; the mechanism changes from "classify at the host" to "enforce in IAM, prove by conformance."

A verification pass then worked through the risks the rewrite listed. Its results are folded in below. The largest change: AWS's MCP condition keys are **not** the anchor. AWS states they are absent when the same credentials are used outside the MCP server, and documents them for the first hop only. The anchor is a dedicated agent role whose limits are unconditional.

A second adversarial review, run after a test in a sandbox account, then found that the rewrite's own controls did not hold: the human write gate was not a gate, the allow-list admitted whatever AWS labels Read, the limits were implicit denies, and the validator could not vouch for the deployed role. The **third revision** below answers those findings. Four things changed:

- **The allow-list is inverted.** Only actions a person has reviewed are allowed, inside services the posture declares. AWS's access-level label proposes candidates and admits nothing.
- **The limits are explicit denies.** A service ceiling and an agent deny set hold against grants made from the resource side.
- **No write role reaches the agent.** Writes go through a reviewed pipeline or a specified human-assumed role, and the agent's environment may resolve only the agent role.
- **The policy is generated and compared, and tier lowering needs a live check.** The validator never interprets IAM policy; it checks that the committed and deployed documents are the generated ones.

The findings and what each answer leaves open are under Risks.

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

- **`aws___run_script` is the only tool that runs arbitrary AWS API calls, and its input is one free-form Python `code` string.** The agent host sees opaque code, not an operation name. The script can build its API calls dynamically, so static inspection of the code is defeatable. AWS's own `secret-safety` hook is reported in an open toolkit issue not to block even a literal secret read made through this tool, and dynamic construction would defeat a fix.
- **AWS documents no per-call human approval.** Its guidance for approval before sensitive use is to "configure client-side hooks or permission rules in your MCP client." What AWS does provide is coarse: tool annotations, a proxy `--read-only` flag that removes every non-read-only tool (which today removes all AWS API access), an OAuth consent page, a profile allow-list, and one blocking hook shipped in the `aws-core` plugin.
- **AWS marks requests the server makes, but only on that one path.** The first-hop request the server makes with the caller's credentials carries `aws:ViaAWSMCPService` (Boolean) and `aws:CalledViaAWSMCP` (the service principal, `aws-mcp.amazonaws.com`), usable in identity policies and service control policies. Neither key marks a request made with the same credentials through the AWS CLI, an SDK, or a shell: AWS says `aws:CalledViaAWSMCP` is absent there, and its sources disagree on `aws:ViaAWSMCPService` (the IAM reference says it returns `false`; an [AWS Security Blog post](https://aws.amazon.com/blogs/security/secure-ai-agent-access-patterns-to-aws-resources-using-model-context-protocol/) says it is absent), so templates must be correct under both readings. The same post puts it this way: "the agent has two paths to the same AWS API, and differentiation controls govern one path." A third key, `aws:IsMcpServiceAction`, marks an MCP service's own actions and does not apply to downstream calls. Nothing AWS publishes says the keys persist past the first hop (for example, on calls made by a Lambda function's execution role). The server defines no IAM actions of its own.

### The gap

Per-action control over what an agent may do in AWS exists only where the consumer writes IAM policy by hand. The agent host cannot supply it, because the host cannot see operations. Nothing connects a project's declared intent ("this agent reads metadata in the sandbox account and nothing else") to the policy that would make it true, and nothing checks the two against each other.

### The proposal

Govern the AWS MCP Server as an external target, in the reference-tool posture `agents/acp` established ([PRD-0037](../requirements/PRD-0037-acp-governance-bridge.md), [PRD-0038](../requirements/PRD-0038-acp-governance-proxy-reference.md)): the harness ships a contract, reference material, and a conformance check, and does not vendor or run the toolkit. This is the third revision of the design; the revision note says what changed and why. The binding has nine parts. Full specification is deferred to a PRD on acceptance.

1. **An agents-family module, `platform/agents/aws-mcp/`.** The repo's taxonomy puts tool-seam governance under Agents ("AI-tool operating packs"); the only existing tier-policy lives in `platform/agents/acp/`. Governance of IaC and deploy file paths stays with `delivery/production-saas`, which already owns `^terraform/`, `^deploy/`, and `^infra/`. The module declares a low baseline `tier.declared` and a low `maxTier` ceiling, because the agent's own reach into AWS is read-only and no write role is ever connected to the agent (part 4). That is what a low ceiling expresses (it caps and never grants). No shipped agent module uses a low ceiling yet: `agents/openclaw` declares a baseline of 2 with a ceiling of 5. Checked against `validate-trust-tier.sh`: the module's own sensitive paths match none of the validator's Tier 4 or Tier 5 samples, and the rule that a declared Tier 5 requires `project.criticality` of `high` or `critical` applies to agent modules too, which no sample project could satisfy.

2. **A declared posture artifact, `docs/aws/aws-mcp-posture.md`.** Frontmatter declares:
   - each AWS account with an environment class (sandbox, non-production, production), and the permitted regions;
   - the AWS services in scope (the agent role is denied every other service);
   - the agent's role per environment, and the paths of its committed policy and trust documents;
   - the hash of the access-level snapshot and of the reviewed read set the policy was generated from;
   - the connection path (the SigV4 proxy only, in this revision) and the proxy version pin, which must be at or above a floor the module sets;
   - how the agent's credentials are isolated (part 5), and every credential the agent's environment can resolve;
   - the write path (part 4);
   - the agent host, and whether it records submitted scripts (part 6);
   - the toolkit plugins installed, and the date of the tool listing the posture was last checked against;
   - the path of the latest live-check attestation (part 7).

3. **A dedicated agent role whose limits are explicit denies.** The agent gets its own IAM role in each environment. Its policy has three layers, and each fails closed in the direction it can:
   - **A service ceiling.** One statement denies every action outside the declared services: `Deny` with `NotAction` listing a `service:*` entry per declared service. It is short, it is explicit, and a service AWS adds later is denied without anyone updating the policy.
   - **An agent deny set.** Explicit `Deny` statements for the actions the agent must never hold whatever AWS labels them: role assumption and every other credential-minting action, all identity and permissions writes, secret and data-content reads, remote execution, and audit-plane changes. The appendix seeds it. Because these are explicit denies they also defeat a grant made from the other side, such as a resource policy or another role's trust policy that names the agent role.
   - **An enumerated allow.** `Allow` statements list each permitted action by full name, with no wildcards and no `NotAction`. The list is the **reviewed read set**: actions a person has reviewed and admitted, service by service. AWS's access-level metadata proposes candidates (List-level actions first) and is never the admission rule, so an action AWS has not annotated, or has labeled Read while it executes code, mints a token, or returns a secret, is not admitted by default. An action AWS adds later is in no list and stays denied.
   - **Environment denies.** Explicit `Deny` for any region outside the declared set (`aws:RequestedRegion`) and any resource outside the role's own account (`aws:ResourceAccount`).
   - **The same documents are the role's permissions boundary.** A policy attached to the role later cannot widen it, and the deny set covers the actions that would change the boundary.

   Sizing drives the service scoping. A snapshot of AWS's Service Authorization Reference taken 2026-11-17 covers 458 services and 22,651 actions, 9,838 of them List or Read; enumerating those would take about 330,000 characters against a managed-policy limit of 6,144. Every List and Read action of ten common services comes to about 26,600 characters, which fits in a handful of managed policies before any review removes actions. The snapshot carries no content version and no retrievable history, so the consumer vendors it and records its hash.

   One residual is left and is stated, not hidden: inside a declared service, an action that is neither in the reviewed read set nor in the deny set is denied only implicitly. A same-account resource policy that names the agent role's session could grant it. The live check in part 7 looks for this, and an organization can close it with a service control policy.

4. **No write role is ever connected to the agent.** The second revision gated writes on a person assuming a write role. That is not a gate: IAM cannot tell a person from an agent running as the same operating-system user, and a session, once assumed, accepts opaque scripts until it expires. This revision removes the write role from the agent's reach altogether.
   - **The default write path is the consumer's reviewed delivery pipeline.** The agent proposes a change as infrastructure code; a person reviews it; the pipeline's own role applies it. Review by someone other than the author is the second human the kernel trust model requires for Tier 5. The reference form is a deployment environment with required reviewers on the code host, whose role the pipeline obtains by federation, so the approval is held off the agent's machine and the write credential never reaches it. With a single maintainer the approver and the author are one identity, and the gate is then only as strong as the separation between that person's review credential and the agent.
   - **A human-assumed role is specified for work the pipeline cannot do.** Its trust policy names specific human identities and not the account; requires MFA where the identity type exposes it (with an identity-provider MFA requirement as the documented substitute for federated sign-in); requires a source identity to be set, so the session is attributable; and caps the session at one hour, the shortest maximum IAM allows. It carries its own **write-path exclusions**: identity and permissions changes, organization changes, and audit-plane changes are not available through it. Tier 5 work done this way needs a recorded second sign-off, which the harness can only ask for.
   - **No approval step is built for agent-driven writes, by decision.** A search of this repo on 2026-11-19 found no mechanism, built or proposed, that lets a person approve an agent's action over a channel the agent cannot also reach: the `agents/acp` proxy's Tier 4 prompt is answered over the editor's own channel, the coordination bus is unauthenticated files with no approve message, and the audit chain in PRD-0040 is keyless. The proxy's Tier 5 behavior, which refuses at the seam without asking, is the piece this binding reuses for `aws___run_script` under any credential but the agent role.
   - **Neither role appears in any MCP client configuration.** The repo check in part 7 fails a committed client configuration that names an AWS profile other than the agent's.
   - **Any other credential is outside the binding.** If the server is connected under anything but the declared agent role, `aws___run_script` stays at Tier 5 and the kernel's rule applies: explicit human direction and a second sign-off for each action.

5. **The agent's environment can resolve only the agent role.** The limits in part 3 hold on every path that uses the agent role. They say nothing about a broader credential the agent can reach, so the binding requires that there is none. The posture declares the isolation mechanism: a separate operating-system user, a container, or a remote sandbox, whose AWS configuration contains the agent role and nothing else. A developer laptop where the agent runs as the developer cannot meet this, and the posture must then declare isolation as `none`, which keeps `aws___run_script` at Tier 5. The account test recorded under Risks was run in exactly that unisolated condition.

6. **Flat tool tiering at the host, with a named reader.** The module declares a tier per tool and ships a reference binding for each supported host, starting with Claude Code: permission rules for the server's tools in the committed settings file, and a pre-call hook that records the text of each submitted script before it is sent. The repo check asserts that the committed host configuration carries the binding. On a host with no binding the tiers are advice.
   - `aws___run_script` is Tier 5 by default. It is lowered to the module's baseline only when three things are all true: the posture declares an isolation mechanism other than `none`; a live-check attestation is current for the role (part 7); and the host records submitted scripts. It is never lowered on the basis of what a script appears to do.
   - `aws___get_presigned_url` is a data-movement path, tiered as a write, and denied by the reference binding. The agent role holds no S3 object actions, so a URL it obtained should fail when used; that is untested.
   - The documentation, skill, region, and task tools are Tier 0, and their output is untrusted input.

7. **A conformance validator, `validate-aws-mcp-posture.sh`, in two modes. Neither evaluates IAM policy semantics.** Deciding what an arbitrary policy denies is beyond a shell validator, so the policy documents are generated, by a reference generator the module ships, from the posture, the reviewed read set, and the agent deny set. The checks are comparisons.
   - **Repo mode (CI, offline).** Asserts the posture's shape; regenerates the policy and trust documents and fails on any difference from the committed ones, so a hand-edited statement, a wildcard allow, or a conditional deny cannot pass; asserts the recorded snapshot and read-set hashes; asserts that every action in the reviewed read set exists in the snapshot and none is in the deny set; asserts that committed MCP client configuration names one AWS server, the agent's profile, and a proxy version at or above the floor; asserts the host binding is present; and asserts that a manifest declaring an account of class `production` has `project.criticality` of `high` or `critical`. Opt-in and requiredArtifact-gated, modeled on `validate-foundry-target.sh`.
   - **Live mode (operator-run, needs the AWS CLI and read access to IAM).** Fetches the deployed role's attached and inline policies, its permissions boundary, and its trust policy, and compares each with the committed documents; fails on any extra attachment; lists the credentials the agent's environment can resolve and fails on any but the agent role; and reports resource policies that grant to the agent role where AWS's analysis tools can find them. It may also ask IAM Access Analyzer whether the policy grants any canary action. It writes a dated attestation holding the hashes it compared and the result. The attestation is void when the policy, the snapshot, the read set, or the posture changes, and it expires. This would be the first validator in the repo to need a cloud CLI and credentials; it runs only for consumers who adopt the module, and never in this repo's CI.

8. **Governed off-switches.** The module's sensitive paths cover the things that can disable the control: the posture, the policy and trust documents, the reviewed read set, the attestation, the host binding, and MCP client configuration (`.mcp.json`, `.claude/settings*.json`, `.cursor/mcp.json`, `.vscode/mcp.json`), where an edit could add a second AWS server, change the profile, or unpin the proxy. A companion rule requires a risk-register entry or an ADR when they change. Configuration written at user level, outside the repo, is invisible to these rules; live mode inspects it at the moment it runs, and between runs it is trusted. The OAuth paths, including the client-credentials flow that needs no browser, are not supported connection paths in this revision, and the `signin` actions that control them are in the agent deny set.

9. **Agent-side installs, a skill, and templates.** The toolkit is more than a server. Its plugins install hooks; one plugin sends opt-in telemetry; its rules files and the server's own instructions tell the agent to prefer the MCP tools over Bash for AWS work; `aws___retrieve_skill` pulls AWS-updatable instructions at runtime; `aws configure agent-toolkit` installs skills globally into every detected agent's configuration; some plugins bind to other endpoints with a different authentication model; and the server advertises prompts and resources as well as tools. The module treats all of this as untrusted input: declared in the posture, pinned where pinning is possible, reviewed on change, and unable to alter tier posture. A `harness-aws` skill carries the tool tiers, the role model, the untrusted-input rules, and the audit plane. Templates live under `platform/templates/aws/` (posture, generated-policy inputs, a starter reviewed read set for a small number of services, risk register), plus an AWS entry in the consumer-facing `platform/templates/tools.md`. The repo-root `TOOLS.md` is not changed: this repo has no AWS surface, and that file's own rule is to list only tools active in the project.

The MCP condition keys remain an optional backstop and never the anchor. An organization may add a service control policy that denies writes made through the server for all principals. The templates use only the forms AWS documents: `Deny` with `Bool` on `aws:ViaAWSMCPService` equal to `true`, or with `StringEquals` on `aws:CalledViaAWSMCP`. They never use `BoolIfExists`, and never a negated operator on `aws:CalledViaAWSMCP` without the `Bool` test beside it, because both forms also match traffic that did not come through the server.

### What the audit plane is relied on for

CloudTrail is declared as the record of which identity called `aws___run_script` and which management-plane APIs ran with what result, which is what the account test observed. It is not relied on for the script text (the host records that, part 6), for sessions that never run a script, or for data-plane outcomes, which need data-event logging the posture must declare separately. The role session name is chosen by the caller and is not treated as attribution.

### What makes the § 10 label honest

The label is given per part, because the parts do not share an enforcement point. Everything is **Asserted-only** until the validator exists.

| Part | Label once the validator ships | What enforces or checks it |
| --- | --- | --- |
| 2, 3 (posture and agent policy) | Half-enforced | Repo mode binds the committed policy to the reviewed inputs; IAM enforces the policy only if the consumer deploys it |
| 4 (write path) | Half-enforced for the client-configuration check; Asserted-only for the pipeline, the trust policy in use, and the second sign-off | Repo mode; otherwise the consumer's process |
| 5 (credential isolation) | Asserted-only between live checks | Live mode, at the moment it runs |
| 6 (host tiering) | Half-enforced on a host with a committed binding; Asserted-only elsewhere | The host's own permission system |
| 7 (live attestation) | Half-enforced | A committed, dated record an operator produced; the harness cannot verify it was run honestly |
| 8, 9 (off-switches, installs) | Half-enforced for repo paths; Asserted-only for user-level configuration | Companion rules |

The validator ships with these tests:

- A canary corpus: a fixed set of known-dangerous actions, including ones AWS labels Read. A generated policy must deny each explicitly, and a reviewed read set that contains one must fail.
- Shape rejection: fixtures with a `NotAction` allow, a wildcard allow, a conditional or resource-scoped deny, and an added statement each fail the comparison.
- A default-deny test: an action absent from the reviewed read set is not allowed by the generated policy, and a snapshot bump fails CI until new actions in declared services are triaged.
- A test that `aws___run_script` is never assigned a lower tier on the basis of script content, and that it stays at Tier 5 when the attestation is missing, stale, or void.
- Fixtures for a malformed or missing policy document or attestation resolving to failure, not to a pass.

IAM is the enforcement point; the harness's contribution is the declared posture, the generated policy, and the checks that the committed and deployed documents are the generated ones.

## Origin / Evidence

- **First research pass and adversarial review (2026-11-17).** Three exploration agents produced the first draft; three review agents then re-derived the AWS facts from primary sources, checked the design against this repo's validators, and red-teamed the classification model. The revision note above summarizes what they overturned.
- **Primary sources read for this revision:** the [toolkit repository](https://github.com/aws/agent-toolkit-for-aws) (file tree, plugin manifests, MCP configuration, hooks, rules files); the [proxy repository](https://github.com/aws/mcp-proxy-for-aws) (argument handling, tool filter, changelog); the [AWS user guide for the toolkit](https://docs.aws.amazon.com/agent-toolkit/latest/userguide/) (tool reference, IAM, logging, multi-account access); an unauthenticated tool listing from the server's public endpoint; and the AWS Security Blog post linked in the Thesis.
- **Account test and second review (2026-11-17).** A test in an unused sandbox AWS account produced the observations under Risks. Four review agents then checked the record against the test evidence, this repo, AWS's current sources, and an attacker's view; the same section lists what they found.
- **Evidence that `call_aws` was removed:** the live tool listing and the current tool reference do not include it; the proxy changelog records replacing its tests with `run_script` tests; and an open issue in the toolkit repository quotes the server's "has been removed" error. No AWS announcement of the removal was found.
- **Evidence from this repo:** `validate-trust-tier.sh` infers Tier 5 from a `\.tf$` or secrets pattern and fails a lower declared tier; `platform/agents/acp/` pairs its policy file with a reference engine, a conformance test, and two accepted PRDs; `delivery/production-saas` already governs IaC paths; `architectures/ai-foundry-target` already owns `aws-bedrock-agentcore` as a deployment landing zone.
- **Related proposals:** [OPP-0065](OPP-0065-govern-ruflo-runtime.md) (proposed, not yet built) names the anti-goals this binding also observes — do not take on the target's runtime footprint, and do not import its governance plugins. [OPP-0062](OPP-0062-a2a-agent-card-descriptor-layer.md) set the practice of marking external claims pending until confirmed.

## Why Now

AWS has named this toolkit the successor to the AWS Labs MCP servers and recommends moving to it, so it is where AWS agent tooling is consolidating. Its surface is also moving quickly: the tool the first draft was designed around was removed within four months of general availability, and a local proxy became optional in July 2026. A binding that anchors in IAM and declared posture, rather than in the shape of any one tool, is the kind that survives that churn. There is no external deadline.

## Risks / Open Questions

### Settled or mitigated by the verification pass (2026-11-17)

- **Condition keys across transitive calls and outside the server.** AWS documents only the first hop, and the keys do not mark requests made outside the server. The mitigation first claimed for this (unconditional limits and no write actions) was reopened by the second review; the third revision's answer is explicit denies on the agent role (part 3).
- **Machine-readability of the access-level metadata.** Confirmed, complete against the HTML reference, and unversioned. Mitigated by vendoring a hashed snapshot (parts 2 and 7). The third revision uses the metadata to propose candidates for review and no longer as the admission rule.
- **Deny-set action names drafted from memory.** 131 candidates were checked against the snapshot: 129 exact, one wrong prefix corrected, one not an IAM action and dropped. The verified seed is in the appendix.
- **Trust-tier consequence for consumers.** Read from `validate-trust-tier.sh`; resolved by a low baseline and ceiling, with the criticality check moved to the posture validator (parts 1 and 7).
- **STS and assumed-role support.** Supported by the server and proxy. The agent role denies role assumption explicitly.

### Observed in a test in a sandbox AWS account (2026-11-17)

One single-region trail, one role carrying AWS's managed `ReadOnlyAccess` policy, and four tool calls through the server by way of the SigV4 proxy (version 1.8.0, resolved from `latest` and not pinned) in `us-east-1`: three `aws___run_script` calls (an identity read, a list, and a write the role does not allow) and one `aws___list_regions` call. The tool calls ran as that role; setup and teardown ran as an administrator user from the same shell. The test resources were deleted afterwards and a check found none remaining.

- **`aws___run_script` calls are recorded as management events.** Each produced a `CallReadWriteTool` event from `aws-mcp.amazonaws.com` with `eventType` `AwsMcpEvent` and `eventCategory` `Management`. The events appeared in Event history and were delivered to S3. The trail logged all management events plus one data-event type, `AWS::AgentAccessMCP::Tools`, the only MCP-named type CloudTrail accepted; AWS lists that type under Amazon WorkSpaces Applications and it matched nothing. Because the events are management events a default trail should capture them, but a default trail was not itself tested. AWS documents no data-event type for the AWS MCP Server, and four guessed type names were rejected.
- **The other calls left no record.** The `aws___list_regions` call, session initialization, and tool listing produced no event in Event history about eleven and a half minutes after the call, nor in the two log files delivered before teardown. The trail was then deleted, so later delivery cannot be ruled out. Six of the eight tools are read-only tools like this one.
- **The submitted script is not recorded.** The event names the tool, but the tool arguments, the request metadata, and the result are each replaced with a redaction placeholder. A unique marker placed as a comment in each script appeared nowhere in Event history or the delivered log files. Values a script passes to an AWS API can still surface downstream: the denied call's error message carried the queue name.
- **The downstream calls are recorded and can be joined.** Each tool-call event lists its downstream requests by API name, region, and request ID, and each request ID matched an ordinary CloudTrail event for that call. Those events carry the agent role as the identity and `aws-mcp.amazonaws.com` in `invokedBy`, `sourceIPAddress`, and `userAgent`. All three downstream calls were management-plane calls.
- **The outcome lives on the downstream event only.** The denied write appeared as `AccessDenied` on its own event. The tool-call event for it carried no error code, and all three tool-call events were marked `readOnly` false, including the two whose scripts only read.
- **The authenticated tool listing matches the unauthenticated one.** The same eight tools with the same descriptions, schemas, and annotations. Only `aws___run_script` and `aws___list_regions` were exercised.
- **IAM applied on this path.** Both reads succeeded as the role and the write was refused by an implicit deny. This does not test the proposed policy: explicit denies, permission boundaries, and conditions were not exercised.

AWS's documentation and the observed service disagree on four points. AWS's sample record shows `eventCategory` `Data`, an exact copy of the request parameters, and `readOnly` true; the test observed `Management`, redacted parameters, and `readOnly` false. AWS's logging page says all actions for authenticated tools are logged; one of four tool calls was not. The AWS Security Blog post cited above says downstream calls are data events that need data-event logging; the three observed were ordinary management events. `AwsMcpEvent` is not in CloudTrail's list of event types, and the API reference the logging page links to does not resolve. The observed shape should be treated as unstable.

So CloudTrail can show which identity called `aws___run_script` and which management-plane AWS APIs ran with what result. It did not record the read-only tool call, and it cannot show what code was submitted.

### Found by the second adversarial review (2026-11-17), and how the third revision answers each

Four reviewers checked the second revision against the test evidence, this repo, AWS's current sources, and an attacker's view. The findings are kept here as the reasons for the third revision. None of the answers has been tested: no policy has been generated, and nothing has been run under the proposed role.

- **The human write gate was not a gate.** IAM cannot tell a person from an agent running as the same operating-system user, so an agent whose shell reached the base profile could assume the write role itself; the trust policy was unspecified; a session accepts opaque scripts until it expires; and the kernel requires a second human for Tier 5. *Answer:* no write role is connected to the agent, writes go through a reviewed pipeline or a specified human-assumed role, and the agent's environment may resolve only the agent role (parts 4 and 5). *Left open:* on a machine where the agent runs as the developer, isolation is `none` and the binding only keeps the tool at Tier 5.
- **The allow-list rule failed open.** Read is the level left when no other flag is set, so an unannotated action was allowed. The snapshot labels as Read actions that execute remotely (`bedrock:InvokeAgent`, `sagemaker:InvokeEndpoint`, `ssm:ExecuteAPI`), mint credentials or tokens (`s3:GetDataAccess`, `sts:GetServiceBearerToken`, `signin:CreateOAuth2Token`), disclose secrets (`secretsmanager:BatchGetSecretValue`, `acm:ExportCertificate`), or have side effects (`sqs:ReceiveMessage`). `IsDataPlane` is true for 251 of the 9,838 Read and List actions and absent for 1,923, so it can seed a review but not replace one. *Answer:* the rule is inverted; only reviewed actions are allowed and AWS's label only proposes candidates (part 3). *Left open:* the reviewed read set does not exist yet, and List-level actions leak too (`ec2:DescribeInstanceAttribute` returns user data), so List is a starting point for review and not a safe default.
- **The limits were implicit denies.** A same-account resource policy, or another role's trust policy naming the agent role, could grant access with no allow on the agent's side, and an enumerated allow-list of thousands of actions would not fit a managed policy. *Answer:* the service ceiling and the agent deny set are explicit denies, and the allow is scoped to declared services so it fits (part 3). *Left open:* the residual named in part 3, for unlisted actions inside a declared service.
- **The validator could pass an unsafe policy, and a committed file is not the deployed role.** A `NotAction` allow, a conditional or resource-scoped deny, or a wildcard got past a canary check, and no validator in this repo evaluates IAM semantics. *Answer:* the policy is generated and the validator compares; live mode compares the deployed role with the committed documents; tier lowering needs a current attestation (parts 6 and 7). *Left open:* the attestation is an operator's committed word, and live mode is the first validator here to need cloud credentials.
- **The audit plane has further blind spots.** A session that never calls `aws___run_script` leaves no MCP event; data-plane outcomes need data-event logging; a presigned URL is used outside the server; the role session name is chosen by the caller. *Answer:* the design states what CloudTrail is relied on for and moves script capture to the host. *Left open:* AWS documents per-tool CloudWatch metrics for the server; these were not tested.
- **Paths around the declared connection.** AWS offers an OAuth client-credentials flow that needs no browser or consent page, controlled by two `signin` actions the snapshot labels Read; the proxy's `--read-only` flag is reported to have been bypassable by a direct tool call before version 1.6.4; and toolkit configuration is also written at user level. *Answer:* the SigV4 proxy is the only supported path, the `signin` actions are denied, the pin has a floor, and live mode inspects user-level configuration (parts 2, 7, and 8). *Left open:* user-level configuration between live checks.
- **Three sets shared the name never-allow.** *Answer:* they are now the agent deny set, the reviewed read set, and the write-path exclusions. The appendix seeds the first and cannot serve as the third, because it contains ordinary deploy actions.
- **Host tool tiering named no reader.** *Answer:* a reference host binding and a per-part enforcement label (part 6 and the § 10 table).
- **Smaller gaps.** The posture now carries the fields later parts need (part 2). The environment class is still self-attested. Scripts can call built-in helper modules that make AWS calls without naming an operation, which is one more reason the design never reads script content.

### Still open

- **The third revision is untested.** Before acceptance, or as the PRD's first gate, the account test should be repeated under a generated policy for a few declared services, from an environment that can resolve only the agent role. It should include a resource-policy grant aimed at the agent role, a role whose trust policy names it, a region outside the declared set, and a presigned URL.
- **Whether the reviewed read set is affordable.** It is per-service review work that must be redone when the snapshot changes; a re-fetch later the same day found 16 added actions. Decided 2026-11-19: the harness ships a reviewed starter set for a small number of common services and consumers extend it, with their additions checked by repo mode against the deny set and the snapshot. Which services, who maintains the starter set as AWS adds actions, and whether that is enough for a real adopter are still open; the repeat account test is the first evidence. A design that is safe but too costly to adopt fails operating-principles § 9 in a different way.
- **Side effects of the environment denies.** A deny on resources outside the role's own account will also block reads of AWS-owned and shared resources, such as public machine images and AWS-managed policies. The PRD must find the exceptions by test.
- **The script text has no AWS-side record.** The reference host binding records it before the call is sent. On a host with no binding nothing does, and the tool stays at Tier 5.
- **Limits of the account test.** One account, one region, one day, and the proxy path only; neither OAuth path was exercised, and six of the eight tools were not called. Whether read-only tools are unrecorded or are logged somewhere the test trail did not capture was not followed up. The event shape is undocumented in any API reference and can change server-side.
- **No AWS consumer exists yet.** Operating-principles § 9 says to ship a contract and validate it against real adoption before building enforcement on it. The PRD should stage the posture contract and reference policies first, and the validator second.
- **The managed server cannot be pinned.** A proxy version can be pinned; the server changes underneath every client, as the `call_aws` removal showed, and the OAuth direct path, which this revision does not support, has no proxy and no `--read-only` flag. The binding does not depend on any one tool's shape, and the posture records the tool listing it was last verified against.
- **What the script tool can reach.** The tool's description says the sandbox has no network access except through its AWS call helper. AWS documents no restriction on which services a script may call (a toolkit issue reports an undocumented per-script service cap) and no completeness guarantee for the `api_calls` list in its response. The design assumes a script can call anything the role allows and treats `api_calls` as informational.
- **Hosts without a permission hook.** A headless agent has no prompt to answer and may have no binding. On such hosts the agent role is the only control, which is the reason it is the anchor.
- **Registration surface.** A new validator, a policy generator, a skill, and a template directory touch roughly twenty count and enumeration surfaces across the repo, several of them governance entrypoints whose edits require an ADR or an operating-principles update. The PRD must enumerate them.
- **Prompt injection.** AWS-returned content (tags, log lines, object contents, documentation, retrieved skills) is attacker-influenceable model input. A read-only agent role limits what a successful injection can do; it does not prevent the injection, and it does not stop disclosure of whatever the role can read.
- **Other AWS-managed MCP servers.** The EKS and ECS servers are in preview, still require their own IAM actions, and AWS's list of service principals is given as examples. Whether one module covers them is left to the PRD.

## Appendix — verified seed for the agent deny set

Checked against the Service Authorization Reference snapshot of 2026-11-17. Every action here is denied explicitly on the agent role. Actions marked (R) or (L) are labeled Read or List by AWS, which is why the label cannot be the admission rule. The list is a seed for the agent deny set and not the write-path exclusions: it contains ordinary deploy actions that a pipeline role needs.

- **Identity and permissions:** `iam:CreateRole`, `iam:AttachRolePolicy`, `iam:PutRolePolicy`, `iam:CreateAccessKey`, `iam:CreatePolicyVersion`, `iam:SetDefaultPolicyVersion`, `iam:PassRole`, `iam:DeleteRolePermissionsBoundary`, `iam:PutRolePermissionsBoundary`, `iam:UpdateAssumeRolePolicy`, `iam:GetAccountAuthorizationDetails` (R), `iam:GetCredentialReport` (R), `sso:CreateAccountAssignment`, `identitystore:CreateUser`, `organizations:LeaveOrganization`, `organizations:AttachPolicy`, `organizations:CloseAccount`, `account:CloseAccount`.
- **Credential minting and secret reads:** `sts:AssumeRole`, `sts:GetFederationToken`, `sts:GetSessionToken` (R), `sts:GetServiceBearerToken` (R), `signin:CreateOAuth2Token` (R), `signin:AuthorizeOAuth2Access` (R), `s3:GetDataAccess` (R), `secretsmanager:BatchGetSecretValue` (R), `acm:ExportCertificate` (R), `secretsmanager:GetSecretValue` (R), `ssm:GetParameter` (R), `ssm:GetParameters` (R), `ssm:GetParametersByPath` (R), `ecr:GetAuthorizationToken` (R), `codeartifact:GetAuthorizationToken` (R), `cognito-identity:GetCredentialsForIdentity` (R), `redshift:GetClusterCredentials`, `rds-db:connect`, `lambda:GetFunction` (R), `ec2:GetPasswordData` (R), `ec2:GetConsoleOutput` (R), `ec2:DescribeInstanceAttribute` (L), `kms:Decrypt`.
- **Code execution and confused deputies:** `ssm:SendCommand`, `ssm:StartSession`, `ssm:ExecuteAPI` (R), `bedrock:InvokeAgent` (R), `bedrock:InvokeModel` (R), `sagemaker:InvokeEndpoint` (R), `ecs:ExecuteCommand`, `lambda:CreateFunction`, `lambda:UpdateFunctionCode`, `lambda:UpdateFunctionConfiguration`, `lambda:InvokeFunction`, `ec2:RunInstances`, `codebuild:StartBuild`, `glue:CreateJob`, `glue:UpdateDevEndpoint`, `sagemaker:CreatePresignedNotebookInstanceUrl`, `ecs:RunTask`, `ecs:RegisterTaskDefinition`, `states:StartExecution`, `cloudformation:CreateStack`, `cloudformation:UpdateStack`, `cloudformation:ExecuteChangeSet`, `events:PutTargets`, `scheduler:CreateSchedule`.
- **Resource policy, sharing, and exposure:** `s3:PutBucketPolicy`, `s3:PutBucketAcl`, `s3:PutObjectAcl`, `s3:PutBucketPublicAccessBlock`, `s3:PutAccountPublicAccessBlock`, `lambda:AddPermission`, `lambda:CreateFunctionUrlConfig`, `sns:AddPermission`, `sns:SetTopicAttributes`, `sqs:SetQueueAttributes`, `sqs:AddPermission`, `ecr:SetRepositoryPolicy`, `kms:PutKeyPolicy`, `kms:CreateGrant`, `secretsmanager:PutResourcePolicy`, `logs:PutResourcePolicy`, `ec2:ModifySnapshotAttribute`, `ec2:ModifyImageAttribute`, `rds:ModifyDBSnapshotAttribute`, `ram:CreateResourceShare`, `ec2:AuthorizeSecurityGroupIngress`, `rds:ModifyDBInstance`.
- **Audit-plane tampering:** `cloudtrail:StopLogging`, `cloudtrail:DeleteTrail`, `cloudtrail:UpdateTrail`, `cloudtrail:PutEventSelectors`, `config:StopConfigurationRecorder`, `config:DeleteDeliveryChannel`, `guardduty:DeleteDetector`, `guardduty:UpdateDetector`, `securityhub:DisableSecurityHub`, `logs:DeleteLogGroup`, `logs:PutRetentionPolicy`, `cloudwatch:DeleteAlarms`, `cloudwatch:DisableAlarmActions`, `ec2:DeleteFlowLogs`, `s3:PutBucketLogging`, `access-analyzer:DeleteAnalyzer`, `macie2:DisableMacie`.
- **Irreversible deletion:** `s3:DeleteBucket`, `s3:PutLifecycleConfiguration`, `s3:PutBucketVersioning`, `dynamodb:DeleteTable`, `rds:DeleteDBInstance`, `rds:DeleteDBCluster`, `ec2:DeleteSnapshot`, `ec2:TerminateInstances`, `backup:DeleteRecoveryPoint`, `kms:ScheduleKeyDeletion`, `kms:DisableKey`.
- **Spend commitment:** `ec2:PurchaseReservedInstancesOffering`, `savingsplans:CreateSavingsPlan`, `route53domains:RegisterDomain`, `route53domains:TransferDomain`, `aws-marketplace:Subscribe`, `servicequotas:RequestServiceQuotaIncrease`, `bedrock:CreateProvisionedModelThroughput`, `shield:CreateSubscription`.
- **DNS, certificates, and edge:** `route53:ChangeResourceRecordSets`, `acm:RequestCertificate`, `acm:DeleteCertificate`, `acm:ImportCertificate`, `cloudfront:UpdateDistribution`.
- **Data movement:** `s3:GetObject` (R), `s3:PutObject`, `dynamodb:Scan` (R), `dynamodb:Query` (R), `logs:GetLogEvents` (R), `logs:FilterLogEvents` (R), `sqs:ReceiveMessage` (R), `rds:StartExportTask`, `ec2:CreateSnapshot`, `ebs:GetSnapshotBlock` (R), `athena:StartQueryExecution`, `rds-data:ExecuteStatement`, `redshift-data:ExecuteStatement`.

Corrections made during verification: `sso-admin:CreateAccountAssignment` is `sso:CreateAccountAssignment`; `sso:GetRoleCredentials` is not an IAM action and cannot be denied in policy; `account:CloseAccount` was first dropped as a console-only permission; the second review found it in the snapshot as a Write action, and it is listed beside `organizations:CloseAccount`. The Read-labeled actions the second review found were added on 2026-11-17 and checked against the same snapshot. `iam:PassRole` and `rds-db:connect` are permissions rather than API operations and are valid in policy.

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
