# TeamOps Orchestration Protocol - 4-Instance Architecture
**Version:** 5.0.0  
**Purpose:** Definitive guide for 4 independent Claude Code instances with checkpoint-based communication
**Core Principle:** Each instance is autonomous and communicates only through filesystem checkpoints

## System Overview

### The Complete Architecture
```
┌─────────────────────────────────────────┐
│         Claude.ai Chat                   │
│   (Strategic Planning & Task Specs)      │
└─────────────────────────────────────────┘
                    │
                    ▼
        Creates TASK_SPEC.md
                    │
    ┌───────────────┴───────────────┐
    │                               │
    ▼                               ▼
┌─────────────────────────────────────────┐
│        4 Claude Code Instances          │
│                                         │
│  ┌──────────────┐  ┌──────────────┐   │
│  │ Orchestrator │  │    Tester    │   │
│  │  Terminal 1  │  │  Terminal 2  │   │
│  └──────────────┘  └──────────────┘   │
│                                         │
│  ┌──────────────┐  ┌──────────────┐   │
│  │ Implementer  │  │   Verifier   │   │
│  │  Terminal 3  │  │  Terminal 4  │   │
│  └──────────────┘  └──────────────┘   │
│                                         │
│      Communication: Checkpoints        │
└─────────────────────────────────────────┘
```

## Communication Protocol

### Checkpoint Flow Diagram
```
Orchestrator          Tester           Implementer        Verifier
     │                  │                   │                │
     ├──001-discovery──►│                   │                │
     │                  │                   │                │
     │◄─003-tests-done──┤                   │                │
     │                  │                   │                │
     ├──004-impl-go─────┼──────────────────►│                │
     │                  │                   │                │
     │◄─────────────────┼──005-impl-done────┤                │
     │                  │                   │                │
     ├──006-verify-go───┼───────────────────┼───────────────►│
     │                  │                   │                │
     │◄─────────────────┼───────────────────┼─007-verified───┤
     │                  │                   │                │
     └─SUMMARY.md       │                   │                │
```

### Checkpoint Naming Convention
```
NNN-action-status.md
│   │      │
│   │      └── Status: ready, complete, ack, go
│   └────────── Action: discovery, tests, impl, verify
└────────────── Sequence: 001-007, then SUMMARY
```

## The 4 Instances Defined

### 1. Orchestrator Instance (wt-orchestrator)
**Purpose:** Workflow coordination and progress tracking

**Capabilities:**
- Read Task Specification
- Create trigger checkpoints
- Monitor for completion checkpoints
- Track timing and metrics
- Write final summary

**Restrictions:**
- NO test writing
- NO implementation
- NO code modification
- NO direct instance control

**Checkpoints:**
- Creates: 001, 002, 004, 006, SUMMARY
- Reads: 003, 005, 007

### 2. Tester Instance (wt-tester)
**Purpose:** Test creation and discovery

**Capabilities:**
- Explore codebase (read-only)
- Write comprehensive tests
- Verify tests fail initially
- Document test strategy

**Restrictions:**
- NO implementation code
- NO fixing tests to pass
- NO modifying existing code

**Checkpoints:**
- Reads: 001
- Creates: 003

### 3. Implementer Instance (wt-impl)
**Purpose:** Feature implementation

**Capabilities:**
- Read test requirements
- Write feature code
- Fix bugs to pass tests
- Refactor as needed

**Restrictions:**
- NO test modification
- NO test creation
- NO changing test expectations

**Checkpoints:**
- Reads: 004
- Creates: 005

### 4. Verifier Instance (wt-verify)
**Purpose:** Quality assurance

**Capabilities:**
- Review all code
- Identify issues
- Check edge cases
- Assess quality

**Restrictions:**
- NO code modification
- NO fixes or patches
- Read-only analysis

**Checkpoints:**
- Reads: 006
- Creates: 007

## Implementation Details

### Directory Structure
```
project-root/
├── .tmops/
│   └── <feature>/
│       ├── TASK_SPEC.md           # Created by Claude Chat
│       └── checkpoints/            # Inter-instance communication
│           ├── 001-discovery.md
│           ├── 003-tests-complete.md
│           ├── 004-impl-ready.md
│           ├── 005-impl-complete.md
│           ├── 006-verify-ready.md
│           ├── 007-verify-complete.md
│           └── SUMMARY.md
├── wt-orchestrator/               # Orchestrator worktree
├── wt-tester/                     # Tester worktree
├── wt-impl/                       # Implementer worktree
└── wt-verify/                     # Verifier worktree
```

### Polling Mechanism
Each instance polls for its trigger checkpoint:
```python
# Standard polling interval: 10 seconds
POLL_INTERVAL = 10

def wait_for_checkpoint(checkpoint_name):
    while not exists(f".tmops/{feature}/checkpoints/{checkpoint_name}"):
        print(f"[{timestamp()}] Waiting for {checkpoint_name}...")
        sleep(POLL_INTERVAL)
    return read_checkpoint(checkpoint_name)
```

### Checkpoint File Format
```markdown
# Checkpoint: [Action] [Status]
**Number:** NNN
**From:** [Instance Name]
**To:** [Target Instance(s)]
**Timestamp:** YYYY-MM-DD HH:MM:SS
**Elapsed:** X minutes

## Status
[Brief status description]

## Work Completed
- [Item 1]
- [Item 2]

## Metrics
- [Relevant metrics]

## Next Action
[What the next instance should do]

## Gate
[No gate | Human review required]
```

## Workflow Execution

