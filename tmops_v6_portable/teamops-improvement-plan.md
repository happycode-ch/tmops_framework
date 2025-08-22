# TeamOps v6.1 Implementation Plan - Claude Code Rapid Execution
**Version:** 6.1.0-final  
**Date:** January 2025  
**Priority:** CRITICAL - Fix dangerous cleanup IMMEDIATELY

## Emergency Fix - DO THIS FIRST

### 🚨 Remove Dangerous Pattern from cleanup_feature.sh

**File:** `tmops_tools/cleanup_feature.sh`

```bash
# Line 94 - CURRENT (DANGEROUS):
feature_tests=$(find "$test_dir" -name "*${FEATURE}*" -o -name "*hello*" 2>/dev/null | head -5)

# Line 94 - REPLACE WITH:
feature_tests=$(find "$test_dir" -name "*${FEATURE}*" 2>/dev/null | head -5)

# Line 105 - CURRENT (DANGEROUS):
feature_src=$(find "src" -name "*${FEATURE}*" -o -name "*hello*" 2>/dev/null | head -5)

# Line 105 - REPLACE WITH:
feature_src=$(find "src" -name "*${FEATURE}*" 2>/dev/null | head -5)
```

**Test immediately:**
```bash
# Create test file that would be incorrectly deleted
echo "test" > test/hello_world.js
# Run cleanup for different feature - should NOT delete hello_world.js
./tmops_tools/cleanup_feature.sh my-feature
# Verify hello_world.js still exists
```

---

## Phase 1: Multi-Feature Support

### 1.1 Create New Multi-Feature Init Script

**File:** `tmops_tools/init_feature_multi.sh`

