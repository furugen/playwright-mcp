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
# ARM64環境ではChromeがサポートされていないため、ChromiumとFirefoxを使用
# RUN npx playwright install --force chromium
RUN npx playwright install --force firefox  
RUN npx playwright install --force webkit

# システム依存関係も強制更新
RUN npx playwright install-deps

# 出力ディレクトリを作成
RUN mkdir -p /app/output && chown -R playwright:playwright /app/output

# 非rootユーザーに切り替え
USER playwright

# ポート設定（固定ポートを使用）
EXPOSE 8931

# ヘルスチェック設定を一時的に無効化（デバッグ用）
# HEALTHCHECK --interval=60s --timeout=30s --start-period=30s --retries=5 \
#     CMD curl -f http://localhost:8931/health || exit 1

# 環境変数でブラウザ設定（サンドボックス無効）
ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright
ENV PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
ENV PLAYWRIGHT_CHROMIUM_ARGS="--no-sandbox --disable-setuid-sandbox --disable-dev-shm-usage"
ENV NODE_ENV=production

# MCP用のポート設定（RailwayのPORTと分けて管理）
ENV MCP_PORT=8931

# シグナルハンドリングを改善するためのinit processを使用
# SIGTERMを適切に処理するためのentrypointスクリプトを作成
RUN echo '#!/bin/bash\n\
set -e\n\
\n\
# Graceful shutdown handler\n\
shutdown() {\n\
    echo "Received SIGTERM signal, shutting down gracefully..."\n\
    if [ -n "$PLAYWRIGHT_PID" ]; then\n\
        kill -TERM "$PLAYWRIGHT_PID" 2>/dev/null || true\n\
        wait "$PLAYWRIGHT_PID" 2>/dev/null || true\n\
    fi\n\
    exit 0\n\
}\n\
\n\
# Register signal handlers\n\
trap shutdown SIGTERM SIGINT\n\
\n\
# Port settings - use MCP_PORT if available, otherwise default to 8931\n\
ACTUAL_PORT=${MCP_PORT:-8931}\n\
\n\
# Start the MCP server\n\
echo "Starting Playwright MCP server..."\n\
echo "Port: $ACTUAL_PORT"\n\
echo "Host: 0.0.0.0"\n\
echo "Railway PORT env: ${PORT:-not_set}"\n\
echo "MCP_PORT env: ${MCP_PORT:-not_set}"\n\
\n\
# Use the correct command based on what npm installs\n\
npx @playwright/mcp --headless --port=$ACTUAL_PORT --host=0.0.0.0 --output-dir=/app/output --browser=firefox --isolated &\n\
PLAYWRIGHT_PID=$!\n\
\n\
echo "Playwright MCP server started with PID: $PLAYWRIGHT_PID"\n\
echo "Waiting for process to complete..."\n\
\n\
# Wait for the background process\n\
wait $PLAYWRIGHT_PID\n\
EXIT_CODE=$?\n\
echo "Process exited with code: $EXIT_CODE"\n\
exit $EXIT_CODE\n\
' > /app/entrypoint.sh && chmod +x /app/entrypoint.sh

# コンテナ起動時にentrypointスクリプトを実行
CMD ["/app/entrypoint.sh"]