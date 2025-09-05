<!--
📁 FILE: /home/anthonycalek/projects/tmops_framework/CODE/.tmops/tmops-mcp/docs/internal/09_template_naming_convention_report.md
🎯 PURPOSE: Bug report and analysis of template naming convention issues in TeamOps framework
🤖 AI-HINT: Comprehensive issue report documenting template naming problems, root cause analysis, and corrective actions
🔗 DEPENDENCIES: tmops_v6_portable/templates/, instance_instructions/, framework documentation
📝 CONTEXT: Critical framework issue affecting AI agents' ability to follow consistent naming conventions
-->

---
# Situation Report Template - AI-Ready Status Communication
# Version: 1.0.0
# License: CC BY 4.0
# Purpose: Bug report on template naming convention discrepancies affecting AI agent workflow

meta:
  version: "1.0.0"
  template_name: "situation_report"
  id: "RPT-BUG-001"
  title: "Report: Template Naming Convention Bug - 2025-09-05"
  type: "report"
  date: "2025-09-05"
  author: "@claude-code"
  distribution: ["@development-team", "@framework-maintainers"]
  complexity: "standard"
  report_type: "incident"
  frequency: "ad_hoc"
  
report_context:
  situation_id: "BUG-TMPL-001"
  reporting_period: "2025-09-05"
  previous_report: "N/A"
  next_report_due: "N/A"
---

# Situation Report: Template Naming Convention Bug - 2025-09-05

## Executive Summary

### Situation Status
- **Overall Status**: 🟡 At Risk - Framework functionality impaired
- **Reporting Period**: 2025-09-05
- **Key Metric**: Template consistency compliance - 0% (No enforcement)
- **Confidence Level**: High

### Critical Updates
1. **🔥 Critical**: AI agents lack explicit instructions for template usage and naming conventions
2. **⚠️ Risk**: Template numbering conflicts (multiple 08_ prefixed templates)
3. **✅ Achievement**: Issue identified and documented with clear remediation path

### Immediate Attention Required
- **Decision Needed**: Approve template renumbering strategy
- **Escalation**: None required - can be fixed immediately
- **Resources**: Developer time to update instructions and renumber templates

## Current Status Analysis

### Progress Metrics
| Metric | Target | Current | Previous | Trend | Status |
|--------|--------|---------|----------|--------|--------|
| Template Consistency | 100% | 0% | N/A | N/A | 🔴 |
| Instruction Clarity | Complete | Missing | N/A | N/A | 🔴 |
| Numbering Conflicts | 0 | 2 | N/A | N/A | 🔴 |
| Documentation Accuracy | 100% | 66% | N/A | N/A | 🟡 |

### Performance Dashboard
```yaml
current_period_summary:
  issues_identified: 4
  root_causes_found: 4
  fixes_proposed: 4
  implementation_effort: "2 hours"
  
impact_analysis:
  affected_workflows: "All AI agent workflows"
  severity: "Medium - causes confusion, not failure"
  user_impact: "Inconsistent documentation generation"
  framework_integrity: "Compromised but functional"
```

## Issues & Risks

### Current Issues

🔴 **Critical Issues**
| Issue | Impact | Status | Owner | Due Date |
|-------|--------|--------|-------|----------|
| No template usage instructions | High | Identified | @dev-team | 2025-09-05 |
| Template numbering conflicts | Medium | Identified | @dev-team | 2025-09-05 |
| Missing naming conventions | High | Identified | @dev-team | 2025-09-05 |
| Inconsistent preflight vs main | Medium | Identified | @dev-team | 2025-09-05 |

### Root Cause Analysis

1. **Missing Template Instructions**
   - Instance instruction files contain no references to template directory
   - No guidance on how to use templates when generating documentation
   - No specification of output naming conventions

2. **Template Numbering Conflicts**
   - `08_human_tasks_template.md` (newly added)
   - `08_patch_template.md` (existing)
   - Creates ambiguity in sequential numbering scheme

3. **Naming Convention Absence**
   - No documented standard for output file naming
   - Agents create files with varied naming patterns
   - No enforcement mechanism in place

4. **Workflow Inconsistency**
   - Preflight instances have explicit file naming in instructions
   - Main workflow instances lack any naming guidance
   - Creates divergent behaviors between workflows

## Findings Detail

### Template Directory Analysis
```
tmops_v6_portable/templates/
├── 00_research_template.md         ✓ Correct
├── 01_plan_template.md             ✓ Correct
├── 02_discovery_template.md        ✓ Correct
├── 03_proposal_template.md         ✓ Correct
├── 04_implementation_template.md   ✓ Correct
├── 05_task_spec_template.md        ✓ Correct
├── 06_summary_template.md          ✓ Correct
├── 07_review_template.md           ✓ Correct
├── 08_human_tasks_template.md      ⚠️ Conflict
├── 08_patch_template.md            ⚠️ Conflict
└── 09_report_template.md           ✓ Correct
```

