# Markdown 编辑器

基于 Vue3 + Element Plus 的 Markdown 文件管理和编辑系统

## 功能特性

- 📁 树形结构显示目录和文件
- ✏️ 实时 Markdown 编辑和预览
- 💾 文件保存功能
- 🎨 代码高亮
- 📱 响应式布局

## 安装和运行

### 前端

```bash
# 安装依赖
npm install

# 启动开发服务器
npm run dev

# 构建生产版本
npm run build
```

### 后端API服务

后端需要提供以下API接口：

- `GET /api/files` - 获取文件树结构
- `GET /api/file/:path` - 读取文件内容
- `POST /api/file/:path` - 保存文件内容

可以使用 Node.js/Express 实现后端服务，参考 `server` 目录。

## 项目结构

```
├── src/
│   ├── components/     # Vue组件
│   ├── api/           # API接口
│   ├── styles/        # 样式文件
│   ├── App.vue        # 主应用组件
│   └── main.js        # 入口文件
├── markdowns/         # Markdown文件存储目录
└── server/            # 后端服务（可选）
```

## 技术栈

- Vue 3
- Element Plus
- Vite
- Markdown-it
- Highlight.js
