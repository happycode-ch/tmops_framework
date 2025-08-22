#!/bin/bash
# List all TeamOps features and their status

echo "╔═══════════════════════════════════════════════╗"
echo "║         TeamOps Features Status              ║"
echo "╚═══════════════════════════════════════════════╝"
echo ""

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)

echo "📂 Active Features:"
echo "────────────────────────────────────"

if [[ ! -f ".tmops/FEATURES.txt" ]]; then
    echo "  (none - no features initialized)"
    echo ""
    echo "💡 Quick Commands:"
    echo "─────────────────"
    echo "  Start new:    ./tmops_tools/init_feature_multi.sh <name>"
    exit 0
fi

# List features from tracking file
while IFS=: read -r feature status timestamp branch_info; do
    echo "  • $feature"
    
    # Check branch status
    if [[ "$CURRENT_BRANCH" == "feature/$feature" ]]; then
        echo "    └─ Branch: feature/$feature [CURRENT]"
    elif git show-ref --verify --quiet "refs/heads/feature/$feature"; then
        echo "    └─ Branch: feature/$feature [exists]"
    else
        echo "    └─ Branch: feature/$feature [missing]"
    fi
    
    # Check for checkpoints
    CHECKPOINT_COUNT=0
    if [[ -d ".tmops/$feature/runs/current/checkpoints" ]]; then
        CHECKPOINT_COUNT=$(ls ".tmops/$feature/runs/current/checkpoints" 2>/dev/null | wc -l)
    fi
    echo "    └─ Checkpoints: $CHECKPOINT_COUNT"
    echo "    └─ Created: $(echo $timestamp | cut -d'T' -f1)"
    
done < .tmops/FEATURES.txt

echo ""
echo "📁 .tmops Directory Status:"
echo "──────────────────────────────────"

if [[ -d .tmops ]]; then
    for dir in .tmops/*/; do
        if [[ -d "$dir" && ! "$dir" =~ \.archive|\.backup ]]; then
            FEATURE=$(basename "$dir")
            
            # Check if tracked
            if grep -q "^$FEATURE:" .tmops/FEATURES.txt 2>/dev/null; then
                STATUS="✓ Tracked"
            else
                STATUS="⚠️  Orphaned"
            fi
            
            echo "  • $FEATURE [$STATUS]"
        fi
    done
else
    echo "  (no .tmops directory)"
fi

echo ""
echo "💡 Quick Commands:"
echo "─────────────────"
echo "  Start new:    ./tmops_tools/init_feature_multi.sh <name>"
echo "  Switch to:    git checkout feature/<name>"
echo "  View info:    ./tmops_tools/switch_feature.sh <name>"
echo "  Clean up:     ./tmops_tools/cleanup_safe.sh <name>"
echo "  Get metrics:  ./tmops_tools/extract_metrics.py <name>"