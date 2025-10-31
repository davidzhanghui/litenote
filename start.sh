#!/bin/bash

echo "🚀 启动多功能文件编辑器..."
echo ""

# 检查是否已安装依赖
if [ ! -d "node_modules" ]; then
    echo "📦 安装前端依赖..."
    npm install
fi

if [ ! -d "server/node_modules" ]; then
    echo "📦 安装后端依赖..."
    cd server && npm install && cd ..
fi

echo ""
echo "✅ 依赖安装完成"
echo ""
echo "🔧 启动后端服务器 (端口 30001)..."
(cd server && npm start) &
SERVER_PID=$!

sleep 2

echo "🔧 启动前端开发服务器 (端口 3001)..."
npm run dev &
FRONTEND_PID=$!

echo ""
echo "✅ 服务已启动！"
echo ""
echo "📝 访问地址: http://localhost:3001"
echo ""
echo "按 Ctrl+C 停止服务"

# 等待信号
wait $SERVER_PID $FRONTEND_PID
