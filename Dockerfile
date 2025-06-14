# Simple Dockerfile for running Playwright MCP server
FROM node:18-alpine

# Install dependencies needed for Playwright
RUN apk add --no-cache \
    chromium \
    nss \
    freetype \
    freetype-dev \
    harfbuzz \
    ca-certificates \
    ttf-freefont

# Set environment variables for Playwright
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

# Create app directory
WORKDIR /app

# Install @playwright/mcp globally
RUN npm install -g @playwright/mcp@latest

# Expose port (default 8931, but configurable)
ARG PORT=8931
EXPOSE $PORT

# Create non-root user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S playwright -u 1001

USER playwright

# Start the MCP server with configurable port
CMD ["sh", "-c", "npx @playwright/mcp --port ${PORT:-8931}"]
