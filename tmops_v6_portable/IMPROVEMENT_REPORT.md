# TeamOps v6 Improvement Report
**Date:** January 2025  
**Version:** 6.0.0  
**Status:** Critical Issues Identified

## Executive Summary

TeamOps v6 has three critical limitations that prevent production use:
1. **Single-feature limitation** - Cannot work on multiple features simultaneously
2. **Dangerous cleanup operations** - Risk of deleting unrelated files
3. **Confusing package structure** - Poor developer experience

This report provides detailed analysis and concrete recommendations for TeamOps v6.1.

---

## Section 1: Multi-Feature Support Analysis

### Current Limitations

#### Problem 1: Hardcoded Worktree Names
**Location:** `init_feature_v6.sh` lines 125-134
```bash
for worktree in wt-orchestrator wt-tester wt-impl wt-verify; do
    if [[ -d "$worktree" ]]; then
        git worktree remove "$worktree" --force 2>/dev/null || rm -rf "$worktree"
    fi
done
```
**Impact:** Forces removal of existing worktrees, making multi-feature work impossible.

#### Problem 2: Single Current Symlink
**Location:** `.tmops/current` points to only one feature
```bash
ln -sfn "$FEATURE/runs/$RUN_TYPE" "$TMOPS_DIR/current"
```
**Impact:** No way to track or switch between multiple active features.

#### Problem 3: No Feature State Management
**Current State:** No mechanism to pause, resume, or archive features.

### Proposed Solution: Multi-Feature Architecture

#### New Directory Structure
```
.tmops/
├── active/
│   ├── feature-api/
│   │   ├── state.json
│   │   ├── worktrees.json
│   │   └── runs/
│   ├── feature-auth/
│   │   └── ...
│   └── current -> feature-api  # Currently selected
├── archived/
│   ├── 2025-01-15_feature-login/
│   └── 2025-01-20_feature-payment/
└── registry.json  # Feature registry with metadata
```

#### Worktree Naming Strategy
```bash
# Pattern: wt-{feature}-{role}
wt-api-orchestrator
wt-api-tester
wt-api-impl
wt-api-verify

wt-auth-orchestrator
wt-auth-tester
wt-auth-impl
wt-auth-verify
```

#### New Commands
```bash
# Initialize new feature
./tmops_tools/init_feature_v6.sh api initial

# Switch between features
./tmops_tools/switch_feature.sh auth

# List all features
./tmops_tools/list_features.sh

# Archive completed feature
./tmops_tools/archive_feature.sh api
```

#### Implementation Code Sample
```bash
# init_feature_v6.sh modifications
FEATURE_SAFE=$(echo "$FEATURE" | tr '/' '-' | tr ' ' '-')
WORKTREE_PREFIX="wt-${FEATURE_SAFE}"

for role in orchestrator tester impl verify; do
    WORKTREE_NAME="${WORKTREE_PREFIX}-${role}"
    if [[ ! -d "$WORKTREE_NAME" ]]; then
        git worktree add "$WORKTREE_NAME" -b "feature/${FEATURE}/${role}"
    fi
done

# Update registry
REGISTRY_FILE="$TMOPS_DIR/registry.json"
jq --arg feature "$FEATURE" \
   --arg status "active" \
   --arg created "$(date -Iseconds)" \
   '.features[$feature] = {status: $status, created: $created}' \
   "$REGISTRY_FILE" > "$REGISTRY_FILE.tmp" && mv "$REGISTRY_FILE.tmp" "$REGISTRY_FILE"
```

---

## Section 2: Cleanup Script Safety Analysis

### Current Dangers (HIGH RISK)

#### Danger 1: Hardcoded Pattern Matching
**Location:** `cleanup_feature.sh` lines 94, 105
```bash
feature_tests=$(find "$test_dir" -name "*${FEATURE}*" -o -name "*hello*" 2>/dev/null | head -5)
feature_src=$(find "src" -name "*${FEATURE}*" -o -name "*hello*" 2>/dev/null | head -5)
```
**Risk:** Will match ANY file containing "hello" - could delete unrelated files like `hello_world.js`, `shell_output.txt`, etc.

