# TeamOps v6 Manual Orchestration - Implementation Guide

**Purpose:** Step-by-step guide to refactor TeamOps v5 into v6 with manual handoffs  
**Executor:** Claude Code instance  
**Time Estimate:** 45-60 minutes  
**Result:** Complete tmops_docs_v6/ folder ready for testing

## Overview

You will create TeamOps v6, which replaces automated polling with manual human coordination between instances. The core framework remains identical to v5, only the handoff mechanism changes.

## Phase 1: Create Folder Structure

```bash
# Navigate to the repository root (contains tmops_docs_v5/)
cd <repository_root>

# Create v6 documentation folder
mkdir -p tmops_docs_v6

# Copy v5 documents as starting point
cp -r tmops_docs_v5/* tmops_docs_v6/

# Verify structure
ls -la tmops_docs_v6/
# Should show: quickstart.md, tmops_claude_chat.md, tmops_claude_code.md, tmops_protocol.md
```

## Phase 2: Update tmops_claude_code.md

This is the most critical file - it contains instance prompts.

### File: `tmops_docs_v6/tmops_claude_code.md`

**Replace the header:**
```markdown
# TeamOps Framework for Claude Code CLI - Manual Orchestration Edition
**Version:** 6.0.0-manual
**Path:** `tmops_docs_v6/tmops_claude_code.md`
**Mode:** Human-coordinated orchestration between 4 specialized instances

## CRITICAL: Manual Process - No Automated Polling

This version uses MANUAL handoffs. You will:
1. Wait for explicit human instructions to begin each phase
2. Report completion to the human (not to other instances)
3. NOT poll for checkpoints - the human will tell you when to proceed
```

**For ORCHESTRATOR Section, replace the workflow:**
```markdown
## Your Workflow (Manual v6)
1. Report: "[ORCHESTRATOR] WAITING: Ready for instructions"
2. WAIT for human: "[BEGIN]: Start orchestration for <feature>"
3. Initialize logging to .tmops/<feature>/runs/current/logs/orchestrator.log
4. Read Task Spec from runs/current/TASK_SPEC.md
5. Create 001-discovery-trigger.md
6. Report: "[ORCHESTRATOR] READY: Tester can begin. Trigger 001 created."
7. WAIT for human: "[CONFIRMED]: Tester has completed"
8. Create 004-impl-trigger.md
9. Report: "[ORCHESTRATOR] READY: Implementer can begin. Trigger 004 created."
10. WAIT for human: "[CONFIRMED]: Implementer has completed"
11. Create 006-verify-trigger.md
12. Report: "[ORCHESTRATOR] READY: Verifier can begin. Trigger 006 created."
13. WAIT for human: "[CONFIRMED]: Verifier has completed"
14. Extract metrics and create SUMMARY.md
15. Report: "[ORCHESTRATOR] COMPLETE: Feature orchestration finished. SUMMARY.md created."

IMPORTANT: Never proceed to next step without explicit human confirmation.
Remove ALL polling code or automatic checkpoint detection.
```

**For TESTER Section, replace the workflow:**
```markdown
## Your Workflow (Manual v6)
1. Report: "[TESTER] WAITING: Ready for instructions"
2. WAIT for human: "[BEGIN]: Start test writing"
3. Verify 001-discovery-trigger.md exists (check once, don't poll)
4. If not found, report: "[TESTER] ERROR: Trigger 001 not found"
5. Read Task Spec and requirements
6. Explore codebase structure (read-only)
7. Report: "[TESTER] WORKING: Writing tests..."
8. Write comprehensive failing tests in PROJECT/test/ or PROJECT/tests/
9. Run tests to confirm they fail
10. Commit test files to git
11. Create 003-tests-complete.md checkpoint
12. Report: "[TESTER] COMPLETE: X tests written, all failing. Checkpoint 003 created."
13. STOP - your work is done

IMPORTANT: Do not poll or wait for other checkpoints.
Only communicate with the human coordinator.
```