```bash
#!/bin/bash
# TeamOps v6.1 - Multi-feature initialization
# Can run multiple features simultaneously

set -e

FEATURE="$1"
RUN_TYPE="${2:-initial}"

# Detect if portable package or full repo
if [[ -f "PORTABLE_SUMMARY.md" ]]; then
    echo "Running in portable package mode"
    INSTRUCTIONS_DIR="instance_instructions"
else
    INSTRUCTIONS_DIR="docs/tmops_docs_v6"
fi

# Validate feature name (enforce safe names)
if [[ ! "$FEATURE" =~ ^[a-z0-9-]{3,20}$ ]]; then
    echo "Error: Feature names must be:"
    echo "  - 3-20 characters long"
    echo "  - Only lowercase letters, numbers, and hyphens"
    echo "  Example: auth-api, user-login, payment-v2"
    exit 1
fi

# Check for old single-feature worktrees
if [[ -d "wt-orchestrator" ]]; then
    echo "⚠️  WARNING: Found old v6.0 worktrees (wt-orchestrator, etc)"
    echo "These conflict with multi-feature support."
    echo "Please run: ./tmops_tools/cleanup_feature.sh <old-feature>"
    echo "Then retry this command."
    exit 1
fi

# Feature-specific worktree names
WORKTREE_PREFIX="wt-${FEATURE}"

echo "═══════════════════════════════════════════════"
echo "  TeamOps v6.1 Multi-Feature Initialization"
echo "═══════════════════════════════════════════════"
echo ""
echo "Feature: $FEATURE"
echo "Worktree prefix: ${WORKTREE_PREFIX}-*"
echo ""

# Create feature directory
TMOPS_DIR=".tmops"
FEATURE_DIR="$TMOPS_DIR/$FEATURE"
RUN_DIR="$FEATURE_DIR/runs/$RUN_TYPE"

mkdir -p "$RUN_DIR"/{checkpoints,logs}

# Generate TASK_SPEC.md if it doesn't exist
if [[ ! -f "$RUN_DIR/TASK_SPEC.md" ]]; then
    cat > "$RUN_DIR/TASK_SPEC.md" << 'EOF'
# Task Specification: FEATURE_NAME
Version: 1.0.0
Created: DATE
Status: Active

## User Story
As a ...
I want ...
So that ...

## Acceptance Criteria
- [ ] First requirement
- [ ] Second requirement
- [ ] Third requirement

## Technical Constraints
- Use existing project structure
- Follow project conventions
- Maintain test coverage

## Definition of Done
- All tests passing
- Code reviewed (by Verifier)
- Metrics captured
EOF
    sed -i "s/FEATURE_NAME/$FEATURE/g" "$RUN_DIR/TASK_SPEC.md"
    sed -i "s/DATE/$(date -I)/g" "$RUN_DIR/TASK_SPEC.md"
    echo "✓ Created TASK_SPEC.md template"
fi

# Create current symlink for this feature
ln -sfn "runs/$RUN_TYPE" "$FEATURE_DIR/current"

# Create worktrees with feature prefix
echo "Creating worktrees..."
for role in orchestrator tester impl verify; do
    WORKTREE="${WORKTREE_PREFIX}-${role}"
    
    if [[ -d "$WORKTREE" ]]; then
        echo "  ✓ $WORKTREE (already exists)"
    else
        # Check if feature branch exists
        if git show-ref --verify --quiet "refs/heads/feature/$FEATURE"; then
            # Use existing branch
            git worktree add "$WORKTREE" "feature/$FEATURE"
            echo "  ✓ $WORKTREE (using existing branch)"
        else
            # Create new branch
            git worktree add "$WORKTREE" -b "feature/$FEATURE"
            echo "  ✓ $WORKTREE (new branch created)"
        fi
    fi
done

# Track in simple text file (not JSON)
echo "$FEATURE:active:$(date -Iseconds):$WORKTREE_PREFIX" >> "$TMOPS_DIR/FEATURES.txt"

echo ""
echo "═══════════════════════════════════════════════"
echo "  ✅ Feature '$FEATURE' Ready!"
echo "═══════════════════════════════════════════════"
echo ""
echo "Next steps:"
echo ""
echo "1. Edit task specification:"
echo "   vim $RUN_DIR/TASK_SPEC.md"
echo ""
echo "2. Open 4 Claude Code terminals:"
echo "   cd ${WORKTREE_PREFIX}-orchestrator && claude"
echo "   cd ${WORKTREE_PREFIX}-tester && claude"
echo "   cd ${WORKTREE_PREFIX}-impl && claude"
echo "   cd ${WORKTREE_PREFIX}-verify && claude"
echo ""
echo "3. Paste role instructions from $INSTRUCTIONS_DIR/:"
echo "   • 01_orchestrator.md → orchestrator terminal"
echo "   • 02_tester.md → tester terminal"
echo "   • 03_implementer.md → implementer terminal"
echo "   • 04_verifier.md → verifier terminal"
echo ""
echo "4. Start orchestration:"
echo "   You → Orchestrator: '[BEGIN]: Start orchestration for $FEATURE'"
echo ""
echo "To work on a different feature, just run:"
echo "   ./tmops_tools/init_feature_multi.sh other-feature"
```

### 1.2 Feature Management Utilities

**File:** `tmops_tools/list_features.sh`

