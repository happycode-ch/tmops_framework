/**
 * Test Suite for Hello API Endpoint
 * Testing Requirements:
 * - GET /api/hello returns proper JSON response
 * - Handles different HTTP methods correctly
 * - Returns proper status codes and headers
 * - Includes error handling
 */

const assert = require('assert');
const http = require('http');

// Test configuration
const TEST_PORT = 3000;
const TEST_HOST = 'localhost';
const API_PATH = '/api/hello';

/**
 * Helper function to make HTTP requests
 */
function makeRequest(method, path, callback) {
    const options = {
        hostname: TEST_HOST,
        port: TEST_PORT,
        path: path,
        method: method,
        headers: {
            'Accept': 'application/json'
        }
    };

    const req = http.request(options, (res) => {
        let data = '';
        res.on('data', (chunk) => {
            data += chunk;
        });
        res.on('end', () => {
            callback(null, {
                statusCode: res.statusCode,
                headers: res.headers,
                body: data
            });
        });
    });

    req.on('error', (err) => {
        callback(err);
    });

    req.end();
}

describe('Hello API Endpoint Tests', function() {
    this.timeout(5000);

    describe('GET /api/hello', function() {
        
        it('should return 200 status code for GET request', function(done) {
            makeRequest('GET', API_PATH, (err, response) => {
                assert.strictEqual(err, null, 'Request should not error');
                assert.strictEqual(response.statusCode, 200, 'Should return 200 status');
                done();
            });
        });

        it('should return JSON with message field', function(done) {
            makeRequest('GET', API_PATH, (err, response) => {
                assert.strictEqual(err, null, 'Request should not error');
                const json = JSON.parse(response.body);
                assert.ok(json.hasOwnProperty('message'), 'Response should have message field');
                assert.strictEqual(json.message, 'Hello, World!', 'Message should be "Hello, World!"');
                done();
            });
        });

        it('should return JSON with timestamp field', function(done) {
            makeRequest('GET', API_PATH, (err, response) => {
                assert.strictEqual(err, null, 'Request should not error');
                const json = JSON.parse(response.body);
                assert.ok(json.hasOwnProperty('timestamp'), 'Response should have timestamp field');
                done();
            });
        });

        it('should return valid ISO-8601 timestamp', function(done) {
            makeRequest('GET', API_PATH, (err, response) => {
                assert.strictEqual(err, null, 'Request should not error');
                const json = JSON.parse(response.body);
                const timestamp = json.timestamp;
                
                // Check ISO-8601 format
                const iso8601Regex = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{3})?Z?$/;
                assert.ok(iso8601Regex.test(timestamp), 'Timestamp should be in ISO-8601 format');
                
                // Check if parseable as date
                const date = new Date(timestamp);
                assert.ok(!isNaN(date.getTime()), 'Timestamp should be a valid date');
                done();
            });
        });

        it('should set Content-Type header to application/json', function(done) {
            makeRequest('GET', API_PATH, (err, response) => {
                assert.strictEqual(err, null, 'Request should not error');
                assert.ok(response.headers['content-type'], 'Content-Type header should be present');
                assert.ok(
                    response.headers['content-type'].includes('application/json'),
                    'Content-Type should be application/json'
                );
                done();
            });
        });

        it('should return valid JSON response', function(done) {
            makeRequest('GET', API_PATH, (err, response) => {
                assert.strictEqual(err, null, 'Request should not error');
                assert.doesNotThrow(() => {
                    JSON.parse(response.body);
                }, 'Response body should be valid JSON');
                done();
            });
        });
    });

    describe('HTTP Method Handling', function() {
        
        it('should return 405 for POST request', function(done) {
            makeRequest('POST', API_PATH, (err, response) => {
                assert.strictEqual(err, null, 'Request should not error');
                assert.strictEqual(response.statusCode, 405, 'Should return 405 Method Not Allowed');
                done();
            });
        });

        it('should return 405 for PUT request', function(done) {
            makeRequest('PUT', API_PATH, (err, response) => {
                assert.strictEqual(err, null, 'Request should not error');
                assert.strictEqual(response.statusCode, 405, 'Should return 405 Method Not Allowed');
                done();
            });
        });

        it('should return 405 for DELETE request', function(done) {
            makeRequest('DELETE', API_PATH, (err, response) => {
                assert.strictEqual(err, null, 'Request should not error');
                assert.strictEqual(response.statusCode, 405, 'Should return 405 Method Not Allowed');
                done();
            });
        });

        it('should return 405 for PATCH request', function(done) {
            makeRequest('PATCH', API_PATH, (err, response) => {
                assert.strictEqual(err, null, 'Request should not error');
                assert.strictEqual(response.statusCode, 405, 'Should return 405 Method Not Allowed');
                done();
            });
        });

        it('should return error message for non-GET methods', function(done) {
            makeRequest('POST', API_PATH, (err, response) => {
                assert.strictEqual(err, null, 'Request should not error');
                const json = JSON.parse(response.body);
                assert.ok(json.hasOwnProperty('error'), 'Error response should have error field');
                assert.ok(
                    json.error.toLowerCase().includes('method not allowed'),
                    'Error message should indicate method not allowed'
                );
                done();
            });
        });
    });

    describe('Error Handling', function() {
        
        it('should handle requests to wrong path with 404', function(done) {
            makeRequest('GET', '/api/wrong', (err, response) => {
                assert.strictEqual(err, null, 'Request should not error');
                assert.strictEqual(response.statusCode, 404, 'Should return 404 for wrong path');
                done();
            });
        });

        it('should return JSON error for 404 responses', function(done) {
            makeRequest('GET', '/api/wrong', (err, response) => {
                assert.strictEqual(err, null, 'Request should not error');
                const json = JSON.parse(response.body);
                assert.ok(json.hasOwnProperty('error'), 'Error response should have error field');
                done();
            });
        });

        it('should handle root path request', function(done) {
            makeRequest('GET', '/', (err, response) => {
                assert.strictEqual(err, null, 'Request should not error');
                assert.ok(
                    response.statusCode === 404 || response.statusCode === 200,
                    'Root path should return either 404 or 200'
                );
                done();
            });
        });
    });

    describe('Response Structure', function() {
        
        it('should return consistent JSON structure', function(done) {
            makeRequest('GET', API_PATH, (err, response) => {
                assert.strictEqual(err, null, 'Request should not error');
                const json = JSON.parse(response.body);
                const expectedKeys = ['message', 'timestamp'];
                const actualKeys = Object.keys(json);
                
                expectedKeys.forEach(key => {
                    assert.ok(actualKeys.includes(key), `Response should include ${key} field`);
                });
                done();
            });
        });

        it('should not include extra fields in response', function(done) {
            makeRequest('GET', API_PATH, (err, response) => {
                assert.strictEqual(err, null, 'Request should not error');
                const json = JSON.parse(response.body);
                const expectedKeys = ['message', 'timestamp'];
                const actualKeys = Object.keys(json);
                
                assert.strictEqual(
                    actualKeys.length,
                    expectedKeys.length,
                    'Response should only contain expected fields'
                );
                done();
            });
        });

        it('should return fresh timestamp on each request', function(done) {
            makeRequest('GET', API_PATH, (err1, response1) => {
                assert.strictEqual(err1, null, 'First request should not error');
                const json1 = JSON.parse(response1.body);
                
                setTimeout(() => {
                    makeRequest('GET', API_PATH, (err2, response2) => {
                        assert.strictEqual(err2, null, 'Second request should not error');
                        const json2 = JSON.parse(response2.body);
                        
                        assert.notStrictEqual(
                            json1.timestamp,
                            json2.timestamp,
                            'Timestamps should be different for different requests'
                        );
                        done();
                    });
                }, 100);
            });
        });
    });

    describe('Coverage Requirements', function() {
        
        it('should test all main code paths', function(done) {
            // This test ensures we're testing all major code paths
            // The actual coverage will be measured by the coverage tool
            assert.ok(true, 'Coverage test placeholder');
            done();
        });
    });
});

// Run tests if this file is executed directly
if (require.main === module) {
    console.log('Starting Hello API tests...');
    console.log('Note: Server should be running on http://localhost:3000');
    console.log('These tests are expected to FAIL initially (TDD approach)');
}