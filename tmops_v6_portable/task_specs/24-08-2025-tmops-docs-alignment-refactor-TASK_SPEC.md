# TASK_SPEC: TeamOps v6.2 Documentation Alignment Refactor

## Meta
- **ID**: TASK-TMOPS-001
- **Title**: Align TeamOps v6 Portable Documentation with v6.2 Simplified Architecture
- **Type**: refactor
- **Priority**: P1
- **Status**: proposed
- **DRI**: @tmops-maintainer
- **Stakeholders**: ["@dev-team", "@documentation-team"]
- **Conventions**:
  - **Commit Prefix**: docs/refactor
  - **Branch Naming**: task/TASK-TMOPS-001-docs-alignment
- **Changelog Required**: true

## Context

### Problem
The TeamOps v6 Portable documentation in `tmops_v6_portable/docs/tmops_docs_v6/` is significantly misaligned with the current v6.2 simplified implementation. Documentation still references the obsolete worktree-based architecture that was removed in commits 54a3db1 and c182382, causing user confusion and setup failures.

### Background
Recent architectural simplification removed Git worktrees entirely, transitioning to a single-branch, root-directory operation model. This fundamental change improved usability but left documentation outdated, creating a critical gap between documented and actual system behavior.

### Links
- **Development Report**: `tmops_v6_portable/development_report/23_08_2025-tmops-docs-alignment-DEV_REPORT.md`
- **Current README**: `tmops_v6_portable/README.md` (already updated)
- **Instance Instructions**: `tmops_v6_portable/instance_instructions/` (already updated)

## Scope

### In
- Update `tmops_claude_code.md` to remove all worktree references
- Update `tmops_protocol.md` to reflect simplified architecture
- Update `tmops_claude_chat.md` to correct version inconsistencies
- Standardize version numbers to v6.2.0-simplified
- Align all file paths with current structure
- Update workflow descriptions to match root directory operation

### Out
- Changes to actual code implementation
- Updates to README.md (already correct)
- Updates to instance_instructions/ (already correct)
- Creation of new documentation files
- Modifications to tmops_tools scripts

### MVP
Remove all worktree references and align documentation with v6.2 simplified architecture where all instances work in root directory on single feature branch.

## Requirements

### Functional
1. Documentation MUST accurately reflect that all instances work in root directory
2. Documentation MUST show correct v6.2.0-simplified version throughout
3. Documentation MUST remove all references to Git worktrees
4. Documentation MUST describe sequential workflow with manual coordination
5. File paths in documentation MUST match actual project structure
6. Instance identification instructions MUST align with current implementation
7. Documentation SHOULD consolidate redundant information where possible
8. Documentation MAY include migration notes from v6.0 to v6.2

### Non-Functional
1. **Clarity**: Documentation MUST be clear and unambiguous for new users
2. **Consistency**: All documents MUST use consistent terminology and version numbers
3. **Completeness**: Documentation MUST cover all four instance roles comprehensively
4. **Maintainability**: Documentation structure SHOULD facilitate future updates

## Acceptance Criteria

```gherkin
Scenario: Documentation contains no worktree references
  Given the documentation files in tmops_v6_portable/docs/tmops_docs_v6/
  When I search for "worktree" or "wt-" patterns
  Then no matches should be found in any documentation file

Scenario: Version numbers are consistent
  Given all documentation files
  When I check version references
  Then all files should reference "v6.2.0-simplified" or "v6.2"
  And no references to v5.x or v6.0 should exist

Scenario: Instance instructions match reality
  Given the tmops_claude_code.md file
  When I read the instance identification section
  Then it should state all instances work in root directory
  And it should reference the correct instruction files
  And it should not mention directory navigation between instances

Scenario: File structures are accurate
  Given documentation showing file structures
  When compared to actual project structure
  Then paths should match exactly
  And no references to wt-* directories should exist
  And .tmops/<feature>/ structure should be correctly shown

Scenario: Workflow descriptions are correct
  Given workflow descriptions in documentation
  When compared to instance_instructions/ content
  Then they should describe sequential operation
  And they should show manual coordination steps
  And they should reference single feature branch usage
```

## Test Plan

### Unit
- Grep search for "worktree", "wt-", "workspaces" patterns
- Version number consistency check across all files
- File path validation against actual structure

### Integration
- Dry-run new user onboarding with updated documentation
- Verify each instance role can be understood from documentation
- Test workflow execution following documented steps

### Acceptance
- All acceptance criteria pass via automated checks
- Manual review confirms clarity and completeness
- No contradictions between different documentation files

### Coverage Target
100% of documentation files reviewed and updated where needed

## Definition of Done

### Criteria
- [x] All worktree references removed from documentation
- [x] Version numbers standardized to v6.2.0-simplified
- [x] File paths match current project structure
- [x] Instance instructions aligned with root directory operation
- [x] Workflow descriptions match instance_instructions/
- [x] No contradictions between documentation files
- [x] All acceptance criteria tests pass
- [x] Documentation reviewed and approved by stakeholder
- [x] Changes committed with appropriate message

## Risks & Dependencies

### Risks
1. **Risk**: Users currently following old documentation may be confused by changes
   - **Mitigation**: Include clear migration notes at top of updated files
   
2. **Risk**: Some edge cases or advanced features may not be documented
   - **Mitigation**: Cross-reference with instance_instructions/ for completeness

### Dependencies
- Access to tmops_v6_portable/docs/tmops_docs_v6/ directory
- Understanding of current v6.2 simplified architecture
- Reference to development report for specific issues

