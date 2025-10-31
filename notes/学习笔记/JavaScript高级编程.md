# JavaScript高级编程学习笔记

## 1. JavaScript基础回顾

### 1.1 变量与数据类型

#### 1.1.1 变量声明方式
```javascript
// var声明 - 函数作用域，存在变量提升
var name = "JavaScript";
console.log(window.name); // 可以通过window对象访问

// let声明 - 块级作用域，暂时性死区
let age = 25;
{
  let age = 30;
  console.log(age); // 30
}
console.log(age); // 25

// const声明 - 常量，必须初始化，不可重新赋值
const PI = 3.14159;
// PI = 3.14; // TypeError: Assignment to constant variable

// 对象和数组的const声明
const person = { name: "Alice", age: 25 };
person.age = 26; // 可以修改属性
// person = {}; // TypeError: Assignment to constant variable

const numbers = [1, 2, 3];
numbers.push(4); // 可以添加元素
// numbers = []; // TypeError: Assignment to constant variable
```

#### 1.1.2 数据类型详解
```javascript
// 原始类型 (Primitive Types)
// 1. Number - 数字类型
let integer = 42;
let float = 3.14;
let scientific = 1.5e3; // 1500
let hex = 0xFF; // 255
let binary = 0b1010; // 10
let octal = 0o755; // 493

// 特殊数值
let infinity = Infinity;
let negInfinity = -Infinity;
let notANumber = NaN;
console.log(isNaN(notANumber)); // true
console.log(Number.isNaN("hello")); // false
console.log(Number.isNaN(NaN)); // true

// 2. String - 字符串类型
let singleQuote = 'Hello';
let doubleQuote = "World";
let templateLiteral = `Hello ${name}, you are ${age} years old`;

// 字符串方法
let text = "JavaScript Programming";
console.log(text.length); // 20
console.log(text.toUpperCase()); // "JAVASCRIPT PROGRAMMING"
console.log(text.substring(0, 10)); // "JavaScript"
console.log(text.includes("Script")); // true
console.log(text.split(" ")); // ["JavaScript", "Programming"]

// 3. Boolean - 布尔类型
let isTrue = true;
let isFalse = false;

// 假值 (Falsy values)
console.log(Boolean(false)); // false
console.log(Boolean(0)); // false
console.log(Boolean("")); // false
console.log(Boolean(null)); // false
console.log(Boolean(undefined)); // false
console.log(Boolean(NaN)); // false

// 4. Undefined - 未定义
let undefinedVar;
console.log(undefinedVar); // undefined

// 5. Null - 空值
let nullVar = null;
console.log(nullVar); // null

// 6. Symbol - 符号类型 (ES6)
let symbol1 = Symbol("description");
let symbol2 = Symbol("description");
console.log(symbol1 === symbol2); // false

// 7. BigInt - 大整数类型 (ES2020)
let bigInt = 123456789012345678901234567890n;
let bigInt2 = BigInt("123456789012345678901234567890");

// 引用类型 (Reference Types)
// 1. Object - 对象
let obj = {
  name: "John",
  age: 30,
  greet: function() {
    return `Hello, I'm ${this.name}`;
  }
};

// 2. Array - 数组
let arr = [1, 2, 3, "four", { five: 5 }];

// 3. Function - 函数
function func() {
  return "I am a function";
}

// 4. Date - 日期
let date = new Date();

// 5. RegExp - 正则表达式
let regex = /pattern/g;

// 6. Map, Set - 集合类型
let map = new Map();
let set = new Set();
```

### 1.2 类型转换与类型检查

#### 1.2.1 类型转换
```javascript
// 显式类型转换
// 转换为字符串
let num = 123;
let str = String(num); // "123"
let str2 = num.toString(); // "123"

// 转换为数字
let strNum = "456";
let num2 = Number(strNum); // 456
let num3 = parseInt(strNum); // 456
let num4 = parseFloat("3.14"); // 3.14

// 转换为布尔值
let bool = Boolean(1); // true
let bool2 = !!1; // true

// 隐式类型转换
console.log("5" + 5); // "55" (字符串拼接)
console.log("5" - 5); // 0 (数字减法)
console.log("5" * 5); // 25 (数字乘法)
console.log("5" / 5); // 1 (数字除法)

// 相等性比较中的类型转换
console.log(5 == "5"); // true (类型转换)
console.log(5 === "5"); // false (严格相等)

// 类型转换规则表
/*
值          -> 转换为字符串 -> 转换为数字 -> 转换为布尔值
undefined   -> "undefined"  -> NaN        -> false
null        -> "null"       -> 0          -> false
true        -> "true"       -> 1          -> true
false       -> "false"      -> 0          -> false
0           -> "0"          -> 0          -> false
-0          -> "0"          -> 0          -> false
NaN         -> "NaN"        -> NaN        -> false
Infinity    -> "Infinity"   -> Infinity   -> true
-Infinity   -> "-Infinity"  -> -Infinity  -> true
""          -> ""           -> 0          -> false
" "         -> " "          -> 0          -> true
"123"       -> "123"        -> 123        -> true
"hello"     -> "hello"      -> NaN        -> true
[]          -> ""           -> 0          -> true
[1,2]       -> "1,2"        -> NaN        -> true
{}          -> "[object Object]" -> NaN   -> true
*/
```

#### 1.2.2 类型检查方法
```javascript
// typeof操作符
console.log(typeof 42); // "number"
console.log(typeof "hello"); // "string"
console.log(typeof true); // "boolean"
console.log(typeof undefined); // "undefined"
console.log(typeof null); // "object" (历史遗留问题)
console.log(typeof {}); // "object"
console.log(typeof []); // "object"
console.log(typeof function(){}); // "function"

// instanceof操作符
console.log([] instanceof Array); // true
console.log({} instanceof Object); // true
console.log(function(){} instanceof Function); // true

// Object.prototype.toString方法
function getType(value) {
  return Object.prototype.toString.call(value).slice(8, -1);
}

console.log(getType(42)); // "Number"
console.log(getType("hello")); // "String"
console.log(getType(true)); // "Boolean"
console.log(getType(null)); // "Null"
console.log(getType(undefined)); // "Undefined"
console.log(getType([])); // "Array"
console.log(getType({})); // "Object"
console.log(getType(function(){})); // "Function"

// Array.isArray方法
console.log(Array.isArray([])); // true
console.log(Array.isArray({})); // false

// Number.isNaN vs isNaN
console.log(isNaN("hello")); // true (会先转换为数字)
console.log(Number.isNaN("hello")); // false (不会转换)
console.log(isNaN(NaN)); // true
console.log(Number.isNaN(NaN)); // true
```

## 2. 函数高级特性

### 2.1 函数声明与表达式

#### 2.1.1 函数声明方式
```javascript
// 1. 函数声明 (Function Declaration)
function greet(name) {
  return `Hello, ${name}!`;
}

// 函数声明会被提升 (Hoisting)
console.log(greet("Alice")); // 可以在声明前调用

function greet(name) {
  return `Hello, ${name}!`;
}

// 2. 函数表达式 (Function Expression)
const greet2 = function(name) {
  return `Hello, ${name}!`;
};

// 函数表达式不会被提升
// console.log(greet2("Bob")); // ReferenceError

const greet2 = function(name) {
  return `Hello, ${name}!`;
};

// 3. 箭头函数 (Arrow Function)
const greet3 = (name) => `Hello, ${name}!`;

// 箭头函数的特性
// - 没有自己的this
// - 没有自己的arguments对象
// - 不能用作构造函数
// - 没有prototype属性

const obj = {
  name: "Object",
  regularMethod: function() {
    console.log(this.name); // "Object"
  },
  arrowMethod: () => {
    console.log(this.name); // undefined (或全局对象的name)
  }
};

// 4. 立即执行函数表达式 (IIFE)
(function() {
  console.log("IIFE executed");
})();

// 带参数的IIFE
(function(name) {
  console.log(`Hello, ${name}!`);
})("IIFE");

// 5. 递归函数
function factorial(n) {
  if (n <= 1) return 1;
  return n * factorial(n - 1);
}

console.log(factorial(5)); // 120

// 尾递归优化 (ES6)
function factorialOptimized(n, acc = 1) {
  if (n <= 1) return acc;
  return factorialOptimized(n - 1, n * acc);
}
```

#### 2.1.2 函数参数
```javascript
// 默认参数 (ES6)
function greet(name = "Guest", age = 18) {
  return `Hello, ${name}! You are ${age} years old.`;
}

