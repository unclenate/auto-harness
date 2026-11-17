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
**Confidence:** medium (the tool surface, IAM context keys, and audit events below were re-read from AWS's current documentation and a live tool listing on 2026-11-17, and the harness-side findings were checked against the validators on disk; a follow-up verification pass the same day settled the allow-list data source, the never-allow action names, the limits of AWS's MCP condition keys, and the trust-tier mechanics; a test in a sandbox AWS account the same day settled what CloudTrail records and compared the authenticated tool listing; medium not high because that test covered one region and the proxy path only, and because there is no AWS consumer yet to test the contract against)

---

## Revision note

This record was rewritten before merge, on its filing branch, after a three-reviewer adversarial pass on the first draft. The first draft proposed a `domains/aws` module with a per-operation tier-policy YAML that classified each `service:Action` at the agent host. The review found that design unbuildable and unsafe:

- **Its central tool no longer exists.** The first draft was built around a generic `call_aws` tool. AWS removed that tool on 2026-08-31. The draft's research relied on the May 2026 general-availability announcement, which is stale on the tool surface.
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

- **`aws___run_script` is the only tool that executes AWS APIs, and its input is one free-form Python `code` string.** The agent host sees opaque code, not an operation name. The script can build its API calls dynamically, so static inspection of the code is defeatable. AWS's own `secret-safety` hook has an open bypass for this reason.
- **AWS provides no per-call human approval and says so.** Its guidance for approval before sensitive use is to "configure client-side hooks or permission rules in your MCP client." What AWS does provide is coarse: tool annotations, a proxy `--read-only` flag that removes every non-read-only tool (which today removes all AWS API access), an OAuth consent page, a profile allow-list, and one blocking hook shipped in the `aws-core` plugin.
- **AWS marks requests the server makes, but only on that one path.** The first-hop request the server makes with the caller's credentials carries `aws:ViaAWSMCPService` (Boolean) and `aws:CalledViaAWSMCP` (the service principal, `aws-mcp.amazonaws.com`), usable in identity policies and service control policies. AWS states the keys are not set when the same credentials are used through the AWS CLI, an SDK, or a shell: "the agent has two paths to the same AWS API, and differentiation controls govern one path." Nothing AWS publishes says the keys persist past the first hop (for example, on calls made by a Lambda function's execution role). The server defines no IAM actions of its own.

### The gap

Per-action control over what an agent may do in AWS exists only where the consumer writes IAM policy by hand. The agent host cannot supply it, because the host cannot see operations. Nothing connects a project's declared intent ("this agent reads metadata in the sandbox account and nothing else") to the policy that would make it true, and nothing checks the two against each other.

### The proposal

Govern the AWS MCP Server as an external target, in the reference-tool posture `agents/acp` established ([PRD-0037](../requirements/PRD-0037-acp-governance-bridge.md), [PRD-0038](../requirements/PRD-0038-acp-governance-proxy-reference.md)): the harness ships a contract, reference material, and a conformance check, and does not vendor or run the toolkit. The binding has eight parts. Full specification is deferred to a PRD on acceptance.

1. **An agents-family module, `platform/agents/aws-mcp/`.** The repo's taxonomy puts tool-seam governance under Agents ("AI-tool operating packs"); the only existing tier-policy lives in `platform/agents/acp/`. Governance of IaC and deploy file paths stays with `delivery/production-saas`, which already owns `^terraform/`, `^deploy/`, and `^infra/`. The module declares a low baseline `tier.declared` and a low `maxTier` ceiling, because under the two-role model in part 3 the agent's own reach into AWS is read-only and every write goes through the human-assumed role. That is what a low ceiling expresses (it caps and never grants), and it is the shape `agents/openclaw` already uses. Checked against `validate-trust-tier.sh`: the module's own sensitive paths match none of the validator's Tier 4 or Tier 5 samples, and the rule that a declared Tier 5 requires `project.criticality` of `high` or `critical` applies to agent modules too, which no sample project could satisfy.

2. **A declared posture artifact, `docs/aws/aws-mcp-posture.md`.** Frontmatter declares: each AWS account with an environment class (sandbox, non-production, production); permitted regions; the connection path (OAuth direct or SigV4 proxy); the agent's role per environment; the separate human-assumed role used for writes; the proxy version pin where a proxy is used; and the toolkit plugins installed.

