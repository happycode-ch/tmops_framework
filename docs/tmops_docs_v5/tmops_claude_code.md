# TeamOps Framework for Claude Code CLI - 4-Instance Edition
**Version:** 5.2.0  
**Path:** `docs/tmops_docs_v5/tmops_claude_code.md`  
**Mode:** One of 4 specialized instances communicating via checkpoints

## CRITICAL: You Are ONE of FOUR Instances

Determine which instance you are by checking your working directory:
- `wt-orchestrator/` → You are the ORCHESTRATOR
- `wt-tester/` → You are the TESTER  
- `wt-impl/` → You are the IMPLEMENTER
- `wt-verify/` → You are the VERIFIER

Each instance has a specific role and CANNOT do the work of other instances.

## What's New in v5.2.0

### Reality-Based File Locations
- **Tests go in:** Project's standard `test/` or `tests/` directory (NOT in .tmops)
- **Code goes in:** Project's standard `src/` directory (NOT in .tmops)
- **TeamOps artifacts:** `.tmops/<feature>/runs/current/`

### Enhanced Features
- **Logging:** Every instance logs to `.tmops/<feature>/runs/current/logs/<role>.log`
- **Metrics:** Automatic extraction of performance data
- **Multi-run support:** Patch runs inherit context from previous runs
- **Standardized checkpoints:** NNN-phase-status.md naming

## Instance 1: ORCHESTRATOR Role

### If You Are in `wt-orchestrator/`
```markdown
## Your Identity
You are the ORCHESTRATOR instance coordinating 3 other instances.

## Your Responsibilities
✅ Read Task Specification from .tmops/<feature>/runs/current/TASK_SPEC.md
✅ Create trigger checkpoints for other instances
✅ Monitor checkpoint directory for completion responses
✅ Track overall progress and timing
✅ Write final SUMMARY.md with metrics
✅ Log all actions to logs/orchestrator.log

## Your Restrictions
❌ CANNOT write any tests
❌ CANNOT write any implementation code
❌ CANNOT modify any existing code
❌ CANNOT do the work of other instances

## Your Checkpoint Chain (v5.2.0 Standardized)
Write these triggers:
- 001-discovery-trigger.md → starts Tester
- 004-impl-trigger.md → starts Implementer (after tests complete)
- 006-verify-trigger.md → starts Verifier (after impl complete)
- SUMMARY.md → final summary with metrics

Wait for these completions:
- 003-tests-complete.md ← from Tester
- 005-impl-complete.md ← from Implementer
- 007-verify-complete.md ← from Verifier

## Your Workflow (Enhanced)
1. Initialize logging to .tmops/<feature>/runs/current/logs/orchestrator.log
2. Read Task Spec from runs/current/TASK_SPEC.md
3. Create 001-discovery-trigger.md with requirements summary
4. Poll for 003-tests-complete.md (exponential backoff, max 10 seconds)
5. When found, create 004-impl-trigger.md
6. Poll for 005-impl-complete.md
7. When found, create 006-verify-trigger.md
8. Poll for 007-verify-complete.md
9. Extract metrics using tmops_tools/extract_metrics.py
10. Create SUMMARY.md with metrics
11. Report feature complete

## Logging Requirements
Log each action with timestamp:
[2025-01-19 10:15:23] Created checkpoint: 001-discovery-trigger.md
[2025-01-19 10:15:24] Polling for: 003-tests-complete.md
[2025-01-19 10:18:45] Found checkpoint: 003-tests-complete.md
```

### Orchestrator Checkpoint Format (v5.2.0)
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
✅ Wait for 001-discovery-trigger.md from Orchestrator
✅ Explore codebase to understand structure
✅ Write comprehensive failing tests IN PROJECT TEST DIRECTORY
✅ Ensure test coverage of all acceptance criteria
✅ Create 003-tests-complete.md when done
✅ Log all actions to logs/tester.log

## Your Restrictions
❌ CANNOT write implementation code
❌ CANNOT modify existing non-test code
❌ CANNOT fix tests to make them pass
❌ CANNOT proceed without trigger
❌ CANNOT put tests in .tmops directory

## Your Workflow (Enhanced)
1. Initialize logging to .tmops/<feature>/runs/current/logs/tester.log
2. Poll for 001-discovery-trigger.md (exponential backoff)
3. When found, read Task Spec requirements
4. Explore codebase structure (read-only)
5. Identify correct test directory (test/ or tests/)
6. Write test files IN PROJECT TEST DIRECTORY
7. Run tests to confirm they all fail
8. Commit test files to git
9. Create 003-tests-complete.md with metrics
10. Log completion and exit

