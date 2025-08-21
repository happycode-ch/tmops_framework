/**
 * Expected test file that tester subagent should create
 * This demonstrates comprehensive TDD test coverage
 */

const request = require('supertest');
const app = require('../src/hello');

describe('Hello World API', () => {
  describe('GET /hello', () => {
    it('should return "Hello, World!" when no name is provided', async () => {
      const response = await request(app)
        .get('/hello')
        .expect(200);
      
      expect(response.body).toHaveProperty('message', 'Hello, World!');
      expect(response.body).toHaveProperty('timestamp');
      expect(new Date(response.body.timestamp)).toBeInstanceOf(Date);
    });

    it('should return personalized greeting when name is provided', async () => {
      const response = await request(app)
        .get('/hello?name=Alice')
        .expect(200);
      
      expect(response.body).toHaveProperty('message', 'Hello, Alice!');
      expect(response.body).toHaveProperty('timestamp');
    });

    it('should return 400 error when name parameter is empty', async () => {
      const response = await request(app)
        .get('/hello?name=')
        .expect(400);
      
      expect(response.body).toHaveProperty('error', 'Name parameter cannot be empty');
      expect(response.body).toHaveProperty('timestamp');
    });

    it('should include valid ISO timestamp in all responses', async () => {
      const response = await request(app)
        .get('/hello')
        .expect(200);
      
      const timestamp = response.body.timestamp;
      expect(timestamp).toMatch(/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$/);
      expect(new Date(timestamp).toISOString()).toBe(timestamp);
    });

    it('should handle names with special characters', async () => {
      const response = await request(app)
        .get('/hello?name=John%20Doe')
        .expect(200);
      
      expect(response.body.message).toBe('Hello, John Doe!');
    });

    it('should handle names with unicode characters', async () => {
      const response = await request(app)
        .get('/hello?name=José')
        .expect(200);
      
      expect(response.body.message).toBe('Hello, José!');
    });
  });

  // Server cleanup for tests
  afterAll((done) => {
    if (app.server) {
      app.server.close(done);
    } else {
      done();
    }
  });
});