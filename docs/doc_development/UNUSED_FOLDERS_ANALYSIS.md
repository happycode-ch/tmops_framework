# TeamOps Framework: Unused Folders Analysis Report

**Document Type:** Investigation Report  
**Created:** 2025-01-19  
**Purpose:** Analysis of disconnect between documented folder structure and actual usage  
**For Discussion:** Control Chat strategic planning session

## Executive Summary

The TeamOps framework documentation describes an elaborate folder structure under `.tmops/<feature>/` including `outputs/`, `logs/`, and `gates/` directories. However, investigation reveals these folders are never created or used in practice. All inter-instance communication and work artifacts are being funneled exclusively through checkpoint files, creating what I call the "Checkpoint Monopoly" phenomenon.

This disconnect represents a significant gap between architectural design and operational reality, potentially confusing users and limiting the framework's organizational capabilities.

## Investigation Methodology

### Scope of Analysis
- All 4 core documentation files in `tmops_docs_v4/`
- Focus on instance prompts and instructions
- Path specifications and file location guidance
- Actual vs documented folder usage patterns

### Search Patterns Analyzed
1. Direct folder references (`outputs/`, `logs/`, `gates/`)
2. File location instructions ("where", "put", "save", "location")
3. Instance write operations and their destinations
4. Checkpoint content patterns

### Key Documents Reviewed
- `tmops_4-inst_protocol.md` - Shows folder structure
- `tmops_claude_code_4-inst.md` - Instance instructions
- `tmops_claude_chat_4-inst.md` - Strategic layer
- `tmops_orchestration_protocol_4-inst.md` - Definitive guide

## Critical Findings

### 1. The Checkpoint Monopoly

**Finding:** All instance outputs are being directed into checkpoint files rather than dedicated folders.

**Evidence:**
- Checkpoint files contain test file lists, implementation file lists, metrics, and logs
- No instructions tell instances WHERE to save actual test or implementation files
- The only explicitly specified paths are for checkpoints

**Example from documentation:**
```markdown
## Test Files
- tests/auth.test.ts
- tests/validation.test.ts
- tests/integration.test.ts
```
This appears IN the checkpoint file itself, not as instruction to create these files.

### 2. Missing Path Instructions

**Finding:** Documentation never tells instances WHERE to write their work files.

**Analysis of prompts:**
- Tester: "Write comprehensive failing tests" - but WHERE?
- Implementer: "Write implementation code to pass tests" - but WHERE?
- Verifier: Reviews only, no file writing specified
- Orchestrator: Only writes checkpoints and SUMMARY.md

**What's Missing:**
- No `cd tests/` instruction
- No `save to .tmops/<feature>/outputs/` directive
- No path specifications beyond checkpoints

### 3. Documentation Shows Structure, Not Usage

**Finding:** The folder structure appears aspirational, not operational.

**Documented Structure (Line 241-262 of tmops_4-inst_protocol.md):**
```
.tmops/<feature>/
├── TASK_SPEC.md
├── checkpoints/
├── outputs/
│   └── 2025-01-15/
│       ├── tests/
│       ├── implementation/
│       └── verification/
└── logs/
    ├── orchestrator.log
    ├── tester.log
    ├── implementer.log
    └── verifier.log
```

**Actual Usage:**
- Only `TASK_SPEC.md` and `checkpoints/` are actively used
- `outputs/` never referenced in instructions
- `logs/` mentioned once as example, never operationalized
- No `gates/` folder despite gate mechanisms

### 4. Default Behavior Pattern

**Finding:** Instances follow standard project conventions due to lack of explicit guidance.

**Observed Pattern:**
1. Tester writes tests to project's standard `tests/` or `test/` directory
2. Implementer writes to standard `src/` or similar
3. Both commit to git repository normally
4. Only checkpoints go to `.tmops/` structure

**Why This Happens:**
- Git worktrees share the same repository
- Standard tooling expects standard locations
- No instructions override these defaults

## Root Cause Analysis

### Primary Causes

1. **Instruction Gap**
   - Prompts focus on WHAT to do, not WHERE to put it
   - Checkpoint creation is explicit, file locations are implicit

2. **Over-Reliance on Checkpoints**
   - Checkpoints became both communication AND documentation
   - Easier to list files in checkpoint than manage separate folders

3. **Practical Constraints**
   - Test runners expect tests in standard locations
   - Build tools expect source in standard locations
   - Moving files to `.tmops/outputs/` would break tooling

4. **Evolution Without Refactoring**
   - Framework evolved from simpler versions
   - Folder structure added conceptually but not operationally
   - Documentation accumulated rather than consolidated

### Secondary Factors

- No validation or enforcement of folder usage
- No examples showing actual folder population
- Success metrics tied only to checkpoint completion
- Instances never instructed to check for these folders

## Impact Assessment

### Current State Consequences

