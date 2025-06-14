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
RUN npx playwright install --force chromium
RUN npx playwright install --force firefox  
RUN npx playwright install --force webkit

# システム依存関係も強制更新
RUN npx playwright install-deps

# 出力ディレクトリを作成
RUN mkdir -p /app/output && chown -R playwright:playwright /app/output

# 非rootユーザーに切り替え
USER playwright

# ポート設定（SSE用既定ポートを開放）
EXPOSE 8931

# ヘルスチェック設定
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8931/health || exit 1

# 環境変数でブラウザ設定（サンドボックス無効）
ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright
ENV PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
ENV PLAYWRIGHT_CHROMIUM_ARGS="--no-sandbox --disable-setuid-sandbox --disable-dev-shm-usage"

# コンテナ起動時にMCPサーバーをヘッドレスモードで起動（Firefoxを使用、分離モード）
# Firefoxはサンドボックス問題が少ないため、Chromiumの代わりに使用
CMD ["npx", "@playwright/mcp", "--headless", "--port=8931", "--host=0.0.0.0", "--output-dir=/app/output", "--browser=firefox", "--isolated"]