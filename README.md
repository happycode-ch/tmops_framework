# TeamOps Framework

## Multi-Instance AI Orchestration for Software Development

TeamOps is a sophisticated orchestration protocol that coordinates multiple Claude AI instances to work collaboratively on software development tasks. By dividing responsibilities across specialized instances and using a checkpoint-based communication system, TeamOps enables parallel, conflict-free development with built-in quality gates.

## 🎯 Key Features

- **4-Instance Architecture**: Specialized roles for Orchestrator, Tester, Implementer, and Verifier
- **Checkpoint-Based Communication**: Filesystem-based protocol for inter-instance coordination
- **Test-Driven Development**: Built-in TDD workflow with automated test creation
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

## 🚀 Quick Start

### Prerequisites

- Git with worktree support
- Claude.ai account (for strategic planning)
- Claude Code CLI access (4 terminals)
- Unix-like environment (Linux, macOS, or WSL)

### Setup

1. **Clone the repository**
   ```bash
   git clone git@github.com:happycode-ch/tmops_framework.git
   cd tmops_framework
   ```

2. **Create feature branch and worktrees**
   ```bash
   git checkout -b feature/your-feature
   git worktree add wt-orchestrator feature/your-feature
   git worktree add wt-tester feature/your-feature
   git worktree add wt-impl feature/your-feature
   git worktree add wt-verify feature/your-feature
   ```

3. **Create Task Specification**
   - Use Claude Chat to create `.tmops/<feature>/TASK_SPEC.md`
   - Define acceptance criteria, constraints, and requirements

4. **Launch 4 Claude Code instances**
   ```bash
   # Terminal 1
   cd wt-orchestrator && claude
   # Paste Orchestrator prompt

   # Terminal 2
   cd wt-tester && claude
   # Paste Tester prompt

   # Terminal 3
   cd wt-impl && claude
   # Paste Implementer prompt

   # Terminal 4
   cd wt-verify && claude
   # Paste Verifier prompt
   ```

5. **Monitor checkpoint flow**
   ```bash
   watch -n 2 'ls -la .tmops/*/checkpoints/'
   ```

## 📁 Project Structure

```
.tmops/
└── <feature>/
    ├── TASK_SPEC.md              # Feature requirements
    └── checkpoints/               # Inter-instance communication
        ├── 001-discovery.md       # Orchestrator → Tester
        ├── 003-tests-complete.md  # Tester → Implementer
        ├── 005-impl-complete.md   # Implementer → Verifier
        ├── 007-verify-complete.md # Verifier → Orchestrator
        └── SUMMARY.md            # Final feature summary
```

## 📋 Checkpoint Protocol

Instances communicate exclusively through checkpoint files:

| Checkpoint | From | To | Purpose |
|------------|------|-----|---------|
| 001-discovery | Orchestrator | Tester | Start test phase |
| 003-tests-complete | Tester | Implementer | Tests ready |
| 005-impl-complete | Implementer | Verifier | Implementation done |
| 007-verify-complete | Verifier | Orchestrator | Verification done |
| SUMMARY | Orchestrator | Human | Feature complete |

## 🔒 Quality Gates

Human review points ensure quality at critical phases:

1. **After Test Writing** - Review test coverage and strategy
2. **After Implementation** - Verify all tests pass
3. **After Verification** - Final approval before merge

## 📚 Documentation

- [Complete Protocol Specification](docs/tmops_docs_v4/tmops_orchestration_protocol_4-inst.md)
- [Claude Chat Guide](docs/tmops_docs_v4/tmops_claude_chat_4-inst.md)
- [Claude Code Instance Guide](docs/tmops_docs_v4/tmops_claude_code_4-inst.md)
- [Improvement Roadmap](docs/doc_development/improvement_plan.md)

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

- [ ] Automated checkpoint monitoring tools
- [ ] Visual dashboard for checkpoint flow
- [ ] Integration with CI/CD pipelines
- [ ] Support for more AI models
- [ ] Plugin system for custom instances
- [ ] Performance metrics and analytics

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

**Version:** 5.0.0 | **Status:** Active Development | **Last Updated:** January 2025