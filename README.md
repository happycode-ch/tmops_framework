# TeamOps Framework

## Multi-Instance AI Orchestration for Software Development

TeamOps is a sophisticated orchestration protocol that coordinates multiple Claude AI instances to work collaboratively on software development tasks. By dividing responsibilities across specialized instances and using a checkpoint-based communication system, TeamOps enables parallel, conflict-free development with built-in quality gates.

**Version 6.0.0** introduces manual orchestration for 100% reliability with human-coordinated handoffs between instances.

## 🎯 Key Features

- **4-Instance Architecture**: Specialized roles for Orchestrator, Tester, Implementer, and Verifier
- **Manual Orchestration** (v6.0.0): Human-coordinated handoffs for 100% reliability
- **Checkpoint-Based Communication**: Filesystem-based protocol for inter-instance coordination
- **Test-Driven Development**: Built-in TDD workflow with automated test creation
- **Automated Setup**: One-command feature initialization with `tmops_tools`
- **Comprehensive Logging**: Instance-specific logs for debugging and monitoring
- **Metrics Extraction**: Automatic performance and quality metrics generation
- **Multi-Run Support**: Iterative development with context inheritance
- **Reality-Based Architecture**: Tests and code in standard project locations
- **Quality Gates**: Human review points at critical phases
- **Git Worktree Integration**: Each instance operates in its own isolated environment

## 🏗️ Architecture Overview

```
┌─────────────────────────┐
│    Claude Chat          │ → Strategic Planning & Task Specifications
└────────────┬────────────┘
             │
    ┌────────▼────────┐
    │  Task Spec.md   │
    └────────┬────────┘
             │
┌────────────▼───────────────────────────┐
│        4 Claude Code Instances         │
│                                        │
│  Orchestrator → Tester → Implementer   │
│       ↑                      ↓         │
│       └──────  Verifier  ◄───┘         │
└────────────────────────────────────────┘
```

### Instance Roles

1. **Orchestrator** (wt-orchestrator)
   - Coordinates workflow between instances
   - Monitors progress and timing
   - Creates trigger checkpoints
   - Generates final summary

2. **Tester** (wt-tester)
   - Discovers codebase structure
   - Writes comprehensive failing tests
   - Ensures acceptance criteria coverage
   - Creates test documentation

3. **Implementer** (wt-impl)
   - Reads test requirements
   - Implements features to pass tests
   - Refactors and optimizes code
   - Never modifies test files

4. **Verifier** (wt-verify)
   - Reviews code quality
   - Identifies edge cases
   - Assesses security and performance
   - Provides improvement recommendations

## 🚀 Quick Start (v6.0.0 - Manual Orchestration)

### Prerequisites

- Git with worktree support
- Claude.ai account (for strategic planning)
- Claude Code CLI access (4 terminals)
- Unix-like environment (Linux, macOS, or WSL)
- Python 3.6+ (for metrics extraction)

### Setup & Usage

1. **Clone and navigate**
   ```bash
   git clone git@github.com:happycode-ch/tmops_framework.git
   cd tmops_framework/CODE
   ```

2. **Initialize your feature**
   ```bash
   ./tmops_tools/init_feature_v6.sh my-feature initial
   ```
   This command:
   - Creates `.tmops/` directory structure
   - Sets up 4 git worktrees (wt-orchestrator, wt-tester, wt-impl, wt-verify)
   - Generates TASK_SPEC template
   - Initializes checkpoint and logging directories

3. **Edit Task Specification**
   ```bash
   vim .tmops/my-feature/runs/current/TASK_SPEC.md
   ```

4. **Launch 4 Claude Code instances**
   ```bash
   # Terminal 1: cd wt-orchestrator && claude
   # Terminal 2: cd wt-tester && claude
   # Terminal 3: cd wt-impl && claude
   # Terminal 4: cd wt-verify && claude
   ```
   Paste the appropriate role section from `docs/tmops_docs_v6/tmops_claude_code.md` into each instance.

5. **Coordinate manually**
   - Send `[BEGIN]: Start orchestration for <feature>` to Orchestrator
   - Relay `[CONFIRMED]` messages between instances as they complete
   - No polling or timeouts - 100% reliable!

6. **Clean up after completion**
   ```bash
   ./tmops_tools/cleanup_feature.sh my-feature
   ```
   This removes worktrees, branches, and `.tmops/` artifacts.

