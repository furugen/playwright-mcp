# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository contains a Docker-based setup for running Playwright MCP (Model Context Protocol) server, enabling external tools like n8n to perform automated browser operations through Server-Sent Events (SSE) communication.

## Architecture

### Core Components
- **Docker Environment**: Containerized Playwright MCP server based on Microsoft's official Playwright image
- **MCP Server**: `@playwright/mcp` package providing browser automation capabilities
- **Communication Layer**: SSE-based API on port 8931 with `/sse` endpoint
- **Output Management**: Configurable output directory for screenshots, PDFs, and trace files

### Key Technologies
- Base Image: `mcr.microsoft.com/playwright:v1.50.1-jammy`
- MCP Server: `@playwright/mcp@latest`
- Communication: Server-Sent Events (SSE) on port 8931
- Mode: Headless browser operation

## Development Commands

### Docker Operations
```bash
# Build the MCP server image
docker build -t playwright-mcp .

# Run with Docker Compose
docker-compose up -d

# View logs
docker logs <container-name>

# Stop services
docker-compose down
```

### MCP Server Operations
```bash
# Start MCP server in headless mode
npx @playwright/mcp --headless --port=8931 --host=0.0.0.0

# Start with output directory
npx @playwright/mcp --headless --port=8931 --host=0.0.0.0 --output-dir=/app/output

# Start with trace saving
npx @playwright/mcp --headless --port=8931 --host=0.0.0.0 --save-trace

# Enable Playwright debug logging
DEBUG=pw:api npx @playwright/mcp --headless --port=8931 --host=0.0.0.0
```

## Project Structure

The project follows a modular Docker-based architecture:

```
playwright-replan/
├── Dockerfile                 # MCP server container definition
├── docker-compose.yml        # Service orchestration
├── .env                      # Environment configuration
├── scripts/
│   ├── entrypoint.sh         # Container startup script
│   └── health-check.sh       # Health monitoring
├── config/
│   └── mcp-server.json       # MCP server configuration
├── output/                   # Generated files (screenshots, PDFs, traces)
└── docs/                     # Documentation
```

## Environment Configuration

### Required Environment Variables
- `MCP_HOST_PORT`: Port for MCP server (default: 8931)
- `MCP_OUTPUT_DIR`: Directory for output files
- `DEBUG`: Enable debug logging (set to `pw:api` for Playwright logs)

### Key Configuration Options
- `--headless`: Run browsers in headless mode (required for Docker)
- `--host=0.0.0.0`: Allow external connections
- `--port=8931`: SSE communication port
- `--output-dir`: Specify output directory for generated files
- `--save-trace`: Enable Playwright trace recording
- `--vision`: Enable screenshot-based operations

## External Integration

### SSE Endpoint
The MCP server exposes `http://localhost:8931/sse` for client connections.

### Client Configuration Example
```json
{
  "mcpServers": {
    "playwright_sse": {
      "url": "http://localhost:8931/sse"
    }
  }
}
```

### n8n Integration
Use the `n8n-nodes-mcp` community package to connect n8n workflows to the MCP server for browser automation tasks.

## Development Notes

### Headless Mode Requirements
Always run browsers in headless mode when using Docker. The server will fail to start if attempting to run in headed mode within a container.

### Port Mapping
Ensure proper port mapping in docker-compose.yml:
```yaml
ports:
  - "8931:8931"
```

### Volume Mounting
Mount output directory to persist generated files:
```yaml
volumes:
  - ./output:/app/output
```

### Debugging
- Use `docker logs` to monitor server startup and client connections
- Set `DEBUG=pw:api` environment variable for detailed Playwright API logs
- Check for "SSE server listening on port 8931" message in logs to confirm successful startup

### Browser Installation
The Dockerfile includes forced browser installation to ensure compatibility:
```dockerfile
RUN npx playwright install --force firefox
RUN npx playwright install --force webkit
RUN npx playwright install-deps
```
This prevents version mismatch issues between `@playwright/mcp` and browser binaries.