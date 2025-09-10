<!--
📁 FILE: /home/anthonycalek/projects/tmops_framework/CODE/tmops_v6_portable/templates/09_patch_template.md
🎯 PURPOSE: Template for documenting patches and updates to existing documents with AI instructions for change tracking and validation
🤖 AI-HINT: Use for patching/updating existing documentation with structured methodology for change documentation and impact analysis
🔗 DEPENDENCIES: Existing documents, change tracking workflow, validation procedures
📝 CONTEXT: Part of template library for standardized patch documentation with AI-ready change tracking structure

FILE NAMING CONVENTION:
When saving this completed template, use:
TEMPLATE_NUM="09"  # This template number
DATE=$(date +%Y-%m-%d)  # YYYY-MM-DD format
TIME=$(date +%H%M%S)    # HHMMSS format
FEATURE="feature_name"  # Replace with actual feature (lowercase, underscores)
FILENAME="${TEMPLATE_NUM}_${DATE}_${TIME}_${FEATURE}_patch.md"
Example: 09_2025-09-09_213607_visual_component_capture_patch.md
-->

---
# Document Patch Template - AI-Ready Change Documentation
# Version: 1.0.0
# License: CC BY 4.0
# Purpose: Document patches, updates, corrections to existing documents

meta:
  version: "1.0.0"
  template_name: "document_patch"
  id: "PATCH-XXXX"
  title: "Patch: [Target Document] - [Brief Change Description]"
  type: "patch"
  date: "YYYY-MM-DD"
  author: "@handle"
  reviewers: ["@reviewer1"]
  complexity: "auto"  # trivial|low|medium|high|auto
  patch_type: "correction|update|enhancement|deprecation"
  
patch_context:
  target_document: "TASK-XXXX|IMPL-XXXX|DISC-XXXX"  # Document being patched
  source_trigger: "bug_report|new_requirement|feedback|audit"
  urgency: "critical|high|medium|low"
  impact_scope: "local|component|system|organization"
---

# Document Patch: [Target Document] - [Change Description]

## AI Patch Instructions

> **For AI Agents:** You are creating a structured document patch.
> 
> 1. **Identify Changes**: Clearly specify what needs modification
> 2. **Justify Changes**: Provide evidence for why changes are needed
> 3. **Impact Analysis**: Assess downstream effects of changes
> 4. **Validation**: Ensure changes maintain document coherence
> 5. **Evidence Required**:
>    - Original content vs proposed changes
>    - Stakeholder feedback or bug reports
>    - Validation that changes solve stated problem
> 6. **Depth Control**:
>    - Trivial: Simple corrections (≤1 page)
>    - Low: Minor updates (≤2 pages)
>    - Medium: Significant changes (≤3 pages)
>    - High: Major restructuring (≤4 pages)
> 7. **Cross-Reference**: Update related documents if needed
> 8. **Maintain Traceability**: Link changes to original requirements

## Executive Summary

### Patch Overview
<!-- One paragraph describing what is being changed and why -->

### Change Type
- **Type**: [Correction|Update|Enhancement|Deprecation]
- **Scope**: [Section|Multiple Sections|Entire Document]
- **Impact**: [Low|Medium|High]
- **Urgency**: [Critical|High|Medium|Low]

### Key Changes
1. **Change 1**: [What is being modified]
2. **Change 2**: [What is being added/removed]
3. **Change 3**: [What is being updated]

## Target Document Analysis

### Document Identification
- **Target Document**: [Document ID and title]
- **Current Version**: [Version number]
- **Document Type**: [research|plan|discovery|proposal|implementation|task_spec|summary|review]
- **Last Modified**: [Date]
- **Current Author(s)**: [@handle1, @handle2]

### Document Status
- **Current State**: [draft|review|approved|deprecated]
- **Usage**: [actively_referenced|archived|superseded]
- **Dependencies**: [List documents that reference this one]

## Change Analysis

### Problem Statement
<!-- What issue prompted this patch -->
- **Issue**: [Specific problem identified]
- **Evidence**: [How problem was discovered]
- **Impact**: [Consequences of not fixing]
- **Reporter**: [@person or system]