console.log(greet()); // "Hello, Guest! You are 18 years old."
console.log(greet("Alice", 25)); // "Hello, Alice! You are 25 years old."

// 剩余参数 (Rest Parameters)
function sum(...numbers) {
  return numbers.reduce((total, num) => total + num, 0);
}

console.log(sum(1, 2, 3, 4, 5)); // 15

// 混合使用普通参数和剩余参数
function greetAll(greeting, ...names) {
  return `${greeting}, ${names.join(", ")}!`;
}

console.log(greetAll("Hello", "Alice", "Bob", "Charlie")); 
// "Hello, Alice, Bob, Charlie!"

// 解构参数
function createUser({ name, age, city = "Unknown" }) {
  return { name, age, city };
}

const user = createUser({ name: "Alice", age: 25, city: "New York" });
console.log(user); // { name: "Alice", age: 25, city: "New York" }

// 参数验证
function divide(a, b) {
  if (typeof a !== "number" || typeof b !== "number") {
    throw new TypeError("Both arguments must be numbers");
  }
  if (b === 0) {
    throw new Error("Division by zero is not allowed");
  }
  return a / b;
}

// 函数重载模拟
function add(a, b) {
  if (typeof a === "string" && typeof b === "string") {
    return a + b;
  }
  if (typeof a === "number" && typeof b === "number") {
    return a + b;
  }
  if (Array.isArray(a) && Array.isArray(b)) {
    return a.concat(b);
  }
  throw new Error("Unsupported argument types");
}
```

### 2.2 闭包与作用域

#### 2.2.1 作用域链
```javascript
// 全局作用域
let globalVar = "global";

function outerFunction() {
  // 外部函数作用域
  let outerVar = "outer";
  
  function innerFunction() {
    // 内部函数作用域
    let innerVar = "inner";
    
    console.log(globalVar); // 可以访问全局变量
    console.log(outerVar); // 可以访问外部函数变量
    console.log(innerVar); // 可以访问自己的变量
  }
  
  innerFunction();
}

outerFunction();

// 作用域链查找过程
// 1. 在当前作用域查找变量
// 2. 如果找不到，向上一级作用域查找
// 3. 重复步骤2，直到全局作用域
// 4. 如果全局作用域也找不到，抛出ReferenceError

// 块级作用域 (ES6)
{
  let blockVar = "block";
  const blockConst = "block const";
  // var没有块级作用域
  var blockVarVar = "block var";
}

// console.log(blockVar); // ReferenceError
// console.log(blockConst); // ReferenceError
console.log(blockVarVar); // "block var" (var声明的变量泄露到函数作用域)
```

#### 2.2.2 闭包详解
```javascript
// 闭包定义：函数能够访问其外部函数作用域中的变量，即使外部函数已经执行完毕

// 基础闭包示例
function createCounter() {
  let count = 0;
  
  return function() {
    count++;
    return count;
  };
}

const counter = createCounter();
console.log(counter()); // 1
console.log(counter()); // 2
console.log(counter()); // 3

// 闭包的实际应用

// 1. 私有变量
function createPerson(name) {
  let _name = name; // 私有变量
  
  return {
    getName: () => _name,
    setName: (newName) => {
      if (typeof newName === "string" && newName.length > 0) {
        _name = newName;
      }
    }
  };
}

const person = createPerson("Alice");
console.log(person.getName()); // "Alice"
person.setName("Bob");
console.log(person.getName()); // "Bob"
console.log(person._name); // undefined (无法直接访问私有变量)

// 2. 函数工厂
function createMultiplier(factor) {
  return function(number) {
    return number * factor;
  };
}

const double = createMultiplier(2);
const triple = createMultiplier(3);

console.log(double(5)); // 10
console.log(triple(5)); // 15

// 3. 事件处理中的闭包
function attachListeners() {
  const buttons = document.querySelectorAll("button");
  
  for (let i = 0; i < buttons.length; i++) {
    buttons[i].addEventListener("click", function() {
      console.log(`Button ${i} clicked`); // 使用let创建块级作用域
    });
  }
}

// 使用闭包解决循环问题
function attachListenersOld() {
  const buttons = document.querySelectorAll("button");
  
  for (var i = 0; i < buttons.length; i++) {
    (function(index) {
      buttons[index].addEventListener("click", function() {
        console.log(`Button ${index} clicked`);
      });
    })(i);
  }
}

// 4. 缓存/记忆化
function memoize(fn) {
  const cache = new Map();
  
  return function(...args) {
    const key = JSON.stringify(args);
    
    if (cache.has(key)) {
      return cache.get(key);
    }
    
    const result = fn.apply(this, args);
    cache.set(key, result);
    return result;
  };
}

function fibonacci(n) {
  if (n <= 1) return n;
  return fibonacci(n - 1) + fibonacci(n - 2);
}

const memoizedFibonacci = memoize(fibonacci);
console.log(memoizedFibonacci(40)); // 计算速度很快

// 闭包的内存管理
// 闭包会保持对外部变量的引用，可能导致内存泄漏
function createLeakyFunction() {
  const largeArray = new Array(1000000).fill("data");
  
  return function() {
    // 这个闭包引用了largeArray，导致largeArray无法被垃圾回收
    return largeArray[0];
  };
}

// 解决方案：及时解除引用
function createNonLeakyFunction() {
  const largeArray = new Array(1000000).fill("data");
  let result = largeArray[0];
  largeArray = null; // 解除引用
  
  return function() {
    return result;
  };
}
```

### 2.3 高阶函数

#### 2.3.1 函数作为参数
```javascript
// 接受函数作为参数的函数称为高阶函数

// 1. Array.prototype.forEach
const numbers = [1, 2, 3, 4, 5];
numbers.forEach((num, index) => {
  console.log(`Index ${index}: ${num}`);
});

// 2. Array.prototype.map
const doubled = numbers.map(num => num * 2);
console.log(doubled); // [2, 4, 6, 8, 10]

// 对象映射
const users = [
  { id: 1, name: "Alice", age: 25 },
  { id: 2, name: "Bob", age: 30 },
  { id: 3, name: "Charlie", age: 35 }
];

const userNames = users.map(user => user.name);
console.log(userNames); // ["Alice", "Bob", "Charlie"]

// 3. Array.prototype.filter
const evenNumbers = numbers.filter(num => num % 2 === 0);
console.log(evenNumbers); // [2, 4]

const adults = users.filter(user => user.age >= 18);
console.log(adults); // 所有用户

// 4. Array.prototype.reduce
const sum = numbers.reduce((accumulator, currentValue) => accumulator + currentValue, 0);
console.log(sum); // 15

// 复杂的reduce操作
const groupedByAge = users.reduce((groups, user) => {
  const ageGroup = user.age >= 30 ? "30+" : "under30";
  if (!groups[ageGroup]) {
    groups[ageGroup] = [];
  }
  groups[ageGroup].push(user);
  return groups;
}, {});

console.log(groupedByAge);
// {
//   "under30": [{ id: 1, name: "Alice", age: 25 }],
//   "30+": [{ id: 2, name: "Bob", age: 30 }, { id: 3, name: "Charlie", age: 35 }]
// }

// 5. Array.prototype.find 和 Array.prototype.findIndex
const foundUser = users.find(user => user.name === "Bob");
console.log(foundUser); // { id: 2, name: "Bob", age: 30 }

const userIndex = users.findIndex(user => user.name === "Bob");
console.log(userIndex); // 1

// 6. Array.prototype.some 和 Array.prototype.every
const hasAdult = users.some(user => user.age >= 18);
console.log(hasAdult); // true

const allAdults = users.every(user => user.age >= 18);
console.log(allAdults); // true

// 7. 自定义高阶函数
function withLogging(fn) {
  return function(...args) {
    console.log(`Calling function with args: ${args}`);
    const result = fn.apply(this, args);
    console.log(`Function returned: ${result}`);
    return result;
  };
}

const add = (a, b) => a + b;
const loggedAdd = withLogging(add);
loggedAdd(2, 3); // 输出日志并返回5

// 函数组合
function compose(...fns) {
  return function(value) {
    return fns.reduceRight((acc, fn) => fn(acc), value);
  };
}

const addOne = x => x + 1;
const double = x => x * 2;
const square = x => x * x;

const composed = compose(square, double, addOne);
console.log(composed(2)); // ((2 + 1) * 2) ^ 2 = 36

