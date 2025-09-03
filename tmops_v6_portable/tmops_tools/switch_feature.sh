#!/bin/bash
# 📁 FILE: /home/anthonycalek/projects/tmops_framework/CODE/tmops-header-standardization/tmops_v6_portable/tmops_tools/switch_feature.sh
# 🎯 PURPOSE: Feature context switching utility to display information and status for specific TeamOps features
# 🤖 AI-HINT: Use to switch active feature context and display detailed information about feature status and artifacts
# 🔗 DEPENDENCIES: .tmops/FEATURES.txt, git branches, feature directories
# 📝 CONTEXT: Context management utility for working with multiple concurrent TeamOps features
# Switch context to a specific feature (show info)

set -e

FEATURE="$1"

if [[ -z "$FEATURE" ]]; then
    echo "Usage: $0 <feature-name>"
    exit 1
fi

# Check if feature exists
if [[ ! -f "../.tmops/FEATURES.txt" ]]; then
    echo "No features initialized yet."
    echo "Run: ./tmops_tools/init_feature_multi.sh <feature-name>"
    exit 0
fi

if ! grep -q "^$FEATURE:" ../.tmops/FEATURES.txt 2>/dev/null; then
    echo "Feature '$FEATURE' not found."
    echo ""
    echo "Available features:"
    cut -d: -f1 ../.tmops/FEATURES.txt | sort -u | sed 's/^/  • /'
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
echo "  ../.tmops/$FEATURE/runs/current/TASK_SPEC.md"

if [[ -f "../.tmops/$FEATURE/runs/current/TASK_SPEC.md" ]]; then
    echo "  ✓ Task spec exists"
else
    echo "  ✗ Task spec not found"
fi

echo ""
echo "📚 Documentation:"
if [[ -d "../.tmops/$FEATURE/docs" ]]; then
    INTERNAL_COUNT=$(find "../.tmops/$FEATURE/docs/internal" -type f 2>/dev/null | wc -l)
    EXTERNAL_COUNT=$(find "../.tmops/$FEATURE/docs/external" -type f 2>/dev/null | wc -l)
    echo "  ✓ Docs directory exists"
    echo "    └─ Internal docs: $INTERNAL_COUNT files"
    echo "    └─ External docs: $EXTERNAL_COUNT files"
else
    echo "  ✗ Docs directory not found"
fi

echo ""
echo "📂 TeamOps Directory:"
if [[ -d "../.tmops/$FEATURE" ]]; then
    echo "  ✓ ../.tmops/$FEATURE exists"
    CHECKPOINT_COUNT=$(find "../.tmops/$FEATURE" -name "*.md" -type f 2>/dev/null | wc -l)
    echo "  📝 Checkpoints: $CHECKPOINT_COUNT files"
else
    echo "  ✗ ../.tmops/$FEATURE missing"
fi

echo ""
echo "To start working:"
echo "  1. cd ..  # Go to root project directory"
echo "  2. git checkout feature/$FEATURE"
echo "  3. Open 4 Claude Code instances (all in root directory)"
echo "  4. Paste role instructions from tmops_v6_portable/instance_instructions/"