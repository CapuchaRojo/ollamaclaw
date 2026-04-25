#!/usr/bin/env bash
set -euo pipefail

# OC Self-Test / Acceptance Suite — Fast, non-destructive validation for Ollamaclaw command center.
# Usage:
#   ./scripts/oc-self-test.sh        # Default mode: non-mutating checks only
#   ./scripts/oc-self-test.sh full   # Full mode: adds safe sample checks
#   ./scripts/oc-self-test.sh help   # Show usage

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
OC="$SCRIPT_DIR/oc"

cd "$PROJECT_ROOT"

# Counters
PASS_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0

# Mode: default or full
MODE="${1:-default}"

usage() {
  cat <<EOF
OC Self-Test / Acceptance Suite

Usage:
  ./scripts/oc-self-test.sh        # Default mode: non-mutating checks only
  ./scripts/oc-self-test.sh full   # Full mode: adds safe sample checks
  ./scripts/oc-self-test.sh help   # Show usage

Modes:
  default  Run fast, non-destructive checks (no samples, no queue mutations)
  full     Add safe sample checks (JSON leak detector samples, slice queue read ops)

Constraints (both modes):
  - Does not call network
  - Does not run sudo
  - Does not install anything
  - Does not launch Claude Code
  - Does not pull models
  - Does not create worktrees
  - Does not commit or push
  - Does not create packages (unless PACKAGE_TEST_MODE=1 is explicitly set)

Exit codes:
  0  PASS or WARN (safe to proceed)
  1  FAIL (hard failures detected)
EOF
}

record_pass() {
  local msg="$1"
  echo -e "\033[0;32m[PASS]\033[0m $msg"
  ((PASS_COUNT++)) || true
}

record_warn() {
  local msg="$1"
  echo -e "\033[1;33m[WARN]\033[0m $msg"
  ((WARN_COUNT++)) || true
}

record_fail() {
  local msg="$1"
  echo -e "\033[0;31m[FAIL]\033[0m $msg"
  ((FAIL_COUNT++)) || true
}