// 管道 (pipe) - 从左到右执行
function pipe(...fns) {
  return function(value) {
    return fns.reduce((acc, fn) => fn(acc), value);
  };
}

const piped = pipe(addOne, double, square);
console.log(piped(2)); // (((2 + 1) * 2) ^ 2) = 36
```

#### 2.3.2 函数作为返回值
```javascript
// 返回函数的函数

// 1. 柯里化 (Currying)
function curry(fn) {
  return function curried(...args) {
    if (args.length >= fn.length) {
      return fn.apply(this, args);
    } else {
      return function(...nextArgs) {
        return curried.apply(this, args.concat(nextArgs));
      };
    }
  };
}

function add(a, b, c) {
  return a + b + c;
}

const curriedAdd = curry(add);
console.log(curriedAdd(1)(2)(3)); // 6
console.log(curriedAdd(1, 2)(3)); // 6
console.log(curriedAdd(1)(2, 3)); // 6

// 2. 偏函数应用 (Partial Application)
function partial(fn, ...presetArgs) {
  return function(...laterArgs) {
    return fn.apply(this, presetArgs.concat(laterArgs));
  };
}

function multiply(a, b, c) {
  return a * b * c;
}

const multiplyBy2And3 = partial(multiply, 2, 3);
console.log(multiplyBy2And3(4)); // 24

// 3. 延迟执行
function delay(fn, waitTime) {
  return function(...args) {
    setTimeout(() => fn.apply(this, args), waitTime);
  };
}

const delayedLog = delay(console.log, 1000);
delayedLog("This will be logged after 1 second");

// 4. 防抖函数 (Debounce)
function debounce(fn, delay) {
  let timeoutId;
  
  return function(...args) {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => fn.apply(this, args), delay);
  };
}

// 搜索框输入防抖
const searchInput = document.getElementById("search");
const debouncedSearch = debounce(function(query) {
  console.log(`Searching for: ${query}`);
}, 300);

searchInput.addEventListener("input", (e) => {
  debouncedSearch(e.target.value);
});

// 5. 节流函数 (Throttle)
function throttle(fn, limit) {
  let inThrottle;
  
  return function(...args) {
    if (!inThrottle) {
      fn.apply(this, args);
      inThrottle = true;
      setTimeout(() => inThrottle = false, limit);
    }
  };
}

// 滚动事件节流
const throttledScroll = throttle(function() {
  console.log("Scroll event handled");
}, 100);

window.addEventListener("scroll", throttledScroll);

// 6. 一次性函数
function once(fn) {
  let called = false;
  let result;
  
  return function(...args) {
    if (!called) {
      called = true;
      result = fn.apply(this, args);
    }
    return result;
  };
}

const initialize = once(function() {
  console.log("Initialized");
  return "Initialization complete";
});

console.log(initialize()); // "Initialized" 和 "Initialization complete"
console.log(initialize()); // 只返回 "Initialization complete"
```

## 3. 面向对象编程

### 3.1 原型与原型链

#### 3.1.1 原型基础
```javascript
// 每个函数都有一个prototype属性
// 每个对象都有一个__proto__属性（非标准，建议使用Object.getPrototypeOf）

// 构造函数
function Person(name, age) {
  this.name = name;
  this.age = age;
}

// 在原型上添加方法
Person.prototype.greet = function() {
  return `Hello, I'm ${this.name} and I'm ${this.age} years old.`;
};

Person.prototype.celebrateBirthday = function() {
  this.age++;
  return `Happy birthday! Now I'm ${this.age} years old.`;
};

// 创建实例
const alice = new Person("Alice", 25);
console.log(alice.greet()); // "Hello, I'm Alice and I'm 25 years old."
console.log(alice.celebrateBirthday()); // "Happy birthday! Now I'm 26 years old."

// 原型链
console.log(alice.__proto__ === Person.prototype); // true
console.log(Person.prototype.__proto__ === Object.prototype); // true
console.log(Object.prototype.__proto__ === null); // true

// 属性查找过程
// 1. 在实例对象上查找属性
// 2. 如果找不到，在原型上查找
// 3. 如果还找不到，在原型的原型上查找
// 4. 重复步骤3，直到Object.prototype
// 5. 如果Object.prototype也找不到，返回undefined

// 检查属性是否在原型上
console.log(alice.hasOwnProperty("name")); // true (实例属性)
console.log(alice.hasOwnProperty("greet")); // false (原型属性)
console.log("greet" in alice); // true (可以访问)

// 获取原型对象
console.log(Object.getPrototypeOf(alice) === Person.prototype); // true

// 设置原型对象
const animal = {
  eat: function() {
    console.log("Eating...");
  }
};

const dog = Object.create(animal);
dog.bark = function() {
  console.log("Woof!");
};

dog.eat(); // "Eating..." (从原型继承)
dog.bark(); // "Woof!" (自身方法)
```

#### 3.1.2 原型继承
```javascript
// 1. 原型链继承
function Animal(name) {
  this.name = name;
}

Animal.prototype.eat = function() {
  console.log(`${this.name} is eating.`);
};

function Dog(name, breed) {
  this.breed = breed;
}

// 设置原型链
Dog.prototype = new Animal();
Dog.prototype.constructor = Dog; // 修复constructor

Dog.prototype.bark = function() {
  console.log(`${this.name} is barking.`);
};

const myDog = new Dog("Buddy", "Golden Retriever");
myDog.eat(); // "Buddy is eating."
myDog.bark(); // "Buddy is barking."

// 2. 构造函数继承
function Animal2(name) {
  this.name = name;
}

Animal2.prototype.eat = function() {
  console.log(`${this.name} is eating.`);
};

function Dog2(name, breed) {
  Animal2.call(this, name); // 继承属性
  this.breed = breed;
}

// 继承方法
Dog2.prototype = Object.create(Animal2.prototype);
Dog2.prototype.constructor = Dog2;

Dog2.prototype.bark = function() {
  console.log(`${this.name} is barking.`);
};

const myDog2 = new Dog2("Max", "Labrador");
myDog2.eat(); // "Max is eating."
myDog2.bark(); // "Max is barking."

// 3. 组合继承 (最常用)
function Animal3(name) {
  this.name = name;
  this.animals = [];
}

Animal3.prototype.eat = function() {
  console.log(`${this.name} is eating.`);
};

function Dog3(name, breed) {
  Animal3.call(this, name); // 继承属性
  this.breed = breed;
}

Dog3.prototype = new Animal3(); // 继承方法
Dog3.prototype.constructor = Dog3;

Dog3.prototype.bark = function() {
  console.log(`${this.name} is barking.`);
};

// 4. 寄生组合式继承 (最优)
function inheritPrototype(child, parent) {
  const prototype = Object.create(parent.prototype);
  prototype.constructor = child;
  child.prototype = prototype;
}

function Animal4(name) {
  this.name = name;
}

Animal4.prototype.eat = function() {
  console.log(`${this.name} is eating.`);
};

function Dog4(name, breed) {
  Animal4.call(this, name);
  this.breed = breed;
}

inheritPrototype(Dog4, Animal4);

Dog4.prototype.bark = function() {
  console.log(`${this.name} is barking.`);
};

const myDog4 = new Dog4("Rocky", "Bulldog");
myDog4.eat(); // "Rocky is eating."
myDog4.bark(); // "Rocky is barking."
```

### 3.2 ES6类语法

#### 3.2.1 类的基本语法
```javascript
// ES6类只是原型继承的语法糖
class Person {
  // 构造函数
  constructor(name, age) {
    this.name = name;
    this.age = age;
  }
  
  // 实例方法
  greet() {
    return `Hello, I'm ${this.name} and I'm ${this.age} years old.`;
  }
  
  // 静态方法
  static createAdult(name) {
    return new Person(name, 18);
  }
  
  // 静态属性
  static species = "Homo sapiens";
  
  // getter
  get description() {
    return `${this.name} (${this.age} years old)`;
  }
  
  // setter
  set age(newAge) {
    if (typeof newAge === "number" && newAge > 0) {
      this._age = newAge;
    } else {
      throw new Error("Invalid age");
    }
  }
  
  get age() {
    return this._age;
  }
}

const alice = new Person("Alice", 25);
console.log(alice.greet()); // "Hello, I'm Alice and I'm 25 years old."
console.log(alice.description); // "Alice (25 years old)"

const adult = Person.createAdult("John");
console.log(adult.age); // 18

// 类继承
class Employee extends Person {
  constructor(name, age, position, salary) {
    super(name, age); // 调用父类构造函数
    this.position = position;
    this.salary = salary;
  }
  
