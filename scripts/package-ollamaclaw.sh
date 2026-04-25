#!/usr/bin/env bash
set -euo pipefail

# Package Ollamaclaw Source ZIP
# Creates a safe source ZIP for uploading/sharing without including:
# - secrets, local settings, bootstrap junk
# - nested archives, git internals, caches, transient files
#
# Does not call network, launch Claude Code, commit, push, or delete files.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

# Output directory and filename
ARTIFACTS_DIR="$PROJECT_ROOT/.ollamaclaw/artifacts"
OUTPUT_FILENAME="${1:-ollamaclaw-$(date +%Y%m%d-%H%M%S).zip}"

# Ensure output filename ends with .zip
if [[ ! "$OUTPUT_FILENAME" =~ \.zip$ ]]; then
    echo "ERROR: Output filename must end with .zip" >&2
    exit 1
fi

# Create artifacts directory if it doesn't exist
mkdir -p "$ARTIFACTS_DIR"

OUTPUT_PATH="$ARTIFACTS_DIR/$OUTPUT_FILENAME"

# Check for zip command
if ! command -v zip &>/dev/null; then
    echo "ERROR: zip command not found. Please install zip." >&2
    exit 1
fi

# Temporary file list for zip
TEMP_FILELIST=$(mktemp)
trap 'rm -f "$TEMP_FILELIST"' EXIT

# Build file list of intentional project files
# Include: .claude/agents/, .claude/commands/, docs/, scripts/, .ollamaclaw/sessions/, .ollamaclaw/slices/
# Include: README.md, CLAUDE.md, .gitignore
# Exclude patterns handled by zip -x flag

cd "$PROJECT_ROOT"

# Create the ZIP with exclusions
# Exclusions:
# - .git/
# - .claude/settings.local.json
# - .env, .env.*, *.pem, *.key
# - node_modules/, __pycache__/, .venv/, venv/
# - _bootstrap_junk/
# - *.tar, *.tar.gz, *.tar.zst
# - root-level *.zip
# - .ollamaclaw/artifacts/, .ollamaclaw/tmp/

zip -r "$OUTPUT_PATH" \
    . \
    -x "*.git*" \
    -x ".claude/settings.local.json" \
    -x ".env" \
    -x ".env.*" \
    -x "*.pem" \
    -x "*.key" \
    -x "node_modules/*" \
    -x "__pycache__/*" \
    -x ".venv/*" \
    -x "venv/*" \
    -x "_bootstrap_junk/*" \
    -x "*.tar" \
    -x "*.tar.gz" \
    -x "*.tar.zst" \
    -x "ollamaclaw.zip" \
    -x ".ollamaclaw/artifacts/*" \
    -x ".ollamaclaw/tmp/*" \
    -x "*.log" \
    -x ".DS_Store" \
    -x "Thumbs.db" \
    -x ".vscode/*" \
    -x ".idea/*" \
    -x "dist/*" \
    -x "build/*" \
    -x "*.pyc" \
    >/dev/null 2>&1

if [ -f "$OUTPUT_PATH" ]; then
    SIZE=$(du -h "$OUTPUT_PATH" | cut -f1)
    echo "Package created: $OUTPUT_PATH"
    echo "Package size: $SIZE"
    echo ""
    echo "=== Package Preview (first 80 entries) ==="
    unzip -l "$OUTPUT_PATH" | head -80
    echo ""
    echo "=== Recommended Next Steps ==="
    echo "1. Run ./scripts/zip-auditor to audit package contents"
    echo "2. Run ./scripts/release-readiness.sh for final safety check"
    echo "3. Upload the package from .ollamaclaw/artifacts/ manually"
else
    echo "ERROR: Failed to create package" >&2
    exit 1
fi