## 🛠️ Available Tools

The `tmops_tools/` directory contains essential scripts for the TeamOps workflow:

- **`init_feature_v6.sh`** - Initialize a new feature with worktrees and directory structure
  ```bash
  ./tmops_tools/init_feature_v6.sh <feature-name> [initial|patch]
  ```

- **`cleanup_feature.sh`** - Clean up after feature completion (removes worktrees, branches, artifacts)
  ```bash
  ./tmops_tools/cleanup_feature.sh <feature-name>
  ```

- **`extract_metrics.py`** - Extract performance metrics and generate reports
  ```bash
  ./tmops_tools/extract_metrics.py <feature-name> --format report
  ```

- **`monitor_checkpoints.py`** - Monitor checkpoint creation (optional for v6)
  ```bash
  ./tmops_tools/monitor_checkpoints.py <feature-name>
  ```

## 📁 Project Structure (v6.0.0)

### TeamOps Orchestration Files
```
.tmops/
└── <feature>/
    └── runs/
        ├── 001-initial/           # First run
        │   ├── TASK_SPEC.md      # Feature requirements
        │   ├── checkpoints/       # Inter-instance communication
        │   │   ├── 001-discovery-trigger.md
        │   │   ├── 003-tests-complete.md
        │   │   ├── 005-impl-complete.md
        │   │   ├── 007-verify-complete.md
        │   │   └── SUMMARY.md
        │   ├── logs/              # Instance logs (NEW)
        │   │   ├── orchestrator.log
        │   │   ├── tester.log
        │   │   ├── implementer.log
        │   │   └── verifier.log
        │   └── metrics.json      # Performance metrics (NEW)
        └── current -> 001-initial # Symlink to active run
```

### tmops_tools Directory
```
tmops_tools/
├── init_feature_v6.sh     # Feature initialization with worktrees
├── cleanup_feature.sh     # Complete cleanup after feature
├── extract_metrics.py     # Metrics extraction and reporting
├── monitor_checkpoints.py # Optional checkpoint monitoring
└── templates/             # Checkpoint templates
```

### Where Code Actually Goes
- **Tests**: `test/` or `tests/` in your project (NOT in .tmops)
- **Implementation**: `src/` in your project (NOT in .tmops)
- **TeamOps artifacts**: `.tmops/<feature>/` only

## 📋 Checkpoint Protocol (v6.0.0 Manual Coordination)

Instances communicate exclusively through checkpoint files using NNN-phase-status naming:

| Checkpoint | From | To | Purpose |
|------------|------|-----|---------|
| 001-discovery-trigger | Orchestrator | Tester | Start test phase |
| 003-tests-complete | Tester | Orchestrator | Tests written and failing |
| 004-impl-trigger | Orchestrator | Implementer | Start implementation |
| 005-impl-complete | Implementer | Orchestrator | All tests passing |
| 006-verify-trigger | Orchestrator | Verifier | Start verification |
| 007-verify-complete | Verifier | Orchestrator | Quality review done |
| SUMMARY.md | Orchestrator | Human | Feature complete with metrics |

## 🔒 Quality Gates

Human review points ensure quality at critical phases:

1. **After Test Writing** - Review test coverage and strategy
2. **After Implementation** - Verify all tests pass
3. **After Verification** - Final approval before merge

## 📚 Documentation

### Version 6.0.0 Documentation (Current)
- [Manual Orchestration Guide](docs/tmops_docs_v6/tmops_claude_code.md) - Complete v6 manual process
- [Migration from v5](docs/tmops_docs_v6/MIGRATION_FROM_V5.md) - Upgrade guide

### Legacy Documentation
- Previous versions archived in `.archive/` directory

## 🤝 Contributing

We welcome contributions! Please:

1. Fork the repository
2. Create a feature branch
3. Follow the TeamOps protocol for development
4. Submit a pull request with clear documentation
5. Maintain attribution per license requirements

## 📄 License

MIT License with Attribution Requirement - see [LICENSE](LICENSE) file.

