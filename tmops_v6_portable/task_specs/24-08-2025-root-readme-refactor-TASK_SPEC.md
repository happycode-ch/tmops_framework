# Task Specification: Root README.md Refactoring

## Meta Information
- **ID**: TASK-001
- **Title**: Refactor Root README.md to Align with TeamOps v6.2 Simplified Architecture
- **Type**: docs
- **Priority**: P1 (Critical)
- **Status**: proposed
- **DRI**: @maintainer
- **Complexity**: medium
- **Profile**: standard
- **Date**: 2025-08-24

## Context

### Problem Statement
The root README.md contains 290 lines of mixed accurate and obsolete information, with 45+ references to git worktrees that no longer exist in v6.2 Simplified Edition. This causes installation failures, user confusion, and professional credibility issues.

### Background
TeamOps evolved from v6.0 (worktree-based) to v6.2 Simplified (branch-based), but documentation wasn't updated. The README violates multiple documentation best practices and contains references to 3 different versions (v6.0, v7.0, v8.0) creating confusion about current architecture.

### Impact
- New users cannot successfully install TeamOps
- Existing users confused about version and features
- Failed commands damage framework credibility
- 30+ minutes wasted per user troubleshooting

## Scope

### In Scope
- Complete rewrite of root README.md for v6.2 Simplified
- Removal of all worktree references and obsolete commands
- Clear version statement and architecture explanation
- Working installation and usage instructions
- Professional structure following best practices

### Out of Scope
- Changes to TeamOps codebase or scripts
- Documentation for archived versions (v7.0, v8.0)
- Detailed API documentation
- Video tutorials or external documentation

### MVP
A clean, accurate README that allows new users to install and run TeamOps v6.2 in under 5 minutes.

## Requirements

### Functional Requirements
- **MUST** remove all 45+ worktree references
- **MUST** provide working installation commands for v6.2
- **MUST** clearly state current version as v6.2 Simplified Edition
- **MUST** include accurate project structure diagram
- **MUST** provide copy-pasteable setup commands that work
- **SHOULD** include migration guide from v6.0 to v6.2
- **SHOULD** add table of contents for navigation
- **MAY** include badges for CI status and license

### Non-Functional Requirements
- **Performance**: README loads in <2 seconds
- **Accessibility**: All images have alt text
- **Compatibility**: GitHub-flavored markdown compliant
- **Length**: Target 150-200 lines (current 290)
- **Readability**: Flesch-Kincaid score >60

## Acceptance Criteria

### Scenario: New User Installation
```gherkin
Given a developer with a fresh Ubuntu/macOS system
When they follow the README installation instructions
Then TeamOps v6.2 is installed and functional within 5 minutes
And they can run init_feature_multi.sh successfully
```

### Scenario: Version Clarity
```gherkin
Given any reader of the README
When they read the first section
Then they understand TeamOps is at v6.2 Simplified Edition
And they know it uses branches, not worktrees
```

### Scenario: Command Execution
```gherkin
Given a user copying commands from the README
When they paste and execute each command
Then all commands run without errors
And produce the expected results
```

### Scenario: Architecture Understanding
```gherkin
Given a technical reader
When they view the architecture section
Then they understand the branch-based workflow
And see no references to git worktrees
```

## Test Plan

### Content Validation
- Verify zero worktree references remain
- Confirm all tool names match current implementation
- Check all file paths reflect actual structure
- Validate version stated as v6.2 throughout

### Technical Testing
- Test installation on fresh Ubuntu 22.04
- Test installation on macOS 14+
- Verify all code blocks have language specifications
- Check all internal links resolve correctly
- Validate markdown with markdownlint

### User Testing
- Time new user from README to working system
- Document any confusion points
- Verify examples actually execute
- Test troubleshooting section effectiveness

## Definition of Done

### Required Criteria
- [x] All worktree references removed (0 remaining)
- [x] Version clearly stated as v6.2 Simplified Edition
- [x] Installation completes in <5 minutes on fresh system
- [x] All commands execute without errors
- [x] Markdown passes linting (markdownlint)
- [x] Peer reviewed by 2+ developers
- [x] Tested on Ubuntu and macOS
- [x] No regression in functionality

## Implementation Details

