# TeamOps Framework - Simplified Edition

**Quick setup → Rapid feature delivery**

TeamOps orchestrates 4 Claude Code instances working sequentially to build features using Test-Driven Development.

**IMPORTANT: TeamOps creates `.tmops/` in your project root (parent of tmops_v6_portable)**

## 🚀 Quick Start

```bash
# 1. Install (first time only)
./INSTALL.sh

# 2. Start your feature (creates feature branch)
cd tmops_v6_portable
./tmops_tools/init_feature_multi.sh my-feature

# 3. Open 4 Claude Code instances in ROOT directory (parent of tmops_v6_portable)
cd ..  # Go to project root
claude  # Terminal 1: Orchestrator
claude  # Terminal 2: Tester
claude  # Terminal 3: Implementer
claude  # Terminal 4: Verifier

# 4. Paste role instructions from tmops_v6_portable/instance_instructions/
# 5. Start: You → Orchestrator: "[BEGIN]: Start orchestration for <feature>"
```

## 💡 Key Features

- **Sequential Workflow** - Instances work one at a time in TDD sequence
- **Simple Branches** - Just feature branches, no worktrees
- **No Navigation Issues** - All instances work in root project directory  
- **Fast Setup** - Initialize in seconds
- **Full Orchestration** - Complete TDD workflow preserved
- **Clean Separation** - Tools in tmops_v6_portable/, artifacts in root .tmops/

## 📝 Core Commands

```bash
# Feature Management (run from tmops_v6_portable directory)
cd tmops_v6_portable
./tmops_tools/init_feature_multi.sh <name>  # Start new feature
./tmops_tools/list_features.sh              # Show all features
./tmops_tools/switch_feature.sh <name>      # Show feature info

# Cleanup (safe by default)
./tmops_tools/cleanup_safe.sh <name>        # Remove .tmops artifacts and branch
./tmops_tools/cleanup_safe.sh <name> full   # Also remove test/src files

# Metrics & Analysis
./tmops_tools/extract_metrics.py <name>     # Performance report
```

## 🎯 Working on Multiple Features

```bash
# Start feature A
./tmops_tools/init_feature_multi.sh auth-api
# Work on branch: feature/auth-api

# Start feature B (switch back to main first)
git checkout main
./tmops_tools/init_feature_multi.sh payment-flow
# Work on branch: feature/payment-flow

# List what's active
./tmops_tools/list_features.sh

# Switch context (shows paths)
./tmops_tools/switch_feature.sh auth-api
```

## 📂 Project Structure

```
your-project/                    # Root project directory
├── .tmops/                      # TeamOps artifacts (created here)
│   ├── <feature>/              # Per-feature data
│   └── FEATURES.txt            # Active features list
├── src/                         # Your implementation goes here
├── test/                        # Your tests go here
├── tmops_v6_portable/           # TeamOps tools
│   ├── tmops_tools/            # Scripts
│   └── instance_instructions/  # Role instructions
└── [Claude instances work here] # All 4 instances in root
```

### Workflow Architecture
- **Sequential Execution**: Orchestrator → Tester → Implementer → Verifier
- **Single Feature Branch**: `feature/<feature>` shared by all instances
- **Checkpoint-Based Progress**: Each phase creates completion markers
- **No Complex Merging**: Linear development on one branch

## 🤝 Sequential Coordination Flow

You act as the conductor, managing the sequential workflow between instances:

```
1. You → Orchestrator: "[BEGIN]: Start orchestration for <feature>"
   Orchestrator creates trigger → "[ORCHESTRATOR] READY: Tester can begin"
   
2. You → Tester: "[BEGIN]: Start test writing"  
   Tester writes failing tests → "[TESTER] COMPLETE: Tests written"
   
3. You → Orchestrator: "[CONFIRMED]: Tester has completed"
   Orchestrator creates trigger → "[ORCHESTRATOR] READY: Implementer can begin"
   
4. You → Implementer: "[BEGIN]: Start implementation"
   Implementer makes tests pass → "[IMPLEMENTER] COMPLETE: Tests passing"
   
5. You → Orchestrator: "[CONFIRMED]: Implementer has completed"  
   Orchestrator creates trigger → "[ORCHESTRATOR] READY: Verifier can begin"
   
6. You → Verifier: "[BEGIN]: Start verification"
   Verifier reviews quality → "[VERIFIER] COMPLETE: Review done"
   
7. You → Orchestrator: "[CONFIRMED]: Verifier has completed"
   Orchestrator finalizes → "[ORCHESTRATOR] COMPLETE: Feature ready"
```

**Important**: Only one instance works at a time. Wait for completion before starting the next.

## 📚 Documentation

- `instance_instructions/` - Role prompts for each instance (paste these into Claude)
- `development_report/REPORT.md` - System architecture and implementation details
- `docs/tmops_docs_v6/` - Advanced documentation
  - `tmops_protocol.md` - Technical protocol details
  - `tmops_claude_code.md` - Full instance instructions
- `../CHANGELOG.md` - Version history and migration notes

## ⚡ Example: Hello API

```bash
# 1. Initialize (from tmops_v6_portable directory)
cd tmops_v6_portable
./tmops_tools/init_feature_multi.sh hello-api

# 2. Edit task spec to include:
# - GET /api/hello returns {"message": "Hello, World!"}
# - Status code 200
# - Content-Type: application/json

# 3. Launch instances in root directory and coordinate
cd ..  # Go to project root
```

## 🔧 Troubleshooting

**"Error reading file"** - Check working directory with `pwd`, must be in project root  
**"Uncommitted changes"** - Commit or stash before cleanup  
**"Branch already exists"** - Run cleanup_safe.sh on the old feature first  
**"Checkpoint not found"** - Verify you're on correct branch with `git branch --show-current`  

## 📄 License

MIT License - Based on TeamOps by @happycode-ch

---

*For detailed documentation, see docs/ directory*