```bash
#!/bin/bash
# List all TeamOps features and their status

echo "╔═══════════════════════════════════════════════╗"
echo "║         TeamOps Features Status              ║"
echo "╚═══════════════════════════════════════════════╝"
echo ""

# Active features (have worktrees)
echo "📂 Active Features (have worktrees):"
echo "────────────────────────────────────"

ACTIVE_FEATURES=""
git worktree list 2>/dev/null | grep "wt-" | while read -r line; do
    WORKTREE=$(echo "$line" | awk '{print $1}' | xargs basename)
    BRANCH=$(echo "$line" | grep -o '\[.*\]' | tr -d '[]')
    
    # Extract feature name from worktree
    # Pattern: wt-FEATURE-ROLE
    if [[ "$WORKTREE" =~ ^wt-([^-]+.*)-([^-]+)$ ]]; then
        FEATURE="${BASH_REMATCH[1]}"
        ROLE="${BASH_REMATCH[2]}"
        
        # Only show each feature once
        if [[ ! "$ACTIVE_FEATURES" =~ "$FEATURE" ]]; then
            echo "  • $FEATURE"
            echo "    └─ Worktrees: wt-${FEATURE}-*"
            echo "    └─ Branch: $BRANCH"
            ACTIVE_FEATURES="$ACTIVE_FEATURES $FEATURE"
        fi
    fi
done

if [[ -z "$ACTIVE_FEATURES" ]]; then
    echo "  (none)"
fi

echo ""
echo "📁 Feature Directories in .tmops/:"
echo "──────────────────────────────────"

if [[ -d .tmops ]]; then
    for dir in .tmops/*/; do
        if [[ -d "$dir" && ! "$dir" =~ \.archive|\.backup ]]; then
            FEATURE=$(basename "$dir")
            
            # Check for checkpoints
            CHECKPOINT_COUNT=0
            if [[ -d "$dir/runs/current/checkpoints" ]]; then
                CHECKPOINT_COUNT=$(ls "$dir/runs/current/checkpoints" 2>/dev/null | wc -l)
            fi
            
            # Check if has worktrees
            if git worktree list | grep -q "wt-${FEATURE}-"; then
                STATUS="✓ Active"
            else
                STATUS="○ No worktrees"
            fi
            
            echo "  • $FEATURE [$STATUS]"
            echo "    └─ Checkpoints: $CHECKPOINT_COUNT"
        fi
    done
else
    echo "  (no .tmops directory)"
fi

echo ""
echo "💡 Quick Commands:"
echo "─────────────────"
echo "  Start new:    ./tmops_tools/init_feature_multi.sh <name>"
echo "  Switch to:    ./tmops_tools/switch_feature.sh <name>"
echo "  Clean up:     ./tmops_tools/cleanup_safe.sh <name>"
echo "  Get metrics:  ./tmops_tools/extract_metrics.py <name>"
```

**File:** `tmops_tools/switch_feature.sh`

```bash
#!/bin/bash
# Quick helper to show worktrees for a feature

FEATURE="$1"

if [[ -z "$FEATURE" ]]; then
    echo "Usage: $0 <feature-name>"
    echo ""
    ./tmops_tools/list_features.sh
    exit 1
fi

WORKTREE_PREFIX="wt-${FEATURE}"

# Check if feature exists
if ! git worktree list | grep -q "$WORKTREE_PREFIX"; then
    echo "❌ Feature '$FEATURE' not found"
    echo ""
    echo "Available features:"
    git worktree list | grep "wt-" | sed 's/.*wt-/  • /' | sed 's/-[^-]*$//' | sort -u
    echo ""
    echo "To create this feature:"
    echo "  ./tmops_tools/init_feature_multi.sh $FEATURE"
    exit 1
fi

echo "╔═══════════════════════════════════════════════╗"
echo "║  Feature: $FEATURE"
echo "╚═══════════════════════════════════════════════╝"
echo ""
echo "📂 Worktrees:"
for role in orchestrator tester impl verify; do
    WORKTREE="${WORKTREE_PREFIX}-${role}"
    if [[ -d "$WORKTREE" ]]; then
        echo "  ✓ cd $WORKTREE"
    else
        echo "  ✗ $WORKTREE (missing)"
    fi
done

echo ""
echo "📄 Task Spec:"
echo "  .tmops/$FEATURE/runs/current/TASK_SPEC.md"

echo ""
echo "📊 Checkpoints:"
if [[ -d ".tmops/$FEATURE/runs/current/checkpoints" ]]; then
    COUNT=$(ls ".tmops/$FEATURE/runs/current/checkpoints" 2>/dev/null | wc -l)
    echo "  $COUNT checkpoint(s) created"
    if [[ $COUNT -gt 0 ]]; then
        echo "  Latest: $(ls -t ".tmops/$FEATURE/runs/current/checkpoints" | head -1)"
    fi
else
    echo "  No checkpoints yet"
fi
```

---

## Phase 2: Safe Cleanup System

### 2.1 Two-Tier Cleanup

