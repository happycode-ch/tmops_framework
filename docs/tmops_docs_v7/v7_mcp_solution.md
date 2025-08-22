# TeamOps v7: MCP-Based Solution Design

## Executive Summary
MCP (Model Context Protocol) could enable a **working TeamOps v7** by providing the missing orchestration layer. Instead of relying on non-existent subagent types and limited hooks, MCP servers can act as intelligent orchestrators with state management and role-based tool access.

## How MCP Solves v7's Problems

### Problem 1: No Custom Subagent Types
**Current Issue**: Can't create tmops-tester, tmops-implementer subagents

**MCP Solution**: 
- Create MCP servers that expose role-specific tools
- Each "role" becomes an MCP server with different capabilities
- Claude Code sees them as `mcp__tmops_tester__`, `mcp__tmops_implementer__`, etc.

### Problem 2: No Automatic Orchestration
**Current Issue**: Hooks can't control workflow or invoke next agents

**MCP Solution**:
- MCP orchestrator server manages the entire workflow
- Tracks phase transitions and state
- Exposes different tools based on current phase
- Can trigger actions and manage flow programmatically

### Problem 3: No Role Enforcement
**Current Issue**: Single Claude instance has access to everything

**MCP Solution**:
- MCP server dynamically enables/disables tools based on phase
- Tester phase: Only exposes test-writing tools
- Implementer phase: Only exposes source-editing tools
- Verifier phase: Only exposes read/analysis tools

## Proposed MCP Architecture

### 1. TeamOps Orchestrator MCP Server

```python
# tmops_orchestrator_mcp.py
import json
from pathlib import Path
from mcp import MCPServer, Tool, Resource

class TeamOpsOrchestrator(MCPServer):
    def __init__(self, feature_name):
        self.feature_name = feature_name
        self.state_file = Path(f".tmops/{feature_name}/runs/current/state.json")
        self.current_phase = "planning"
        self.current_role = "orchestrator"
        
    def get_available_tools(self):
        """Dynamically return tools based on current phase/role"""
        if self.current_role == "tester":
            return [
                Tool("write_test", self.write_test_file),
                Tool("read_spec", self.read_task_spec),
                Tool("run_tests", self.run_tests),
            ]
        elif self.current_role == "implementer":
            return [
                Tool("write_source", self.write_source_file),
                Tool("read_tests", self.read_test_files),
                Tool("run_tests", self.run_tests),
            ]
        elif self.current_role == "verifier":
            return [
                Tool("read_all", self.read_all_files),
                Tool("run_tests", self.run_tests),
                Tool("generate_report", self.generate_report),
            ]
        else:
            return [
                Tool("start_testing", self.transition_to_testing),
                Tool("check_status", self.get_current_status),
            ]
    
    def transition_to_testing(self):
        """Transition to testing phase"""
        self.current_phase = "testing"
        self.current_role = "tester"
        self.update_state()
        return {
            "message": "Transitioned to testing phase",
            "instructions": "Write comprehensive failing tests for the feature",
            "available_tools": ["write_test", "read_spec", "run_tests"]
        }
    
    def write_test_file(self, path, content):
        """Tester-only tool to write test files"""
        if self.current_role != "tester":
            return {"error": "Only tester role can write tests"}
        # Write test file
        Path(path).write_text(content)
        return {"success": True, "file": path}
    
    def write_source_file(self, path, content):
        """Implementer-only tool to write source files"""
        if self.current_role != "implementer":
            return {"error": "Only implementer role can write source"}
        # Write source file
        Path(path).write_text(content)
        return {"success": True, "file": path}
    
    def check_test_results(self):
        """Check test results and trigger phase transitions"""
        import subprocess
        result = subprocess.run(["npm", "test"], capture_output=True)
        
        if self.current_phase == "testing" and result.returncode != 0:
            # Tests failing as expected, move to implementation
            self.transition_to_implementation()
        elif self.current_phase == "implementation" and result.returncode == 0:
            # Tests passing, move to verification
            self.transition_to_verification()
            
        return {"tests_passing": result.returncode == 0}
    
    def transition_to_implementation(self):
        """Auto-transition to implementation when tests are failing"""
        self.current_phase = "implementation"
        self.current_role = "implementer"
        self.update_state()
        return {
            "message": "Tests are properly failing. Transitioning to implementation.",
            "instructions": "Implement minimal code to make all tests pass",
            "available_tools": ["write_source", "read_tests", "run_tests"]
        }
    
    def transition_to_verification(self):
        """Auto-transition to verification when tests pass"""
        self.current_phase = "verification"
        self.current_role = "verifier"
        self.update_state()
        return {
            "message": "All tests passing. Transitioning to verification.",
            "instructions": "Review code quality and generate report",
            "available_tools": ["read_all", "run_tests", "generate_report"]
        }
    
    def update_state(self):
        """Update state.json with current phase/role"""
        state = {
            "feature": self.feature_name,
            "phase": self.current_phase,
            "role": self.current_role,
            "version": "v7-mcp"
        }
        self.state_file.write_text(json.dumps(state, indent=2))
```

