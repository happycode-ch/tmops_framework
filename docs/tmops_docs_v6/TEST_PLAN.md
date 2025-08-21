# TeamOps v6 Manual Orchestration - Test Plan

## Test Feature: "hello-api"

### Acceptance Criteria
- GET /api/hello returns {"message": "Hello, World!"}
- Response has 200 status code
- Content-Type is application/json

### Expected Timeline
- Setup: 5 minutes
- Test Writing: 5 minutes (simple feature)
- Implementation: 5 minutes
- Verification: 5 minutes
- Total: ~20 minutes

## Pre-Test Cleanup (if needed)

If the hello-api feature already exists from a previous test:

```bash
# Run the cleanup script (once created)
./tmops_tools/cleanup_feature.sh hello-api

# Or manually clean up:
# 1. Remove worktrees
git worktree remove wt-orchestrator --force 2>/dev/null || true
git worktree remove wt-tester --force 2>/dev/null || true
git worktree remove wt-impl --force 2>/dev/null || true
git worktree remove wt-verify --force 2>/dev/null || true

# 2. Remove feature branch
git branch -D feature/hello-api 2>/dev/null || true

# 3. Remove TeamOps artifacts
rm -rf .tmops/hello-api

# 4. Remove any test/src files created (check first!)
rm -f test/*hello* src/*hello* 2>/dev/null || true
```

## Test Execution Steps

### Phase 1: Setup (5 minutes)

#### 1.1 Initialize Feature
```bash
cd /path/to/tmops_framework/CODE
./tmops_tools/init_feature.sh hello-api initial
```

#### 1.2 Update Task Specification
Edit `.tmops/hello-api/runs/current/TASK_SPEC.md`:
```markdown
# Task Specification: hello-api
Version: 1.0.0
Created: [Current Date]
Status: Active
Run: 001-initial

## User Story
As a developer
I want a simple hello world API endpoint
So that I can test the TeamOps v6 manual orchestration

## Acceptance Criteria
- [ ] GET /api/hello returns JSON response
- [ ] Response contains message "Hello, World!"
- [ ] Status code is 200
- [ ] Content-Type header is application/json

## Technical Constraints
- Use existing Express.js setup
- Add endpoint to src/server.js
- Write tests using existing test framework

## Performance Requirements
- Response time < 100ms

## Definition of Done
- All tests passing
- Endpoint accessible
- Clean code structure
```

### Phase 2: Launch Instances (2 minutes)

Open 4 terminal windows:

```bash
# Terminal 1 - Orchestrator
cd wt-orchestrator && claude

# Terminal 2 - Tester
cd wt-tester && claude

# Terminal 3 - Implementer
cd wt-impl && claude

# Terminal 4 - Verifier
cd wt-verify && claude
```

### Phase 3: Initialize Instances

Paste the appropriate section from `docs/tmops_docs_v6/tmops_claude_code.md` into each instance.

**Expected Response from Each:**
- `[ORCHESTRATOR] WAITING: Ready for instructions`
- `[TESTER] WAITING: Ready for instructions`
- `[IMPLEMENTER] WAITING: Ready for instructions`
- `[VERIFIER] WAITING: Ready for instructions`

### Phase 4: Execute Manual Orchestration

#### Step 1: Start Orchestration
```
You → Orchestrator: [BEGIN]: Start orchestration for "hello-api"
Expected: [ORCHESTRATOR] READY: Tester can begin. Trigger 001 created.
```

#### Step 2: Start Testing
```
You → Tester: [BEGIN]: Start test writing
Expected: [TESTER] WORKING: Writing tests...
Wait for: [TESTER] COMPLETE: X tests written, all failing. Checkpoint 003 created.
```

#### Step 3: Confirm to Orchestrator
```
You → Orchestrator: [CONFIRMED]: Tester has completed
Expected: [ORCHESTRATOR] READY: Implementer can begin. Trigger 004 created.
```

#### Step 4: Start Implementation
```
You → Implementer: [BEGIN]: Start implementation
Expected: [IMPLEMENTER] WORKING: Making tests pass...
Wait for: [IMPLEMENTER] COMPLETE: All tests passing. Checkpoint 005 created.
```