1. **User Confusion**
   - Documentation promises organization that doesn't materialize
   - Users may waste time looking for outputs in wrong places

2. **Lost Opportunities**
   - No separation of framework artifacts from project code
   - No timestamped archival of iterations
   - No structured logging for debugging

3. **Reduced Traceability**
   - All information compressed into checkpoints
   - Harder to track evolution of specific files
   - No clear artifact separation

### Potential Benefits if Implemented

1. **Better Organization**
   - Clear separation of TeamOps artifacts from project code
   - Timestamped iterations for comparison
   - Structured logs for analysis

2. **Enhanced Debugging**
   - Instance-specific logs for troubleshooting
   - Preserved outputs for review
   - Clear audit trail

## Discussion Points for Control Chat

### Key Questions to Address

1. **Design Philosophy**
   - Should we implement the documented structure or simplify documentation?
   - Is folder separation worth the added complexity?
   - How important is artifact preservation?

2. **Implementation Approach**
   - Add explicit path instructions to all prompts?
   - Create symlinks from standard locations to `.tmops/outputs/`?
   - Use post-processing to copy files?

3. **Backward Compatibility**
   - How to handle existing workflows?
   - Migration path for current users?
   - Version strategy for changes?

4. **Priority Assessment**
   - Is this a critical fix or nice-to-have?
   - What's the effort vs benefit ratio?
   - Should this be v5.1 or v6.0?

## Proposed Solutions

### Option 1: Full Implementation (High Complexity)
**Approach:** Implement the complete documented folder structure

**Changes Required:**
- Modify all instance prompts with explicit paths
- Add folder creation instructions
- Implement file copying/moving logic
- Create symlinks for tool compatibility

**Pros:**
- Matches documentation
- Maximum organization
- Full artifact preservation

**Cons:**
- High implementation effort
- May break existing workflows
- Adds complexity for users

### Option 2: Checkpoint Enhancement (Medium Complexity)
**Approach:** Keep checkpoint-centric model but enhance it

**Changes Required:**
- Extend checkpoint format to include file contents
- Add automatic extraction tools
- Implement checkpoint-to-folder converter

**Pros:**
- Maintains current workflow
- Backward compatible
- Progressive enhancement

**Cons:**
- Large checkpoint files
- Still doesn't use documented folders
- Partial solution

### Option 3: Documentation Alignment (Low Complexity)
**Approach:** Update documentation to match reality

**Changes Required:**
- Remove unused folder references
- Document actual behavior
- Clarify checkpoint-centric approach

**Pros:**
- Immediate clarity
- No implementation needed
- Honest about current state

**Cons:**
- Loses organizational vision
- May disappoint users expecting more
- Admits design limitation

### Option 4: Hybrid Approach (Medium Complexity)
**Approach:** Implement logging only, document test/code location reality

**Changes Required:**
- Add logging instructions to prompts
- Keep test/implementation in standard locations
- Document this as intentional design

**Pros:**
- Practical compromise
- Preserves useful features
- Acknowledges constraints

**Cons:**
- Partial implementation
- Still some documentation updates needed

## Recommendations for Control Chat

### Immediate Actions
1. Acknowledge the disconnect in documentation
2. Decide on philosophical approach (aspirational vs operational)
3. Choose implementation strategy based on user needs

### Strategic Considerations
1. Survey actual users about their needs
2. Consider framework's long-term evolution
3. Balance idealism with pragmatism

### Suggested Priority
1. **High Priority:** Fix documentation to prevent confusion
2. **Medium Priority:** Implement logging for debugging
3. **Low Priority:** Full folder structure implementation

## Appendix: Evidence Samples

### Missing Instructions Example
From `tmops_claude_code_4-inst.md`, Tester workflow (lines 102-109):
```
1. Poll for 001-discovery.md (every 10 seconds)
2. When found, read Task Spec requirements
3. Explore codebase (read-only)
4. Write test files covering all criteria  # WHERE?
5. Run tests to confirm they fail
6. Commit test files
7. Create 003-tests-complete.md
8. Your work is done
```

### Checkpoint Content Example
The checkpoint includes file lists but not locations:
```markdown
## Test Files
- tests/auth.test.ts
- tests/validation.test.ts
```

This suggests files are in standard project locations, not `.tmops/outputs/`.

## Conclusion

The TeamOps framework exhibits a clear disconnect between its documented folder structure and actual operational behavior. This "Checkpoint Monopoly" pattern emerged naturally from practical constraints and the path of least resistance. 

The control chat discussion should focus on whether to:
1. Embrace the checkpoint-centric reality
2. Implement the full folder vision
3. Find a pragmatic middle ground

The decision will significantly impact both user experience and implementation effort, making this a critical architectural choice for the framework's future.

---

*This report prepared for strategic discussion. Please review with AI teammate to determine optimal path forward.*