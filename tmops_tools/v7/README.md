# TeamOps v7 Tools

This directory contains the v7 implementation of TeamOps tools, featuring automated orchestration through Claude Code's hooks and subagents.

## Directory Structure
- `hooks/` - Hook implementations for workflow control
- `agents/` - Subagent definitions for role-based tasks
- `templates/` - Configuration and specification templates
- `test/` - Testing and validation utilities
- `init_feature_v7.sh` - Feature initialization script
- `merge_hooks.py` - Hook integration utility

## Key Differences from v6
- No worktrees required (single Claude instance)
- Automated phase transitions via hooks
- Subagent-based role isolation
- Self-aware hooks for non-interference