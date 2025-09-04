<!--
📁 FILE: /home/anthonycalek/projects/tmops_framework/CODE/.claude/CLAUDE.md
🎯 PURPOSE: Development context and workflow guide for tmops framework
🤖 AI-HINT: Read this first when working on framework development - contains commands, patterns, and quality gates
🔗 DEPENDENCIES: tmops_tools/, tmops_v6_portable/, shellcheck, npm
📝 CONTEXT: Project uses recursive development (framework develops itself)
-->

# TeamOps Framework Development

## 🤖 Quick AI Reference
**Role**: Development context and workflow guide  
**Usage**: Read before framework development tasks  
**Outputs**: Commands, patterns, quality standards  
**Connections**: tmops_tools/, validation scripts, tests

## File Creation Standards

**CRITICAL**: When creating ANY new file in this project, ALWAYS add this standardized header:

```
<!--
📁 FILE: [full absolute path to the file]
🎯 PURPOSE: [brief description of file's primary function]
🤖 AI-HINT: [how AI agents should use this file and what to expect]
🔗 DEPENDENCIES: [related files, tools, or prerequisites]
📝 CONTEXT: [key information for understanding usage patterns]
-->
```

This ensures every Claude Code-generated file has consistent AI-readable metadata for better context and collaboration.

## Project Overview
This repository develops the TeamOps AI orchestration framework. The project has a dual nature:
- **Framework Development**: Modify/enhance the framework itself
- **Framework Testing**: Use the framework to develop its own features (dogfooding)

## Development Commands

### Testing & Quality Assurance
```bash
npm test                    # Run test suite
timeout 30 npm test         # Run tests with timeout (for long-running tests)
npm run lint               # Code linting  
npm run test:coverage      # Coverage reporting
shellcheck *.sh            # Validate bash scripts (ALWAYS run after creating/editing)
```

### Project Validation Scripts
```bash
./TEST_PACKAGE.sh          # Test package functionality
./test_v6.1.sh            # Version-specific testing
./test_docs_alignment.sh   # Documentation consistency check
```

### TeamOps Framework Tools (Two Locations)
```bash
# Framework development tools (modify these when developing)
./tmops_tools/cleanup_safe.sh feature-name
./tmops_tools/init_feature_multi.sh feature-name

# Portable framework tools (test these, but they move with framework)
./tmops_v6_portable/tmops_tools/init_feature_multi.sh feature-name
./tmops_v6_portable/tmops_tools/init_preflight.sh feature-name
./tmops_v6_portable/tmops_tools/cleanup_safe.sh feature-name
```

## Shell Scripting Conventions

### Quality Standards
- **ALWAYS run `shellcheck` on bash scripts before committing**
- Follow existing patterns in `tmops_tools/` directory
- Use `set -e` for error handling
- Include descriptive comments for complex logic

### Common Patterns
```bash
# Timeout pattern for potentially long-running commands
timeout 30 command_here

# Standard script header
#!/bin/bash
set -e

# Get script directory pattern (used throughout codebase)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
```

## Git Workflow

### Branch Management
```bash
git checkout -b feature/feature-name    # Feature branches
git stash push -m "description"         # Complex branch switching
gh pr create                           # Create pull requests
```

### Changelog Management
- **Update CHANGELOG.md** when adding significant features or breaking changes
- Add entries before committing major changes
- Use clear, user-focused descriptions

### Commit Standards
- Run quality checks before committing
- Use descriptive commit messages
- Reference issues/PRs where relevant

## Project Structure Understanding

### Dual Tool Paths
```
./tmops_tools/                    # Framework development (modify these)
./tmops_v6_portable/tmops_tools/  # Portable framework (test these, don't modify)
```

