#!/usr/bin/env python3
"""
Validate TeamOps v7 hooks for correct behavior and response format.
"""

import json
import subprocess
import sys
from pathlib import Path
import tempfile
import os

class HookValidator:
    """Validates hook implementations."""
    
    def __init__(self, hooks_dir=None):
        """Initialize validator with hooks directory."""
        if hooks_dir:
            self.hooks_dir = Path(hooks_dir)
        else:
            # Find hooks directory relative to this script
            self.hooks_dir = Path(__file__).parent.parent / "hooks"
        
        if not self.hooks_dir.exists():
            raise ValueError(f"Hooks directory not found: {self.hooks_dir}")
    
    def validate_hook_response(self, response):
        """Validate hook response format."""
        try:
            data = json.loads(response)
        except json.JSONDecodeError:
            return False, "Invalid JSON response"
        
        # Required field
        if "continue" not in data:
            return False, "Missing required 'continue' field"
        
        if not isinstance(data["continue"], bool):
            return False, "'continue' must be boolean"
        
        # Optional field
        if "hookSpecificOutput" in data:
            if not isinstance(data["hookSpecificOutput"], dict):
                return False, "'hookSpecificOutput' must be a dictionary"
        
        return True, "Valid response format"
    
    def test_hook(self, hook_name, input_data):
        """Test a specific hook with given input."""
        hook_path = self.hooks_dir / hook_name
        
        if not hook_path.exists():
            return False, f"Hook not found: {hook_path}"
        
        try:
            # Run hook with input
            result = subprocess.run(
                ["python3", str(hook_path)],
                input=json.dumps(input_data),
                capture_output=True,
                text=True,
                timeout=35  # Slightly more than hook timeout
            )
            
            if result.returncode != 0:
                return False, f"Hook exited with code {result.returncode}: {result.stderr}"
            
            # Validate response
            is_valid, message = self.validate_hook_response(result.stdout)
            
            if is_valid:
                response_data = json.loads(result.stdout)
                return True, response_data
            else:
                return False, message
                
        except subprocess.TimeoutExpired:
            return False, "Hook timed out (>35 seconds)"
        except Exception as e:
            return False, f"Hook execution error: {e}"
    
    def run_all_tests(self):
        """Run comprehensive hook validation tests."""
        print("=" * 60)
        print("TeamOps v7 Hook Validation Suite")
        print("=" * 60)
        
        all_passed = True
        
        # Test pre_tool_use.py
        print("\n[1] Testing pre_tool_use.py")
        print("-" * 40)
        
        # Test without TeamOps active (should pass through)
        success, result = self.test_hook("pre_tool_use.py", {
            "tool_name": "Write",
            "tool_input": {"file_path": "src/test.py"}
        })
        
        if success and result.get("continue") == True:
            print("✓ Pass-through when TeamOps inactive")
        else:
            print(f"✗ Failed pass-through test: {result}")
            all_passed = False
        
        # Test with TeamOps active (needs state file)
        with tempfile.TemporaryDirectory() as tmpdir:
            # Create temporary state
            state_dir = Path(tmpdir) / ".tmops/current"
            state_dir.mkdir(parents=True)
            state_file = state_dir / "state.json"
            
            # Test tester role restriction
            state_file.write_text(json.dumps({
                "role": "tester",
                "phase": "testing"
            }))
            
            # Change to temp directory for test
            original_cwd = os.getcwd()
            os.chdir(tmpdir)
            
            success, result = self.test_hook("pre_tool_use.py", {
                "tool_name": "Write",
                "tool_input": {"file_path": "src/implementation.py"}
            })
            
            os.chdir(original_cwd)
            
            if success and result.get("continue") == False:
                print("✓ Tester role restriction working")
            else:
                print(f"✗ Failed role restriction test: {result}")
                all_passed = False
        
        # Test post_tool_use.py
        print("\n[2] Testing post_tool_use.py")
        print("-" * 40)
        
        success, result = self.test_hook("post_tool_use.py", {
            "tool_name": "Bash",
            "tool_input": {"command": "npm test"},
            "output": "5 tests, 5 failures"
        })
        
        if success:
            print("✓ PostToolUse hook responds correctly")
        else:
            print(f"✗ PostToolUse failed: {result}")
            all_passed = False
        
        # Test session_start.py
        print("\n[3] Testing session_start.py")
        print("-" * 40)
        
        success, result = self.test_hook("session_start.py", {})
        
        if success:
            print("✓ SessionStart hook responds correctly")
        else:
            print(f"✗ SessionStart failed: {result}")
            all_passed = False
        
        # Test notification hooks
        notification_hooks = ["stop.py", "subagent_stop.py", "attention_needed.py"]
        
        for i, hook in enumerate(notification_hooks, 4):
            print(f"\n[{i}] Testing {hook}")
            print("-" * 40)
            
            success, result = self.test_hook(hook, {})
            
            if success:
                print(f"✓ {hook} responds correctly")
            else:
                print(f"✗ {hook} failed: {result}")
                all_passed = False
        
        # Summary
        print("\n" + "=" * 60)
        if all_passed:
            print("✅ All hook validation tests PASSED")
            return 0
        else:
            print("❌ Some hook validation tests FAILED")
            return 1

def main():
    """Main entry point."""
    validator = HookValidator()
    return validator.run_all_tests()

if __name__ == "__main__":
    sys.exit(main())