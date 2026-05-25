<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0013 — Healthcare Domain Family (decomposed `domains/healthcare-*`)

**Status:** proposed
**Owner:** @unclenate
**Created:** 2026-05-24
**Last Updated:** 2026-05-24 *(augmented with Tula patient-client SMART-on-FHIR evidence + US-healthcare-bias guardrail; see §TG5 and OPP-0022)*
**Confidence:** high

---

## Thesis

The harness has no `domains/healthcare-*` coverage. Healthcare is one of
the largest regulated software domains — HIPAA-governed in the US, with
similar regimes globally — and represents a major potential consumer
audience the harness is currently positioned for but cannot fully serve.

OpenEMR's brownfield onboarding initially proposed a single
`domains/healthcare-ehr` module. Deeper subsystem-by-subsystem discovery
demonstrated the single-module approach is **too coarse**: a downstream
consumer building, say, a FHIR-only client application does not need
ePrescribing or CCDA artifacts. Bundling them into one module forces
irrelevant required-artifact debt that downstream projects pay forever.

Adopt the harness's existing per-concern module granularity (modeled on
the `delivery/` family's `prototype`/`mvp`/`production-saas` split) and
ship the healthcare coverage as a **decomposed family** of 12 sub-modules
plus templates, a skill, and a convenience composition:

### Sub-modules (each per-activation, each with its own required artifacts)

| Sub-module | What it governs | Required artifact (proposed) |
|---|---|---|
| `domains/healthcare-fhir` | FHIR R4 server (with US Core 8.0, Bulk Data Export) | `docs/healthcare/fhir-resource-map.md` |
| `domains/healthcare-hl7v2` | HL7 v2 messaging (ADT, ORM, ORU, MDM, …) | `docs/healthcare/hl7v2-message-coverage.md` |
| `domains/healthcare-smart-on-fhir` | SMART app launch + scope handling | `docs/healthcare/smart-on-fhir-scope-map.md` |
| `domains/healthcare-ccda` | C-CDA / CCR clinical document export | `docs/healthcare/ccda-coverage.md` |
| `domains/healthcare-eprescribing` | ePrescribing, EPCS, DEA controls | `docs/healthcare/eprescribing-readiness.md` |
| `domains/healthcare-cdr` | Clinical Decision Rules engine | `docs/healthcare/cdr-rule-coverage.md` |
| `domains/healthcare-cqm` | Clinical Quality Measures / HEDIS-style reporting | `docs/healthcare/cqm-measure-coverage.md` |
| `domains/healthcare-phi-encryption` | At-rest cipher suite + keystore + key rotation | `docs/healthcare/phi-encryption-design.md` |
| `domains/healthcare-audit-log` | HITECH/HIPAA audit, breakglass policy | `docs/healthcare/audit-log-design.md` |
| `domains/healthcare-direct-messaging` | HISP / secure healthcare email | `docs/healthcare/direct-messaging.md` |
| `domains/healthcare-ehi-export` | ONC-mandated patient EHI export | `docs/healthcare/ehi-export-readiness.md` |
| `domains/healthcare-patient-portal` | Sub-app with separate auth surface | `docs/healthcare/patient-portal-design.md` |

### Templates

A new `platform/templates/healthcare/` directory containing the artifact
templates referenced above. Eight initial templates (one per non-trivial
required artifact; some sub-modules share a template).

### Skill

A `harness-healthcare` skill — healthcare-codebase onboarding & code-review,
loaded on demand when any `domains/healthcare-*` is active. Knows where to
look for PHI flows, FHIR/HL7/CCDA implementations, audit logs, encryption,
ACL. Spawned mid-session as the "explore this healthcare codebase" agent.

### Convenience composition

A `platform/compositions/healthcare-full-ehr.yaml` brownfield-lite starter
that activates the full sub-module family at once, for projects (like
OpenEMR) that implement the entire stack. Standalone single-purpose
healthcare apps activate only what they need.

