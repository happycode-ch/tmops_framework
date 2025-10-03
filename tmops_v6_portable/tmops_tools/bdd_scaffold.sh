#!/usr/bin/env bash
# 📁 FILE: tmops_v6_portable/tmops_tools/bdd_scaffold.sh
# 🎯 PURPOSE: Extract ```gherkin code blocks from a curated acceptance doc into runnable .feature files
# 🤖 AI-HINT: Beginner-friendly; defaults to JavaScript (cucumber-js). Optional Python later.
# 🔗 DEPENDENCIES: bash, awk/sed, tmops_tools/lib/common.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

usage() {
  cat << EOF
Usage: $0 --from <path/to/acceptance.md> [--stack js|python] [--feature-slug <slug>] [--out <dir>] [--gen-steps]

Examples:
  $0 --from docs/product/gherkin/2025-09-23_acceptance.md --stack js
  $0 --from docs/product/gherkin/2025-09-23_acceptance.md --stack python --feature-slug directory-search
EOF
}

INPUT=""
STACK="js"
FEATURE_SLUG=""
OUT_DIR=""
GEN_STEPS=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --from) INPUT="$2"; shift 2 ;;
    --stack) STACK="$2"; shift 2 ;;
    --feature-slug) FEATURE_SLUG="$2"; shift 2 ;;
    --out) OUT_DIR="$2"; shift 2 ;;
    --gen-steps) GEN_STEPS=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; usage; exit 1 ;;
  esac
done

if [[ -z "$INPUT" || ! -f "$INPUT" ]]; then
  echo "ERROR: --from <file.md> is required and must exist" >&2
  usage; exit 1
fi

get_project_paths

# Default grouping slug from file name if not provided
base_name="$(basename "$INPUT")"
default_group="${base_name%.*}"
group_slug="${FEATURE_SLUG:-$default_group}"
group_slug="$(echo "$group_slug" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g')"

# Default output dir
if [[ -z "$OUT_DIR" ]]; then
  OUT_DIR="$PROJECT_ROOT/tests/features/$group_slug"
fi

mkdir -p "$OUT_DIR"

tmpfile="$(mktemp)"
cp "$INPUT" "$tmpfile"

# Extract gherkin blocks into temp with separators
# We will mark start/end and then split per block
awk '
  BEGIN{inblk=0}
  /^```gherkin[[:space:]]*$/ { inblk=1; print "\n@@@GHERKIN_BLOCK_START@@@"; next }
  /^```[[:space:]]*$/ { if(inblk){ print "@@@GHERKIN_BLOCK_END@@@\n"; inblk=0; next } }
  { if(inblk) print $0 }
' "$tmpfile" > "$tmpfile.blocks"

created=()
block_num=0
while IFS= read -r line; do
  if [[ "$line" == "@@@GHERKIN_BLOCK_START@@@" ]]; then
    block_num=$((block_num+1))
    current=""
    continue
  fi
  if [[ "$line" == "@@@GHERKIN_BLOCK_END@@@" ]]; then
    # determine feature name from first non-empty line starting with Feature:
    feature_title=$(echo -e "$current" | awk 'BEGIN{FS=":"} /^\s*Feature:/ {sub(/^\s*Feature:\s*/, ""); print; exit}')
    if [[ -z "$feature_title" ]]; then
      feature_title="feature-$block_num"
    fi
    feature_slug=$(echo "$feature_title" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g')
    out_file="$OUT_DIR/$feature_slug.feature"
    {
      echo "# Generated from $INPUT on $(date -Iseconds)"
      echo "# Do not edit by hand; update the curated doc and re-run scaffold."
      echo "$current"
    } > "$out_file"
    created+=("$out_file")
    current=""
    continue
  fi
  # accumulate block contents
  current+="$line\n"
done < "$tmpfile.blocks"

if [[ ${#created[@]} -eq 0 ]]; then
  echo "WARNING: No \`\`\`gherkin blocks found in $INPUT" >&2
  exit 0
fi

# Optionally generate step stubs
steps_dir="$PROJECT_ROOT/tests/steps"
mkdir -p "$steps_dir"
if [[ "$GEN_STEPS" == true ]]; then
  case "$STACK" in
    js)
      stub="$steps_dir/$group_slug.steps.js"
      if [[ ! -f "$stub" ]]; then
        cat > "$stub" << 'JS'
// Generated step stubs – fill with real step definitions.
const { Given, When, Then } = require('@cucumber/cucumber');

Given(/^.*/, function () { return 'pending'; });
When(/^.*/, function () { return 'pending'; });
Then(/^.*/, function () { return 'pending'; });
JS
      fi
      ;;
    python)
      stub="$steps_dir/test_${group_slug}_steps.py"
      if [[ ! -f "$stub" ]]; then
        cat > "$stub" << 'PY'
# Generated step stubs – fill with real step definitions.
from pytest_bdd import given, when, then

@given('...')
def _given():
    raise NotImplementedError

@when('...')
def _when():
    raise NotImplementedError

@then('...')
def _then():
    raise NotImplementedError
PY
      fi
      ;;
    *) echo "INFO: Unknown stack $STACK – skipping step stubs" ;;
  esac
fi

echo "Created ${#created[@]} feature file(s) under: $OUT_DIR"
for f in "${created[@]}"; do echo "  • $f"; done

echo
if [[ "$STACK" == "js" ]]; then
  echo "Run: npx cucumber-js $PROJECT_ROOT/tests/features"
elif [[ "$STACK" == "python" ]]; then
  echo "Run: pytest -q"
fi
