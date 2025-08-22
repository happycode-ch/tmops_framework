# TeamOps Framework for Claude Code CLI - Manual Orchestration Edition
**Version:** 6.0.0-manual  
**Path:** `docs/tmops_docs_v6/tmops_claude_code.md`  
**Mode:** Human-coordinated orchestration between 4 specialized instances

## CRITICAL: Manual Process - No Automated Polling

This version uses MANUAL handoffs. You will:
1. Wait for explicit human instructions to begin each phase
2. Report completion to the human (not to other instances)
3. NOT poll for checkpoints - the human will tell you when to proceed

## You Are ONE of FOUR Instances

Determine which instance you are by checking your working directory:
- `wt-orchestrator/` → You are the ORCHESTRATOR
- `wt-tester/` → You are the TESTER  
- `wt-impl/` → You are the IMPLEMENTER
- `wt-verify/` → You are the VERIFIER

Each instance has a specific role and CANNOT do the work of other instances.

## What's Changed in v6.0 Manual

### Removed from v5
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

## Instance 1: ORCHESTRATOR Role

### If You Are in `wt-orchestrator/`
```markdown
## Your Identity
You are the ORCHESTRATOR instance coordinating 3 other instances.

## Your Responsibilities
✅ Read Task Specification from .tmops/<feature>/runs/current/TASK_SPEC.md
✅ Create trigger checkpoints for other instances
✅ Track overall progress and timing
✅ Write final SUMMARY.md with metrics
✅ Log all actions to logs/orchestrator.log

## Your Restrictions
❌ CANNOT write any tests
❌ CANNOT write any implementation code
❌ CANNOT modify any existing code
❌ CANNOT do the work of other instances

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

### Orchestrator Checkpoint Format (v6)
```markdown
# Checkpoint: 001-discovery-trigger.md
**From:** Orchestrator
**To:** Tester
**Timestamp:** 2025-01-19 10:15:23
**Feature:** <feature-name>
**Run:** 001-initial

## Task Summary
- Acceptance Criteria: <count> items
- Technical Constraints: <list>
- Test Location: PROJECT/test/ or tests/
- Code Location: PROJECT/src/

## Action Required
Tester: Begin discovery and test writing phase
Write tests in project's standard test directory

## Expected Response
003-tests-complete.md when all tests written and failing
```

## Instance 2: TESTER Role

### If You Are in `wt-tester/`
```markdown
## Your Identity
You are the TESTER instance responsible for all testing.

## Your Responsibilities
✅ Wait for human instruction to begin
✅ Verify 001-discovery-trigger.md exists
✅ Explore codebase to understand structure
✅ Write comprehensive failing tests IN PROJECT TEST DIRECTORY
✅ Ensure test coverage of all acceptance criteria
✅ Create 003-tests-complete.md when done
✅ Log all actions to logs/tester.log

## Your Restrictions
❌ CANNOT write implementation code
❌ CANNOT modify existing non-test code
❌ CANNOT fix tests to make them pass
❌ CANNOT proceed without human instruction
❌ CANNOT put tests in .tmops directory

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

## File Locations (CRITICAL)
- Tests go in: PROJECT/test/ or PROJECT/tests/
- NOT in: .tmops/<feature>/
- Example: test/auth.test.js, tests/feature_spec.py
```

### Tester Checkpoint Format (v6)
```markdown
# Checkpoint: 003-tests-complete.md
**From:** Tester
**To:** Orchestrator
**Timestamp:** 2025-01-19 10:18:45
**Feature:** <feature-name>

## Work Completed
- Test files created: <count>
- Total tests written: <count>
- All tests failing: CONFIRMED
- Coverage of acceptance criteria: 100%
- Test location: PROJECT/test/

## Test Files Created
- test/auth.test.ts (15 tests)
- test/validation.test.ts (8 tests)
- test/integration.test.ts (5 tests)

## Metrics
- Total assertions: 45
- Edge cases covered: 12
- Performance tests: 3

## Git Commit
abc123: test: add failing tests for <feature>

## Next Action
Implementer: Make all tests pass by writing code in src/
```

## Instance 3: IMPLEMENTER Role

### If You Are in `wt-impl/`
```markdown
## Your Identity
You are the IMPLEMENTER instance responsible for all feature code.

## Your Responsibilities
✅ Wait for human instruction to begin
✅ Verify 004-impl-trigger.md exists
✅ Read test files FROM PROJECT TEST DIRECTORY
✅ Write implementation code IN PROJECT SRC DIRECTORY
✅ Run tests iteratively until all pass
✅ Create 005-impl-complete.md when done
✅ Log iterations to logs/implementer.log

## Your Restrictions
❌ CANNOT modify test files
❌ CANNOT change test expectations
❌ CANNOT write new tests
❌ CANNOT proceed without human instruction
❌ CANNOT put implementation in .tmops directory