**For IMPLEMENTER Section, replace the workflow:**
```markdown
## Your Workflow (Manual v6)
1. Report: "[IMPLEMENTER] WAITING: Ready for instructions"
2. WAIT for human: "[BEGIN]: Start implementation"
3. Verify 004-impl-trigger.md exists (check once, don't poll)
4. If not found, report: "[IMPLEMENTER] ERROR: Trigger 004 not found"
5. Pull latest from git to get test files
6. Report: "[IMPLEMENTER] WORKING: Making tests pass..."
7. Read all test files to understand requirements
8. Implement features to satisfy tests
9. Run tests iteratively until all pass
10. Commit implementation to git
11. Create 005-impl-complete.md checkpoint
12. Report: "[IMPLEMENTER] COMPLETE: All tests passing. Checkpoint 005 created."
13. STOP - your work is done

IMPORTANT: Do not modify test files or poll for checkpoints.
```

**For VERIFIER Section, replace the workflow:**
```markdown
## Your Workflow (Manual v6)
1. Report: "[VERIFIER] WAITING: Ready for instructions"
2. WAIT for human: "[BEGIN]: Start verification"
3. Verify 006-verify-trigger.md exists (check once, don't poll)
4. If not found, report: "[VERIFIER] ERROR: Trigger 006 not found"
5. Pull latest from git to review all changes
6. Report: "[VERIFIER] WORKING: Reviewing code quality..."
7. Review test quality and coverage
8. Review implementation quality
9. Assess security, performance, edge cases
10. Calculate quality score
11. Create 007-verify-complete.md with findings
12. Report: "[VERIFIER] COMPLETE: Review finished. Quality score X/10. Checkpoint 007 created."
13. STOP - your work is done

IMPORTANT: This is read-only review. Do not modify any code.
```

**Add new section at the end:**
```markdown
## Communication Protocol (v6 Manual)

### Your Status Messages to Human
- `[ROLE] WAITING: Ready for instructions` - Initial state
- `[ROLE] WORKING: <description>` - During execution
- `[ROLE] READY: <next step>` - Orchestrator only, after creating trigger
- `[ROLE] COMPLETE: <summary>` - When finished
- `[ROLE] ERROR: <issue>` - If problems occur

### Human Instructions You'll Receive
- `[BEGIN]: <description>` - Start your phase
- `[CONFIRMED]: <instance> has completed` - Orchestrator only
- `[STATUS]: Report current status` - Status check
- `[PAUSE]: Hold current work` - Pause execution
- `[ABORT]: Stop and cleanup` - Emergency stop

### CRITICAL v6 Rules
1. NEVER poll for checkpoints
2. ALWAYS wait for explicit human instruction
3. ALWAYS report status after major actions
4. NEVER proceed without confirmation
5. Checkpoints are for documentation only, not communication
```

## Phase 3: Update quickstart.md

### File: `tmops_docs_v6/quickstart.md`

**Replace the title and version:**
```markdown
# TeamOps Framework Manual Orchestration Quick Start
**Version:** 6.0.0-manual
**Time to First Feature:** ~5 minutes setup, 30-60 minutes execution
**Key Change:** Human coordinates instance handoffs (no automated polling)
```

