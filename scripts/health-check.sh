#!/bin/bash

# Health check script for Playwright MCP Server
set -e

PORT=${MCP_PORT:-8931}
TIMEOUT=${HEALTH_TIMEOUT:-5}

echo "Checking health of MCP server on port $PORT..."

# Check if the server is responding
if curl -f -s --max-time "$TIMEOUT" "http://localhost:$PORT/health" > /dev/null 2>&1; then
    echo "✓ MCP server is healthy"
    exit 0
else
    echo "✗ MCP server health check failed"
    
    # Additional diagnostics
    echo "Attempting to check if server is running..."
    
    # Check if port is open
    if nc -z localhost "$PORT" 2>/dev/null; then
        echo "✓ Port $PORT is open, but health endpoint not responding"
        exit 1
    else
        echo "✗ Port $PORT is not open"
        exit 1
    fi
fi