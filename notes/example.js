/**
 * JavaScript 示例脚本
 * 演示基本的 JavaScript 语法和功能
 */

// 示例 1: 基本函数
function greet(name) {
  return `Hello, ${name}!`;
}

// 示例 2: 箭头函数
const add = (a, b) => a + b;

// 示例 3: 数组操作
const numbers = [1, 2, 3, 4, 5];

// 使用 map 转换数组
const doubled = numbers.map(n => n * 2);
console.log("原数组:", numbers);
console.log("翻倍后:", doubled);

// 使用 filter 过滤数组
const evens = numbers.filter(n => n % 2 === 0);
console.log("偶数:", evens);

// 使用 reduce 累加
const sum = numbers.reduce((acc, n) => acc + n, 0);
console.log("总和:", sum);

// 示例 4: 对象操作
const person = {
  name: "李四",
  age: 28,
  city: "上海",
  greet() {
    return `我是 ${this.name}，来自 ${this.city}`;
  }
};

console.log(person.greet());

// 示例 5: 异步操作
async function fetchData() {
  try {
    // 模拟异步操作
    const response = await new Promise(resolve => {
      setTimeout(() => {
        resolve({ data: "异步数据获取成功" });
      }, 1000);
    });
    console.log(response.data);
  } catch (error) {
    console.error("错误:", error);
  }
}

// 示例 6: 类定义
class Calculator {
  constructor(name) {
    this.name = name;
  }

  add(a, b) {
    return a + b;
  }

  subtract(a, b) {
    return a - b;
  }

  multiply(a, b) {
    return a * b;
  }

  divide(a, b) {
    return b !== 0 ? a / b : "不能除以零";
  }
}

// 使用类
const calc = new Calculator("我的计算器");
console.log(`${calc.name} - 10 + 5 = ${calc.add(10, 5)}`);
console.log(`${calc.name} - 10 - 5 = ${calc.subtract(10, 5)}`);
console.log(`${calc.name} - 10 * 5 = ${calc.multiply(10, 5)}`);
console.log(`${calc.name} - 10 / 5 = ${calc.divide(10, 5)}`);

// 导出函数（如果在模块环境中）
if (typeof module !== "undefined" && module.exports) {
  module.exports = { greet, add, Calculator };
}
