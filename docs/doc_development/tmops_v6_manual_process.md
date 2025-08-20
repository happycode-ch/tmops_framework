# TeamOps Framework v6: Manual Orchestration Process
**Version:** 6.0.0-manual  
**Created:** 2025-08-20  
**Purpose:** Human-coordinated orchestration between 4 Claude Code instances

## Overview

TeamOps v6 Manual Process introduces a human-in-the-loop orchestration model where YOU act as the communication bridge between the 4 specialized Claude Code instances. This eliminates automated checkpoint polling in favor of explicit human coordination, providing better control, visibility, and reliability.

### Key Difference from v5
- **v5**: Instances automatically poll for checkpoints (can timeout, miss files)
- **v6**: Human manually relays completion status between instances (100% reliable)

### Benefits of Manual Orchestration
✅ **No timeout issues** - Work proceeds at natural pace  
✅ **Clear confirmations** - Explicit acknowledgment at each phase  
✅ **Better debugging** - See exactly where issues occur  
✅ **Pause capability** - Stop between any phases  
✅ **Quality control** - Review work before proceeding  

## Architecture

```
┌─────────────────────────────────────────┐
│              YOU (Human)                 │
│         Central Coordinator              │
└─────────────┬───────────────────┬────────┘
              │                   │
    ┌─────────▼──────┐   ┌───────▼────────┐
    │  Orchestrator  │   │     Tester     │
    │   Terminal 1   │   │   Terminal 2   │
    └────────────────┘   └────────────────┘
              │                   │
    ┌─────────▼──────┐   ┌───────▼────────┐
    │  Implementer   │   │    Verifier    │
    │   Terminal 3   │   │   Terminal 4   │
    └────────────────┘   └────────────────┘
```

## Communication Protocol

### Instance States
Each instance has three states:
1. **WAITING** - Awaiting your instruction to begin
2. **WORKING** - Actively performing their role
3. **COMPLETE** - Finished and waiting for acknowledgment

### Communication Format

#### Instance → Human
```
[ROLE] STATUS: Message
Example: [TESTER] COMPLETE: All tests written and failing. Checkpoint 003-tests-complete.md created.
```

#### Human → Instance
```
[INSTRUCTION]: Message
Example: [BEGIN]: Start test writing phase
Example: [CONFIRMED]: Tester has completed, prepare implementation phase
```

## Modified Instance Prompts

### ORCHESTRATOR Prompt (Terminal 1)
```markdown
You are the ORCHESTRATOR instance for TeamOps v6 Manual Process.

IMPORTANT: This is a MANUAL orchestration. You will:
1. Create trigger checkpoints when instructed
2. Wait for the HUMAN to confirm phase completions
3. NOT poll for checkpoints automatically

Your workflow:
1. Wait for human instruction: "[BEGIN]: Start orchestration"
2. Read .tmops/<feature>/runs/current/TASK_SPEC.md
3. Create 001-discovery-trigger.md
4. Report: "[ORCHESTRATOR] READY: Tester can begin. Trigger 001 created."
5. WAIT for human: "[CONFIRMED]: Tester has completed"
6. Create 004-impl-trigger.md
7. Report: "[ORCHESTRATOR] READY: Implementer can begin. Trigger 004 created."
8. WAIT for human: "[CONFIRMED]: Implementer has completed"
9. Create 006-verify-trigger.md
10. Report: "[ORCHESTRATOR] READY: Verifier can begin. Trigger 006 created."
11. WAIT for human: "[CONFIRMED]: Verifier has completed"
12. Extract metrics and create SUMMARY.md
13. Report: "[ORCHESTRATOR] COMPLETE: Feature orchestration finished. SUMMARY.md created."

Always wait for explicit human confirmation before proceeding to next phase.
Log all actions but do NOT poll for checkpoints.
```

### TESTER Prompt (Terminal 2)
```markdown
You are the TESTER instance for TeamOps v6 Manual Process.

IMPORTANT: This is a MANUAL orchestration. You will:
1. Wait for human instruction to begin
2. Work independently once started
3. Report completion to the HUMAN (not to checkpoints)

Your workflow:
1. Wait for human instruction: "[BEGIN]: Start test writing"
2. Check that 001-discovery-trigger.md exists (don't poll, just verify once)
3. Read requirements from TASK_SPEC.md
4. Explore codebase structure
5. Write comprehensive failing tests in PROJECT/test/ directory
6. Run tests to confirm they fail
7. Commit test files to git
8. Create 003-tests-complete.md checkpoint
9. Report: "[TESTER] COMPLETE: 18 tests written, all failing. Checkpoint 003 created."
10. STOP and wait - do not proceed further

You will NOT monitor for other checkpoints or communicate with other instances.
Your only communication is with the human coordinator.
```

