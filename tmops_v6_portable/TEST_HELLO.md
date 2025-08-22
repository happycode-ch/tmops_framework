# TeamOps v6 - Hello World Test Example

This document provides a complete, copy-paste example of using TeamOps v6 to implement a simple "hello-world" feature. Follow this exactly to verify your installation works.

## Prerequisites

1. TeamOps v6 installed in your project (see `INSTALL.sh`)
2. Project has `src/` and `test/` (or `tests/`) directories
3. 4 Claude Code CLI instances available

## Step 1: Initialize the Feature

```bash
./tmops_tools/init_feature_v6.sh hello-world initial
```

This creates:
- `.tmops/hello-world/runs/001-initial/` directory structure
- 4 git worktrees: `wt-orchestrator`, `wt-tester`, `wt-impl`, `wt-verify`
- Feature branch: `feature/hello-world`

## Step 2: Update Task Specification

Edit `.tmops/hello-world/runs/current/TASK_SPEC.md`:

```markdown
# Task Specification: Hello World API

## Objective
Create a simple "Hello World" API endpoint that returns a greeting message.

## Acceptance Criteria
- [ ] API endpoint accepts a name parameter
- [ ] Returns "Hello, {name}!" when name is provided
- [ ] Returns "Hello, World!" when no name is provided
- [ ] Handles edge cases (empty strings, special characters)

## Technical Requirements
- Function/module in `src/` directory
- Comprehensive test coverage in `test/` directory
- Handle basic input validation

## Constraints
- Keep it simple - this is a test of the TeamOps workflow
- No external dependencies required

## Expected Deliverables
1. Test file: `test/test_hello.py` (or `.js`, `.go`, etc.)
2. Implementation: `src/hello.py` (or appropriate language)
3. All tests passing

## Notes
This is a hello-world test to verify TeamOps v6 works correctly.
```

## Step 3: Launch Claude Code Instances

Open 4 terminals and run:

```bash
# Terminal 1: Orchestrator
cd wt-orchestrator && claude

# Terminal 2: Tester  
cd wt-tester && claude

# Terminal 3: Implementer
cd wt-impl && claude

# Terminal 4: Verifier
cd wt-verify && claude
```

## Step 4: Paste Instructions into Each Instance

Copy the entire content of each file into the corresponding Claude Code instance:

1. **Orchestrator**: Copy all of `instance_instructions/01_orchestrator.md`
2. **Tester**: Copy all of `instance_instructions/02_tester.md`
3. **Implementer**: Copy all of `instance_instructions/03_implementer.md`
4. **Verifier**: Copy all of `instance_instructions/04_verifier.md`

## Step 5: Execute the Workflow

### 5.1 Wait for All Instances to Report Ready

Each should respond with:
- `[ORCHESTRATOR] WAITING: Ready for instructions`
- `[TESTER] WAITING: Ready for instructions`
- `[IMPLEMENTER] WAITING: Ready for instructions`
- `[VERIFIER] WAITING: Ready for instructions`

### 5.2 Start Orchestration

In the **Orchestrator** instance, type:
```
[BEGIN]: Start orchestration for hello-world
```

Orchestrator should:
- Read the TASK_SPEC.md
- Create `001-discovery-trigger.md`
- Respond: `[ORCHESTRATOR] READY: Tester can begin. Trigger 001 created.`

### 5.3 Start Testing Phase

In the **Tester** instance, type:
```
[BEGIN]: Start test writing
```

Tester should:
- Write comprehensive tests for the hello-world feature
- Create tests in your project's test directory
- Ensure all tests fail initially (no implementation yet)
- Create `003-tests-complete.md` checkpoint

### 5.4 Confirm Testing Complete

When Tester finishes, tell the **Orchestrator**:
```
[CONFIRMED]: Tester has completed
```

Orchestrator should:
- Create `004-impl-trigger.md`
- Respond: `[ORCHESTRATOR] READY: Implementer can begin. Trigger 004 created.`

### 5.5 Start Implementation Phase

In the **Implementer** instance, type:
```
[BEGIN]: Start implementation
```

Implementer should:
- Read the test requirements
- Implement the hello-world feature in `src/`
- Make all tests pass
- Create `005-impl-complete.md` checkpoint

### 5.6 Confirm Implementation Complete

When Implementer finishes, tell the **Orchestrator**:
```
[CONFIRMED]: Implementer has completed
```

Orchestrator should:
- Create `006-verify-trigger.md`
- Respond: `[ORCHESTRATOR] READY: Verifier can begin. Trigger 006 created.`

### 5.7 Start Verification Phase

In the **Verifier** instance, type:
```
[BEGIN]: Start verification
```

Verifier should:
- Review the implementation quality
- Test edge cases
- Check for potential issues
- Create `007-verify-complete.md` checkpoint

### 5.8 Complete the Feature

When Verifier finishes, tell the **Orchestrator**:
```
[CONFIRMED]: Verifier has completed
```

Orchestrator should:
- Generate final metrics and summary
- Create `SUMMARY.md`
- Respond: `[ORCHESTRATOR] COMPLETE: Feature orchestration finished.`

## Expected Results

After completion, you should have:

### Files Created
- `test/test_hello.py` (or appropriate language) - Comprehensive tests
- `src/hello.py` (or appropriate language) - Implementation
- `.tmops/hello-world/runs/001-initial/checkpoints/` - All checkpoints
- `.tmops/hello-world/runs/001-initial/SUMMARY.md` - Final report

### Tests Passing
Run your project's test command to verify all tests pass:
```bash
# Python example
python -m pytest test/test_hello.py -v

# JavaScript example  
npm test

# Go example
go test ./test/
```

### Feature Complete
Your hello-world feature should:
- Accept name parameter
- Return "Hello, {name}!" or "Hello, World!"
- Handle edge cases properly
- Have 100% test coverage

## Troubleshooting

### If Something Goes Wrong

1. **Instance not responding**: Re-paste the instruction file
2. **Tests don't fail initially**: Tester should create failing tests first
3. **Implementation doesn't pass tests**: Implementer should read test requirements carefully
4. **Checkpoints not found**: Check `.tmops/hello-world/runs/current/checkpoints/`

### Clean Up and Restart

If you need to start over:
```bash
./tmops_tools/cleanup_feature.sh hello-world
./tmops_tools/init_feature_v6.sh hello-world initial
```

## Success Verification

Your TeamOps v6 installation is working correctly if:

1. ✅ All 4 instances coordinated successfully
2. ✅ Each phase completed and created proper checkpoints  
3. ✅ Tests were written first and initially failed
4. ✅ Implementation made all tests pass
5. ✅ Verification found no critical issues
6. ✅ Final SUMMARY.md was generated with metrics

## What This Tests

This hello-world example verifies:
- **Orchestration**: Manual coordination between instances works
- **Test-Driven Development**: Tests written before implementation
- **Implementation Quality**: Code meets test requirements
- **Verification**: Quality assurance and edge case testing
- **Metrics**: Automated extraction and reporting
- **File Management**: Proper separation of concerns (tests in test/, code in src/)

Congratulations! You now have a working TeamOps v6 installation ready for real features.