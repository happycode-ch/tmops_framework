#!/bin/bash
# Quick test to verify the portable package works

echo "Testing TeamOps v6 Portable Package..."
echo ""

# Check all required files exist
REQUIRED_FILES=(
    "tmops_tools/init_feature_v6.sh"
    "tmops_tools/cleanup_feature.sh"
    "tmops_tools/extract_metrics.py"
    "tmops_tools/monitor_checkpoints.py"
    "instance_instructions/01_orchestrator.md"
    "instance_instructions/02_tester.md"
    "instance_instructions/03_implementer.md"
    "instance_instructions/04_verifier.md"
    "docs/tmops_docs_v6/tmops_protocol.md"
    "docs/tmops_docs_v6/tmops_claude_code.md"
    "INSTALL.sh"
    "README_QUICK_START.md"
)

echo "Checking required files..."
MISSING=0
for file in "${REQUIRED_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        echo "  ✓ $file"
    else
        echo "  ✗ MISSING: $file"
        MISSING=$((MISSING + 1))
    fi
done

if [[ $MISSING -gt 0 ]]; then
    echo ""
    echo "ERROR: $MISSING files missing from package"
    exit 1
fi

echo ""
echo "✅ All required files present"
echo ""
echo "Package is ready to copy to any project with:"
echo "  cp -r tmops_v6_portable/ /path/to/your/project/"
echo ""
echo "Or use the installer:"
echo "  cd /path/to/your/project/"
echo "  ./tmops_v6_portable/INSTALL.sh"