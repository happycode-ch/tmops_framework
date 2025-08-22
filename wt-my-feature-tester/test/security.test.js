const request = require('supertest');
const app = require('../src/app');

describe('Security tests for hello endpoint', () => {
  describe('Input validation', () => {
    test('should ignore query parameters', async () => {
      const response = await request(app)
        .get('/api/hello?malicious=<script>alert(1)</script>');
      expect(response.status).toBe(200);
      expect(response.body.message).toBe('Hello, World!');
      expect(JSON.stringify(response.body)).not.toContain('<script>');
    });

    test('should ignore request body on GET', async () => {
      const response = await request(app)
        .get('/api/hello')
        .send({ malicious: 'data' });
      expect(response.status).toBe(200);
      expect(response.body.message).toBe('Hello, World!');
    });

    test('should handle malformed headers', async () => {
      const response = await request(app)
        .get('/api/hello')
        .set('X-Malformed', '\x00\x01\x02');
      expect(response.status).toBe(200);
    });
  });

  describe('Response security', () => {
    test('should not expose server information', async () => {
      const response = await request(app)
        .get('/api/hello');
      expect(response.headers['x-powered-by']).toBeUndefined();
      expect(response.headers['server']).not.toMatch(/Express/i);
    });

    test('should not include sensitive headers', async () => {
      const response = await request(app)
        .get('/api/hello');
      expect(response.headers['x-frame-options']).toBeDefined();
      expect(response.headers['x-content-type-options']).toBeDefined();
      expect(response.headers['x-xss-protection']).toBeDefined();
    });

    test('should set secure Content-Type', async () => {
      const response = await request(app)
        .get('/api/hello');
      expect(response.headers['content-type']).toMatch(/application\/json/);
      expect(response.headers['content-type']).toMatch(/charset=utf-8/);
    });

    test('should not reflect user input', async () => {
      const response = await request(app)
        .get('/api/hello')
        .set('X-User-Input', '<script>alert(1)</script>');
      const responseText = JSON.stringify(response.body);
      expect(responseText).not.toContain('<script>');
    });
  });

  describe('Rate limiting and abuse prevention', () => {
    test('should handle rapid requests', async () => {
      const promises = Array(100).fill(null).map(() => 
        request(app).get('/api/hello')
      );
      
      const responses = await Promise.all(promises);
      const successResponses = responses.filter(r => r.status === 200);
      
      // Should handle at least most requests successfully
      expect(successResponses.length).toBeGreaterThan(50);
    });

    test('should not consume excessive memory', async () => {
      const memBefore = process.memoryUsage().heapUsed;
      
      for (let i = 0; i < 100; i++) {
        await request(app).get('/api/hello');
      }
      
      const memAfter = process.memoryUsage().heapUsed;
      const memIncrease = memAfter - memBefore;
      
      // Memory increase should be reasonable (< 10MB)
      expect(memIncrease).toBeLessThan(10 * 1024 * 1024);
    });
  });

  describe('HTTP method security', () => {
    test('should reject POST with proper status', async () => {
      const response = await request(app)
        .post('/api/hello')
        .send({ data: 'test' });
      expect(response.status).toBe(405);
    });

    test('should reject PUT with proper status', async () => {
      const response = await request(app)
        .put('/api/hello')
        .send({ data: 'test' });
      expect(response.status).toBe(405);
    });

    test('should reject DELETE with proper status', async () => {
      const response = await request(app)
        .delete('/api/hello');
      expect(response.status).toBe(405);
    });

    test('should reject PATCH with proper status', async () => {
      const response = await request(app)
        .patch('/api/hello')
        .send({ data: 'test' });
      expect(response.status).toBe(405);
    });

    test('should allow HEAD requests', async () => {
      const response = await request(app)
        .head('/api/hello');
      expect(response.status).toBe(200);
      expect(response.text).toBe('');
    });

    test('should allow OPTIONS for CORS', async () => {
      const response = await request(app)
        .options('/api/hello');
      expect([200, 204]).toContain(response.status);
    });
  });

  describe('Path traversal prevention', () => {
    test('should not allow path traversal attempts', async () => {
      const response = await request(app)
        .get('/api/hello/../../../etc/passwd');
      expect(response.status).not.toBe(200);
    });

    test('should not expose file system paths', async () => {
      const response = await request(app)
        .get('/api/hello/%2e%2e%2f');
      expect(response.body).not.toMatch(/\/home\//);
      expect(response.body).not.toMatch(/\/usr\//);
      expect(response.body).not.toMatch(/C:\\/);
    });
  });
});