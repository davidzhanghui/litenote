#!/bin/bash

# Shell 示例脚本
# 演示基本的 Shell 语法和功能

echo "=== Shell 示例脚本 ==="
echo ""

# 示例 1: 变量定义和使用
echo "示例 1: 变量定义和使用"
name="张三"
age=25
echo "姓名: $name"
echo "年龄: $age"
echo ""

# 示例 2: 字符串操作
echo "示例 2: 字符串操作"
str="Hello, World!"
echo "原字符串: $str"
echo "字符串长度: ${#str}"
echo "子字符串: ${str:0:5}"
echo ""

# 示例 3: 数组操作
echo "示例 3: 数组操作"
fruits=("apple" "banana" "orange" "grape")
echo "水果列表: ${fruits[@]}"
echo "第一个水果: ${fruits[0]}"
echo "水果数量: ${#fruits[@]}"
echo ""

# 示例 4: 条件判断
echo "示例 4: 条件判断"
if [ $age -ge 18 ]; then
    echo "$name 已成年"
else
    echo "$name 未成年"
fi
echo ""

# 示例 5: 循环
echo "示例 5: 循环"
echo "1 到 5 的数字:"
for i in {1..5}; do
    echo "  $i"
done
echo ""

# 示例 6: 函数定义
echo "示例 6: 函数定义"

add() {
    local a=$1
    local b=$2
    echo $((a + b))
}

multiply() {
    local a=$1
    local b=$2
    echo $((a * b))
}

result_add=$(add 10 5)
result_mul=$(multiply 10 5)
echo "10 + 5 = $result_add"
echo "10 * 5 = $result_mul"
echo ""

# 示例 7: 文件操作
echo "示例 7: 文件操作"
test_file="/tmp/test_file.txt"
echo "创建测试文件: $test_file"
echo "这是一个测试文件" > "$test_file"

if [ -f "$test_file" ]; then
    echo "文件存在"
    echo "文件内容:"
    cat "$test_file"
    rm "$test_file"
    echo "文件已删除"
else
    echo "文件不存在"
fi
echo ""

# 示例 8: 命令替换
echo "示例 8: 命令替换"
current_date=$(date "+%Y-%m-%d %H:%M:%S")
echo "当前时间: $current_date"
echo ""

echo "=== 脚本执行完成 ==="
