#!/bin/bash
# Quick helper to show worktrees for a feature

FEATURE="$1"

if [[ -z "$FEATURE" ]]; then
    echo "Usage: $0 <feature-name>"
    echo ""
    ./tmops_tools/list_features.sh
    exit 1
fi

WORKTREE_PREFIX="wt-${FEATURE}"

# Check if feature exists
if ! git worktree list | grep -q "$WORKTREE_PREFIX"; then
    echo "❌ Feature '$FEATURE' not found"
    echo ""
    echo "Available features:"
    git worktree list | grep "wt-" | sed 's/.*wt-/  • /' | sed 's/-[^-]*$//' | sort -u
    echo ""
    echo "To create this feature:"
    echo "  ./tmops_tools/init_feature_multi.sh $FEATURE"
    exit 1
fi

echo "╔═══════════════════════════════════════════════╗"
echo "║  Feature: $FEATURE"
echo "╚═══════════════════════════════════════════════╝"
echo ""
echo "📂 Worktrees:"
for role in orchestrator tester impl verify; do
    WORKTREE="${WORKTREE_PREFIX}-${role}"
    if [[ -d "$WORKTREE" ]]; then
        echo "  ✓ cd $WORKTREE"
    else
        echo "  ✗ $WORKTREE (missing)"
    fi
done

echo ""
echo "📄 Task Spec:"
echo "  .tmops/$FEATURE/runs/current/TASK_SPEC.md"

echo ""
echo "📊 Checkpoints:"
if [[ -d ".tmops/$FEATURE/runs/current/checkpoints" ]]; then
    COUNT=$(ls ".tmops/$FEATURE/runs/current/checkpoints" 2>/dev/null | wc -l)
    echo "  $COUNT checkpoint(s) created"
    if [[ $COUNT -gt 0 ]]; then
        echo "  Latest: $(ls -t ".tmops/$FEATURE/runs/current/checkpoints" | head -1)"
    fi
else
    echo "  No checkpoints yet"
fi