## Origin / Evidence

- **Consumer project: OpenEMR (`https://github.com/openemr/openemr`).**
  Brownfield onboarding session 2026-05-24 produced a gap analysis at
  `docs/knowledge/harness-coverage-gap-analysis.md` § G3, G6, G12, G19
  in the consumer project tree. The decomposition table above is lifted
  directly from § G3, which derived it from subsystem-by-subsystem
  inspection of OpenEMR's actual code paths.

- **Second consumer, role-distinct: Tula (`github.com/unclenate/tula`
  fork).** Brownfield onboarding 2026-05-24; gap analysis §TG5. Tula is the
  "second healthcare consumer" this OPP's Risks section asked for — and it
  exercises `healthcare-fhir` and `healthcare-smart-on-fhir` from the
  **patient-authorized-client** role rather than OpenEMR's
  **server/provider-launch** role. `skills/health-records` (derived from
  [`jmandel/health-skillz`](https://github.com/jmandel/health-skillz), by
  SMART co-creator Josh Mandel) reads the patient's *own* records via a
  patient-access SMART launch; records land as FHIR R4 JSON in a workspace
  cache. This validates the two sub-modules' boundary and refines their
  required-artifact shape: the SMART scope map must distinguish
  patient-access scopes (`patient/*.read`) from provider-launch scopes, and
  the trust model differs (the patient is the resource owner). The
  patient-side *safety* surface this consumer surfaced is filed separately
  as OPP-0022 (patient-facing health-agent safety), the patient-side
  counterpart to this operator-side family.

- **Decomposition is grounded in observed subsystem boundaries**, not
  speculation:
  - `domains/healthcare-fhir` ← `src/FHIR/R4/`, `src/Services/FHIR/`,
    `src/FHIR/Export/`, `apis/`, the documented FHIR R4 + US Core 8.0 +
    Bulk Data Export support
  - `domains/healthcare-hl7v2` ← `aranyasen/hl7 ^3.2.2` Composer
    dependency
  - `domains/healthcare-smart-on-fhir` ← `src/FHIR/SMART/`,
    `src/FHIR/SMART/ExternalClinicalDecisionSupport/`
  - `domains/healthcare-ccda` ← `ccdaservice/` (Node.js service),
    `ccr/`, `Documentation/api/`
  - `domains/healthcare-eprescribing` ← `src/Rx/`
  - `domains/healthcare-cdr` ← `src/ClinicalDecisionRules/`,
    `Documentation/Clinical_Decision_Rules_Manual.pdf`
  - `domains/healthcare-cqm` ← `src/Cqm/`, `contrib/cqm_valueset/`
  - `domains/healthcare-phi-encryption` ← `src/Encryption/` (a
    surprisingly mature implementation with `CipherSuite`,
    `Aes256CbcHmacSha384`, `Plaintext`/`Ciphertext`/`Message` value
    objects, `Keychain` + `KeyMaterial`, both DB and on-disk key
    storage, `KeyId` + `KeyMaterialId` domain primitives)
  - `domains/healthcare-audit-log` ← `src/Common/Logging/Audit/`,
    `EventAuditLogger`, `BreakglassChecker`, `PortalAuditLogger`
  - `domains/healthcare-direct-messaging` ← `Documentation/Direct_Messaging_README.txt`
  - `domains/healthcare-ehi-export` ← `Documentation/EHI_Export/`
    (ONC-mandated patient data export)
  - `domains/healthcare-patient-portal` ← `portal/`,
    `src/Controllers/Portal/`, `PortalAuditLogger`,
    `PortalLoginCredentialsRepository`

  Every entry has a concrete code-path anchor; nothing is speculative.

- **Decomposition rationale.** A consumer building a FHIR-only client
  does not need ePrescribing artifacts. A consumer building a HL7 v2
  integration layer does not need patient portal artifacts. The
  "healthcare project" is not a monolith — it's a *family* of capability
  surfaces that consumer projects mix-and-match. Bundling them into a
  single `domains/healthcare-ehr` module would force every consumer to
  inherit irrelevant required-artifact debt. The decomposition matches
  observable subsystem boundaries in real healthcare codebases.

- **Internal precedent for module granularity.** The `delivery/` family
  already encodes per-concern modules (`prototype`, `mvp`,
  `production-saas`, `internal-platform`) — none mandates the others;
  each has its own required-artifact contract. The proposed
  `domains/healthcare-*` family applies the same granularity principle
  to a different concern axis.

- **A "module sizing principle" observation.** The bootstrap observations
  recorded in the consumer project's `docs/knowledge/shared-observations.md`
  capture the meta-finding: *"Module granularity decisions made on
  coarse first-pass assessment carry forward as forced bundling later.
  The harness's module sizing principle should explicitly account for
  consumer-audience granularity — what subset of artifacts a typical
  consumer actually needs activated. Bundling artifacts a typical
  consumer does not need is module-debt that downstream projects pay
  forever."* (See cycle-end-distillation entry filed alongside this OPP.)

- **PHI encryption sub-module deserves attention.** OpenEMR's
  `src/Encryption/` is unusually mature — it implements a full
  cryptographic stack with proper primitives separation. This is itself
  an absorption candidate: the `domains/healthcare-phi-encryption`
  module's required-artifact template can reasonably encode the
  *pattern* OpenEMR demonstrates (CipherSuite + Keychain + KeyMaterial +
  KeyId domain primitive) as the recommended approach for any
  PHI-handling project.

## Why Now

- **Unblocks the entire OpenEMR canonization roadmap.** Each of the 12
  sub-modules is a target for one or more downstream canonization OPPs
  in OpenEMR. Filing this family OPP — and ratifying the decomposition
  shape — anchors the canonization work in modules that actually fit
  OpenEMR's surface. Deferring forces canonization OPPs to land against
  placeholder shapes that get refactored later.

- **Healthcare is the harness's largest plausible regulated-domain
  expansion.** Healthcare has well-defined standards (FHIR, HL7 v2,
  CCDA, SMART on FHIR, US Core), well-defined compliance frameworks
  (HIPAA, HITECH, ONC certification), and a substantial open-source
  base (OpenEMR, OpenMRS, HAPI FHIR). Filing now establishes
  governance coverage for the domain while the harness's catalog
  is still small enough to add coherently.

- **Composability with the regulated-compliance OPP.** OPP-0015
  proposes `domains/regulated-compliance` for external compliance
  test kits (Inferno ONC G10, PCI scanners, SOC2 evidence
  harnesses). The healthcare family and the regulated-compliance
  module pair naturally — many `domains/healthcare-*` modules
  imply an external test kit (Inferno for ONC; ToCKit for IHE
  integration testing). Filing both together makes the regulated-
  healthcare path concrete.

## Risks / Open Questions

- **Twelve sub-modules is a lot.** Module-count alone is not a quality
  metric, but it does increase catalog complexity for consumers
  browsing the module list. Mitigation: the convenience composition
  `healthcare-full-ehr.yaml` activates them all at once; consumers
  doing single-purpose work pick individually. The catalog index
  groups them under a clear "healthcare" heading.

- **Where does ACL/RBAC live?** OpenEMR has `src/Gacl/` (gacl-style ACL),
  which is healthcare-adjacent but not healthcare-specific. The gap
  analysis (§ G11) proposed an `auth/acl-rbac-design.md` template
  separate from the healthcare family. This OPP scopes ACL/RBAC out;
  OPP-0017 (legacy-coexistence templates) absorbs the ACL template
  alongside other generalizable auth patterns.

- **PHI handling vs PII / PCI handling.** The PHI encryption sub-module
  is healthcare-flavored but the *technique* (cipher suite + keystore +
  key rotation + domain primitives) generalizes to any
  sensitive-data domain. Validation: prototype the
  `phi-encryption-design.md` template and assess whether ~80% of
  content is healthcare-specific or whether it would better live as a
  generic `templates/sensitive-data/encryption-design.md` referenced
  by multiple domain modules.

- **`harness-healthcare` skill scope.** Single broad skill vs multiple
  narrow ones is decided in OPP-0016, which proposes a specialist
  skill family (`harness-fhir`, `harness-hl7v2`,
  `harness-onc-certification`, `harness-phi-audit`,
  `harness-encryption-review`, `harness-rbac-review`). This OPP scopes
  only the broad `harness-healthcare` skill; specialist skills are
  refinement-layer work.

- **Sub-modules without observed external evidence yet.** Several
  sub-modules (`direct-messaging`, `ehi-export`, `patient-portal`)
  are grounded in OpenEMR alone. Validation that they're broadly
  useful — not just OpenEMR-specific — requires looking at
  OpenMRS, HAPI FHIR, or a commercial reference like Epic's open
  surfaces. Initial bias: include them in the family; flag for
  re-evaluation after the second healthcare consumer onboards.
  *(Partially satisfied: Tula is the second consumer, but from the
  patient-client angle — see Origin/Evidence — so the operator-only
  sub-modules above remain OpenEMR-grounded.)*

- **US-healthcare bias (cross-cutting, architectural).** Both evidence
  points to date are American: OpenEMR (ONC certification, HIPAA) and Tula
  (Epic MyChart, HIPAA §164.526, US Core). There is a real risk of baking
  the cultural and economic assumptions of the **US** health system — its
  payer model, certification regime (ONC), consent/amendment law, MyChart
  as the canonical portal, US Core as the canonical profile — into module
  shapes as if universal. **Required before freezing any artifact in this
  family:** seek international second-evidence (Europe / EHDS, the Near East,
  the Far East; OpenMRS is a strong LMIC-deployed candidate) and design
  required artifacts around *concepts* that hold cross-jurisdiction, with
  realm-specific law carried as fill-in references (HIPAA, GDPR/EHDS, etc.)
  rather than hard-coded. FHIR core is an international HL7 standard, but
  US Core is a US-realm profile — the family must keep that distinction
  explicit. See the US-healthcare-bias observation in
  `docs/knowledge/shared-observations.md`.

## Disposition

<!-- Empty: status is proposed -->

## Promotion

<!-- Empty: not yet accepted -->

## Related

- Gap analysis source: consumer project (`openemr`) at
  `docs/knowledge/harness-coverage-gap-analysis.md` §§ G3, G6, G12, G19
- Refinement OPP for specialist skills: [OPP-0016](OPP-0016-specialist-healthcare-review-skills.md)
- Pairs with: [OPP-0015](OPP-0015-regulated-compliance-test-kits.md)
  — regulated-compliance and external test kits
- Module sizing meta-observation: shared-observations entry filed
  alongside this OPP (cycle-end distillation)
- Patient-side counterpart (second consumer, Tula): [OPP-0022](OPP-0022-patient-facing-health-agent-safety.md)
- Second-consumer gap analysis: consumer project (`tula`) at
  `docs/knowledge/harness-coverage-gap-analysis.md` §TG5
- Companion OPPs filed in the same session (OpenEMR canonization):
  [OPP-0011](OPP-0011-stack-module-php.md),
  [OPP-0012](OPP-0012-data-module-relational-sql-engine-generalization.md),
  [OPP-0014](OPP-0014-polyglot-companion-services.md),
  [OPP-0015](OPP-0015-regulated-compliance-test-kits.md),
  [OPP-0016](OPP-0016-specialist-healthcare-review-skills.md),
  [OPP-0017](OPP-0017-legacy-coexistence-template-family.md)
