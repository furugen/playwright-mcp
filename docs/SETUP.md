# Playwright MCP Docker セットアップガイド

## 概要
このガイドでは、Docker上でPlaywright MCPサーバーを構築し、外部ツールから自動ブラウザ操作を行うための環境構築手順を説明します。

## 前提条件
- Docker Engine がインストールされていること
- Docker Compose がインストールされていること
- 8931番ポートが利用可能であること

## クイックスタート

### 1. リポジトリのクローン
```bash
git clone <repository-url>
cd playwright-replan
```

### 2. 環境設定
```bash
# .envファイルを必要に応じて編集
cp .env .env.local
```

### 3. Docker Composeでの起動
```bash
# サービスの起動
docker-compose up -d

# ログの確認
docker-compose logs -f playwright-mcp
```

### 4. 動作確認
```bash
# ヘルスチェック
curl http://localhost:8931/health

# SSEエンドポイントの確認
curl http://localhost:8931/sse
```

## 詳細設定

### 環境変数
`.env`ファイルで以下の設定を調整できます：

| 変数名 | デフォルト値 | 説明 |
|--------|-------------|------|
| `MCP_HOST_PORT` | 8931 | ホスト側で公開するポート番号 |
| `MCP_HOST` | 0.0.0.0 | バインドするホストアドレス |
| `MCP_OUTPUT_DIR` | /app/output | 出力ファイルの保存先 |
| `DEBUG` | (空) | デバッグログの有効化 (例: `pw:api`) |

### 出力ファイル
以下のファイルが`output/`ディレクトリに保存されます：
- スクリーンショット (.png)
- PDF (.pdf)
- Traceファイル (.zip)
- 実行ログ (.json)

### デバッグモードの有効化
```bash
# .envファイルでデバッグを有効化
echo "DEBUG=pw:api" >> .env

# コンテナを再起動
docker-compose restart
```

## トラブルシューティング

### サーバーが起動しない場合
```bash
# コンテナのログを確認
docker-compose logs playwright-mcp

# コンテナの状態を確認
docker-compose ps
```

### ポートが使用中の場合
```bash
# ポート使用状況の確認
lsof -i :8931

# 別のポートを使用
echo "MCP_HOST_PORT=8932" >> .env
docker-compose up -d
```

### ヘルスチェックが失敗する場合
```bash
# 手動でヘルスチェックを実行
docker-compose exec playwright-mcp /app/scripts/health-check.sh

# コンテナ内でのネットワーク確認
docker-compose exec playwright-mcp curl -v http://localhost:8931/health
```

## メンテナンス

### ログのクリーンアップ
```bash
# Dockerログのクリーンアップ
docker-compose logs --tail=0 -f > /dev/null &

# 出力ファイルのクリーンアップ
rm -rf output/*
```

### アップデート
```bash
# イメージの更新
docker-compose pull
docker-compose up -d --force-recreate
```

## セキュリティ考慮事項
- 本番環境では適切なネットワーク制限を設定してください
- 出力ディレクトリへのアクセス権限を適切に設定してください
- 必要に応じてSSL/TLS終端を設定してください