3. **Enforcement anchored in a dedicated agent role.** The agent gets its own IAM role in each environment, and that role's limits are unconditional, so they hold on every path to AWS: the MCP server, the AWS CLI, an SDK, or a shell. The harness ships reference permission-boundary templates for that role:
   - **Default deny.** Anything not positively allowed is denied, including actions AWS adds later.
   - **No writes on the agent role.** This also closes the transitive-call question: a role that cannot invoke a function, start a build, or create a stack has no second hop on which a marker could be lost.
   - **Allow-list derived from AWS's access-level metadata.** AWS publishes the Service Authorization Reference as unauthenticated JSON, one file per service, and the access level is derived from four booleans on each action. A snapshot taken 2026-11-17 covers 458 services and 22,651 actions and matches the HTML reference action for action. It carries no retrievable version, so the consumer of this module vendors a snapshot and records its hash. List-level actions are allowed. Read-level actions are allowed minus a curated read-deny set.
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
- **Primary sources read for this revision:** the [toolkit repository](https://github.com/aws/agent-toolkit-for-aws) (file tree, plugin manifests, MCP configuration, hooks, rules files); the [proxy repository](https://github.com/aws/mcp-proxy-for-aws) (argument handling, tool filter, changelog); the [AWS user guide for the toolkit](https://docs.aws.amazon.com/agent-toolkit/latest/userguide/) (tool reference, IAM, logging, multi-account access); and an unauthenticated tool listing from the server's public endpoint.
- **Evidence that `call_aws` was removed:** the live tool listing and the current tool reference do not include it; the proxy changelog records replacing its tests with `run_script` tests; and an open issue in the toolkit repository quotes the server's "has been removed" error. No AWS announcement of the removal was found.
- **Evidence from this repo:** `validate-trust-tier.sh` infers Tier 5 from a `\.tf$` or secrets pattern and fails a lower declared tier; `platform/agents/acp/` pairs its policy file with a reference engine, a conformance test, and two accepted PRDs; `delivery/production-saas` already governs IaC paths; `architectures/ai-foundry-target` already owns `aws-bedrock-agentcore` as a deployment landing zone.
- **Related proposals:** [OPP-0065](OPP-0065-govern-ruflo-runtime.md) (proposed, not yet built) names the anti-goals this binding also observes — do not take on the target's runtime footprint, and do not import its governance plugins. [OPP-0062](OPP-0062-a2a-agent-card-descriptor-layer.md) set the practice of marking external claims pending until confirmed.

## Why Now

AWS has named this toolkit the successor to the AWS Labs MCP servers and recommends moving to it, so it is where AWS agent tooling is consolidating. Its surface is also moving quickly: the tool the first draft was designed around was removed within four months of general availability, and a local proxy became optional in July 2026. A binding that anchors in IAM and declared posture, rather than in the shape of any one tool, is the kind that survives that churn. There is no external deadline.

## Risks / Open Questions

### Settled by the verification pass (2026-11-17)

- **Condition keys across transitive calls and outside the server.** AWS confirms the keys are absent outside the server and documents only the first hop. Mitigated by design: the agent role's limits are unconditional and it has no write actions, so neither gap is load-bearing (part 3).
- **Machine-readability of the access-level metadata.** Confirmed, complete against the HTML reference, and unversioned. Mitigated by vendoring a hashed snapshot (parts 3 and 5).
- **Never-allow action names drafted from memory.** 131 candidates were checked against the snapshot: 129 exact, one wrong prefix corrected, one not an IAM action and dropped. The verified seed is in the appendix.
- **Trust-tier consequence for consumers.** Read from `validate-trust-tier.sh`; resolved by a low baseline and ceiling, with the criticality check moved to the posture validator (parts 1 and 5).
- **STS and assumed-role support.** Supported by the server and proxy. The agent role denies role assumption.

### Settled by a test in a sandbox AWS account (2026-11-17)

One trail, one read-only role, and four tool calls through the server by way of the SigV4 proxy (version 1.8.0) in `us-east-1`: three `aws___run_script` calls (an identity read, a list, and a write the role does not allow) and one `aws___list_regions` call. The test resources were deleted afterwards.

- **Tool calls are recorded as management events.** Each `aws___run_script` call produced a `CallReadWriteTool` event from `aws-mcp.amazonaws.com` with `eventType` `AwsMcpEvent` and `eventCategory` `Management`. The events appeared in Event history and were delivered to S3 by a trail with default management-event logging. No data-event selector was needed, and none exists: CloudTrail's published list of data-event resource types has no entry for the AWS MCP Server. This corrects the earlier reading of AWS's sample record, which shows the category as `Data`.
- **The submitted script is not recorded.** The event names the tool, but the tool arguments, the request metadata, and the result are each replaced with a redaction placeholder. A unique marker placed in each script appeared nowhere in Event history or the delivered log files.
- **The downstream calls are recorded and can be joined.** Each tool-call event lists its downstream requests by API name, region, and request ID, and each request ID matched an ordinary CloudTrail event for that call. Those events carry the agent role as the identity and `aws-mcp.amazonaws.com` in `invokedBy`, `sourceIPAddress`, and `userAgent`.
- **The outcome lives on the downstream event only.** The denied write appeared as `AccessDenied` on its own event. The tool-call event for it carried no error code, and all three tool-call events were marked `readOnly` false, including the two whose scripts only read.
- **The authenticated tool listing matches the unauthenticated one.** The same eight tools, with `aws___run_script` the only one that executes AWS APIs.
- **IAM is enforced on this path.** Both reads succeeded as the read-only role and the write was refused.

So CloudTrail can serve as the verification plane for which identity called which tool and which AWS APIs ran with what result. It cannot show what code was submitted.

### Still open

- **The script text has no AWS-side record.** A consumer that needs the submitted code for review or forensics must capture it at the host before the call is sent, and the posture should say whether it does. The PRD decides whether the binding requires this or only declares it.
- **Limits of the account test.** One account, one region, one day, and the proxy path only; the OAuth direct path was not exercised. The `aws___list_regions` call left no event in Event history or the delivered logs within twelve minutes, so tools that execute no AWS API may go unrecorded; this was not followed up. The event shape is undocumented in any API reference and can change server-side.
- **No AWS consumer exists yet.** Operating-principles § 9 says to ship a contract and validate it against real adoption before building enforcement on it. The PRD should stage the posture contract and reference policies first, and the validator second.
- **The curated read-deny set is unbuilt.** The appendix seeds it; the sweep of 9,838 Read and List actions is PRD work, and it must be repeated when the snapshot changes. Two service files changed the day before the snapshot was taken.
- **The managed server cannot be pinned.** A proxy version can be pinned; the server changes underneath every client, as the `call_aws` removal showed, and the OAuth direct path has no proxy and no `--read-only` flag. The binding does not depend on any one tool's shape, and the posture records the tool listing it was last verified against.
- **What the script tool can reach.** AWS documents no restriction on which services a script may call and no completeness guarantee for the `api_calls` list in its response. The design assumes a script can call anything the role allows and treats `api_calls` as informational.
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