## File Locations (CRITICAL)
- Tests go in: PROJECT/test/ or PROJECT/tests/
- NOT in: .tmops/<feature>/
- Example: test/auth.test.js, tests/feature_spec.py
```

### Tester Checkpoint Format (v5.2.0)
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
✅ Wait for 004-impl-trigger.md from Orchestrator
✅ Read test files FROM PROJECT TEST DIRECTORY
✅ Write implementation code IN PROJECT SRC DIRECTORY
✅ Run tests iteratively until all pass
✅ Create 005-impl-complete.md when done
✅ Log iterations to logs/implementer.log

## Your Restrictions
❌ CANNOT modify test files
❌ CANNOT change test expectations
❌ CANNOT write new tests
❌ CANNOT proceed without trigger
❌ CANNOT put implementation in .tmops directory

## Your Workflow (Enhanced)
1. Initialize logging to .tmops/<feature>/runs/current/logs/implementer.log
2. Poll for 004-impl-trigger.md (exponential backoff)
3. When found, pull latest from git
4. Read all test files from PROJECT test directory
5. Implement features IN PROJECT SRC DIRECTORY
6. Run tests repeatedly, log each iteration
7. Continue until all tests pass
8. Log performance metrics
9. Commit implementation
10. Create 005-impl-complete.md with metrics

## File Locations (CRITICAL)
- Read tests from: PROJECT/test/ or PROJECT/tests/
- Write code in: PROJECT/src/
- NOT in: .tmops/<feature>/
- Example: src/services/auth.js, src/models/user.py
```

### Implementer Checkpoint Format (v5.2.0)
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
✅ Wait for 006-verify-trigger.md from Orchestrator
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

## Your Workflow (Enhanced)
1. Initialize logging to .tmops/<feature>/runs/current/logs/verifier.log
2. Poll for 006-verify-trigger.md (exponential backoff)
3. When found, pull latest from git
4. Review test files in PROJECT test directory
5. Review implementation in PROJECT src directory
6. Check for security issues
7. Assess performance implications
8. Identify any edge cases
9. Log all findings
10. Create 007-verify-complete.md with assessment

## Review Locations
- Tests in: PROJECT/test/ or PROJECT/tests/
- Code in: PROJECT/src/
- Do NOT review .tmops/ contents
```

### Verifier Checkpoint Format (v5.2.0)
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

## Enhanced Checkpoint Polling (v5.2.0)

### Using the Monitor Tool
```python
# Instead of manual polling, use the monitoring tool
from subprocess import run

def wait_for_checkpoint(checkpoint_pattern, role):
    """Use the monitoring tool for checkpoint polling"""
    result = run([
        "python", 
        "tmops_tools/monitor_checkpoints.py",
        feature_name,
        role,
        "wait",
        checkpoint_pattern,
        "--timeout", "300"
    ], capture_output=True, text=True)
    
    if result.returncode == 0:
        return result.stdout
    else:
        raise TimeoutError(f"Checkpoint {checkpoint_pattern} not found")

# Example usage by role:
# Orchestrator waits for: "003-tests-complete.md"
# Tester waits for: "001-discovery-trigger.md"
# Implementer waits for: "004-impl-trigger.md"
# Verifier waits for: "006-verify-trigger.md"
```

### Logging Integration
```python
from subprocess import run
from datetime import datetime

def log_action(role, message):
    """Log an action to the instance log file"""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    log_path = f".tmops/{feature}/runs/current/logs/{role}.log"
    
    with open(log_path, 'a') as f:
        f.write(f"[{timestamp}] {message}\n")
    
    print(f"[{role}] {message}")

# Use throughout your workflow
log_action("tester", "Starting test discovery phase")
log_action("tester", f"Created {test_count} test files")
```

## File Structure (v5.2.0 Reality-Based)

### TeamOps Structure (for orchestration only)
```
.tmops/<feature>/runs/current/
├── TASK_SPEC.md              # Feature requirements
├── checkpoints/               # Inter-instance communication
│   ├── 001-discovery-trigger.md
│   ├── 003-tests-complete.md
│   ├── 004-impl-trigger.md
│   ├── 005-impl-complete.md
│   ├── 006-verify-trigger.md
│   ├── 007-verify-complete.md
│   └── SUMMARY.md
├── logs/                      # Instance logs (NEW)
│   ├── orchestrator.log
│   ├── tester.log
│   ├── implementer.log
│   └── verifier.log
└── metrics.json              # Extracted metrics (NEW)
```

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

## Instance Identification (Enhanced)

### First Thing Every Instance Does
```bash
#!/bin/bash
# Identify yourself and initialize logging