  // 重写父类方法
  greet() {
    return `${super.greet()} I work as a ${this.position}.`;
  }
  
  // 新方法
  promote(newPosition, salaryIncrease) {
    this.position = newPosition;
    this.salary += salaryIncrease;
    return `Promoted to ${newPosition}! New salary: $${this.salary}`;
  }
  
  // 静态方法
  static createManager(name, age) {
    return new Employee(name, age, "Manager", 80000);
  }
}

const bob = new Employee("Bob", 30, "Developer", 60000);
console.log(bob.greet()); // "Hello, I'm Bob and I'm 30 years old. I work as a Developer."
console.log(bob.promote("Senior Developer", 10000)); // "Promoted to Senior Developer! New salary: $70000"

const manager = Employee.createManager("Sarah", 35);
console.log(manager.position); // "Manager"
```

#### 3.2.2 类的高级特性
```javascript
// 私有字段 (ES2022)
class BankAccount {
  #balance = 0; // 私有字段
  #transactions = [];
  
  constructor(owner, initialBalance = 0) {
    this.owner = owner;
    this.#balance = initialBalance;
  }
  
  deposit(amount) {
    if (amount > 0) {
      this.#balance += amount;
      this.#transactions.push({ type: "deposit", amount, date: new Date() });
      return this.#balance;
    }
    throw new Error("Deposit amount must be positive");
  }
  
  withdraw(amount) {
    if (amount > 0 && amount <= this.#balance) {
      this.#balance -= amount;
      this.#transactions.push({ type: "withdraw", amount, date: new Date() });
      return this.#balance;
    }
    throw new Error("Invalid withdrawal amount");
  }
  
  get balance() {
    return this.#balance;
  }
  
  get statement() {
    return this.#transactions.slice(); // 返回副本，保护内部数据
  }
}

const account = new BankAccount("Alice", 1000);
account.deposit(500);
account.withdraw(200);
console.log(account.balance); // 1300
// account.#balance = 9999; // SyntaxError: Private field '#balance' must be declared in an enclosing class

// 静私有字段
class MathUtils {
  static #PI = 3.14159265359;
  
  static circleArea(radius) {
    return this.#PI * radius * radius;
  }
  
  static get PI() {
    return this.#PI;
  }
}

console.log(MathUtils.circleArea(5)); // 78.53981633975
console.log(MathUtils.PI); // 3.14159265359

// 类表达式
const MyClass = class {
  constructor(value) {
    this.value = value;
  }
  
  getValue() {
    return this.value;
  }
};

const instance = new MyClass(42);
console.log(instance.getValue()); // 42

// 匿名类
function createClass(className) {
  return new (class {
    constructor() {
      this.name = className;
    }
    
    toString() {
      return this.name;
    }
  })();
}

const obj = createClass("DynamicClass");
console.log(obj.toString()); // "DynamicClass"

// Mixin模式
const canFly = {
  fly() {
    console.log(`${this.name} is flying!`);
  }
};

const canSwim = {
  swim() {
    console.log(`${this.name} is swimming!`);
  }
};

class Duck {
  constructor(name) {
    this.name = name;
  }
  
  quack() {
    console.log("Quack quack!");
  }
}

// 应用mixin
Object.assign(Duck.prototype, canFly, canSwim);

const duck = new Duck("Donald");
duck.quack(); // "Quack quack!"
duck.fly(); // "Donald is flying!"
duck.swim(); // "Donald is swimming!"
```

### 3.3 设计模式

#### 3.3.1 创建型模式
```javascript
// 1. 单例模式 (Singleton)
class DatabaseConnection {
  constructor() {
    if (DatabaseConnection.instance) {
      return DatabaseConnection.instance;
    }
    
    this.connection = "Connected to database";
    DatabaseConnection.instance = this;
  }
  
  query(sql) {
    console.log(`Executing: ${sql}`);
    return "Query results";
  }
  
  static getInstance() {
    if (!DatabaseConnection.instance) {
      DatabaseConnection.instance = new DatabaseConnection();
    }
    return DatabaseConnection.instance;
  }
}

const db1 = DatabaseConnection.getInstance();
const db2 = DatabaseConnection.getInstance();
console.log(db1 === db2); // true

// 2. 工厂模式 (Factory)
class Vehicle {
  constructor(type, brand) {
    this.type = type;
    this.brand = brand;
  }
  
  drive() {
    console.log(`Driving a ${this.brand} ${this.type}`);
  }
}

class VehicleFactory {
  static createVehicle(type, brand) {
    switch (type) {
      case "car":
        return new Vehicle("car", brand);
      case "motorcycle":
        return new Vehicle("motorcycle", brand);
      case "truck":
        return new Vehicle("truck", brand);
      default:
        throw new Error(`Unknown vehicle type: ${type}`);
    }
  }
}

const car = VehicleFactory.createVehicle("car", "Toyota");
const motorcycle = VehicleFactory.createVehicle("motorcycle", "Harley-Davidson");

car.drive(); // "Driving a Toyota car"
motorcycle.drive(); // "Driving a Harley-Davidson motorcycle"

// 3. 建造者模式 (Builder)
class Computer {
  constructor() {
    this.cpu = null;
    this.memory = null;
    this.storage = null;
    this.gpu = null;
  }
  
  setCPU(cpu) {
    this.cpu = cpu;
    return this;
  }
  
  setMemory(memory) {
    this.memory = memory;
    return this;
  }
  
  setStorage(storage) {
    this.storage = storage;
    return this;
  }
  
  setGPU(gpu) {
    this.gpu = gpu;
    return this;
  }
  
  build() {
    if (!this.cpu || !this.memory || !this.storage) {
      throw new Error("Missing required components");
    }
    return { ...this };
  }
}

const gamingPC = new Computer()
  .setCPU("Intel i9")
  .setMemory("32GB DDR4")
  .setStorage("1TB NVMe SSD")
  .setGPU("RTX 4090")
  .build();

console.log(gamingPC);
// {
//   cpu: "Intel i9",
//   memory: "32GB DDR4",
//   storage: "1TB NVMe SSD",
//   gpu: "RTX 4090"
// }
```

#### 3.3.2 结构型模式
```javascript
// 1. 装饰器模式 (Decorator)
class Coffee {
  cost() {
    return 5;
  }
  
  description() {
    return "Simple coffee";
  }
}

class MilkDecorator {
  constructor(coffee) {
    this.coffee = coffee;
  }
  
  cost() {
    return this.coffee.cost() + 1;
  }
  
  description() {
    return this.coffee.description() + ", milk";
  }
}

class SugarDecorator {
  constructor(coffee) {
    this.coffee = coffee;
  }
  
  cost() {
    return this.coffee.cost() + 0.5;
  }
  
  description() {
    return this.coffee.description() + ", sugar";
  }
}

let coffee = new Coffee();
coffee = new MilkDecorator(coffee);
coffee = new SugarDecorator(coffee);

console.log(coffee.description()); // "Simple coffee, milk, sugar"
console.log(coffee.cost()); // 6.5

// 2. 适配器模式 (Adapter)
class LegacyPaymentSystem {
  processPayment(amount, currency, cardNumber, cvv) {
    console.log(`Processing $${amount} ${currency} payment with card ${cardNumber}`);
    return "Payment processed";
  }
}

class ModernPaymentGateway {
  pay(paymentDetails) {
    const { amount, currency, paymentMethod } = paymentDetails;
    console.log(`Paying ${amount} ${currency} via ${paymentMethod.type}`);
    return "Payment successful";
  }
}

class PaymentAdapter {
  constructor(legacySystem) {
    this.legacySystem = legacySystem;
  }
  
  pay(paymentDetails) {
    const { amount, currency, paymentMethod } = paymentDetails;
    return this.legacySystem.processPayment(
      amount,
      currency,
      paymentMethod.cardNumber,
      paymentMethod.cvv
    );
  }
}

const legacySystem = new LegacyPaymentSystem();
const adapter = new PaymentAdapter(legacySystem);

const paymentDetails = {
  amount: 100,
  currency: "USD",
  paymentMethod: {
    type: "credit_card",
    cardNumber: "1234-5678-9012-3456",
    cvv: "123"
  }
};

adapter.pay(paymentDetails); // 使用旧系统处理现代格式的支付请求

// 3. 代理模式 (Proxy)
class RealImage {
  constructor(filename) {
    this.filename = filename;
    this.loadImage();
  }
  
