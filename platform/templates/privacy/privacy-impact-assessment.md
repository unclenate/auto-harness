<!--
Copyright [[YEAR]] [[OWNER_NAME]] <[[OWNER_EMAIL]]>
SPDX-License-Identifier: [[SPDX_LICENSE]]
-->

# Privacy Impact Assessment — [[PROJECT_NAME]]

> Owner: [[OWNER]]
> Last updated: YYYY-MM-DD
> Regime: see `docs/privacy/privacy-profile.md`

Data Protection Impact Assessment (DPIA) / Privacy Impact Assessment (PIA)
for the `management/privacy-by-design` overlay. Complete one PIA per
significant new processing activity or feature that introduces personal-data
risk. Store filled copies at `docs/privacy/pia-NNNN-slug.md`.

---

## 1. Processing Description

Describe the personal data processing activity being assessed.

- **Feature / system:** [[FEATURE_OR_SYSTEM_NAME]]
- **Data categories involved:** *(cross-reference `docs/privacy/data-inventory.md`)*
- **Data subjects:** [[DATA_SUBJECTS]] (e.g., registered users, employees,
  minors, healthcare patients)
- **Volume / scale:** [[VOLUME_ESTIMATE]] (rough order of magnitude is fine)
- **Automated decision-making:** Yes / No — if yes, describe logic and impact.

---

## 2. Necessity and Proportionality

Demonstrate that the processing is limited to what is strictly necessary.

- **Stated purpose:** [[PURPOSE]]
- **Minimum data set:** Is data collection limited to what is necessary for
  the stated purpose? [[YES_OR_NO_AND_EXPLANATION]]
- **Less-privacy-invasive alternatives considered:**
  [[ALTERNATIVES_CONSIDERED]]
- **Retention justified:** [[RETENTION_JUSTIFICATION]]

---

## 3. Risks to Data Subjects

Enumerate foreseeable privacy risks. Rate each as Low / Medium / High.

| Risk | Likelihood | Severity | Overall |
| ---- | ---------- | -------- | ------- |
| [[RISK_1]] | [[LIKELIHOOD]] | [[SEVERITY]] | [[OVERALL]] |
| [[RISK_2]] | [[LIKELIHOOD]] | [[SEVERITY]] | [[OVERALL]] |

Risk dimensions to consider: unauthorized access or breach; re-identification
of pseudonymized data; function creep (data used for purposes beyond original
scope); data subject harm (discrimination, financial, reputational);
cross-border transfer exposure.

---

## 4. Mitigations

For each risk above, describe the control(s) in place or planned.

| Risk | Mitigation | Status |
| ---- | ---------- | ------ |
| [[RISK_1]] | [[MITIGATION_1]] | Planned / In progress / Implemented |
| [[RISK_2]] | [[MITIGATION_2]] | Planned / In progress / Implemented |

---

## 5. Residual Risk and Sign-off

After mitigations, document the residual risk posture and obtain sign-off.

- **Residual risk level:** Low / Medium / High
- **Acceptable?** Yes / No — if No, list blocking items before proceeding.
- **DPO / Privacy lead consulted:** [[DPO_OR_PRIVACY_LEAD]] (required under
  GDPR when High risk persists; advisory for other regimes)
- **Sign-off:** [[REVIEWER]] — YYYY-MM-DD

## Cross-Reference

- Privacy profile: `docs/privacy/privacy-profile.md`
- Data inventory: `docs/privacy/data-inventory.md`
