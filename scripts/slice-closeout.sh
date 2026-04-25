#!/bin/bash
set -euo pipefail

# Slice Closeout Workflow for Ollamaclaw
# Finalizes a completed slice after review/commit by running checks, updating status, and logging.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SLICES_DIR="$PROJECT_ROOT/.ollamaclaw/slices"

usage() {
    cat <<EOF
Slice Closeout Workflow for Ollamaclaw

Usage:
  $0 <command> [arguments]

Commands:
  help                              Show this help message
  dry-run <slice-name>              Run checks without modifying files
  done <slice-name> "<summary>"     Mark slice as completed
  blocked <slice-name> "<reason>"   Mark slice as blocked
  deferred <slice-name> "<reason>"  Mark slice as deferred

Examples:
  $0 help
  $0 dry-run batch-2-repo-hygiene-agents
  $0 done batch-2-repo-hygiene-agents "Added 6 repo hygiene agents"
  $0 blocked feature-x "Waiting on API access"
  $0 deferred nice-to-have "Lower priority than Q2 goals"

Behavior:

  dry-run:
    - Verifies slice exists in .ollamaclaw/slices/
    - Shows current slice status
    - Runs diagnostic scripts (doctor, source-truth, inventory, release-readiness)
    - Prints what would be changed without modifying files

  done:
    - Verifies slice exists
    - Warns if working tree has uncommitted changes
    - Runs diagnostic scripts
    - Stops on hard failures (does not mark done if diagnostics fail)
    - Updates slice status to 'done' via slice-queue.sh
    - Appends closeout notes to slice file (Closed, Summary, Branch, Commit)
    - Logs to session via session-log.sh
    - Prints recommended next command: slice-queue.sh next

  blocked:
    - Marks slice as blocked
    - Appends blocker reason to slice file
    - Logs to session

  deferred:
    - Marks slice as deferred
    - Appends deferral reason to slice file
    - Logs to session

Notes:
  - Does NOT commit or push
  - Does NOT switch branches
  - Does NOT create worktrees
  - Does NOT launch Claude Code
  - Does NOT call network
  - Slice names must be lowercase hyphenated (e.g., my-slice-name)

EOF
}

