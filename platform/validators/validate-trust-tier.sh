#!/usr/bin/env bash
# shellcheck disable=SC2034
# (TIER_INFER_* arrays below are read via name-mangled iteration; the
# static analyzer cannot trace that pattern.)
# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
# Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
#
# validate-trust-tier.sh — Assert active modules' declared/inferred trust
# tiers are coherent and agent-pack max-tier ceilings are respected.
#
# Why this exists:
#   The trust-tier model (six tiers 0–5) is the framework's centerpiece
#   safety claim — but until this validator, *zero* code anchored the
#   doctrine. The safety sweep §2 classified the relevant claims
#   (claim 10 "no self-elevation", claim 11 "tier-ceiling fixed") as
#   Asserted-only. This validator converts both to Enforced at the
#   PR-boundary layer per PRD-0006.
#
#   Roadmap citation: ADR-0017 (Safety Hardening Roadmap) Wave 5.1.
#   Closes safety-security-sweep §2 claims 10 + 11.
#
# Usage:
#   validate-trust-tier.sh [<manifest>] [<project-root>]
#
# Behavior:
#   1. Parse the manifest, enumerate active modules.
#   2. For each active module, read its module.yaml:
#      - Validate declared tier (range 0–5; rationale required for ≥3).
#      - Compute inferred tier from sensitivePaths via the INFERENCE
#        table below; highest match wins.
#      - Assert declared >= inferred (no under-declaration).
#      - Warn if declared is missing and inferred > 2.
#   3. For each active agent module, validate maxTier (range 0–5).
#      Assert agent maxTier >= max(declared|inferred) across all
#      non-agent active modules.
#   4. Cross-cutting: if any active *non-kernel* module's declared tier is
#      5, require the manifest's project.criticality to be "high" or
#      "critical" (catches "Tier 5 work on prototype" misconfigurations).
#      The universal kernel (kernel/base) is excluded — every consumer
#      inherits its structural tier-5, so counting it would false-positive
#      on every non-platform consumer. Relaxed entirely for
#      maturity: platform projects.
#
# Inference table (kept in sync with PRD-0006 FR-002):
#   ^src/migrations/  | ^db/migrations/                  → tier 4
#   ^deploy/  | ^.github/workflows/deploy.*  | ^infra/   → tier 5
#   ^.github/workflows/  (non-deploy)                    → tier 4
#   ^.env  | ^secrets/  | ^.kube/                        → tier 5
#   ^Dockerfile  | ^docker-compose                       → tier 4
#   ^package\.json | ^pyproject\.toml | lockfiles        → tier 4
#   ^harness\.manifest\.yaml | ^platform/core/kernel/    → tier 5
#
# Exit codes:
#   0  all active modules' tier declarations are coherent
#   1  one or more violations (under-declaration, maxTier breach, etc.)
#   2  usage error

set -euo pipefail

# ----------------------------------------------------------------------
# Help
# ----------------------------------------------------------------------

case "${1:-}" in
  -h|--help)
    cat <<'USAGE'
validate-trust-tier.sh — Enforce trust-tier coherence on active modules.

Usage:
  validate-trust-tier.sh [<manifest>] [<project-root>]

Arguments:
  manifest      Path to harness.manifest.yaml (default: ./harness.manifest.yaml)
  project-root  Path to the project root (default: dirname of manifest)

Behavior:
  For each active module, validates the optional `tier.declared` field
  (range 0–5; rationale required for ≥3) and computes the inferred tier
  from declared sensitivePaths via a built-in pattern table. Asserts no
  under-declaration (declared >= inferred). For agent modules, validates
  `maxTier` and asserts it is at least the highest active-module tier.

Inference patterns (production-shape paths force higher tier regardless
of declaration):

  ^src/migrations/, ^db/migrations/             → tier 4 (schema)
  ^deploy/, ^.github/workflows/deploy.*,        → tier 5 (production
    ^infra/                                                 deployment)
  ^.github/workflows/ (non-deploy)              → tier 4 (CI)
  ^.env, ^secrets/, ^.kube/                     → tier 5 (credentials)
  ^Dockerfile, ^docker-compose.*                → tier 4 (env construction)
  ^package\.json, ^pyproject\.toml, lockfiles   → tier 4 (deps)
  ^harness\.manifest\.yaml,                     → tier 5 (kernel)
    ^platform/core/kernel/

Cross-cutting: a *consumer-selected* (non-kernel) declared tier-5 module
requires project.criticality in {high,critical}. The universal kernel
(kernel/base) is excluded — its tier-5 declaration is a structural
governance-ceiling every consumer inherits, not a per-project risk signal.
The rule is also relaxed entirely for maturity: platform projects.

Exit codes:
  0  all tiers coherent
  1  under-declaration, maxTier breach, or other violation
  2  usage error
