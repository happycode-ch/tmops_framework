# TeamOps v6 Portable Development Report

**Date**: 2025-08-22  
**Author**: Claude Code & Anthony Calek  
**Version**: v6.2 Simplified Edition

## Genesis of This Report

This report was created following a live TeamOps testing session that revealed critical path resolution issues when instances couldn't locate checkpoint files. The debugging process exposed important insights about the system's architecture, leading to the decision to document the current state comprehensively and prepare TeamOps to use its own methodology for self-improvement.

## System Overview

### Architecture
TeamOps v6 Portable orchestrates 4 Claude Code instances to build features using Test-Driven Development (TDD). Each instance has a specific role:

1. **Orchestrator** - Manages workflow and creates trigger checkpoints
2. **Tester** - Writes comprehensive failing tests based on requirements
3. **Implementer** - Writes code to make tests pass
4. **Verifier** - Reviews code quality and completeness

### Core Principles
- **Manual Coordination** - Human acts as conductor between instances
- **Branch-Based Development** - Simple feature branches, no worktrees
- **Checkpoint Communication** - Markdown files signal phase transitions
- **Clean Separation** - Tools in `tmops_v6_portable/`, artifacts in root `.tmops/`

## Technical Implementation

### Directory Structure
```
project-root/
├── .tmops/                      # TeamOps artifacts (created here)
│   ├── <feature>/
│   │   ├── current -> runs/initial  # Symlink for consistency
│   │   └── runs/
│   │       └── initial/
│   │           ├── TASK_SPEC.md
│   │           ├── checkpoints/
│   │           └── logs/
│   └── FEATURES.txt           # Active features tracking
├── src/                        # Implementation code
├── test/                       # Test files
└── tmops_v6_portable/          # TeamOps tools
    ├── tmops_tools/           # Scripts
    └── instance_instructions/ # Role documentation
```

### Path Resolution System

**PROJECT_ROOT Discovery** (implemented today):
```bash
# Get script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PORTABLE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Always use parent of tmops_v6_portable as project root
PROJECT_ROOT="$(cd "$PORTABLE_DIR/.." && pwd)"
```

This ensures consistent behavior regardless of execution location.

### Symlink Design
The `current` symlink points to the active run directory:
- Provides consistent paths in documentation
- Allows switching between run types (initial, hotfix, enhancement)
- Both paths work: `.tmops/feature/current/` and `.tmops/feature/runs/initial/`

## Known Issues & Solutions

### Issue 1: Working Directory Confusion
**Problem**: Instances fail to find files when not in correct directory  
**Symptom**: "Error reading file" when accessing checkpoints  
**Solution**: All instances must verify working directory with `pwd` and `cd` to PROJECT_ROOT if needed

### Issue 2: Relative vs Absolute Paths
**Problem**: Documentation uses relative paths that break in wrong directory  
**Solution**: Instance instructions should provide both relative and absolute path examples

### Issue 3: Script Execution Location
**Problem**: Scripts behaved differently when run from different directories  
**Fixed**: Unified PROJECT_ROOT calculation in all scripts (2025-08-22)

## Best Practices

### For Users
1. **Always run from consistent location** - Either from CODE or tmops_v6_portable
2. **Verify branches** - Check with `git branch --show-current` before starting
3. **Manual coordination** - Act as conductor, wait for explicit completion signals
4. **Use symlinks** - Reference `.tmops/feature/current/` for consistency

### For Development
1. **Test from multiple directories** - Ensure scripts work from any location
2. **Use absolute paths internally** - Scripts should calculate PROJECT_ROOT
3. **Clear error messages** - Include path information in errors
4. **Document both paths** - Show relative and absolute options

## Self-Improvement Strategy

### Using TeamOps on Itself
Starting today, TeamOps will use its own methodology for improvements:

1. **Feature**: `tmops-self-improvement`
2. **Test-Driven Enhancements**:
   - Write tests for desired improvements
   - Implement changes to pass tests
   - Verify quality through review process

### Planned Improvements
- **Path Resolution Enhancement** - Add automatic working directory detection
- **Instance Instructions Update** - Include troubleshooting section
- **Validation Script** - Quick health check for setup
- **Better Error Messages** - Include diagnostic information

### Success Metrics
- Reduction in setup errors
- Faster feature completion time
- Fewer path-related issues
- Improved documentation clarity

## Version Evolution

### v6.2 (Current) - Simplified Edition
- Removed worktree complexity entirely
- Fixed path resolution for multi-directory execution
- Production-ready with comprehensive testing
- Single branch architecture

### v6.1 - Multi-Feature Support  
- Introduced parallel feature development
- Added safe cleanup mechanism
- Worktree-based isolation (later removed)

### v6.0 - Initial Portable Package
- First standalone implementation
- 4-instance orchestration model
- Manual coordination protocol

## Lessons Learned

1. **Simplicity wins** - Removing worktrees made the system more reliable
2. **Path resolution is critical** - Must work from any directory
3. **Clear documentation** - Users need explicit working directory guidance
4. **Testing reveals truth** - Live testing exposed issues unit tests missed
5. **Self-improvement works** - Using TeamOps to improve TeamOps is viable

## Conclusion

TeamOps v6 Portable has evolved into a robust, simplified system that successfully orchestrates TDD feature development. Today's debugging session validated the architecture while revealing path resolution as the primary challenge. With these issues now documented and fixed, TeamOps is ready to use its own methodology for continuous improvement.

The system's strength lies in its simplicity: feature branches, clear roles, and checkpoint-based communication. By removing complexity (worktrees) and fixing fundamental issues (path resolution), v6.2 achieves production readiness.

---

*This report serves as both documentation and discovery reference for future TeamOps development using the TeamOps methodology itself.*