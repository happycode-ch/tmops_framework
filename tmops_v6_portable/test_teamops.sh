#!/bin/bash
# 📁 FILE: tmops_v6_portable/test_teamops.sh
# 🎯 PURPOSE: Quick verification of TeamOps core workflows and artifacts
# 🤖 AI-HINT: Focused checks for branches, .tmops structure, docs subfolders, multi-run
# 🔗 DEPENDENCIES: git, bash, core TeamOps scripts
# Quick test of TeamOps capabilities

echo "Testing TeamOps Framework..."

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
if [[ ! -d "../.tmops/test-a" ]]; then
    echo "FAIL: ../.tmops/test-a not created"
    exit 1
fi

if [[ ! -d "../.tmops/test-b" ]]; then
    echo "FAIL: ../.tmops/test-b not created"
    exit 1
fi

echo "✓ TeamOps directories created"

# Verify docs subfolders (internal, external, archive, images)
for f in test-a test-b; do
  for d in internal external archive images; do
    if [[ ! -d "../.tmops/$f/docs/$d" ]]; then
      echo "FAIL: ../.tmops/$f/docs/$d missing"
      exit 1
    fi
  done
done
echo "✓ Docs subfolders created (internal, external, archive, images)"

# Verify FEATURES.txt idempotent update (no duplicates)
git checkout main 2>/dev/null || git checkout master 2>/dev/null
./tmops_tools/init_feature_multi.sh test-b --use-current-branch || true
COUNT=$(grep -c "^test-b:" ../.tmops/FEATURES.txt 2>/dev/null || echo 0)
if [[ "$COUNT" -ne 1 ]]; then
  echo "FAIL: FEATURES.txt should contain exactly one entry for test-b"
  exit 1
fi
echo "✓ FEATURES.txt updated idempotently"

# Test 3: Run manager multi-run flow
echo "Test 3: Managing runs for test-b..."
git checkout main 2>/dev/null || git checkout master 2>/dev/null
./tmops_tools/run_manager.sh test-b new --name cycle-test --spec new --desc "automated check"
if [[ ! -d "../.tmops/test-b/runs/cycle-test/checkpoints" ]]; then
  echo "FAIL: run_manager new did not create run"
  exit 1
fi
./tmops_tools/run_manager.sh test-b clear --what both --desc "reset"
# Find latest archive
ARCH_DIR=$(ls -1dt ../.tmops/test-b/.archive/* 2>/dev/null | head -n1)
if [[ -z "$ARCH_DIR" || ! -f "$ARCH_DIR/ARCHIVE_META.txt" ]]; then
  echo "FAIL: run_manager clear did not archive artifacts"
  exit 1
fi
./tmops_tools/run_manager.sh test-b switch --name cycle-test
if [[ ! -L "../.tmops/test-b/current" ]]; then
  echo "FAIL: current symlink missing after switch"
  exit 1
fi
echo "✓ Run manager (new/clear/switch) works"

# Header markers present in core scripts
for f in \
  tmops_tools/lib/common.sh \
  tmops_tools/init_feature_multi.sh \
  tmops_tools/init_preflight.sh \
  tmops_tools/list_features.sh \
  tmops_tools/switch_feature.sh \
  tmops_tools/run_manager.sh; do
  if ! rg -n "📁 FILE:" "./$f" >/dev/null 2>&1; then
    echo "FAIL: Missing header marker in $f"
    exit 1
  fi
done
echo "✓ Header markers present in core scripts"

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
echo "✅ All tests passed! TeamOps is ready."
