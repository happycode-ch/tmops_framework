# TeamOps v7 Analysis and SDK-Based Solution

## Executive Summary
The current TeamOps v7 implementation **does not work** because it relies on non-existent Claude Code features. However, the Claude Code SDK provides real capabilities that could enable a working v7 system with modifications.

## What Failed in Our Test

### 1. Fake Subagents
- **Problem**: The `.claude/agents/*.md` files are just markdown documents, not real agents
- **What Happened**: I used `subagent_type: "general-purpose"` and asked it to pretend to be different roles
- **Reality**: Claude Code only supports "general-purpose", "statusline-setup", and "output-style-setup" subagent types

### 2. No Hook Execution
- **Problem**: Hooks require `TMOPS_V7_ACTIVE=1` environment variable AND actual tool usage
- **Evidence**: Zero log files in `.tmops/hello-v7/runs/current/logs/`
- **Impact**: No automatic phase transitions, no notifications, no monitoring

### 3. Manual State Management
- **What Should Have Happened**: Hooks automatically update state.json based on test results
- **What Actually Happened**: I manually edited state.json after each phase
- **Result**: No automation, just manual orchestration

### 4. No Real Isolation
- **Intended**: Each subagent has restricted tool access (tester can't modify src/, implementer can't modify tests/)
- **Reality**: Single Claude instance with full access, pretending to follow restrictions

## How Claude Code SDK Could Fix This

### Real Agent Creation with SDK

The SDK supports creating actual agents with different permissions:

```python
# tmops_agents.py
from claude_code_sdk import ClaudeSDKClient, ClaudeCodeOptions
import asyncio
import json
from pathlib import Path

class TeamOpsTester:
    """Real tester agent with restricted permissions"""
    def __init__(self):
        self.client = ClaudeSDKClient(
            options=ClaudeCodeOptions(
                system_prompt=self._load_tester_prompt(),
                allowed_tools=["Read", "Write", "Edit", "Bash", "Grep"],
                disallowed_paths=["src/", "lib/", "app/"],  # Can't modify implementation
                max_turns=10
            )
        )
    
    def _load_tester_prompt(self):
        return """You are the TESTER in TeamOps v7. 
        Write comprehensive failing tests following TDD principles.
        You can ONLY modify test files, not implementation files."""
    
    async def run(self, task_spec_path):
        return await self.client.query(
            f"Read {task_spec_path} and write comprehensive failing tests"
        )

class TeamOpsImplementer:
    """Real implementer agent with restricted permissions"""
    def __init__(self):
        self.client = ClaudeSDKClient(
            options=ClaudeCodeOptions(
                system_prompt=self._load_implementer_prompt(),
                allowed_tools=["Read", "Write", "Edit", "Bash"],
                disallowed_paths=["test/", "tests/", "spec/"],  # Can't modify tests
                max_turns=10
            )
        )
    
    def _load_implementer_prompt(self):
        return """You are the IMPLEMENTER in TeamOps v7.
        Make all failing tests pass with minimal implementation.
        You can ONLY modify source files, not test files."""
    
    async def run(self):
        return await self.client.query(
            "Run tests and implement the minimal code to make them pass"
        )

class TeamOpsVerifier:
    """Real verifier agent with read-only permissions"""
    def __init__(self):
        self.client = ClaudeSDKClient(
            options=ClaudeCodeOptions(
                system_prompt=self._load_verifier_prompt(),
                allowed_tools=["Read", "Bash", "Grep"],  # Read-only
                max_turns=5
            )
        )
    
    def _load_verifier_prompt(self):
        return """You are the VERIFIER in TeamOps v7.
        Review code quality and test coverage.
        You have read-only access."""
    
    async def run(self):
        return await self.client.query(
            "Review the implementation and tests for quality and completeness"
        )
```

### Orchestrator Script

```python
# tmops_v7_orchestrator.py
import asyncio
import json
from pathlib import Path
from tmops_agents import TeamOpsTester, TeamOpsImplementer, TeamOpsVerifier

class TeamOpsOrchestrator:
    def __init__(self, feature_name):
        self.feature_name = feature_name
        self.state_file = Path(f".tmops/{feature_name}/runs/current/state.json")
        self.task_spec = Path(f".tmops/{feature_name}/runs/current/TASK_SPEC.md")
        
    async def run_workflow(self):
        print(f"🚀 Starting TeamOps v7 workflow for {self.feature_name}")
        
        # Phase 1: Testing
        print("\n📝 Phase 1: Writing Tests (Red Phase)")
        await self._update_state("testing", "tester")
        
        tester = TeamOpsTester()
        result = await tester.run(self.task_spec)
        print(f"✅ Tests written: {result}")
        
        # Check if tests are failing
        if await self._tests_failing():
            print("✅ Tests are properly failing (Red phase complete)")
            await self._update_state("testing", "tester", phase_complete=True)
        
        # Phase 2: Implementation
        print("\n🔨 Phase 2: Implementation (Green Phase)")
        await self._update_state("implementation", "implementer")
        
        implementer = TeamOpsImplementer()
        result = await implementer.run()
        print(f"✅ Implementation complete: {result}")
        
        # Check if tests are passing
        if await self._tests_passing():
            print("✅ Tests are passing (Green phase complete)")
            await self._update_state("implementation", "implementer", phase_complete=True)
        
        # Phase 3: Verification
        print("\n🔍 Phase 3: Verification")
        await self._update_state("verification", "verifier")
        
        verifier = TeamOpsVerifier()
        result = await verifier.run()
        print(f"✅ Verification complete: {result}")
        
        await self._update_state("verification", "verifier", phase_complete=True)
        print("\n🎉 TeamOps v7 workflow complete!")
    
    async def _update_state(self, phase, role, phase_complete=False):
        state = {
            "feature": self.feature_name,
            "phase": phase,
            "role": role,
            "phase_complete": phase_complete,
            "version": "v7-sdk"
        }
        self.state_file.write_text(json.dumps(state, indent=2))
    
    async def _tests_failing(self):
        # Run tests and check if they fail
        import subprocess
        result = subprocess.run(["npm", "test"], capture_output=True)
        return result.returncode != 0
    
    async def _tests_passing(self):
        # Run tests and check if they pass
        import subprocess
        result = subprocess.run(["npm", "test"], capture_output=True)
        return result.returncode == 0

# Usage
if __name__ == "__main__":
    orchestrator = TeamOpsOrchestrator("hello-v7")
    asyncio.run(orchestrator.run_workflow())
```

