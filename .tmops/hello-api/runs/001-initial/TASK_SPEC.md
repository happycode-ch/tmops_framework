# Task Specification: hello-api

## Objective
Create a simple HTTP API endpoint that returns a greeting message in JSON format, demonstrating the TeamOps Framework v5.2.0 4-instance orchestration system.

## Acceptance Criteria
- [ ] GET /api/hello returns {"message": "Hello, World!", "timestamp": "<ISO-8601>"}
- [ ] Response has 200 status code
- [ ] Content-Type header is application/json
- [ ] Handle non-GET methods with 405 Method Not Allowed
- [ ] Include proper error handling for edge cases
- [ ] Tests achieve > 80% code coverage

## Technical Requirements
- Simple HTTP endpoint implementation
- JSON response format with proper headers
- ISO-8601 timestamp format (e.g., "2025-01-20T10:30:00Z")
- Error responses in consistent JSON format
- Use standard library where possible (minimize dependencies)

## Constraints
- Tests must be written first and fail initially (TDD approach)
- Implementation must be in src/ directory
- Tests must be in test/ or tests/ directory
- No external API dependencies
- Keep implementation simple and focused

## Expected Deliverables
1. Tests in `test/` or `tests/` directory covering all acceptance criteria
2. Implementation in `src/` directory with the API endpoint
3. All tests passing with > 80% coverage
4. Clean, readable code following project conventions

## Notes
This is a test feature to validate the TeamOps Framework v5.2.0 orchestration system. The focus is on demonstrating proper instance coordination through checkpoint communication.
