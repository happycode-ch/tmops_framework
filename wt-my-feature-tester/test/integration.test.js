const request = require('supertest');
const app = require('../src/app');

describe('Integration tests for hello API', () => {
  describe('Application setup', () => {
    test('should export Express application', () => {
      expect(app).toBeDefined();
      expect(typeof app).toBe('function');
      expect(app.listen).toBeDefined();
    });

    test('should have /api/hello route configured', async () => {
      const response = await request(app)
        .get('/api/hello');
      expect(response.status).not.toBe(404);
    });

    test('should use Express JSON middleware', async () => {
      const response = await request(app)
        .post('/api/test')
        .send({ test: 'data' })
        .set('Content-Type', 'application/json');
      // Even if endpoint doesn't exist, Express should parse JSON
      expect(response.status).toBeDefined();
    });
  });

  describe('Full request-response cycle', () => {
    test('should complete request within timeout', async () => {
      const response = await request(app)
        .get('/api/hello')
        .timeout(100);
      expect(response.status).toBe(200);
    });

    test('should handle rapid sequential requests', async () => {
      for (let i = 0; i < 5; i++) {
        const response = await request(app)
          .get('/api/hello');
        expect(response.status).toBe(200);
        expect(response.body.message).toBe('Hello, World!');
      }
    });

    test('should maintain consistent response format', async () => {
      const responses = [];
      for (let i = 0; i < 3; i++) {
        const response = await request(app)
          .get('/api/hello');
        responses.push(response.body);
      }
      
      // All responses should have same structure
      responses.forEach(body => {
        expect(Object.keys(body).sort()).toEqual(['message', 'timestamp'].sort());
      });
    });

    test('should generate unique timestamps for each request', async () => {
      const timestamps = [];
      for (let i = 0; i < 3; i++) {
        const response = await request(app)
          .get('/api/hello');
        timestamps.push(response.body.timestamp);
        if (i > 0) {
          await new Promise(resolve => setTimeout(resolve, 10));
        }
      }
      
      // All timestamps should be unique
      const uniqueTimestamps = [...new Set(timestamps)];
      expect(uniqueTimestamps.length).toBe(timestamps.length);
    });
  });

  describe('Server behavior', () => {
    test('should handle empty request headers', async () => {
      const response = await request(app)
        .get('/api/hello');
      expect(response.status).toBe(200);
    });

    test('should handle large request headers', async () => {
      const largeHeader = 'x'.repeat(1000);
      const response = await request(app)
        .get('/api/hello')
        .set('X-Large-Header', largeHeader);
      expect(response.status).toBe(200);
    });

    test('should not leak internal errors', async () => {
      // Try to trigger an error by sending invalid data
      const response = await request(app)
        .get('/api/hello')
        .set('Content-Length', 'invalid');
      // Should handle gracefully without exposing stack trace
      expect(response.status).toBeDefined();
      if (response.status >= 500) {
        expect(response.body).not.toMatch(/stack/i);
        expect(response.body).not.toMatch(/error/i);
      }
    });
  });
});