# TeamOps Framework v6.1 - Multi-Feature Edition

**Quick setup → Rapid feature delivery**

TeamOps orchestrates 4 Claude Code instances to build features using Test-Driven Development.
Now supports multiple features in parallel!

## 🚀 Quick Start

```bash
# 1. Install (first time only)
./INSTALL.sh

# 2. Start your feature (creates 4 worktrees)
./tmops_tools/init_feature_multi.sh my-feature

# 3. Open 4 Claude Code terminals
cd wt-my-feature-orchestrator && claude
cd wt-my-feature-tester && claude  
cd wt-my-feature-impl && claude
cd wt-my-feature-verify && claude

# 4. Paste role instructions (from instance_instructions/ or docs/roles/)
# 5. Start: You → Orchestrator: "[BEGIN]: Start orchestration"
```

## 💡 What's New in v6.1

- **Multi-Feature Support** - Work on multiple features simultaneously
- **Safe Cleanup** - Two-tier system prevents accidental deletions
- **Simple Commands** - One README, clear structure

## 📝 Core Commands

```bash
# Feature Management
./tmops_tools/init_feature_multi.sh <name>  # Start new feature
./tmops_tools/list_features.sh              # Show all features
./tmops_tools/switch_feature.sh <name>      # Show feature info

# Cleanup (safe by default)
./tmops_tools/cleanup_safe.sh <name>        # Remove tmops + worktrees
./tmops_tools/cleanup_safe.sh <name> full   # Also remove code files

# Metrics & Analysis
./tmops_tools/extract_metrics.py <name>     # Performance report
```

## 🎯 Working on Multiple Features

```bash
# Start feature A
./tmops_tools/init_feature_multi.sh auth-api
# Work in: wt-auth-api-orchestrator, wt-auth-api-tester, etc.

# Start feature B (while A is active)
./tmops_tools/init_feature_multi.sh payment-flow
# Work in: wt-payment-flow-orchestrator, wt-payment-flow-tester, etc.

# List what's active
./tmops_tools/list_features.sh

# Switch context (shows paths)
./tmops_tools/switch_feature.sh auth-api
```

## 📂 Project Structure

```
your-project/
├── src/                         # Your implementation goes here
├── test/                        # Your tests go here
├── .tmops/                      # TeamOps artifacts (auto-created)
│   ├── <feature>/              # Per-feature data
│   └── FEATURES.txt            # Active features list
├── wt-<feature>-orchestrator/   # Worktree on branch: feature/<feature>-orchestrator
├── wt-<feature>-tester/         # Worktree on branch: feature/<feature>-tester
├── wt-<feature>-impl/           # Worktree on branch: feature/<feature>-impl
└── wt-<feature>-verify/         # Worktree on branch: feature/<feature>-verify
```

### Branch Architecture
- Each role works on its own branch to prevent Git conflicts
- Integration branch `feature/<feature>` merges all work
- Orchestrator handles merging between phases

## 🤝 Manual Coordination Flow

You act as the conductor between instances:

```
1. You → Orchestrator: "[BEGIN]: Start orchestration for <feature>"
2. You → Tester: "[BEGIN]: Start test writing"
   (wait for: "[TESTER] COMPLETE: Tests written")
3. You → Orchestrator: "[CONFIRMED]: Tests complete"
4. You → Implementer: "[BEGIN]: Start implementation"
   (wait for: "[IMPLEMENTER] COMPLETE: Tests passing")
5. You → Orchestrator: "[CONFIRMED]: Implementation complete"
6. You → Verifier: "[BEGIN]: Start verification"
   (wait for: "[VERIFIER] COMPLETE: Review done")
7. You → Orchestrator: "[CONFIRMED]: Verification complete"
```

## 📚 Documentation

- `instance_instructions/` - Role prompts for each instance
- `docs/tmops_docs_v6/` - Advanced documentation (if needed)
  - `tmops_protocol.md` - Technical protocol details
  - `tmops_claude_code.md` - Full instance instructions
  - `MIGRATION_FROM_V5.md` - Upgrading from v5

## ⚡ Example: Hello API

```bash
# 1. Initialize
./tmops_tools/init_feature_multi.sh hello-api

# 2. Edit task spec to include:
# - GET /api/hello returns {"message": "Hello, World!"}
# - Status code 200
# - Content-Type: application/json

# 3. Launch instances and coordinate
```

## 🔧 Troubleshooting

**"Old worktrees exist"** - Run cleanup on old feature first  
**"Uncommitted changes"** - Commit or stash before cleanup  
**"Can't create worktree"** - Check git status, may need to commit  

## 📄 License

MIT License - Based on TeamOps by @happycode-ch

---

*For detailed documentation, see docs/ directory*