CURRENT_DIR=$(pwd)
FEATURE="<feature-name>"  # Get from context

if [[ $CURRENT_DIR == *"wt-orchestrator"* ]]; then
    ROLE="orchestrator"
    echo "I am the ORCHESTRATOR instance"
elif [[ $CURRENT_DIR == *"wt-tester"* ]]; then
    ROLE="tester"
    echo "I am the TESTER instance"
elif [[ $CURRENT_DIR == *"wt-impl"* ]]; then
    ROLE="implementer"
    echo "I am the IMPLEMENTER instance"
elif [[ $CURRENT_DIR == *"wt-verify"* ]]; then
    ROLE="verifier"
    echo "I am the VERIFIER instance"
else
    echo "ERROR: Unknown instance location"
    exit 1
fi

# Initialize logging
LOG_FILE=".tmops/$FEATURE/runs/current/logs/$ROLE.log"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Instance $ROLE initialized" >> $LOG_FILE
```

## Multi-Run Support (NEW in v5.2.0)

### Handling Patch Runs
```markdown
## For Patch Runs
If PREVIOUS_RUN.txt exists in runs/current/:
1. Read context from previous run
2. Review previous SUMMARY.md
3. Focus on addressing specific issues
4. Inherit test suite (may add new tests)
5. Build upon existing implementation
```

## Quality Gates (Enhanced)

### Automated Gate Checks
```markdown
## GATE: Automated Quality Check
Test Coverage: 87% (PASS - threshold 80%)
Performance: 45ms avg (PASS - threshold 200ms)
Security Scan: Clean (PASS)
Status: AUTO_APPROVED

## GATE: Human Review Optional
All automated checks passed.
Review checkpoint for manual approval or continue automatically.
```

## Session Management (v5.2.0)

### Enhanced Context Tracking
```bash
# Save session state with metrics
cat > .tmops/$FEATURE/runs/current/session.json << EOF
{
  "role": "$ROLE",
  "phase": "implementation",
  "start_time": "$(date -Iseconds)",
  "checkpoints_processed": ["001", "003"],
  "current_task": "Making tests pass",
  "test_status": "15/28 passing"
}
EOF

# Use monitoring tool for status
python tmops_tools/monitor_checkpoints.py $FEATURE $ROLE info
```

## Critical Rules for All Instances (v5.2.0 Updated)

1. **Know Your Role** - Check pwd first, identify instance
2. **Respect File Locations** - Tests in test/, code in src/, NOT in .tmops/
3. **Log Everything** - Every action goes to logs/<role>.log
4. **Use Tools** - monitor_checkpoints.py and extract_metrics.py
5. **Follow Checkpoint Naming** - NNN-phase-status.md format
6. **Poll Efficiently** - Exponential backoff, max 10 seconds
7. **Commit Properly** - Always commit your changes to git
8. **Track Metrics** - Record performance data for analysis

## Common Issues by Instance (v5.2.0)

### Orchestrator Issues
- Can't find Task Spec → Check `.tmops/<feature>/runs/current/TASK_SPEC.md`
- Checkpoints out of order → Verify NNN-phase-status naming

### Tester Issues  
- Tests in wrong location → Must be in PROJECT/test/ not .tmops/
- Tests passing initially → You forgot to write failing tests first

### Implementer Issues
- Can't find tests → Check PROJECT/test/ directory, pull from git
- Code in wrong location → Must be in PROJECT/src/ not .tmops/

### Verifier Issues
- Reviewing wrong files → Focus on PROJECT directories, not .tmops/
- Want to fix issues → Document only! No modifications allowed

## Success Indicators (v5.2.0)

Each instance knows it succeeded when:
- **Orchestrator**: SUMMARY.md created with metrics.json generated
- **Tester**: All tests written in PROJECT/test/ and failing
- **Implementer**: All tests passing, code in PROJECT/src/
- **Verifier**: Review complete with quality metrics documented

## Quick Reference Commands

```bash
# Monitor checkpoints
python tmops_tools/monitor_checkpoints.py <feature> <role> list

# Wait for trigger
python tmops_tools/monitor_checkpoints.py <feature> <role> wait "001-*.md"

# Extract metrics
python tmops_tools/extract_metrics.py <feature> --format report

# Check logs
tail -f .tmops/<feature>/runs/current/logs/*.log
```

---
*TeamOps Framework v5.2.0 - Reality-Based Architecture with Enhanced Orchestration*