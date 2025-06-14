# Playwright MCP Docker環境構築計画

## プロジェクト概要
Docker上でPlaywright MCPサーバーを動作させ、外部ツール（n8n等）から自動ブラウザ操作を可能にする環境を構築する。

## 技術スタック
- **Base Image**: `mcr.microsoft.com/playwright:v1.50.1-jammy`
- **MCP Server**: `@playwright/mcp@latest`
- **Communication**: Server-Sent Events (SSE)
- **Port**: 8931 (デフォルト)
- **Mode**: Headless

## 実装計画

### Phase 1: Docker環境セットアップ
- [ ] **Dockerfile作成**
  - Microsoft公式Playwrightイメージをベースに使用
  - `@playwright/mcp`パッケージをグローバルインストール
  - ポート8931を公開
  - ヘッドレスモードでの起動設定

- [ ] **docker-compose.yml作成**
  - サービス定義とポートマッピング
  - 環境変数の設定
  - ボリュームマウント設定

- [ ] **.env設定ファイル作成**
  - ポート番号、ホスト設定
  - デバッグオプション
  - 出力ディレクトリ設定

### Phase 2: MCP サーバー設定
- [ ] **起動オプション設定**
  - `--headless`: ヘッドレスモード有効化
  - `--port=8931`: SSE通信ポート指定
  - `--host=0.0.0.0`: 外部アクセス許可
  - `--output-dir=/app/output`: 出力ファイル保存先

- [ ] **ネットワーク設定**
  - SSEエンドポイント(`/sse`)の公開
  - 外部クライアントからの接続許可
  - セキュリティ設定

### Phase 3: ログ・出力管理
- [ ] **ログ設定**
  - `docker logs`でのリアルタイム確認
  - `DEBUG=pw:api`でPlaywrightデバッグログ
  - エラーハンドリングとトラブルシューティング

- [ ] **出力ファイル管理**
  - スクリーンショット、PDF保存
  - Traceファイル生成(`--save-trace`)
  - ホストマシンとのボリューム共有

### Phase 4: 運用スクリプト
- [ ] **起動スクリプト作成**
  - 環境変数による設定切り替え
  - ヘルスチェック機能
  - グレースフルシャットダウン

- [ ] **管理スクリプト作成**
  - コンテナ状態監視
  - ログローテーション
  - バックアップ・復旧

### Phase 5: ドキュメント作成
- [ ] **セットアップガイド**
  - 環境構築手順
  - 設定パラメータ説明
  - トラブルシューティングガイド

- [ ] **API使用例**
  - n8nとの連携方法
  - 基本的なブラウザ操作コマンド
  - エラーハンドリング例

## ファイル構成
```
playwright-replan/
├── Dockerfile                 # MCPサーバー用Dockerイメージ
├── docker-compose.yml        # サービス定義
├── .env                      # 環境変数設定
├── scripts/
│   ├── entrypoint.sh         # コンテナ起動スクリプト
│   └── health-check.sh       # ヘルスチェック
├── config/
│   └── mcp-server.json       # MCP設定ファイル
├── output/                   # 出力ファイル保存先
└── docs/
    ├── SETUP.md             # セットアップガイド
    └── API_USAGE.md         # API使用方法

```

## 期待される成果物
1. **Docker環境**: ワンコマンドで起動可能なPlaywright MCP環境
2. **SSE接続**: `http://localhost:8931/sse`でのクライアント接続
3. **外部連携**: n8nなどの自動化ツールから利用可能
4. **ログ管理**: 実行ログとトレース情報の適切な管理
5. **運用ドキュメント**: 構築・運用・トラブルシューティング手順

## 参考リソース
- [Microsoft Playwright MCP公式](https://github.com/microsoft/playwright)
- [Docker Compose環境例](https://github.com/iuill/playwright-mcp-docker)
- [MCP Protocol仕様](https://modelcontextprotocol.io/)
- [n8n-nodes-mcp](https://www.npmjs.com/package/n8n-nodes-mcp)

## 次のステップ
1. 基本的なDockerfile作成から開始
2. ローカル環境での動作確認
3. 外部ツールとの連携テスト
4. 運用設定の最適化
5. ドキュメント整備