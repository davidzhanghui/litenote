#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Python 示例脚本
演示基本的 Python 语法和功能
"""

def hello_world():
    """打印 Hello World"""
    print("Hello, World!")


def fibonacci(n):
    """
    计算斐波那契数列
    
    Args:
        n: 数列的长度
        
    Returns:
        list: 斐波那契数列
    """
    if n <= 0:
        return []
    elif n == 1:
        return [1]
    elif n == 2:
        return [1, 1]
    
    fib = [1, 1]
    for i in range(2, n):
        fib.append(fib[i-1] + fib[i-2])
    return fib


def main():
    """主函数"""
    print("=== Python 示例脚本 ===\n")
    
    # 示例 1: Hello World
    hello_world()
    
    # 示例 2: 斐波那契数列
    print("\n斐波那契数列 (前10项):")
    fib = fibonacci(10)
    print(fib)
    
    # 示例 3: 列表推导式
    print("\n列表推导式示例:")
    squares = [x**2 for x in range(1, 6)]
    print(f"1-5 的平方: {squares}")
    
    # 示例 4: 字典操作
    print("\n字典操作示例:")
    person = {
        "name": "张三",
        "age": 25,
        "city": "北京"
    }
    for key, value in person.items():
        print(f"{key}: {value}")


if __name__ == "__main__":
    main()
