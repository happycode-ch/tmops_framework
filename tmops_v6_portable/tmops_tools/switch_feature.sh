#!/bin/bash
# Switch context to a specific feature (show info)

set -e

FEATURE="$1"

if [[ -z "$FEATURE" ]]; then
    echo "Usage: $0 <feature-name>"
    exit 1
fi

# Check if feature exists
if [[ ! -f ".tmops/FEATURES.txt" ]]; then
    echo "No features initialized yet."
    echo "Run: ./tmops_tools/init_feature_multi.sh <feature-name>"
    exit 0
fi

if ! grep -q "^$FEATURE:" .tmops/FEATURES.txt 2>/dev/null; then
    echo "Feature '$FEATURE' not found."
    echo ""
    echo "Available features:"
    cut -d: -f1 .tmops/FEATURES.txt | sort -u | sed 's/^/  • /'
    exit 1
fi

echo "╔═══════════════════════════════════════════════╗"
echo "║  Feature: $FEATURE"
echo "╚═══════════════════════════════════════════════╝"
echo ""

echo "🌿 Branch Status:"
CURRENT_BRANCH=$(git branch --show-current)
if [[ "$CURRENT_BRANCH" == "feature/$FEATURE" ]]; then
    echo "  ✓ Currently on feature/$FEATURE"
else
    echo "  ⚠️  Not on feature branch (current: $CURRENT_BRANCH)"
    echo "  To switch: git checkout feature/$FEATURE"
fi

echo ""
echo "📄 Task Spec:"
echo "  .tmops/$FEATURE/runs/current/TASK_SPEC.md"

if [[ -f ".tmops/$FEATURE/runs/current/TASK_SPEC.md" ]]; then
    echo "  ✓ Task spec exists"
else
    echo "  ✗ Task spec not found"
fi

echo ""
echo "📂 TeamOps Directory:"
if [[ -d ".tmops/$FEATURE" ]]; then
    echo "  ✓ .tmops/$FEATURE exists"
    CHECKPOINT_COUNT=$(find ".tmops/$FEATURE" -name "*.md" -type f 2>/dev/null | wc -l)
    echo "  📝 Checkpoints: $CHECKPOINT_COUNT files"
else
    echo "  ✗ .tmops/$FEATURE missing"
fi

echo ""
echo "To start working:"
echo "  1. git checkout feature/$FEATURE"
echo "  2. Open 4 Claude Code instances (all in same directory)"
echo "  3. Paste role instructions to each instance"