# macOS 浏览器 UI 测试配置指南

> 解决 chrome-devtools MCP 工具在 macOS 上的浏览器实例占用问题

---

## 🔍 问题原因

当你看到以下错误信息时：
```
The browser is already running for /Users/mi/.cache/chrome-devtools-mcp/chrome-profile. 
Use --isolated to run multiple browser instances.
```

这是因为 chrome-devtools MCP 工具已经启动了一个 Chrome 浏览器实例，并且正在使用特定的用户数据目录。MCP 工具默认不允许同时运行多个实例。

---

## ✅ 解决方案

### 方案 1: 使用便捷脚本（推荐）

我们已经创建了一个自动化脚本来处理这个问题：

```bash
# 运行测试脚本
./resetreset-mcp-chrome-devtools.sh
```

这个脚本会：
- ✅ 自动检测并关闭现有的 Chrome 进程
- ✅ 验证前端和后端服务器是否运行
- ✅ 提供清晰的状态反馈

### 方案 2: 手动关闭 Chrome 进程

如果你想手动处理，可以使用以下命令：

```bash
# 1. 查看正在运行的 Chrome 进程
ps aux | grep -i "chrome-devtools" | grep -v grep

# 2. 关闭所有相关的 Chrome 进程
pkill -f "chrome-devtools-mcp/chrome-profile"

# 3. 验证进程已关闭
ps aux | grep -i "chrome-devtools" | grep -v grep
# 应该没有输出
```

### 方案 3: 清理缓存目录

如果进程关闭后仍有问题，可以清理缓存：

```bash
# 关闭进程
pkill -f "chrome-devtools-mcp/chrome-profile"

# 清理缓存目录
rm -rf /Users/mi/.cache/chrome-devtools-mcp/chrome-profile

# 重启 MCP 工具
# 在 Windsurf IDE 中重新调用 chrome-devtools 工具
```

### 方案 4: 在 Windsurf 中重启 MCP 服务器

1. 打开 Windsurf IDE
2. 重启 MCP 服务器：
   - 命令面板 (Cmd+Shift+P)
   - 输入 "MCP: Restart Server"
   - 选择 "chrome-devtools"

---

## 🧪 测试流程

### 步骤 1: 准备环境

```bash
# 1. 启动后端服务器
cd backend
mvn spring-boot:run

# 2. 启动前端服务器（新终端）
cd frontend
npm run dev
```

### 步骤 2: 清理旧的浏览器实例

```bash
# 运行清理脚本
./reset-mcp-chrome-devtools.sh
```

### 步骤 3: 使用 MCP 工具测试

在 Windsurf IDE 中：

```
请使用 chrome-devtools MCP 工具访问 http://localhost:5173 并测试以下功能：

1. 评论功能
2. 点赞功能  
3. 搜索功能
```

---

## 🛠️ 高级配置

### 配置 MCP 服务器使用独立实例

如果你需要同时运行多个浏览器实例，可以修改 MCP 服务器配置：

**1. 找到 MCP 配置文件**
```bash
# Windsurf MCP 配置通常在：
~/.windsurf/mcp-config.json
# 或
~/.config/windsurf/mcp-config.json
```

**2. 添加 isolated 标志**
```json
{
  "mcpServers": {
    "chrome-devtools": {
      "command": "npx",
      "args": [
        "chrome-devtools-mcp@latest",
        "--isolated"
      ]
    }
  }
}
```

**3. 重启 Windsurf**

### 使用不同的用户数据目录

你也可以为每个测试会话使用不同的用户数据目录：

```bash
# 方法 1: 使用环境变量
export CHROME_USER_DATA_DIR="/tmp/chrome-test-$(date +%s)"
npx chrome-devtools-mcp

# 方法 2: 每次测试后清理
rm -rf /Users/mi/.cache/chrome-devtools-mcp/chrome-profile
```

---

## 🔄 常见工作流

### 日常测试工作流

```bash
# 1. 早上开始工作
./reset-mcp-chrome-devtools.sh

# 2. 进行开发和测试
# ... 编码 ...

# 3. 晚上结束工作，清理环境
pkill -f "chrome-devtools-mcp"
```

