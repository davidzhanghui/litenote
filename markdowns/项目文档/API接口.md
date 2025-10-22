# API 接口文档

## 文件管理接口

### 获取文件树

**GET** `/api/files`

**响应示例:**

```json
[
  {
    "name": "学习笔记1",
    "path": "学习笔记1",
    "type": "directory",
    "children": [
      {
        "name": "Vue3.md",
        "path": "学习笔记/Vue3.md",
        "type": "file"
      }
    ]
  }
]
```

### 读取文件内容

**GET** `/api/file?path=<文件路径>`

**查询参数:**
- `path`: 文件相对路径

**响应示例:**

```json
{
  "content": "# 文件内容\n\n这是文件的 Markdown 内容..."
}
```

### 保存文件内容

**POST** `/api/file`

**请求体:**

```json
{
  "path": "示例文档.md",
  "content": "# 新内容\n\n更新后的内容..."
}
```

**响应示例:**

```json
{
  "success": true
}
```

## 错误码

| 状态码 | 说明 |
|--------|------|
| 200 | 成功 |
| 400 | 请求参数错误 |
| 403 | 权限不足 |
| 404 | 文件不存在 |
| 500 | 服务器错误 |
