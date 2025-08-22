#!/bin/bash
# SAFE cleanup - two-tier system with extensive safety checks
# Replaces dangerous cleanup_feature.sh

set -e

FEATURE="$1"
MODE="${2:-safe}"  # safe or full

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

if [[ -z "$FEATURE" ]]; then
    echo "Usage: $0 <feature-name> [safe|full]"
    echo ""
    echo "Modes:"
    echo "  safe - Only removes .tmops and worktrees (default)"
    echo "  full - Also removes test/src files (with confirmation)"
    echo ""
    echo "Available features to clean:"
    if [[ -f .tmops/FEATURES.txt ]]; then
        cut -d: -f1 .tmops/FEATURES.txt | sort -u | sed 's/^/  • /'
    fi
    exit 1
fi

echo -e "${YELLOW}═══════════════════════════════════════════════${NC}"
echo -e "${YELLOW}  TeamOps v6.1 Safe Cleanup${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════${NC}"
echo ""
echo "Feature: $FEATURE"
echo "Mode: $MODE"
echo ""

# Safety Check 1: Uncommitted changes
echo "🔍 Checking for uncommitted changes..."
if ! git diff --quiet || ! git diff --cached --quiet; then
    echo -e "${RED}⚠️  ERROR: You have uncommitted changes${NC}"
    echo ""
    git status --short
    echo ""
    echo "Please commit or stash changes first:"
    echo "  git add . && git commit -m 'Save work'"
    echo "  OR"
    echo "  git stash push -m 'Before cleanup'"
    exit 1
fi
echo -e "${GREEN}  ✓ Working directory clean${NC}"

# Safety Check 2: Create backup
BACKUP_DIR=".tmops/.backups/$(date +%Y%m%d-%H%M%S)-$FEATURE"
echo ""
echo "💾 Creating backup..."
mkdir -p "$BACKUP_DIR"

if [[ -d ".tmops/$FEATURE" ]]; then
    cp -r ".tmops/$FEATURE" "$BACKUP_DIR/"
    echo -e "${GREEN}  ✓ Backed up .tmops/$FEATURE${NC}"
fi

# Backup any existing test/src files that match
if [[ "$MODE" == "full" ]]; then
    for dir in test tests src; do
        if [[ -d "$dir" ]]; then
            matches=$(find "$dir" -type f -name "*${FEATURE}*" 2>/dev/null || true)
            if [[ -n "$matches" ]]; then
                mkdir -p "$BACKUP_DIR/$dir"
                echo "$matches" | while read -r file; do
                    cp "$file" "$BACKUP_DIR/$file" 2>/dev/null || true
                done
                echo -e "${GREEN}  ✓ Backed up $dir files${NC}"
            fi
        fi
    done
fi

echo "  Backup location: $BACKUP_DIR"

# Step 1: Remove worktrees
echo ""
echo "🔧 Removing worktrees..."
WORKTREE_PREFIX="wt-${FEATURE}"
removed_count=0

for role in orchestrator tester impl verify; do
    WORKTREE="${WORKTREE_PREFIX}-${role}"
    if [[ -d "$WORKTREE" ]]; then
        echo "  Removing: $WORKTREE"
        git worktree remove "$WORKTREE" --force 2>/dev/null || rm -rf "$WORKTREE"
        ((removed_count++))
    fi
done

if [[ $removed_count -eq 0 ]]; then
    echo "  No worktrees found for $FEATURE"
fi

# Step 2: Handle branches
echo ""
echo "🌿 Checking branches..."
BRANCH="feature/$FEATURE"

if git show-ref --verify --quiet "refs/heads/$BRANCH"; then
    # Check for unpushed commits
    UNPUSHED=0
    if git remote | grep -q origin; then
        UNPUSHED=$(git rev-list --count "origin/$BRANCH..$BRANCH" 2>/dev/null || echo "0")
    fi
    
    if [[ "$UNPUSHED" -gt 0 ]]; then
        echo -e "${YELLOW}  ⚠️  Branch $BRANCH has $UNPUSHED unpushed commits${NC}"
        read -p "  Delete anyway? (yes/no): " confirm
        if [[ "$confirm" == "yes" ]]; then
            git branch -D "$BRANCH"
            echo -e "${GREEN}  ✓ Deleted branch${NC}"
        else
            echo "  ✓ Kept branch (push with: git push origin $BRANCH)"
        fi
    else
        git branch -D "$BRANCH" 2>/dev/null
        echo -e "${GREEN}  ✓ Deleted branch $BRANCH${NC}"
    fi
else
    echo "  No branch found"
fi

# Step 3: Handle test/src files (only in full mode)
if [[ "$MODE" == "full" ]]; then
    echo ""
    echo -e "${YELLOW}═══════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}  ⚠️  FULL CLEANUP MODE - CODE DELETION${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════${NC}"
    echo ""
    
    # Find files (NO WILDCARDS, NO 'hello' pattern!)
    echo "Files that will be deleted:"
    echo ""
    
    found_files=false
    for dir in test tests src; do
        if [[ -d "$dir" ]]; then
            matches=$(find "$dir" -type f -name "*${FEATURE}*" 2>/dev/null | head -20 || true)
            if [[ -n "$matches" ]]; then
                found_files=true
                echo "  $dir/:"
                echo "$matches" | sed 's/^/    - /'
            fi
        fi
    done
    
    if [[ "$found_files" == true ]]; then
        echo ""
        echo -e "${RED}⚠️  This action cannot be undone (except from backup)${NC}"
        echo "Type 'DELETE' (in capitals) to confirm deletion:"
        read -r confirm
        
        if [[ "$confirm" == "DELETE" ]]; then
            for dir in test tests src; do
                if [[ -d "$dir" ]]; then
                    find "$dir" -type f -name "*${FEATURE}*" -delete 2>/dev/null || true
                fi
            done
            echo -e "${GREEN}  ✓ Files deleted${NC}"
        else
            echo "  ✓ Files preserved"
        fi
    else
        echo "  No matching test/src files found"
    fi
fi

# Step 4: Archive TeamOps directory
echo ""
echo "📦 Archiving TeamOps artifacts..."
if [[ -d ".tmops/$FEATURE" ]]; then
    ARCHIVE_DIR=".tmops/.archive/$(date +%Y%m%d)-$FEATURE"
    mkdir -p "$(dirname "$ARCHIVE_DIR")"
    mv ".tmops/$FEATURE" "$ARCHIVE_DIR"
    echo -e "${GREEN}  ✓ Archived to: $ARCHIVE_DIR${NC}"
else
    echo "  No .tmops/$FEATURE directory found"
fi

# Step 5: Update feature tracking
if [[ -f ".tmops/FEATURES.txt" ]]; then
    grep -v "^$FEATURE:" ".tmops/FEATURES.txt" > ".tmops/FEATURES.txt.tmp" 2>/dev/null || true
    if [[ -f ".tmops/FEATURES.txt.tmp" ]]; then
        mv ".tmops/FEATURES.txt.tmp" ".tmops/FEATURES.txt"
    fi
fi

# Final summary
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════${NC}"
echo -e "${GREEN}  ✅ Cleanup Complete${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════${NC}"
echo ""
echo "Feature: $FEATURE"
echo "Backup: $BACKUP_DIR"
echo ""
echo "To restore from backup:"
echo "  cp -r $BACKUP_DIR/.tmops/$FEATURE .tmops/"
echo ""
echo "To start fresh:"
echo "  ./tmops_tools/init_feature_multi.sh $FEATURE"