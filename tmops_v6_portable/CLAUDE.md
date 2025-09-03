<!--
📁 FILE: /home/anthonycalek/projects/tmops_framework/CODE/tmops_v6_portable/CLAUDE.md
🎯 PURPOSE: Portable framework documentation for AI-driven development workflows
🤖 AI-HINT: Core instructions for TeamOps v6 framework usage - defines workflow patterns and instance coordination
🔗 DEPENDENCIES: tmops_tools/, instance_instructions/, templates/
📝 CONTEXT: Self-contained framework that ships with projects, supports 4-instance and 7-instance workflows
-->

# TeamOps Framework v6 - Simplified Edition

## Framework Overview
TeamOps is a Test-Driven Development orchestration framework that coordinates Claude Code instances working sequentially to build features. This portable framework provides tools and templates for rapid, high-quality feature development using AI agents.

**Two Workflow Options:**
- **Standard (4-instance):** Direct implementation for straightforward features
- **Preflight (7-instance):** Research → Analysis → Specification → Implementation for complex features

**Purpose:** Enable efficient TDD workflows by orchestrating specialized AI instances through structured phases, with optional preflight specification refinement for complex features.

## Critical Context for Claude
- **Two workflow options available** - Choose standard (fast) or preflight (thorough) based on feature complexity
- **Sequential workflow is mandatory** - Only one instance works at a time, in specific order  
- **Preflight creates refined specifications** - 3-instance workflow that automatically hands off to main workflow
- **Framework lives in tmops_v6_portable/** - But all work happens in parent project directory
- **Artifacts go in parent .tmops/** - Never modify files in tmops_v6_portable itself
- **Smart handoff system** - Main workflow auto-detects and uses preflight-refined specifications

## Tech Stack & Dependencies
- **Shell Scripts:** Bash-based orchestration tools
- **Python:** Metrics extraction and monitoring (Python 3.6+)
- **Git:** Feature branch management (no worktrees)
- **Claude Code CLI:** 4 instances required for full orchestration

## Framework Structure
```
tmops_v6_portable/           # Framework directory (DO NOT MODIFY)
├── tmops_tools/            # Orchestration scripts
│   ├── init_feature_multi.sh    # Start standard workflow (auto-detects refined specs)
│   ├── init_preflight.sh        # Start preflight workflow (3-instance refinement)
│   ├── lib/                     # Shared function library
│   ├── cleanup_safe.sh          # Clean up features
│   ├── list_features.sh         # Show active features
│   ├── switch_feature.sh        # Display feature info
│   └── extract_metrics.py       # Performance analysis
├── instance_instructions/   # Role definitions for all instances
│   ├── 01_orchestrator.md       # Main workflow: Orchestrator
│   ├── 02_tester.md             # Main workflow: Tester  
│   ├── 03_implementer.md        # Main workflow: Implementer
│   ├── 04_verifier.md           # Main workflow: Verifier
│   ├── 02_preflight_researcher.md  # Preflight: Researcher
│   ├── 03_preflight_analyzer.md    # Preflight: Analyzer
│   └── 04_preflight_specifier.md   # Preflight: Specifier
├── templates/              # AI-ready markdown templates
└── docs/                   # Framework documentation

Parent Directory Structure (Created by framework):
.tmops/                     # TeamOps artifacts (auto-created)
├── [feature-name]/        # Per-feature workspace
│   ├── docs/             
│   │   ├── internal/     # AI-generated docs
│   │   └── external/     # Human-created docs
│   └── checkpoints/      # Phase completion markers
src/                       # Implementation goes here
test/                      # Tests go here
```

## Commands & Workflows

### Choosing Your Workflow

#### Standard Workflow (Straightforward Features)
```bash
# From tmops_v6_portable directory
cd tmops_v6_portable
./tmops_tools/init_feature_multi.sh my-feature

# This creates:
# - Feature branch: feature/my-feature  
# - Basic task spec template
# - Documentation folders: internal/ and external/
# - Ready for 4-instance orchestration
```

#### Preflight Workflow (Complex Features)
```bash
# Step 1: Start preflight specification refinement
cd tmops_v6_portable
./tmops_tools/init_preflight.sh my-feature

# Step 2: Run 3-instance preflight workflow
# Researcher → Analyzer → Specifier (creates refined specification)

# Step 3: Automatic handoff to main workflow
./tmops_tools/init_feature_multi.sh my-feature
# Auto-detects refined spec, skips template, ready for main orchestration

# Result: 7-instance total workflow with comprehensive specification
```

### Managing Features
```bash
# List all active features
./tmops_tools/list_features.sh

# Show feature details (paths, status)
./tmops_tools/switch_feature.sh my-feature

# Clean up a feature (safe mode - preserves code)
./tmops_tools/cleanup_safe.sh my-feature

# Full cleanup (removes all artifacts and code)
./tmops_tools/cleanup_safe.sh my-feature full

# Extract performance metrics
./tmops_tools/extract_metrics.py my-feature
```

### Pre-commit Checklist
When working on implementation:
1. Ensure all tests pass
2. Verify no files modified in tmops_v6_portable/
3. Check that changes are on correct feature branch
4. Confirm .tmops/ artifacts are properly structured

## Orchestration Protocol

### Standard Workflow Phase Sequence (4-Instance)
1. **Orchestrator** - Creates plan and coordinates phases
2. **Tester** - Writes failing tests based on spec
3. **Implementer** - Makes tests pass
4. **Verifier** - Reviews quality and completeness

### Preflight Workflow Phase Sequence (7-Instance) 
**Preflight Phases (Specification Refinement):**
1. **Preflight Researcher** - Investigates codebase patterns and technical context
2. **Preflight Analyzer** - Performs deep technical analysis and implementation planning
3. **Preflight Specifier** - Creates comprehensive, implementation-ready specification

**Main Phases (Implementation - same as standard):**
4. **Orchestrator** - Coordinates implementation using refined spec
5. **Tester** - Writes failing tests based on refined spec
6. **Implementer** - Makes tests pass
7. **Verifier** - Reviews quality and completeness

### Checkpoint System
Each phase creates a checkpoint file in `.tmops/[feature]/runs/initial/checkpoints/`:

**Standard Workflow Checkpoints:**
- `orchestrator_ready.checkpoint` - Triggers Tester
- `tester_complete.checkpoint` - Triggers Implementer  
- `implementer_complete.checkpoint` - Triggers Verifier
- `verifier_complete.checkpoint` - Feature complete

**Preflight Workflow Checkpoints:**
- `preflight_research_complete.checkpoint` - Triggers Analyzer
- `preflight_analysis_complete.checkpoint` - Triggers Specifier
- `preflight_specification_complete.checkpoint` - Triggers handoff to main workflow
- `preflight_specification_rejected.checkpoint` - Specification rejected, needs rework
- *(Then standard workflow checkpoints as above)*

### When to Choose Each Workflow

**Use Standard Workflow When:**
- ✅ Feature requirements are clear and well-understood
- ✅ Implementation approach is straightforward  
- ✅ Similar patterns already exist in the codebase
- ✅ Low-medium complexity changes
- ✅ Time-sensitive delivery needed

**Use Preflight Workflow When:**
- 🔬 Requirements need research and analysis
- 🔬 Complex integrations or new patterns required
- 🔬 High-risk or high-impact features
- 🔬 Stakeholder alignment needed before implementation
- 🔬 Learning new domain or technology

### Human Coordination Commands
```
User → Instance: "[BEGIN]: Start [phase] for [feature]"
Instance → User: "[ROLE] COMPLETE: [Status message]"
User → Orchestrator: "[CONFIRMED]: [Role] has completed"
```

## Templates & Documentation

### Available Templates
All in `tmops_v6_portable/templates/`:
- `00_research_template.md` - Prior art analysis
- `01_plan_template.md` - Strategic planning
- `02_discovery_template.md` - Codebase analysis
- `03_proposal_template.md` - Solution design
- `04_implementation_template.md` - Change documentation
- `05_task_spec_template.md` - Requirements (PRIMARY)
- `06_summary_template.md` - Retrospectives
- `07_review_template.md` - Final acceptance

### Template Usage
- Templates include embedded AI instructions
- Support lite/standard/deep complexity profiles
- Auto-referenced by orchestration scripts
- Filled templates saved to `.tmops/[feature]/docs/internal/`

## Architectural Patterns

### TDD Enforcement
- Tests MUST be written before implementation
- Implementation MUST only make tests pass
- No feature code without corresponding tests
- Verification ensures TDD compliance

### Branch Strategy
- Single feature branch per feature
- No worktrees or parallel development
- All instances share the same branch
- Sequential commits maintain clean history

### Documentation Flow
- Task spec is source of truth
- Internal docs are AI-generated
- External docs are human-created
- Templates ensure consistency

## Common Tasks

### Adding Test Cases
1. Tester reads task spec from `.tmops/[feature]/docs/05_task_spec.md`
2. Creates test files in `test/` directory
3. Writes failing tests with clear assertions
4. Creates `tester_complete.checkpoint`

### Implementing Features
1. Implementer reads failing tests
2. Creates minimal code in `src/` to pass tests
3. Runs tests to verify all pass
4. Creates `implementer_complete.checkpoint`

### Reviewing Changes
1. Verifier examines test coverage
2. Reviews code quality and patterns
3. Checks TDD compliance
4. Creates `verifier_complete.checkpoint`

## Security & Compliance

### Framework Security Rules
- NEVER expose orchestration checkpoints publicly
- Keep `.tmops/` in .gitignore
- Don't commit incomplete feature states
- Sanitize any credentials in task specs

### Code Review Requirements
- All features must pass Verifier review
- TDD compliance is mandatory
- Test coverage must be comprehensive
- No implementation without tests

## Performance Considerations

### Metrics Tracking
- Each phase is timed automatically
- Metrics extracted via `extract_metrics.py`
- Performance data stored in `.tmops/[feature]/metrics/`
- Use for continuous improvement

### Optimization Points
- Keep task specs focused and clear
- Minimize inter-phase dependencies
- Use templates to reduce planning time
- Cache common patterns in external docs

## Troubleshooting

### Common Issues
- **"Checkpoint not found"** - Ensure on correct feature branch
- **"Already exists"** - Run cleanup_safe.sh first
- **"Permission denied"** - Check script permissions (chmod +x)
- **"Not in git repo"** - Framework requires git initialization

### Instance Coordination Problems
- Verify all instances in project root (not tmops_v6_portable/)
- Check git branch consistency across instances
- Ensure checkpoints created in correct order
- Validate task spec exists and is complete

## Migration Notes

### From v5 (Worktree-based)
- No worktree commands needed
- Simpler branch management
- All instances in same directory
- Manual coordination (no polling)

### From Earlier Versions
- Templates now in dedicated directory
- Documentation split into internal/external
- Checkpoint system simplified
- Feature tracking via FEATURES.txt

## Known Limitations

### Current Constraints
- Requires manual coordination between instances
- No parallel feature development
- Single language focus (bash/python tools)
- Limited to 4-instance orchestration

### Planned Improvements
- Automated instance coordination
- Multi-feature parallel support
- Additional language templates
- Web-based monitoring dashboard

## Best Practices

### For Human Coordinators
1. Always wait for explicit completion signals
2. Confirm each phase before proceeding
3. Review checkpoints if issues arise
4. Use list_features.sh to track progress

### For Claude Instances
1. Stay within assigned role boundaries
2. Create clear, verifiable checkpoints
3. Follow templates precisely
4. Report completion explicitly

### For Feature Development
1. Start with comprehensive task spec
2. Write tests that fully cover requirements
3. Implement only what tests require
4. Verify TDD compliance thoroughly

## External Documentation
For detailed protocol specifications and advanced usage, see:
- `docs/tmops_docs_v6/tmops_protocol.md` - Technical protocol details
- `docs/tmops_docs_v6/tmops_claude_code.md` - Full instance instructions
- `docs/tmops_docs_v6/tmops_claude_chat.md` - Chat-based coordination

## License & Attribution
MIT License - Based on TeamOps Framework by @happycode-ch
See LICENSE file for full terms.

---
*TeamOps v6 Simplified Edition - Efficient TDD through AI Orchestration*