### Instance Instruction Analysis
- **01_orchestrator.md**: No template references found
- **02_tester.md**: No template references found
- **03_implementer.md**: No template references found
- **04_verifier.md**: No template references found
- **02_preflight_researcher.md**: Has explicit output naming
- **03_preflight_analyzer.md**: Has explicit output naming
- **04_preflight_specifier.md**: Has explicit output naming

### Generated Files Analysis
Files in `.tmops/tmops-mcp/docs/internal/`:
- Some follow numbering: `00_research_report.md`, `01_strategic_plan.md`
- Some don't: `mcp_implementation_proposal.md`
- Inconsistent patterns throughout

## Corrective Actions

### Immediate Actions (Today)

1. **Renumber Conflicting Templates**
   - Rename `08_patch_template.md` → `10_patch_template.md`
   - Rename `09_report_template.md` → `11_report_template.md`
   - Keep `08_human_tasks_template.md` as is

2. **Add Template Usage Instructions**
   - Update all instance instruction files
   - Add explicit template usage section
   - Specify output naming conventions

3. **Create Naming Convention Guide**
   ```markdown
   ## Template Usage Instructions
   
   When creating documentation, use templates from `tmops_v6_portable/templates/`:
   1. Select appropriate template based on task
   2. Fill template with required information
   3. Save to `.tmops/<feature>/docs/internal/`
   4. Use naming convention: `[template_number]_[descriptive_name].md`
      - Example: `00_research_findings.md` (from 00_research_template.md)
      - Example: `05_task_specification.md` (from 05_task_spec_template.md)
   ```

4. **Update Documentation**
   - Fix README.md template counts
   - Update CLAUDE.md with template guidelines
   - Add to CHANGELOG.md

### Implementation Plan

```yaml
fix_implementation:
  step_1:
    action: "Renumber conflicting templates"
    files:
      - "tmops_v6_portable/templates/08_patch_template.md → 10_patch_template.md"
      - "tmops_v6_portable/templates/09_report_template.md → 11_report_template.md"
    
  step_2:
    action: "Update instance instructions"
    files:
      - "tmops_v6_portable/instance_instructions/01_orchestrator.md"
      - "tmops_v6_portable/instance_instructions/02_tester.md"
      - "tmops_v6_portable/instance_instructions/03_implementer.md"
      - "tmops_v6_portable/instance_instructions/04_verifier.md"
    additions: "Template usage section with naming conventions"
    
  step_3:
    action: "Update documentation"
    files:
      - "README.md - Update template list"
      - "tmops_v6_portable/README.md - Update template list"
      - "CHANGELOG.md - Add fix entry"
```

## Recommendations

### Immediate Actions (Next 48 Hours)
1. **Action**: Apply template renumbering
   - **Rationale**: Eliminates numbering conflicts immediately
   - **Owner**: @dev-team
   - **Resources Needed**: File system access

2. **Action**: Update all instance instructions
   - **Rationale**: Provides clear guidance to AI agents
   - **Owner**: @dev-team
   - **Resources Needed**: Editor, 1 hour

### Short-term Actions (This Week)
- **Action**: Test updated instructions with new feature
  - **Priority**: High
  - **Impact**: Validates fix effectiveness

### Strategic Recommendations
- **Recommendation**: Add automated validation for template numbering
  - **Business Case**: Prevents future conflicts
  - **Timeline**: Next sprint

## Lessons Learned

### What's Working Well
- **Success Factor 1**: Preflight instances have clear naming
  - **Evidence**: Consistent output from preflight workflow
  - **Replication**: Apply same pattern to main workflow

### Areas for Improvement
- **Challenge 1**: Lack of explicit instructions
  - **Root Cause**: Assumption that agents would infer conventions
  - **Proposed Solution**: Explicit instructions in all instance files

- **Challenge 2**: No validation of template numbering
  - **Action Plan**: Add pre-commit hook to check for conflicts

## Future Outlook

### Expected Outcome
- Consistent template usage across all AI agents
- Predictable output file naming
- Reduced confusion in documentation generation
- Improved framework reliability

### Success Metrics
- 100% template naming consistency
- Zero numbering conflicts
- All agents following conventions within 24 hours

## Verification Plan

### Test Criteria
1. No duplicate template numbers
2. All instance instructions contain template usage section
3. Generated files follow naming convention
4. Documentation accurately reflects template count

### Validation Steps
```bash
# Check for duplicate numbers
ls tmops_v6_portable/templates/ | cut -d_ -f1 | sort | uniq -d

# Verify instructions updated
grep -l "Template Usage" tmops_v6_portable/instance_instructions/*.md

# Test with new feature
./tmops_tools/init_feature_multi.sh test-naming
```

---

## Summary

This incident report documents a critical but easily fixable issue in the TeamOps framework where AI agents lack proper instructions for template usage and naming conventions. The issue manifests as inconsistent documentation generation and template numbering conflicts. The fix involves renumbering conflicting templates, adding explicit usage instructions to all instance files, and updating documentation. Total implementation time estimated at 2 hours with immediate positive impact on framework reliability.

---

*Report Version: 1.0.0 | Bug Report Framework | TeamOps v6*