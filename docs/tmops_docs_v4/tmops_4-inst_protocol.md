# TeamOps Orchestration Protocol - 4-Instance Architecture
**Version:** 5.0.0  
**Purpose:** Filesystem-based communication for 4 independent Claude Code instances
**Architecture:** Strategic planning in Chat, 4 autonomous Code instances with checkpoint communication

## Core Concept
The TeamOps framework uses 4 independent Claude Code instances that communicate exclusively through checkpoint files. Claude Chat handles strategic planning (Task Specifications), while the 4 Code instances handle all execution autonomously.

## System Architecture

### Strategic Layer (Claude.ai Chat)
```
Responsibilities:
- Create Task Specifications with acceptance criteria
- Review checkpoint summaries
- Approve quality gates
- NO orchestration of instances (Orchestrator instance handles this)
```

### The 4 Claude Code Instances
Each runs in its own terminal with a specific phase responsibility:

1. **Orchestrator Instance** (Terminal 1)
   - Role: Workflow coordinator
   - Directory: `wt-orchestrator`
   - Reads Task Spec, triggers other instances via checkpoints
   - Monitors progress, enforces gates, writes final summary
   - NEVER writes tests or implementation

2. **Tester Instance** (Terminal 2)  
   - Role: Test writing and discovery
   - Directory: `wt-tester`
   - Waits for trigger checkpoint from Orchestrator
   - Creates failing tests based on acceptance criteria
   - NEVER writes implementation code

3. **Implementer Instance** (Terminal 3)
   - Role: Feature implementation
   - Directory: `wt-impl`
   - Waits for trigger checkpoint from Tester
   - Makes tests pass without modifying them
   - NEVER modifies test files

4. **Verifier Instance** (Terminal 4)
   - Role: Quality verification
   - Directory: `wt-verify`
   - Waits for trigger checkpoint from Implementer
   - Reviews code, checks edge cases, validates quality
   - NEVER modifies any code

## Communication Protocol

### Checkpoint File Convention
All instances communicate via standardized checkpoint files:

```
.tmops/<feature>/checkpoints/
├── 001-discovery.md        # Orchestrator → Tester
├── 002-tests-ready.md       # Tester → Orchestrator
├── 003-tests-complete.md    # Tester → Implementer
├── 004-impl-ready.md        # Implementer → Orchestrator
├── 005-impl-complete.md     # Implementer → Verifier
├── 006-verify-ready.md      # Verifier → Orchestrator
├── 007-verify-complete.md   # Verifier → Orchestrator
└── SUMMARY.md              # Final summary from Orchestrator
```

### Checkpoint Format
```markdown
# Checkpoint: [Phase] Complete
**Number:** 003  
**From:** Tester  
**To:** Implementer  
**Timestamp:** 2025-01-15 14:35:22  
**Status:** Ready to proceed

## Work Completed
- [List of completed items]

## Outputs Created
- [Files with paths]

## Metrics
- Tests written: 24
- Coverage: 85%
- [Other relevant metrics]

## Next Instance Action Required
**Implementer**: Read tests at [paths] and implement to make them pass

## Gate Status
[No gate required | Awaiting human approval]
```

## Instance Initialization

### Terminal Setup
```bash
# Terminal 1: Orchestrator
git worktree add wt-orchestrator feature/<feature>
cd wt-orchestrator
claude

# Terminal 2: Tester
git worktree add wt-tester feature/<feature>
cd wt-tester
claude

# Terminal 3: Implementer
git worktree add wt-impl feature/<feature>
cd wt-impl
claude

# Terminal 4: Verifier
git worktree add wt-verify feature/<feature>
cd wt-verify
claude
```

### Instance Prompts

#### Orchestrator Instance
```
You are the Orchestrator instance.
Your role: Coordinate workflow between Tester, Implementer, and Verifier.

1. Read Task Spec at .tmops/<feature>/TASK_SPEC.md
2. Monitor .tmops/<feature>/checkpoints/ for instance updates
3. Write checkpoint files to trigger next phases
4. Track overall progress and timing

Start by creating checkpoint 001-discovery.md to trigger Tester.
```

#### Tester Instance
```
You are the Tester instance.
Your role: Discovery and test writing ONLY.

1. Wait for checkpoint 001-discovery.md
2. Explore codebase (read-only)
3. Write comprehensive failing tests
4. Create checkpoint 003-tests-complete.md for Implementer
5. NEVER write implementation code

Monitor .tmops/<feature>/checkpoints/ for your trigger.
```

#### Implementer Instance
```
You are the Implementer instance.
Your role: Implementation ONLY.

1. Wait for checkpoint 003-tests-complete.md
2. Read test files (do not modify)
3. Implement code to make tests pass
4. Create checkpoint 005-impl-complete.md for Verifier
5. NEVER modify test files

Monitor .tmops/<feature>/checkpoints/ for your trigger.
```

#### Verifier Instance
```
You are the Verifier instance.
Your role: Verification and review ONLY.

1. Wait for checkpoint 005-impl-complete.md
2. Review implementation (read-only)
3. Check for edge cases and quality issues
4. Create checkpoint 007-verify-complete.md for Orchestrator
5. NEVER modify any code

Monitor .tmops/<feature>/checkpoints/ for your trigger.
```

