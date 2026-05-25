<!--
Copyright [[YEAR]] [[OWNER_NAME]] <[[OWNER_EMAIL]]>
SPDX-License-Identifier: [[SPDX_LICENSE]]
-->

# Skill Authoring Conventions — [[PROJECT_NAME]]

> Template for `docs/skills/authoring-conventions.md` (optional artifact of
> `architectures/agent-skill-pack`). This is the source of truth for how
> skills in this project are authored and shipped. Fill every `[[…]]` token.

**Owner:** [[OWNER]] | **Last Updated:** [[DATE]] | **Runtime:** [[TARGET_RUNTIME]]

---

## Priority Rule

State which authority wins when guidance conflicts (e.g. "runtime
compatibility first, eval/lint polish second"). [[PRIORITY_RULE]]

## Reference Skill

The canonical example new skills should mirror: [[REFERENCE_SKILL_PATH]].

## Frontmatter Spec

Required keys and their rules (name format, description style, trigger
guidance). [[FRONTMATTER_SPEC]]

Optional metadata keys this runtime honors: [[OPTIONAL_METADATA_KEYS]]

## Body Sections (in order)

The canonical section order for a `SKILL.md`. [[BODY_SECTION_ORDER]]

## Path Conventions

Placeholders and workspace paths skills may reference (e.g. `{baseDir}`, the
runtime workspace root, the `references/` module location). [[PATH_CONVENTIONS]]

## Personal / Sensitive Data: Reference, Don't Embed

How skills that personalize behavior must resolve user data at runtime
instead of embedding it. State the precedence chain and the
synthetic-fixture rule for evals. [[REFERENCE_DONT_EMBED_POLICY]]

## Scope & Permission Discipline

The one-skill-one-job rule and the least-permission workspace-cache boundary
each skill is confined to. [[SCOPE_AND_PERMISSION_POLICY]]

## Validation Before Ship

The eval/lint gate a skill must pass before deploy, and the deploy path
itself. [[VALIDATION_AND_DEPLOY]]
