# Markdown 编辑器

基于 Vue3 + Element Plus 的 Markdown 文件管理和编辑系统

## 功能特性

- 📁 树形结构显示目录和文件
- ✏️ 实时 Markdown 编辑和预览
- 💻 专业代码编辑器（Monaco Editor）支持 20+ 种编程语言
- 🎨 高亮代码着色（Java、Vue、Bash、Python、JavaScript、TypeScript、C++、Go、Rust、Ruby、PHP、Shell 等）
- 💾 智能自动保存（每 5 秒检测变更并自动保存）
- 📝 文件保存状态提示（显示"未保存"和"已自动保存"状态）
- 📱 响应式布局
- 🔄 实时刷新文件树
- 👀 三种视图模式（编辑/预览/双栏）- 仅限 Markdown 文件

## 快速开始

### 方式一：一键启动（推荐）

```bash
# 给启动脚本添加执行权限
chmod +x start.sh

# 运行启动脚本（会自动安装依赖并启动前后端服务）
./start.sh
```

### 方式二：分步启动

#### 1. 安装依赖

**前端依赖：**
```bash
npm install
```

**后端依赖：**
```bash
cd server
npm install
cd ..
```

#### 2. 启动服务

**启动后端 API 服务（端口 30001）：**

在一个终端窗口中运行：
```bash
cd server
npm start
```

服务启动后会显示：
```
服务器运行在 http://localhost:30001
Markdown 文件目录: /path/to/markdowns
```

**启动前端开发服务器（端口 3001）：**

在另一个终端窗口中运行：
```bash
npm run dev
```

服务启动后会显示：
```
➜  Local:   http://localhost:3001/
```

#### 3. 访问应用

打开浏览器访问：**http://localhost:3001**

## 端口配置

- **前端服务**: `http://localhost:3001`
- **后端 API**: `http://localhost:30001`
- **API 代理**: 前端通过 `/api` 路径代理到后端服务

## 项目结构

```
docs/
├── src/                      # 前端源码
│   ├── components/          # Vue 组件
│   │   ├── FileTree.vue     # 文件树组件
│   │   ├── MarkdownEditor.vue  # Markdown 编辑器
│   │   └── CodeEditor.vue   # 代码编辑器（支持多种脚本文件）
│   ├── api/                 # API 接口
│   │   └── files.js         # 文件操作 API
│   ├── styles/              # 样式文件
│   │   └── main.scss        # 全局样式
│   ├── App.vue              # 主应用组件
│   └── main.js              # 入口文件
├── server/                  # 后端服务
│   ├── server.js            # Express 服务器
│   └── package.json         # 后端依赖配置
├── markdowns/               # 文件存储目录（支持 Markdown 和脚本文件）
│   ├── 示例文档.md
│   ├── example.py           # Python 示例
│   ├── example.js           # JavaScript 示例
│   ├── example.sh           # Shell 示例
│   ├── 学习笔记/
│   └── 项目文档/
├── package.json             # 前端依赖配置
├── vite.config.js           # Vite 配置
├── index.html               # HTML 模板
├── start.sh                 # 一键启动脚本
└── README.md                # 项目说明
```

## 后端 API 接口

### 获取文件树
- **GET** `/api/files`
- **返回**: 树形结构的文件和目录列表

### 读取文件内容
- **GET** `/api/file?path=<文件路径>`
- **参数**: `path` - 文件相对路径
- **返回**: 文件内容

### 保存文件内容
- **POST** `/api/file`
- **请求体**: `{ "path": "文件路径", "content": "文件内容" }`
- **返回**: 保存结果

## 技术栈

### 前端
- **Vue 3** - 渐进式 JavaScript 框架
- **Element Plus** - Vue 3 组件库
- **Vite** - 下一代前端构建工具
- **Monaco Editor** - 专业代码编辑器（VS Code 核心）
- **@monaco-editor/loader** - Monaco Editor 动态加载器
- **Markdown-it** - Markdown 解析器
- **Highlight.js** - 代码语法高亮
- **Axios** - HTTP 客户端
- **Sass** - CSS 预处理器（使用现代编译器 API）