  loadImage() {
    console.log(`Loading image: ${this.filename}`);
    this.data = `Image data for ${this.filename}`;
  }
  
  display() {
    console.log(`Displaying image: ${this.filename}`);
  }
}

class ProxyImage {
  constructor(filename) {
    this.filename = filename;
    this.realImage = null;
  }
  
  display() {
    if (!this.realImage) {
      this.realImage = new RealImage(this.filename);
    }
    this.realImage.display();
  }
}

const image1 = new ProxyImage("photo1.jpg");
const image2 = new ProxyImage("photo2.jpg");

// 图片只在实际显示时才加载
image1.display(); // "Loading image: photo1.jpg" then "Displaying image: photo1.jpg"
image1.display(); // Only "Displaying image: photo1.jpg" (already loaded)
image2.display(); // "Loading image: photo2.jpg" then "Displaying image: photo2.jpg"
```

#### 3.3.3 行为型模式
```javascript
// 1. 观察者模式 (Observer)
class Subject {
  constructor() {
    this.observers = [];
  }
  
  subscribe(observer) {
    this.observers.push(observer);
  }
  
  unsubscribe(observer) {
    this.observers = this.observers.filter(obs => obs !== observer);
  }
  
  notify(data) {
    this.observers.forEach(observer => observer.update(data));
  }
}

class NewsPublisher extends Subject {
  publishNews(news) {
    console.log(`Publishing news: ${news}`);
    this.notify(news);
  }
}

class NewsSubscriber {
  constructor(name) {
    this.name = name;
  }
  
  update(news) {
    console.log(`${this.name} received news: ${news}`);
  }
}

const publisher = new NewsPublisher();
const subscriber1 = new NewsSubscriber("Alice");
const subscriber2 = new NewsSubscriber("Bob");

publisher.subscribe(subscriber1);
publisher.subscribe(subscriber2);

publisher.publishNews("JavaScript ES2022 released!");
// Alice received news: JavaScript ES2022 released!
// Bob received news: JavaScript ES2022 released!

// 2. 策略模式 (Strategy)
class PaymentStrategy {
  pay(amount) {
    throw new Error("Pay method must be implemented");
  }
}

class CreditCardPayment extends PaymentStrategy {
  constructor(cardNumber, cvv) {
    super();
    this.cardNumber = cardNumber;
    this.cvv = cvv;
  }
  
  pay(amount) {
    console.log(`Paid $${amount} using credit card ${this.cardNumber}`);
  }
}

class PayPalPayment extends PaymentStrategy {
  constructor(email) {
    super();
    this.email = email;
  }
  
  pay(amount) {
    console.log(`Paid $${amount} using PayPal account ${this.email}`);
  }
}

class ShoppingCart {
  constructor(paymentStrategy) {
    this.items = [];
    this.paymentStrategy = paymentStrategy;
  }
  
  addItem(item, price) {
    this.items.push({ item, price });
  }
  
  setPaymentStrategy(strategy) {
    this.paymentStrategy = strategy;
  }
  
  checkout() {
    const total = this.items.reduce((sum, item) => sum + item.price, 0);
    this.paymentStrategy.pay(total);
  }
}

const cart = new ShoppingCart(new CreditCardPayment("1234-5678-9012-3456", "123"));
cart.addItem("Book", 20);
cart.addItem("Pen", 5);
cart.checkout(); // "Paid $25 using credit card 1234-5678-9012-3456"

cart.setPaymentStrategy(new PayPalPayment("user@example.com"));
cart.checkout(); // "Paid $25 using PayPal account user@example.com"

// 3. 命令模式 (Command)
class Command {
  execute() {
    throw new Error("Execute method must be implemented");
  }
}

class Light {
  turnOn() {
    console.log("Light is ON");
  }
  
  turnOff() {
    console.log("Light is OFF");
  }
}

class LightOnCommand extends Command {
  constructor(light) {
    super();
    this.light = light;
  }
  
  execute() {
    this.light.turnOn();
  }
}

class LightOffCommand extends Command {
  constructor(light) {
    super();
    this.light = light;
  }
  
  execute() {
    this.light.turnOff();
  }
}

class RemoteControl {
  constructor() {
    this.command = null;
  }
  
  setCommand(command) {
    this.command = command;
  }
  
  pressButton() {
    if (this.command) {
      this.command.execute();
    }
  }
}

const light = new Light();
const lightOn = new LightOnCommand(light);
const lightOff = new LightOffCommand(light);

const remote = new RemoteControl();

remote.setCommand(lightOn);
remote.pressButton(); // "Light is ON"

remote.setCommand(lightOff);
remote.pressButton(); // "Light is OFF"
```

## 4. 异步编程

### 4.1 Promise详解

#### 4.1.1 Promise基础
```javascript
// Promise的三种状态：
// 1. pending: 初始状态，既没有被兑现，也没有被拒绝
// 2. fulfilled: 操作成功完成
// 3. rejected: 操作失败

// 创建Promise
const promise = new Promise((resolve, reject) => {
  // 异步操作
  setTimeout(() => {
    const success = Math.random() > 0.5;
    if (success) {
      resolve("Operation successful!");
    } else {
      reject(new Error("Operation failed!"));
    }
  }, 1000);
});

// 使用Promise
promise
  .then(result => {
    console.log(result); // "Operation successful!"
  })
  .catch(error => {
    console.error(error.message); // "Operation failed!"
  })
  .finally(() => {
    console.log("Operation completed"); // 总是执行
  });

// Promise链式调用
function fetchUser(userId) {
  return new Promise((resolve, reject) => {
    setTimeout(() => {
      if (userId === 1) {
        resolve({ id: 1, name: "John Doe", email: "john@example.com" });
      } else {
        reject(new Error("User not found"));
      }
    }, 500);
  });
}

function fetchUserPosts(user) {
  return new Promise((resolve, reject) => {
    setTimeout(() => {
      resolve([
        { id: 1, title: "Post 1", userId: user.id },
        { id: 2, title: "Post 2", userId: user.id }
      ]);
    }, 300);
  });
}

fetchUser(1)
  .then(user => {
    console.log("User:", user);
    return fetchUserPosts(user); // 返回Promise，传递给下一个then
  })
  .then(posts => {
    console.log("Posts:", posts);
  })
  .catch(error => {
    console.error("Error:", error.message);
  });

// Promise.all - 并行执行多个Promise
const promise1 = Promise.resolve(3);
const promise2 = new Promise(resolve => setTimeout(() => resolve("foo"), 1000));
const promise3 = Promise.resolve("bar");

Promise.all([promise1, promise2, promise3])
  .then(values => {
    console.log(values); // [3, "foo", "bar"]
  })
  .catch(error => {
    console.error("One of the promises failed:", error);
  });

// Promise.race - 返回最先完成的结果
const promise4 = new Promise(resolve => setTimeout(() => resolve("first"), 500));
const promise5 = new Promise(resolve => setTimeout(() => resolve("second"), 1000));

Promise.race([promise4, promise5])
  .then(value => {
    console.log(value); // "first"
  });

// Promise.allSettled - 等待所有Promise完成，不管成功还是失败
const promise6 = Promise.resolve("success");
const promise7 = Promise.reject("failure");
const promise8 = Promise.resolve("another success");

Promise.allSettled([promise6, promise7, promise8])
  .then(results => {
    console.log(results);
    // [
    //   { status: "fulfilled", value: "success" },
    //   { status: "rejected", reason: "failure" },
    //   { status: "fulfilled", value: "another success" }
    // ]
  });
```

#### 4.1.2 Promise工具函数
```javascript
// 创建工具函数
class PromiseUtils {
  // 延迟函数
  static delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
  
  // 超时函数
  static timeout(promise, ms) {
    return Promise.race([
      promise,
      new Promise((_, reject) => 
        setTimeout(() => reject(new Error("Timeout after " + ms + "ms")), ms)
      )
    ]);
  }
  
  // 重试函数
  static retry(fn, maxAttempts = 3, delay = 1000) {
    return new Promise((resolve, reject) => {
      let attempts = 0;
      
      function attempt() {
        attempts++;
        fn()
          .then(resolve)
          .catch(error => {
            if (attempts >= maxAttempts) {
              reject(error);
            } else {
              setTimeout(attempt, delay);
            }
          });
      }
      
      attempt();
    });
  }
  
  // 串行执行
  static series(tasks) {
    return tasks.reduce((promise, task) => {
      return promise.then(result => {
        return Promise.resolve(task()).then(taskResult => {
          return result.concat(taskResult);
        });
      });
    }, Promise.resolve([]));
  }
  