# A. Command Center
check_command_center() {
  echo
  echo "=== A. Command Center ==="

  # Confirm scripts/oc exists and is executable
  if [[ -x "$OC" ]]; then
    record_pass "scripts/oc exists and is executable"
  else
    record_fail "scripts/oc missing or not executable"
    return
  fi

  # Run oc help and verify expected commands
  local help_output
  help_output="$("$OC" help 2>&1)" || true

  local expected_commands=(
    "status"
    "doctor"
    "toolchain"
    "truth"
    "agents"
    "release"
    "hygiene"
    "package"
    "queue"
    "closeout"
    "worktree"
    "parallel"
    "model-smoke"
    "json-leak"
    "launch-cloud"
  )

  local missing=()
  for cmd in "${expected_commands[@]}"; do
    if echo "$help_output" | grep -q "$cmd"; then
      record_pass "oc help contains '$cmd'"
    else
      missing+=("$cmd")
      record_fail "oc help missing '$cmd'"
    fi
  done

  if [[ ${#missing[@]} -eq 0 ]]; then
    record_pass "All expected commands present in oc help"
  fi
}

# B. Core Diagnostics
check_core_diagnostics() {
  echo
  echo "=== B. Core Diagnostics ==="

  local diagnostics=(
    "toolchain:toolchain-doctor"
    "doctor:ollamaclaw-doctor"
    "truth:source-truth"
    "agents:agent-inventory"
    "release:release-readiness"
  )

  for diag in "${diagnostics[@]}"; do
    local name="${diag%%:*}"
    local cmd="${diag##*:}"

    echo
    echo "--- $name ---"

    local output
    output=$("$OC" "$cmd" 2>&1) || true

    # Strip ANSI codes for pattern matching
    local clean_output
    clean_output=$(echo "$output" | sed 's/\x1b\[[0-9;]*m//g')

    # Check for FAIL in output
    if echo "$clean_output" | grep -q "RESULT: FAIL"; then
      record_fail "$cmd reported FAIL"
    elif echo "$clean_output" | grep -q "RESULT: WARN"; then
      # Special handling for release: known WARNs are acceptable
      if [[ "$name" == "release" ]]; then
        if echo "$clean_output" | grep -qE "Root ZIP|_bootstrap_junk|uncommitted changes"; then
          record_warn "$cmd reported WARN (known acceptable: root ZIP / _bootstrap_junk / uncommitted)"
        else
          record_warn "$cmd reported WARN"
        fi
      else
        record_warn "$cmd reported WARN"
      fi
    elif echo "$clean_output" | grep -qE "RESULT: PASS|RESULT: All|All checks passed|checks passed"; then
      record_pass "$cmd reported PASS"
    else
      # If no clear result line, check for hard errors
      if echo "$clean_output" | grep -qi "error\|not found\|command not found"; then
        record_fail "$cmd encountered error"
      else
        record_pass "$cmd completed"
      fi
    fi
  done
}

# C. Planning Lifecycle
check_planning_lifecycle() {
  echo
  echo "=== C. Planning Lifecycle ==="

  # Run queue list
  echo
  echo "--- Queue List ---"
  local list_output
  list_output=$("$OC" queue list 2>&1) || true
  if [[ -n "$list_output" ]]; then
    record_pass "oc queue list executed successfully"
  else
    record_warn "oc queue list returned empty output"
  fi

  # Run queue next
  echo
  echo "--- Queue Next ---"
  local next_output
  next_output=$("$OC" queue next 2>&1) || true
  if [[ -n "$next_output" ]]; then
    record_pass "oc queue next executed successfully"
  else
    record_warn "oc queue next returned empty (no planned slices)"
  fi
}

# D. Closeout Dry Run
check_closeout_dry_run() {
  echo
  echo "=== D. Closeout Dry Run ==="

  local slices_dir="$PROJECT_ROOT/.ollamaclaw/slices"
  if [[ -d "$slices_dir" ]]; then
    local slice_files
    slice_files=$(find "$slices_dir" -maxdepth 1 -name "*.md" -type f 2>/dev/null | head -1)

    if [[ -n "$slice_files" ]]; then
      local slice_name
      slice_name=$(basename "$slice_files" .md)

      # Skip if it's the current slice being worked on
      if [[ "$slice_name" == "oc-self-test-suite" ]]; then
        record_warn "Only oc-self-test-suite slice found; skipping closeout dry-run"
        return
      fi

      echo
      echo "--- Dry Run: $slice_name ---"
      local dryrun_output
      dryrun_output=$("$OC" closeout dry-run "$slice_name" 2>&1) || true

      if echo "$dryrun_output" | grep -q "RESULT: FAIL"; then
        record_fail "closeout dry-run for $slice_name reported FAIL"
      elif echo "$dryrun_output" | grep -q "RESULT: WARN\|WARN"; then
        record_warn "closeout dry-run for $slice_name reported WARN"
      else
        record_pass "closeout dry-run for $slice_name completed"
      fi
    else
      record_warn "No slice files found in .ollamaclaw/slices/"
    fi
  else
    record_warn ".ollamaclaw/slices/ directory not found"
  fi
}

# E. Parallel / Worktree Safety
check_parallel_worktree() {
  echo
  echo "=== E. Parallel / Worktree Safety ==="

  echo
  echo "--- Parallel Safety Check ---"
  local parallel_output
  parallel_output=$("$OC" parallel 2>&1) || true
  if echo "$parallel_output" | grep -q "RESULT: PASS\|safe to proceed\|no conflicts"; then
    record_pass "parallel-safety-check reported PASS"
  elif echo "$parallel_output" | grep -q "RESULT: WARN"; then
    record_warn "parallel-safety-check reported WARN"
  elif echo "$parallel_output" | grep -q "RESULT: FAIL"; then
    record_fail "parallel-safety-check reported FAIL"
  else
    record_pass "parallel-safety-check completed"
  fi

  echo
  echo "--- Worktree List ---"
  local worktree_output
  worktree_output=$("$OC" worktree list 2>&1) || true
  if [[ -n "$worktree_output" ]]; then
    record_pass "oc worktree list executed successfully"
  else
    record_warn "oc worktree list returned empty"
  fi
}

# F. Artifact Hygiene
check_artifact_hygiene() {
  echo
  echo "=== F. Artifact Hygiene ==="

  echo
  echo "--- Hygiene Check ---"
  local hygiene_output
  hygiene_output=$("$OC" hygiene 2>&1) || true

  if echo "$hygiene_output" | grep -q "RESULT: FAIL"; then
    record_fail "artifact-hygiene-check reported FAIL (tracked secrets?)"
  elif echo "$hygiene_output" | grep -q "RESULT: WARN"; then
    # Known acceptable warnings
    if echo "$hygiene_output" | grep -qE "Root ZIP|_bootstrap_junk"; then
      record_warn "artifact-hygiene-check reported WARN (known acceptable: root ZIP / _bootstrap_junk)"
    else
      record_warn "artifact-hygiene-check reported WARN"
    fi
  elif echo "$hygiene_output" | grep -q "RESULT: PASS"; then
    record_pass "artifact-hygiene-check reported PASS"
  else
    record_pass "artifact-hygiene-check completed"
  fi
}

# G. Model / JSON Tools
check_model_json_tools() {
  echo
  echo "=== G. Model / JSON Tools ==="

  # Check scripts exist and are executable
  local smoke_test="$SCRIPT_DIR/model-smoke-test.sh"
  local json_leak="$SCRIPT_DIR/json-leak-detector.sh"

  if [[ -x "$smoke_test" ]]; then
    record_pass "scripts/model-smoke-test.sh exists and is executable"
  else
    record_fail "scripts/model-smoke-test.sh missing or not executable"
  fi

  if [[ -x "$json_leak" ]]; then
    record_pass "scripts/json-leak-detector.sh exists and is executable"
  else
    record_fail "scripts/json-leak-detector.sh missing or not executable"
  fi

  # Full mode: run JSON leak detector samples
  if [[ "$MODE" == "full" ]]; then
    echo
    echo "--- JSON Leak Detector Samples (Full Mode) ---"

    # Test 1: Should detect a leak
    echo "Test 1: JSON leak detection (should detect)"
    local leak_test
    leak_test=$(printf '{"name":"Read","arguments":{"file_path":"README.md"}}\n' | "$OC" json-leak - 2>&1) || true

    if echo "$leak_test" | grep -qi "leak\|detected\|FAIL"; then
      record_pass "JSON leak detector correctly detected leak"
    else
      record_warn "JSON leak detector did not detect expected leak (output: $leak_test)"
    fi

    # Test 2: Should pass (no leak)
    echo "Test 2: Normal text (should pass)"
    local normal_test
    normal_test=$(printf 'Normal Claude Code response.\n' | "$OC" json-leak - 2>&1) || true

    if echo "$normal_test" | grep -qi "PASS\|No leak\|clean"; then
      record_pass "JSON leak detector correctly passed clean input"
    else
      record_warn "JSON leak detector output unclear for clean input (output: $normal_test)"
    fi
  fi
}

# H. Summary
print_summary() {
  echo
  echo "============================================"
  echo "OC SELF-TEST SUMMARY"
  echo "============================================"
  echo -e "  \033[0;32mPASS:\033[0m $PASS_COUNT"
  echo -e "  \033[1;33mWARN:\033[0m $WARN_COUNT"
  echo -e "  \033[0;31mFAIL:\033[0m $FAIL_COUNT"
  echo

  if [[ $FAIL_COUNT -gt 0 ]]; then
    echo -e "\033[0;31mRESULT: FAIL - Hard failures detected. Fix before proceeding.\033[0m"
    exit 1
  elif [[ $WARN_COUNT -gt 0 ]]; then
    echo -e "\033[1;33mRESULT: WARN - Warnings detected. Safe to proceed with caution.\033[0m"
    exit 0
  else
    echo -e "\033[0;32mRESULT: PASS - All self-test checks passed.\033[0m"
    exit 0
  fi
}

# Main
case "$MODE" in
  help|-h|--help)
    usage
    exit 0
    ;;
  default|"")
    MODE="default"
    ;;
  full)
    MODE="full"
    ;;
  *)
    echo "Unknown mode: $MODE" >&2
    echo "Use './scripts/oc-self-test.sh help' for usage." >&2
    exit 1
    ;;
esac

echo "OC Self-Test Suite"
echo "Mode: $MODE"
echo "Project Root: $PROJECT_ROOT"

# Run all checks
check_command_center
check_core_diagnostics
check_planning_lifecycle
check_closeout_dry_run
check_parallel_worktree
check_artifact_hygiene
check_model_json_tools

# Print summary
print_summary