### IMPLEMENTER Prompt (Terminal 3)
```markdown
You are the IMPLEMENTER instance for TeamOps v6 Manual Process.

IMPORTANT: This is a MANUAL orchestration. You will:
1. Wait for human instruction to begin
2. Work independently once started
3. Report completion to the HUMAN

Your workflow:
1. Wait for human instruction: "[BEGIN]: Start implementation"
2. Check that 004-impl-trigger.md exists (verify once)
3. Pull latest code to get test files
4. Read test requirements from PROJECT/test/ directory
5. Write implementation in PROJECT/src/ directory
6. Run tests iteratively until all pass
7. Commit implementation to git
8. Create 005-impl-complete.md checkpoint
9. Report: "[IMPLEMENTER] COMPLETE: All tests passing. Checkpoint 005 created."
10. STOP and wait

You will NOT poll for checkpoints or communicate with other instances.
Your only communication is with the human coordinator.
```

### VERIFIER Prompt (Terminal 4)
```markdown
You are the VERIFIER instance for TeamOps v6 Manual Process.

IMPORTANT: This is a MANUAL orchestration. You will:
1. Wait for human instruction to begin
2. Perform read-only review once started
3. Report completion to the HUMAN

Your workflow:
1. Wait for human instruction: "[BEGIN]: Start verification"
2. Check that 006-verify-trigger.md exists (verify once)
3. Pull latest code to review all changes
4. Review test quality in PROJECT/test/
5. Review implementation quality in PROJECT/src/
6. Assess security, performance, and edge cases
7. Create 007-verify-complete.md with findings
8. Report: "[VERIFIER] COMPLETE: Review finished. Quality score 9.5/10. Checkpoint 007 created."
9. STOP and wait

You will NOT modify any code or poll for checkpoints.
Your only communication is with the human coordinator.
```

## Step-by-Step Workflow

### Phase 1: Initialization
```
1. Human opens 4 terminals
2. Human pastes prompts into each Claude Code instance
3. All instances report ready:
   [ORCHESTRATOR] WAITING: Ready for instructions
   [TESTER] WAITING: Ready for instructions
   [IMPLEMENTER] WAITING: Ready for instructions
   [VERIFIER] WAITING: Ready for instructions
```

### Phase 2: Orchestration Start
```
Human → Orchestrator: [BEGIN]: Start orchestration for feature "hello-api"
Orchestrator: [ORCHESTRATOR] WORKING: Reading TASK_SPEC.md...
Orchestrator: [ORCHESTRATOR] READY: Tester can begin. Trigger 001 created.
```

### Phase 3: Test Writing
```
Human → Tester: [BEGIN]: Start test writing
Tester: [TESTER] WORKING: Writing tests...
(... 10-15 minutes pass ...)
Tester: [TESTER] COMPLETE: 18 tests written, all failing. Checkpoint 003 created.
```

### Phase 4: Test Completion Relay
```
Human → Orchestrator: [CONFIRMED]: Tester has completed
Orchestrator: [ORCHESTRATOR] READY: Implementer can begin. Trigger 004 created.
```

### Phase 5: Implementation
```
Human → Implementer: [BEGIN]: Start implementation
Implementer: [IMPLEMENTER] WORKING: Making tests pass...
(... 5-10 minutes pass ...)
Implementer: [IMPLEMENTER] COMPLETE: All tests passing. Checkpoint 005 created.
```

### Phase 6: Implementation Completion Relay
```
Human → Orchestrator: [CONFIRMED]: Implementer has completed
Orchestrator: [ORCHESTRATOR] READY: Verifier can begin. Trigger 006 created.
```

### Phase 7: Verification
```
Human → Verifier: [BEGIN]: Start verification
Verifier: [VERIFIER] WORKING: Reviewing code quality...
(... 5-10 minutes pass ...)
Verifier: [VERIFIER] COMPLETE: Review finished. Quality score 9.5/10. Checkpoint 007 created.
```

### Phase 8: Final Summary
```
Human → Orchestrator: [CONFIRMED]: Verifier has completed
Orchestrator: [ORCHESTRATOR] WORKING: Generating summary and metrics...
Orchestrator: [ORCHESTRATOR] COMPLETE: Feature orchestration finished. SUMMARY.md created.
```

## Quick Reference Card

### What Each Instance Says