validate_slice_name() {
    local name="$1"
    if [[ ! "$name" =~ ^[a-z0-9]([a-z0-9-]*[a-z0-9])?$ ]]; then
        echo "ERROR: Invalid slice name '$name'"
        echo "Slice names must be lowercase alphanumeric with hyphens (e.g., my-slice-name)"
        exit 1
    fi
    if [[ ${#name} -lt 2 ]] || [[ ${#name} -gt 64 ]]; then
        echo "ERROR: Slice name must be 2-64 characters"
        exit 1
    fi
}

slice_file() {
    local name="$1"
    echo "$SLICES_DIR/${name}.md"
}

run_diagnostics() {
    echo "=== Running Diagnostics ==="
    echo ""

    local pass_count=0
    local warn_count=0
    local fail_count=0

    # Run doctor
    echo "--- ollamaclaw-doctor.sh ---"
    if "$SCRIPT_DIR/ollamaclaw-doctor.sh" >/dev/null 2>&1; then
        echo "[PASS] Doctor checks passed"
        pass_count=$((pass_count + 1))
    else
        echo "[FAIL] Doctor checks failed"
        fail_count=$((fail_count + 1))
    fi
    echo ""

    # Run source truth check
    echo "--- source-truth-check.sh ---"
    local stc_output
    stc_output=$("$SCRIPT_DIR/source-truth-check.sh" 2>&1) || true
    if echo "$stc_output" | grep -q "RESULT:.*FAIL"; then
        echo "[FAIL] Source truth check failed"
        fail_count=$((fail_count + 1))
    elif echo "$stc_output" | grep -q "RESULT:.*WARN"; then
        echo "[WARN] Source truth check has warnings"
        warn_count=$((warn_count + 1))
    else
        echo "[PASS] Source truth check passed"
        pass_count=$((pass_count + 1))
    fi
    echo ""

    # Run agent inventory
    echo "--- agent-inventory.sh ---"
    if "$SCRIPT_DIR/agent-inventory.sh" >/dev/null 2>&1; then
        echo "[PASS] Agent inventory passed"
        pass_count=$((pass_count + 1))
    else
        echo "[FAIL] Agent inventory failed"
        fail_count=$((fail_count + 1))
    fi
    echo ""

    # Run release readiness
    echo "--- release-readiness.sh ---"
    local rr_output
    rr_output=$("$SCRIPT_DIR/release-readiness.sh" 2>&1) || true
    if echo "$rr_output" | grep -q "RESULT:.*FAIL"; then
        echo "[FAIL] Release readiness failed"
        fail_count=$((fail_count + 1))
    elif echo "$rr_output" | grep -q "RESULT:.*WARN"; then
        echo "[WARN] Release readiness has warnings"
        warn_count=$((warn_count + 1))
    else
        echo "[PASS] Release readiness passed"
        pass_count=$((pass_count + 1))
    fi
    echo ""

    echo "=== Diagnostics Summary ==="
    echo "PASS: $pass_count | WARN: $warn_count | FAIL: $fail_count"
    echo ""

    if [[ $fail_count -gt 0 ]]; then
        return 1
    fi
    return 0
}

check_uncommitted_changes() {
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "[WARN] Not a git repository"
        return 0
    fi

    local changes
    changes=$(git status --short 2>/dev/null || true)

    if [[ -n "$changes" ]]; then
        echo "[WARN] Working tree has uncommitted changes:"
        echo "$changes"
        echo ""
        echo "Consider committing or stashing changes before closeout."
        echo "Proceeding anyway (closeout does not commit)..."
        echo ""
        return 1
    fi

    echo "[PASS] Working tree is clean"
    return 0
}

get_current_branch() {
    if git rev-parse --git-dir >/dev/null 2>&1; then
        git branch --show-current 2>/dev/null || echo "(unknown)"
    else
        echo "(not a git repo)"
    fi
}

get_short_commit() {
    if git rev-parse --git-dir >/dev/null 2>&1; then
        git rev-parse --short HEAD 2>/dev/null || echo "(unknown)"
    else
        echo "(unknown)"
    fi
}

cmd_dry_run() {
    local name="$1"
    validate_slice_name "$name"

    local file
    file=$(slice_file "$name")

    echo "=== Slice Closeout Dry-Run ==="
    echo ""

    # Verify slice exists
    if [[ ! -f "$file" ]]; then
        echo "[FAIL] Slice '$name' not found at $file"
        echo "Run './scripts/slice-queue.sh list' to see available slices"
        exit 1
    fi

    echo "[PASS] Slice file exists: $file"
    echo ""

    # Show current status
    echo "--- Current Slice Status ---"
    local status goal
    status=$(grep "^Status:" "$file" 2>/dev/null | cut -d: -f2- | xargs || echo "unknown")
    goal=$(grep "^Goal:" "$file" 2>/dev/null | cut -d: -f2- | xargs || echo "(no goal)")
    echo "Status: $status"
    echo "Goal: $goal"
    echo ""

    # Run diagnostics
    run_diagnostics || true
    echo ""

    # Show what would happen
    echo "--- What Would Happen on 'done' ---"
    echo "1. Verify diagnostics pass (no FAIL items)"
    echo "2. Check for uncommitted changes (warn if dirty)"
    echo "3. Update status to 'done' via slice-queue.sh"
    echo "4. Append closeout notes to $file:"
    echo "   - Closed: $(date -Iseconds)"
    echo "   - Summary: <provided summary>"
    echo "   - Branch: $(get_current_branch)"
    echo "   - Commit: $(get_short_commit)"
    echo "5. Log to session via session-log.sh"
    echo "6. Print: ./scripts/slice-queue.sh next"
    echo ""

    echo "--- What Would Happen on 'blocked' ---"
    echo "1. Update status to 'blocked' via slice-queue.sh"
    echo "2. Append blocker reason to $file"
    echo "3. Log to session via session-log.sh"
    echo ""

    echo "--- What Would Happen on 'deferred' ---"
    echo "1. Update status to 'deferred' via slice-queue.sh"
    echo "2. Append deferral reason to $file"
    echo "3. Log to session via session-log.sh"
    echo ""

    echo "Dry-run complete. No files were modified."
}

cmd_done() {
    local name="$1"
    local summary="$2"
    validate_slice_name "$name"

    local file
    file=$(slice_file "$name")

    echo "=== Slice Closeout: $name ==="
    echo ""

    # Verify slice exists
    if [[ ! -f "$file" ]]; then
        echo "[FAIL] Slice '$name' not found at $file"
        echo "Run './scripts/slice-queue.sh list' to see available slices"
        exit 1
    fi

    echo "[PASS] Slice file exists: $file"
    echo ""

    # Check for uncommitted changes
    check_uncommitted_changes || true
    echo ""

    # Run diagnostics
    echo "Running diagnostics..."
    echo ""
    if ! run_diagnostics; then
        echo ""
        echo "[FAIL] Diagnostics reported failures."
        echo "Cannot mark slice as 'done' until diagnostics pass."
        echo "Review and fix issues, then re-run closeout."
        exit 1
    fi
    echo ""

    # Get metadata
    local timestamp branch commit
    timestamp=$(date -Iseconds)
    branch=$(get_current_branch)
    commit=$(get_short_commit)

    # Update status to done
    echo "Updating slice status to 'done'..."
    "$SCRIPT_DIR/slice-queue.sh" status "$name" done
    echo ""

    # Append closeout notes to slice file
    echo "Appending closeout notes to $file..."
    cat >> "$file" <<EOF

---
Closed: $timestamp
Summary: $summary
Branch: $branch
Commit: $commit
EOF

    # Log to session
    echo "Logging to session..."
    "$SCRIPT_DIR/session-log.sh" "Completed slice: $name - $summary"
    echo ""

    # Print final summary
    echo "=== Closeout Complete ==="
    echo ""
    echo "Slice: $name"
    echo "Status: done"
    echo "Summary: $summary"
    echo "Branch: $branch"
    echo "Commit: $commit"
    echo "Closed: $timestamp"
    echo ""
    echo "Recommended next command:"
    echo "  ./scripts/slice-queue.sh next"
}

cmd_blocked() {
    local name="$1"
    local reason="$2"
    validate_slice_name "$name"

    local file
    file=$(slice_file "$name")

    echo "=== Slice Closeout: $name (Blocked) ==="
    echo ""

    # Verify slice exists
    if [[ ! -f "$file" ]]; then
        echo "[FAIL] Slice '$name' not found at $file"
        echo "Run './scripts/slice-queue.sh list' to see available slices"
        exit 1
    fi

    echo "[PASS] Slice file exists: $file"
    echo ""

    # Update status to blocked
    echo "Updating slice status to 'blocked'..."
    "$SCRIPT_DIR/slice-queue.sh" status "$name" blocked
    echo ""

    # Append blocker reason
    local timestamp
    timestamp=$(date -Iseconds)
    echo "Appending blocker reason to $file..."
    cat >> "$file" <<EOF

---
Blocked: $timestamp
Reason: $reason
EOF

    # Log to session
    echo "Logging to session..."
    "$SCRIPT_DIR/session-log.sh" "Blocked slice: $name - $reason"
    echo ""

    # Print final summary
    echo "=== Slice Blocked ==="
    echo ""
    echo "Slice: $name"
    echo "Status: blocked"
    echo "Reason: $reason"
    echo "Blocked: $timestamp"
    echo ""
    echo "Slice remains in queue for future unblocking."
}

cmd_deferred() {
    local name="$1"
    local reason="$2"
    validate_slice_name "$name"

    local file
    file=$(slice_file "$name")

    echo "=== Slice Closeout: $name (Deferred) ==="
    echo ""

    # Verify slice exists
    if [[ ! -f "$file" ]]; then
        echo "[FAIL] Slice '$name' not found at $file"
        echo "Run './scripts/slice-queue.sh list' to see available slices"
        exit 1
    fi

    echo "[PASS] Slice file exists: $file"
    echo ""

    # Update status to deferred
    echo "Updating slice status to 'deferred'..."
    "$SCRIPT_DIR/slice-queue.sh" status "$name" deferred
    echo ""

    # Append deferral reason
    local timestamp
    timestamp=$(date -Iseconds)
    echo "Appending deferral reason to $file..."
    cat >> "$file" <<EOF

---
Deferred: $timestamp
Reason: $reason
EOF

    # Log to session
    echo "Logging to session..."
    "$SCRIPT_DIR/session-log.sh" "Deferred slice: $name - $reason"
    echo ""

    # Print final summary
    echo "=== Slice Deferred ==="
    echo ""
    echo "Slice: $name"
    echo "Status: deferred"
    echo "Reason: $reason"
    echo "Deferred: $timestamp"
    echo ""
    echo "Slice remains in queue for future reactivation."
}

# Main command dispatch
if [[ $# -lt 1 ]]; then
    usage
    exit 1
fi

command="$1"
shift

case "$command" in
    help|--help|-h)
        usage
        ;;
    dry-run)
        if [[ $# -lt 1 ]]; then
            echo "ERROR: 'dry-run' requires <slice-name>"
            echo ""
            usage
            exit 1
        fi
        cmd_dry_run "$1"
        ;;
    done)
        if [[ $# -lt 2 ]]; then
            echo "ERROR: 'done' requires <slice-name> and \"<summary>\""
            echo ""
            usage
            exit 1
        fi
        cmd_done "$1" "$2"
        ;;
    blocked)
        if [[ $# -lt 2 ]]; then
            echo "ERROR: 'blocked' requires <slice-name> and \"<reason>\""
            echo ""
            usage
            exit 1
        fi
        cmd_blocked "$1" "$2"
        ;;
    deferred)
        if [[ $# -lt 2 ]]; then
            echo "ERROR: 'deferred' requires <slice-name> and \"<reason>\""
            echo ""
            usage
            exit 1
        fi
        cmd_deferred "$1" "$2"
        ;;
    *)
        echo "ERROR: Unknown command '$command'"
        echo ""
        usage
        exit 1
        ;;
esac