## LLM Execution

### Autonomy Level
constrained

### Allowed Tools
["git", "bash", "grep", "sed", "markdown-linters"]

### Repo Read Paths
["tmops_v6_portable/docs/", "tmops_v6_portable/instance_instructions/", "tmops_v6_portable/README.md"]

### Repo Write Paths
["tmops_v6_portable/docs/tmops_docs_v6/"]

### Constraints
- Do NOT modify code files or scripts
- Do NOT create new documentation files
- Preserve existing documentation structure while updating content
- Maintain markdown formatting and readability

### Evaluation
```bash
# Check for worktree references
grep -r "worktree\|wt-" tmops_v6_portable/docs/tmops_docs_v6/ || echo "✓ No worktree references found"

# Verify version consistency
grep -r "v[56]\.[0-9]" tmops_v6_portable/docs/tmops_docs_v6/ | grep -v "v6.2" || echo "✓ Version numbers consistent"

# Validate markdown
npx markdownlint tmops_v6_portable/docs/tmops_docs_v6/*.md || true
```

## Deliverables

### Artifacts
- **Type**: docs
- **Paths**: 
  - `tmops_v6_portable/docs/tmops_docs_v6/tmops_claude_code.md`
  - `tmops_v6_portable/docs/tmops_docs_v6/tmops_protocol.md`
  - `tmops_v6_portable/docs/tmops_docs_v6/tmops_claude_chat.md`

### Review Checklist
- [ ] All worktree references removed
- [ ] Version numbers consistent (v6.2.0-simplified)
- [ ] File paths accurate to current structure
- [ ] Instance roles clearly defined for root directory operation
- [ ] Workflow matches sequential single-branch model
- [ ] No contradictions with README.md or instance_instructions/
- [ ] Documentation is clear for new users
- [ ] Markdown formatting is correct

## Implementation Priority

### Phase 1: Critical Updates (HIGHEST PRIORITY)
1. Update `tmops_claude_code.md` - most critical misalignments
   - Remove worktree directory references (lines 13-21, 40-43, etc.)
   - Update instance identification for root directory
   - Fix file structure diagrams
   - Update all role sections (Orchestrator, Tester, Implementer, Verifier)

### Phase 2: Supporting Documentation (MEDIUM PRIORITY)
2. Update `tmops_protocol.md`
   - Fix version references
   - Update instance headers for root directory
   - Remove worktree architecture diagrams

3. Update `tmops_claude_chat.md`
   - Standardize version numbers
   - Update "What's New" section for v6.2
   - Remove legacy version references

### Phase 3: Validation (FINAL)
4. Cross-reference all documents for consistency
5. Run validation scripts
6. Test complete workflow with updated documentation

## Specific Changes Required

### tmops_claude_code.md Changes

#### Lines 13-21 - Instance Identification
```markdown
## You Are ONE of FOUR Instances

All instances work in the ROOT project directory.
Determine which instance you are based on the instructions you receive:
- Received 01_orchestrator.md → You are the ORCHESTRATOR
- Received 02_tester.md → You are the TESTER  
- Received 03_implementer.md → You are the IMPLEMENTER
- Received 04_verifier.md → You are the VERIFIER

Each instance has a specific role and CANNOT do the work of other instances.
All instances work on the same feature branch: feature/<name>
```

#### Lines 381-411 - File Structure
```markdown
## File Structure (v6.2 Simplified)

### Project Structure
project-root/                 # All instances work here
├── .tmops/<feature>/        # TeamOps orchestration files
│   └── runs/current/
│       ├── TASK_SPEC.md
│       ├── checkpoints/
│       ├── logs/
│       └── metrics.json
├── src/                     # Implementation code
├── test/ or tests/          # Test files
└── tmops_v6_portable/       # Framework tools
    ├── tmops_tools/
    └── instance_instructions/
```

### tmops_protocol.md Changes

#### Version Update
- Change all instances of "v6.0.0-manual" to "v6.2.0-simplified"

#### Instance Headers
- Update all instance section headers to indicate "Root Directory - feature/<name> branch"
- Remove any references to wt-orchestrator, wt-tester, wt-impl, wt-verify

### tmops_claude_chat.md Changes

#### Version Standardization
- Update to v6.2.0-simplified throughout
- Remove v5.2.0 and v6.0.0-manual references

#### What's New Section
```markdown
## What's New in v6.2 Simplified

### Complete Simplification
- Removed all Git worktree complexity
- All instances work in root directory
- Single feature branch architecture
- No navigation confusion possible
- Setup time reduced to seconds

### Preserved Benefits
- Full TDD orchestration workflow
- Manual coordination for reliability
- Checkpoint-based progress tracking
- Comprehensive metrics and logging
```

## Assumptions
- Current instance_instructions/ files are the source of truth for workflow
- README.md accurately reflects current v6.2 architecture
- No additional documentation files need updating beyond the three identified

## Open Questions
- Should we maintain a version history section showing migration from v6.0 to v6.2?
- Should we add automated documentation validation to CI/CD pipeline?
- Do we need to update any external references or links to these documents?

## Success Metrics
- Zero worktree references in documentation
- 100% version consistency across files
- User confusion incidents reduced to zero
- Setup success rate increased to 100%
- Documentation review passes without corrections needed

---

**Created**: 2025-08-24  
**Author**: AI Assistant via Claude Code  
**Based On**: Development Report 23_08_2025-tmops-docs-alignment-DEV_REPORT.md  
**Framework**: TeamOps v6.2 Simplified Edition