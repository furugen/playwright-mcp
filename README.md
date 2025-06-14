# Playwright MCP Docker Environment

Docker環境でPlaywright MCPサーバーを実行し、外部ツールから自動ブラウザ操作を可能にするプロジェクトです。

## 🚀 クイックスタート

```bash
# 1. リポジトリをクローン
git clone <repository-url>
cd playwright-replan

# 2. Docker Composeで起動
docker-compose up -d

# 3. 動作確認
curl http://localhost:8931/health
```

SSEエンドポイント: `http://localhost:8931/sse`

## 📋 機能

- **ヘッドレスブラウザ操作**: Chromium/Firefox/WebKitでの自動操作
- **SSE通信**: リアルタイムなブラウザ操作結果の取得
- **外部ツール連携**: n8n、VS Code、Cursorなどとの統合
- **出力ファイル管理**: スクリーンショット、PDF、Traceファイルの保存
- **設定可能**: 環境変数による柔軟な設定変更

## 🛠️ 構成

```
playwright-replan/
├── Dockerfile                 # MCPサーバー用コンテナ
├── docker-compose.yml        # サービス定義
├── .env                      # 環境設定
├── scripts/
│   ├── entrypoint.sh         # 起動スクリプト
│   └── health-check.sh       # ヘルスチェック
├── config/
│   └── mcp-server.json       # MCP設定
├── output/                   # 出力ファイル
└── docs/
    ├── SETUP.md             # 詳細セットアップ
    └── API_USAGE.md         # API使用方法
```

## ⚙️ 設定

### 環境変数

| 変数 | デフォルト | 説明 |
|------|-----------|------|
| `MCP_HOST_PORT` | 8931 | 公開ポート |
| `DEBUG` | - | デバッグログ有効化 |
| `SAVE_TRACE` | false | Trace保存 |
| `VISION_MODE` | false | スクリーンショットモード |

### デバッグ有効化
```bash
echo "DEBUG=pw:api" >> .env
docker-compose restart
```

## 🔗 外部ツール連携

### n8n
```json
{
  "mcpServers": {
    "playwright": {
      "url": "http://localhost:8931/sse"
    }
  }
}
```

### VS Code/Cursor
```json
{
  "mcpServers": {
    "playwright": {
      "url": "http://localhost:8931/sse"
    }
  }
}
```

## 📊 監視

```bash
# ログ確認
docker-compose logs -f

# ヘルスチェック
curl http://localhost:8931/health

# コンテナ状態
docker-compose ps
```

## 📚 ドキュメント

- [詳細セットアップガイド](docs/SETUP.md)
- [API使用方法](docs/API_USAGE.md)
- [開発者向けガイド](CLAUDE.md)

## 🔧 トラブルシューティング

### よくある問題

1. **ポート競合**: `.env`で`MCP_HOST_PORT`を変更
2. **起動失敗**: `docker-compose logs`でエラー確認
3. **接続できない**: ファイアウォール設定を確認

### サポート

問題が発生した場合は、以下を確認してください：
- [トラブルシューティングガイド](docs/SETUP.md#トラブルシューティング)
- コンテナログ: `docker-compose logs playwright-mcp`
- ヘルスチェック: `curl http://localhost:8931/health`

## 📝 ライセンス

このプロジェクトは実験的なものです。商用利用の際は適切なライセンス確認を行ってください。

## 🤝 貢献

プルリクエストやイシューの報告を歓迎します。