### 后端
- **Node.js** - JavaScript 运行时
- **Express** - Web 应用框架
- **CORS** - 跨域资源共享

## 使用说明

### 基本操作
1. **查看文件**: 点击左侧文件树中的文件名
2. **编辑内容**: 在右侧编辑器中修改文件内容
3. **保存文件**: 点击工具栏的"保存"按钮或等待自动保存
4. **刷新树**: 点击左上角刷新按钮重新加载文件树

### 自动保存功能
- ⏱️ **自动保存间隔**: 每 5 秒检测一次文档变更
- 📝 **状态提示**: 工具栏显示保存状态
  - 黄色标签"未保存" - 表示有未保存的变更
  - 绿色标签"已自动保存" - 表示已自动保存
- 💡 **工作流**: 编辑 → 5 秒后自动保存 → 状态更新

### Markdown 文件
- 支持三种视图模式：编辑、预览、双栏
- 使用工具栏按钮切换视图模式
- 支持实时预览和代码高亮
- 自动保存功能同样适用

### 代码文件编辑（Monaco Editor）
使用专业的 Monaco Editor（VS Code 核心编辑器）编辑代码文件，支持以下语言：

**编程语言**
- **Java** (.java)
- **Python** (.py)
- **JavaScript/JSX** (.js, .jsx)
- **TypeScript/TSX** (.ts, .tsx)
- **C/C++** (.c, .cpp, .h, .cc)
- **Go** (.go)
- **Rust** (.rs)
- **Ruby** (.rb)
- **PHP** (.php)

**脚本语言**
- **Shell/Bash** (.sh, .bash, .zsh, .fish)

**Web 技术**
- **Vue** (.vue)
- **HTML** (.html)
- **CSS/SCSS/LESS** (.css, .scss, .less)
- **XML** (.xml)

**数据格式**
- **JSON** (.json)
- **YAML** (.yaml, .yml)
- **SQL** (.sql)
- **Markdown** (.md)
- **Text** (.txt)

**编辑器特性**
- 🎨 语法高亮
- 🔢 行号显示
- 🗺️ 代码缩小地图
- 📏 自动换行
- 🔧 代码格式化
- ⌨️ 智能缩进
- 💾 自动保存

## 开发指南

### 构建生产版本

```bash
npm run build
```

构建输出位于 `dist/` 目录。

### 预览生产构建

```bash
npm run preview
```

## 常见问题

**Q: 启动时出现 Sass 弃用警告怎么办？**

A: 这是正常的，已在 `vite.config.js` 中配置使用现代 Sass 编译器 API。如果仍然看到警告，请确保 Sass 版本为最新。

**Q: Monaco Editor 加载失败？**

A: 
- 确保已运行 `npm install` 安装依赖
- 检查浏览器控制台是否有网络错误
- 尝试清除浏览器缓存并刷新页面
- 确保网络连接正常（Monaco Editor 需要从 CDN 加载资源）

**Q: 自动保存没有工作？**

A: 
- 检查后端服务是否正在运行
- 查看浏览器控制台是否有错误信息
- 确保 `markdowns/` 目录有写入权限
- 手动点击"保存"按钮进行测试

**Q: 端口被占用怎么办？**

A: 修改以下文件中的端口配置：
- 前端端口: `vite.config.js` 中的 `server.port`
- 后端端口: `server/server.js` 中的 `PORT` 常量
- 同时更新 `vite.config.js` 中的代理目标 `server.proxy['/api'].target`

**Q: 文件无法保存？**

A: 确保后端服务正在运行，检查 `markdowns/` 目录的读写权限。

**Q: 看不到文件树？**

A: 检查后端服务是否正常启动，浏览器控制台是否有错误信息。

## License

MIT