**Replace Step 4 (Launch instances) with:**
```markdown
### Step 4: Launch 4 Claude Code Instances with Manual Coordination

Open 4 terminal windows/tabs and launch Claude Code in each:

**Terminal 1 - Orchestrator:**
```bash
cd wt-orchestrator && claude
```

**Terminal 2 - Tester:**
```bash
cd wt-tester && claude
```

**Terminal 3 - Implementer:**
```bash
cd wt-impl && claude
```

**Terminal 4 - Verifier:**
```bash
cd wt-verify && claude
```

### Step 5: Initialize All Instances

Paste the appropriate v6 prompt into each instance from `tmops_docs_v6/tmops_claude_code.md`.

All instances should respond:
- `[ORCHESTRATOR] WAITING: Ready for instructions`
- `[TESTER] WAITING: Ready for instructions`
- `[IMPLEMENTER] WAITING: Ready for instructions`
- `[VERIFIER] WAITING: Ready for instructions`

### Step 6: Manual Orchestration Workflow

**Phase 1 - Start Orchestration:**
```
You → Orchestrator: [BEGIN]: Start orchestration for "my-feature"
Orchestrator: [ORCHESTRATOR] READY: Tester can begin. Trigger 001 created.
```

**Phase 2 - Test Writing:**
```
You → Tester: [BEGIN]: Start test writing
Tester: [TESTER] WORKING: Writing tests...
(wait 10-15 minutes)
Tester: [TESTER] COMPLETE: 18 tests written, all failing. Checkpoint 003 created.
```

**Phase 3 - Relay to Orchestrator:**
```
You → Orchestrator: [CONFIRMED]: Tester has completed
Orchestrator: [ORCHESTRATOR] READY: Implementer can begin. Trigger 004 created.
```

**Phase 4 - Implementation:**
```
You → Implementer: [BEGIN]: Start implementation
Implementer: [IMPLEMENTER] WORKING: Making tests pass...
(wait 10-20 minutes)
Implementer: [IMPLEMENTER] COMPLETE: All tests passing. Checkpoint 005 created.
```

**Phase 5 - Relay to Orchestrator:**
```
You → Orchestrator: [CONFIRMED]: Implementer has completed
Orchestrator: [ORCHESTRATOR] READY: Verifier can begin. Trigger 006 created.
```

**Phase 6 - Verification:**
```
You → Verifier: [BEGIN]: Start verification
Verifier: [VERIFIER] WORKING: Reviewing code quality...
(wait 5-10 minutes)
Verifier: [VERIFIER] COMPLETE: Review finished. Quality score 9/10. Checkpoint 007 created.
```

**Phase 7 - Final Summary:**
```
You → Orchestrator: [CONFIRMED]: Verifier has completed
Orchestrator: [ORCHESTRATOR] COMPLETE: Feature orchestration finished. SUMMARY.md created.
```
```

**Add new section:**
```markdown
## Manual Process Benefits

### Why Manual Orchestration?
1. **100% Reliable** - No missed checkpoints or polling timeouts
2. **Full Visibility** - See exactly what each instance is doing
3. **Pause Capability** - Stop between phases to review work
4. **Better Debugging** - Clear failure points when issues occur
5. **Learning Tool** - Understand the workflow by participating

### Quick Reference Card

| From Instance | Message | Your Response |
|--------------|---------|---------------|
| `[X] WAITING: Ready` | Instance initialized | Send `[BEGIN]` when ready |
| `[X] WORKING: ...` | Instance is busy | Wait for completion |
| `[X] COMPLETE: ...` | Instance finished | Relay to Orchestrator |
| `[X] ERROR: ...` | Problem occurred | Debug and retry |

| To Instance | When to Send |
|------------|--------------|
| `[BEGIN]: Start <phase>` | When previous phase complete |
| `[CONFIRMED]: X has completed` | After instance reports COMPLETE |
| `[STATUS]: Report status` | To check progress |
| `[PAUSE]: Hold work` | To pause execution |
```

## Phase 4: Update tmops_protocol.md

### File: `tmops_docs_v6/tmops_protocol.md`

**Add new section after "Core Concepts":**
```markdown
## Orchestration Modes

### v5.x - Automated Polling (Legacy)
- Instances poll for checkpoints automatically
- Exponential backoff for efficiency
- Risk of missed checkpoints or timeouts

### v6.0 - Manual Orchestration (Current)
- Human relays completion status between instances
- 100% reliable handoffs
- Better visibility and control
- Checkpoints still created for audit trail
- No polling code or timeout logic

### Choosing a Mode
- **Use v6 Manual** for: Critical features, learning, debugging
- **Use v5 Automated** for: Experienced users, simple features (deprecated)
```

## Phase 5: Update tmops_claude_chat.md

### File: `tmops_docs_v6/tmops_claude_chat.md`

**Update the "Managing the Orchestration" section:**
```markdown
## Managing the Orchestration (v6 Manual Process)

### Your Role as Human Coordinator

In v6, you are the communication bridge between instances:

1. **Launch Phase**: Start all 4 instances with v6 prompts
2. **Coordination Phase**: Relay messages between instances
3. **Monitoring Phase**: Watch for completion messages
4. **Quality Gates**: Review work between phases if needed

### Communication Flow
```
Instance A completes → Reports to YOU → You inform Orchestrator → Orchestrator triggers Instance B
```

This manual process ensures 100% reliable handoffs with no polling issues.

### Message Templates

**Starting work:**
```
[BEGIN]: Start orchestration for "<feature-name>"
[BEGIN]: Start test writing
[BEGIN]: Start implementation
[BEGIN]: Start verification
```

**Confirming completion:**
```
[CONFIRMED]: Tester has completed
[CONFIRMED]: Implementer has completed
[CONFIRMED]: Verifier has completed
```

**Status checks:**
```
[STATUS]: Report current status
```
```

