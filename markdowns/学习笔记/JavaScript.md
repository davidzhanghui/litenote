# JavaScript 高级特性

## ES6+ 新特性

### 箭头函数

```javascript
const add = (a, b) => a + b
const square = x => x * x
```

### 解构赋值

```javascript
// 数组解构
const [first, second, ...rest] = [1, 2, 3, 4, 5]

// 对象解构
const { name, age } = { name: 'Alice', age: 25 }
```

### 模板字符串

```javascript
const name = 'World'
const greeting = `Hello, ${name}!`
```

## Promise 和 async/await

### Promise

```javascript
fetch('/api/data')
  .then(response => response.json())
  .then(data => console.log(data))
  .catch(error => console.error(error))
```

### async/await

```javascript
async function fetchData() {
  try {
    const response = await fetch('/api/data')
    const data = await response.json()
    return data
  } catch (error) {
    console.error(error)
  }
}
```

## 高阶函数

```javascript
// map
const doubled = [1, 2, 3].map(x => x * 2)

// filter
const evens = [1, 2, 3, 4].filter(x => x % 2 === 0)

// reduce
const sum = [1, 2, 3, 4].reduce((acc, x) => acc + x, 0)
```

## 模块化

```javascript
// 导出
export const PI = 3.14159
export function add(a, b) {
  return a + b
}

// 导入
import { PI, add } from './math.js'
```
