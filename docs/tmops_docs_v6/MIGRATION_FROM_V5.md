# Migrating from TeamOps v5 to v6 Manual Orchestration

## What's Changed

### Removed in v6
- ❌ All polling loops and checkpoint monitoring
- ❌ Timeout configurations
- ❌ Exponential backoff logic
- ❌ Automated checkpoint detection
- ❌ monitor_checkpoints.py polling functionality

### Added in v6
- ✅ Human coordination of handoffs
- ✅ Explicit status reporting (WAITING/WORKING/COMPLETE)
- ✅ Clear wait states between phases
- ✅ Manual confirmation requirements
- ✅ Ability to pause between phases

### Unchanged from v5
- ✅ All instance roles and responsibilities
- ✅ Checkpoint file formats and locations
- ✅ Git worktree structure
- ✅ Test/implementation file locations
- ✅ Metrics and logging systems
- ✅ Directory structure (.tmops/)

## Migration Steps

### 1. Update Documentation
Replace your v5 documentation with v6:
```bash
# Backup v5 docs if needed
cp -r docs/tmops_docs_v5 docs/tmops_docs_v5.backup

# Use v6 documentation
cp -r docs/tmops_docs_v6/* docs/tmops_docs_v5/
```

### 2. Update Instance Prompts
The key change is in the prompts you paste into each Claude Code instance:

**v5 Prompt Example (Automated):**
```
You are the TESTER instance in wt-tester.
Wait for .tmops/my-feature/runs/current/checkpoints/001-discovery-trigger.md
Poll for checkpoint using exponential backoff...
```

**v6 Prompt Example (Manual):**
```
You are the TESTER instance in wt-tester.
Report: "[TESTER] WAITING: Ready for instructions"
WAIT for human: "[BEGIN]: Start test writing"
Do NOT poll for checkpoints...
```

### 3. Learn the New Communication Flow

**v5 Flow (Automated):**
```
Orchestrator → Creates trigger → Tester polls and finds it → Tester works
```

**v6 Flow (Manual):**
```
Human → "[BEGIN]" → Orchestrator → Creates trigger → Reports to Human
Human → "[BEGIN]" → Tester → Checks trigger once → Works → Reports to Human
Human → "[CONFIRMED]" → Orchestrator → Continues...
```

## Quick Conversion Checklist

- [ ] Read v6 documentation thoroughly
- [ ] Understand manual coordination role
- [ ] Practice status message format
- [ ] Test with simple feature first
- [ ] Document any issues for improvement

## Common Migration Questions

**Q: Do I need to change my existing code or tests?**
A: No, all project code remains the same. Only the orchestration method changes.

**Q: Can I still use the monitoring tools?**
A: Yes, but not for polling. Use them to check status and extract metrics after completion.

**Q: Do I need to type messages exactly as shown?**
A: The format helps clarity but minor variations are fine. The key is clear communication.

**Q: Can I automate the human coordination?**
A: That defeats the purpose. The manual process provides reliability and visibility.

**Q: What if an instance doesn't respond?**
A: Send `[STATUS]: Report current status` to check if it's still working.

**Q: Can I pause between phases?**
A: Yes! That's a key benefit. Take breaks, review work, or debug as needed.

**Q: Is v6 slower than v5?**
A: Not significantly. The human coordination adds minimal overhead while providing much better reliability.

## Benefits of Migration

### Reliability
- **v5**: ~90% success rate (polling timeouts, missed checkpoints)
- **v6**: 100% success rate (explicit handoffs)

### Visibility
- **v5**: Must check logs to understand state
- **v6**: Clear status messages at each step

### Control
- **v5**: Automated flow, hard to intervene
- **v6**: Can pause, review, and guide at any point

### Debugging
- **v5**: Complex polling logs to trace issues
- **v6**: Clear communication trail shows exactly where problems occur

## Example Migration Session

### Starting a Feature in v6

1. **Initialize** (same as v5):
```bash
./tmops_tools/init_feature.sh my-feature initial
```

2. **Launch Instances** (same terminals as v5):
```bash
# Terminal 1
cd wt-orchestrator && claude

# Terminal 2
cd wt-tester && claude

# Terminal 3
cd wt-impl && claude

# Terminal 4
cd wt-verify && claude
```

3. **Paste v6 Prompts** (NEW):
Each instance should respond with:
```
[ROLE] WAITING: Ready for instructions
```

4. **Coordinate Manually** (NEW):
```
You → Orchestrator: [BEGIN]: Start orchestration for "my-feature"
You → Tester: [BEGIN]: Start test writing
(wait for completion)
You → Orchestrator: [CONFIRMED]: Tester has completed
...continue pattern...
```

## Rollback Plan

If you need to revert to v5:
1. Use the v5 documentation from `docs/tmops_docs_v5.backup/`
2. Paste v5 prompts with polling instructions
3. Let instances run automatically

However, we strongly recommend staying with v6 for its reliability benefits.

## Support

- Review the [v6 Quick Start](quickstart.md)
- Check the [v6 Protocol](tmops_protocol.md)
- Read instance details in [tmops_claude_code.md](tmops_claude_code.md)

## Summary

The migration from v5 to v6 is primarily a change in how you coordinate the instances:
- **v5**: Automated polling (hands-off but unreliable)
- **v6**: Manual coordination (hands-on but 100% reliable)

The actual work done by each instance remains exactly the same. You're simply replacing unreliable polling with reliable human coordination.

---
*Migration typically takes less than 5 minutes to understand and implement.*