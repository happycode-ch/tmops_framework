# TeamOps v6 - 3-Minute Setup

**Get TeamOps v6 running in ANY project in under 3 minutes!**

## Prerequisites
- Git repository with `src/` and `test/` (or `tests/`) directories
- 4 Claude Code CLI instances available

## Package Contents
- `tmops_tools/` - Core automation scripts
- `instance_instructions/` - Quick-paste role instructions  
- `docs/tmops_docs_v6/` - Complete v6 documentation
  - `tmops_protocol.md` - Full protocol specification
  - `tmops_claude_code.md` - Detailed instance instructions
  - `quickstart.md` - Extended setup guide
  - `TEST_PLAN.md` - Testing strategies

## 3-Minute Setup

### 1. Copy TeamOps to Your Project
```bash
# Copy the entire tmops_v6_portable/ directory to your project root
cp -r tmops_v6_portable/ /path/to/your/project/
cd /path/to/your/project/

# OR use the installer
./tmops_v6_portable/INSTALL.sh
```

### 2. Initialize a Feature
```bash
# Creates .tmops structure and git worktrees
./tmops_tools/init_feature_v6.sh hello-world initial
```

### 3. Launch 4 Claude Code Instances
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

## Quick Test with Hello World

**Optional**: Test your setup with a working example:
```bash
# Update TASK_SPEC.md with hello-world requirements (see TEST_HELLO.md)
nano .tmops/hello-world/runs/current/TASK_SPEC.md
```

## Start Coordinating

- **Copy-paste** the appropriate instruction file into each Claude Code instance:
  - Orchestrator: `instance_instructions/01_orchestrator.md`
  - Tester: `instance_instructions/02_tester.md`
  - Implementer: `instance_instructions/03_implementer.md`
  - Verifier: `instance_instructions/04_verifier.md`

## Manual Coordination Workflow
1. All instances report `[ROLE] WAITING: Ready for instructions`
2. Tell Orchestrator: `[BEGIN]: Start orchestration for hello-world`
3. Orchestrator creates trigger → Tell Tester: `[BEGIN]: Start test writing`
4. Tester completes → Tell Orchestrator: `[CONFIRMED]: Tester has completed`
5. Continue pattern through Implementer and Verifier

## That's It!
TeamOps v6 will create failing tests, implement the feature, and verify quality.
All work goes in your `src/` and `test/` directories, not in `.tmops/`

**Need help?** 
- `TEST_HELLO.md` - Complete hello-world walkthrough
- `COPY_PASTE_GUIDE.md` - Detailed examples and troubleshooting