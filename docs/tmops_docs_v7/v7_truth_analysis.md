# TeamOps v7: The Truth About Subagents and Hooks

## Executive Summary
After thorough investigation, TeamOps v7's implementation has **fundamental misunderstandings** about Claude Code's capabilities. The system was built on incorrect assumptions about how subagents and hooks work.

## The Truth About Subagents

### What the Documentation Says
According to the official Claude Code documentation:
- Subagents ARE supported via `.claude/agents/*.md` files
- They need YAML frontmatter with `name`, `description`, and optional `tools`
- Claude Code can delegate tasks to them automatically or explicitly

### What Actually Happens
1. **No Custom subagent_type**: When using the Task tool, you can only specify:
   - `"general-purpose"`
   - `"statusline-setup"`
   - `"output-style-setup"`
   
2. **The .claude/agents/*.md files exist but**:
   - They are NOT available as new subagent types
   - You cannot invoke them with `subagent_type: "tmops-tester"`
   - They work through **context-driven delegation**, not explicit type invocation

3. **How They Actually Work** (based on documentation):
   - Claude reads these files and may use them to guide behavior
   - Invocation happens through natural language: "Use the tmops-tester subagent to..."
   - The general-purpose agent reads the instructions and follows them
   - This is more like "prompt templates" than true isolated agents

### Critical Discovery
**The v7 implementation incorrectly assumes**:
```python
# This DOES NOT WORK
Task(subagent_type="tmops-tester", ...)  # ❌ Error: Agent type not found
```

**What actually works**:
```python
# This is what happens
Task(
    subagent_type="general-purpose",
    prompt="Use the tmops-tester subagent to write tests..."
)
# Claude MAY read .claude/agents/tmops-tester.md and follow its instructions
```

## The Truth About Hooks

### What v7 Assumes Hooks Do
1. Automatically detect test results and trigger phase transitions
2. Block tool usage based on roles
3. Orchestrate the entire workflow automatically
4. Update state.json and manage the pipeline

### What Hooks Actually Do
Based on the official documentation:

1. **Hooks are shell commands** that execute at specific events
2. **They have limited control**:
   - PreToolUse can block actions (return `{"continue": false}`)
   - PostToolUse runs after tools complete
   - They provide feedback to Claude but don't control workflow

3. **Critical Limitations**:
   - Hooks cannot automatically invoke other tools or subagents
   - They cannot force Claude to take specific actions
   - They're advisory, not orchestrative
   - They require environment variables (like TMOPS_V7_ACTIVE) to activate

### Evidence from Our Test
- **Zero hook logs created**: `.tmops/hello-v7/runs/current/logs/` is empty
- **No automatic transitions**: I manually updated state.json
- **No notifications sent**: The hook system never activated
- **No role enforcement**: I had full access to all files

## The Gap Analysis

### What v7 Designed For
```
Hooks detect test results → Update state → Invoke next subagent → Automatic workflow
```

### What Actually Happened
```
Manual test check → Manual state update → Manual agent invocation → Manual workflow
```

### Why It Failed

1. **Subagent Misconception**:
   - v7 expected: Separate agent instances with enforced restrictions
   - Reality: Single Claude instance reading different prompt templates

2. **Hook Misconception**:
   - v7 expected: Hooks orchestrate and control the workflow
   - Reality: Hooks provide feedback but don't control Claude's actions

3. **State Management**:
   - v7 expected: Automatic state transitions via hooks
   - Reality: Hooks can write to files but can't make Claude read them

## The Real Architecture

### What Works
1. **Subagents as Prompt Templates**: The .md files can guide behavior when explicitly referenced
2. **Hooks as Monitors**: They can log, notify, and provide feedback
3. **Manual Orchestration**: A human can follow the workflow manually

### What Doesn't Work
1. **Automatic Orchestration**: No mechanism for hooks to control Claude's next action
2. **True Agent Isolation**: All "subagents" share the same context and permissions
3. **Enforced Restrictions**: Tool restrictions are suggestions, not enforced

## Proof: Testing the Real Behavior

### Test 1: Custom Subagent Type
```bash
# Created .claude/agents/tmops-tester.md with proper YAML frontmatter
# Attempted: Task(subagent_type="tmops-tester")
# Result: Error - Agent type 'tmops-tester' not found
```

### Test 2: Hook Execution
```bash
# Ran entire "automated" workflow
# Checked: ls .tmops/hello-v7/runs/current/logs/
# Result: Empty directory - no hooks fired
```

### Test 3: Role Restrictions
```bash
# "Tester" subagent created src/hello.js (should be restricted)
# "Implementer" could have modified tests (should be restricted)
# Result: No actual restrictions enforced
```

## Conclusion

TeamOps v7's architecture is based on **capabilities that don't exist** in Claude Code:

1. **Custom subagent types**: Not supported - only general-purpose + 2 specific types
2. **Orchestrative hooks**: Hooks can't control Claude's workflow
3. **Enforced isolation**: All "subagents" are the same Claude instance

The system "worked" in our test only because:
- I manually orchestrated everything
- I pretended to follow role restrictions
- I simulated what should have happened automatically

## The Path Forward

### Option 1: Use Claude Code SDK
The SDK (Python/TypeScript) provides real agent instances with:
- Actual permission enforcement
- Programmatic orchestration
- True isolation between agents

### Option 2: Accept Manual Orchestration
Keep v7 as a structured manual process:
- Subagents as guidelines/templates
- Hooks for logging/notifications only
- Human orchestrates the workflow

### Option 3: Hybrid Approach
- Use hooks for monitoring and notifications
- Use explicit prompts to invoke subagent behavior
- Accept that it's semi-automated, not fully automated

## Key Takeaway
**TeamOps v7 as designed cannot work with Claude Code's current capabilities.** The test "succeeded" through manual simulation, not automation. The fundamental assumptions about subagents and hooks were incorrect.