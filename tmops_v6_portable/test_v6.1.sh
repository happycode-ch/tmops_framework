#!/bin/bash
# Quick test of v6.2 simplified capabilities

echo "Testing TeamOps v6.2 (no worktrees)..."

# Test 1: Feature creation
echo "Test 1: Creating two features..."
./tmops_tools/init_feature_multi.sh test-a
git checkout main 2>/dev/null || git checkout master 2>/dev/null
./tmops_tools/init_feature_multi.sh test-b

# Verify branches
if ! git show-ref --verify --quiet "refs/heads/feature/test-a"; then
    echo "FAIL: feature/test-a branch not created"
    exit 1
fi

if ! git show-ref --verify --quiet "refs/heads/feature/test-b"; then
    echo "FAIL: feature/test-b branch not created"
    exit 1
fi

echo "✓ Feature branch creation works"

# Verify .tmops directories
if [[ ! -d ".tmops/test-a" ]]; then
    echo "FAIL: .tmops/test-a not created"
    exit 1
fi

if [[ ! -d ".tmops/test-b" ]]; then
    echo "FAIL: .tmops/test-b not created"
    exit 1
fi

echo "✓ TeamOps directories created"

# Test 2: Safe cleanup
echo "Test 2: Testing safe cleanup..."
git checkout main 2>/dev/null || git checkout master 2>/dev/null
./tmops_tools/cleanup_safe.sh test-a

if git show-ref --verify --quiet "refs/heads/feature/test-a"; then
    echo "FAIL: test-a branch not cleaned"
    exit 1
fi

if ! git show-ref --verify --quiet "refs/heads/feature/test-b"; then
    echo "FAIL: test-b branch was incorrectly removed"
    exit 1
fi

echo "✓ Safe cleanup works"

# Clean up test
./tmops_tools/cleanup_safe.sh test-b

echo ""
echo "✅ All tests passed! v6.2 (simplified) is ready."