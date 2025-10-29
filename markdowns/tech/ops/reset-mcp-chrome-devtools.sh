#!/bin/bash

# 使用 chrome-devtools MCP 进行浏览器自动化测试

set -e

echo "========================================"
echo "  前端 UI 测试"
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

echo ""
echo "========================================"
echo "  环境检查完成，可以开始测试"
echo "========================================"
echo ""
echo "现在你可以："
echo "1. 使用 MCP chrome-devtools 工具进行自动化测试"
echo ""
echo -e "${YELLOW}提示：如果要使用 MCP 工具，请确保：${NC}"
echo "  - 在 Windsurf IDE 中使用 MCP chrome-devtools 工具"
echo "  - 或者使用命令行：npx chrome-devtools-mcp"
echo ""
