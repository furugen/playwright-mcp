#!/bin/bash

# Playwright MCP Server Entrypoint Script
set -e

echo "Starting Playwright MCP Server..."
echo "Configuration:"
echo "  Port: ${MCP_PORT:-8931}"
echo "  Host: ${MCP_HOST:-0.0.0.0}"
echo "  Output Dir: ${MCP_OUTPUT_DIR:-/app/output}"
echo "  Debug: ${DEBUG:-disabled}"

# Create output directory if it doesn't exist
mkdir -p "${MCP_OUTPUT_DIR:-/app/output}"

# Set default values
MCP_PORT=${MCP_PORT:-8931}
MCP_HOST=${MCP_HOST:-0.0.0.0}
MCP_OUTPUT_DIR=${MCP_OUTPUT_DIR:-/app/output}

# Build command arguments
CMD_ARGS=(
    "--headless"
    "--port=$MCP_PORT"
    "--host=$MCP_HOST"
    "--output-dir=$MCP_OUTPUT_DIR"
)

# Add trace saving if enabled
if [ "${SAVE_TRACE:-false}" = "true" ]; then
    CMD_ARGS+=("--save-trace")
    echo "  Trace saving: enabled"
fi

# Add vision mode if enabled
if [ "${VISION_MODE:-false}" = "true" ]; then
    CMD_ARGS+=("--vision")
    echo "  Vision mode: enabled"
fi

# Add custom arguments if provided
if [ -n "$ADDITIONAL_ARGS" ]; then
    echo "  Additional args: $ADDITIONAL_ARGS"
    # Split additional arguments and add them to the array
    IFS=' ' read -ra ADDR <<< "$ADDITIONAL_ARGS"
    for arg in "${ADDR[@]}"; do
        CMD_ARGS+=("$arg")
    done
fi

echo "Starting MCP server with: npx @playwright/mcp ${CMD_ARGS[*]}"

# Start the MCP server
exec npx @playwright/mcp "${CMD_ARGS[@]}"