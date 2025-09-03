<div align="center">
  <div style="background-color: #DC143C; color: white; padding: 20px; border-radius: 8px; font-family: monospace; font-size: 24px; font-weight: bold; margin: 20px 0;">
    <pre style="color: white; margin: 0; background: none;">
████████╗███╗   ███╗ ██████╗ ██████╗ ███████╗
╚══██╔══╝████╗ ████║██╔═══██╗██╔══██╗██╔════╝
   ██║   ██╔████╔██║██║   ██║██████╔╝███████╗
   ██║   ██║╚██╔╝██║██║   ██║██╔═══╝ ╚════██║
   ██║   ██║ ╚═╝ ██║╚██████╔╝██║     ███████║
   ╚═╝   ╚═╝     ╚═╝ ╚═════╝ ╚═╝     ╚══════╝
    </pre>
  </div>
</div>

## Multi-Instance AI Orchestration Workflow

TeamOps or tmops (as I refer to it) is a sophisticated orchestration protocol that coordinates multiple Claude AI instances to work collaboratively on software development tasks. By dividing responsibilities across specialized instances and using a checkpoint-based communication system, tmops enables parallel, conflict-free development with built-in quality gates.

tmops introduces comprehensive AI-ready templates and enhanced documentation structure for complete development workflows.

## 🎯 Key Features

- **Dual Workflow Options**: Standard 4-instance or extended 7-instance preflight workflow
- **AI-Ready Templates**: 8 comprehensive markdown templates for complete development workflow
- **Documentation Structure**: Organized docs/internal and docs/external folders per feature
- **Manual Orchestration**: Human-coordinated handoffs for 100% reliability
- **Checkpoint-Based Communication**: Filesystem-based protocol for inter-instance coordination
- **Test-Driven Development**: Built-in TDD workflow with automated test creation
- **Automated Setup**: One-command feature initialization with `tmops_tools`
- **Comprehensive Logging**: Instance-specific logs for debugging and monitoring
- **Metrics Extraction**: Automatic performance and quality metrics generation
- **Multi-Run Support**: Iterative development with context inheritance
- **Reality-Based Architecture**: Tests and code in standard project locations
- **Quality Gates**: Human review points at critical phases

## 🎯 Use Cases

- **Complex Feature Development**: Coordinate multiple aspects of feature implementation
- **Test-Driven Development**: Enforce TDD practices automatically
- **Code Review Workflows**: Built-in verification and quality checks
- **Learning Tool**: Understand AI orchestration and software development patterns
- **Team Simulation**: Experience how specialized roles collaborate

## 💡 Philosophy

tmops embodies the principle that complex software development benefits from specialized, focused roles working in coordination. By separating concerns across instances and enforcing clear communication protocols, we achieve:

- **Clarity**: Each instance has a single, well-defined responsibility
- **Quality**: Multiple review points ensure high standards
- **Efficiency**: Sequential, specialized execution with clear handoff protocols
- **Traceability**: Complete audit trail via checkpoints

### Why Separate Instances Over Subagents?

tmops deliberately uses separate Claude Code instances rather than subagents for two critical technical reasons. First, each subagent operates within Claude Code's 20,000 token response limit, which constrains the depth and complexity of outputs during intensive development phases like comprehensive test creation or detailed code reviews. Second, and more importantly, separate instances prevent *context contamination*—the gradual degradation that occurs when diverse conversational threads introduce noise into a shared context window. By maintaining isolated contexts, tmops ensures each specialized role (Orchestrator, Tester, Implementer, Verifier) operates with maximum clarity and focus, preventing the context degradation syndrome that can cause AI models to lose coherence over extended development sessions. This architectural choice prioritizes conversation quality and role-specific precision over convenience, resulting in more reliable and predictable AI-assisted development workflows.

## 🚀 Quick Start

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
   ./tmops_v6_portable/tmops_tools/init_feature_multi.sh my-feature
   ```
   This command:
   - Creates `.tmops/my-feature/` directory structure
   - Creates `docs/internal/` and `docs/external/` folders
   - Creates feature branch `feature/my-feature`
   - Generates TASK_SPEC.md template
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

## 🛠️ Tools

Essential scripts for the tmops workflow:

- **`init_feature_multi.sh`** - Initialize new features with complete directory structure
  ```bash
  ./tmops_v6_portable/tmops_tools/init_feature_multi.sh <feature-name>
  ```

- **`cleanup_safe.sh`** - Safely clean up features with backups and archiving
  ```bash
  ./tmops_v6_portable/tmops_tools/cleanup_safe.sh <feature-name>
  ```

- **`extract_metrics.py`** - Extract performance and quality metrics
  ```bash
  ./tmops_v6_portable/tmops_tools/extract_metrics.py <feature-name> --format report
  ```

- **`monitor_checkpoints.py`** - Monitor checkpoint creation with logging
  ```bash
  ./tmops_v6_portable/tmops_tools/monitor_checkpoints.py <feature-name>
  ```

## 📁 Project Structure

### tmops Orchestration Files
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

### Where Code Actually Goes
- **Tests**: `test/` or `tests/` in your project (NOT in .tmops)
- **Implementation**: `src/` in your project (NOT in .tmops)
- **tmops artifacts**: `.tmops/<feature>/` only

## 🏗️ How It Works

tmops uses two workflow options depending on complexity:

### Standard Workflow (4-Instance)
```
┌─────────────────────────┐
│    Claude Chat          │ → Basic Task Specification
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