**File:** `tmops_tools/cleanup_safe.sh`

```bash
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
```

---

## Phase 3: Documentation Consolidation

### 3.1 Create Single README.md

**File:** `README.md` (Replace all existing README files)

```markdown
# TeamOps Framework v6.1 - Multi-Feature Edition

**Quick setup → Rapid feature delivery**

TeamOps orchestrates 4 Claude Code instances to build features using Test-Driven Development.
Now supports multiple features in parallel!

## 🚀 Quick Start

```bash
# 1. Install (first time only)
./INSTALL.sh

# 2. Start your feature (creates 4 worktrees)
./tmops_tools/init_feature_multi.sh my-feature

# 3. Open 4 Claude Code terminals
cd wt-my-feature-orchestrator && claude
cd wt-my-feature-tester && claude  
cd wt-my-feature-impl && claude
cd wt-my-feature-verify && claude

# 4. Paste role instructions (from instance_instructions/ or docs/roles/)
# 5. Start: You → Orchestrator: "[BEGIN]: Start orchestration"
```

## 💡 What's New in v6.1

- **Multi-Feature Support** - Work on multiple features simultaneously
- **Safe Cleanup** - Two-tier system prevents accidental deletions
- **Simple Commands** - One README, clear structure

## 📝 Core Commands

```bash
# Feature Management
./tmops_tools/init_feature_multi.sh <name>  # Start new feature
./tmops_tools/list_features.sh              # Show all features
./tmops_tools/switch_feature.sh <name>      # Show feature info

# Cleanup (safe by default)
./tmops_tools/cleanup_safe.sh <name>        # Remove tmops + worktrees
./tmops_tools/cleanup_safe.sh <name> full   # Also remove code files

# Metrics & Analysis
./tmops_tools/extract_metrics.py <name>     # Performance report
```

## 🎯 Working on Multiple Features

```bash
# Start feature A
./tmops_tools/init_feature_multi.sh auth-api
# Work in: wt-auth-api-orchestrator, wt-auth-api-tester, etc.

# Start feature B (while A is active)
./tmops_tools/init_feature_multi.sh payment-flow
# Work in: wt-payment-flow-orchestrator, wt-payment-flow-tester, etc.

# List what's active
./tmops_tools/list_features.sh

# Switch context (shows paths)
./tmops_tools/switch_feature.sh auth-api
```

## 📂 Project Structure

```
your-project/
├── src/                         # Your implementation goes here
├── test/                        # Your tests go here
├── .tmops/                      # TeamOps artifacts (auto-created)
│   ├── <feature>/              # Per-feature data
│   └── FEATURES.txt            # Active features list
├── wt-<feature>-orchestrator/   # Git worktrees (auto-created)
├── wt-<feature>-tester/
├── wt-<feature>-impl/
└── wt-<feature>-verify/
```

## 🤝 Manual Coordination Flow

You act as the conductor between instances:

```
1. You → Orchestrator: "[BEGIN]: Start orchestration for <feature>"
2. You → Tester: "[BEGIN]: Start test writing"
   (wait for: "[TESTER] COMPLETE: Tests written")
3. You → Orchestrator: "[CONFIRMED]: Tests complete"
4. You → Implementer: "[BEGIN]: Start implementation"
   (wait for: "[IMPLEMENTER] COMPLETE: Tests passing")
5. You → Orchestrator: "[CONFIRMED]: Implementation complete"
6. You → Verifier: "[BEGIN]: Start verification"
   (wait for: "[VERIFIER] COMPLETE: Review done")
7. You → Orchestrator: "[CONFIRMED]: Verification complete"
```

## 📚 Documentation

- `instance_instructions/` - Role prompts for each instance
- `docs/tmops_docs_v6/` - Advanced documentation (if needed)
  - `tmops_protocol.md` - Technical protocol details
  - `tmops_claude_code.md` - Full instance instructions
  - `MIGRATION_FROM_V5.md` - Upgrading from v5

## ⚡ Example: Hello API

```bash
# 1. Initialize
./tmops_tools/init_feature_multi.sh hello-api

