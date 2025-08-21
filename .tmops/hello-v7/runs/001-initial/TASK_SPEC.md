# Task Specification: Hello World API

## Objective
Create a simple REST API endpoint that returns personalized JSON greetings with timestamp.

## Acceptance Criteria
- [ ] GET /hello returns JSON with message "Hello, World!"
- [ ] GET /hello?name=Alice returns JSON with message "Hello, Alice!"
- [ ] GET /hello with empty name parameter returns 400 status with error message
- [ ] All responses include a timestamp field in ISO format

## Technical Requirements
### Functionality
- Simple HTTP server with one endpoint
- Query parameter parsing for name
- JSON response formatting
- Error handling for invalid input

### Error Handling
- Empty name parameter should return 400 Bad Request
- Error message should be clear: "Name parameter cannot be empty"
- Non-error responses should return 200 OK

### Performance
- Response time under 100ms
- Minimal memory footprint

## Constraints
- **Language**: JavaScript (Node.js 14+)
- **Framework**: Express.js
- **Testing**: Jest with Supertest

## Expected Deliverables
1. **Tests**: Comprehensive test suite in `test/`
2. **Implementation**: Express server in `src/`
3. **Documentation**: This spec serves as documentation

## Example Usage
```javascript
// GET /hello
{
  "message": "Hello, World!",
  "timestamp": "2024-01-15T10:30:00.000Z"
}

// GET /hello?name=Alice
{
  "message": "Hello, Alice!",
  "timestamp": "2024-01-15T10:30:00.000Z"
}

// GET /hello?name= (error case)
{
  "error": "Name parameter cannot be empty",
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

## Notes
This is a simple test feature to validate TeamOps v7 automated workflow