#### Danger 2: Forced Branch Deletion
**Location:** `cleanup_feature.sh` line 70
```bash
git branch -D "feature/$FEATURE" 2>/dev/null
```
**Risk:** Deletes branch with unpushed commits without warning.

#### Danger 3: Interactive Prompts During Automation
**Location:** Multiple locations asking for `y/n` input
**Risk:** Scripts calling cleanup could hang or make wrong choices.

### Proposed Two-Tier Cleanup System

#### Tier 1: Safe Test Cleanup (`cleanup_test_feature.sh`)
```bash
#!/bin/bash
# Safe cleanup for testing - ONLY removes TeamOps artifacts

set -e

FEATURE="$1"
DRY_RUN="${2:-false}"

# Safety checks
if [[ -z "$FEATURE" ]]; then
    echo "Error: Feature name required"
    exit 1
fi

# Check for uncommitted changes
if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "Error: Uncommitted changes detected. Commit or stash first."
    exit 1
fi

# Create backup
BACKUP_DIR=".tmops/backups/$(date +%Y%m%d_%H%M%S)_${FEATURE}"
mkdir -p "$BACKUP_DIR"
cp -r ".tmops/active/$FEATURE" "$BACKUP_DIR/" 2>/dev/null || true

# Safe cleanup operations
echo "=== SAFE TEST CLEANUP ==="
echo "Feature: $FEATURE"
echo "Backup: $BACKUP_DIR"
echo ""

# 1. Remove worktrees (feature-specific only)
FEATURE_SAFE=$(echo "$FEATURE" | tr '/' '-')
for role in orchestrator tester impl verify; do
    WORKTREE="wt-${FEATURE_SAFE}-${role}"
    if [[ -d "$WORKTREE" ]]; then
        echo "Removing worktree: $WORKTREE"
        [[ "$DRY_RUN" == "false" ]] && git worktree remove "$WORKTREE" --force
    fi
done

# 2. Archive feature directory
if [[ -d ".tmops/active/$FEATURE" ]]; then
    ARCHIVE_DIR=".tmops/archived/$(date +%Y-%m-%d)_${FEATURE}"
    echo "Archiving to: $ARCHIVE_DIR"
    [[ "$DRY_RUN" == "false" ]] && mv ".tmops/active/$FEATURE" "$ARCHIVE_DIR"
fi

# 3. List (but don't delete) potential test/src files
echo ""
echo "=== Manual Cleanup Required ==="
echo "Review and delete these files manually if needed:"
find test tests src -type f -newer ".tmops/active/$FEATURE/created.timestamp" 2>/dev/null | grep -E "^(test|tests|src)/${FEATURE}" || true

echo ""
echo "✅ Safe cleanup complete. Backup available at: $BACKUP_DIR"
```

#### Tier 2: Production Cleanup (`cleanup_production_feature.sh`)
```bash
#!/bin/bash
# Full cleanup with extensive warnings and confirmations

# ... includes all safety checks from Tier 1 plus:

# Explicit confirmation with details
echo "⚠️  WARNING: PRODUCTION CLEANUP ⚠️"
echo "This will permanently delete:"
echo "  - Git branch: feature/$FEATURE"
echo "  - Test files matching: $FEATURE"
echo "  - Source files matching: $FEATURE"
echo "  - All TeamOps artifacts"
echo ""
echo "Type the feature name to confirm: "
read -r CONFIRM
if [[ "$CONFIRM" != "$FEATURE" ]]; then
    echo "Confirmation failed. Exiting."
    exit 1
fi

# Create comprehensive backup
tar -czf ".tmops/backups/${FEATURE}_full_backup.tar.gz" \
    ".tmops/active/$FEATURE" \
    $(git ls-files | grep "$FEATURE") \
    2>/dev/null

# ... proceed with full cleanup
```

