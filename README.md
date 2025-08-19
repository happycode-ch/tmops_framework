# TeamOps Framework

## Multi-Instance AI Orchestration for Software Development

TeamOps is a sophisticated orchestration protocol that coordinates multiple Claude AI instances to work collaboratively on software development tasks. By dividing responsibilities across specialized instances and using a checkpoint-based communication system, TeamOps enables parallel, conflict-free development with built-in quality gates.

**Version 5.2.0** brings reality-based architecture, automated setup tools, comprehensive logging, and metrics extraction.

## 🎯 Key Features

- **4-Instance Architecture**: Specialized roles for Orchestrator, Tester, Implementer, and Verifier
- **Checkpoint-Based Communication**: Filesystem-based protocol for inter-instance coordination
- **Test-Driven Development**: Built-in TDD workflow with automated test creation
- **Automated Setup** (v5.2.0): One-command feature initialization with `tmops_tools`
- **Comprehensive Logging** (v5.2.0): Instance-specific logs for debugging and monitoring
- **Metrics Extraction** (v5.2.0): Automatic performance and quality metrics generation
- **Multi-Run Support** (v5.2.0): Iterative development with context inheritance
- **Reality-Based Architecture** (v5.2.0): Tests and code in standard project locations
- **Quality Gates**: Human review points at critical phases
- **Parallel Execution**: Multiple instances work simultaneously without conflicts
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

## 🚀 Quick Start (v5.2.0 - Automated!)

### Prerequisites

- Git with worktree support
- Claude.ai account (for strategic planning)
- Claude Code CLI access (4 terminals)
- Unix-like environment (Linux, macOS, or WSL)
- Python 3.6+ (for monitoring tools)

### 5-Minute Setup

1. **Clone and navigate**
   ```bash
   git clone git@github.com:happycode-ch/tmops_framework.git
   cd tmops_framework/CODE
   ```

2. **Initialize your feature (NEW - Automated!)**
   ```bash
   ./tmops_tools/init_feature.sh my-feature initial
   ```
   This single command:
   - Creates directory structure
   - Sets up git worktrees
   - Generates TASK_SPEC template
   - Initializes logging directories

3. **Edit Task Specification**
   ```bash
   vim .tmops/my-feature/runs/current/TASK_SPEC.md
   ```

4. **Launch 4 Claude Code instances**
   Open 4 terminals and paste the prompts from [docs/tmops_docs_v5/quickstart.md](docs/tmops_docs_v5/quickstart.md)

5. **Monitor progress**
   ```bash
   # Watch checkpoints
   watch -n 2 'ls -la .tmops/my-feature/runs/current/checkpoints/'
   
   # Monitor logs (NEW)
   tail -f .tmops/my-feature/runs/current/logs/*.log
   
   # Extract metrics (NEW)
   ./tmops_tools/extract_metrics.py my-feature --format report
   ```

For detailed instructions, see the [Quick Start Guide](docs/tmops_docs_v5/quickstart.md).

## 📁 Project Structure (v5.2.0)

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

### Automation Tools (NEW)
```
tmops_tools/
├── init_feature.sh        # One-command feature setup
├── monitor_checkpoints.py # Checkpoint monitoring with backoff
├── extract_metrics.py     # Metrics extraction and reporting
└── templates/             # Checkpoint templates
```

### Where Code Actually Goes
- **Tests**: `test/` or `tests/` in your project (NOT in .tmops)
- **Implementation**: `src/` in your project (NOT in .tmops)
- **TeamOps artifacts**: `.tmops/<feature>/` only

## 📋 Checkpoint Protocol (v5.2.0 Standardized)

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

### Version 5.2.0 Documentation (Current)
- [Quick Start Guide](docs/tmops_docs_v5/quickstart.md) - Get started in 5 minutes
- [Complete Protocol Specification](docs/tmops_docs_v5/tmops_protocol.md) - Technical details
- [Claude Chat Guide](docs/tmops_docs_v5/tmops_claude_chat.md) - Strategic planning
- [Claude Code Instance Guide](docs/tmops_docs_v5/tmops_claude_code.md) - Instance roles

### Development Documentation
- [v5.2.0 Implementation Plan](docs/doc_development/tmops-v520-plan.md)
- [Improvement Roadmap](docs/doc_development/improvement_plan.md)

### Legacy Documentation (v5.0.0)
- [v4 Protocol](docs/tmops_docs_v4/tmops_orchestration_protocol_4-inst.md)
- [v4 Chat Guide](docs/tmops_docs_v4/tmops_claude_chat_4-inst.md)
- [v4 Code Guide](docs/tmops_docs_v4/tmops_claude_code_4-inst.md)

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

### Completed in v5.2.0
- [x] Automated checkpoint monitoring tools (`tmops_tools/monitor_checkpoints.py`)
- [x] Performance metrics and analytics (`tmops_tools/extract_metrics.py`)
- [x] Automated feature initialization (`tmops_tools/init_feature.sh`)
- [x] Instance-specific logging system
- [x] Multi-run support with context inheritance
- [x] Reality-based file locations

### Future Enhancements
- [ ] Visual dashboard for checkpoint flow
- [ ] Integration with CI/CD pipelines
- [ ] Support for more AI models
- [ ] Plugin system for custom instances
- [ ] Web-based monitoring interface
- [ ] MCP server implementation

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

**Version:** 5.2.0 | **Status:** Active Development | **Last Updated:** January 2025

### What's New in v5.2.0
- **Automated Setup**: One-command feature initialization with `tmops_tools/init_feature.sh`
- **Reality-Based Architecture**: Tests and code stay in standard project directories
- **Comprehensive Logging**: Every instance logs actions for debugging and monitoring
- **Metrics Extraction**: Automatic performance and quality metrics generation
- **Multi-Run Support**: Patch runs with context inheritance for iterative development
- **Enhanced Monitoring**: Tools for real-time checkpoint and log monitoring