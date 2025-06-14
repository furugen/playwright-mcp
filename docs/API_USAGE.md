# Playwright MCP API 使用方法

## 概要
Playwright MCPサーバーは、Server-Sent Events (SSE)を使用してブラウザ自動化機能を提供します。このドキュメントでは、API の使用方法と外部ツールとの連携について説明します。

## 接続情報
- **エンドポイント**: `http://localhost:8931/sse`
- **プロトコル**: Server-Sent Events (SSE)
- **ポート**: 8931 (デフォルト)

## 基本的な使用方法

### 1. SSE接続の確立
```javascript
const eventSource = new EventSource('http://localhost:8931/sse');

eventSource.onmessage = function(event) {
    const data = JSON.parse(event.data);
    console.log('Received:', data);
};

eventSource.onerror = function(event) {
    console.error('SSE error:', event);
};
```

### 2. ブラウザ操作コマンド

#### ページナビゲーション
```json
{
    "command": "navigate",
    "params": {
        "url": "https://example.com"
    }
}
```

#### 要素のクリック
```json
{
    "command": "click",
    "params": {
        "selector": "button[data-test='submit']"
    }
}
```

#### テキスト入力
```json
{
    "command": "fill",
    "params": {
        "selector": "input[name='username']",
        "value": "testuser"
    }
}
```

#### スクリーンショット取得
```json
{
    "command": "screenshot",
    "params": {
        "path": "/app/output/screenshot.png"
    }
}
```

## n8n との連携

### 1. n8n-nodes-mcp のインストール
```bash
npm install n8n-nodes-mcp
```

### 2. n8n ワークフロー設定例
```json
{
    "nodes": [
        {
            "name": "MCP Tool Executor",
            "type": "n8n-nodes-mcp.mcpToolExecutor",
            "parameters": {
                "mcpServerUrl": "http://localhost:8931/sse",
                "tool": "playwright",
                "action": "navigate",
                "params": {
                    "url": "https://example.com"
                }
            }
        }
    ]
}
```

### 3. 基本的なワークフロー例

#### Webスクレイピング
1. **Navigate** - 対象サイトへアクセス
2. **Wait for Selector** - 要素の読み込み待機
3. **Extract Text** - テキストデータの抽出
4. **Screenshot** - 結果の記録

#### フォーム入力自動化
1. **Navigate** - フォームページへアクセス
2. **Fill** - 各フィールドへの入力
3. **Click** - 送信ボタンのクリック
4. **Wait for Navigation** - 結果ページの読み込み待機

## VS Code / Cursor との連携

### MCP設定 (settings.json)
```json
{
    "mcpServers": {
        "playwright": {
            "url": "http://localhost:8931/sse",
            "name": "Playwright MCP Server"
        }
    }
}
```

## 利用可能なコマンド一覧

| コマンド | 説明 | パラメータ例 |
|----------|------|--------------|
| `navigate` | ページ遷移 | `{"url": "https://example.com"}` |
| `click` | 要素クリック | `{"selector": "button"}` |
| `fill` | テキスト入力 | `{"selector": "input", "value": "text"}` |
| `screenshot` | スクリーンショット | `{"path": "/app/output/image.png"}` |
| `pdf` | PDF生成 | `{"path": "/app/output/page.pdf"}` |
| `wait_for_selector` | 要素待機 | `{"selector": ".loading", "timeout": 5000}` |
| `get_text` | テキスト取得 | `{"selector": "h1"}` |
| `get_attribute` | 属性取得 | `{"selector": "a", "attribute": "href"}` |
| `evaluate` | JavaScript実行 | `{"expression": "document.title"}` |

## エラーハンドリング

### 一般的なエラーと対処法

#### 1. タイムアウトエラー
```json
{
    "error": "Timeout",
    "message": "Selector not found within timeout",
    "selector": "button[data-test='submit']",
    "timeout": 30000
}
```
**対処法**: タイムアウト値を調整するか、セレクタを確認

#### 2. 要素が見つからない
```json
{
    "error": "ElementNotFound",
    "message": "No element found for selector",
    "selector": ".non-existent-class"
}
```
**対処法**: セレクタの正確性を確認

#### 3. ネットワークエラー
```json
{
    "error": "NetworkError",
    "message": "Failed to navigate to URL",
    "url": "https://invalid-url.com"
}
```
**対処法**: URLの正確性とネットワーク接続を確認

## 高度な使用例

### 1. 複数ページの処理
```javascript
const commands = [
    { command: 'navigate', params: { url: 'https://example.com' } },
    { command: 'click', params: { selector: 'a[href="/page1"]' } },
    { command: 'wait_for_selector', params: { selector: '.content' } },
    { command: 'screenshot', params: { path: '/app/output/page1.png' } },
    { command: 'navigate', params: { url: 'https://example.com/page2' } },
    { command: 'screenshot', params: { path: '/app/output/page2.png' } }
];
```

### 2. 条件分岐処理
```javascript
// 要素の存在チェック
const elementExists = await sendCommand({
    command: 'evaluate',
    params: {
        expression: 'document.querySelector(".target-element") !== null'
    }
});

if (elementExists.result) {
    // 要素が存在する場合の処理
    await sendCommand({
        command: 'click',
        params: { selector: '.target-element' }
    });
}
```

## パフォーマンス最適化

### 1. 適切な待機時間の設定
- `wait_for_selector` を使用して要素の読み込みを待機
- 固定時間の `sleep` は避ける

### 2. 効率的なセレクタの使用
- ID セレクタを優先的に使用
- 複雑な CSS セレクタは避ける

### 3. リソースのクリーンアップ
- 不要なページは適切に閉じる
- 定期的な出力ファイルのクリーンアップ

## セキュリティ考慮事項
- 信頼できないサイトへのアクセス時は注意
- 個人情報を含むフォーム入力時は適切な処理を実装
- 出力ファイルのアクセス権限を適切に設定