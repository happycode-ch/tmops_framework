#!/bin/bash
# TeamOps v6.1 - Multi-feature initialization
# Can run multiple features simultaneously

set -e

FEATURE="$1"
RUN_TYPE="${2:-initial}"

# Detect if portable package or full repo
if [[ -f "PORTABLE_SUMMARY.md" ]]; then
    echo "Running in portable package mode"
    INSTRUCTIONS_DIR="instance_instructions"
else
    INSTRUCTIONS_DIR="docs/tmops_docs_v6"
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

# Feature-specific worktree names
WORKTREE_PREFIX="wt-${FEATURE}"

echo "═══════════════════════════════════════════════"
echo "  TeamOps v6.1 Multi-Feature Initialization"
echo "═══════════════════════════════════════════════"
echo ""
echo "Feature: $FEATURE"
echo "Worktree prefix: ${WORKTREE_PREFIX}-*"
echo ""

# Create feature directory
TMOPS_DIR=".tmops"
FEATURE_DIR="$TMOPS_DIR/$FEATURE"
RUN_DIR="$FEATURE_DIR/runs/$RUN_TYPE"

mkdir -p "$RUN_DIR"/{checkpoints,logs}

# Generate TASK_SPEC.md if it doesn't exist
if [[ ! -f "$RUN_DIR/TASK_SPEC.md" ]]; then
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
fi

# Create current symlink for this feature
ln -sfn "runs/$RUN_TYPE" "$FEATURE_DIR/current"

# Create worktrees with role-specific branches
echo "Creating worktrees with role-specific branches..."
for role in orchestrator tester impl verify; do
    WORKTREE="${WORKTREE_PREFIX}-${role}"
    BRANCH="feature/${FEATURE}-${role}"
    
    if [[ -d "$WORKTREE" ]]; then
        echo "  ✓ $WORKTREE (already exists on branch: $BRANCH)"
    else
        # Always create role-specific branch
        git worktree add "$WORKTREE" -b "$BRANCH"
        echo "  ✓ $WORKTREE (created with branch: $BRANCH)"
    fi
done

# Create main integration branch if it doesn't exist
if ! git show-ref --verify --quiet "refs/heads/feature/$FEATURE"; then
    git branch "feature/$FEATURE" HEAD
    echo "  ✓ Created integration branch: feature/$FEATURE"
else
    echo "  ✓ Integration branch exists: feature/$FEATURE"
fi

# Track in simple text file (not JSON)
echo "$FEATURE:active:$(date -Iseconds):$WORKTREE_PREFIX" >> "$TMOPS_DIR/FEATURES.txt"

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
echo "2. Open 4 Claude Code terminals:"
echo "   cd ${WORKTREE_PREFIX}-orchestrator && claude"
echo "   cd ${WORKTREE_PREFIX}-tester && claude"
echo "   cd ${WORKTREE_PREFIX}-impl && claude"
echo "   cd ${WORKTREE_PREFIX}-verify && claude"
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
echo "To work on a different feature, just run:"
echo "   ./tmops_tools/init_feature_multi.sh other-feature"