  // 并行执行，限制并发数
  static parallel(tasks, limit = 3) {
    return new Promise((resolve, reject) => {
      const results = [];
      let completed = 0;
      let running = 0;
      let index = 0;
      
      function run() {
        if (index >= tasks.length && running === 0) {
          resolve(results);
          return;
        }
        
        while (running < limit && index < tasks.length) {
          const currentIndex = index++;
          running++;
          
          Promise.resolve(tasks[currentIndex]())
            .then(result => {
              results[currentIndex] = result;
            })
            .catch(error => {
              results[currentIndex] = error;
            })
            .finally(() => {
              running--;
              completed++;
              run();
            });
        }
      }
      
      run();
    });
  }
}

// 使用示例
async function demonstrateUtils() {
  try {
    // 延迟
    await PromiseUtils.delay(1000);
    console.log("Delayed execution");
    
    // 超时
    const result = await PromiseUtils.timeout(
      PromiseUtils.delay(2000).then(() => "Done"),
      1000
    );
  } catch (error) {
    console.error(error.message); // "Timeout after 1000ms"
  }
  
  // 重试
  let attempts = 0;
  const flakyFunction = () => {
    attempts++;
    if (attempts < 3) {
      return Promise.reject(new Error("Failed attempt " + attempts));
    }
    return Promise.resolve("Success!");
  };
  
  try {
    const retryResult = await PromiseUtils.retry(flakyFunction, 5, 500);
    console.log(retryResult); // "Success!"
  } catch (error) {
    console.error("All attempts failed:", error.message);
  }
  
  // 串行执行
  const serialTasks = [
    () => PromiseUtils.delay(1000).then(() => "Task 1"),
    () => PromiseUtils.delay(1000).then(() => "Task 2"),
    () => PromiseUtils.delay(1000).then(() => "Task 3")
  ];
  
  const serialResults = await PromiseUtils.series(serialTasks);
  console.log(serialResults); // ["Task 1", "Task 2", "Task 3"]
  
  // 并行执行（限制并发数）
  const parallelTasks = Array(10).fill().map((_, i) => 
    () => PromiseUtils.delay(Math.random() * 2000).then(() => `Task ${i + 1}`)
  );
  
  const parallelResults = await PromiseUtils.parallel(parallelTasks, 3);
  console.log(parallelResults);
}
```

### 4.2 Async/Await

#### 4.2.1 基础语法
```javascript
// async函数总是返回Promise
async function fetchData() {
  return "Data fetched"; // 自动包装为Promise.resolve("Data fetched")
}

fetchData().then(data => console.log(data)); // "Data fetched"

// await只能在async函数中使用
async function getUserData(userId) {
  try {
    const user = await fetchUser(userId);
    const posts = await fetchUserPosts(user);
    const comments = await fetchPostComments(posts[0].id);
    
    return { user, posts, comments };
  } catch (error) {
    console.error("Error fetching data:", error);
    throw error;
  }
}

// 使用async函数
getUserData(1)
  .then(data => console.log("Complete data:", data))
  .catch(error => console.error("Failed:", error));

// async函数表达式
const asyncFunction = async function() {
  return "Async function expression";
};

// 箭头async函数
const asyncArrow = async () => {
  return "Async arrow function";
};

// 对象方法中的async
const obj = {
  async getData() {
    return await Promise.resolve("Object method");
  }
};

// 并行执行async操作
async function fetchMultipleUsers() {
  const [user1, user2, user3] = await Promise.all([
    fetchUser(1),
    fetchUser(2),
    fetchUser(3)
  ]);
  
  return { user1, user2, user3 };
}

// 顺序执行vs并行执行
async function sequentialVsParallel() {
  console.time("Sequential");
  const user1 = await fetchUser(1);
  const user2 = await fetchUser(2);
  const user3 = await fetchUser(3);
  console.timeEnd("Sequential"); // 约1500ms (3 * 500ms)
  
  console.time("Parallel");
  const [u1, u2, u3] = await Promise.all([
    fetchUser(1),
    fetchUser(2),
    fetchUser(3)
  ]);
  console.timeEnd("Parallel"); // 约500ms (所有请求并行)
}

// 错误处理
async function errorHandling() {
  try {
    const data = await Promise.reject(new Error("Something went wrong"));
  } catch (error) {
    console.error("Caught error:", error.message);
  }
  
  // 或者使用.catch()
  const data = await Promise.reject(new Error("Another error"))
    .catch(error => {
      console.error("Handled error:", error.message);
      return "Default value";
    });
  
  console.log(data); // "Default value"
}
```

#### 4.2.2 高级模式
```javascript
// async迭代器
class AsyncDatabase {
  constructor(data) {
    this.data = data;
    this.index = 0;
  }
  
  async next() {
    if (this.index >= this.data.length) {
      return { done: true };
    }
    
    // 模拟异步数据库查询
    await new Promise(resolve => setTimeout(resolve, 100));
    
    return {
      value: this.data[this.index++],
      done: false
    };
  }
  
  [Symbol.asyncIterator]() {
    return this;
  }
}

async function processUsers() {
  const users = ["Alice", "Bob", "Charlie"];
  const db = new AsyncDatabase(users);
  
  for await (const user of db) {
    console.log("Processing:", user);
  }
}

// async生成器
async function* asyncGenerator() {
  let i = 0;
  while (i < 5) {
    await PromiseUtils.delay(1000);
    yield i++;
  }
}

async function consumeGenerator() {
  for await (const value of asyncGenerator()) {
    console.log("Generated:", value);
  }
}

// 并发控制模式
class ConcurrencyLimiter {
  constructor(limit = 3) {
    this.limit = limit;
    this.running = 0;
    this.queue = [];
  }
  
  async add(promiseFactory) {
    return new Promise((resolve, reject) => {
      this.queue.push({
        promiseFactory,
        resolve,
        reject
      });
      
      this.process();
    });
  }
  
  async process() {
    if (this.running >= this.limit || this.queue.length === 0) {
      return;
    }
    
    this.running++;
    const { promiseFactory, resolve, reject } = this.queue.shift();
    
    try {
      const result = await promiseFactory();
      resolve(result);
    } catch (error) {
      reject(error);
    } finally {
      this.running--;
      this.process();
    }
  }
}

// 使用并发限制器
async function limitedConcurrencyExample() {
  const limiter = new ConcurrencyLimiter(2);
  
  const tasks = Array(10).fill().map((_, i) => 
    limiter.add(() => 
      PromiseUtils.delay(Math.random() * 2000).then(() => `Task ${i} completed`)
    )
  );
  
  const results = await Promise.all(tasks);
  console.log(results);
}

// async装饰器
function withRetry(maxAttempts = 3, delay = 1000) {
  return function(target, propertyKey, descriptor) {
    const originalMethod = descriptor.value;
    
    descriptor.value = async function(...args) {
      let lastError;
      
      for (let attempt = 1; attempt <= maxAttempts; attempt++) {
        try {
          return await originalMethod.apply(this, args);
        } catch (error) {
          lastError = error;
          if (attempt < maxAttempts) {
            console.log(`Attempt ${attempt} failed, retrying in ${delay}ms...`);
            await PromiseUtils.delay(delay);
          }
        }
      }
      
      throw lastError;
    };
    
    return descriptor;
  };
}

class ApiService {
  @withRetry(3, 1000)
  async fetchData(url) {
    // 模拟可能失败的API调用
    if (Math.random() > 0.7) {
      throw new Error("Network error");
    }
    
    await PromiseUtils.delay(500);
    return `Data from ${url}`;
  }
}

// 缓存async结果
function memoizeAsync() {
  const cache = new Map();
  
  return function(target, propertyKey, descriptor) {
    const originalMethod = descriptor.value;
    
    descriptor.value = async function(...args) {
      const key = JSON.stringify(args);
      
      if (cache.has(key)) {
        return cache.get(key);
      }
      
      const result = await originalMethod.apply(this, args);
      cache.set(key, result);
      return result;
    };
    
    return descriptor;
  };
}

class ExpensiveService {
  @memoizeAsync()
  async expensiveCalculation(x, y) {
    console.log(`Performing expensive calculation for ${x}, ${y}`);
    await PromiseUtils.delay(2000);
    return x * y + Math.random();
  }
}

