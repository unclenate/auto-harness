# Construction / AEC / BIM Domain — Research Brief for a Deep-Domain Module Family

**Date:** 2026-06-03
**Purpose:** Ground a future auto-harness `domains/construction-*` (or `aec-*`) deep-domain module family, mapped explicitly to the reusable pattern proven by the healthcare wedge:
- (a) decompose a deep regulated vertical into **technology-bounded sub-modules**;
- (b) a required **"jurisdiction-profile" forcing artifact** so no jurisdiction is assumed by default, with a **bias guardrail**;
- (c) where one technology serves multiple **trust roles**, model role as a **documented axis**.

**Connectivity check:** PASSED. `WebFetch` on buildingsmart.org succeeded; `WebSearch` for "ISO 19650 parts overview" succeeded.

> **Verification note:** All claims below are cited to fetched/searched sources. Vendor API specifics that could not be confirmed at the exact endpoint level are flagged **[verify at implementation]**. `Bash` was denied in this session, so this file was written via the Write tool directly.

---

## 1. Standards & Information-Management Layer

### ISO 19650 series (the spine)
ISO 19650 is the international framework for "Organization and digitization of information about buildings and civil engineering works, including building information modelling (BIM) — Information management using BIM." It is the internationalisation of the UK's BIM Level 2 model (BS 1192 + PAS 1192), carrying the same principles with country-specific content pushed into a **National Annex**. ([iso.org](https://www.iso.org/standard/68078.html), [thenbs.com](https://www.thenbs.com/knowledge/from-bs-1192-to-iso-19650-and-everything-in-between))

