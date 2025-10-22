# Vue 3 学习笔记

## Composition API

Vue 3 引入了 Composition API，提供了更灵活的代码组织方式。

### setup 函数

```vue
<script setup>
import { ref, computed } from 'vue'

const count = ref(0)
const doubleCount = computed(() => count.value * 2)

function increment() {
  count.value++
}
</script>
```

### 响应式 API

- `ref()`: 创建响应式引用
- `reactive()`: 创建响应式对象
- `computed()`: 计算属性
- `watch()`: 监听器

## 组件通信

### Props

```javascript
defineProps({
  title: String,
  count: Number
})
```

### Emits

```javascript
const emit = defineEmits(['update', 'delete'])

function handleClick() {
  emit('update', data)
}
```

## 生命周期

- `onMounted()`: 组件挂载后
- `onUpdated()`: 组件更新后
- `onUnmounted()`: 组件卸载前

## 性能优化

1. 使用 `v-memo` 缓存模板
2. 使用 `<Suspense>` 处理异步组件
3. 按需导入组件和函数