### 快速重置环境

```bash
# 创建别名，方便使用
echo 'alias reset-chrome="pkill -f chrome-devtools-mcp && rm -rf ~/.cache/chrome-devtools-mcp/chrome-profile"' >> ~/.zshrc
source ~/.zshrc

# 使用
reset-chrome
```

---

## 📋 故障排查

### 问题 1: 进程关闭后仍然提示占用

**解决方案：**
```bash
# 1. 强制关闭所有 Chrome 进程
pkill -9 -f "Google Chrome"

# 2. 清理锁文件
rm -rf /Users/mi/.cache/chrome-devtools-mcp/chrome-profile/SingletonLock
rm -rf /Users/mi/.cache/chrome-devtools-mcp/chrome-profile/SingletonSocket

# 3. 重新测试
```

### 问题 2: MCP 工具无法启动浏览器

**解决方案：**
```bash
# 1. 检查 Chrome 是否安装
which google-chrome-stable
# 或
ls -la /Applications/Google\ Chrome.app

# 2. 重新安装 MCP 工具
npx chrome-devtools-mcp@latest --version

# 3. 检查 Node.js 版本
node --version  # 应该 >= 16.x
```

### 问题 3: 权限问题

**解决方案：**
```bash
# 修复缓存目录权限
sudo chown -R $(whoami) ~/.cache/chrome-devtools-mcp
chmod -R 755 ~/.cache/chrome-devtools-mcp
```

---

## 🎯 推荐的测试方法

### 方法 1: MCP 自动化测试（理想）

**优点：**
- ✅ 可重复性高
- ✅ 可以记录测试步骤
- ✅ 适合回归测试

**缺点：**
- ⚠️ 需要处理浏览器实例管理
- ⚠️ 配置相对复杂

**适用场景：** CI/CD 自动化测试

### 方法 2: 手动浏览器测试（当前推荐）

**优点：**
- ✅ 简单直接
- ✅ 可以实时查看效果
- ✅ 易于调试

**缺点：**
- ⚠️ 手动操作，效率较低
- ⚠️ 不易重复

**适用场景：** 开发阶段的功能验证

**测试步骤：**
1. 打开浏览器访问 http://localhost:5173
2. 手动测试评论、点赞、搜索功能
3. 记录测试结果

### 方法 3: 使用 Playwright/Cypress（推荐长期）

**安装 Playwright：**
```bash
cd frontend
npm install -D @playwright/test
npx playwright install
```

**创建测试文件：**
```javascript
// frontend/tests/week3.spec.js
import { test, expect } from '@playwright/test';

test('评论功能测试', async ({ page }) => {
  await page.goto('http://localhost:5173');
  // 测试逻辑...
});
```

---

## 📝 最佳实践

### 1. 每天开始工作前

```bash
# 清理旧的浏览器实例
./reset-mcp-chrome-devtools.sh

# 或使用快捷命令
reset-chrome
```

### 2. 开发过程中

- 💡 如果需要调试，使用普通浏览器手动测试
- 💡 如果需要自动化，先关闭其他 Chrome 实例
- 💡 定期清理缓存目录

### 3. 提交代码前

```bash
# 运行完整的测试套件
./reset-mcp-chrome-devtools.sh

# 手动验证关键功能
# 1. 评论发表和回复
# 2. 点赞和取消点赞
# 3. 搜索和历史记录
```

---

## 🎓 总结

### 快速解决当前问题

```bash
# 一行命令解决
pkill -f "chrome-devtools-mcp/chrome-profile"
```

### 长期解决方案

1. ✅ 使用 `test_week3_frontend_ui.sh` 脚本
2. ✅ 配置 shell 别名 `reset-chrome`
3. ✅ 考虑引入 Playwright 进行自动化测试

### 推荐工作流

```
开始工作 → 运行清理脚本 → 开发测试 → 提交代码前验证 → 清理环境
```

---

**最后更新**: 2025-10-25  
**适用系统**: macOS  
**Chrome 版本**: 141.x  
**MCP 工具**: chrome-devtools-mcp@latest
