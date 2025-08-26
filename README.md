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

1. **Orchestrator**
   - Coordinates workflow between instances
   - Monitors progress and timing
   - Creates trigger checkpoints
   - Generates final summary

2. **Tester**
   - Discovers codebase structure
   - Writes comprehensive failing tests
   - Ensures acceptance criteria coverage
   - Creates test documentation

3. **Implementer**
   - Reads test requirements
   - Implements features to pass tests
   - Refactors and optimizes code
   - Never modifies test files

4. **Verifier**
   - Reviews code quality
   - Identifies edge cases
   - Assesses security and performance
   - Provides improvement recommendations

## 🚀 Quick Start (v6.0.0 - Manual Orchestration)

### Prerequisites

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
   - Creates feature branch
   - Generates TASK_SPEC template
   - Initializes checkpoint and logging directories

3. **Edit Task Specification**
   ```bash
   vim .tmops/my-feature/runs/current/TASK_SPEC.md
   ```

4. **Launch 4 Claude Code instances from project root**
   ```bash
   # Terminal 1: claude  # Paste tmops_v6_portable/instance_instructions/01_orchestrator.md
   # Terminal 2: claude  # Paste tmops_v6_portable/instance_instructions/02_tester.md
   # Terminal 3: claude  # Paste tmops_v6_portable/instance_instructions/03_implementer.md
   # Terminal 4: claude  # Paste tmops_v6_portable/instance_instructions/04_verifier.md
   ```
   Copy and paste the respective role instructions to prime each instance.

5. **Coordinate manually**
   - Send `[BEGIN]: Start orchestration for <feature>` to Orchestrator
   - Relay `[CONFIRMED]` messages between instances as they complete
   - No polling or timeouts - 100% reliable!

6. **Clean up after completion**
   ```bash
   ./tmops_tools/cleanup_feature.sh my-feature
   ```
   This removes branches and `.tmops/` artifacts.

## 🛠️ Available Tools

The `tmops_tools/` directory contains essential scripts for the TeamOps workflow:

- **`init_feature_v6.sh`** - Initialize a new feature with directory structure
  ```bash
  ./tmops_tools/init_feature_v6.sh <feature-name> [initial|patch]
  ```

- **`cleanup_feature.sh`** - Clean up after feature completion (removes branches, artifacts)
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
├── init_feature_v6.sh     # Feature initialization
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

### Completed in v7.0 Exploration (Archived)
- [x] Automated orchestration attempt with subagents and hooks
- [x] Comprehensive analysis of Claude Code capabilities
- [x] Gap analysis between expected and actual features
- [x] MCP architecture design for true automation
- [x] Archived to .archive/ for reference and refactoring

### In Active Development
- [ ] **Enhanced v6** - Integrating subagents and hooks into manual orchestration
- [ ] **Version 8.0** - MCP Service implementation for full automation

### Future Enhancements
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

## 🔬 Version 7.0: Archived for Refactoring

### Current Status: Archived (January 2025)

TeamOps v7 explored **fully automated orchestration** using Claude Code's subagent and hook capabilities. After thorough testing and analysis, v7 has been **archived** to `.archive/` for refactoring. The implementation revealed important architectural insights that will guide future development.

### What v7 Revealed

Through extensive testing, we discovered critical gaps between expected and actual Claude Code capabilities:

1. **Subagents as Templates, Not Instances**: Custom subagent types function as prompt templates rather than isolated instances
2. **Hooks for Monitoring, Not Control**: Hooks provide feedback but cannot orchestrate workflow transitions
3. **Advisory vs. Enforced Restrictions**: Tool restrictions remain suggestions rather than hard constraints

### Development Roadmap

#### Enhanced v6 (In Development)
We are refactoring v7's valuable concepts into an **enhanced v6** that will:
- Integrate subagent support within the manual orchestration framework
- Implement hooks for monitoring and notifications (not control)
- Maintain v6's reliability while adding v7's innovative features
- Provide a stable bridge between manual control and future automation

#### Version 8.0: MCP Service (Planning)
The Model Context Protocol (MCP) represents the true path to automation:
- **MCP Servers** will provide the missing orchestration layer
- Dynamic tool availability based on workflow phase
- Programmatic state management and transitions
- True role enforcement through server-controlled permissions
- Full automation without sacrificing reliability

### Archive Contents

All v7 materials have been preserved in `.archive/` for reference:
- **tmops_docs_v7/** - Complete documentation and analysis reports
- **tmops_tools_v7/** - Full implementation including hooks and agents
- **hello_v7_feature/** - Working example with test results
- **v7_archive_README.md** - Detailed archive documentation

### Key Takeaway

v7's exploration was invaluable in understanding the boundaries of current tooling and pointing toward better architectural solutions. Rather than forcing automation through unsupported features, we're taking a pragmatic approach: enhancing v6 with proven concepts while developing v8's MCP-based architecture for true automation.