### TypeScript Alternative

```typescript
// tmops_v7_orchestrator.ts
import { query, ClaudeCodeOptions } from "@anthropic-ai/claude-code";
import * as fs from 'fs';
import { execSync } from 'child_process';

class TeamOpsOrchestrator {
  private featureName: string;
  private statePath: string;
  
  constructor(featureName: string) {
    this.featureName = featureName;
    this.statePath = `.tmops/${featureName}/runs/current/state.json`;
  }
  
  async runWorkflow() {
    console.log(`🚀 Starting TeamOps v7 workflow for ${this.featureName}`);
    
    // Phase 1: Testing
    await this.runTester();
    
    // Phase 2: Implementation
    await this.runImplementer();
    
    // Phase 3: Verification
    await this.runVerifier();
  }
  
  private async runTester() {
    const testerOptions: ClaudeCodeOptions = {
      systemPrompt: "You are the TESTER. Write failing tests.",
      allowedTools: ["Read", "Write", "Edit", "Bash"],
      // Tool restrictions would go here
    };
    
    for await (const message of query({
      prompt: "Write comprehensive failing tests for the task spec",
      options: testerOptions
    })) {
      if (message.type === "result") {
        console.log("Tests written:", message.result);
      }
    }
  }
  
  private async runImplementer() {
    const implementerOptions: ClaudeCodeOptions = {
      systemPrompt: "You are the IMPLEMENTER. Make tests pass.",
      allowedTools: ["Read", "Write", "Edit", "Bash"],
      // Tool restrictions
    };
    
    for await (const message of query({
      prompt: "Implement code to make all tests pass",
      options: implementerOptions
    })) {
      if (message.type === "result") {
        console.log("Implementation complete:", message.result);
      }
    }
  }
  
  private async runVerifier() {
    const verifierOptions: ClaudeCodeOptions = {
      systemPrompt: "You are the VERIFIER. Review quality.",
      allowedTools: ["Read", "Bash", "Grep"], // Read-only
    };
    
    for await (const message of query({
      prompt: "Review code quality and test coverage",
      options: verifierOptions
    })) {
      if (message.type === "result") {
        console.log("Verification complete:", message.result);
      }
    }
  }
}
```

## Key Advantages of SDK Approach

### 1. Real Agent Isolation
- Each agent is a separate SDK client instance
- Tool permissions are enforced by the SDK
- No need to rely on advisory hooks

### 2. Programmatic Control
- Orchestrator script manages the workflow
- Can check test results programmatically
- State management is explicit and reliable

### 3. True Automation
- No manual intervention needed
- Agents run sequentially based on phase completion
- Notifications can be added at the orchestrator level

### 4. Scalability
- Can run multiple features in parallel
- Each feature gets its own orchestrator instance
- Agents can be reused across features

## Migration Path

### Step 1: Install SDK
```bash
# Python
pip install claude-code-sdk

# TypeScript
npm install @anthropic-ai/claude-code
```

### Step 2: Convert Subagent Markdown to SDK Agents
- Extract prompts from `.claude/agents/*.md`
- Create SDK agent classes with appropriate permissions
- Define tool restrictions for each role

### Step 3: Replace Hook-Based Orchestration
- Remove dependency on hooks for phase transitions
- Use orchestrator script to manage workflow
- Implement programmatic test result checking

### Step 4: Update Init Script
- Modify `init_feature_v7.sh` to create SDK config files
- Generate orchestrator script for each feature
- Remove hook installation steps (optional - keep for other uses)

## Limitations and Considerations

### 1. State Sharing
- Agents communicate through filesystem (tests, code, state.json)
- No direct agent-to-agent communication
- This matches the original v7 design

### 2. Context Persistence
- Each agent starts fresh (no shared conversation history)
- CLAUDE.md can provide persistent context
- State.json tracks workflow progress

### 3. Cost Implications
- Each agent invocation uses tokens
- Multiple agents = multiple API calls
- Consider caching and optimization

## Conclusion

The TeamOps v7 vision is **achievable** with the Claude Code SDK, but requires:
1. Using real SDK agents instead of markdown files
2. Programmatic orchestration instead of hook-based automation
3. Explicit state management instead of implicit detection

This approach provides:
- ✅ Real role-based isolation
- ✅ Automated TDD workflow
- ✅ Proper phase transitions
- ✅ Scalable architecture

The current implementation failed because it tried to use features that don't exist in Claude Code's interactive mode. The SDK provides the missing pieces to make v7 work as intended.