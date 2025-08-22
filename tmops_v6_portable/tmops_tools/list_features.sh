#!/bin/bash
# List all TeamOps features and their status

echo "╔═══════════════════════════════════════════════╗"
echo "║         TeamOps Features Status              ║"
echo "╚═══════════════════════════════════════════════╝"
echo ""

# Active features (have worktrees)
echo "📂 Active Features (have worktrees):"
echo "────────────────────────────────────"

ACTIVE_FEATURES=""
git worktree list 2>/dev/null | grep "wt-" | while read -r line; do
    WORKTREE=$(echo "$line" | awk '{print $1}' | xargs basename)
    BRANCH=$(echo "$line" | grep -o '\[.*\]' | tr -d '[]')
    
    # Extract feature name from worktree
    # Pattern: wt-FEATURE-ROLE
    if [[ "$WORKTREE" =~ ^wt-([^-]+.*)-([^-]+)$ ]]; then
        FEATURE="${BASH_REMATCH[1]}"
        ROLE="${BASH_REMATCH[2]}"
        
        # Only show each feature once
        if [[ ! "$ACTIVE_FEATURES" =~ "$FEATURE" ]]; then
            echo "  • $FEATURE"
            echo "    └─ Worktrees: wt-${FEATURE}-*"
            echo "    └─ Branch: $BRANCH"
            ACTIVE_FEATURES="$ACTIVE_FEATURES $FEATURE"
        fi
    fi
done

if [[ -z "$ACTIVE_FEATURES" ]]; then
    echo "  (none)"
fi

echo ""
echo "📁 Feature Directories in .tmops/:"
echo "──────────────────────────────────"

if [[ -d .tmops ]]; then
    for dir in .tmops/*/; do
        if [[ -d "$dir" && ! "$dir" =~ \.archive|\.backup ]]; then
            FEATURE=$(basename "$dir")
            
            # Check for checkpoints
            CHECKPOINT_COUNT=0
            if [[ -d "$dir/runs/current/checkpoints" ]]; then
                CHECKPOINT_COUNT=$(ls "$dir/runs/current/checkpoints" 2>/dev/null | wc -l)
            fi
            
            # Check if has worktrees
            if git worktree list | grep -q "wt-${FEATURE}-"; then
                STATUS="✓ Active"
            else
                STATUS="○ No worktrees"
            fi
            
            echo "  • $FEATURE [$STATUS]"
            echo "    └─ Checkpoints: $CHECKPOINT_COUNT"
        fi
    done
else
    echo "  (no .tmops directory)"
fi

echo ""
echo "💡 Quick Commands:"
echo "─────────────────"
echo "  Start new:    ./tmops_tools/init_feature_multi.sh <name>"
echo "  Switch to:    ./tmops_tools/switch_feature.sh <name>"
echo "  Clean up:     ./tmops_tools/cleanup_safe.sh <name>"
echo "  Get metrics:  ./tmops_tools/extract_metrics.py <name>"