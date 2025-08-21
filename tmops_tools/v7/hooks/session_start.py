#!/usr/bin/env python3
"""
TeamOps v7 SessionStart Hook
Initializes TeamOps workflow if invoked with appropriate command.
Self-aware: Only activates for TeamOps-specific commands.
"""

import json
import sys
import os
from pathlib import Path

def detect_teamops_invocation():
    """Detect if this session is a TeamOps workflow."""
    # Check for TeamOps-specific environment variable
    if os.getenv('TMOPS_V7_ACTIVE'):
        return True
    
    # Check for existing active session
    if Path(".tmops/current/state.json").exists():
        # Check if session is stale (over 24 hours old)
        try:
            import datetime
            with open(".tmops/current/state.json") as f:
                state = json.load(f)
            started = datetime.datetime.fromisoformat(state.get('started_at', ''))
            age = datetime.datetime.now() - started
            if age.days >= 1:
                # Stale session, can be replaced
                return True
        except:
            pass
    
    return False

def initialize_teamops_session():
    """Initialize a new TeamOps session."""
    # Check if we have a current feature symlink
    current_link = Path(".tmops/current")
    if not current_link.exists():
        return None
    
    # Read the feature from the symlink target
    try:
        feature_path = current_link.resolve()
        feature = feature_path.parent.parent.name
    except:
        return None
    
    # Create initial state
    import datetime
    state = {
        "feature": feature,
        "phase": "planning",
        "role": "orchestrator",
        "started_at": datetime.datetime.now().isoformat(),
        "phase_complete": False,
        "version": "v7",
        "workflow_type": "automated"
    }
    
    # Write state file
    state_file = Path(".tmops/current/state.json")
    try:
        with open(state_file, 'w') as f:
            json.dump(state, f, indent=2)
        return state
    except:
        return None

def get_orchestrator_instructions():
    """Generate instructions for the orchestrator."""
    return """
## TeamOps v7 Workflow Activated

You are now the master orchestrator for an automated TDD workflow.

### Your Responsibilities:
1. Read the task specification from `.tmops/current/TASK_SPEC.md`
2. Invoke subagents via the Task tool for each phase
3. Monitor hook outputs for phase transitions
4. Manage the workflow until completion

### Workflow Phases:
1. **Testing**: Invoke `tmops-tester` subagent to write failing tests
2. **Implementation**: Invoke `tmops-implementer` to make tests pass
3. **Verification**: Invoke `tmops-verifier` for quality review

### Important Notes:
- Hooks will notify you of phase completions via `hookSpecificOutput`
- Only you can invoke subagents (hooks cannot)
- State is managed via `.tmops/current/state.json`
- Each subagent works in isolation with role-based restrictions

Start by reading the task specification and beginning the testing phase.
"""

def main():
    """Main hook entry point."""
    # Check if this is a TeamOps invocation
    if not detect_teamops_invocation():
        print(json.dumps({"continue": True}))
        return
    
    # Initialize TeamOps session
    state = initialize_teamops_session()
    
    if state:
        # Session initialized successfully
        print(json.dumps({
            "continue": True,
            "hookSpecificOutput": {
                "teamops_activated": True,
                "version": "v7",
                "feature": state.get('feature'),
                "instructions": get_orchestrator_instructions()
            }
        }))
    else:
        # No TeamOps session to initialize
        print(json.dumps({"continue": True}))

if __name__ == "__main__":
    # Set a timeout alarm to ensure we don't exceed hook limits
    try:
        import signal
        signal.alarm(8)  # Safety margin under 10s limit for SessionStart
    except:
        pass  # Not all platforms support alarm
    
    main()