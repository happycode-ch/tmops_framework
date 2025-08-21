#!/usr/bin/env python3
"""
TeamOps v7 PostToolUse Hook
Detects phase completion and updates state for orchestration.
Self-aware: Only active when TeamOps session is running.
"""

import json
import sys
from pathlib import Path
import re

def is_teamops_active():
    """Check if a TeamOps session is currently active."""
    return Path(".tmops/current/state.json").exists()

def get_current_state():
    """Get the current state from state file."""
    state_file = Path(".tmops/current/state.json")
    if not state_file.exists():
        return None
    
    try:
        with open(state_file) as f:
            return json.load(f)
    except Exception:
        return None

def update_state(updates):
    """Update the state file with new values."""
    state_file = Path(".tmops/current/state.json")
    try:
        with open(state_file) as f:
            state = json.load(f)
        
        state.update(updates)
        
        with open(state_file, 'w') as f:
            json.dump(state, f, indent=2)
        
        return True
    except Exception:
        return False

def detect_test_completion(output):
    """Detect if tests have been written and are failing (TDD red phase)."""
    indicators = [
        r'(\d+) tests?, \d+ failures?',
        r'FAIL.*Test',
        r'AssertionError',
        r'expected.*to equal',
        r'Test.*failed',
        r'(\d+) failing',
        r'✖ \d+ tests? failed'
    ]
    
    for pattern in indicators:
        if re.search(pattern, output, re.IGNORECASE):
            return True
    return False

def detect_implementation_completion(output):
    """Detect if all tests are passing (TDD green phase)."""
    indicators = [
        r'(\d+) tests?, 0 failures?',
        r'All tests passed',
        r'PASS.*Test',
        r'(\d+) passing',
        r'✓ \d+ tests? passed',
        r'test.*passed'
    ]
    
    # Also check for absence of failures
    no_failures = not re.search(r'(\d+) fail', output, re.IGNORECASE)
    
    for pattern in indicators:
        if re.search(pattern, output, re.IGNORECASE) and no_failures:
            return True
    return False

def create_checkpoint(phase, feature, message):
    """Create a checkpoint file for the completed phase."""
    checkpoint_dir = Path(f".tmops/{feature}/runs/current/checkpoints")
    checkpoint_dir.mkdir(parents=True, exist_ok=True)
    
    # Generate checkpoint filename
    import datetime
    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    checkpoint_file = checkpoint_dir / f"{timestamp}_{phase}_complete.md"
    
    content = f"""# Phase Completion: {phase.title()}

**Feature**: {feature}
**Timestamp**: {datetime.datetime.now().isoformat()}
**Status**: Complete

## Summary
{message}

## Next Steps
- Phase transition detected
- Ready for next phase in workflow
"""
    
    try:
        with open(checkpoint_file, 'w') as f:
            f.write(content)
        return True
    except Exception:
        return False

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
        output = input_data.get('output', '')
    except Exception:
        print(json.dumps({"continue": True}))
        return
    
    # Get current state
    state = get_current_state()
    if not state:
        print(json.dumps({"continue": True}))
        return
    
    phase = state.get('phase', 'unknown')
    feature = state.get('feature', 'unknown')
    
    # Check for phase completion based on tool output
    phase_complete = False
    next_phase = None
    message = ""
    
    # Detect phase transitions based on test execution
    if tool_name == "Bash" and "test" in tool_input.get("command", "").lower():
        if phase == 'testing' and detect_test_completion(output):
            phase_complete = True
            next_phase = 'implementation'
            message = "Tests written and failing as expected (TDD red phase)"
            
        elif phase == 'implementation' and detect_implementation_completion(output):
            phase_complete = True
            next_phase = 'verification'
            message = "All tests passing (TDD green phase)"
    
    # Handle phase completion
    if phase_complete and next_phase:
        # Update state
        update_state({
            'previous_phase': phase,
            'phase': next_phase,
            'phase_complete': True,
            'last_transition': str(datetime.datetime.now().isoformat())
        })
        
        # Create checkpoint
        create_checkpoint(phase, feature, message)
        
        # Return with phase transition information
        print(json.dumps({
            "continue": True,
            "hookSpecificOutput": {
                "phase_transition": True,
                "from_phase": phase,
                "to_phase": next_phase,
                "message": message,
                "feature": feature
            }
        }))
    else:
        # No phase transition detected
        print(json.dumps({"continue": True}))

if __name__ == "__main__":
    # Set a timeout alarm to ensure we don't exceed hook limits
    try:
        import signal
        import datetime
        signal.alarm(25)  # Safety margin under 30s limit
    except:
        pass  # Not all platforms support alarm
    
    main()