| Instance | When Waiting | When Working | When Complete |
|----------|--------------|--------------|---------------|
| Orchestrator | `[ORCHESTRATOR] WAITING: Ready` | `[ORCHESTRATOR] WORKING: ...` | `[ORCHESTRATOR] READY: X can begin` |
| Tester | `[TESTER] WAITING: Ready` | `[TESTER] WORKING: Writing tests...` | `[TESTER] COMPLETE: Tests written` |
| Implementer | `[IMPLEMENTER] WAITING: Ready` | `[IMPLEMENTER] WORKING: Coding...` | `[IMPLEMENTER] COMPLETE: Tests pass` |
| Verifier | `[VERIFIER] WAITING: Ready` | `[VERIFIER] WORKING: Reviewing...` | `[VERIFIER] COMPLETE: Score X/10` |

### What You Tell Each Instance

| To Instance | To Start | Example |
|-------------|----------|---------|
| Orchestrator | `[BEGIN]: Start orchestration` | When ready to begin feature |
| Orchestrator | `[CONFIRMED]: X has completed` | After each instance finishes |
| Tester | `[BEGIN]: Start test writing` | After Orchestrator says ready |
| Implementer | `[BEGIN]: Start implementation` | After Orchestrator says ready |
| Verifier | `[BEGIN]: Start verification` | After Orchestrator says ready |

## Advantages Over Automated Process

### 1. **Reliability**
- No missed checkpoints due to timing issues
- No polling timeouts
- 100% confirmation of each phase

### 2. **Flexibility**
- Pause between any phases
- Review work before proceeding
- Adjust approach based on progress

### 3. **Visibility**
- See all communication explicitly
- Know exactly what each instance is doing
- Clear error messages if issues occur

### 4. **Control**
- Decide when to proceed
- Can stop if quality issues detected
- Manual verification of readiness

## Troubleshooting

### Instance Not Responding
**Solution:** Check if waiting for your input. Look for `[WAITING]` status.

### Checkpoint Not Created
**Solution:** Ask instance to report status. They should tell you if checkpoint was created.

### Wrong Phase Order
**Solution:** Orchestrator maintains phase order. Always confirm with Orchestrator before proceeding.

### Instance Confused About Role
**Solution:** Remind instance of their role and current phase. Reference this document.

## Migration from v5

### Key Changes
1. Remove all polling code from prompts
2. Add explicit wait states
3. Change from checkpoint detection to human confirmation
4. Add status reporting messages

### Checkpoint Files Still Created
- Checkpoints are still created for documentation
- But NOT used for inter-instance communication
- Human relays all status updates

## Example Complete Session

```
[10:00] Human: Launches 4 instances with v6 prompts
[10:01] All: [X] WAITING: Ready for instructions

[10:02] Human → Orchestrator: [BEGIN]: Start orchestration for "user-auth"
[10:03] Orchestrator: [ORCHESTRATOR] READY: Tester can begin. Trigger 001 created.

[10:04] Human → Tester: [BEGIN]: Start test writing
[10:05] Tester: [TESTER] WORKING: Writing tests...
[10:18] Tester: [TESTER] COMPLETE: 25 tests written, all failing. Checkpoint 003 created.

[10:19] Human → Orchestrator: [CONFIRMED]: Tester has completed
[10:20] Orchestrator: [ORCHESTRATOR] READY: Implementer can begin. Trigger 004 created.

[10:21] Human → Implementer: [BEGIN]: Start implementation
[10:22] Implementer: [IMPLEMENTER] WORKING: Making tests pass...
[10:28] Implementer: [IMPLEMENTER] COMPLETE: All tests passing. Checkpoint 005 created.

[10:29] Human → Orchestrator: [CONFIRMED]: Implementer has completed
[10:30] Orchestrator: [ORCHESTRATOR] READY: Verifier can begin. Trigger 006 created.

[10:31] Human → Verifier: [BEGIN]: Start verification
[10:32] Verifier: [VERIFIER] WORKING: Reviewing code quality...
[10:38] Verifier: [VERIFIER] COMPLETE: Review finished. Quality score 9/10. Checkpoint 007 created.

[10:39] Human → Orchestrator: [CONFIRMED]: Verifier has completed
[10:40] Orchestrator: [ORCHESTRATOR] COMPLETE: Feature orchestration finished. SUMMARY.md created.

[10:41] Human: Feature complete! Total time: 41 minutes
```

## Summary

TeamOps v6 Manual Process provides a more reliable, controllable, and transparent orchestration method by placing the human at the center of instance coordination. This approach eliminates the complexity and potential failure points of automated checkpoint polling while maintaining all the benefits of specialized instance roles and checkpoint documentation.

The manual process is particularly suitable for:
- Critical features requiring oversight
- Learning the TeamOps system
- Debugging and development
- Situations where timing is unpredictable
- Teams new to the framework

---
*TeamOps Framework v6.0.0-manual - Human-Orchestrated Multi-Instance Development*