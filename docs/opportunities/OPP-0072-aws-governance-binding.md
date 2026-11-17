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
**Confidence:** low (lowered from medium on 2026-11-17 after a second adversarial review found defects in the write gate, the allow-list rule, and the validator's reach that must be resolved before acceptance; see the review section under Risks. The factual base is firmer than the design: the tool surface, IAM context keys, and audit events below were re-read from AWS's current documentation and a live tool listing on 2026-11-17, and the harness-side findings were checked against the validators on disk; a follow-up verification pass the same day settled the allow-list data source, the never-allow action names, the limits of AWS's MCP condition keys, and the trust-tier mechanics; a test in a sandbox AWS account the same day settled what CloudTrail records for `aws___run_script` calls and compared the authenticated tool listing. That test covered one region and the proxy path only, and there is no AWS consumer yet to test the contract against)

---

## Revision note

This record was rewritten before merge, on its filing branch, after a three-reviewer adversarial pass on the first draft. The first draft proposed a `domains/aws` module with a per-operation tier-policy YAML that classified each `service:Action` at the agent host. The review found that design unbuildable and unsafe:

- **Its central tool no longer exists.** The first draft was built around a generic `call_aws` tool. AWS removed that tool between 2026-08-27 and 2026-09-03; no announcement or exact date was found. The draft's research relied on the May 2026 general-availability announcement, which is stale on the tool surface.
- **Nothing would have enforced it.** No component in any realistic deployment reads a policy YAML. Under operating-principles § 10 that is Asserted-only, not the Half-enforced the draft claimed.
- **Its classification model failed open.** A verb-prefix default left every unlisted verb without a tier and rated privilege escalation, sensitive reads, and audit-log tampering as approvable.
- **It failed this repo's own validators.** The proposed `tier.declared: 3` fails `validate-trust-tier.sh` against the proposed sensitive paths, and a `domains/` module's path-regex machinery never sees a tool call.

The design below replaces it. The thesis that AWS leaves per-action approval to the agent host survives; the mechanism changes from "classify at the host" to "enforce in IAM, prove by conformance."

A verification pass then worked through the risks the rewrite listed. Its results are folded in below. The largest change: AWS's MCP condition keys are **not** the anchor. AWS states they are absent when the same credentials are used outside the MCP server, and documents them for the first hop only. The anchor is a dedicated agent role whose limits are unconditional.

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

Govern the AWS MCP Server as an external target, in the reference-tool posture `agents/acp` established ([PRD-0037](../requirements/PRD-0037-acp-governance-bridge.md), [PRD-0038](../requirements/PRD-0038-acp-governance-proxy-reference.md)): the harness ships a contract, reference material, and a conformance check, and does not vendor or run the toolkit. The binding has eight parts. Full specification is deferred to a PRD on acceptance.

1. **An agents-family module, `platform/agents/aws-mcp/`.** The repo's taxonomy puts tool-seam governance under Agents ("AI-tool operating packs"); the only existing tier-policy lives in `platform/agents/acp/`. Governance of IaC and deploy file paths stays with `delivery/production-saas`, which already owns `^terraform/`, `^deploy/`, and `^infra/`. The module declares a low baseline `tier.declared` and a low `maxTier` ceiling, because under the two-role model in part 3 the agent's own reach into AWS is read-only and every write goes through the human-assumed role. That is what a low ceiling expresses (it caps and never grants). No shipped agent module uses a low ceiling yet: `agents/openclaw` declares a baseline of 2 with a ceiling of 5. Checked against `validate-trust-tier.sh`: the module's own sensitive paths match none of the validator's Tier 4 or Tier 5 samples, and the rule that a declared Tier 5 requires `project.criticality` of `high` or `critical` applies to agent modules too, which no sample project could satisfy.

2. **A declared posture artifact, `docs/aws/aws-mcp-posture.md`.** Frontmatter declares: each AWS account with an environment class (sandbox, non-production, production); permitted regions; the connection path (OAuth direct or SigV4 proxy); the agent's role per environment; the separate human-assumed role used for writes; the proxy version pin where a proxy is used; and the toolkit plugins installed.

3. **Enforcement anchored in a dedicated agent role.** The agent gets its own IAM role in each environment, and that role's limits are unconditional, so they hold on every path to AWS: the MCP server, the AWS CLI, an SDK, or a shell. The harness ships reference permission-boundary templates for that role:
   - **Default deny.** Anything not positively allowed is denied, including actions AWS adds later.
   - **No writes on the agent role.** This narrows the transitive-call question without closing it: a role that cannot invoke a function, start a build, or create a stack loses most second hops, but AWS labels some invoke actions as Read (see the review findings under Risks).
   - **Allow-list derived from AWS's access-level metadata.** AWS publishes the Service Authorization Reference as unauthenticated JSON, one file per service, and each action carries five booleans; the access level is inferred from four of them (an inference checked against the HTML reference, not a rule AWS states), and the fifth, `IsDataPlane`, marks actions on data content. A snapshot taken 2026-11-17 covers 458 services and 22,651 actions and matches the HTML reference action for action. It carries no content version and no retrievable history, so the consumer of this module vendors a snapshot and records its hash. List-level actions are allowed. Read-level actions are allowed minus a curated read-deny set.
   - **The curated read-deny set is real work, not a short list.** List plus Read admits 9,838 actions, and AWS labels many secret-bearing and data-content reads as Read or List (`secretsmanager:GetSecretValue`, `ssm:GetParameter`, `ecr:GetAuthorizationToken`, `lambda:GetFunction`, `s3:GetObject`, `dynamodb:Scan`, `logs:GetLogEvents`, and `ec2:DescribeInstanceAttribute`, which returns user data). The set must come from a sweep of those 9,838 actions, seeded by the appendix.
   - **The agent role cannot change its own limits.** It cannot assume other roles, and it cannot modify its boundary or policies.
   - **Writes run through a separate human-assumed role.** Assuming that role is the human gate for Tier 4 and Tier 5 work. Its own never-allow set is chosen by action name, not by AWS's "Permissions management" label: AWS classes `iam:CreateRole`, `iam:CreateAccessKey`, `iam:PassRole`, and `sts:AssumeRole` as Write.
   - **Environment is a first-class input.** One role per environment, with `aws:RequestedRegion` and `aws:ResourceAccount` conditions. An undeclared account or region is denied.
   - **The MCP condition keys are an optional backstop, never the anchor.** An organization may add a service control policy that denies writes made through the server for all principals. The templates use only the forms AWS documents: `Deny` with `Bool` on `aws:ViaAWSMCPService` equal to `true`, or with `StringEquals` on `aws:CalledViaAWSMCP`. They never use `BoolIfExists`, and never a negated operator on `aws:CalledViaAWSMCP` without the `Bool` test beside it, because both forms also match traffic that did not come through the server.

4. **Flat tool tiering at the host.** The module declares a tier per tool, with no attempt to classify script content:
   - `aws___run_script` takes the tier of the credentials it runs under. The default is Tier 5. It is lowered only when the posture declares a credential path whose policy has passed the conformance check as read-only, and never on the basis of what the script appears to do.
   - `aws___get_presigned_url` is a data-movement path and is tiered as a write.
   - The documentation, skill, region, and task tools are Tier 0, and their output is untrusted input.

5. **A conformance validator, `validate-aws-mcp-posture.sh`.** Opt-in and requiredArtifact-gated, modeled on `validate-foundry-target.sh`. It asserts the posture frontmatter's shape, and it checks the policy document the posture names (committed in the consumer's repo) against the never-allow set: every action in the set must be denied for the agent role. It also asserts that the posture records the hash of the access-level snapshot the policy was built from, and that a manifest declaring an account of class `production` has `project.criticality` of `high` or `critical` — the criticality signal belongs with the declared environment, not with the module's tier. A second, operator-run mode checks the deployed role using IAM policy simulation, in the way `validate-agent-bus.sh` is operator-run against live state.