### Framework vs Implementation
- **tmops_v6_portable/**: The portable framework that ships to other projects
- **Root directory**: Framework development and testing workspace
- **.tmops/**: Generated artifacts (ignored in git)

## Development Workflow

### For Framework Features
1. Use the framework to develop the feature (dogfooding)
2. Test changes with validation scripts
3. Run `shellcheck` on any modified bash scripts
4. Update CHANGELOG.md for significant changes
5. Create PR with `gh pr create`

### Quality Gates
- All bash scripts pass `shellcheck`
- Tests pass (with timeouts if needed)
- Linting passes if available
- Documentation updated for significant changes

## Common Development Tasks

### Modifying Framework Scripts
1. Edit files in `tmops_tools/` or `tmops_v6_portable/tmops_tools/`
2. Run `shellcheck` on modified scripts
3. Test with validation scripts (`./TEST_PACKAGE.sh`)
4. Use framework to test the changes (dogfooding)

### Adding New Features
1. Use either standard (4-instance) or preflight (7-instance) workflow
2. Test the feature development process itself
3. Document any new patterns or commands
4. Update changelog for user-visible changes

### Testing Framework Changes
1. Run validation scripts after modifications
2. Test both local tools and portable tools
3. Use timeout patterns for potentially slow tests
4. Verify framework can still develop its own features

## Troubleshooting

### Script Issues
- **Permission denied**: `chmod +x script.sh`
- **Shellcheck failures**: Fix all warnings before committing
- **Timeout issues**: Use `timeout 30` prefix for long-running commands

### Development Environment
- Ensure both `./tmops_tools/` and `./tmops_v6_portable/tmops_tools/` work
- Validate with `./TEST_PACKAGE.sh` after changes
- Check documentation alignment with `./test_docs_alignment.sh`

## Pre-commit Checklist
1. **Run `shellcheck` on any modified bash scripts**
2. **Run `npm run lint` if available**
3. **Test with appropriate validation scripts**
4. **Update CHANGELOG.md for significant changes**
5. **Ensure tests pass (use timeouts if needed)**

## Framework Development Notes
- This codebase develops AND uses the TeamOps framework
- The `tmops_v6_portable/CLAUDE.md` file travels with the framework (don't modify)
- Focus on practical development workflow and quality standards
- Use the framework to test framework changes (recursive development)

## Developer Profile

### Core Interaction Style
- Conversational but engineering-focused tone
- Direct, to-the-point explanations using technical terminology when appropriate  
- Summary/TL;DR first, then details
- Bullet points and small, readable chunks preferred
- Skeptical assessment over agreeable responses - challenge ideas when warranted

### Development Context
- Solo agentic developer using Claude Code + VS Code + WSL2
- AI writes 95-100% of code - focus on orchestration and planning
- TeamOps framework practitioner - heavy planning before implementation
- TDD methodology is non-negotiable
- Language-agnostic (Python/JS/SQL primary, but flexible based on project needs)

### Critical Behaviors
#### ALWAYS:
- Verify claims and provide real-world examples
- Research first - check if solution already exists (GitHub, open source)
- Ask clarifying questions before solving
- Flag potential issues and suggest alternatives
- Be direct about limitations - say what can't be done

#### NEVER:
- Start solving problems without explicit request
- Provide overly agreeable responses without critical assessment
- Waste tokens on unsolicited solutions
- Skip verification in favor of quick answers

### Workflow Pattern
1. **Discuss** - Understand the problem deeply
2. **Research** - Find existing solutions, best practices, current zeitgeist
3. **Plan** - Develop approach collaboratively
4. **Summarize** - Create artifact if needed
5. **Execute** - Only when explicitly requested

### Research Priorities
- "Are we reinventing the wheel?" - Always check first
- Current best practices and industry standards
- Links, resources, and concrete examples
- Identify impossible paths early to avoid wasted effort

### Documentation & Output
- Create documentation suitable for Notebook LM export
- Elegant, robust, maintainable code
- Framework/tool selection based on project requirements
- Consider Switzerland/US regulatory requirements when relevant

### Agentic Development Support
- Optimize responses for AI-to-AI collaboration
- Provide context that other AI agents can leverage
- Structure information for TeamOps workflow integration
- Enable efficient handoffs between planning and implementation phases