### Root Cause Analysis
1. **Primary Cause**: [Why the issue exists]
2. **Contributing Factors**: [What made it worse]
3. **Detection Gap**: [Why wasn't it caught earlier]

## Proposed Changes

### Change Set 1: [Section Name]
#### Current Content
```markdown
[Exact text being replaced - quote original]
```

#### Proposed Content
```markdown
[New text - show exact replacement]
```

#### Rationale
- **Why Changed**: [Justification for change]
- **Evidence**: [Support for new content]
- **Impact**: [How this improves the document]

### Change Set 2: [Section Name]
<!-- Repeat pattern for each change -->

### Additions
#### New Section: [Section Name]
```markdown
[New content being added]
```
- **Purpose**: [Why this section is needed]
- **Placement**: [Where in document structure]

### Deletions
#### Removed Section: [Section Name]
- **Reason**: [Why removing]
- **Content Archived**: [Where old content goes if needed]
- **References Updated**: [How removal affects other docs]

## Impact Assessment

### Document Coherence
- **Structure Impact**: [How changes affect document flow]
- **Consistency**: [Alignment with document style/tone]
- **Completeness**: [Does patched doc remain complete]

### Downstream Effects
| Affected Document | Change Required | Priority | Owner |
|-------------------|----------------|----------|-------|
| TASK-001 | Update references | High | @owner1 |
| IMPL-002 | Revise implementation | Medium | @owner2 |
| DISC-003 | No change needed | - | - |

### Stakeholder Impact
- **Authors**: [How original authors are affected]
- **Reviewers**: [Re-review requirements]
- **Users**: [Who uses this document and impact]
- **Systems**: [Automated processes that reference doc]

## Validation Plan

### Technical Validation
- [ ] All links still work
- [ ] Cross-references updated
- [ ] Formatting consistent
- [ ] Metadata updated

### Content Validation
- [ ] Changes solve stated problem
- [ ] New content factually accurate
- [ ] Style matches document tone
- [ ] Technical accuracy verified

### Stakeholder Review
| Reviewer | Role | Required | Status |
|----------|------|----------|--------|
| @original_author | Original Author | Yes | Pending |
| @subject_expert | Subject Expert | Yes | Pending |
| @doc_maintainer | Documentation | Yes | Pending |

## Implementation Plan

### Phased Rollout
1. **Phase 1**: Apply patch to target document
2. **Phase 2**: Update dependent documents
3. **Phase 3**: Notify stakeholders
4. **Phase 4**: Archive old versions

### Communication Plan
- **Internal Team**: [How to notify team]
- **Document Users**: [How to communicate changes]
- **Stakeholders**: [Key people to inform]

### Rollback Plan
- **Backup**: [Where original version stored]
- **Rollback Trigger**: [Conditions requiring rollback]
- **Rollback Process**: [Steps to revert changes]

## Quality Gates

### Pre-Implementation Checklist
- [ ] Problem clearly defined
- [ ] Solution addresses root cause
- [ ] All changes reviewed
- [ ] Dependencies identified
- [ ] Impact assessed
- [ ] Stakeholders consulted

### Post-Implementation Validation
- [ ] Changes implemented correctly
- [ ] Dependent docs updated
- [ ] No new issues introduced
- [ ] Stakeholders notified
- [ ] Version control updated

## Risk Assessment

### Implementation Risks
| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Breaking downstream docs | Medium | High | Update dependencies |
| Content accuracy issues | Low | Medium | Expert review |
| Stakeholder rejection | Low | High | Early consultation |

### Mitigation Strategies
1. **Risk**: [Specific concern]
   - **Prevention**: [How to avoid]
   - **Response**: [What to do if occurs]
   - **Owner**: [@responsible_person]

## Traceability

### Change History
```yaml
patch_id: PATCH-XXXX
target: TASK-001 v2.1
trigger: Bug report #142
changes:
  - section: "Requirements"
    type: "correction"
    lines: "45-52"
  - section: "Acceptance Criteria"  
    type: "addition"
    content: "New scenario for error handling"
```

### Related Changes
- **Related Patches**: [Other patches affecting same area]
- **Original Issues**: [Bug reports, feedback that led to this]
- **Future Patches**: [Known follow-up changes needed]

## Version Management

### Versioning Strategy
- **Current Version**: [Target doc version]
- **New Version**: [Post-patch version]
- **Version Scheme**: [How versions are managed]

### Change Log Entry
```markdown
## [Version X.Y.Z] - YYYY-MM-DD
### Changed
- Fixed incorrect requirement in REQ-003 (PATCH-XXXX)
- Updated acceptance criteria for edge cases (PATCH-XXXX)
### Added
- New error handling scenario (PATCH-XXXX)
```

## Documentation Standards

### Style Consistency
- [ ] Follows established document style
- [ ] Terminology consistent throughout
- [ ] Formatting matches document conventions
- [ ] AI hints updated if applicable

### Metadata Updates
- [ ] Document version incremented
- [ ] Last modified date updated
- [ ] Author list updated if needed
- [ ] Template version noted

## Success Criteria

### Patch Acceptance Criteria
- [ ] Original problem solved
- [ ] No new issues introduced
- [ ] Stakeholder approval obtained
- [ ] Dependencies updated
- [ ] Quality gates passed

### Success Metrics
- **Problem Resolution**: [How to measure success]
- **User Satisfaction**: [Feedback mechanism]
- **System Impact**: [Performance/usage metrics]

## Next Steps

### Immediate Actions
1. [ ] Submit patch for review
2. [ ] Address reviewer feedback
3. [ ] Update dependent documents
4. [ ] Communicate changes

### Follow-up Tasks
- [ ] Monitor for issues post-implementation
- [ ] Collect feedback on changes
- [ ] Plan any needed refinements
- [ ] Archive old versions

## Lessons Learned

### Process Improvements
- **What Worked**: [Effective aspects of patch process]
- **What Didn't**: [Areas for improvement]
- **Recommendations**: [For future patches]

### Prevention Measures
- **Root Cause**: [How to prevent similar issues]
- **Detection**: [How to catch issues earlier]
- **Process**: [Workflow improvements]

---

## Profile Guidelines

### Trivial Profile (≤1 page)
- Focus: Simple corrections, typos
- Omit: Detailed impact analysis, complex validation
- Use for: Spelling fixes, minor clarifications

### Low Profile (≤2 pages)
- Focus: Minor updates, small additions
- Include: Basic impact assessment, stakeholder review
- Use for: Requirement clarifications, small enhancements

### Medium Profile (≤3 pages)
- Focus: Significant changes, multiple sections
- Include: Full impact analysis, validation plan
- Use for: Requirement changes, process updates

### High Profile (≤4 pages)
- Focus: Major restructuring, critical fixes
- Include: Comprehensive analysis, risk assessment
- Use for: Document overhauls, critical corrections

---

*Template Version: 1.0.0 | Patch Framework | CC BY 4.0 License*