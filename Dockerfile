# Playwright公式イメージを使用（Node 18 + ブラウザ依存関係込み）
FROM mcr.microsoft.com/playwright:v1.50.1-jammy

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

# curlをインストール（ヘルスチェック用）
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# 非rootユーザーに切り替え
USER playwright

# ポート設定（SSE用既定ポートを開放）
EXPOSE 8931

# ヘルスチェック設定（タイムアウトを延長）
HEALTHCHECK --interval=60s --timeout=30s --start-period=30s --retries=5 \
    CMD curl -f http://localhost:8931/health || exit 1

# 環境変数でブラウザ設定（サンドボックス無効）
ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright
ENV PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
ENV PLAYWRIGHT_CHROMIUM_ARGS="--no-sandbox --disable-setuid-sandbox --disable-dev-shm-usage"
ENV NODE_ENV=production

# Railway用の環境変数設定
ENV PORT=8931

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
# Start the MCP server\n\
echo "Starting Playwright MCP server..."\n\
npx @playwright/mcp --headless --port=8931 --host=0.0.0.0 --output-dir=/app/output --browser=firefox --isolated &\n\
PLAYWRIGHT_PID=$!\n\
\n\
# Wait for the background process\n\
wait $PLAYWRIGHT_PID\n\
' > /app/entrypoint.sh && chmod +x /app/entrypoint.sh

# コンテナ起動時にentrypointスクリプトを実行
CMD ["/app/entrypoint.sh"]