## Workflow Sequence

### Phase Flow
```
1. Human → Claude Chat: Create Task Spec
2. Human → Orchestrator: Initialize with Task Spec
3. Orchestrator → Tester: Trigger via checkpoint-001
4. Tester: Discovery and test writing
5. Tester → Implementer: Trigger via checkpoint-003
6. Implementer: Make tests pass
7. Implementer → Verifier: Trigger via checkpoint-005
8. Verifier: Quality review
9. Verifier → Orchestrator: Complete via checkpoint-007
10. Orchestrator: Create final SUMMARY.md
```

### Checkpoint Monitoring
Each instance polls for its trigger checkpoints:
```bash
# Example for Tester instance
while [ ! -f .tmops/<feature>/checkpoints/001-discovery.md ]; do
  sleep 5
  echo "Waiting for discovery trigger..."
done
echo "Trigger received! Starting test phase..."
```

## Quality Gates

### Human Review Points
Certain checkpoints require human approval:

1. **After Test Writing** (checkpoint-003)
   - Human reviews test coverage
   - Types 'approved' in checkpoint file

2. **After Implementation** (checkpoint-005)
   - Human verifies tests pass
   - Types 'approved' in checkpoint file

3. **Final Approval** (SUMMARY.md)
   - Human reviews complete feature
   - Approves merge to main

### Gate File Format
```markdown
# Gate: Test Coverage Review
**Checkpoint:** 003
**Status:** AWAITING_APPROVAL

## Evidence
- Tests written: 24
- Coverage: 85%
- All acceptance criteria covered: Yes

## Human Action Required
Review tests and add approval:
APPROVED: [timestamp] [initials]
```

## File Organization

### Standard Structure
```
.tmops/<feature>/
├── TASK_SPEC.md              # Created by Claude Chat
├── checkpoints/              # Inter-instance communication
│   ├── 001-discovery.md
│   ├── 002-tests-ready.md
│   ├── 003-tests-complete.md
│   ├── 004-impl-ready.md
│   ├── 005-impl-complete.md
│   ├── 006-verify-ready.md
│   ├── 007-verify-complete.md
│   └── SUMMARY.md
├── outputs/                  # Work artifacts
│   └── 2025-01-15/
│       ├── tests/
│       ├── implementation/
│       └── verification/
└── logs/                     # Instance logs
    ├── orchestrator.log
    ├── tester.log
    ├── implementer.log
    └── verifier.log
```

## Instance Rules

### Orchestrator Rules
- ✅ Read all checkpoints
- ✅ Write trigger checkpoints
- ✅ Track timing and progress
- ❌ Cannot write tests or code
- ❌ Cannot modify implementation

### Tester Rules
- ✅ Write test files
- ✅ Explore codebase (read-only)
- ✅ Create test documentation
- ❌ Cannot write implementation
- ❌ Cannot modify existing code

### Implementer Rules
- ✅ Write feature code
- ✅ Fix bugs to pass tests
- ✅ Refactor implementation
- ❌ Cannot modify test files
- ❌ Cannot change test expectations

### Verifier Rules
- ✅ Review code quality
- ✅ Identify edge cases
- ✅ Suggest improvements
- ❌ Cannot modify any files
- ❌ Cannot write code

## Timing Guidelines

### Phase Durations
- Discovery: 5 minutes
- Test Writing: 10 minutes
- Implementation: 15 minutes
- Verification: 5 minutes
- Total: ~35 minutes per feature

### Checkpoint Polling
- Check every 10 seconds for triggers
- Timeout after 5 minutes of inactivity
- Alert human if instance appears stuck

## Error Recovery

### Instance Failure
If an instance fails:
1. Save current state to recovery checkpoint
2. Restart instance with last valid checkpoint
3. Resume from last successful phase

### Checkpoint Corruption
If checkpoint file is corrupted:
1. Orchestrator recreates from instance logs
2. Requests status from affected instance
3. Rebuilds checkpoint chain

### Deadlock Prevention
- No circular dependencies between instances
- Clear phase progression
- Timeout mechanisms on all waits

## Success Metrics

Track per feature:
- Total checkpoints: [count]
- Phase transitions: [count]
- Human interventions: [count]
- Time per phase: [minutes]
- Instances active: 4/4
- Tests passing: [percentage]
- Code coverage: [percentage]

## Quick Reference

### Instance → Checkpoint Mapping
| Instance | Reads | Writes | Triggers |
|----------|-------|--------|----------|
| Orchestrator | All | 001, 002, 004, 006, SUMMARY | All instances |
| Tester | 001 | 003 | Implementer |
| Implementer | 003 | 005 | Verifier |
| Verifier | 005 | 007 | Orchestrator |

### Checkpoint Naming
- Format: `NNN-phase-status.md`
- NNN: Three-digit sequence number
- Phase: discovery, tests, impl, verify
- Status: ready, complete, gate

### Critical Rules
1. Each instance has ONE role only
2. Checkpoints are the ONLY communication method
3. No instance can modify another's outputs
4. All instances work from same feature branch
5. Orchestrator manages workflow, not implementation