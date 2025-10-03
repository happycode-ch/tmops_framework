#!/bin/bash
# 📁 FILE: tmops_v6_portable/tmops_tools/init_feature_multi.sh
# 🎯 PURPOSE: Initialize TeamOps features with directory structure, branches, and runs
# 🤖 AI-HINT: Supports multi-run and flexible branch modes
# 🔗 DEPENDENCIES: git, tmops_tools/lib/common.sh
# 📝 CONTEXT: Multi-feature initialization with optional preflight handoff detection
# TeamOps v6.1 - Multi-feature initialization
# Can run multiple features simultaneously

set -e

# Positional and flags parsing
FEATURE="${1:-}"
MODE="default"        # default|use_current|skip|explicit
RESOLVED_BRANCH=""

if [[ -z "$FEATURE" ]]; then
  echo "Usage: $0 <feature> [run-type] [--use-current-branch|--skip-branch|--branch <name>]" >&2
  exit 1
fi

# Determine RUN_TYPE from second arg if not a flag
if [[ -n "${2:-}" && "${2}" != --* ]]; then
  RUN_TYPE="$2"
  shift 2
else
  RUN_TYPE="initial"
  shift 1
fi

# Parse flags
while [[ $# -gt 0 ]]; do
  case "$1" in
    --use-current-branch)
      MODE="use_current"; shift ;;
    --skip-branch)
      MODE="skip"; shift ;;
    --branch)
      MODE="explicit"; RESOLVED_BRANCH="$2"; shift 2 ;;
    *)
      shift ;;
  esac
done

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PORTABLE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Always use the parent of tmops_v6_portable as project root
# This ensures consistent behavior regardless of where script is run from
PROJECT_ROOT="$(cd "$PORTABLE_DIR/.." && pwd)"

# Set instructions directory based on what exists
if [[ -d "$PORTABLE_DIR/instance_instructions" ]]; then
    INSTRUCTIONS_DIR="$PORTABLE_DIR/instance_instructions"
else
    INSTRUCTIONS_DIR="$PORTABLE_DIR/docs/tmops_docs_v6"
fi

# Validate feature name (enforce safe names)
if [[ ! "$FEATURE" =~ ^[a-z0-9-]{3,20}$ ]]; then
    echo "Error: Feature names must be:"
    echo "  - 3-20 characters long"
    echo "  - Only lowercase letters, numbers, and hyphens"
    echo "  Example: auth-api, user-login, payment-v2"
    exit 1
fi

# Check for old single-feature worktrees
if [[ -d "wt-orchestrator" ]]; then
    echo "⚠️  WARNING: Found old v6.0 worktrees (wt-orchestrator, etc)"
    echo "These conflict with multi-feature support."
    echo "Please run: ./tmops_tools/cleanup_feature.sh <old-feature>"
    echo "Then retry this command."
    exit 1
fi

echo "═══════════════════════════════════════════════"
echo "  TeamOps Feature Initialization"
echo "═══════════════════════════════════════════════"
echo ""
echo "Feature: $FEATURE"

# Determine resolved branch name
if [[ "$MODE" == "use_current" || "$MODE" == "skip" ]]; then
  RESOLVED_BRANCH="$(git branch --show-current)"
fi
if [[ -z "$RESOLVED_BRANCH" ]]; then
  RESOLVED_BRANCH="feature/$FEATURE"
fi

echo "Branch: $RESOLVED_BRANCH"
echo ""

# Create feature directory in project root
TMOPS_DIR="$PROJECT_ROOT/.tmops"
FEATURE_DIR="$TMOPS_DIR/$FEATURE"
RUN_DIR="$FEATURE_DIR/runs/$RUN_TYPE"

mkdir -p "$RUN_DIR"/{checkpoints,logs}
mkdir -p "$FEATURE_DIR/docs"/{internal,external,archive,images}

# Check for existing refined specification from preflight
REFINED_SPEC_EXISTS=false
if [[ -f "$RUN_DIR/TASK_SPEC.md" ]]; then
    if grep -q "Created by preflight workflow\|Refined by preflight" "$RUN_DIR/TASK_SPEC.md" 2>/dev/null; then
        REFINED_SPEC_EXISTS=true
        echo "🎯 Using existing refined specification from preflight workflow"
        echo "   Task specification already refined and ready for implementation"
        echo ""
    fi
