# TeamOps v7 Setup Guide

## Prerequisites

### Required Software
- **Claude Code CLI**: Latest version
- **Python 3.8+**: For hooks execution
- **Git**: For version control
- **Text Editor**: For editing task specifications

### Platform-Specific Requirements

#### macOS
- No additional requirements (notifications work out of the box)

#### Linux
- `notify-send` (usually pre-installed with desktop environments)
- Optional: `paplay` for audio notifications

#### Windows
- PowerShell 5.1+
- Optional: BurntToast module for notifications
  ```powershell
  Install-Module -Name BurntToast -Force
  ```

## Installation

### Step 1: Clone or Update Repository
```bash
# For new installation
git clone <repository-url>
cd tmops_framework/CODE

# For existing installation
git pull origin main
```

### Step 2: Make Scripts Executable
```bash
chmod +x tmops_tools/v7/init_feature_v7.sh
chmod +x tmops_tools/v7/merge_hooks.py
chmod +x tmops_tools/v7/hooks/*.py
```

### Step 3: Initialize Your First Feature
```bash
./tmops_tools/v7/init_feature_v7.sh my-feature initial
```

This command will:
1. Create feature directory structure
2. Install subagents to `.claude/agents/`
3. Configure hooks in `.claude/project_settings.json`
4. Create initial state and task specification
5. Set up git branch (if in a git repository)

## Configuration

### Environment Variables

Configure TeamOps behavior via environment variables:

```bash
# Enable TeamOps v7 for a session
export TMOPS_V7_ACTIVE=1

# Disable notification sounds
export TMOPS_SILENT=1

# Enable push notifications
export TMOPS_PUSH_NOTIFICATIONS=1
export TMOPS_PUSH_TOPIC="my-project-tmops"

# Custom notification command
export TMOPS_NOTIFY_CMD="my-notifier"
```

### Project Settings

The `.claude/project_settings.json` file configures hooks:

```json
{
  "hooks": {
    "PreToolUse": [...],
    "PostToolUse": [...],
    "SessionStart": [...],
    "Stop": [...],
    "SubagentStop": [...],
    "Notification": [...]
  }
}
```

### Git Configuration

Add to `.gitignore`:
```
.claude/
.tmops/
```

## Usage Workflow

### 1. Initialize Feature
```bash
./tmops_tools/v7/init_feature_v7.sh user-auth initial
```

### 2. Define Requirements
Edit the task specification:
```bash
vim .tmops/user-auth/runs/current/TASK_SPEC.md
```

Include:
- Clear objectives
- Specific acceptance criteria
- Technical requirements
- Example usage

### 3. Start Automated Workflow
```bash
TMOPS_V7_ACTIVE=1 claude "Build user-auth feature using TeamOps v7"
```

### 4. Monitor Progress
Claude will automatically:
1. Invoke tester subagent → Write failing tests
2. Detect test completion → Invoke implementer
3. Make tests pass → Invoke verifier
4. Generate final report

You'll receive notifications at each phase transition.

## Advanced Usage

### Patch Runs
Add modifications to existing features:
```bash
./tmops_tools/v7/init_feature_v7.sh user-auth patch
```

### Multiple Features
Work on multiple features in parallel:
```bash
# Terminal 1
./tmops_tools/v7/init_feature_v7.sh feature-a initial
TMOPS_V7_ACTIVE=1 claude "Build feature-a using TeamOps v7"

# Terminal 2
./tmops_tools/v7/init_feature_v7.sh feature-b initial
TMOPS_V7_ACTIVE=1 claude "Build feature-b using TeamOps v7"
```

### Custom Subagents
Create specialized subagents in `.claude/agents/`:
```markdown
# .claude/agents/tmops-documenter.md
You are the DOCUMENTER subagent...
```

### Hook Customization
Modify hook behavior by editing files in `tmops_tools/v7/hooks/`.

## Troubleshooting

### Common Issues

#### Issue: Hooks not executing
**Solution**: Verify `.claude/project_settings.json` exists and contains TeamOps hooks.

#### Issue: Notifications not working
**Solution**: 
- macOS: Check System Preferences → Notifications
- Linux: Ensure `notify-send` is installed
- Windows: Install BurntToast PowerShell module

#### Issue: Phase transitions not detected
**Solution**: Ensure tests actually run and produce output. Check `.tmops/current/state.json`.

#### Issue: Subagent not found
**Solution**: Verify `.claude/agents/tmops-*.md` files exist.

### Debugging

#### Check Hook Execution
```bash
# View hook logs
tail -f .tmops/*/runs/current/logs/*.jsonl
```

#### Verify State
```bash
# Check current state
cat .tmops/current/state.json
```

#### Test Hooks Manually
```bash
# Test pre-tool hook
echo '{"tool_name":"Write","tool_input":{"file_path":"test.py"}}' | \
  python3 tmops_tools/v7/hooks/pre_tool_use.py
```

### Reset Feature
If a feature gets stuck:
```bash
# Remove current state
rm -f .tmops/current/state.json

# Start fresh patch run
./tmops_tools/v7/init_feature_v7.sh my-feature patch
```

## Migration from v6

### Coexistence
v6 and v7 can coexist in the same project:
- v6 uses: `tmops_tools/*.sh`
- v7 uses: `tmops_tools/v7/*.sh`

### Migration Steps
1. Complete existing v6 features
2. Install v7 alongside v6
3. Use v7 for new features
4. Gradually migrate tools and processes

### Feature Comparison
| Action | v6 Command | v7 Command |
|--------|------------|------------|
| Initialize | `./tmops_tools/init_feature_v6.sh` | `./tmops_tools/v7/init_feature_v7.sh` |
| Start Work | Open 4 terminals, paste prompts | `TMOPS_V7_ACTIVE=1 claude "..."` |
| Coordinate | Manual [BEGIN], [CONFIRMED] | Automatic |
| Monitor | Watch 4 terminals | Single terminal + notifications |

## Best Practices

### Task Specifications
1. **Be Specific**: Vague requirements lead to incomplete tests
2. **Include Examples**: Show expected usage and output
3. **Define Errors**: Specify error handling requirements
4. **Set Boundaries**: Clearly state what's out of scope

### Workflow Management
1. **One Feature at a Time**: Focus on single features
2. **Review Checkpoints**: Check generated checkpoints for progress
3. **Trust the Process**: Let automation handle coordination
4. **Document Learnings**: Update task specs based on experience

### Team Collaboration
1. **Share Task Specs**: Review requirements before starting
2. **Version Control**: Commit completed features promptly
3. **Document Patterns**: Create templates for common features
4. **Collect Metrics**: Use logs for process improvement

## Support and Resources

### Documentation
- Architecture: `docs/tmops_docs_v7/architecture.md`
- Migration Guide: `docs/tmops_docs_v7/migration_guide.md`
- Examples: `docs/tmops_docs_v7/examples/`

### Getting Help
1. Check troubleshooting section above
2. Review hook and subagent logs
3. Consult the architecture documentation
4. File issues in project repository

## Next Steps
1. Initialize your first v7 feature
2. Write a clear task specification
3. Launch the automated workflow
4. Experience the magic of automated TDD orchestration!