### Preflight Workflow (7-Instance for Complex Features)
```
┌─────────────────────────┐
│    Initial Concept      │ → High-level requirements
└────────────┬────────────┘
             │
┌────────────▼───────────────────────────┐
│     3 Preflight Instances              │
│                                        │
│  Researcher → Analyzer → Specifier     │
│                            ↓           │
└─────────────────────┬──────────────────┘
                      │ 
             ┌────────▼────────┐
             │ Refined Spec.md │ → Comprehensive specification
             └────────┬────────┘
                      │
┌────────────────────▼───────────────────┐
│        4 Main Instances (auto-handoff) │
│                                        │
│  Orchestrator → Tester → Implementer   │
│       ↑                      ↓         │
│       └──────  Verifier  ◄───┘         │
└────────────────────────────────────────┘
```

## 🏗️ Detailed Architecture

### Instance Roles

#### Preflight Instances (Optional - for Complex Features)
1. **Preflight Researcher**
   - Investigates existing codebase patterns
   - Researches relevant libraries and frameworks
   - Documents integration points and constraints
   - Identifies technical risks and opportunities

2. **Preflight Analyzer**
   - Performs deep technical architecture analysis
   - Designs implementation approach using discovered patterns
   - Plans code organization and structure  
   - Creates detailed technical specifications

3. **Preflight Specifier**
   - Reviews and validates research and analysis
   - Creates comprehensive, implementation-ready task specification
   - Has rejection authority if inputs are inadequate
   - Ensures seamless handoff to main workflow

#### Main Workflow Instances
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

## 📋 Checkpoint Protocol

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

### Preflight Workflow (7-Instance) Quality Gates
1. **After Research** - Review codebase analysis and integration points
2. **After Analysis** - Validate technical architecture and implementation approach
3. **After Specification** - Approve comprehensive specification before main workflow handoff

### Main Workflow Quality Gates
4. **After Test Writing** - Review test coverage and strategy
5. **After Implementation** - Verify all tests pass
6. **After Verification** - Final approval before merge

## 📚 Documentation

### Templates

tmops includes 8 AI-ready markdown templates for complete development workflows:

1. **Research** (`00_research_template.md`) - Prior art analysis and feasibility studies
2. **Planning** (`01_plan_template.md`) - Strategic approach and resource allocation
3. **Discovery** (`02_discovery_template.md`) - Codebase analysis and gap identification
4. **Proposal** (`03_proposal_template.md`) - Solution design with alternatives
5. **Implementation** (`04_implementation_template.md`) - Change documentation and verification
6. **Task Specification** (`05_task_spec_template.md`) - Detailed requirements and acceptance criteria
7. **Summary** (`06_summary_template.md`) - Project retrospectives and ROI analysis
8. **Review** (`07_review_template.md`) - Final acceptance and go/no-go decisions

Templates are located in `tmops_v6_portable/templates/` and support complexity profiles (lite/standard/deep).

### Documentation Structure

Each feature maintains its own documentation:
- `.tmops/<feature>/docs/internal/` - AI-generated documentation
- `.tmops/<feature>/docs/external/` - Human-created documentation

### Core Documentation
- [CLAUDE.md](tmops_v6_portable/CLAUDE.md) - Framework context and guidance for Claude Code
- [Manual Orchestration Guide](tmops_v6_portable/docs/tmops_docs_v6/tmops_claude_code.md) - Complete v6 manual process
- [Instance Instructions](tmops_v6_portable/instance_instructions/) - Role-specific guides for each instance

## 🤝 Contributing

We welcome contributions! Please:

1. Fork the repository
2. Create a feature branch
3. Follow the tmops protocol for development
4. Submit a pull request with clear documentation
5. Maintain attribution per license requirements

## 📄 License

MIT License with Attribution Requirement - see [LICENSE](LICENSE) file.

When using tmops, please include:
> Based on tmops by Anthony Calek (https://github.com/happycode-ch/tmops_framework)

## 🚧 Roadmap

### Completed
- [x] Manual orchestration for 100% reliability
- [x] Human-coordinated handoffs between instances
- [x] Elimination of polling and timeouts
- [x] Clear status reporting from each instance
- [x] Simplified debugging and control

### Archived Exploration
- [x] Automated orchestration attempt with subagents and hooks
- [x] Comprehensive analysis of Claude Code capabilities
- [x] Gap analysis between expected and actual features
- [x] MCP architecture design for true automation
- [x] Archived to .archive/ for reference and refactoring

### In Active Development
- [ ] **Enhanced Integration** - Integrating subagents and hooks into manual orchestration
- [ ] **MCP Service** - Model Context Protocol implementation for full automation

### Future Enhancements
- [ ] Visual dashboard for checkpoint flow
- [ ] Integration with CI/CD pipelines
- [ ] Support for more AI models
- [ ] Plugin system for custom instances
- [ ] Web-based monitoring interface

## 🔗 Links

- [GitHub Repository](https://github.com/happycode-ch/tmops_framework)
- [Issue Tracker](https://github.com/happycode-ch/tmops_framework/issues)
- [Discussions](https://github.com/happycode-ch/tmops_framework/discussions)

## 📧 Contact

Created by Anthony Calek - [GitHub Profile](https://github.com/happycode-ch)

---

**Status:** Active Development | **Last Updated:** September 2025

### Latest Updates
- **AI-Ready Templates**: 8 comprehensive markdown templates for complete workflow
- **Documentation Structure**: New docs/internal and docs/external folders per feature
- **Enhanced Scripts**: Updated tmops_tools to support new documentation structure
- **Template System**: From research to review, complete development lifecycle coverage
- **Improved Organization**: Historical docs moved to .docs/, templates in dedicated directory