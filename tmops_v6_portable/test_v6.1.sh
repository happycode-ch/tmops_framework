#!/bin/bash
# Quick test of v6.1 capabilities

echo "Testing TeamOps v6.1..."

# Test 1: Multi-feature creation
echo "Test 1: Creating two features..."
./tmops_tools/init_feature_multi.sh test-a
./tmops_tools/init_feature_multi.sh test-b

# Verify worktrees
if [[ ! -d "wt-test-a-orchestrator" ]]; then
    echo "FAIL: test-a worktrees not created"
    exit 1
fi

if [[ ! -d "wt-test-b-orchestrator" ]]; then
    echo "FAIL: test-b worktrees not created"
    exit 1
fi

echo "✓ Multi-feature creation works"

# Verify branches were created correctly
echo "Verifying branch structure..."
for feature in test-a test-b; do
    for role in orchestrator tester impl verify; do
        if ! git show-ref --verify --quiet "refs/heads/feature/${feature}-${role}"; then
            echo "FAIL: Branch feature/${feature}-${role} not created"
            exit 1
        fi
    done
    if ! git show-ref --verify --quiet "refs/heads/feature/${feature}"; then
        echo "FAIL: Integration branch feature/${feature} not created"
        exit 1
    fi
done
echo "✓ Branch structure correct"

# Test 2: Safe cleanup
echo "Test 2: Testing safe cleanup..."
./tmops_tools/cleanup_safe.sh test-a

if [[ -d "wt-test-a-orchestrator" ]]; then
    echo "FAIL: test-a not cleaned"
    exit 1
fi

if [[ ! -d "wt-test-b-orchestrator" ]]; then
    echo "FAIL: test-b was incorrectly removed"
    exit 1
fi

echo "✓ Safe cleanup works"

# Clean up test
./tmops_tools/cleanup_safe.sh test-b

echo ""
echo "✅ All tests passed! v6.1 is ready."