### Structure Template
```markdown
# TeamOps Framework — Orchestrated AI Development with TDD

## Description
[Clear value proposition in 2-3 sentences]

## Quick Start
[5-minute tutorial to first feature]

## Overview
- Key Features (v6.2 only)
- Architecture (branch-based)
- Benefits

## Installation
### Prerequisites
### Setup Steps

## Usage
### Basic Workflow
### Coordination Protocol
### Examples

## Project Structure
[Current structure without worktrees]

## Documentation
[Links to guides]

## Contributing
[Link to CONTRIBUTING.md]

## License
MIT with attribution

## Links
[Repository, Issues, Support]
```

### Specific Changes Required

#### Must Remove
- Lines 21: "Git Worktree Integration" feature
- Lines 45-67: Instance roles with worktree paths
- Lines 88-95: Worktree setup commands
- Lines 103-108: Navigation between worktrees
- Lines 146-168: File structure showing worktrees
- Lines 299-338: v7.0 archived content

#### Must Update
- Title: Simplify to single-line tagline
- Version: State "v6.2 Simplified Edition" prominently
- Installation: Reference `init_feature_multi.sh`
- Usage: Show branch-based workflow
- Architecture: New diagram without worktrees

#### Must Add
- Quick Start section (5-minute guide)
- Migration notes from v6.0
- Troubleshooting common issues
- Clear success indicators

## Risks and Dependencies

### Risks
- **User Confusion**: During transition period
  - *Mitigation*: Add clear migration banner
- **Broken External Links**: From old tutorials
  - *Mitigation*: Add redirect notes
- **Search Index**: Old content cached
  - *Mitigation*: Update meta descriptions

### Dependencies
- Access to current v6.2 codebase
- Verification of all script names
- Testing environments (Ubuntu/macOS)

## LLM Execution Guidelines

### Autonomy Level
constrained

### Allowed Tools
- git (for version verification)
- bash (for command testing)
- markdown linters

### Repository Paths
- **Read**: All paths (for verification)
- **Write**: README.md only

### Constraints
- Do NOT modify any code files
- Do NOT change script functionality
- Preserve MIT license exactly
- Keep professional tone throughout

### Evaluation Commands
```bash
# Verify no worktree references
grep -i "worktree" README.md | wc -l  # Should be 0

# Check markdown validity
npx markdownlint README.md

# Verify all links
npx markdown-link-check README.md

# Test line count
wc -l README.md  # Target: 150-200
```

## Deliverables

### Primary Artifact
- Refactored README.md (150-200 lines)

### Supporting Documents
- Migration guide snippet
- Troubleshooting section
- Quick start tutorial

### Review Checklist
- [ ] Meets all acceptance criteria
- [ ] Zero worktree references
- [ ] Commands tested and working
- [ ] Professional appearance
- [ ] Clear value proposition
- [ ] Under 200 lines

## Citations and References

### Documentation Best Practices
1. **README Best Practices** — GitHub Documentation, 2024; https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-readmes; accessed 2025-08-24
2. **The Art of README** — Stephen Whitmore, 2024; https://github.com/noffle/art-of-readme; accessed 2025-08-24
3. **RFC 2119: Key words for use in RFCs** — IETF, 1997; https://www.ietf.org/rfc/rfc2119.txt; accessed 2025-08-24

### Technical Standards
4. **CommonMark Specification** — CommonMark, v0.30; https://spec.commonmark.org/; accessed 2025-08-24
5. **Semantic Versioning** — Tom Preston-Werner, 2.0.0; https://semver.org/; accessed 2025-08-24

## Success Metrics

### Quantitative
- Installation time: <5 minutes (from 30+ currently)
- README length: 150-200 lines (from 290)
- Worktree references: 0 (from 45+)
- Failed commands: 0 (from 10+)

### Qualitative
- User confusion reports decrease by 80%
- Positive feedback on clarity
- No version-related issues reported
- Professional appearance confirmed

## Timeline Estimate
- Research and verification: 1 hour
- Content restructuring: 2 hours
- Writing and editing: 2 hours
- Testing and validation: 1 hour
- Review and refinement: 1 hour
- **Total**: 7 hours

## Notes
This task focuses on documentation accuracy and user experience. The refactored README will serve as the single source of truth for TeamOps v6.2 Simplified Edition, eliminating confusion and enabling rapid adoption.

---
*Task Specification Version 1.0 - Based on AI-Ready Task Spec Template v1.2.0*