fi

# Generate basic TASK_SPEC.md template only if no refined spec exists
if [[ "$REFINED_SPEC_EXISTS" == "false" ]]; then
    if [[ -f "$RUN_DIR/TASK_SPEC.md" ]]; then
        echo "⚠️  Found basic task spec - will be replaced with template"
        echo "   Consider using preflight workflow for complex features"
        echo ""
    fi
    cat > "$RUN_DIR/TASK_SPEC.md" << 'EOF'
# Task Specification: FEATURE_NAME
Version: 1.0.0
Created: DATE
Status: Active

## User Story
As a ...
I want ...
So that ...

## Acceptance Criteria
- [ ] First requirement
- [ ] Second requirement
- [ ] Third requirement

## Technical Constraints
- Use existing project structure
- Follow project conventions
- Maintain test coverage

## Definition of Done
- All tests passing
- Code reviewed (by Verifier)
- Metrics captured
EOF
    sed -i "s/FEATURE_NAME/$FEATURE/g" "$RUN_DIR/TASK_SPEC.md"
    sed -i "s/DATE/$(date -I)/g" "$RUN_DIR/TASK_SPEC.md"
    echo "✓ Created TASK_SPEC.md template"
    echo ""
    echo "💡 For complex features, consider using preflight workflow:"
    echo "   ./tmops_tools/init_preflight.sh $FEATURE"
    echo "   (Research → Analysis → Specification → Main Workflow)"
    echo ""
fi

# Create current symlink for this feature
ln -sfn "runs/$RUN_TYPE" "$FEATURE_DIR/current"

# Create or checkout feature branch (unless skipped or using current)
if [[ "$MODE" != "skip" && "$MODE" != "use_current" ]]; then
    echo "Setting up feature branch..."
    if git show-ref --verify --quiet "refs/heads/$RESOLVED_BRANCH"; then
        echo "  ✓ Checking out existing branch: $RESOLVED_BRANCH"
        git checkout "$RESOLVED_BRANCH"
    else
        echo "  ✓ Creating new branch: $RESOLVED_BRANCH"
        git checkout -b "$RESOLVED_BRANCH"
    fi
else
    echo "Skipping branch operations (mode: $MODE). Using current branch: $RESOLVED_BRANCH"
fi

# Track in simple text file (not JSON)
mkdir -p "$TMOPS_DIR"
# Track feature with resolved branch (idempotent)
if [[ -f "$PORTABLE_DIR/tmops_tools/lib/common.sh" ]]; then
  # shellcheck source=/dev/null
  source "$PORTABLE_DIR/tmops_tools/lib/common.sh"
  get_project_paths
  track_feature "$FEATURE" "active" "$RESOLVED_BRANCH"
else
  echo "$FEATURE:active:$(date -Iseconds):$RESOLVED_BRANCH" >> "$TMOPS_DIR/FEATURES.txt"
fi

echo ""
echo "═══════════════════════════════════════════════"
echo "  ✅ Feature '$FEATURE' Ready!"
echo "═══════════════════════════════════════════════"
echo ""
echo "Next steps:"
echo ""
echo "1. Edit task specification:"
echo "   vim $RUN_DIR/TASK_SPEC.md"
echo ""
echo "2. Open 4 Claude Code instances in the ROOT directory:"
echo "   cd $PROJECT_ROOT  # Go to root project directory"
echo "   Terminal 1: claude  # For Orchestrator"
echo "   Terminal 2: claude  # For Tester"
echo "   Terminal 3: claude  # For Implementer"
echo "   Terminal 4: claude  # For Verifier"
echo ""
echo "3. Paste role instructions from $INSTRUCTIONS_DIR/:"
echo "   • 01_orchestrator.md → orchestrator terminal"
echo "   • 02_tester.md → tester terminal"
echo "   • 03_implementer.md → implementer terminal"
echo "   • 04_verifier.md → verifier terminal"
echo ""
echo "4. Start orchestration:"
echo "   You → Orchestrator: '[BEGIN]: Start orchestration for $FEATURE'"
echo ""
echo "To work on a different feature:"
echo "   git checkout main  # Return to main first"
echo "   ./tmops_tools/init_feature_multi.sh other-feature"
