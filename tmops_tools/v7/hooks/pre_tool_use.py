#!/usr/bin/env python3
"""
TeamOps v7 PreToolUse Hook
Enforces role-based boundaries for tool usage.
Self-aware: Only active when TeamOps session is running.
"""

import json
import sys
from pathlib import Path

def is_teamops_active():
    """Check if a TeamOps session is currently active."""
    return Path(".tmops/current/state.json").exists()

def get_current_role():
    """Get the current role from state file."""
    state_file = Path(".tmops/current/state.json")
    if not state_file.exists():
        return None
    
    try:
        with open(state_file) as f:
            state = json.load(f)
        return state.get('role', 'orchestrator')
    except Exception:
        return None

def is_allowed(tool_name, tool_input, role):
    """Check if operation is allowed for current role."""
    if role is None or role == 'orchestrator':
        return True  # Orchestrator has full access
    
    # Tester role restrictions
    if role == 'tester':
        if tool_name in ['Write', 'Edit', 'MultiEdit']:
            path = tool_input.get('file_path', '')
            # Testers can only modify test files
            restricted_paths = ['src/', 'lib/', 'app/', 'pkg/', 'internal/', 'cmd/']
            if any(restricted in path for restricted in restricted_paths):
                return False
    
    # Implementer role restrictions
    elif role == 'implementer':
        if tool_name in ['Write', 'Edit', 'MultiEdit']:
            path = tool_input.get('file_path', '')
            # Implementers cannot modify test files (they should already be written)
            if 'test' in path.lower() or 'spec' in path.lower():
                # Allow modifications to test helpers or utilities
                if 'helper' not in path.lower() and 'util' not in path.lower():
                    return False
    
    # Verifier role restrictions
    elif role == 'verifier':
        # Verifiers are read-only
        if tool_name in ['Write', 'Edit', 'MultiEdit', 'Delete', 'NotebookEdit']:
            return False
        # Also restrict dangerous bash commands
        if tool_name == 'Bash':
            command = tool_input.get('command', '')
            write_commands = ['>', '>>', 'rm', 'mv', 'cp', 'mkdir', 'touch', 'sed -i', 'echo']
            if any(cmd in command for cmd in write_commands):
                return False
    
    return True

def main():
    """Main hook entry point."""
    # Only activate for TeamOps workflows
    if not is_teamops_active():
        print(json.dumps({"continue": True}))
        return
    
    # Parse input
    try:
        input_data = json.loads(sys.stdin.read())
        tool_name = input_data.get('tool_name', '')
        tool_input = input_data.get('tool_input', {})
    except Exception:
        # On any parsing error, allow the operation
        print(json.dumps({"continue": True}))
        return
    
    # Get current role
    role = get_current_role()
    
    # Check if operation is allowed
    if is_allowed(tool_name, tool_input, role):
        print(json.dumps({"continue": True}))
    else:
        print(json.dumps({
            "continue": False,
            "hookSpecificOutput": {
                "reason": f"Role restriction: {role} cannot use {tool_name} on this path",
                "role": role,
                "tool": tool_name
            }
        }))

if __name__ == "__main__":
    # Set a timeout alarm to ensure we don't exceed hook limits
    try:
        import signal
        signal.alarm(25)  # Safety margin under 30s limit
    except:
        pass  # Not all platforms support alarm
    
    main()