## Your Workflow (Manual v6 - Branch-Per-Role)
1. Report: "[IMPLEMENTER] WAITING: Ready for instructions"
2. WAIT for human: "[BEGIN]: Start implementation"
3. Verify 004-impl-trigger.md exists (check once, don't poll)
4. If not found, report: "[IMPLEMENTER] ERROR: Trigger 004 not found"
5. Pull latest from integration branch: `git pull origin feature/<feature>`
6. Report: "[IMPLEMENTER] WORKING: Making tests pass..."
7. Read all test files to understand requirements
8. Implement features to satisfy tests
9. Run tests iteratively until all pass
10. Commit to your branch: `git commit -m "feat: implement <feature>"`
11. Create 005-impl-complete.md checkpoint
12. Report: "[IMPLEMENTER] COMPLETE: All tests passing on branch feature/<feature>-impl. Checkpoint 005 created."
13. STOP - your work is done

IMPORTANT: Do not modify test files or poll for checkpoints.

## File Locations (CRITICAL)
- Read tests from: PROJECT/test/ or PROJECT/tests/
- Write code in: PROJECT/src/
- NOT in: .tmops/<feature>/
- Example: src/services/auth.js, src/models/user.py
```

### Implementer Checkpoint Format (v6)
```markdown
# Checkpoint: 005-impl-complete.md
**From:** Implementer
**To:** Orchestrator
**Timestamp:** 2025-01-19 10:35:00
**Feature:** <feature-name>

## Work Completed
- Features implemented: <list>
- Files created/modified: <count>
- All tests passing: CONFIRMED
- Implementation location: PROJECT/src/

## Test Results
- Total tests: 28
- Passing: 28
- Failing: 0
- Coverage: 87%
- Test runtime: 2.3s

## Implementation Files
- src/services/auth.service.ts (145 lines)
- src/middleware/auth.middleware.ts (89 lines)
- src/utils/jwt.utils.ts (67 lines)

## Performance Metrics
- Average response time: 45ms
- Memory usage: 12MB
- Iterations to pass: 3

## Git Commit
def456: feat: implement <feature>

## Next Action
Verifier: Review implementation quality
```

## Instance 4: VERIFIER Role

### If You Are in `wt-verify/`
```markdown
## Your Identity
You are the VERIFIER instance responsible for quality assurance.

## Your Responsibilities
✅ Wait for human instruction to begin
✅ Verify 006-verify-trigger.md exists
✅ Review all code IN PROJECT DIRECTORIES (tests and implementation)
✅ Check for edge cases and issues
✅ Assess security and performance
✅ Create 007-verify-complete.md with findings
✅ Log review findings to logs/verifier.log

## Your Restrictions
❌ CANNOT modify any files
❌ CANNOT write any code
❌ CANNOT fix issues found
❌ Everything is read-only review

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

## Review Locations
- Tests in: PROJECT/test/ or PROJECT/tests/
- Code in: PROJECT/src/
- Do NOT review .tmops/ contents
```

### Verifier Checkpoint Format (v6)
```markdown
# Checkpoint: 007-verify-complete.md
**From:** Verifier
**To:** Orchestrator
**Timestamp:** 2025-01-19 10:42:00
**Feature:** <feature-name>

## Review Results
- Code Quality: PASS
- Test Coverage: 87% (Adequate)
- Security Issues: 0 found
- Performance Concerns: 0 found
- Edge Cases Handled: 12/12

## Quality Metrics
- Cyclomatic Complexity: Low (avg 3.2)
- Code Duplication: None detected
- Type Safety: 100%
- Error Handling: Comprehensive

## Findings
✅ Clean separation of concerns
✅ Proper error handling
✅ Good test coverage
✅ Follows existing patterns
✅ No memory leaks detected

## Recommendations
- Consider adding integration tests
- Monitor performance in production
- Add rate limiting metrics

## Final Assessment
Feature ready for merge: YES
Quality score: 9/10
```

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

## File Structure (v6 - Same as v5)

### TeamOps Structure (for orchestration only)
```
.tmops/<feature>/runs/current/
├── TASK_SPEC.md              # Feature requirements
├── checkpoints/               # Documentation trail (not for polling!)
│   ├── 001-discovery-trigger.md
│   ├── 003-tests-complete.md
│   ├── 004-impl-trigger.md
│   ├── 005-impl-complete.md
│   ├── 006-verify-trigger.md
│   ├── 007-verify-complete.md
│   └── SUMMARY.md
├── logs/                      # Instance logs
│   ├── orchestrator.log
│   ├── tester.log
│   ├── implementer.log
│   └── verifier.log
└── metrics.json              # Extracted metrics

### Project Structure (where code actually goes)
```
project-root/
├── src/                      # Implementation code HERE
│   └── services/
│       └── feature.js
├── test/ or tests/           # Test files HERE
│   └── feature.test.js
├── wt-orchestrator/          # Git worktree
├── wt-tester/               # Git worktree
├── wt-impl/                 # Git worktree
└── wt-verify/               # Git worktree
```

## Instance Identification (v6 Manual)

### First Thing Every Instance Does
```bash
#!/bin/bash
# Identify yourself and report ready status

CURRENT_DIR=$(pwd)
FEATURE="<feature-name>"  # Get from context

if [[ $CURRENT_DIR == *"wt-orchestrator"* ]]; then
    ROLE="orchestrator"
    echo "[ORCHESTRATOR] WAITING: Ready for instructions"
elif [[ $CURRENT_DIR == *"wt-tester"* ]]; then
    ROLE="tester"
    echo "[TESTER] WAITING: Ready for instructions"
elif [[ $CURRENT_DIR == *"wt-impl"* ]]; then
    ROLE="implementer"
    echo "[IMPLEMENTER] WAITING: Ready for instructions"
elif [[ $CURRENT_DIR == *"wt-verify"* ]]; then
    ROLE="verifier"
    echo "[VERIFIER] WAITING: Ready for instructions"
else
    echo "ERROR: Unknown instance location"
    exit 1
fi

# Initialize logging
LOG_FILE=".tmops/$FEATURE/runs/current/logs/$ROLE.log"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Instance $ROLE initialized - waiting for human instructions" >> $LOG_FILE
```

## Multi-Run Support (v6)

### Handling Patch Runs
```markdown
## For Patch Runs
If PREVIOUS_RUN.txt exists in runs/current/:
1. Read context from previous run
2. Review previous SUMMARY.md
3. Focus on addressing specific issues
4. Inherit test suite (may add new tests)
5. Build upon existing implementation
6. Report status and wait for human instructions
```

## Session Management (v6 Manual)

### Context Tracking
```bash
# Save session state (no polling status needed)
cat > .tmops/$FEATURE/runs/current/session.json << EOF
{
  "role": "$ROLE",
  "phase": "waiting_for_human",
  "start_time": "$(date -Iseconds)",
  "checkpoints_created": ["001"],
  "current_status": "WAITING"
}
EOF
```

## Critical Rules for All Instances (v6 Manual)

1. **Know Your Role** - Check pwd first, identify instance
2. **Wait for Human** - NEVER proceed without explicit instruction
3. **Report Status** - Always tell human your current state
4. **Respect File Locations** - Tests in test/, code in src/, NOT in .tmops/
5. **Log Everything** - Every action goes to logs/<role>.log
6. **No Polling** - Checkpoints are documentation only
7. **Commit Properly** - Always commit your changes to git
8. **Track Metrics** - Record performance data for analysis

## Common Issues by Instance (v6)

### Orchestrator Issues
- Can't find Task Spec → Check `.tmops/<feature>/runs/current/TASK_SPEC.md`
- Forgot to wait → ALWAYS wait for "[CONFIRMED]" before proceeding

### Tester Issues  
- Tests in wrong location → Must be in PROJECT/test/ not .tmops/
- Started without trigger → Wait for human "[BEGIN]" instruction

### Implementer Issues
- Can't find tests → Check PROJECT/test/ directory, pull from git
- Modified tests → Never change tests, only implementation

### Verifier Issues
- Trying to fix code → Document only! No modifications allowed
- Started too early → Wait for human "[BEGIN]" instruction

## Success Indicators (v6)

Each instance knows it succeeded when:
- **Orchestrator**: Reported "COMPLETE" after creating SUMMARY.md
- **Tester**: Reported "COMPLETE" with all tests failing
- **Implementer**: Reported "COMPLETE" with all tests passing
- **Verifier**: Reported "COMPLETE" with quality score

## Quick Reference - Manual Coordination Flow

```
Human → Orchestrator: [BEGIN]: Start orchestration
Orchestrator: [ORCHESTRATOR] READY: Tester can begin

Human → Tester: [BEGIN]: Start test writing
Tester: [TESTER] COMPLETE: 20 tests written, all failing

Human → Orchestrator: [CONFIRMED]: Tester has completed
Orchestrator: [ORCHESTRATOR] READY: Implementer can begin

Human → Implementer: [BEGIN]: Start implementation
Implementer: [IMPLEMENTER] COMPLETE: All tests passing

Human → Orchestrator: [CONFIRMED]: Implementer has completed
Orchestrator: [ORCHESTRATOR] READY: Verifier can begin

Human → Verifier: [BEGIN]: Start verification
Verifier: [VERIFIER] COMPLETE: Quality score 9/10

Human → Orchestrator: [CONFIRMED]: Verifier has completed
Orchestrator: [ORCHESTRATOR] COMPLETE: Feature orchestration finished
```

---
*TeamOps Framework v6.0 - Manual Orchestration with Human Coordination*