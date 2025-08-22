#!/bin/bash
# Migrate from v6.0 to v6.1 - Quick and safe

echo "╔═══════════════════════════════════════════════╗"
echo "║  TeamOps v6.0 → v6.1 Migration               ║"
echo "╚═══════════════════════════════════════════════╝"
echo ""

# Check for old worktrees
OLD_WT=$(ls -d wt-orchestrator wt-tester wt-impl wt-verify 2>/dev/null | wc -l)

if [[ $OLD_WT -gt 0 ]]; then
    echo "⚠️  Found v6.0 worktrees:"
    ls -d wt-* 2>/dev/null
    echo ""
    echo "These must be cleaned up before using v6.1"
    echo ""
    read -p "What feature were you working on? " FEATURE
    echo ""
    echo "Please run:"
    echo "  ./tmops_tools/cleanup_feature.sh $FEATURE"
    echo "Then run this migration again."
    exit 1
fi

# Backup current structure
echo "Creating backup..."
tar -czf ".tmops-backup-v6.0-$(date +%Y%m%d-%H%M%S).tar.gz" .tmops 2>/dev/null || true

# Create v6.1 structure
mkdir -p .tmops/.archive
mkdir -p .tmops/.backups
touch .tmops/FEATURES.txt

# Update documentation
if [[ ! -f "README.md.v6.0" ]]; then
    cp README.md README.md.v6.0 2>/dev/null || true
fi

echo ""
echo "✅ Migration complete!"
echo ""
echo "What's new:"
echo "  • Multi-feature support via init_feature_multi.sh"
echo "  • Safe cleanup via cleanup_safe.sh"
echo "  • Feature listing via list_features.sh"
echo ""
echo "Start your first v6.1 feature:"
echo "  ./tmops_tools/init_feature_multi.sh my-feature"