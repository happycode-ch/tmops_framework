# TeamOps v6 - Copy-Paste Guide

**Exact commands to get TeamOps v6 working in any project**

## Installation

### Option 1: Direct Copy (Recommended)
```bash
# From the tmops_framework directory
cp -r tmops_v6_portable/ /path/to/your/project/
cd /path/to/your/project/
```

### Option 2: Download from GitHub (Future)
```bash
# When available on GitHub
curl -sSL https://github.com/your-org/tmops/releases/latest/tmops_v6_portable.tar.gz | tar xz
```

## Complete Example: Hello World API

### Step 1: Setup Project Structure
```bash
# Create a test project
mkdir my-test-project
cd my-test-project
git init
mkdir -p src test
echo '{"name": "test-project", "version": "1.0.0"}' > package.json

# Copy TeamOps v6
cp -r /path/to/tmops_framework/tmops_v6_portable/ ./
```

### Step 2: Initialize Feature
```bash
# Initialize the hello-world feature
./tmops_v6_portable/tmops_tools/init_feature_v6.sh hello-world initial
```

### Step 3: Define Requirements
Create `.tmops/hello-world/runs/current/TASK_SPEC.md`:
```markdown
# Task Specification: Hello World API

## Objective
Create a simple REST API endpoint that returns "Hello, World!"

## Acceptance Criteria
- [ ] GET /hello endpoint returns "Hello, World!"
- [ ] Response has correct Content-Type header
- [ ] Response status is 200 OK
- [ ] Works with both Node.js/Express and Python/Flask

## Technical Requirements
- Clean, testable code structure
- Proper error handling
- Input validation if needed

## Constraints
- Use standard libraries where possible
- Follow existing project patterns

## Expected Deliverables
1. Tests in `test/` directory
2. Implementation in `src/` directory
3. All tests passing

## Notes
This is a simple demo to validate TeamOps v6 workflow
```

### Step 4: Launch Claude Code Instances

**Terminal 1 - Orchestrator:**
```bash
cd wt-orchestrator
claude
```
Then paste the entire contents of `tmops_v6_portable/instance_instructions/01_orchestrator.md`

**Terminal 2 - Tester:**
```bash
cd wt-tester  
claude
```
Then paste the entire contents of `tmops_v6_portable/instance_instructions/02_tester.md`

**Terminal 3 - Implementer:**
```bash
cd wt-impl
claude
```
Then paste the entire contents of `tmops_v6_portable/instance_instructions/03_implementer.md`

**Terminal 4 - Verifier:**
```bash
cd wt-verify
claude
```
Then paste the entire contents of `tmops_v6_portable/instance_instructions/04_verifier.md`

### Step 5: Execute Workflow

**Wait for all instances to report WAITING, then:**

1. **To Orchestrator:** `[BEGIN]: Start orchestration for hello-world`
   - Wait for: `[ORCHESTRATOR] READY: Tester can begin. Trigger 001 created.`

2. **To Tester:** `[BEGIN]: Start test writing`
   - Wait for: `[TESTER] COMPLETE: X tests written, all failing. Checkpoint 003 created.`

3. **To Orchestrator:** `[CONFIRMED]: Tester has completed`
   - Wait for: `[ORCHESTRATOR] READY: Implementer can begin. Trigger 004 created.`

4. **To Implementer:** `[BEGIN]: Start implementation`
   - Wait for: `[IMPLEMENTER] COMPLETE: All tests passing. Checkpoint 005 created.`

5. **To Orchestrator:** `[CONFIRMED]: Implementer has completed`
   - Wait for: `[ORCHESTRATOR] READY: Verifier can begin. Trigger 006 created.`

6. **To Verifier:** `[BEGIN]: Start verification`
   - Wait for: `[VERIFIER] COMPLETE: Review finished. Quality score X/10. Checkpoint 007 created.`

7. **To Orchestrator:** `[CONFIRMED]: Verifier has completed`
   - Wait for: `[ORCHESTRATOR] COMPLETE: Feature orchestration finished. SUMMARY.md created.`

## Expected Results

After completion, you should have:
- **Tests** in `test/hello.test.js` (or similar)
- **Implementation** in `src/hello.js` (or similar)
- **All tests passing**
- **Quality score** from verification
- **Metrics** in `.tmops/hello-world/runs/current/metrics.json`

## Troubleshooting

### "Feature already exists"
```bash
./tmops_v6_portable/tmops_tools/cleanup_feature.sh hello-world
./tmops_v6_portable/tmops_tools/init_feature_v6.sh hello-world initial
```

### "Worktree already exists"
```bash
rm -rf wt-*
git worktree prune
./tmops_v6_portable/tmops_tools/init_feature_v6.sh hello-world initial
```

### "Tests not found" (Implementer)
```bash
# In wt-impl terminal
git pull origin feature/hello-world
ls ../test/  # Should see test files
```

### Instance not responding
- Make sure you copied the ENTIRE instruction file
- Check that the instance identified its role correctly
- Look for error messages in the Claude Code output

## Adapting to Different Project Types

### Python Projects
```bash
mkdir -p src tests
# In TASK_SPEC.md, specify Python/pytest instead of Node.js/Jest
```

### Go Projects
```bash
mkdir -p cmd pkg
# Tests go in same directory as Go files (*_test.go)
# Update TASK_SPEC.md accordingly
```

### TypeScript Projects
```bash
mkdir -p src test
echo '{"compilerOptions": {"target": "es2017"}}' > tsconfig.json
# Specify TypeScript in TASK_SPEC.md
```

## Clean Up After Testing
```bash
# Remove all TeamOps artifacts
./tmops_v6_portable/tmops_tools/cleanup_feature.sh hello-world

# Or clean everything
rm -rf .tmops/ wt-* tmops_v6_portable/
git branch -D feature/hello-world
```

## Performance Tips

### Faster Iteration
```bash
# Use patch runs for incremental improvements
./tmops_v6_portable/tmops_tools/init_feature_v6.sh hello-world patch
```

### Monitoring
```bash
# Check metrics
python3 tmops_v6_portable/tmops_tools/extract_metrics.py hello-world

# Monitor logs
tail -f .tmops/hello-world/runs/current/logs/orchestrator.log
```

## One-Liner Test Drive

```bash
# Complete test in any git project
mkdir -p src test && \
cp -r /path/to/tmops_framework/tmops_v6_portable/ ./ && \
./tmops_v6_portable/tmops_tools/init_feature_v6.sh hello-test initial && \
echo "Edit .tmops/hello-test/runs/current/TASK_SPEC.md then launch 4 Claude Code instances"
```

---

**Questions?** The process is designed to be completely self-contained. Each instance knows exactly what to do from the instruction files.