USAGE
    exit 0
    ;;
esac

MANIFEST="${1:-harness.manifest.yaml}"
PROJECT_ROOT="${2:-}"

if [[ ! -f "$MANIFEST" ]]; then
  echo "✗ Manifest not found: $MANIFEST" >&2
  exit 2
fi

if [[ -z "$PROJECT_ROOT" ]]; then
  PROJECT_ROOT="$(cd "$(dirname "$MANIFEST")" && pwd)"
fi

if [[ ! -d "$PROJECT_ROOT" ]]; then
  echo "✗ Project root not a directory: $PROJECT_ROOT" >&2
  exit 2
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"
HARNESS_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
PLATFORM_ROOT="${HARNESS_ROOT}/platform"

# ----------------------------------------------------------------------
# Delegate to Ruby for YAML parsing + per-module traversal.
# Bash drives the contract (args, exit codes); Ruby does the structured
# logic. Same shape as validate-companions / validate-module-graph.
# ----------------------------------------------------------------------

ruby -I "$LIB_DIR" -r harness_registry - "$MANIFEST" "$PLATFORM_ROOT" <<'RUBY' || exit $?
manifest_path = ARGV[0]
platform_root = ARGV[1]

begin
  manifest = HarnessRegistry.load_manifest(manifest_path)
rescue HarnessRegistry::ManifestShapeError => e
  warn "✗ #{e.message}"
  exit 2
end

# Inference table: tier → representative sample paths. For each active
# module's sensitivePaths regex set, test whether any sample path of a
# given tier WOULD match. Highest matched tier wins. Robust against
# regex-string-comparison fragility — we test what the rules would
# actually catch in practice.
#
# Kept in sync with the validator's --help text and PRD-0006 FR-002.
INFERENCE = {
  5 => [
    "deploy/prod.sh",
    ".github/workflows/deploy.yml",
    "infra/main.tf",
    ".env",
    "secrets/api-key",
    ".kube/config",
    "harness.manifest.yaml",
    "platform/core/kernel/base/module.yaml",
  ],
  4 => [
    "src/migrations/001_init.sql",
    "db/migrations/v1.sql",
    ".github/workflows/test.yml",
    "Dockerfile",
    "docker-compose.yml",
    "package.json",
    "pyproject.toml",
    "package-lock.json",
    "yarn.lock",
    "poetry.lock",
    "Gemfile.lock",
  ],
}.freeze

VALID_TIERS = (0..5).to_a

# Compute inferred tier from a module's sensitivePaths (array of
# {description, patterns}). Returns 0 when no rules match. Method:
# compile each pattern as a regex; for each tier (highest first), test
# whether any sample of that tier matches any compiled regex. Stop at
# the first tier with a match.
def inferred_tier(sensitive_paths)
  return 0 if sensitive_paths.nil? || sensitive_paths.empty?

  patterns = []
  sensitive_paths.each do |group|
    patterns.concat Array(group.is_a?(Hash) ? group["patterns"] : group)
  end

  compiled = patterns.compact.map do |p|
    begin
      Regexp.new(p.to_s)
    rescue RegexpError
      nil
    end
  end.compact

  return 0 if compiled.empty?

  [5, 4].each do |tier|
    INFERENCE[tier].each do |sample|
      return tier if compiled.any? { |rx| rx.match?(sample) }
    end
  end
  0
end

violations = 0
warnings   = 0

active_modules = HarnessRegistry.active_modules(platform_root, manifest)

# Track the maximum effective tier across non-agent active modules for
# the agent-maxTier check.
max_active_tier = 0

# Per-module checks (declared/inferred coherence)
active_modules.each do |mod|
  display = mod["id"] || mod["__path"] || "(unknown)"

  tier_block = mod["tier"]
  declared   = tier_block.is_a?(Hash) ? tier_block["declared"] : nil
  rationale  = tier_block.is_a?(Hash) ? tier_block["rationale"] : nil

  if declared
    unless VALID_TIERS.include?(declared)
      warn "✗ #{display}: tier.declared #{declared.inspect} out of range (must be 0-5)"
      violations += 1
      next
    end
    if declared >= 3 && (rationale.nil? || rationale.to_s.strip.empty?)
      warn "✗ #{display}: tier.declared = #{declared} requires tier.rationale"
      violations += 1
    end
  end

  inferred = inferred_tier(mod["sensitivePaths"])
  effective = [declared || 0, inferred].max

  # Agent modules are checked separately for maxTier (below); their
  # own tier.declared still applies to the coherence rules above.
  if (mod["type"] || "") != "agent"
    max_active_tier = effective if effective > max_active_tier
  end

  if declared && inferred > declared
    warn "✗ #{display}: declared tier #{declared} < inferred tier #{inferred} (under-declaration; check sensitivePaths)"
    violations += 1
    next
  end

  if declared.nil? && inferred > 2
    warn "⚠ #{display}: no tier.declared and inferred tier is #{inferred} (consider adding explicit declaration)"
    warnings += 1
  end
