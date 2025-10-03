# GitHub @claude PR Integration Guide
**Date:** 2025-01-19
**Time:** 21:51:56 (Zurich Time)
**Context:** Understanding Claude Code's GitHub PR automation capabilities

## Executive Summary

Tagging @claude in a GitHub PR does NOT automatically implement changes from documentation alone. Claude requires explicit commands and the GitHub Action to be installed first. This document clarifies what @claude can and cannot do in GitHub PRs.

## Prerequisites

### Required Setup
Before @claude mentions work, you must install the GitHub integration:
```bash
# In Claude Code terminal
/install-github-app
```
This command guides you through:
- Setting up the GitHub app
- Configuring required secrets
- Enabling the action for your repository

## What @claude CAN Do

### 1. Respond to Explicit Commands
When properly configured, @claude responds to specific requests in PR/issue comments:

**Implementation Commands:**
- `@claude implement this feature` - Analyzes issue, writes code, creates PR
- `@claude fix the TypeError in user dashboard` - Locates bug, pushes fix
- `@claude implement based on the issue description` - Full feature implementation

**Review Commands:**
- `@claude review this PR` - Provides comprehensive code review
- `@claude check for security issues` - Security-focused review
- `@claude suggest improvements` - Enhancement recommendations

### 2. Automated Workflows
Can be configured for:
- Automatic PR reviews when opened/updated
- Path-specific reviews (e.g., critical files)
- External contributor special handling
- Custom review checklists
- Scheduled maintenance checks

### 3. Code Generation Capabilities
- Analyzes issue descriptions
- Writes implementation code
- Creates pull requests
- Generates appropriate commit messages
- Follows project standards (via CLAUDE.md file)

## What @claude CANNOT Do

### 1. Auto-implement from Documents
- **Won't process**: Just posting analysis document + @claude tag
- **Won't auto-update**: Multiple files based on written specifications alone
- **Won't infer**: Complex changes without explicit instructions

### 2. Work Without Setup
- No response without GitHub Action installed
- No access without proper authentication
- No changes without explicit permissions

### 3. Context Limitations
- Cannot see full repository history without access
- Cannot modify files outside PR scope
- Cannot override repository protection rules

## Practical Examples

### ❌ What WON'T Work:
```markdown
@claude
Here's our 482-line analysis document about TeamOps V8 architecture...
[document content]
Please implement all these changes.
```
Result: Claude won't automatically rewrite all instruction files

### ✅ What WILL Work:
```markdown
@claude Based on the analysis in this PR, please:
1. Update tmops_v6_portable/instance_instructions/01_orchestrator.md to add:
   - Resource discovery section after reading TASK_SPEC.md
   - Check for Version 2.0.0 vs 1.0.0
   - List available patterns in checkpoint triggers

2. Add pattern loading sections to 02_tester.md:
   - Test framework discovery before writing tests
   - Pattern translation using detected framework

3. Create example pattern files in docs/patterns/testing/
```
Result: Claude will make specific changes and create PR

### ✅ Even More Specific:
```markdown
@claude Please update the orchestrator checkpoint format starting at line 61
in 01_orchestrator.md to include an "Available Resources" section that lists:
- Preflight Status (Version 2.0.0 or 1.0.0)
- Preflight Outputs locations
- Available Pattern Files
```
Result: Claude makes precise, targeted change

## Authentication Options

Claude Code GitHub Action supports:
1. **Anthropic Direct API** - Using ANTHROPIC_API_KEY
2. **Amazon Bedrock** - AWS credentials
3. **Google Vertex AI** - GCP authentication

## Project Standards Integration

Create `CLAUDE.md` in repository root to define:
- Coding standards
- Architecture patterns
- Testing requirements
- Documentation format

Claude respects these during all implementations.

## Alternative Solutions

### Third-party Options:
1. **PR-Agent** - Open-source AI PR assistant
2. **Bedrock Claude PR Reviewer** - AWS-based solution
3. **Custom GitHub Actions** - Build your own integration

## Key Takeaways

1. **Explicit Instructions Required**: Claude needs clear commands, not just documents
2. **Setup is Mandatory**: GitHub Action must be installed first
3. **Specificity Yields Results**: The more specific the request, the better the outcome
4. **Project Standards Matter**: CLAUDE.md file guides all implementations
5. **Not Magic**: Claude is a tool that responds to commands, not an autonomous agent

## Implementation Strategy for TeamOps V8

To implement our analyzed changes:

### Step 1: Install GitHub Integration
```bash
/install-github-app
```

### Step 2: Create Specific PR Comments
Break down the 482-line analysis into specific, actionable commands:
```markdown
@claude Update 01_orchestrator.md lines 40-50 to add preflight detection
@claude Add pattern loading section to 02_tester.md after line 45
@claude Create pattern file at docs/patterns/testing/api_test_patterns.md
```

### Step 3: Review and Iterate
- Review Claude's PRs
- Request specific adjustments
- Merge when satisfied

## Common Pitfalls

1. **Using /claude instead of @claude** - Must use @ symbol
2. **Vague requests** - "Make it better" won't work
3. **Missing setup** - Forgetting to install GitHub app
4. **Exceeding scope** - Asking for changes outside PR context
5. **Document dumping** - Posting long documents without specific asks

## Resources

- Official Docs: `https://docs.claude.com/en/docs/claude-code/github-actions`
- GitHub Action: `https://github.com/anthropics/claude-code-action`
- Marketplace: `https://github.com/marketplace/actions/claude-code-action-official`

## Conclusion

@claude in GitHub is a powerful tool for automated code implementation, but it requires:
- Proper setup via `/install-github-app`
- Explicit, specific commands
- Clear scope definition

It's not a magical document-to-code converter, but rather an intelligent assistant that responds to precise requests within the GitHub ecosystem.