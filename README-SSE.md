# Playwright MCP SSE Server

このプロジェクトは、公式のPlaywright MCPサーバーをHTTP+SSE（Server-Sent Events）トランスポートで実行する方法を説明します。

## 概要

- **公式Playwright MCP**: Microsoftの公式Playwright MCPサーバーを使用
- **SSE Transport**: HTTP+SSEを使用した双方向通信
- **Docker対応**: コンテナ化された環境での実行
- **StreamableHTTP**: より効率的なStreamableHTTPトランスポートも利用可能
- **柔軟な設定**: ポート番号やブラウザオプションのカスタマイズ

## 前提条件

- Node.js 18以上
- Docker（Docker実行時）
- npm または yarn

## ローカル実行

### 1. 依存関係のインストール

```bash
npm install
```

### 2. プロジェクトのビルド

```bash
npm run build
```

### 3. SSEサーバーの起動

```bash
# 公式CLIを使用してSSE transportで起動
node cli.js --port 3002
```

### 4. 動作確認

```bash
# SSE接続のテスト
curl http://localhost:3002/sse

# StreamableHTTP接続のテスト（推奨）
curl -X POST http://localhost:3002/mcp
```

## Docker実行

### 1. Dockerネットワークの作成

```bash
docker network create mcp-network
```

### 2. サーバーの起動

```bash
# デフォルトポート（3002）で起動
docker-compose up --build

# カスタムポートで起動
PORT=4000 docker-compose up --build
```

### 3. サーバーの停止

```bash
docker-compose down
```

## エンドポイント

| エンドポイント | メソッド | 説明 |
|---------------|---------|------|
| `/` | GET | サーバー情報を取得 |
| `/health` | GET | ヘルスチェック |
| `/sse` | GET | SSE接続の開始 |
| `/messages` | POST | MCPメッセージの送信 |

## MCP クライアントからの接続

### Roo Code での設定

MCP Settings に以下の設定を追加：

```json
{
  "mcpServers": {
    "playwright-sse-mcp-server": {
      "url": "http://localhost:3002/sse"
    }
  }
}
```

### コンテナ環境からの接続

同一Dockerネットワーク内のコンテナから接続する場合：

```json
{
  "mcpServers": {
    "playwright-sse-mcp-server": {
      "url": "http://playwright-sse-mcp-server:3002/sse"
    }
  }
}
```

### 開発コンテナからの接続

開発コンテナからホスト経由で接続する場合：

**Docker Desktop（Mac/Windows）:**
```json
{
  "mcpServers": {
    "playwright-sse-mcp-server": {
      "url": "http://host.docker.internal:3002/sse"
    }
  }
}
```

**Linux:**
```json
{
  "mcpServers": {
    "playwright-sse-mcp-server": {
      "url": "http://172.17.0.1:3002/sse"
    }
  }
}
```

## 環境変数

| 変数名 | デフォルト値 | 説明 |
|-------|-------------|------|
| `PORT` | 3002 | サーバーのポート番号 |
| `NODE_ENV` | production | Node.jsの実行環境 |

## ログ出力例

```
🚀 Playwright MCP SSE Server is running on port 3002
📡 SSE endpoint: http://localhost:3002/sse
📨 Messages endpoint: http://localhost:3002/messages
❤️  Health check: http://localhost:3002/health
```

## 利用可能なPlaywright機能

- ブラウザの起動・終了
- ページナビゲーション
- 要素の検索・操作
- スクリーンショット撮影
- PDFの生成
- JavaScriptの実行
- フォームの入力
- クリック・キーボード操作
- ファイルのアップロード/ダウンロード

## トラブルシューティング

### よくある問題

1. **ポートが使用中**
   ```bash
   PORT=4000 npm run run-sse-server
   ```

2. **ブラウザの依存関係不足**
   ```bash
   npx playwright install-deps chromium
   ```

3. **権限エラー（Docker）**
   ```bash
   docker-compose down
   docker system prune
   docker-compose up --build
   ```

### ログの確認

```bash
# Dockerログの確認
docker-compose logs -f playwright-sse-mcp-server

# コンテナ内での実行
docker exec -it playwright-sse-mcp-server sh
```

## 参考資料

- [Playwright MCP公式リポジトリ](https://github.com/microsoft/playwright-mcp)
- [Model Context Protocol仕様](https://spec.modelcontextprotocol.io/)
- [Zenn記事：Playwright MCPをHTTP/SSEで実装する](https://zenn.dev/texia/articles/b9b8a7fb24a55e)

## ライセンス

Apache License 2.0 