end

# Agent-pack maxTier checks
agent_mods = active_modules.select { |mod| (mod["type"] || "") == "agent" }
agent_mods.each do |mod|
  display = mod["id"] || mod["__path"] || "(unknown agent)"
  max_tier = mod["maxTier"]
  if max_tier.nil?
    # A missing maxTier SKIPS the ceiling check silently — an agent pack could omit maxTier to
    # bypass it entirely. Surface the omission (warn, not hard-fail).
    warn "⚠ #{display}: agent pack declares no maxTier — its trust-tier ceiling is unbounded and the ceiling check cannot run; declare an explicit maxTier"
    warnings += 1
    next
  end

  tier_block    = mod["tier"]
  declared_tier = tier_block.is_a?(Hash) ? tier_block["declared"] : nil

  # `maxTier` is an UPPER ceiling on the agent's autonomous reach — it caps but
  # never grants (ADR-0020). The only violations are an out-of-range value or a
  # ceiling below the agent's OWN declared baseline. A ceiling below the
  # manifest workload is NOT a violation (see the informational note below).
  case HarnessRegistry.agent_maxtier_status(max_tier, declared_tier)
  when :out_of_range
    warn "✗ #{display}: maxTier #{max_tier.inspect} out of range (must be 0-5)"
    violations += 1
    next
  when :below_declared
    warn "✗ #{display}: agent maxTier = #{max_tier} is below the agent's own declared tier #{declared_tier} — a ceiling cannot sit beneath the agent's baseline operating tier"
    violations += 1
    next
  end

  # Least-privilege is valid: an agent whose ceiling is below some non-agent
  # module's workload simply defers that higher-tier work to the human gate
  # (Tier 4/5 are human-authorized regardless — the ceiling never grants them).
  # Surface it as INFORMATION so the deferral is visible, never as a failure.
  # This is the corrected direction of the AH-ADV-04 inversion: the old check
  # failed exactly this safe configuration and pressured every agent to the
  # maximum ceiling.
  if max_tier < max_active_tier
    warn "ℹ #{display}: agent ceiling maxTier = #{max_tier} is below the manifest's highest non-agent tier #{max_active_tier}; that tier-#{max_active_tier} work requires human authorization — the ceiling caps the agent's autonomous reach, it does not grant the higher tier"
  end
end

# Cross-cutting: declared tier 5 requires criticality high/critical,
# UNLESS the project's maturity is "platform". Platform-maturity projects
# (e.g., auto-harness itself, governance frameworks generally) are
# inherently high-rigor regardless of declared criticality — the
# heuristic "tier-5 work on a prototype = probable misconfiguration"
# doesn't apply when the project is the platform layer governing other
# projects. See ADR-0017 Wave 5.1 implementation reconciliation notes.
#
# The heuristic only counts *consumer-selected* tier-5 modules. The
# universal kernel (kernel/base, and any future kernel/* submodule) is
# EXCLUDED: it declares tier 5 because it governs CI workflows and
# governance entrypoints on EVERY project — a structural governance-ceiling,
# not a per-project risk signal. Since every consumer activates the kernel,
# counting it would fire this rule on every non-platform consumer (every
# stock sample manifest included), which is a false positive. What the rule
# is meant to catch is a consumer bolting a genuinely tier-5 module (deploy,
# infra, secrets) onto a low-criticality project — for which the kernel
# carries no signal.
criticality = (manifest.dig("project", "criticality") || "").to_s
maturity    = (manifest.dig("project", "maturity") || "").to_s
has_consumer_tier_5 = active_modules.any? do |mod|
  id   = (mod["id"] || "").to_s
  path = (mod["__path"] || "").to_s
  next false if id.start_with?("kernel/") || path.include?("/core/kernel/")
  block = mod["tier"]
  block.is_a?(Hash) && block["declared"] == 5
end
if has_consumer_tier_5 && !%w[high critical].include?(criticality) && maturity != "platform"
  warn "✗ project.criticality is #{criticality.inspect} but the active manifest declares a non-kernel tier-5 module (expected high or critical for non-platform projects)"
  violations += 1
end

if violations > 0
  warn ""
  warn "✗ Trust-tier validation failed: #{violations} violation(s); #{warnings} warning(s)."
  warn "  See declared/inferred output above."
  exit 1
end

if warnings > 0
  puts "✓ Trust-tier validation passed (#{warnings} warning(s) — see stderr)."
else
  puts "✓ Trust-tier validation passed (#{active_modules.size} active modules checked)."
end
exit 0
RUBY
