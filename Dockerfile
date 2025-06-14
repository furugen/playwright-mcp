# Playwright公式イメージを使用（Node 18 + ブラウザ依存関係込み）
FROM mcr.microsoft.com/playwright:v1.50.1-jammy

# curlをインストール（rootユーザーで実行）
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# 非rootユーザーを作成
RUN groupadd -r playwright && useradd -r -g playwright -G audio,video playwright \
    && mkdir -p /home/playwright/Downloads \
    && chown -R playwright:playwright /home/playwright

# 作業ディレクトリ設定
WORKDIR /app
RUN chown -R playwright:playwright /app

# Playwright MCPサーバーをインストール
RUN npm install -g @playwright/mcp@latest

# Playwrightブラウザを強制再インストール（MCPパッケージとの互換性確保）
RUN npx playwright install --force firefox  
RUN npx playwright install --force webkit

# システム依存関係も強制更新
RUN npx playwright install-deps

# 出力ディレクトリを作成
RUN mkdir -p /app/output && chown -R playwright:playwright /app/output

# テストファイルをコピー
COPY test-mcp.js /app/test-mcp.js
RUN chmod +x /app/test-mcp.js && chown playwright:playwright /app/test-mcp.js

# 非rootユーザーに切り替え
USER playwright

# ポート設定（固定ポートを使用）
EXPOSE 8080

# 環境変数でブラウザ設定（サンドボックス無効）
ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright
ENV PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
ENV PLAYWRIGHT_CHROMIUM_ARGS="--no-sandbox --disable-setuid-sandbox --disable-dev-shm-usage"
ENV NODE_ENV=production
ENV MCP_PORT=8080

# デバッグ用のentrypointスクリプト
RUN echo '#!/bin/bash\n\
set -e\n\
\n\
echo "=== DEBUG MODE ==="\n\
echo "Running diagnostic tests..."\n\
node /app/test-mcp.js\n\
\n\
echo "\n=== STARTING MCP SERVER ==="\n\
# RailwayのPORT環境変数を優先的に使用\n\
ACTUAL_PORT=${PORT:-${MCP_PORT:-8080}}\n\
echo "Port: $ACTUAL_PORT"\n\
echo "Host: 0.0.0.0"\n\
echo "Railway PORT env: ${PORT:-not_set}"\n\
echo "MCP_PORT env: ${MCP_PORT:-not_set}"\n\
echo "Using port: $ACTUAL_PORT"\n\
\n\
# Check available commands and environment\n\
echo "=== DIAGNOSTIC INFO ==="\n\
echo "Node version: $(node --version)"\n\
echo "NPM version: $(npm --version)"\n\
echo "Available MCP commands:"\n\
which mcp-server-playwright && echo "mcp-server-playwright found" || echo "mcp-server-playwright not found"\n\
ls -la /usr/local/bin/mcp* 2>/dev/null || echo "No mcp commands in /usr/local/bin"\n\
ls -la /home/playwright/.npm/_npx/ 2>/dev/null || echo "No npx cache"\n\
npm list -g | grep playwright || echo "No playwright packages found globally"\n\
\n\
# Create a fallback solution with signal handling\n\
echo "Starting MCP server with signal handling..."\n\
\n\
# Trap SIGTERM and SIGINT for graceful shutdown\n\
trap '\''echo "Received shutdown signal, exiting gracefully..."; exit 0'\'' SIGTERM SIGINT\n\
\n\
# Try multiple approaches to start the server\n\
if command -v mcp-server-playwright > /dev/null 2>&1; then\n\
    echo "Using mcp-server-playwright command"\n\
    echo "Starting with WebSocket support and increased timeout..."\n\
    \n\
    # Start server in background for health monitoring\n\
    mcp-server-playwright --headless --port=$ACTUAL_PORT --host=0.0.0.0 --output-dir=/app/output --browser=firefox --isolated &\n\
    SERVER_PID=$!\n\
    \n\
    # Wait a moment for server to start\n\
    sleep 3\n\
    \n\
    # Check if server is responding\n\
    echo "Checking server endpoints..."\n\
    curl -s -m 5 http://0.0.0.0:$ACTUAL_PORT/health && echo " - Health endpoint OK" || echo " - Health endpoint failed"\n\
    curl -s -m 5 http://0.0.0.0:$ACTUAL_PORT/sse && echo " - SSE endpoint OK" || echo " - SSE endpoint failed"\n\
    curl -s -m 5 http://0.0.0.0:$ACTUAL_PORT/mcp && echo " - MCP endpoint OK" || echo " - MCP endpoint failed"\n\
    \n\
    # Wait for the server process\n\
    wait $SERVER_PID\n\
elif command -v npx > /dev/null 2>&1; then\n\
    echo "Using npx approach"\n\
    echo "Starting with WebSocket support..."\n\
    \n\
    # Start server in background for health monitoring\n\
    npx mcp-server-playwright --headless --port=$ACTUAL_PORT --host=0.0.0.0 --output-dir=/app/output --browser=firefox --isolated &\n\
    SERVER_PID=$!\n\
    \n\
    # Wait a moment for server to start\n\
    sleep 3\n\
    \n\
    # Check if server is responding\n\
    echo "Checking server endpoints..."\n\
    curl -s -m 5 http://0.0.0.0:$ACTUAL_PORT/health && echo " - Health endpoint OK" || echo " - Health endpoint failed"\n\
    curl -s -m 5 http://0.0.0.0:$ACTUAL_PORT/sse && echo " - SSE endpoint OK" || echo " - SSE endpoint failed"\n\
    curl -s -m 5 http://0.0.0.0:$ACTUAL_PORT/mcp && echo " - MCP endpoint OK" || echo " - MCP endpoint failed"\n\
    \n\
    # Wait for the server process\n\
    wait $SERVER_PID\n\
else\n\
    echo "No suitable MCP command found"\n\
    exit 1\n\
fi\n\
' > /app/debug-entrypoint.sh && chmod +x /app/debug-entrypoint.sh

# デバッグモード用のコマンド
CMD ["/app/debug-entrypoint.sh"] 