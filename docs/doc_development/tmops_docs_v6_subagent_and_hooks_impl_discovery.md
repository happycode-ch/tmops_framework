Here's a carefully crafted prompt that nudges Claude Code in the direction of our discussion:

---

## Prompt for Claude Code: TeamOps v7 Architecture

I need your expertise to evolve the TeamOps framework from its current v5.2.0(tmops_docs_v6, location: docs/tmops_docs_v6/) implementation to a revolutionary v7 architecture using Claude Code's subagents and hooks capabilities.

### Current State Analysis Request

Please review the TeamOps framework v5.2.0 in this repository. The current implementation:
- Uses 4 separate Claude Code CLI instances (orchestrator, tester, implementer, verifier) 
- Relies on filesystem polling for coordination via checkpoint files
- Requires manual setup of 4 terminals with manual prompt pasting
- Has excellent role separation but inefficient resource usage
- Uses `tmops_tools/` for automation scripts but still requires human coordination

### Key Innovation Opportunity

I've been studying Claude Code's subagents and hooks documentation (attached as two NotebookLM guides). I believe we can transform TeamOps using these features to achieve:

1. **Single-command orchestration** instead of 4 terminals
2. **Isolated context windows** for each phase (preserving the current benefit of separate instances)
3. **Deterministic workflow control** via hooks (no more filesystem polling)
4. **Automatic phase transitions** when completion criteria are met
5. **Rich inter-phase communication** while maintaining context isolation

### Specific Questions for Your Analysis

1. **Subagent Architecture**: How can we transform the current 4 instance prompts into subagents that maintain context isolation while being coordinated from a single master instance?

2. **Hook Integration**: Which hook events (PreToolUse, PostToolUse, SessionStart, Stop) would be most valuable for:
   - Enforcing TDD (no implementation before tests)
   - Detecting phase completion (e.g., all tests written)
   - Automatically triggering the next subagent
   - Collecting metrics

3. **Context Preservation**: The current system benefits from isolated contexts per instance. How can we ensure subagents provide the same isolation while improving coordination?

4. **Hybrid Approach**: Should we consider a hybrid where:
   - Hooks handle deterministic operations (phase detection, enforcement)
   - Subagents handle role-specific work (test writing, implementation)
   - A master orchestrator coordinates via both mechanisms

5. **Migration Path**: What would be the safest migration path from v5.2.0(tmops_docs_v6) to v7 that:
   - Maintains backward compatibility during transition
   - Allows testing of new architecture alongside current system
   - Preserves all existing automation tools

### Deliverables Requested

Please provide:

1. **Architecture Design**: A complete v7 architecture showing how subagents and hooks work together

2. **Implementation Plan**: Step-by-step plan to create:
   - Subagent definitions for each role (using `/agents` command best practices)
   - Hook configurations for workflow automation
   - Master orchestration strategy

3. **Code Examples**: 
   - Sample subagent configurations (`.claude/agents/`)
   - Hook scripts for phase management (`tmops_tools/hooks/`)
   - Master orchestration prompt/script

4. **Critical Considerations**: 
   - Performance implications (latency from context switching)
   - Security considerations for hook scripts
   - Failure recovery strategies

### Vision Statement

Imagine running: `claude "Build user authentication feature using TeamOps"` and having:
- Hooks automatically detect and enforce TDD workflow
- Subagents handle each phase in isolation
- Automatic transitions when criteria are met
- Complete feature delivered with zero manual coordination
- Rich metrics and logging throughout

### Reference Materials

I'm providing two NotebookLM documents:
1. **Claude Code Subagents Guide** - Details on creating and managing subagents
2. **Claude Code Hooks Guide** - Comprehensive hooks documentation

Please analyze these in the context of TeamOps and show me how we can create a v7 that leverages both technologies to eliminate manual coordination while preserving the benefits of role separation and context isolation.

### Additional Context

The beauty of the current TeamOps design is the clear separation of concerns and isolated contexts. We want to preserve these benefits while eliminating the friction of manual coordination. Think of hooks as the "nervous system" that detects state changes and subagents as the "specialized workers" that execute in isolation.

Your expertise in both technologies will help us create something revolutionary - a fully automated TDD orchestration system that maintains quality while requiring zero human intervention after the initial command.

Please begin by reviewing the current v5.2.0 implementation, then provide your architectural recommendations for v7.

---

This prompt:
- Establishes clear context about the current system
- Highlights the specific pain points we discussed
- Suggests the vision of hooks + subagents working together
- Asks targeted questions that lead toward our discussed solution
- Requests concrete deliverables
- Emphasizes preserving context isolation (key benefit)
- Nudges toward the single-command orchestration goal
- Positions hooks and subagents as complementary technologies
- Includes the reference documents for grounding

The prompt is structured to guide Claude Code toward recognizing that:
1. Subagents solve the context isolation requirement
2. Hooks solve the deterministic control requirement  
3. Together they can eliminate manual coordination
4. The current instance prompts can be adapted to subagents
5. The evolution from v5.2.0(tmops_docs_v6) to v7 is natural and beneficial