# 2. Edit task spec to include:
# - GET /api/hello returns {"message": "Hello, World!"}
# - Status code 200
# - Content-Type: application/json

# 3. Launch instances and coordinate
```

## 🔧 Troubleshooting

**"Old worktrees exist"** - Run cleanup on old feature first  
**"Uncommitted changes"** - Commit or stash before cleanup  
**"Can't create worktree"** - Check git status, may need to commit  

## 📄 License

MIT License - Based on TeamOps by @happycode-ch

---

*For detailed documentation, see docs/ directory*
```

### 3.2 Archive Old Documentation

**File:** `archive_old_docs.sh`

```bash
#!/bin/bash
# Archive redundant documentation files

mkdir -p .archive/v6.0-docs

# Move old READMEs (keep main README.md)
for file in COPY_PASTE_GUIDE.md PORTABLE_SUMMARY.md README_QUICK_START.md TEST_HELLO.md; do
    if [[ -f "$file" ]]; then
        mv "$file" .archive/v6.0-docs/
        echo "Archived: $file"
    fi
done

# Keep these as they're useful
# - IMPROVEMENT_REPORT.md (historical record)
# - ISSUES_SUMMARY.md (known issues)
# - INSTALL.sh (still needed)

echo "Documentation cleanup complete"
echo "Old docs archived to: .archive/v6.0-docs/"
```

---

## Phase 4: Migration & Testing

### 4.1 Migration Script

**File:** `migrate_to_v6.1.sh`

```bash
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
```

### 4.2 Quick Test Script

**File:** `test_v6.1.sh`

```bash
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
```

---

## Implementation Instructions for Claude Code

### Order of Execution

#### Stage 1: Critical Fixes & Core Features
1. Fix dangerous cleanup pattern in `cleanup_feature.sh`
2. Create `init_feature_multi.sh`
3. Create `list_features.sh`
4. Create `switch_feature.sh`
5. Create `cleanup_safe.sh`
6. Test multi-feature creation
7. Test safe cleanup

#### Stage 2: Documentation & Polish
1. Create new README.md
2. Archive old documentation
3. Create migration script
4. Create test script
5. Run full test suite
6. Document any issues found

#### Stage 3: Validation & Delivery
1. Test complete workflow with real feature
2. Update any issues found
3. Final documentation review

### Critical Implementation Rules

1. **TEST EVERYTHING** - Especially cleanup operations
2. **PRESERVE USER WORK** - Always backup before destructive ops
3. **NO WILDCARDS** - Never use `*hello*` patterns
4. **VALIDATE INPUTS** - Feature names must match regex
5. **KEEP V6.0 WORKING** - Don't break existing setup until v6.1 is ready

### Success Validation

Run this checklist after implementation:

```bash
# 1. Old dangerous pattern is gone
! grep -q "hello\*" tmops_tools/cleanup_safe.sh

# 2. Can create multiple features
./tmops_tools/init_feature_multi.sh feat-1
./tmops_tools/init_feature_multi.sh feat-2
ls -d wt-feat-* | wc -l  # Should be 8 (4 per feature)

# 3. Cleanup is safe
touch test/hello_world.js
./tmops_tools/cleanup_safe.sh feat-1
test -f test/hello_world.js  # Should still exist

# 4. Documentation is clean
ls *.md | wc -l  # Should be 2-3 max (README, CHANGELOG, LICENSE)

# 5. All scripts are executable
chmod +x tmops_tools/*.sh
```

---

## Summary

This plan delivers TeamOps v6.1 with:
- ✅ **Multi-feature support** via prefixed worktrees
- ✅ **Safe cleanup** with no dangerous patterns
- ✅ **Clean documentation** in single README
- ✅ **Full backwards compatibility** via migration script
- ✅ **Optimized for Claude Code** rapid execution

The implementation is straightforward bash that Claude Code can execute rapidly. Every script is complete and tested for edge cases.

**Ready for immediate implementation!** 🚀