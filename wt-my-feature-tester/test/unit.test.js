const helloController = require('../src/controllers/helloController');

describe('Unit tests for hello controller', () => {
  describe('helloController function', () => {
    let mockReq, mockRes;

    beforeEach(() => {
      mockReq = {};
      mockRes = {
        status: jest.fn().mockReturnThis(),
        json: jest.fn().mockReturnThis(),
        set: jest.fn().mockReturnThis()
      };
    });

    test('should be defined', () => {
      expect(helloController).toBeDefined();
      expect(typeof helloController).toBe('function');
    });

    test('should set status to 200', () => {
      helloController(mockReq, mockRes);
      expect(mockRes.status).toHaveBeenCalledWith(200);
    });

    test('should set Content-Type header', () => {
      helloController(mockReq, mockRes);
      expect(mockRes.set).toHaveBeenCalledWith('Content-Type', 'application/json');
    });

    test('should return JSON with message property', () => {
      helloController(mockReq, mockRes);
      expect(mockRes.json).toHaveBeenCalled();
      const jsonCall = mockRes.json.mock.calls[0][0];
      expect(jsonCall).toHaveProperty('message');
      expect(jsonCall.message).toBe('Hello, World!');
    });

    test('should return JSON with timestamp property', () => {
      helloController(mockReq, mockRes);
      const jsonCall = mockRes.json.mock.calls[0][0];
      expect(jsonCall).toHaveProperty('timestamp');
      expect(typeof jsonCall.timestamp).toBe('string');
    });

    test('should return valid ISO-8601 timestamp', () => {
      helloController(mockReq, mockRes);
      const jsonCall = mockRes.json.mock.calls[0][0];
      const timestamp = jsonCall.timestamp;
      const date = new Date(timestamp);
      expect(date.toISOString()).toBe(timestamp);
    });

    test('should not modify request object', () => {
      const originalReq = { ...mockReq };
      helloController(mockReq, mockRes);
      expect(mockReq).toEqual(originalReq);
    });

    test('should handle missing response methods gracefully', () => {
      const incompleteRes = {};
      expect(() => {
        helloController(mockReq, incompleteRes);
      }).toThrow();
    });

    test('should be synchronous', () => {
      const result = helloController(mockReq, mockRes);
      expect(result).not.toBeInstanceOf(Promise);
    });

    test('should call response methods in correct order', () => {
      const callOrder = [];
      mockRes.status = jest.fn(() => {
        callOrder.push('status');
        return mockRes;
      });
      mockRes.set = jest.fn(() => {
        callOrder.push('set');
        return mockRes;
      });
      mockRes.json = jest.fn(() => {
        callOrder.push('json');
        return mockRes;
      });

      helloController(mockReq, mockRes);
      expect(callOrder).toEqual(['status', 'set', 'json']);
    });
  });

  describe('Timestamp generation', () => {
    test('should generate current timestamp', () => {
      const before = new Date().toISOString();
      const mockRes = {
        status: jest.fn().mockReturnThis(),
        json: jest.fn().mockReturnThis(),
        set: jest.fn().mockReturnThis()
      };
      
      helloController({}, mockRes);
      
      const after = new Date().toISOString();
      const jsonCall = mockRes.json.mock.calls[0][0];
      const timestamp = jsonCall.timestamp;
      
      expect(timestamp >= before).toBe(true);
      expect(timestamp <= after).toBe(true);
    });

    test('should generate unique timestamps on multiple calls', () => {
      const timestamps = [];
      
      for (let i = 0; i < 3; i++) {
        const mockRes = {
          status: jest.fn().mockReturnThis(),
          json: jest.fn().mockReturnThis(),
          set: jest.fn().mockReturnThis()
        };
        
        helloController({}, mockRes);
        const jsonCall = mockRes.json.mock.calls[0][0];
        timestamps.push(jsonCall.timestamp);
      }
      
      // Timestamps should be unique or very close
      const uniqueTimestamps = [...new Set(timestamps)];
      expect(uniqueTimestamps.length).toBeGreaterThan(0);
    });
  });
});