async function demonstrateMemoization() {
  const service = new ExpensiveService();
  
  console.time("First call");
  const result1 = await service.expensiveCalculation(5, 10);
  console.timeEnd("First call"); // 约2000ms
  
  console.time("Second call");
  const result2 = await service.expensiveCalculation(5, 10);
  console.timeEnd("Second call"); // 几乎0ms（缓存命中）
  
  console.log("Results:", result1, result2); // 相同的结果
}
```

## 5. 性能优化与最佳实践

### 5.1 性能优化技巧

#### 5.1.1 内存管理
```javascript
// 避免内存泄漏的最佳实践

// 1. 及时清理事件监听器
class Component {
  constructor() {
    this.handleClick = this.handleClick.bind(this);
    document.addEventListener("click", this.handleClick);
  }
  
  handleClick() {
    console.log("Clicked");
  }
  
  destroy() {
    // 清理事件监听器
    document.removeEventListener("click", this.handleClick);
  }
}

// 2. 避免闭包中的循环引用
function createLeakyClosure() {
  const largeObject = { data: new Array(1000000).fill("data") };
  
  return {
    getData: () => largeObject.data,
    // 这个闭包引用了largeObject，可能导致内存泄漏
  };
}

// 解决方案：使用WeakMap
const componentData = new WeakMap();

function createNonLeakyClosure() {
  const component = {};
  const largeObject = { data: new Array(1000000).fill("data") };
  
  componentData.set(component, largeObject);
  
  return {
    getData: () => componentData.get(component).data,
    // 当component被垃圾回收时，largeObject也会被回收
  };
}

// 3. 使用WeakSet和WeakMap
const weakSet = new WeakSet();
const weakMap = new WeakMap();

// WeakSet示例：跟踪对象是否被处理过
const processedObjects = new WeakSet();

function processObject(obj) {
  if (processedObjects.has(obj)) {
    return "Already processed";
  }
  
  // 处理对象
  processedObjects.add(obj);
  return "Processed";
}

// WeakMap示例：私有数据存储
const privateData = new WeakMap();

class Person {
  constructor(name, age) {
    privateData.set(this, { name, age });
  }
  
  getName() {
    return privateData.get(this).name;
  }
  
  getAge() {
    return privateData.get(this).age;
  }
}

// 4. 及时清理定时器
class Timer {
  constructor() {
    this.timers = [];
  }
  
  setTimeout(callback, delay) {
    const timerId = setTimeout(() => {
      callback();
      this.removeTimer(timerId);
    }, delay);
    
    this.timers.push(timerId);
    return timerId;
  }
  
  removeTimer(timerId) {
    clearTimeout(timerId);
    this.timers = this.timers.filter(id => id !== timerId);
  }
  
  clearAll() {
    this.timers.forEach(timerId => clearTimeout(timerId));
    this.timers = [];
  }
}
```

#### 5.1.2 执行效率优化
```javascript
// 1. 避免频繁的DOM操作
// 不好的做法
function updateListBad(items) {
  const list = document.getElementById("list");
  list.innerHTML = ""; // 清空列表
  
  items.forEach(item => {
    const li = document.createElement("li");
    li.textContent = item;
    list.appendChild(li); // 每次appendChild都会触发重排
  });
}

// 好的做法：使用DocumentFragment
function updateListGood(items) {
  const list = document.getElementById("list");
  const fragment = document.createDocumentFragment();
  
  items.forEach(item => {
    const li = document.createElement("li");
    li.textContent = item;
    fragment.appendChild(li);
  });
  
  list.innerHTML = "";
  list.appendChild(fragment); // 只触发一次重排
}

// 更好的做法：使用innerHTML或模板字符串
function updateListBest(items) {
  const list = document.getElementById("list");
  list.innerHTML = items.map(item => `<li>${item}</li>`).join("");
}

// 2. 事件委托
// 不好的做法：为每个按钮添加事件监听器
function setupButtonsBad() {
  const buttons = document.querySelectorAll(".button");
  buttons.forEach(button => {
    button.addEventListener("click", function() {
      console.log("Button clicked:", this.textContent);
    });
  });
}

// 好的做法：使用事件委托
function setupButtonsGood() {
  const container = document.getElementById("button-container");
  
  container.addEventListener("click", function(event) {
    if (event.target.classList.contains("button")) {
      console.log("Button clicked:", event.target.textContent);
    }
  });
}

// 3. 防抖和节流
// 搜索框防抖
class SearchBox {
  constructor(inputElement, callback, delay = 300) {
    this.input = inputElement;
    this.callback = callback;
    this.delay = delay;
    this.timeoutId = null;
    
    this.input.addEventListener("input", this.handleInput.bind(this));
  }
  
  handleInput(event) {
    clearTimeout(this.timeoutId);
    
    this.timeoutId = setTimeout(() => {
      this.callback(event.target.value);
    }, this.delay);
  }
  
  destroy() {
    clearTimeout(this.timeoutId);
    this.input.removeEventListener("input", this.handleInput);
  }
}

// 滚动事件节流
class ScrollHandler {
  constructor(callback, limit = 100) {
    this.callback = callback;
    this.limit = limit;
    this.lastRun = 0;
    this.handleScroll = this.throttle.bind(this);
    
    window.addEventListener("scroll", this.handleScroll);
  }
  
  throttle() {
    const now = Date.now();
    if (now - this.lastRun >= this.limit) {
      this.callback();
      this.lastRun = now;
    }
  }
  
  destroy() {
    window.removeEventListener("scroll", this.handleScroll);
  }
}

// 4. 虚拟滚动（处理大量数据）
class VirtualScroll {
  constructor(container, items, itemHeight, visibleCount) {
    this.container = container;
    this.items = items;
    this.itemHeight = itemHeight;
    this.visibleCount = visibleCount;
    this.startIndex = 0;
    
    this.container.style.height = `${visibleCount * itemHeight}px`;
    this.container.style.overflow = "auto";
    
    this.render();
    this.bindEvents();
  }
  
  render() {
    const endIndex = Math.min(
      this.startIndex + this.visibleCount,
      this.items.length
    );
    
    const visibleItems = this.items.slice(this.startIndex, endIndex);
    
    this.container.innerHTML = `
      <div style="height: ${this.startIndex * this.itemHeight}px"></div>
      ${visibleItems.map(item => `
        <div style="height: ${this.itemHeight}px; border-bottom: 1px solid #ccc">
          ${item}
        </div>
      `).join("")}
      <div style="height: ${(this.items.length - endIndex) * this.itemHeight}px"></div>
    `;
  }
  
  bindEvents() {
    this.container.addEventListener("scroll", () => {
      const scrollTop = this.container.scrollTop;
      this.startIndex = Math.floor(scrollTop / this.itemHeight);
      this.render();
    });
  }
}

// 使用虚拟滚动处理10000条数据
const largeData = Array(10000).fill().map((_, i) => `Item ${i + 1}`);
const virtualScroll = new VirtualScroll(
  document.getElementById("virtual-list"),
  largeData,
  30, // 每项高度30px
  20  // 可见20项
);
```

### 5.2 代码质量与最佳实践

#### 5.2.1 代码组织
```javascript
// 模块化设计
// utils.js
export const formatDate = (date) => {
  return new Intl.DateTimeFormat("en-US").format(date);
};

export const debounce = (fn, delay) => {
  let timeoutId;
  return (...args) => {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => fn.apply(null, args), delay);
  };
};

// api.js
import { debounce } from "./utils.js";

class ApiClient {
  constructor(baseURL) {
    this.baseURL = baseURL;
    this.cache = new Map();
  }
  
  async request(endpoint, options = {}) {
    const url = `${this.baseURL}${endpoint}`;
    const cacheKey = `${url}:${JSON.stringify(options)}`;
    
    if (this.cache.has(cacheKey)) {
      return this.cache.get(cacheKey);
    }
    
    try {
      const response = await fetch(url, options);
      const data = await response.json();
      
      this.cache.set(cacheKey, data);
      return data;
    } catch (error) {
      console.error("API request failed:", error);
      throw error;
    }
  }
  
  // 防抖的搜索方法
  search = debounce(async function(query) {
    return this.request(`/search?q=${encodeURIComponent(query)}`);
  }, 300);
}

// 使用示例
const api = new ApiClient("https://api.example.com");

// 单一职责原则
class UserValidator {
  static validateEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  }
  
  static validatePassword(password) {
    return password.length >= 8 && /[A-Z]/.test(password) && /[0-9]/.test(password);
  }
  
  static validateAge(age) {
    return Number.isInteger(age) && age >= 0 && age <= 150;
  }
}