## Phase 6: Create Migration Guide

### New File: `tmops_docs_v6/MIGRATION_FROM_V5.md`

```markdown
# Migrating from TeamOps v5 to v6 Manual Orchestration

## What's Changed

### Removed in v6
- ❌ All polling loops and checkpoint monitoring
- ❌ Timeout configurations
- ❌ Exponential backoff logic
- ❌ Automated checkpoint detection

### Added in v6
- ✅ Human coordination of handoffs
- ✅ Explicit status reporting
- ✅ Clear wait states
- ✅ Manual confirmation requirements

### Unchanged from v5
- ✅ All instance roles and responsibilities
- ✅ Checkpoint file formats and locations
- ✅ Git worktree structure
- ✅ Test/implementation file locations
- ✅ Metrics and logging systems

## Quick Conversion Checklist

- [ ] Read v6 documentation
- [ ] Understand manual coordination role
- [ ] Practice status message format
- [ ] Test with simple feature first
- [ ] Document any issues for improvement

## Common Questions

**Q: Do I need to type messages exactly as shown?**
A: The format helps clarity but minor variations are fine. The key is clear communication.

**Q: Can I automate the human coordination?**
A: That defeats the purpose. The manual process provides reliability and visibility.

**Q: What if an instance doesn't respond?**
A: Send `[STATUS]: Report current status` to check if it's still working.

**Q: Can I pause between phases?**
A: Yes! That's a key benefit. Take breaks, review work, or debug as needed.
```

## Phase 7: Cleanup Procedure for Existing Features

### New File: `tmops_tools/cleanup_feature.sh`

Create a cleanup script for removing existing features:

```bash
#!/bin/bash
# TeamOps Feature Cleanup Script
# Removes all artifacts from a previous feature run

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

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}    Cleanup Complete for: $FEATURE${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo ""
echo "You can now run a fresh test with:"
echo "  ./tmops_tools/init_feature_v6.sh $FEATURE initial"
echo ""

# Make script executable
chmod +x "$0" 2>/dev/null || true
```

### Usage Instructions for Cleanup

Add this to the TEST_PLAN.md:

```markdown
## Pre-Test Cleanup (if needed)

If the hello-api feature already exists from a previous test:

```bash
# Run the cleanup script
./tmops_tools/cleanup_feature.sh hello-api

# Or manually clean up:
# 1. Remove worktrees
git worktree remove wt-orchestrator --force
git worktree remove wt-tester --force  
git worktree remove wt-impl --force
git worktree remove wt-verify --force

# 2. Remove feature branch
git branch -D feature/hello-api

# 3. Remove TeamOps artifacts
rm -rf .tmops/hello-api

