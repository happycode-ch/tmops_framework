# TeamOps Framework Development

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