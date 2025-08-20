/**
 * Hello API Server Implementation
 * Implements a simple HTTP server with /api/hello endpoint
 */

const http = require('http');

const PORT = 3000;
const API_PATH = '/api/hello';

/**
 * Generate response for the hello endpoint
 */
function getHelloResponse() {
    return {
        message: 'Hello, World!',
        timestamp: new Date().toISOString()
    };
}

/**
 * Generate error response
 */
function getErrorResponse(errorMessage) {
    return {
        error: errorMessage
    };
}

/**
 * Handle HTTP requests
 */
function handleRequest(req, res) {
    const { method, url } = req;

    // Handle /api/hello endpoint
    if (url === API_PATH) {
        if (method === 'GET') {
            // Success response for GET /api/hello
            res.writeHead(200, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify(getHelloResponse()));
        } else {
            // Method not allowed for non-GET requests
            res.writeHead(405, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify(getErrorResponse('Method Not Allowed')));
        }
    } else if (url === '/') {
        // Handle root path - return 404 with JSON error
        res.writeHead(404, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(getErrorResponse('Not Found')));
    } else {
        // Handle all other paths with 404
        res.writeHead(404, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(getErrorResponse('Not Found')));
    }
}

/**
 * Create and start the server
 */
const server = http.createServer(handleRequest);

server.listen(PORT, () => {
    console.log(`Hello API Server running on http://localhost:${PORT}`);
    console.log(`API endpoint available at http://localhost:${PORT}${API_PATH}`);
});

// Handle graceful shutdown
process.on('SIGTERM', () => {
    console.log('SIGTERM received, closing server...');
    server.close(() => {
        console.log('Server closed');
        process.exit(0);
    });
});

process.on('SIGINT', () => {
    console.log('SIGINT received, closing server...');
    server.close(() => {
        console.log('Server closed');
        process.exit(0);
    });
});

module.exports = server;