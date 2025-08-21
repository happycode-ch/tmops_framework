# hello-v7 Test Feature Walkthrough

## Overview
The hello-v7 feature is a simple Hello World API designed to validate and demonstrate the TeamOps v7 automated TDD workflow. It serves as both a test case and learning example.

## Feature Description
A REST API endpoint that returns personalized JSON greetings with timestamps.

### Requirements
- GET /hello returns "Hello, World!"
- GET /hello?name=Alice returns "Hello, Alice!"
- Empty name parameter returns 400 error
- All responses include ISO timestamp

## Setup Process

### 1. Initialize the Feature
```bash
./tmops_tools/v7/init_feature_v7.sh hello-v7 initial
```

This creates:
- `.tmops/hello-v7/` directory structure
- Initial state.json
- TASK_SPEC.md template
- Installs subagents and hooks (if first time)

### 2. Configure Task Specification
The TASK_SPEC.md has been pre-configured with clear requirements for a Hello World API including:
- 4 specific acceptance criteria
- Technology stack (Node.js, Express, Jest)
- Example usage scenarios
- Error handling requirements

### 3. Node.js Project Setup
A package.json is provided with necessary dependencies:
- express: Web framework
- jest: Testing framework
- supertest: HTTP testing

## Expected Workflow Execution

### Phase 1: Testing (Red Phase)
**Agent**: tmops-tester

The tester subagent should create `test/hello.test.js` with:
- Test for default greeting
- Test for personalized greeting
- Test for empty name error case
- Test for timestamp validation
- Tests for edge cases (special characters, unicode)

All tests should initially FAIL since no implementation exists.

### Phase 2: Implementation (Green Phase)
**Agent**: tmops-implementer

The implementer subagent should create `src/hello.js` with:
- Express server setup
- Single GET /hello endpoint
- Query parameter handling
- Error checking for empty name
- JSON response formatting
- Timestamp generation

After implementation, all tests should PASS.

### Phase 3: Verification (Review Phase)
**Agent**: tmops-verifier

The verifier subagent should:
- Run all tests to confirm passing
- Review code quality
- Check acceptance criteria
- Generate verification report

## Running the Validation

### Quick Validation Script
```bash
./tmops_tools/v7/test/validate_hello_v7.sh
```

This script checks:
- Feature structure exists
- TASK_SPEC is configured
- State file is present
- Expected outputs are available
- Hooks are configured
- Subagents are installed

### Full Workflow Test
```bash
TMOPS_V7_ACTIVE=1 claude "Build hello-v7 feature using TeamOps v7"
```

## Expected Outputs

### Test File Structure
```
test/
└── hello.test.js    # 6 comprehensive tests
```

### Implementation Structure
```
src/
└── hello.js         # Express server with /hello endpoint
```

### Verification Report
A detailed report covering:
- Test results (6/6 passing)
- Code quality assessment
- Feature completeness
- Performance metrics
- Security review

## Validation Criteria

### Success Indicators
1. **Automatic Phase Transitions**: Hooks detect test completion
2. **Role Enforcement**: Each agent only modifies allowed files
3. **Test Coverage**: All 4 acceptance criteria tested
4. **Clean Implementation**: Minimal code to pass tests
5. **Complete Verification**: Comprehensive review generated

### Expected Timeline
- Phase 1 (Testing): ~2 minutes
- Phase 2 (Implementation): ~2 minutes
- Phase 3 (Verification): ~1 minute
- **Total**: ~5 minutes

## Comparing with Expected Outputs

The `.tmops/hello-v7/expected/` directory contains reference implementations:
- `hello.test.js` - Expected test file
- `hello.js` - Expected implementation
- `verification-report.md` - Expected verification

Compare actual outputs with these files to validate correctness.

## Troubleshooting

### Issue: Tests don't run
**Solution**: Ensure Node.js dependencies are installed
```bash
npm install
```

### Issue: Hooks not triggering
**Solution**: Check TMOPS_V7_ACTIVE environment variable is set

### Issue: Phase transitions not detected
**Solution**: Verify test output format matches detection patterns

### Issue: Subagent not found
**Solution**: Check `.claude/agents/tmops-*.md` files exist

## Learning Points

### TDD Workflow
1. **Red**: Write failing tests first
2. **Green**: Minimal implementation to pass
3. **Review**: Verify quality and completeness

### Automation Benefits
- No manual coordination required
- Automatic phase detection
- Role-based isolation
- Progress notifications

### v7 Advantages
- Single Claude instance (vs 4 in v6)
- No worktrees needed
- Fully automated transitions
- Self-aware hooks

## Conclusion

The hello-v7 feature demonstrates a complete TeamOps v7 workflow in ~5 minutes with zero manual intervention. It validates:
- Hook functionality
- Subagent execution
- Phase transitions
- Role enforcement
- State management

Use this as a template for testing v7 with your own features!