/**
 * Expected implementation that implementer subagent should create
 * Minimal code to make all tests pass
 */

const express = require('express');
const app = express();

// Main endpoint
app.get('/hello', (req, res) => {
  const name = req.query.name;
  const timestamp = new Date().toISOString();
  
  // Check for empty name parameter
  if (name === '') {
    return res.status(400).json({
      error: 'Name parameter cannot be empty',
      timestamp
    });
  }
  
  // Generate appropriate greeting
  const message = name ? `Hello, ${name}!` : 'Hello, World!';
  
  // Return success response
  res.json({
    message,
    timestamp
  });
});

// Start server if running directly (not in test)
if (require.main === module) {
  const PORT = process.env.PORT || 3000;
  app.server = app.listen(PORT, () => {
    console.log(`Hello API server running on port ${PORT}`);
  });
}

module.exports = app;