When using this framework, please include:
> Based on TeamOps Framework by Anthony Calek (https://github.com/happycode-ch/tmops_framework)

## 🎯 Use Cases

- **Complex Feature Development**: Coordinate multiple aspects of feature implementation
- **Test-Driven Development**: Enforce TDD practices automatically
- **Code Review Workflows**: Built-in verification and quality checks
- **Learning Tool**: Understand AI orchestration and software development patterns
- **Team Simulation**: Experience how specialized roles collaborate

## 🚧 Roadmap

### Completed in v6.0.0
- [x] Manual orchestration for 100% reliability
- [x] Human-coordinated handoffs between instances
- [x] Elimination of polling and timeouts
- [x] Clear status reporting from each instance
- [x] Simplified debugging and control

### Completed in v7.0 Exploration
- [x] Automated orchestration attempt with subagents and hooks
- [x] Comprehensive analysis of Claude Code capabilities
- [x] Gap analysis between expected and actual features
- [x] MCP architecture design for true automation

### Future Enhancements
- [ ] MCP server implementation (In Development)
- [ ] Visual dashboard for checkpoint flow
- [ ] Integration with CI/CD pipelines
- [ ] Support for more AI models
- [ ] Plugin system for custom instances
- [ ] Web-based monitoring interface

## 💡 Philosophy

TeamOps embodies the principle that complex software development benefits from specialized, focused roles working in coordination. By separating concerns across instances and enforcing clear communication protocols, we achieve:

- **Clarity**: Each instance has a single, well-defined responsibility
- **Quality**: Multiple review points ensure high standards
- **Efficiency**: Parallel execution without conflicts
- **Traceability**: Complete audit trail via checkpoints

## 🔗 Links

- [GitHub Repository](https://github.com/happycode-ch/tmops_framework)
- [Issue Tracker](https://github.com/happycode-ch/tmops_framework/issues)
- [Discussions](https://github.com/happycode-ch/tmops_framework/discussions)

## 📧 Contact

Created by Anthony Calek - [GitHub Profile](https://github.com/happycode-ch)

---

**Version:** 6.0.0 (Stable) | v7.0 (Experimental) | **Status:** Active Development | **Last Updated:** January 2025

### What's New in v6.0.0
- **Manual Orchestration**: Human-coordinated handoffs for 100% reliability
- **No Polling**: Eliminated all automated polling and timeout issues
- **Clear Communication**: Explicit status messages from each instance
- **Simplified Control**: Direct human control over workflow progression
- **Enhanced Debugging**: Easier to troubleshoot with manual coordination
- **Maintained Features**: All v5 logging, metrics, and multi-run support retained

## 🔬 Version 7.0: Automation Exploration & Learnings

TeamOps v7 represented an ambitious attempt to achieve **fully automated orchestration** using Claude Code's subagent and hook capabilities. While the implementation revealed important limitations, it provided valuable insights that point toward more robust solutions.

### The v7 Vision
- Automated TDD workflow with specialized subagents
- Hook-based orchestration and phase transitions
- Role-enforced tool restrictions
- Zero manual intervention required

### What We Learned

Through extensive testing and analysis, we discovered critical gaps between expected and actual Claude Code capabilities:

1. **Subagents as Templates, Not Instances**: Custom subagent types don't create isolated instances - they function as prompt templates within a single Claude context
2. **Hooks for Monitoring, Not Control**: Hooks can observe and log but cannot orchestrate Claude's workflow or force phase transitions
3. **Advisory vs. Enforced Restrictions**: Tool restrictions remain suggestions rather than hard constraints

For detailed technical analysis, see our comprehensive reports:
- [v7 Truth Analysis](docs/tmops_docs_v7/v7_truth_analysis.md) - Deep dive into subagent and hook realities
- [v7 Analysis & Fix](docs/tmops_docs_v7/v7_analysis_and_fix.md) - SDK-based solutions for true automation
- [v7 MCP Solution](docs/tmops_docs_v7/v7_mcp_solution.md) - Model Context Protocol as the orchestration layer

### The Path Forward: MCP Integration

The Model Context Protocol (MCP) emerges as the most promising solution for achieving v7's automation goals. MCP servers can provide:
- Dynamic tool availability based on workflow phase
- Programmatic state management and transitions
- True role enforcement through server-controlled permissions
- Intelligent orchestration without manual intervention

Development of an MCP-based TeamOps server is planned as the next evolution of the framework.

### Key Takeaway

While v7's initial implementation didn't achieve full automation, it served as a crucial exploration that:
- Clarified the boundaries of current Claude Code capabilities
- Identified the need for external orchestration layers
- Pointed toward MCP as the architectural solution
- Demonstrated the value of iterative framework development

The v7 artifacts remain in the codebase as a learning resource and foundation for future MCP integration.