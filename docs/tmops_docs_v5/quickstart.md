# TeamOps Framework Quick Start Guide
**Version:** 5.2.0  
**Time to First Feature:** ~5 minutes setup, 30-60 minutes execution

## What is TeamOps?

TeamOps is a multi-instance AI orchestration framework that divides software development tasks across 4 specialized Claude Code instances, enabling parallel, conflict-free development with built-in quality checks.

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

### Step 4: Launch 4 Claude Code Instances

Open 4 terminal windows/tabs:

**Terminal 1 - Orchestrator:**
```bash
cd wt-orchestrator && claude
```
Paste this prompt:
```
You are the ORCHESTRATOR instance in wt-orchestrator.
Read .tmops/my-feature/runs/current/TASK_SPEC.md
Create 001-discovery-trigger.md to start the workflow.
Monitor for completion checkpoints and coordinate phases.
Log to .tmops/my-feature/runs/current/logs/orchestrator.log
```

**Terminal 2 - Tester:**
```bash
cd wt-tester && claude
```
Paste this prompt:
```
You are the TESTER instance in wt-tester.
Wait for .tmops/my-feature/runs/current/checkpoints/001-discovery-trigger.md
Write failing tests in the PROJECT test/ directory.
Create 003-tests-complete.md when done.
Log to .tmops/my-feature/runs/current/logs/tester.log
```

**Terminal 3 - Implementer:**
```bash
cd wt-impl && claude
```
Paste this prompt:
```
You are the IMPLEMENTER instance in wt-impl.
Wait for .tmops/my-feature/runs/current/checkpoints/004-impl-trigger.md
Read tests from PROJECT test/ directory.
Write implementation in PROJECT src/ directory.
Create 005-impl-complete.md when all tests pass.
Log to .tmops/my-feature/runs/current/logs/implementer.log
```

**Terminal 4 - Verifier:**
```bash
cd wt-verify && claude
```
Paste this prompt:
```
You are the VERIFIER instance in wt-verify.
Wait for .tmops/my-feature/runs/current/checkpoints/006-verify-trigger.md
Review all code (read-only).
Create 007-verify-complete.md with findings.
Log to .tmops/my-feature/runs/current/logs/verifier.log
```

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

### Monitoring
```bash
# List checkpoints
python tmops_tools/monitor_checkpoints.py feature-name orchestrator list

# Watch specific instance log
tail -f .tmops/feature-name/runs/current/logs/tester.log

# Extract metrics
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