### 2. MCP Server Configuration

```json
// .claude/mcp_servers.json
{
  "tmops": {
    "command": "python",
    "args": ["tmops_tools/v7/mcp/orchestrator.py"],
    "description": "TeamOps v7 TDD Orchestrator",
    "autoStart": true,
    "resources": {
      "task_spec": ".tmops/*/runs/current/TASK_SPEC.md",
      "state": ".tmops/*/runs/current/state.json"
    }
  }
}
```

### 3. Claude Code Integration

```bash
# Add the MCP server to Claude Code
claude mcp add tmops python tmops_tools/v7/mcp/orchestrator.py

# The orchestrator appears as MCP tools in Claude:
# - mcp__tmops__start_testing
# - mcp__tmops__write_test (only when in tester role)
# - mcp__tmops__write_source (only when in implementer role)
# - mcp__tmops__generate_report (only when in verifier role)
```

## How It Would Work

### Step 1: Initialize Feature
```bash
./tmops_tools/v7/init_feature_v7.sh my-feature initial
```

### Step 2: Start MCP Orchestrator
```bash
# MCP server starts and exposes initial tools
claude "Start TeamOps workflow for my-feature"
# Claude sees: mcp__tmops__start_testing tool
```

### Step 3: Automatic Phase Progression
```
Claude: "I'll start the testing phase"
> Uses mcp__tmops__start_testing

MCP Server:
- Changes role to "tester"
- Disables orchestrator tools
- Enables test-writing tools only
- Returns instructions for Claude

Claude: "Now I can only see test-writing tools. Writing tests..."
> Uses mcp__tmops__write_test

Claude: "Running tests to verify they fail"
> Uses mcp__tmops__run_tests

MCP Server (automatically):
- Detects tests failing
- Transitions to implementation phase
- Changes available tools
- Notifies Claude of phase change

Claude: "Phase changed. Now I see implementation tools. Writing code..."
> Uses mcp__tmops__write_source

[Process continues automatically]
```

## Key Advantages

### 1. True Role Enforcement
- MCP server controls which tools are available
- Claude literally cannot access restricted tools
- No relying on "advisory" restrictions

### 2. Automatic Orchestration
- MCP server monitors test results
- Automatically transitions phases
- No manual state management needed

### 3. State Persistence
- MCP server maintains state across invocations
- Can resume workflows
- Tracks progress systematically

### 4. Single Integration Point
- One MCP server manages entire workflow
- No need for multiple subagents
- Clean, maintainable architecture

## Implementation Requirements

### 1. MCP Server Development
```python
# Required packages
pip install mcp-server
pip install watchdog  # For file monitoring
```

### 2. Tool Definitions
Each phase needs specific tool implementations:
- **Tester Tools**: write_test, read_spec, validate_tests
- **Implementer Tools**: write_source, read_tests, check_coverage
- **Verifier Tools**: analyze_quality, generate_report

### 3. State Management
- Persistent state in `.tmops/*/state.json`
- Phase transitions tracked
- Progress checkpoints created

## Migration Path from Current v7

### Step 1: Keep Existing Structure
- Maintain `.tmops/` directory structure
- Keep TASK_SPEC.md format
- Preserve checkpoint system

### Step 2: Replace Hooks with MCP
- Remove hook-based orchestration attempts
- Implement MCP server with phase management
- Use MCP tools instead of subagent invocations

### Step 3: Simplify Agent Setup
- Remove `.claude/agents/*.md` files (not needed)
- Single Claude instance with MCP tools
- Let MCP server handle role switching

## Proof of Concept

```python
# Simple MCP server that enforces roles
class RoleBasedMCP(MCPServer):
    def __init__(self):
        self.role = "tester"
        
    @mcp_tool("write_file")
    def write_file(self, path: str, content: str):
        # Enforce role-based path restrictions
        if self.role == "tester" and not path.startswith("test/"):
            return {"error": "Tester can only write to test/"}
        if self.role == "implementer" and path.startswith("test/"):
            return {"error": "Implementer cannot modify tests"}
        
        # Write the file
        Path(path).write_text(content)
        return {"success": True}
    
    @mcp_tool("switch_role")
    def switch_role(self, new_role: str):
        self.role = new_role
        return {
            "role": new_role,
            "message": f"Switched to {new_role} role"
        }
```

## Conclusion

MCP provides the **missing orchestration layer** for TeamOps v7:
- ✅ Dynamic tool availability based on role/phase
- ✅ Automatic phase transitions based on test results
- ✅ State persistence and workflow management
- ✅ True enforcement (not advisory)
- ✅ Single point of control

Unlike the current v7 implementation that relies on non-existent features, an MCP-based solution uses **actual, documented capabilities** to achieve the automation goals. The MCP server acts as the intelligent orchestrator that v7's hooks were supposed to be but couldn't be.