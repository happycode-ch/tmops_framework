#!/bin/bash
# TeamOps Feature Cleanup Script
# Removes all artifacts from a previous feature run
# This script will:
# - Remove .tmops/<feature>/ directory
# - Remove git worktrees (wt-*)
# - Remove feature branch
# - Identify test/src files for manual removal
# - Check package.json files for feature contamination
# - Optionally remove feature-specific package.json files

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

FEATURE="$1"

if [[ -z "$FEATURE" ]]; then
    echo -e "${RED}Error: Feature name required${NC}"
    echo "Usage: $0 <feature-name>"
    echo "Example: $0 hello-api"
    exit 1
fi

echo -e "${YELLOW}═══════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}    TeamOps Feature Cleanup: $FEATURE${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════${NC}"
echo ""

# Step 1: Check if feature exists
if [[ ! -d ".tmops/$FEATURE" ]]; then
    echo -e "${YELLOW}Warning: Feature directory .tmops/$FEATURE not found${NC}"
else
    echo "Found feature directory: .tmops/$FEATURE"
fi

# Step 2: Remove git worktrees
echo ""
echo "Removing git worktrees..."
for worktree in wt-orchestrator wt-tester wt-impl wt-verify; do
    if [[ -d "$worktree" ]]; then
        echo "  Removing worktree: $worktree"
        git worktree remove "$worktree" --force 2>/dev/null || {
            echo -e "${YELLOW}  Warning: Could not remove $worktree via git, removing directory${NC}"
            rm -rf "$worktree"
        }
    else
        echo "  Worktree $worktree not found (already clean)"
    fi
done

# Step 3: Clean up git branches
echo ""
echo "Checking for feature branch..."
if git show-ref --verify --quiet refs/heads/feature/$FEATURE; then
    echo "  Found branch: feature/$FEATURE"
    
    # Check if it's the current branch
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
    if [[ "$CURRENT_BRANCH" == "feature/$FEATURE" ]]; then
        echo "  Switching away from feature branch..."
        git checkout main || git checkout master || git checkout -b temp-cleanup
    fi
    
    echo "  Deleting branch: feature/$FEATURE"
    git branch -D "feature/$FEATURE" 2>/dev/null || {
        echo -e "${YELLOW}  Warning: Could not delete branch, it may have unpushed changes${NC}"
    }
else
    echo "  Feature branch not found (already clean)"
fi

# Step 4: Remove .tmops feature directory
echo ""
if [[ -d ".tmops/$FEATURE" ]]; then
    echo "Removing .tmops/$FEATURE directory..."
    rm -rf ".tmops/$FEATURE"
    echo -e "${GREEN}  Feature directory removed${NC}"
else
    echo "Feature directory already clean"
fi

# Step 5: Clean up any test/implementation files (optional)
echo ""
echo "Checking for feature files in project..."

# Check test directory
for test_dir in test tests; do
    if [[ -d "$test_dir" ]]; then
        feature_tests=$(find "$test_dir" -name "*${FEATURE}*" -o -name "*hello*" 2>/dev/null | head -5)
        if [[ -n "$feature_tests" ]]; then
            echo -e "${YELLOW}Found possible feature test files:${NC}"
            echo "$feature_tests"
            echo -e "${YELLOW}Remove these manually if they belong to the old feature${NC}"
        fi
    fi
done

# Check src directory
if [[ -d "src" ]]; then
    feature_src=$(find "src" -name "*${FEATURE}*" -o -name "*hello*" 2>/dev/null | head -5)
    if [[ -n "$feature_src" ]]; then
        echo -e "${YELLOW}Found possible feature source files:${NC}"
        echo "$feature_src"
        echo -e "${YELLOW}Remove these manually if they belong to the old feature${NC}"
    fi
fi

# Step 5b: Check for feature-specific package.json files
echo ""
echo "Checking for feature-specific package.json files..."

# Check root package.json
if [[ -f "package.json" ]]; then
    # Look for feature name or common test patterns
    if grep -qi "$FEATURE\|hello" package.json 2>/dev/null; then
        echo -e "${YELLOW}Found feature references in package.json${NC}"
        echo "  Contains: $(grep -o '"name": "[^"]*"' package.json | head -1)"
        
        # Check if package.json existed before this feature in git history
        if git ls-tree HEAD~10 -- package.json >/dev/null 2>&1; then
            echo -e "${YELLOW}  Warning: package.json may have existed before this feature${NC}"
            echo -e "${YELLOW}  Consider checking: git log --oneline -- package.json${NC}"
        else
            echo -e "${YELLOW}  This package.json appears to be feature-specific${NC}"
        fi
        
        read -p "  Remove package.json and package-lock.json? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -f package.json package-lock.json
            echo -e "${GREEN}  Removed root package files${NC}"
        else
            echo "  Keeping package files"
        fi
    else
        echo "  Root package.json appears clean"
    fi
fi

# Check test/package.json
if [[ -f "test/package.json" ]]; then
    if grep -qi "$FEATURE\|hello" test/package.json 2>/dev/null; then
        echo -e "${YELLOW}Found feature references in test/package.json${NC}"
        echo "  Contains: $(grep -o '"name": "[^"]*"' test/package.json | head -1)"
        read -p "  Remove test/package.json and test/package-lock.json? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -f test/package.json test/package-lock.json
            echo -e "${GREEN}  Removed test package files${NC}"
        else
            echo "  Keeping test package files"
        fi
    else
        echo "  test/package.json appears clean"
    fi
fi

# Step 6: Verify cleanup
echo ""
echo "Verification:"
echo -n "  Worktrees: "
remaining_wt=$(ls -d wt-* 2>/dev/null | wc -l)
if [[ $remaining_wt -eq 0 ]]; then
    echo -e "${GREEN}✓ Clean${NC}"
else
    echo -e "${YELLOW}⚠ $remaining_wt worktree(s) remain${NC}"
fi

echo -n "  Feature directory: "
if [[ ! -d ".tmops/$FEATURE" ]]; then
    echo -e "${GREEN}✓ Removed${NC}"
else
    echo -e "${RED}✗ Still exists${NC}"
fi

echo -n "  Git branch: "
if ! git show-ref --verify --quiet refs/heads/feature/$FEATURE; then
    echo -e "${GREEN}✓ Removed${NC}"
else
    echo -e "${YELLOW}⚠ Still exists${NC}"
fi

echo -n "  Package files: "
package_clean=true
if [[ -f "package.json" ]] && grep -qi "$FEATURE\|hello" package.json 2>/dev/null; then
    package_clean=false
fi
if [[ -f "test/package.json" ]] && grep -qi "$FEATURE\|hello" test/package.json 2>/dev/null; then
    package_clean=false
fi
if [[ "$package_clean" == true ]]; then
    echo -e "${GREEN}✓ Clean${NC}"
else
    echo -e "${YELLOW}⚠ Feature references remain${NC}"
fi

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}    Cleanup Complete for: $FEATURE${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo ""
echo "You can now run a fresh test with:"
echo "  ./tmops_tools/init_feature.sh $FEATURE initial"
echo "  (or for v6: ./tmops_tools/init_feature_v6.sh $FEATURE initial)"
echo ""