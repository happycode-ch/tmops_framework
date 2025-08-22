# TeamOps v6.1 Worktree Architecture Fix Report

**Date:** 2025-08-22  
**Author:** Claude Code Analysis  
**Status:** Critical Bug Identified  

## Executive Summary

The TeamOps v6.1 framework has a fundamental architectural bug in its Git worktree implementation. The `init_feature_multi.sh` script attempts to create 4 worktrees all pointing to the same branch, which violates Git's core constraint that only one worktree can have a specific branch checked out at any time. This report provides a comprehensive analysis and three solution approaches.

## The Core Problem

### Current Implementation (BROKEN)
```bash
# init_feature_multi.sh lines 92-109
for role in orchestrator tester impl verify; do
    WORKTREE="${WORKTREE_PREFIX}-${role}"
    if git show-ref --verify --quiet "refs/heads/feature/$FEATURE"; then
        git worktree add "$WORKTREE" "feature/$FEATURE"  # FAILS after first iteration
    else
        git worktree add "$WORKTREE" -b "feature/$FEATURE"  # Only works once
    fi
done
```

### Git's Fundamental Rule
- **Only ONE worktree can checkout a specific branch at a time**
- This prevents conflicts when multiple worktrees modify the same branch
- Git enforces this with: `fatal: 'feature/test-hello' is already used by worktree`

### Impact Analysis
1. **Broken Installation**: The test script (`test_v6.1.sh`) expects 4 worktrees but only 1 gets created
2. **Workflow Blocked**: Users cannot set up the 4-instance architecture as documented
3. **Feature Isolation Failed**: Multi-feature support is broken

## Deep Architecture Analysis

### What TeamOps v6 Expects

Based on comprehensive analysis of all documentation and scripts:

1. **4 Independent Claude Code Instances**: Each in its own terminal/worktree
2. **Sequential Workflow**: Tester → Implementer → Verifier (orchestrated)
3. **Same Feature Branch**: All instances work on `feature/<name>`
4. **Git Synchronization**: Instances use `git pull` to get each other's changes
5. **Checkpoint Communication**: Via `.tmops/<feature>/runs/current/checkpoints/`

### The Architectural Contradiction

The framework has conflicting requirements:
- **Requirement A**: 4 separate worktrees for instance isolation
- **Requirement B**: All instances work on the same branch
- **Git Reality**: Can't have both - only one worktree per branch

### Evidence from Code Review

1. **Instance Instructions** (e.g., `03_implementer.md` line 36):
   - "Pull latest from git to get test files"
   - Implies shared branch with sequential commits

2. **Cleanup Script** (`cleanup_safe.sh` lines 88-95):
   - Expects 4 worktrees: `wt-${FEATURE}-{orchestrator,tester,impl,verify}`

3. **Switch Script** (`switch_feature.sh` lines 32-39):
   - Lists 4 worktrees as expected state

4. **Test Script** (`test_v6.1.sh` lines 11-19):
   - Validates existence of all 4 worktrees

## Solution Approaches

### Solution 1: Single Worktree (Simplest, Recommended)

**Concept**: All 4 instances share one worktree directory

**Implementation**:
```bash
# Modified init_feature_multi.sh
WORKTREE="wt-${FEATURE}"
git worktree add "$WORKTREE" -b "feature/$FEATURE"

echo "All instances will work in: $WORKTREE/"
echo "Open 4 terminals, all using: cd $WORKTREE && claude"
```

**Pros**:
- Aligns with Git's constraints
- Simplest to implement
- Matches sequential workflow nature
- No complex synchronization needed

**Cons**:
- Less isolation between instances
- Potential file conflicts if instances run simultaneously
- Different from current documentation

### Solution 2: Detached HEAD Worktrees

**Concept**: Create worktrees in detached HEAD state, manually sync

**Implementation**:
```bash
# Create first worktree with branch
git worktree add "wt-${FEATURE}-orchestrator" -b "feature/$FEATURE"

# Create others in detached state
for role in tester impl verify; do
    WORKTREE="wt-${FEATURE}-${role}"
    git worktree add "$WORKTREE" --detach
    cd "$WORKTREE"
    git checkout "feature/$FEATURE"  # Detached HEAD at same commit
    cd ..
done
```

**Workflow**:
1. Tester works in detached state
2. Tester creates temporary branch, commits
3. Tester pushes changes to `feature/$FEATURE`
4. Implementer pulls, works in detached state
5. Continue pattern...

**Pros**:
- Maintains 4 separate worktrees
- Provides instance isolation