6. **Governed off-switches.** The module's sensitive paths cover the things that can disable the control: the posture document, the policy document, and MCP client configuration (`.mcp.json`, `.claude/settings*.json`, `.cursor/mcp.json`, `.vscode/mcp.json`), where an edit could add a second ungoverned AWS server, change the profile, or unpin the proxy. A companion rule requires a risk-register entry or an ADR when they change. The posture must also declare which credentials the agent's shell can reach. The design holds only if that is the same restricted agent role; an agent whose shell holds a developer's broader credentials is ungoverned on that path whatever the MCP configuration says.

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
- **Primary sources read for this revision:** the [toolkit repository](https://github.com/aws/agent-toolkit-for-aws) (file tree, plugin manifests, MCP configuration, hooks, rules files); the [proxy repository](https://github.com/aws/mcp-proxy-for-aws) (argument handling, tool filter, changelog); the [AWS user guide for the toolkit](https://docs.aws.amazon.com/agent-toolkit/latest/userguide/) (tool reference, IAM, logging, multi-account access); an unauthenticated tool listing from the server's public endpoint; and the AWS Security Blog post linked in the Thesis.
- **Account test and second review (2026-11-17).** A test in an unused sandbox AWS account produced the observations under Risks. Four review agents then checked the record against the test evidence, this repo, AWS's current sources, and an attacker's view; the same section lists what they found.
- **Evidence that `call_aws` was removed:** the live tool listing and the current tool reference do not include it; the proxy changelog records replacing its tests with `run_script` tests; and an open issue in the toolkit repository quotes the server's "has been removed" error. No AWS announcement of the removal was found.
- **Evidence from this repo:** `validate-trust-tier.sh` infers Tier 5 from a `\.tf$` or secrets pattern and fails a lower declared tier; `platform/agents/acp/` pairs its policy file with a reference engine, a conformance test, and two accepted PRDs; `delivery/production-saas` already governs IaC paths; `architectures/ai-foundry-target` already owns `aws-bedrock-agentcore` as a deployment landing zone.
- **Related proposals:** [OPP-0065](OPP-0065-govern-ruflo-runtime.md) (proposed, not yet built) names the anti-goals this binding also observes — do not take on the target's runtime footprint, and do not import its governance plugins. [OPP-0062](OPP-0062-a2a-agent-card-descriptor-layer.md) set the practice of marking external claims pending until confirmed.

## Why Now

AWS has named this toolkit the successor to the AWS Labs MCP servers and recommends moving to it, so it is where AWS agent tooling is consolidating. Its surface is also moving quickly: the tool the first draft was designed around was removed within four months of general availability, and a local proxy became optional in July 2026. A binding that anchors in IAM and declared posture, rather than in the shape of any one tool, is the kind that survives that churn. There is no external deadline.

## Risks / Open Questions

### Settled or mitigated by the verification pass (2026-11-17)

- **Condition keys across transitive calls and outside the server.** AWS documents only the first hop, and the keys do not mark requests made outside the server. The mitigation claimed for this (unconditional limits and no write actions) was reopened by the second review below.
- **Machine-readability of the access-level metadata.** Confirmed, complete against the HTML reference, and unversioned. Mitigated by vendoring a hashed snapshot (parts 3 and 5).
- **Never-allow action names drafted from memory.** 131 candidates were checked against the snapshot: 129 exact, one wrong prefix corrected, one not an IAM action and dropped. The verified seed is in the appendix.
- **Trust-tier consequence for consumers.** Read from `validate-trust-tier.sh`; resolved by a low baseline and ceiling, with the criticality check moved to the posture validator (parts 1 and 5).
- **STS and assumed-role support.** Supported by the server and proxy. The agent role denies role assumption.

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

### Found by the second adversarial review (2026-11-17): resolve before acceptance

Four reviewers checked the record against the test evidence, this repo, AWS's current sources, and an attacker's view. The proposal in parts 1 to 8 is left as written above; these findings are against it. The record should not be accepted until the first four are answered.

- **The human write gate is not yet a gate.** Nothing in IAM distinguishes a human from an agent running as the same operating-system user, so an agent whose shell can reach the base profile can assume the write role itself. The write role's trust policy is unspecified (no MFA requirement, session length, or source identity). Assumption is per session, so an agent can submit opaque scripts under the write role for as long as the session lasts. The kernel trust model requires a second human for Tier 5, which one person assuming a role does not provide; `agents/acp` blocks Tier 5 at the seam for that reason. The account test above was itself run from a shell holding administrator credentials, which is the condition part 6 calls ungoverned.
- **The allow-list rule fails open.** Read is the level left when no other flag is set, so an action AWS has not annotated is allowed. The snapshot labels as Read actions that execute remotely (`bedrock:InvokeAgent`, `sagemaker:InvokeEndpoint`, `ssm:ExecuteAPI`), mint credentials or tokens (`s3:GetDataAccess`, `sts:GetServiceBearerToken`, `signin:CreateOAuth2Token`), disclose secrets (`secretsmanager:BatchGetSecretValue`, a sibling of a canary; `acm:ExportCertificate`), or have side effects (`sqs:ReceiveMessage`). None is in the appendix. `IsDataPlane` is true for 251 of the 9,838 Read and List actions and absent for 1,923, so it can seed a sweep but not replace one. The direction to evaluate is the inverse rule: List plus a reviewed positive set of metadata reads, with unreviewed Read denied.
- **The limits are implicit denies, not unconditional ones.** A same-account resource policy, or another role's trust policy naming the agent role, can grant access with no allow on the agent's side. The limit needs explicit `Deny` statements, including on role assumption. An enumerated allow-list of thousands of actions will also not fit a managed policy's size limit, and wildcards would defeat the default-deny test.
- **The validator can pass an unsafe policy, and a committed file is not the deployed role.** A `NotAction` allow, a conditional or resource-scoped deny, or a wildcard gets past a canary check. Deciding what a policy denies means evaluating IAM policy semantics, which no validator in this repo does; `validate-foundry-target.sh` checks frontmatter shape only. An operator-run mode that calls AWS would be the first validator to need a cloud CLI and credentials. The Half-enforced label would rest on a committed document alone, and lowering the tier of `aws___run_script` on that basis says nothing about what is attached to the live role.
- **The audit plane has further blind spots.** A session that never calls `aws___run_script` leaves no MCP event. Outcomes of data-plane calls (object, item, and message reads) need data-event logging that a default trail lacks. A presigned URL is used outside the server and carries no marker. The role session name is chosen by the caller, so attribution to a person or agent is not established. AWS documents per-tool CloudWatch metrics for the server; these were not tested.
- **Paths around the declared connection.** AWS offers an OAuth client-credentials flow that needs no browser or consent page, controlled by two `signin` actions that the snapshot labels Read. The proxy's `--read-only` flag is reported to have been bypassable by a direct tool call before version 1.6.4, so a version pin needs a floor. Toolkit configuration is also written at user level, outside the repo, where sensitive paths and companion rules cannot see it; part 6 covers repo-committed configuration only.
- **Three sets share the name never-allow.** The agent role's never-allow set, the curated read-deny set, and the write role's own set are distinct. The appendix cannot be the write role's set, because it contains ordinary deploy actions. `account:CloseAccount` is a real action (Write) and belongs beside `organizations:CloseAccount`.
- **Host tool tiering names no reader.** Part 4 declares a tier per tool but no component that applies it, which is the defect the revision note finds in the first draft. The enforcement label should be given per part: after the validator ships, parts 2, 3, and 5 could be Half-enforced on a committed document, while parts 4, 6, and 7 stay Asserted-only.
- **Smaller gaps.** The environment class is self-attested. The posture contract in part 2 omits fields later parts require (the policy document path, the snapshot hash, shell-reachable credentials, the last-verified tool listing, and whether the host captures scripts). The server also advertises prompts and resources, and scripts can call built-in helper modules that make AWS calls without naming an operation.

### Still open

- **The script text has no AWS-side record.** A consumer that needs the submitted code for review or forensics must capture it at the host before the call is sent, and the posture should say whether it does. The PRD decides whether the binding requires this or only declares it.
- **Limits of the account test.** One account, one region, one day, and the proxy path only; neither OAuth path was exercised, and six of the eight tools were not called. Whether read-only tools are unrecorded or are logged somewhere the test trail did not capture was not followed up. The event shape is undocumented in any API reference and can change server-side.
- **No AWS consumer exists yet.** Operating-principles § 9 says to ship a contract and validate it against real adoption before building enforcement on it. The PRD should stage the posture contract and reference policies first, and the validator second.
- **The curated read-deny set is unbuilt.** The appendix seeds it; the sweep of 9,838 Read and List actions is PRD work, and it must be repeated when the snapshot changes. The reference changes often: a re-fetch later the same day found 16 added actions.
- **The managed server cannot be pinned.** A proxy version can be pinned; the server changes underneath every client, as the `call_aws` removal showed, and the OAuth direct path has no proxy and no `--read-only` flag. The binding does not depend on any one tool's shape, and the posture records the tool listing it was last verified against.
- **What the script tool can reach.** The tool's description says the sandbox has no network access except through its AWS call helper. AWS documents no restriction on which services a script may call (a toolkit issue reports an undocumented per-script service cap) and no completeness guarantee for the `api_calls` list in its response. The design assumes a script can call anything the role allows and treats `api_calls` as informational.
- **Hosts without a permission hook.** A headless agent has no prompt to answer. On such hosts the agent role is the only control, which is the reason it is the anchor.
- **Registration surface.** A new validator, skill, and template directory touch roughly twenty count and enumeration surfaces across the repo, several of them governance entrypoints whose edits require an ADR or an operating-principles update. The PRD must enumerate them.
- **Prompt injection.** AWS-returned content (tags, log lines, object contents, documentation, retrieved skills) is attacker-influenceable model input. A read-only agent role limits what a successful injection can do; it does not prevent the injection, and it does not stop disclosure of whatever the role can read.
- **Other AWS-managed MCP servers.** The EKS and ECS servers are in preview, still require their own IAM actions, and AWS's list of service principals is given as examples. Whether one module covers them is left to the PRD.

## Appendix — verified seed for the never-allow set

Checked against the Service Authorization Reference snapshot of 2026-11-17. Actions marked (R) or (L) are labeled Read or List by AWS, so an access-level allow-list does not exclude them and the curated read-deny set must.

- **Identity and permissions:** `iam:CreateRole`, `iam:AttachRolePolicy`, `iam:PutRolePolicy`, `iam:CreateAccessKey`, `iam:CreatePolicyVersion`, `iam:SetDefaultPolicyVersion`, `iam:PassRole`, `iam:DeleteRolePermissionsBoundary`, `iam:PutRolePermissionsBoundary`, `iam:UpdateAssumeRolePolicy`, `iam:GetAccountAuthorizationDetails` (R), `iam:GetCredentialReport` (R), `sso:CreateAccountAssignment`, `identitystore:CreateUser`, `organizations:LeaveOrganization`, `organizations:AttachPolicy`, `organizations:CloseAccount`.
- **Credential minting and secret reads:** `sts:AssumeRole`, `sts:GetFederationToken`, `sts:GetSessionToken` (R), `secretsmanager:GetSecretValue` (R), `ssm:GetParameter` (R), `ssm:GetParameters` (R), `ssm:GetParametersByPath` (R), `ecr:GetAuthorizationToken` (R), `codeartifact:GetAuthorizationToken` (R), `cognito-identity:GetCredentialsForIdentity` (R), `redshift:GetClusterCredentials`, `rds-db:connect`, `lambda:GetFunction` (R), `ec2:GetPasswordData` (R), `ec2:GetConsoleOutput` (R), `ec2:DescribeInstanceAttribute` (L), `kms:Decrypt`.
- **Code execution and confused deputies:** `ssm:SendCommand`, `ssm:StartSession`, `ecs:ExecuteCommand`, `lambda:CreateFunction`, `lambda:UpdateFunctionCode`, `lambda:UpdateFunctionConfiguration`, `lambda:InvokeFunction`, `ec2:RunInstances`, `codebuild:StartBuild`, `glue:CreateJob`, `glue:UpdateDevEndpoint`, `sagemaker:CreatePresignedNotebookInstanceUrl`, `ecs:RunTask`, `ecs:RegisterTaskDefinition`, `states:StartExecution`, `cloudformation:CreateStack`, `cloudformation:UpdateStack`, `cloudformation:ExecuteChangeSet`, `events:PutTargets`, `scheduler:CreateSchedule`.
- **Resource policy, sharing, and exposure:** `s3:PutBucketPolicy`, `s3:PutBucketAcl`, `s3:PutObjectAcl`, `s3:PutBucketPublicAccessBlock`, `s3:PutAccountPublicAccessBlock`, `lambda:AddPermission`, `lambda:CreateFunctionUrlConfig`, `sns:AddPermission`, `sns:SetTopicAttributes`, `sqs:SetQueueAttributes`, `sqs:AddPermission`, `ecr:SetRepositoryPolicy`, `kms:PutKeyPolicy`, `kms:CreateGrant`, `secretsmanager:PutResourcePolicy`, `logs:PutResourcePolicy`, `ec2:ModifySnapshotAttribute`, `ec2:ModifyImageAttribute`, `rds:ModifyDBSnapshotAttribute`, `ram:CreateResourceShare`, `ec2:AuthorizeSecurityGroupIngress`, `rds:ModifyDBInstance`.
- **Audit-plane tampering:** `cloudtrail:StopLogging`, `cloudtrail:DeleteTrail`, `cloudtrail:UpdateTrail`, `cloudtrail:PutEventSelectors`, `config:StopConfigurationRecorder`, `config:DeleteDeliveryChannel`, `guardduty:DeleteDetector`, `guardduty:UpdateDetector`, `securityhub:DisableSecurityHub`, `logs:DeleteLogGroup`, `logs:PutRetentionPolicy`, `cloudwatch:DeleteAlarms`, `cloudwatch:DisableAlarmActions`, `ec2:DeleteFlowLogs`, `s3:PutBucketLogging`, `access-analyzer:DeleteAnalyzer`, `macie2:DisableMacie`.
- **Irreversible deletion:** `s3:DeleteBucket`, `s3:PutLifecycleConfiguration`, `s3:PutBucketVersioning`, `dynamodb:DeleteTable`, `rds:DeleteDBInstance`, `rds:DeleteDBCluster`, `ec2:DeleteSnapshot`, `ec2:TerminateInstances`, `backup:DeleteRecoveryPoint`, `kms:ScheduleKeyDeletion`, `kms:DisableKey`.
- **Spend commitment:** `ec2:PurchaseReservedInstancesOffering`, `savingsplans:CreateSavingsPlan`, `route53domains:RegisterDomain`, `route53domains:TransferDomain`, `aws-marketplace:Subscribe`, `servicequotas:RequestServiceQuotaIncrease`, `bedrock:CreateProvisionedModelThroughput`, `shield:CreateSubscription`.
- **DNS, certificates, and edge:** `route53:ChangeResourceRecordSets`, `acm:RequestCertificate`, `acm:DeleteCertificate`, `acm:ImportCertificate`, `cloudfront:UpdateDistribution`.
- **Data movement:** `s3:GetObject` (R), `s3:PutObject`, `dynamodb:Scan` (R), `dynamodb:Query` (R), `logs:GetLogEvents` (R), `logs:FilterLogEvents` (R), `sqs:ReceiveMessage` (R), `rds:StartExportTask`, `ec2:CreateSnapshot`, `ebs:GetSnapshotBlock` (R), `athena:StartQueryExecution`, `rds-data:ExecuteStatement`, `redshift-data:ExecuteStatement`.

Corrections made during verification: `sso-admin:CreateAccountAssignment` is `sso:CreateAccountAssignment`; `sso:GetRoleCredentials` is not an IAM action and cannot be denied in policy; `account:CloseAccount` is a console permission, so the API form `organizations:CloseAccount` is listed instead. `iam:PassRole` and `rds-db:connect` are permissions rather than API operations and are valid in policy.

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