### Additional Safety Mechanisms

1. **Pre-cleanup Checklist**
```bash
check_safety() {
    local FEATURE=$1
    local ERRORS=0
    
    # Check for uncommitted changes
    if ! git diff --quiet; then
        echo "❌ Uncommitted changes detected"
        ((ERRORS++))
    fi
    
    # Check for unpushed commits
    if git rev-list --count origin/feature/${FEATURE}..feature/${FEATURE} > 0; then
        echo "❌ Unpushed commits on feature branch"
        ((ERRORS++))
    fi
    
    # Check for active worktrees
    if git worktree list | grep -q "${FEATURE}"; then
        echo "⚠️  Active worktrees detected"
    fi
    
    return $ERRORS
}
```

2. **Pattern Validation**
```bash
# Never use wildcards without validation
validate_pattern() {
    local PATTERN=$1
    local FILE=$2
    
    # Ensure pattern is specific to feature
    if [[ "$FILE" =~ ^(test|tests|src)/${PATTERN}[^/]*\.(js|ts|py|java)$ ]]; then
        return 0
    fi
    return 1
}
```

---

## Section 3: Portable Package Optimization

### Current Structure Problems

#### Problem 1: Redundant Documentation
Current files with overlapping content:
- `README_QUICK_START.md` (71 lines)
- `COPY_PASTE_GUIDE.md` (166 lines)  
- `TEST_HELLO.md` (194 lines)
- `PORTABLE_SUMMARY.md` (65 lines)
- `docs/tmops_docs_v6/quickstart.md` (209 lines)

**Issue:** 705 lines of documentation for a 3-minute setup.

#### Problem 2: Unclear Entry Point
Developer's first question: "Where do I start?"
- No clear `README.md` as entry point
- Multiple "quick start" guides
- No visual hierarchy

#### Problem 3: Nested Documentation
```
docs/
└── tmops_docs_v6/
    ├── tmops_protocol.md      # Deep technical details
    ├── tmops_claude_code.md   # Duplicate of instance_instructions/
    └── ...
```

### Proposed Simplified Structure

```
tmops_v6_portable/
├── README.md                   # START HERE - clear entry point
├── install.sh                  # One-command installer
├── tmops/                      # Core tools (renamed for clarity)
│   ├── init.sh                 # Simplified names
│   ├── cleanup.sh
│   ├── switch.sh               # New feature switching
│   └── lib/                    # Supporting scripts
│       ├── metrics.py
│       └── monitor.py
├── roles/                      # Clear role definitions
│   ├── orchestrator.md
│   ├── tester.md
│   ├── implementer.md
│   └── verifier.md
├── examples/                   # Optional examples
│   └── hello-world.md
└── docs/                       # Optional deep-dive docs
    └── protocol.md
```

### Simplified README.md (Complete Replacement)
```markdown
# TeamOps v6 - TDD Orchestration for Claude Code

4 Claude instances working together to build features test-first.

## Install (30 seconds)
\`\`\`bash
curl -sSL https://tmops.dev/install | bash
# or
./install.sh
\`\`\`

## Start Feature (2 minutes)
\`\`\`bash
# 1. Initialize feature with 4 worktrees
tmops/init.sh my-feature

# 2. Open 4 Claude Code terminals
cd wt-my-feature-orchestrator && claude
cd wt-my-feature-tester && claude
cd wt-my-feature-impl && claude
cd wt-my-feature-verify && claude

# 3. Paste role instructions from roles/ into each

# 4. Start orchestration
Tell Orchestrator: [BEGIN]: Start orchestration for my-feature
\`\`\`

## How It Works
1. **Orchestrator** coordinates the workflow
2. **Tester** writes failing tests (Red)
3. **Implementer** makes tests pass (Green)
4. **Verifier** reviews quality (Refactor)

## Commands
- \`tmops/init.sh <feature>\` - Start new feature
- \`tmops/switch.sh <feature>\` - Switch features
- \`tmops/cleanup.sh <feature>\` - Clean up feature
- \`tmops/list.sh\` - List all features

## Learn More
- \`examples/hello-world.md\` - Try it out
- \`docs/protocol.md\` - Technical details

---
MIT License | Based on TeamOps by @happycode-ch
```

