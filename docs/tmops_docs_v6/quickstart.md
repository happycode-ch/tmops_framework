# TeamOps Framework Manual Orchestration Quick Start
**Version:** 6.0.0-manual  
**Time to First Feature:** ~5 minutes setup, 30-60 minutes execution
**Key Change:** Human coordinates instance handoffs (no automated polling)

## What is TeamOps v6 Manual?

TeamOps v6 is a human-coordinated orchestration framework where YOU relay messages between 4 specialized Claude Code instances. This manual approach ensures 100% reliable handoffs with no polling timeouts or missed checkpoints.

## Prerequisites

- Git with worktree support
- Claude.ai account (for planning)
- Claude Code CLI access (4 terminals)
- Unix-like environment (Linux, macOS, or WSL)

## 5-Minute Setup

### Step 1: Clone and Navigate
```bash
git clone git@github.com:happycode-ch/tmops_framework.git
cd tmops_framework/CODE
```

### Step 2: Initialize Your Feature
```bash
# Create your feature with automated setup
./tmops_tools/init_feature.sh my-feature initial

# This creates:
# ✓ Directory structure in .tmops/my-feature/
# ✓ Git worktrees for 4 instances
# ✓ Feature branch: feature/my-feature
# ✓ Task specification template
```

### Step 3: Define Your Task
Edit the generated task specification:
```bash
# Open in your editor
vim .tmops/my-feature/runs/current/TASK_SPEC.md
```

Add your requirements:
```markdown
## Acceptance Criteria
- [ ] User can authenticate with email/password
- [ ] JWT tokens are generated on successful login
- [ ] Tokens expire after 30 minutes
- [ ] Invalid credentials return 401 error
```

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

Paste the appropriate v6 prompt into each instance from `docs/tmops_docs_v6/tmops_claude_code.md`.

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

## Monitoring Progress

### Watch Checkpoints in Real-Time
```bash
# In a new terminal
watch -n 2 'ls -la .tmops/my-feature/runs/current/checkpoints/'
```

### Monitor Logs
```bash
# See what each instance is doing
tail -f .tmops/my-feature/runs/current/logs/*.log
```

### Check Metrics
```bash
# After completion, extract metrics
./tmops_tools/extract_metrics.py my-feature --format report
```

## Understanding the Workflow

### Phase Flow
```
1. Orchestrator reads task → creates trigger for Tester
2. Tester writes failing tests → notifies Orchestrator
3. Orchestrator triggers Implementer
4. Implementer makes tests pass → notifies Orchestrator
5. Orchestrator triggers Verifier
6. Verifier reviews quality → notifies Orchestrator
7. Orchestrator creates final summary with metrics
```

### Where Files Go
- **Tests:** `test/` or `tests/` in your project
- **Code:** `src/` in your project
- **TeamOps artifacts:** `.tmops/<feature>/`
- **Logs:** `.tmops/<feature>/runs/current/logs/`

## Common Commands Reference

### Feature Management
```bash
# Start new feature
./tmops_tools/init_feature.sh feature-name initial

# Create patch for existing feature
./tmops_tools/init_feature.sh feature-name patch

# Check feature status
ls -la .tmops/feature-name/runs/current/checkpoints/
```

### Monitoring (v6 Manual)
```bash
# Watch specific instance log
tail -f .tmops/feature-name/runs/current/logs/tester.log

# Check checkpoint creation (documentation only)
ls -la .tmops/feature-name/runs/current/checkpoints/

# Extract metrics after completion
python tmops_tools/extract_metrics.py feature-name
```

### Git Operations
```bash
# Check worktree status
git worktree list

# Remove worktrees after completion
git worktree remove wt-orchestrator
git worktree remove wt-tester
git worktree remove wt-impl
git worktree remove wt-verify
```

## Quick Troubleshooting

### "Instances not starting"
- Check all 4 terminals are running
- Verify prompts were pasted correctly
- Check `.tmops/<feature>/runs/current/` exists

### "Tests not found"
```bash
# Ensure git sync
cd wt-impl && git pull
```

### "Checkpoint not created"
```bash
# Check permissions
ls -la .tmops/<feature>/runs/current/checkpoints/

# Check logs for errors
grep ERROR .tmops/<feature>/runs/current/logs/*.log
```

### "Want to see what's happening"
```bash
# Real-time checkpoint monitoring
watch -n 1 'ls -ltr .tmops/*/runs/current/checkpoints/*.md 2>/dev/null | tail -5'

# Instance activity
tail -f .tmops/<feature>/runs/current/logs/*.log
```

## First Feature Checklist

Before starting:
- [ ] Repository cloned
- [ ] 4 terminals ready
- [ ] Feature name chosen

During execution:
- [ ] Task spec updated with requirements
- [ ] 4 instances launched with prompts
- [ ] Orchestrator created first trigger
- [ ] Tests being written by Tester
- [ ] Implementation in progress
- [ ] Verification completed

After completion:
- [ ] SUMMARY.md generated
- [ ] Metrics extracted
- [ ] All tests passing
- [ ] Feature branch ready to merge

## Example: Simple Auth Feature

### 1. Initialize
```bash
./tmops_tools/init_feature.sh user-auth initial
```

### 2. Update Task Spec
```markdown
## Acceptance Criteria
- [ ] POST /api/login accepts email and password
- [ ] Returns JWT token on success
- [ ] Returns 401 on invalid credentials
- [ ] Token includes user ID and email
```

### 3. Launch instances and watch them work!

Expected timeline:
- Setup: 5 minutes
- Test writing: 10 minutes
- Implementation: 15 minutes
- Verification: 5 minutes
- **Total: ~35 minutes**

## Next Steps

1. **Read Full Documentation**
   - [Claude Chat Guide](tmops_claude_chat.md) - Strategic planning
   - [Claude Code Guide](tmops_claude_code.md) - Instance details
   - [Protocol Specification](tmops_protocol.md) - Technical details

2. **Try Advanced Features**
   - Multi-run support for iterative development
   - Custom quality gates
   - Performance optimization

3. **Join the Community**
   - [GitHub Issues](https://github.com/happycode-ch/tmops_framework/issues)
   - [Discussions](https://github.com/happycode-ch/tmops_framework/discussions)

## Tips for Success

1. **Clear Task Specs** - The better your requirements, the better the output
2. **Let Instances Work** - Don't interrupt unless there's an error
3. **Monitor Logs** - They show exactly what each instance is doing
4. **Trust the Process** - Instances know their roles and boundaries
5. **Review Metrics** - Learn from each feature's performance data

## Quick Win: Your First Feature

Try this simple task to see TeamOps in action:

```markdown
# Task: Add a "hello world" API endpoint

## Acceptance Criteria
- [ ] GET /api/hello returns {"message": "Hello, World!"}
- [ ] Response has 200 status code
- [ ] Content-Type is application/json
```

This should complete in under 20 minutes and demonstrate the full workflow!

---
*Get started now: `./tmops_tools/init_feature.sh my-first-feature initial`*