Parts (six total):
- **Part 1 — Concepts and principles.** Defines core terms, information requirements, roles, the information delivery cycle, the **Common Data Environment (CDE)**, status codes and approval processes. ([iso.org](https://www.iso.org/standard/68078.html))
- **Part 2 — Delivery phase (design & construction).** Specifies info-management processes during delivery; introduces the **BIM Execution Plan (BEP)**, **Master Information Delivery Plan (MIDP)**, and **Task Information Delivery Plans (TIDPs)**; aligns appointments/tendering with information requirements.
- **Part 3 — Operational phase.** Info management during operation, maintenance, refurbishment (the FM / asset-operator hand-off).
- **Part 4 — Information exchange.** Exchange-specific roles (provider, receiver, reviewer).
- **Part 5 — Security-minded information management.** (See §6.)
- **Part 6 — Health and safety information.** Collaborative classification/sharing of H&S info across the lifecycle; supports the UK "golden thread" for higher-risk buildings.

Source for parts breakdown: WebSearch "ISO 19650 parts overview" (synthesizing iso.org, en.wikipedia.org/wiki/ISO_19650, iso19650.org).

### Actors (the trust-role primitives — load-bearing for §4)
ISO 19650 defines three party tiers ([bimcorner.com](https://bimcorner.com/iso-19650-terms-explained-in-this-simple-way/), [12dsynergy.com](https://www.12dsynergy.com/iso-19650-guide/)):
- **Appointing party** — client/owner. Sets overall information requirements (OIR/AIR/PIR/EIR), controls objectives, appoints others, and ensures a CDE is in place.
- **Lead appointed party** — main contractor or lead consultant; coordinates the delivery team and interfaces with the appointing party.
- **Appointed party** — designers, sub-contractors, suppliers, vendors in the delivery team.

### CDE and information containers
- **CDE** = central repository to collect, manage and disseminate information for both providers and receivers. ([12d.co](https://12d.co/guides/common-data-environment/))
- **Information container** = any unique file (structured, e.g. geometry/schedules with metadata; or unstructured, e.g. PDFs/scans/photos), each with a unique ID plus status, revision, and classification metadata. This is the atomic governed object.

### National annexes / jurisdictional variance — THE JURISDICTION AXIS
- A **National Annex (NA)** provides guidance on application of the base standard within a country. The **UK NA** mandates **Uniclass 2015** as the classification system, for example. ([operam.co.uk](https://www.operam.co.uk/iso-19650-national-annex/), WebSearch synthesis)
- **UK:** ISO 19650 (as **BS EN ISO 19650**) is effectively required for public infrastructure projects; UK was the origin and is the most mature adopter.
- **US:** ISO 19650 is **not universally mandated** — adoption is market-driven, strongest on internationally-aligned projects. The US runs its own consensus standard track (NBIMS-US, below) while integrating ISO 19650 rather than replacing it. NIBS and the (now-closed) Centre for Digital Built Britain signed an **MOU** to align a US national roadmap with ISO 19650. ([revizto.com](https://revizto.com/resources/blog/what-is-iso-19650-bim-standards), [nibs.org US National BIM Program Implementation Plan PDF](https://nibs.org/wp-content/uploads/2025/04/NIBS_USNBP_ImplementationPlan_2022-1.pdf))

### NIBS / National BIM Standard — United States (NBIMS-US)
- Produced by the **National Institute of Building Sciences (NIBS)**; **NBIMS-US V4** unveiled at Building Innovation 2023, developed over ~3 years; a **consensus-based** standard (public comment + member voting) that references existing standards, documents information exchanges, and codifies best practices across the whole built-environment lifecycle. V4 emphasizes **BIM Execution Planning** and **Project BIM Requirements**, aimed at making owner adoption easy. ([nationalbimstandard.org / nibs.org/nbims/v4](https://nibs.org/nbims/v4/), [globalbim.org](https://globalbim.org/info-collection/the-national-bim-standard-united-states/))

### buildingSMART (the openBIM standards body — see §2)
buildingSMART International is "the worldwide industry body driving the digital transformation of the built asset industry," developing/maintaining the openBIM standards (IFC, BCF, IDS, bSDD) through a Standards Committee with sector domains (Building, Infrastructure, Railway). ([buildingsmart.org](https://www.buildingsmart.org/))

---

## 2. openBIM / File Formats

### IFC (Industry Foundation Classes)
- Open, vendor-neutral BIM exchange schema; the buildingSMART flagship, standardized as **ISO 16739**. ([buildingsmart.org](https://www.buildingsmart.org/))
- **IFC2x3** (2005): introduced complex building elements, object relationships, spatial hierarchy, classification; geometry limited (no full B-rep; polyhedra/sweeps/basic CSG). Still extremely widely deployed — the de-facto interop baseline.
- **IFC4** (2013): full B-rep, advanced geometry, construction-sequencing representation, richer schemas, domains beyond buildings.
- **IFC4.1 / 4.2 / 4.3**: progressive schema refinement; **IFC4.3** adds infrastructure (rail, road, bridge, ports/waterways) — the horizontal-infrastructure expansion. ([cadexchanger / WebSearch synthesis](https://cadexchanger.com/navisworks-to-ifc/), [technical.buildingsmart.org IFC4.3 implementations](https://technical.buildingsmart.org/ifc-4-3-software-implementations/))

### BCF (BIM Collaboration Format)
Standard communication protocol for issue management/coordination, deliberately **separating communication from the model files** — issues can be tracked/resolved without altering source data. ([buildingsmart.org](https://www.buildingsmart.org/), [bimcollab.com](https://www.bimcollab.com/en/resources/blog/bim-file-formats-openbim-native-guide/))

### IDS (Information Delivery Specification)
Machine-readable way to **define exchange requirements** against IFC (which objects/classifications/materials/properties must be present). This is the openBIM analog of a conformance/validation contract — directly relevant to a governance artifact. ([buildingsmart.org](https://www.buildingsmart.org/), [bimcollab.com](https://www.bimcollab.com/en/resources/blog/bim-file-formats-openbim-native-guide/))

### COBie (Construction-Operations Building information exchange)
Spreadsheet/exchange schema for handing **operational/asset data** to the facility owner at handover. Frequently delivered as an IFC MVD or spreadsheet. **[verify at implementation]** — exact current COBie version and whether NBIMS-US V4 still embeds it should be confirmed; the bimcollab source fetched did not enumerate COBie.

### Native vs open formats — the LOCK-IN / FEDERATION governance angle
- **Native/proprietary:** Autodesk Revit **`.rvt`**; AutoCAD `.dwg`; Tekla; Allplan; Archicad `.pln`. Navisworks **`.nwd`** (standalone, self-contained tessellated geometry + metadata + annotations, good for archive/distribution), **`.nwc`** (cache file), **`.nwf`** (lightweight link container pointing to source RVT/DWG/IFC without duplicating geometry). ([bimcollab.com](https://www.bimcollab.com/en/resources/blog/bim-file-formats-openbim-native-guide/), [WebSearch synthesis on Navisworks](https://www.cadinterop.com/en/formats/cad-systems/navisworks.html))
- **Governance themes:**
  - **Lock-in:** native formats optimize a single vendor's features but trap data; the recommended mitigation is IFC export for cross-team interop.
  - **Federation:** coordinating multiple discipline models (often via `.nwf`/IFC) into a federated whole; ISO 19650-5 (§6) calls out **secure federation** as a control.
  - **Exchange requirements:** IDS + EIR/MIDP make the "what data, in what format, when" contract explicit — the natural enforcement seam.
  - **Round-trip fidelity gap:** IFC export from native tools is lossy and version-sensitive (e.g., Navisworks 2023 cannot open IFC4x3; 2024 can but not the ADD2 variant). This version-skew is a real governance hazard. ([autodesk support](https://www.autodesk.com/support/technical/article/caas/sfdcarticles/sfdcarticles/IFC-4x3-file-exported-from-Civil-3D-cannot-be-opened-in-Navisworks.html))

---

## 3. Tooling / API Layer

### Autodesk Platform Services (APS, formerly Forge) + Revit API
- **Revit API:** a **.NET API** to automate repetitive tasks and extend Revit (simulation, construction). Runs **in-process** (add-ins) — distinct from the cloud APS surface. ([aps.autodesk.com/developer/overview/revit-api](https://aps.autodesk.com/developer/overview/revit-api))
- **APS cloud APIs** (auth via **OAuth v2**, scope-based) ([aps.autodesk.com OAuth scopes](https://aps.autodesk.com/en/docs/oauth/v2/developers_guide/scopes/)):
  - **Authentication (OAuth):** scopes are the permission context (`data:read`, `data:readwrite`, `bucket:read`, `viewables:read`, `code:all`, etc.). Best practice = least-privilege (e.g., `data:read` not `data:readwrite`; restrict Viewer tokens to `viewables:read`). ([aps best-practices blog](https://aps.autodesk.com/blog/best-practices-developers-using-autodesk-platform-services-aps-apis))
  - **Data Management API:** files/folders/buckets across BIM 360 / ACC / OSS.
  - **Model Derivative API:** translate native models (RVT etc.) into viewables (SVF) and extract metadata/properties.
  - **Design Automation API:** run AutoCAD/Revit/Inventor/3ds Max headless in the cloud; **now enforces the `code:all` OAuth scope** across all engines. ([aps blog: Design Automation enforcing OAuth scope](https://aps.autodesk.com/blog/design-automation-api-enforcing-oauth-scope))
- **Governance concerns (APS):**
  - **Credentials:** OAuth client secrets / 2-legged vs 3-legged tokens; least-privilege scope selection is the primary control.
  - **Model-data sensitivity:** full design models flow to/through Autodesk cloud; Viewer should get only `viewables:read`-scoped derivatives, not source.
  - **Automation tiers:** headless Design Automation is a higher-trust capability (can mutate models at scale) gated behind `code:all` — a natural "elevated automation" tier in harness terms.

### Bluebeam (Revu + Studio + Developer API)
- **Revu** = PDF-centric markup, **takeoff/quantity**, and review tool for construction documents. ([bluebeam.com](https://www.bluebeam.com/product/integrations/))
- **Studio Sessions** = cloud "digital conference room": multiple users mark up/comment on PDFs simultaneously or asynchronously; PDFs and markups are stored **separately** in-session, combined into a **Snapshot** for distribution. ([support.bluebeam.com Studio Session Guide](https://support.bluebeam.com/developer/studio-session-guide.html), [bbdn.bluebeam.com sessions](https://bbdn.bluebeam.com/articles/sessions/))
- **Developer Portal / API:** access is **gated** — only active customers, channel/software partners in **US, AU, DE, UK, SE**, via a request form. ([support.bluebeam.com getting-started-dev-portal](https://support.bluebeam.com/developer/getting-started-dev-portal.html))
  - **Studio API** exposes roughly the same functionality as the Studio GUI; **Markups API** reads/updates markup status from an integrating app; **Sessions Roundtrip** launches sessions and invites collaborators from a third-party app. ([developers.bluebeam.com](https://developers.bluebeam.com/s/studio))
  - Exact auth mechanism (OAuth vs API key) and rate/permission tiers **[verify at implementation]** — the dev portal is access-gated so specifics weren't fetchable here.
- **Governance concerns (Bluebeam):** session-level access control (who can join a markup session), markup provenance/audit, snapshot vs live-markup separation (an integrity concern), and regional availability gating of the dev program itself.

---

## 4. Trust Roles (AEC analog of provider-launch vs patient-access)

Healthcare modeled *role* as a documented axis (same FHIR tech serves provider-launch and patient-access trust contexts). The AEC analog maps cleanly onto ISO 19650 actors plus the regulator:

| Trust role | ISO 19650 / AEC mapping | Trust posture / sensitivity |
|---|---|---|
| **Owner / appointing party** | Client; sets info requirements; owns the CDE and the asset data long-term | Highest standing interest; defines what others may see |
| **Design lead / lead appointed party** | Lead consultant or main contractor; coordinates federation | Broad model access; coordination authority |
| **Trade / appointed parties** | Designers, sub-contractors, suppliers | Scoped to their discipline container(s); least-privilege |
| **Facility operator / FM** | ISO 19650-3 operational phase; COBie/asset-data recipient | Long-tail access to operational subset, not full design history |
| **Regulator / AHJ** | Authority Having Jurisdiction; reviews permit sets, inspects, signs off occupancy | Read/review of a defined "permit set"; external party, not in delivery team ([Procore AHJ](https://www.procore.com/library/ahjs-in-construction), [Autodesk AHJ](https://www.autodesk.com/blogs/construction/ahj-construction/)) |

**Cross-role wedge candidates (sub-modules exercised across multiple roles):**
- **CDE / information-container governance** — every role touches the CDE but with different read/write/status-transition rights. This is the strongest cross-role analog to FHIR-the-substrate. **Role is the documented axis here.**
- **IFC/openBIM exchange** — owner mandates it, design lead federates it, trades produce it, FM consumes it, AHJ may receive it. Multi-role.
- **Bluebeam Studio review/markup** — design lead, trades, and AHJ (plan review) all participate in markup workflows with different authority.

---

## 5. Economic & Construction-Development Context (tight)

Lifecycle where info-governance bites ([Procore predevelopment](https://www.procore.com/library/construction-predevelopment-phase), [Procore permitting](https://www.procore.com/library/construction-permitting)):
- **Pre-development:** feasibility, **pro-forma / project finance**, site control, risk identification. Light BIM, heavy on assumptions — the governance bite is *jurisdiction selection itself* (entitlement risk lives here).
- **Entitlements / permitting:** **AHJ** reviews the **permit set** of drawings to confirm code compliance before work; jurisdiction-specific codes apply. Governance bite: which AHJ, which code edition, what must the permit set contain.
- **Design:** BEP/MIDP/TIDP take force (ISO 19650-2); CDE status codes govern container maturity.
- **Construction:** federation, clash detection (Navisworks), RFIs/markups (Bluebeam), AHJ inspections at milestones.
- **Operations / FM:** ISO 19650-3; COBie/asset-data handover; AHJ occupancy sign-off is the gate to operations. ([WebSearch synthesis](https://www.shovels.ai/blog/ahj-in-construction/))

Takeaway: **the jurisdiction (AHJ + code edition + national annex) is the dominant variable** — it determines permit content, classification system, and mandate status. This is the construction equivalent of "don't assume a jurisdiction."

---

## 6. Security-Minded BIM (ISO 19650-5)

- Published as **BS EN ISO 19650-5:2020** (ISO 19650-5:2020). Specifies principles/requirements for **security-minded information management** of sensitive info created/stored as part of any asset/project/product/service. ([iso.org/standard/74206](https://www.iso.org/standard/74206.html), [bimdictionary](https://bimdictionary.com/en/iso-19650-5/1))
- **Core artifacts:** a **sensitivity assessment** (identify/classify sensitive information) and a **security management plan** (policies, processes, technical measures, monitoring/audit). ([Construction Management — sensitivity assessment & SMP](https://constructionmanagement.co.uk/understanding-iso-19650-5-the-sensitivity-assessment-and-the-security-management-plan/))
- **Technical controls called out:** selective **redaction**, **role-based access control**, and **secure federation** (protecting sensitive content during model coordination).
- **Sensitive-data drivers:** critical infrastructure, building occupants, and embedded **security systems** (cameras, access control, defense/utility assets) — disclosure can affect safety, security, and resilience of built assets. ([Construction Innovation Hub](https://constructioninnovationhub.org.uk/blogs/bs-en-iso-19650-52020-supporting-a-secure-future-for-digital-construction/))
- This is the construction analog to healthcare PHI sensitivity — and it is *already a named standard part*, which makes it an obvious dedicated sub-module rather than a cross-cutting concern.

---

## 7. PROPOSED Deep-Domain Decomposition (the payoff)

### Candidate `domains/construction-*` sub-module family

| Sub-module | What it governs | Likely required artifact | Trust roles exercised |
|---|---|---|---|
| **`construction-iso19650-im`** (information management core) | CDE structure, information containers, status codes, BEP/MIDP/TIDP, the actor model | **Information-management plan** (BEP-derived) + CDE status-transition policy | All (owner, design lead, appointed, FM) — cross-role |
| **`construction-openbim-exchange`** (IFC/BCF/IDS/COBie) | Open-format exchange, federation, exchange-requirement conformance, version-skew handling | **IDS / exchange-requirement spec** (machine-checkable) | Owner mandates, design lead federates, trades produce, FM consumes — cross-role |
| **`construction-iso19650-5-security`** | Sensitivity assessment, security management plan, redaction/RBAC/secure-federation | **Sensitivity assessment + security management plan** | Owner + security-cleared subset; gates everyone |
| **`construction-aps-tooling`** (Autodesk Platform Services / Revit) | OAuth scope least-privilege, Model Derivative, Data Management, Design Automation tiers | **Credential & automation-tier register** (scopes per integration; elevated-automation gate) | Design lead, trades (integrators) |
| **`construction-bluebeam-review`** | Studio Sessions, markup/takeoff, plan-review workflows | **Markup/session access-control policy** | Design lead, trades, AHJ (plan review) |
| **`construction-permitting-ahj`** (optional, later) | Permit-set definition, AHJ submission/inspection/occupancy gates | **Permit-set / jurisdiction-code register** | Owner, design lead, AHJ |

### THE WEDGE (analog of FHIR + SMART-on-FHIR — 1–3 sub-modules)
**Recommended wedge: `construction-iso19650-im` + `construction-openbim-exchange`** (optionally pulling in `construction-iso19650-5-security` as the third).

Rationale, by analogy:
- **`construction-iso19650-im` ≈ FHIR** — the universal substrate everyone touches; the document/container model and the actor/role primitives. It is the standard, cross-vendor, multi-role core.
- **`construction-openbim-exchange` ≈ SMART-on-FHIR** — the interop/access layer that rides on the substrate (IFC/IDS define *what data flows to whom under what contract*, the way SMART defines launch/access). Strong cross-role surface and the natural place to model **role as a documented axis** (producer vs receiver vs reviewer per IFC/BCF exchange).
- Adding **`construction-iso19650-5-security`** as the third gives the privacy/security spine immediately (it is already a named ISO part — low ambiguity, high value).

### The "jurisdiction-profile" analog (the forcing artifact + bias guardrail)
Healthcare forced a jurisdiction profile so no jurisdiction was assumed. The construction analog is a **`jurisdiction-profile` artifact = {ISO 19650 National Annex selection} × {AHJ / code edition} × {classification system}**:
- e.g. UK NA → Uniclass 2015, BS EN mandate; US → no universal mandate, NBIMS-US + local AHJ + (often) MasterFormat/OmniClass/UniFormat.
- **Bias guardrail:** default-deny any assumption of "UK BS EN ISO 19650 + Uniclass" (the most documented path) — the module must force an explicit national-annex / AHJ / classification declaration, exactly as healthcare refused to assume a default jurisdiction. The over-documentation of the UK path is itself the bias risk to guard against.

### Open questions for the design session
1. **Module-family prefix:** `domains/construction-*` vs `domains/aec-*`? AEC is broader (covers engineering/infrastructure incl. IFC4.3 horizontal); "construction" reads narrower. Lean `aec-*` if infrastructure is in scope.
2. **Is `construction-openbim-exchange` one module or two?** IFC-the-schema vs IDS-the-conformance-contract may warrant splitting (substrate vs contract), mirroring FHIR-vs-SMART more tightly.
3. **Where does the role axis live** — inside `iso19650-im` (CDE permissions) or `openbim-exchange` (provider/receiver/reviewer per ISO 19650-4)? Possibly both, documented once and referenced.
4. **AHJ as a trust role vs a jurisdiction-profile field** — the AHJ is simultaneously an external actor (role) and a jurisdiction determinant (profile). Decide whether `construction-permitting-ahj` is in the wedge or a later module.
5. **COBie currency** — confirm whether NBIMS-US V4 / current openBIM still centers COBie or has moved to IFC-MVD-based handover. **[verify at implementation]**
6. **Bluebeam dev-API auth model and regional gating** — the gated dev portal blocked confirmation of OAuth-vs-key and rate tiers. **[verify at implementation]**
7. **IFC version-skew policy** — should the exchange module *require* a pinned IFC version per project (given the 4.3/4x3-ADD2 tool-support fragmentation)? Likely yes; treat as an enforced field.

---

## Source inventory

**Fetched (WebFetch):** buildingsmart.org; aps.autodesk.com/developer/overview/revit-api; bimcollab.com openBIM/native formats guide. (3 direct fetches)
**Searched (WebSearch):** ISO 19650 parts; APS OAuth scopes/Design Automation; Bluebeam dev/Studio; IFC versions + Navisworks formats; ISO 19650-5 security; ISO 19650 national annex / NIBS adoption; ISO 19650 actors/CDE; NBIMS-US V4; construction lifecycle/AHJ/permitting. (9 searches)

**Could not verify (flagged [verify at implementation]):** Bluebeam dev-API auth mechanism & rate/permission tiers (gated portal); current COBie version / NBIMS-US V4 COBie centrality; exact APS Model Derivative & Data Management endpoint scopes beyond the documented scope list (the Revit-API overview page is a landing hub, not a technical reference).