### Developer Experience Improvements

#### 1. Single Decision Path
```
Start → README.md → install.sh → tmops/init.sh → Done
```

#### 2. Progressive Disclosure
- **Level 1:** README.md (just enough to start)
- **Level 2:** examples/ (learn by doing)
- **Level 3:** docs/ (deep understanding)

#### 3. Consistent Naming
- Scripts: verb-noun pattern (`init.sh`, `cleanup.sh`)
- Directories: plural nouns (`roles/`, `examples/`)
- Worktrees: `wt-{feature}-{role}` pattern

#### 4. Smart Defaults
```bash
# init.sh with smart detection
if [[ -d "test" ]]; then
    TEST_DIR="test"
elif [[ -d "tests" ]]; then
    TEST_DIR="tests"
elif [[ -d "spec" ]]; then
    TEST_DIR="spec"
else
    echo "Creating test/ directory..."
    mkdir -p test
    TEST_DIR="test"
fi
```

---

## Section 4: Implementation Recommendations

### Priority 1: Safety First (Week 1)
1. **Create backup mechanisms** in cleanup scripts
2. **Remove hardcoded "hello" patterns**
3. **Add confirmation prompts** with clear warnings
4. **Implement dry-run mode** for all destructive operations

### Priority 2: Multi-Feature Support (Week 2)
1. **Implement feature-namespaced worktrees**
2. **Create feature registry** (`.tmops/registry.json`)
3. **Add switch_feature.sh** script
4. **Build archive_feature.sh** for completed work

### Priority 3: Package Simplification (Week 3)
1. **Consolidate documentation** into single README.md
2. **Rename directories** for clarity
3. **Create progressive examples**
4. **Add automated tests**

### Migration Strategy

#### For Existing Users
```bash
# Migration script
./tmops_tools/migrate_to_v6.1.sh

# What it does:
# 1. Backs up current .tmops/
# 2. Converts to new structure
# 3. Updates worktree names
# 4. Preserves feature history
```

#### Breaking Changes
- Worktree names change from `wt-{role}` to `wt-{feature}-{role}`
- `.tmops/current` becomes `.tmops/active/current`
- Scripts move from `tmops_tools/` to `tmops/`

### Testing Plan

#### Unit Tests
```bash
# Test suite for each component
test/
├── test_init.sh
├── test_cleanup.sh
├── test_multi_feature.sh
└── test_migration.sh
```

#### Integration Tests
```bash
# Full workflow test
./test/integration/test_full_workflow.sh

# Tests:
# 1. Initialize feature-a
# 2. Initialize feature-b
# 3. Switch between them
# 4. Archive feature-a
# 5. Cleanup feature-b
# 6. Verify no data loss
```

### Documentation Updates

#### Required Documentation
1. **Migration Guide** - Step-by-step from v6.0 to v6.1
2. **Multi-Feature Guide** - How to work on multiple features
3. **Safety Guide** - Best practices for cleanup and archival
4. **API Reference** - All commands and options

---

## Conclusion

TeamOps v6 has significant potential but requires critical improvements for production use:

1. **Multi-feature support** is essential for real projects
2. **Safety mechanisms** must prevent accidental data loss
3. **Developer experience** needs dramatic simplification

The proposed v6.1 addresses all critical issues while maintaining backward compatibility where possible. Implementation should prioritize safety, then functionality, then experience.

### Recommended Next Steps
1. Review this report with stakeholders
2. Create v6.1 branch for implementation
3. Implement Priority 1 (Safety) immediately
4. Test with real projects before full release
5. Gather feedback and iterate

---

**Report prepared for:** TeamOps v6.1 Planning  
**Estimated effort:** 3 weeks (1 developer)  
**Risk level:** Low with proper migration strategy