### Phase 1: Initialization
1. Human creates Task Spec via Claude Chat
2. Human sets up 4 worktrees
3. Human launches 4 Claude Code instances
4. Each instance identifies its role via pwd

### Phase 2: Discovery & Testing
1. Orchestrator creates 001-discovery.md
2. Tester polls, finds trigger, begins work
3. Tester explores, writes tests, creates 003-tests-complete.md
4. Orchestrator detects completion, creates 004-impl-ready.md

### Phase 3: Implementation
1. Implementer polls, finds trigger, begins work
2. Implementer reads tests, implements features
3. Implementer runs tests until all pass
4. Implementer creates 005-impl-complete.md

### Phase 4: Verification
1. Orchestrator detects completion, creates 006-verify-ready.md
2. Verifier polls, finds trigger, begins review
3. Verifier analyzes quality, documents findings
4. Verifier creates 007-verify-complete.md

### Phase 5: Completion
1. Orchestrator detects all phases complete
2. Orchestrator writes SUMMARY.md
3. Human reviews summary
4. Feature ready for merge

## Quality Gates

### Mandatory Review Points
1. **Post-Testing Gate** (after 003)
   - Review test coverage
   - Verify acceptance criteria
   - Check edge cases

2. **Post-Implementation Gate** (after 005)
   - Confirm all tests pass
   - Review implementation approach
   - Check performance

3. **Final Gate** (after SUMMARY)
   - Overall quality assessment
   - Security review
   - Merge approval

### Gate Implementation
```markdown
## GATE: Human Review Required
Type: [Test Coverage | Implementation | Final]
Status: AWAITING_APPROVAL

Review Checklist:
- [ ] Criteria 1 met
- [ ] Criteria 2 met
- [ ] No blockers

To approve: Add "APPROVED: [timestamp]" below
```

## Instance Initialization Prompts

### Complete Prompt Set
Each instance needs exactly this prompt when starting:

#### Orchestrator (Terminal 1)
```
You are the ORCHESTRATOR instance in wt-orchestrator.
Read .tmops/<feature>/TASK_SPEC.md and coordinate workflow.
Create checkpoints: 001, 004, 006, SUMMARY.
Monitor for: 003, 005, 007.
Poll every 10 seconds. Never implement or test.
```

#### Tester (Terminal 2)
```
You are the TESTER instance in wt-tester.
Wait for 001-discovery.md trigger.
Write failing tests covering all acceptance criteria.
Create 003-tests-complete.md when done.
Poll every 10 seconds. Never implement.
```

#### Implementer (Terminal 3)
```
You are the IMPLEMENTER instance in wt-impl.
Wait for 004-impl-ready.md trigger.
Make all tests pass without modifying them.
Create 005-impl-complete.md when done.
Poll every 10 seconds. Never modify tests.
```

#### Verifier (Terminal 4)
```
You are the VERIFIER instance in wt-verify.
Wait for 006-verify-ready.md trigger.
Review all code quality, no modifications.
Create 007-verify-complete.md when done.
Poll every 10 seconds. Read-only analysis.
```

## Timing Guidelines

### Expected Phase Durations
- Discovery & Test Writing: 10-15 minutes
- Implementation: 15-20 minutes
- Verification: 5-10 minutes
- Total Feature Time: 30-45 minutes

### Polling Timeout
- If no trigger after 5 minutes, alert human
- If no response after 10 minutes, check instance status

## Error Recovery

### Instance Failure Recovery
```bash
# If instance crashes
cd wt-[role]
claude

# Reidentify role
"I am the [ROLE] instance. Checking last checkpoint..."

# Resume from last checkpoint
cat .tmops/<feature>/checkpoints/*.md | tail -1
```

### Checkpoint Recovery
```bash
# If checkpoint corrupted
mv checkpoint.md checkpoint.backup
# Recreate from instance state

# If checkpoint missing
# Check git history
git log --oneline .tmops/
```

## Success Metrics

### Per-Feature Tracking
```markdown
## Feature: <name>
- Checkpoints created: 8/8
- Instances coordinated: 4/4
- Time elapsed: XX minutes
- Gates passed: 3/3
- Tests: XX/XX passing
- Coverage: XX%
- Human interventions: X
```

## Critical Rules

1. **Four Instances Always** - Never combine roles
2. **Checkpoints Only** - No other communication
3. **Polling Discipline** - 10 seconds, no faster
4. **Role Boundaries** - Never cross them
5. **Sequential Flow** - Follow the checkpoint chain
6. **Git Synchronization** - Commit and pull appropriately
7. **Error Visibility** - Report issues immediately

## Troubleshooting Matrix

| Problem | Check | Solution |
|---------|-------|----------|
| Instance not starting | pwd correct? | cd to correct wt-* directory |
| No trigger checkpoint | Path correct? | Check .tmops/<feature>/checkpoints/ |
| Tests not found | Git synced? | git pull in implementer |
| Can't modify code | Role correct? | Verifier is read-only |
| Checkpoint missing | Permissions? | Check file permissions |
| Instance confused | Role clear? | Restart with role prompt |

## Final Checklist

Before starting any feature:
- [ ] Task Spec created and saved
- [ ] 4 worktrees created (wt-orchestrator, wt-tester, wt-impl, wt-verify)
- [ ] 4 terminals ready
- [ ] Each instance knows its role
- [ ] Checkpoint directory exists
- [ ] Git branch created
- [ ] All instances on same branch

This protocol is the definitive guide. Any conflicts with other documents should defer to this version.