class UserRepository {
  constructor(database) {
    this.db = database;
  }
  
  async save(user) {
    if (!UserValidator.validateEmail(user.email)) {
      throw new Error("Invalid email");
    }
    
    if (!UserValidator.validatePassword(user.password)) {
      throw new Error("Invalid password");
    }
    
    return this.db.users.save(user);
  }
  
  async findById(id) {
    return this.db.users.findById(id);
  }
  
  async findByEmail(email) {
    return this.db.users.findOne({ email });
  }
}

// 开闭原则：对扩展开放，对修改关闭
class PaymentProcessor {
  constructor(paymentMethods) {
    this.paymentMethods = paymentMethods;
  }
  
  async processPayment(paymentMethod, amount) {
    const processor = this.paymentMethods[paymentMethod.type];
    if (!processor) {
      throw new Error(`Unsupported payment method: ${paymentMethod.type}`);
    }
    
    return processor.process(amount, paymentMethod);
  }
  
  addPaymentMethod(type, processor) {
    this.paymentMethods[type] = processor;
  }
}

// 依赖注入
class UserService {
  constructor(userRepository, emailService, logger) {
    this.userRepository = userRepository;
    this.emailService = emailService;
    this.logger = logger;
  }
  
  async registerUser(userData) {
    try {
      const user = await this.userRepository.save(userData);
      await this.emailService.sendWelcomeEmail(user.email);
      this.logger.info("User registered successfully", { userId: user.id });
      return user;
    } catch (error) {
      this.logger.error("User registration failed", { error: error.message });
      throw error;
    }
  }
}

// 工厂模式创建服务实例
class ServiceFactory {
  static createUserService() {
    const db = new Database();
    const emailService = new EmailService();
    const logger = new Logger();
    const userRepository = new UserRepository(db);
    
    return new UserService(userRepository, emailService, logger);
  }
}
```

#### 5.2.2 错误处理与调试
```javascript
// 自定义错误类
class ValidationError extends Error {
  constructor(message, field) {
    super(message);
    this.name = "ValidationError";
    this.field = field;
  }
}

class NetworkError extends Error {
  constructor(message, statusCode) {
    super(message);
    this.name = "NetworkError";
    this.statusCode = statusCode;
  }
}

// 错误处理中间件
class ErrorHandler {
  static handle(error, req, res, next) {
    if (error instanceof ValidationError) {
      return res.status(400).json({
        error: "Validation Error",
        message: error.message,
        field: error.field
      });
    }
    
    if (error instanceof NetworkError) {
      return res.status(error.statusCode).json({
        error: "Network Error",
        message: error.message
      });
    }
    
    // 未知错误
    console.error("Unhandled error:", error);
    return res.status(500).json({
      error: "Internal Server Error",
      message: "Something went wrong"
    });
  }
}

// 重试机制
class RetryManager {
  static async execute(fn, options = {}) {
    const {
      maxAttempts = 3,
      delay = 1000,
      backoff = 2,
      shouldRetry = (error) => true
    } = options;
    
    let lastError;
    let currentDelay = delay;
    
    for (let attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        return await fn();
      } catch (error) {
        lastError = error;
        
        if (attempt === maxAttempts || !shouldRetry(error)) {
          throw error;
        }
        
        console.warn(`Attempt ${attempt} failed, retrying in ${currentDelay}ms...`);
        await new Promise(resolve => setTimeout(resolve, currentDelay));
        currentDelay *= backoff;
      }
    }
    
    throw lastError;
  }
}

// 断路器模式
class CircuitBreaker {
  constructor(fn, options = {}) {
    this.fn = fn;
    this.failureThreshold = options.failureThreshold || 5;
    this.resetTimeout = options.resetTimeout || 60000;
    this.state = "CLOSED"; // CLOSED, OPEN, HALF_OPEN
    this.failureCount = 0;
    this.nextAttempt = Date.now();
  }
  
  async execute(...args) {
    if (this.state === "OPEN") {
      if (Date.now() < this.nextAttempt) {
        throw new Error("Circuit breaker is OPEN");
      }
      this.state = "HALF_OPEN";
    }
    
    try {
      const result = await this.fn(...args);
      this.onSuccess();
      return result;
    } catch (error) {
      this.onFailure();
      throw error;
    }
  }
  
  onSuccess() {
    this.failureCount = 0;
    this.state = "CLOSED";
  }
  
  onFailure() {
    this.failureCount++;
    if (this.failureCount >= this.failureThreshold) {
      this.state = "OPEN";
      this.nextAttempt = Date.now() + this.resetTimeout;
    }
  }
}

// 日志系统
class Logger {
  constructor(level = "info") {
    this.level = level;
    this.levels = {
      debug: 0,
      info: 1,
      warn: 2,
      error: 3
    };
  }
  
  log(level, message, meta = {}) {
    if (this.levels[level] < this.levels[this.level]) {
      return;
    }
    
    const logEntry = {
      timestamp: new Date().toISOString(),
      level: level.toUpperCase(),
      message,
      ...meta
    };
    
    console.log(JSON.stringify(logEntry, null, 2));
  }
  
  debug(message, meta) {
    this.log("debug", message, meta);
  }
  
  info(message, meta) {
    this.log("info", message, meta);
  }
  
  warn(message, meta) {
    this.log("warn", message, meta);
  }
  
  error(message, meta) {
    this.log("error", message, meta);
  }
}

// 性能监控
class PerformanceMonitor {
  static measure(name, fn) {
    return async function(...args) {
      const start = performance.now();
      try {
        const result = await fn.apply(this, args);
        const duration = performance.now() - start;
        console.log(`${name} took ${duration.toFixed(2)}ms`);
        return result;
      } catch (error) {
        const duration = performance.now() - start;
        console.error(`${name} failed after ${duration.toFixed(2)}ms:`, error);
        throw error;
      }
    };
  }
  
  static memoryUsage() {
    const usage = process.memoryUsage();
    return {
      rss: Math.round(usage.rss / 1024 / 1024 * 100) / 100,
      heapTotal: Math.round(usage.heapTotal / 1024 / 1024 * 100) / 100,
      heapUsed: Math.round(usage.heapUsed / 1024 / 1024 * 100) / 100,
      external: Math.round(usage.external / 1024 / 1024 * 100) / 100
    };
  }
}

// 使用示例
const monitoredFunction = PerformanceMonitor.measure("API Call", async function() {
  // 模拟API调用
  await new Promise(resolve => setTimeout(resolve, 1000));
  return "API response";
});

// 调试工具
class DebugUtils {
  static trace(fn) {
    return function(...args) {
      console.log(`Calling ${fn.name} with:`, args);
      const result = fn.apply(this, args);
      console.log(`${fn.name} returned:`, result);
      return result;
    };
  }
  
  static time(name) {
    console.time(name);
    return () => console.timeEnd(name);
  }
  
  static inspect(obj) {
    return JSON.stringify(obj, null, 2);
  }
}
```

## 6. 总结

JavaScript高级编程涵盖了语言的深层次特性和最佳实践。通过掌握这些高级概念，开发者可以编写更高效、更可维护的代码。

### 6.1 核心概念回顾
1. **类型系统**: 深入理解JavaScript的类型转换和类型检查机制
2. **函数特性**: 掌握闭包、高阶函数、柯里化等函数式编程概念
3. **面向对象**: 理解原型链、ES6类语法和设计模式
4. **异步编程**: 熟练使用Promise、async/await处理异步操作
5. **性能优化**: 学习内存管理、执行效率优化技巧
6. **代码质量**: 采用模块化、错误处理、调试等最佳实践

### 6.2 学习建议
1. **循序渐进**: 从基础概念开始，逐步深入高级特性
2. **实践为主**: 多写代码，在实际项目中应用所学知识
3. **阅读源码**: 学习优秀开源项目的代码实现
4. **持续学习**: 跟上ECMAScript标准的最新发展
5. **性能意识**: 在开发中始终考虑性能和用户体验

### 6.3 进阶方向
1. **框架深入**: 深入学习React、Vue、Angular等现代框架
2. **Node.js**: 掌握服务端JavaScript开发
3. **TypeScript**: 学习类型安全的JavaScript超集
4. **WebAssembly**: 探索高性能Web应用开发
5. **工具链**: 掌握构建工具、测试工具、部署工具

JavaScript作为一门动态语言，具有强大的灵活性和表达能力。通过系统学习和不断实践，开发者可以充分发挥JavaScript的潜力，构建出色的Web应用。