# 4. Remove any test/src files created (check first!)
rm -f test/*hello* src/*hello*
```

After cleanup, you can start fresh with the v6 test.
```

## Phase 8: Create Test Plan

```markdown
# TeamOps v6 Manual Orchestration - Test Plan

## Test Feature: "hello-api"

### Acceptance Criteria
- GET /api/hello returns {"message": "Hello, World!"}
- Response has 200 status code
- Content-Type is application/json

### Expected Timeline
- Setup: 5 minutes
- Test Writing: 5 minutes (simple feature)
- Implementation: 5 minutes
- Verification: 5 minutes
- Total: ~20 minutes

### Test Checklist

#### Pre-Launch
- [ ] Repository cloned
- [ ] In CODE/ directory
- [ ] Run: `./tmops_tools/init_feature.sh hello-api initial`
- [ ] Edit `.tmops/hello-api/runs/current/TASK_SPEC.md`

#### Launch Phase
- [ ] Open 4 terminals
- [ ] Navigate each to appropriate worktree
- [ ] Launch Claude Code in each
- [ ] Paste v6 prompts
- [ ] All instances report WAITING

#### Orchestration Phase
- [ ] Send `[BEGIN]` to Orchestrator
- [ ] Orchestrator creates trigger 001
- [ ] Send `[BEGIN]` to Tester
- [ ] Tester completes and reports
- [ ] Send `[CONFIRMED]` to Orchestrator
- [ ] Continue through all phases

#### Verification
- [ ] SUMMARY.md created
- [ ] All tests passing
- [ ] Metrics extracted
- [ ] Feature complete

### Success Criteria
- No polling timeouts
- Clear status messages at each step
- Complete audit trail in checkpoints
- Working hello API endpoint
```

## Phase 8: Update Scripts

### File: `tmops_tools/init_feature_v6.sh`

Create new initialization script that mentions v6:

```bash
#!/bin/bash
# TeamOps v6 Manual Orchestration - Feature Initializer

FEATURE_NAME="$1"
RUN_TYPE="${2:-initial}"

echo "═══════════════════════════════════════════════════════"
echo "    TeamOps v6 - Manual Orchestration Framework"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "Initializing feature: $FEATURE_NAME"
echo "Run type: $RUN_TYPE"
echo ""

# Rest of script identical to v5 init_feature.sh
# ... (copy existing logic)

echo ""
echo "IMPORTANT: This is v6 with MANUAL orchestration"
echo "You will coordinate handoffs between instances."
echo "No automated polling - 100% reliable!"
echo ""
echo "Next steps:"
echo "1. Edit .tmops/$FEATURE_NAME/runs/current/TASK_SPEC.md"
echo "2. Launch 4 Claude Code instances"
echo "3. Use prompts from tmops_docs_v6/tmops_claude_code.md"
echo "4. Follow manual coordination workflow"
```

## Implementation Checklist

### For Claude Code Instance:

1. **Clean up existing test feature (if needed)**
   - [ ] Create cleanup_feature.sh script
   - [ ] Run: `./tmops_tools/cleanup_feature.sh hello-api`
   - [ ] Verify all artifacts removed

2. **Create folder structure**
   - [ ] Create tmops_docs_v6/ directory
   - [ ] Copy all files from tmops_docs_v5/

3. **Update core documents**
   - [ ] Modify tmops_claude_code.md with manual workflows
   - [ ] Update quickstart.md with manual process
   - [ ] Enhance tmops_protocol.md with v6 section
   - [ ] Update tmops_claude_chat.md coordination section

3. **Create new documents**
   - [ ] Create MIGRATION_FROM_V5.md
   - [ ] Create TEST_PLAN.md
   - [ ] Create init_feature_v6.sh script

4. **Verify changes**
   - [ ] All polling instructions removed
   - [ ] Wait states added
   - [ ] Status reporting format documented
   - [ ] Manual coordination steps clear

5. **Test the implementation**
   - [ ] Run through hello-api test case
   - [ ] Verify all handoffs work
   - [ ] Check checkpoint creation
   - [ ] Confirm no polling occurs

## Validation Commands

```bash
# Verify cleanup completed (if hello-api existed)
ls -la .tmops/ | grep hello-api  # Should return nothing
git worktree list | grep wt-      # Should show no worktrees
git branch | grep feature/hello-api  # Should not exist

# Verify structure created
ls -la tmops_docs_v6/

# Check no polling references remain
grep -r "poll" tmops_docs_v6/ | grep -v "# No polling"

# Verify manual instructions added
grep -r "WAITING" tmops_docs_v6/tmops_claude_code.md

# Check for human coordination
grep -r "CONFIRMED" tmops_docs_v6/

# Ensure v5 unchanged
diff -q tmops_docs_v5/quickstart.md tmops_docs_v5/quickstart.md.backup

# Verify cleanup script is executable
ls -la tmops_tools/cleanup_feature.sh
```

## Success Criteria

The implementation is complete when:
1. All v6 documents exist in tmops_docs_v6/
2. No polling logic remains in instance instructions
3. Manual coordination workflow is clearly documented
4. Test with hello-api feature succeeds
5. All instances report status correctly
6. Human can successfully coordinate all handoffs

## Time Estimate

- Cleanup of existing hello-api (if needed): 5 minutes
- Document creation/modification: 30 minutes
- Testing with hello-api: 20 minutes
- Refinements: 10 minutes
- **Total: ~65 minutes (or 60 minutes if no cleanup needed)**

---
*End of Implementation Guide - Ready for Claude Code execution*