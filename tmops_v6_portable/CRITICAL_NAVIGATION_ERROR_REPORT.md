# Critical Navigation Error Report - TeamOps v6.1

**Date:** 2025-08-22  
**Severity:** CRITICAL  
**Component:** Instance Instructions  
**Impact:** Complete system failure - instances cannot coordinate

## Executive Summary

A critical navigation bug was discovered where Claude Code instances could not locate their worktree directories, causing them to either:
1. Create new directories in incorrect locations (system root, wrong project paths)
2. Fail to find checkpoint files and task specifications
3. Break the entire orchestration workflow

## The Problem

### Root Cause
Instance instructions lacked clear, explicit navigation guidance. The instructions assumed instances would know:
- WHERE to navigate (which directory)
- HOW to navigate (find command vs direct path)
- WHEN to navigate (before any other operations)

### Symptoms Observed
1. **Tester Instance:** Created `/wt-my-feature-tester` at system root
2. **Orchestrator:** Created checkpoints in wrong location
3. **All Instances:** Could not find `.tmops/` directory structure
4. **Coordination Failure:** No instance could communicate via checkpoints

### Technical Details

#### Original Problem (Missing Navigation)
```markdown
## Your Workflow (Manual v6)
1. Report: "[TESTER] WAITING: Ready for instructions"
2. WAIT for human: "[BEGIN]: Start test writing"
```
No mention of WHERE the instance should be running from.

#### First Fix Attempt (Relative Path - FAILED)
```bash
cd wt-<feature>-tester
```
Problem: Instances didn't know the base directory, created worktrees in random locations.

#### Second Fix Attempt (Absolute Path - NON-PORTABLE)
```bash
cd /home/anthonycalek/projects/tmops_framework/CODE/tmops_v6_portable/wt-<feature>-tester
```
Problem: Hardcoded paths make the framework non-portable.

#### Final Solution (Portable Search)
```bash
# First, find where TeamOps was initialized:
find ~ -type d -name "wt-<feature>-tester" 2>/dev/null

# Navigate to YOUR worktree:
cd /path/to/project/wt-<feature>-tester
```

## Impact Analysis

### Failed Operations
- Checkpoint creation/discovery failed
- Git operations executed in wrong directories
- Test files created in incorrect locations
- Worktrees created outside project structure

### Data Loss Risk
- LOW: No code was lost
- MEDIUM: Time lost to debugging (~2 hours)
- HIGH: User confidence impacted

## Resolution

### Immediate Actions Taken
1. Added explicit navigation section to all 4 instance instruction files
2. Included find command to locate worktrees portably
3. Provided concrete examples with full paths
4. Positioned navigation as FIRST critical step

### Code Changes
All files in `instance_instructions/`:
- `01_orchestrator.md`
- `02_tester.md`
- `03_implementer.md`
- `04_verifier.md`

Added section:
```markdown
## CRITICAL: Navigate to Your Worktree First!
**You MUST be in the correct directory before starting:**

1. First, find where TeamOps was initialized:
```bash
find ~ -type d -name "wt-<feature>-<role>" 2>/dev/null
```

2. Navigate to YOUR worktree:
```bash
cd /path/to/project/wt-<feature>-<role>
```
```

## Prevention Measures

### Short-term
1. ✅ Updated all instance instructions with navigation
2. ✅ Made navigation the FIRST highlighted section
3. ✅ Included find command for portability
4. ✅ Added concrete examples

### Long-term Recommendations
1. Consider adding automatic worktree detection to instance startup
2. Create validation script that confirms correct directory
3. Add environment variable `TMOPS_PROJECT_ROOT` for reference
4. Include pwd output in instance status reports

## Testing Verification

### Test Scenario
```bash
# Initialize feature
./tmops_tools/init_feature_multi.sh test-hello

# Each instance should:
1. Run find command to locate their worktree
2. Navigate to found directory
3. Verify with pwd
4. Confirm access to ../.tmops/ structure
```

### Success Criteria
- All instances report correct working directory
- Checkpoints created in correct location
- All instances can read/write checkpoints
- Git operations occur in correct worktree

## Lessons Learned

1. **Never assume context:** Claude Code instances start with no knowledge of directory structure
2. **Explicit is better than implicit:** Every instruction should be unambiguous
3. **Portability matters:** Hardcoded paths break the framework's reusability
4. **First steps are critical:** Navigation must happen before any other operation
5. **Test the obvious:** Even basic operations like "cd" need testing

## Conclusion

This critical navigation error exposed a fundamental assumption flaw: that instances would inherently know where to operate. The fix ensures every instance can reliably find and navigate to its worktree regardless of the installation location. This makes TeamOps truly portable and prevents future navigation-related failures.

**Status:** RESOLVED  
**Fix Version:** v6.1.1  
**Commits:** Multiple fixes applied to instance instructions

---

*This report documents a critical bug that prevented TeamOps v6.1 from functioning. The issue has been resolved through comprehensive updates to all instance instruction files.*