#### Step 5: Confirm to Orchestrator
```
You → Orchestrator: [CONFIRMED]: Implementer has completed
Expected: [ORCHESTRATOR] READY: Verifier can begin. Trigger 006 created.
```

#### Step 6: Start Verification
```
You → Verifier: [BEGIN]: Start verification
Expected: [VERIFIER] WORKING: Reviewing code quality...
Wait for: [VERIFIER] COMPLETE: Review finished. Quality score X/10. Checkpoint 007 created.
```

#### Step 7: Final Confirmation
```
You → Orchestrator: [CONFIRMED]: Verifier has completed
Expected: [ORCHESTRATOR] COMPLETE: Feature orchestration finished. SUMMARY.md created.
```

## Verification Checklist

### During Execution
- [ ] All instances report WAITING initially
- [ ] Each instance responds to [BEGIN] command
- [ ] Status messages follow expected format
- [ ] No polling messages appear
- [ ] Each phase completes successfully

### After Completion
- [ ] Check test files exist in `test/` directory
- [ ] Check implementation exists in `src/` directory
- [ ] Verify endpoint works:
  ```bash
  # Start server
  npm start
  
  # Test endpoint
  curl http://localhost:3000/api/hello
  # Should return: {"message": "Hello, World!"}
  ```
- [ ] Check all checkpoints created:
  ```bash
  ls -la .tmops/hello-api/runs/current/checkpoints/
  # Should show: 001, 003, 004, 005, 006, 007, SUMMARY.md
  ```
- [ ] Review logs for each instance:
  ```bash
  cat .tmops/hello-api/runs/current/logs/*.log
  ```
- [ ] Extract and review metrics:
  ```bash
  python tmops_tools/extract_metrics.py hello-api
  ```

## Success Criteria

The test is successful if:
1. ✅ No polling timeouts or errors
2. ✅ Clear status messages at each step
3. ✅ All checkpoints created in sequence
4. ✅ Tests written and failing initially
5. ✅ Implementation makes all tests pass
6. ✅ Verifier provides quality score
7. ✅ SUMMARY.md generated with metrics
8. ✅ API endpoint works as specified

## Troubleshooting Guide

### Issue: Instance doesn't respond
**Solution:** Send `[STATUS]: Report current status`

### Issue: Trigger file not found
**Check:**
```bash
ls -la .tmops/hello-api/runs/current/checkpoints/
```
**Solution:** Ensure Orchestrator created it before proceeding

### Issue: Tests not found by Implementer
**Solution:**
```bash
cd wt-impl
git pull origin feature/hello-api
```

### Issue: Instance seems stuck
**Check logs:**
```bash
tail -f .tmops/hello-api/runs/current/logs/[role].log
```

## Comparison with v5

| Aspect | v5 (Automated) | v6 (Manual) |
|--------|---------------|-------------|
| Polling | Yes, with timeouts | No |
| Human involvement | Launch only | Active coordination |
| Reliability | ~90% | 100% |
| Status visibility | Check logs | Clear messages |
| Ability to pause | No | Yes |
| Debug ease | Difficult | Simple |

## Post-Test Cleanup

After successful test:
```bash
# Optional: Archive the results
cp -r .tmops/hello-api .tmops/hello-api.$(date +%Y%m%d)

# Clean up for next test
./tmops_tools/cleanup_feature.sh hello-api
```

## Expected Outputs

### Test File (test/hello_api.test.js)
```javascript
describe('Hello API', () => {
  test('GET /api/hello returns correct message', async () => {
    const response = await request(app).get('/api/hello');
    expect(response.status).toBe(200);
    expect(response.body.message).toBe('Hello, World!');
    expect(response.headers['content-type']).toMatch(/json/);
  });
});
```

### Implementation (src/server.js addition)
```javascript
app.get('/api/hello', (req, res) => {
  res.json({ message: 'Hello, World!' });
});
```

## Notes for Testers

1. **Be Patient**: Wait for each instance to complete before proceeding
2. **Watch Status**: Each instance should clearly report its state
3. **No Rushing**: The manual process ensures reliability over speed
4. **Document Issues**: Note any confusion or problems for improvement
5. **Celebrate Success**: The v6 process should work flawlessly!

---
*This test validates the complete v6 manual orchestration workflow.*