**Cons**:
- Complex Git workflow
- Requires careful branch management
- Easy to lose work if not careful
- Not standard Git practice

### Solution 3: Branch-Per-Role Architecture

**Concept**: Each role gets its own branch, merged sequentially

**Implementation**:
```bash
# Create role-specific branches
for role in orchestrator tester impl verify; do
    WORKTREE="wt-${FEATURE}-${role}"
    BRANCH="feature/${FEATURE}-${role}"
    git worktree add "$WORKTREE" -b "$BRANCH"
done

# Create main feature branch for merging
git branch "feature/${FEATURE}" HEAD
```

**Workflow**:
1. Tester works on `feature/test-hello-tester`
2. Tester merges to `feature/test-hello`
3. Implementer branches from updated `feature/test-hello`
4. Implementer merges back to `feature/test-hello`
5. Continue pattern...

**Pros**:
- True branch isolation
- Clear Git history
- No worktree conflicts

**Cons**:
- Requires protocol changes
- More complex merging
- Deviates from documented workflow
- May introduce merge conflicts

## Recommended Fix Implementation

### Phase 1: Immediate Fix (Solution 1)

Modify `init_feature_multi.sh`:

```bash
#!/bin/bash
# TeamOps v6.1 - Multi-feature initialization (FIXED)

set -e

FEATURE="$1"
RUN_TYPE="${2:-initial}"

# ... [validation code stays the same] ...

# Create single worktree for all instances
echo "Creating shared worktree..."
WORKTREE="wt-${FEATURE}"

if [[ -d "$WORKTREE" ]]; then
    echo "  ✓ $WORKTREE (already exists)"
else
    if git show-ref --verify --quiet "refs/heads/feature/$FEATURE"; then
        git worktree add "$WORKTREE" "feature/$FEATURE"
        echo "  ✓ $WORKTREE (using existing branch)"
    else
        git worktree add "$WORKTREE" -b "feature/$FEATURE"
        echo "  ✓ $WORKTREE (new branch created)"
    fi
fi

# ... [rest of script stays the same] ...

echo "Next steps:"
echo ""
echo "1. Edit task specification:"
echo "   vim $RUN_DIR/TASK_SPEC.md"
echo ""
echo "2. Open 4 Claude Code terminals, ALL in the same directory:"
echo "   Terminal 1: cd ${WORKTREE} && claude  # Orchestrator"
echo "   Terminal 2: cd ${WORKTREE} && claude  # Tester"
echo "   Terminal 3: cd ${WORKTREE} && claude  # Implementer"
echo "   Terminal 4: cd ${WORKTREE} && claude  # Verifier"
echo ""
echo "3. Paste role instructions from $INSTRUCTIONS_DIR/"
```

### Phase 2: Update Supporting Scripts

1. **cleanup_safe.sh**: Remove the loop checking for 4 worktrees
2. **switch_feature.sh**: Show single worktree location
3. **list_features.sh**: Update to recognize single worktree pattern
4. **test_v6.1.sh**: Update tests to check for single worktree

### Phase 3: Documentation Updates

1. Update instance instructions to clarify shared worktree
2. Add Git workflow documentation for sequential commits
3. Update README with new setup instructions

## Risk Assessment

### Current State Risks
- **HIGH**: New users cannot initialize features
- **HIGH**: Test suite fails immediately
- **MEDIUM**: Confusion from conflicting documentation

### Fix Implementation Risks
- **LOW**: Solution 1 is simple and aligns with Git
- **MEDIUM**: Requires documentation updates
- **LOW**: Backward compatibility (v6.1 is new)

## Testing Plan

1. **Unit Test**: Create feature, verify single worktree
2. **Integration Test**: Run full TeamOps workflow
3. **Multi-Feature Test**: Verify multiple features can coexist
4. **Cleanup Test**: Ensure cleanup removes correct files

## Timeline

- **Immediate** (1 hour): Implement Solution 1 fix
- **Short-term** (2 hours): Update all supporting scripts
- **Medium-term** (4 hours): Complete documentation updates
- **Long-term** (1 week): Consider Solution 3 for v7.0

## Conclusion

The TeamOps v6.1 worktree architecture has a fundamental bug that prevents proper initialization. The root cause is attempting to create multiple worktrees for the same Git branch, which Git prohibits.

**Recommended Action**: Implement Solution 1 (single shared worktree) immediately, as it:
- Aligns with Git's constraints
- Maintains the sequential workflow
- Requires minimal code changes
- Preserves the checkpoint-based communication

This fix will restore functionality while maintaining the core TeamOps orchestration principles.

---

*End of Report*