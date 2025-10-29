#!/bin/bash

# Week 3 前端 UI 测试脚本
# 使用 chrome-devtools MCP 进行浏览器自动化测试

set -e

echo "========================================"
echo "  Week 3 前端 UI 测试"
echo "========================================"
echo ""

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 检查并关闭现有的 Chrome 进程
echo "📋 检查现有的 Chrome 进程..."
if pgrep -f "chrome-devtools-mcp/chrome-profile" > /dev/null; then
    echo -e "${YELLOW}⚠️  发现现有的 Chrome 进程，正在关闭...${NC}"
    pkill -f "chrome-devtools-mcp/chrome-profile" || true
    sleep 2
    echo -e "${GREEN}✓ Chrome 进程已关闭${NC}"
else
    echo -e "${GREEN}✓ 没有运行中的 Chrome 进程${NC}"
fi

# 检查前端服务器
echo ""
echo "📋 检查前端服务器状态..."
if lsof -i :5173 > /dev/null 2>&1; then
    echo -e "${GREEN}✓ 前端服务器正在运行 (http://localhost:5173)${NC}"
else
    echo -e "${RED}✗ 前端服务器未运行${NC}"
    echo "请先启动前端服务器："
    echo "  cd frontend && npm run dev"
    exit 1
fi

# 检查后端服务器
echo ""
echo "📋 检查后端服务器状态..."
if lsof -i :8080 > /dev/null 2>&1; then
    echo -e "${GREEN}✓ 后端服务器正在运行 (http://localhost:8080)${NC}"
else
    echo -e "${RED}✗ 后端服务器未运行${NC}"
    echo "请先启动后端服务器："
    echo "  cd backend && mvn spring-boot:run"
    exit 1
fi

echo ""
echo "========================================"
echo "  环境检查完成，可以开始测试"
echo "========================================"
echo ""
echo "现在你可以："
echo "1. 手动在浏览器中访问: http://localhost:5173"
echo "2. 或使用 MCP chrome-devtools 工具进行自动化测试"
echo ""
echo -e "${YELLOW}提示：如果要使用 MCP 工具，请确保：${NC}"
echo "  - 在 Windsurf IDE 中使用 MCP chrome-devtools 工具"
echo "  - 或者使用命令行：npx chrome-devtools-mcp"
echo ""
