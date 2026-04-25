#!/bin/bash
set -euo pipefail

# Slice Queue Manager for Ollamaclaw
# Manages a simple project-local queue of build slices

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SLICES_DIR="$PROJECT_ROOT/.ollamaclaw/slices"

# Ensure slices directory exists
mkdir -p "$SLICES_DIR"

usage() {
    cat <<EOF
Slice Queue Manager for Ollamaclaw

Usage:
  $0 <command> [arguments]

Commands:
  list                              List all slices with status and goal
  add <slice-name> "<goal>"         Add a new planned slice
  show <slice-name>                 Show details of a specific slice
  status <slice-name> <status>      Update slice status
  next                              Show the next planned slice
  help                              Show this help message

Status Values:
  planned    - Slice is queued and ready to start
  active     - Slice is currently being worked on
  blocked    - Slice is blocked by an external dependency
  done       - Slice is completed
  deferred   - Slice is postponed for later

Examples:
  $0 add docs-cleanup "Clean and align documentation after worktree protocol"
  $0 list
  $0 show docs-cleanup
  $0 status docs-cleanup active
  $0 next
  $0 help

Notes:
  - Slice names must be lowercase hyphenated (e.g., my-slice-name)
  - Slices are stored as Markdown files in .ollamaclaw/slices/
  - Queue tracks intent; Git tracks actual code

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

cmd_add() {
    local name="$1"
    local goal="$2"
    local timestamp
    timestamp=$(date -Iseconds)

    validate_slice_name "$name"

    local file
    file=$(slice_file "$name")

    if [[ -f "$file" ]]; then
        echo "ERROR: Slice '$name' already exists at $file"
        echo "Use '$0 show $name' to view it or choose a different name"
        exit 1
    fi

    cat > "$file" <<EOF
# Slice: $name
Status: planned
Goal: $goal
Branch:
Worktree:
File Scope:
Validation:
Blockers:
Notes:
Created: $timestamp
Updated: $timestamp
EOF

    echo "Added slice: $name"
    echo "File: $file"
    echo ""
    echo "Recommended next steps:"
    echo "  $0 show $name"
    echo "  $0 status $name active    # When starting work"
    echo "  ./scripts/worktree-slice.sh plan $name"
}

cmd_list() {
    local count=0
    local planned=0
    local active=0
    local blocked=0
    local done=0
    local deferred=0

    echo "=== Slice Queue ==="
    echo ""

    if [[ ! -d "$SLICES_DIR" ]] || [[ -z "$(ls -A "$SLICES_DIR" 2>/dev/null)" ]]; then
        echo "No slices in queue yet."
        echo ""
        echo "Add your first slice:"
        echo "  $0 add <slice-name> \"<goal>\""
        return 0
    fi

    printf "%-30s %-12s %s\n" "SLICE" "STATUS" "GOAL"
    printf "%-30s %-12s %s\n" "-----" "------" "----"

    for file in "$SLICES_DIR"/*.md; do
        [[ -f "$file" ]] || continue
        count=$((count + 1))

        local name status goal
        name=$(basename "$file" .md)
        status=$(grep "^Status:" "$file" 2>/dev/null | cut -d: -f2- | xargs || echo "unknown")
        goal=$(grep "^Goal:" "$file" 2>/dev/null | cut -d: -f2- | xargs || echo "(no goal)")

        printf "%-30s %-12s %s\n" "$name" "$status" "$goal"

        case "$status" in
            planned) planned=$((planned + 1)) ;;
            active) active=$((active + 1)) ;;
            blocked) blocked=$((blocked + 1)) ;;
            done) done=$((done + 1)) ;;
            deferred) deferred=$((deferred + 1)) ;;
        esac
    done

    echo ""
    echo "=== Summary ==="
    echo "Total: $count | Planned: $planned | Active: $active | Blocked: $blocked | Done: $done | Deferred: $deferred"
}

cmd_show() {
    local name="$1"
    validate_slice_name "$name"

    local file
    file=$(slice_file "$name")

    if [[ ! -f "$file" ]]; then
        echo "ERROR: Slice '$name' not found"
        echo "Run '$0 list' to see available slices"
        exit 1
    fi

    cat "$file"
}

cmd_status() {
    local name="$1"
    local new_status="$2"

    validate_slice_name "$name"

    local file
    file=$(slice_file "$name")

    if [[ ! -f "$file" ]]; then
        echo "ERROR: Slice '$name' not found"
        echo "Run '$0 list' to see available slices"
        exit 1
    fi

    case "$new_status" in
        planned|active|blocked|done|deferred) ;;
        *)
            echo "ERROR: Invalid status '$new_status'"
            echo "Valid statuses: planned, active, blocked, done, deferred"
            exit 1
            ;;
    esac

    local timestamp
    timestamp=$(date -Iseconds)

    # Update Status and Updated lines only
    local tmpfile
    tmpfile=$(mktemp)
    while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ "$line" =~ ^Status: ]]; then
            echo "Status: $new_status"
        elif [[ "$line" =~ ^Updated: ]]; then
            echo "Updated: $timestamp"
        else
            echo "$line"
        fi
    done < "$file" > "$tmpfile"
    mv "$tmpfile" "$file"

    echo "Updated slice '$name' status to: $new_status"
    echo "Updated: $timestamp"
}

cmd_next() {
    echo "=== Next Slice ==="
    echo ""

    if [[ ! -d "$SLICES_DIR" ]] || [[ -z "$(ls -A "$SLICES_DIR" 2>/dev/null)" ]]; then
        echo "No slices in queue."
        echo ""
        echo "Add a slice:"
        echo "  $0 add <slice-name> \"<goal>\""
        return 0
    fi

    # Find first planned slice
    local found_planned=""
    local blocked_list=""
    local deferred_list=""

    for file in "$SLICES_DIR"/*.md; do
        [[ -f "$file" ]] || continue

        local name status
        name=$(basename "$file" .md)
        status=$(grep "^Status:" "$file" 2>/dev/null | cut -d: -f2- | xargs || echo "")

        case "$status" in
            planned)
                if [[ -z "$found_planned" ]]; then
                    found_planned="$file"
                fi
                ;;
            blocked)
                blocked_list="$blocked_list  - $name"$'\n'
                ;;
            deferred)
                deferred_list="$deferred_list  - $name"$'\n'
                ;;
        esac
    done

    if [[ -n "$found_planned" ]]; then
        echo "Next planned slice:"
        cat "$found_planned"
        echo ""
        echo "Recommended next steps:"
        local name
        name=$(basename "$found_planned" .md)
        echo "  $0 status $name active"
        echo "  ./scripts/worktree-slice.sh plan $name"
        return 0
    fi

    echo "No planned slices ready to start."
    echo ""

    if [[ -n "$blocked_list" ]]; then
        echo "Blocked slices:"
        echo -n "$blocked_list"
    fi

    if [[ -n "$deferred_list" ]]; then
        echo "Deferred slices:"
        echo -n "$deferred_list"
    fi

    if [[ -z "$blocked_list" ]] && [[ -z "$deferred_list" ]]; then
        echo "All slices are either done or no slices exist yet."
        echo ""
        echo "Add a new slice:"
        echo "  $0 add <slice-name> \"<goal>\""
    fi
}

# Main command dispatch
if [[ $# -lt 1 ]]; then
    usage
    exit 1
fi

command="$1"
shift

case "$command" in
    list)
        cmd_list
        ;;
    add)
        if [[ $# -lt 2 ]]; then
            echo "ERROR: 'add' requires <slice-name> and \"<goal>\""
            echo ""
            usage
            exit 1
        fi
        cmd_add "$1" "$2"
        ;;
    show)
        if [[ $# -lt 1 ]]; then
            echo "ERROR: 'show' requires <slice-name>"
            echo ""
            usage
            exit 1
        fi
        cmd_show "$1"
        ;;
    status)
        if [[ $# -lt 2 ]]; then
            echo "ERROR: 'status' requires <slice-name> and <status>"
            echo ""
            usage
            exit 1
        fi
        cmd_status "$1" "$2"
        ;;
    next)
        cmd_next
        ;;
    help|--help|-h)
        usage
        ;;
    *)
        echo "ERROR: Unknown command '$command'"
        echo ""
        usage
        exit 1
        ;;
esac
