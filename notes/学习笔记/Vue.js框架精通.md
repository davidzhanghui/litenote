# Vue.js框架精通学习笔记

## 1. Vue.js核心概念深入

### 1.1 响应式系统原理

#### 1.1.1 响应式数据基础
Vue.js的响应式系统是其最核心的特性，通过数据劫持和依赖收集实现数据变化时视图的自动更新。

```javascript
// Vue 2.x 响应式原理（简化版）
class Dep {
  constructor() {
    this.id = uid++;
    this.subs = [];
  }
  
  addSub(sub) {
    this.subs.push(sub);
  }
  
  removeSub(sub) {
    remove(this.subs, sub);
  }
  
  depend() {
    if (window.target) {
      window.target.addDep(this);
    }
  }
  
  notify() {
    const subs = this.subs.slice();
    subs.forEach(sub => {
      sub.update();
    });
  }
}

class Watcher {
  constructor(vm, expOrFn, cb, options) {
    this.vm = vm;
    this.cb = cb;
    this.deps = [];
    this.newDeps = [];
    this.depIds = new Set();
    this.newDepIds = new Set();
    
    if (options) {
      this.lazy = !!options.lazy;
    } else {
      this.lazy = false;
    }
    
    this.dirty = this.lazy;
    this.value = this.lazy ? undefined : this.get();
  }
  
  get() {
    pushTarget(this);
    let value;
    const vm = this.vm;
    
    try {
      value = this.getter.call(vm, vm);
    } catch (e) {
      if (this.user) {
        handleError(e, vm, `getter for watcher "${this.expression}"`);
      } else {
        throw e;
      }
    } finally {
      popTarget();
      this.cleanupDeps();
    }
    
    return value;
  }
  
  addDep(dep) {
    const id = dep.id;
    if (!this.newDepIds.has(id)) {
      this.newDepIds.add(id);
      this.newDeps.push(dep);
      if (!this.depIds.has(id)) {
        dep.addSub(this);
      }
    }
  }
  
  update() {
    if (this.lazy) {
      this.dirty = true;
    } else if (this.sync) {
      this.run();
    } else {
      queueWatcher(this);
    }
  }
  
  run() {
    if (this.active) {
      const value = this.get();
      if (value !== this.value || isObject(value) || this.deep) {
        const oldValue = this.value;
        this.value = value;
        if (this.user) {
          try {
            this.cb.call(this.vm, value, oldValue);
          } catch (e) {
            handleError(e, this.vm, `callback for watcher "${this.expression}"`);
          }
        } else {
          this.cb.call(this.vm, value, oldValue);
        }
      }
    }
  }
}

// Vue 3.x 响应式原理（Proxy实现）
const reactiveMap = new WeakMap();
const shallowReactiveMap = new WeakMap();
const readonlyMap = new WeakMap();
const shallowReadonlyMap = new WeakMap();

function reactive(target) {
  if (target && target.__v_isReactive) {
    return target;
  }
  
  return createReactiveObject(
    target,
    false,
    mutableHandlers,
    mutableCollectionHandlers,
    reactiveMap
  );
}

function createReactiveObject(target, isReadonly, baseHandlers, collectionHandlers, proxyMap) {
  if (!isObject(target)) {
    return target;
  }
  
  if (target.__v_raw && !(isReadonly && target.__v_isReactive)) {
    return target;
  }
  
  const existingProxy = proxyMap.get(target);
  if (existingProxy) {
    return existingProxy;
  }
  
  const targetType = getTargetType(target);
  if (targetType === 0 /* TargetType.INVALID */) {
    return target;
  }
  
  const proxy = new Proxy(
    target,
    targetType === 2 /* TargetType.COLLECTION */ ? collectionHandlers : baseHandlers
  );
  
  proxyMap.set(target, proxy);
  return proxy;
}

const mutableHandlers = {
  get,
  set,
  deleteProperty,
  has,
  ownKeys
};

function get(target, key, receiver) {
  if (key === "__v_isReactive" /* IS_REACTIVE */) {
    return true;
  } else if (key === "__v_isReadonly" /* IS_READONLY */) {
    return false;
  } else if (key === "__v_raw" /* RAW */) {
    return target;
  }
  
  const targetIsArray = isArray(target);
  if (!isReadonly && targetIsArray && hasOwn(arrayInstrumentations, key)) {
    return Reflect.get(arrayInstrumentations, key, receiver);
  }
  
  const res = Reflect.get(target, key, receiver);
  
  if (isSymbol(key) ? builtInSymbols.has(key) : isNonTrackableKeys(key)) {
    return res;
  }
  
  if (!isReadonly) {
    track(target, "get" /* GET */, key);
  }
  
  if (shallow) {
    return res;
  }
  
  if (isRef(res)) {
    return res.value;
  }
  
  if (isObject(res)) {
    return isReadonly ? readonly(res) : reactive(res);
  }
  
  return res;
}

function set(target, key, value, receiver) {
  let oldValue = target[key];
  const hadKey = hasOwn(target, key);
  const result = Reflect.set(target, key, value, receiver);
  
  if (target === toRaw(receiver)) {
    if (!hadKey) {
      trigger(target, "add" /* ADD */, key, value);
    } else if (hasChanged(value, oldValue)) {
      trigger(target, "set" /* SET */, key, value, oldValue);
    }
  }
  
  return result;
}
```

#### 1.1.2 依赖收集和派发更新
```javascript
// Vue 3.x 依赖收集
let activeEffect = null;
const targetMap = new WeakMap();

function track(target, type, key) {
  if (!activeEffect) {
    return;
  }
  
  let depsMap = targetMap.get(target);
  if (!depsMap) {
    targetMap.set(target, (depsMap = new Map()));
  }
  
  let dep = depsMap.get(key);
  if (!dep) {
    depsMap.set(key, (dep = new Set()));
  }
  
  if (!dep.has(activeEffect)) {
    dep.add(activeEffect);
    activeEffect.deps.push(dep);
  }
}

function trigger(target, type, key, newValue, oldValue) {
  const depsMap = targetMap.get(target);
  if (!depsMap) {
    return;
  }
  
  const effects = new Set();
  
  const add = (effectsToAdd) => {
    if (effectsToAdd) {
      effectsToAdd.forEach(effect => {
        if (effect !== activeEffect) {
          effects.add(effect);
        }
      });
    }
  };
  
  if (key !== undefined) {
    add(depsMap.get(key));
  }
  
  if (type === "add" /* ADD */) {
    if (!isArray(target)) {
      add(depsMap.get(ITERATE_KEY));
      if (isMap(target)) {
        add(depsMap.get(MAP_KEY_ITERATE_KEY));
      }
    } else if (isIntegerKey(key)) {
      add(depsMap.get("length" /* LENGTH */));
    }
  } else if (type === "delete" /* DELETE */) {
    if (!isArray(target)) {
      add(depsMap.get(ITERATE_KEY));
      if (isMap(target)) {
        add(depsMap.get(MAP_KEY_ITERATE_KEY));
      }
    }
  } else if (type === "set" /* SET */) {
    if (isMap(target)) {
      add(depsMap.get(ITERATE_KEY));
    }
  }
  
  const run = (effect) => {
    if (effect.options.scheduler) {
      effect.options.scheduler(effect);
    } else {
      effect();
    }
  };
  
  effects.forEach(run);
}

// Effect 函数
function effect(fn, options = {}) {
  if (isEffect(fn)) {
    fn = fn.raw;
  }
  
  const effect = createReactiveEffect(fn, options);
  
  if (!options.lazy) {
    effect();
  }
  
  return effect;
}

function createReactiveEffect(fn, options) {
  const effect = function reactiveEffect() {
    if (!effect.active) {
      return fn();
    }
    
    if (!effect.stack.includes(effect)) {
      cleanup(effect);
      try {
        enableTracking();
        effect.stack.push(effect);
        activeEffect = effect;
        return fn();
      } finally {
        effect.stack.pop();
        activeEffect = effect.stack[effect.stack.length - 1];
        resetTracking();
      }
    }
  };
  
  effect.id = uid++;
  effect.allowRecurse = !!options.allowRecurse;
  effect._isEffect = true;
  effect.active = true;
  effect.raw = fn;
  effect.deps = [];
  effect.options = options;
  
  return effect;
}

// 计算属性
class ComputedRefImpl {
  constructor(getter, setter) {
    this._dirty = true;
    this._value = undefined;
    this._setter = setter;
    
    this.effect = effect(getter, {
      lazy: true,
      scheduler: () => {
        if (!this._dirty) {
          this._dirty = true;
          trigger(toRaw(this), "set" /* SET */, "value");
        }
      }
    });
  }
  
  get value() {
    if (this._dirty) {
      this._dirty = false;
      this._value = this.effect();
    }
    track(toRaw(this), "get" /* GET */, "value");
    return this._value;
  }
  
  set value(newValue) {
    this._setter(newValue);
  }
}

function computed(getterOrOptions) {
  let getter, setter;
  
  if (isFunction(getterOrOptions)) {
    getter = getterOrOptions;
    setter = NOOP;
  } else {
    getter = getterOrOptions.get;
    setter = getterOrOptions.set;
  }
  
  return new ComputedRefImpl(getter, setter);
}
```

### 1.2 组件系统深入

#### 1.2.1 组件生命周期
Vue组件的生命周期钩子提供了在组件不同阶段执行代码的能力。

```javascript
// Vue 3.x 组合式API生命周期
import { ref, onMounted, onUpdated, onUnmounted, onBeforeMount, onBeforeUpdate, onBeforeUnmount } from 'vue';

export default {
  setup() {
    const count = ref(0);
    
    // 组件实例被创建之后
    onBeforeMount(() => {
      console.log('组件即将挂载');
    });
    
    // 组件挂载到DOM之后
    onMounted(() => {
      console.log('组件已挂载');
      console.log('DOM元素:', document.querySelector('.component'));
    });
    
    // 组件更新之前
    onBeforeUpdate(() => {
      console.log('组件即将更新');
    });
    
    // 组件更新之后
    onUpdated(() => {
      console.log('组件已更新');
    });
    
    // 组件卸载之前
    onBeforeUnmount(() => {
      console.log('组件即将卸载');
    });
    
    // 组件卸载之后
    onUnmounted(() => {
      console.log('组件已卸载');
    });
    
    // 错误捕获
    onErrorCaptured((err, instance, info) => {
      console.error('捕获到错误:', err);
      console.error('组件实例:', instance);
      console.error('错误信息:', info);
      return false; // 阻止错误继续向上传播
    });
    
    return { count };
  }
};

// 自定义生命周期钩子
function useCustomLifecycle() {
  const lifecycle = ref('created');
  
  onMounted(() => {
    lifecycle.value = 'mounted';
  });
  
  onBeforeUnmount(() => {
    lifecycle.value = 'beforeUnmount';
  });
  
  return { lifecycle };
}

// 生命周期调试工具
function useLifecycleDebug(componentName) {
  const hooks = [
    'onBeforeMount',
    'onMounted', 
    'onBeforeUpdate',
    'onUpdated',
    'onBeforeUnmount',
    'onUnmounted'
  ];
  
  hooks.forEach(hookName => {
    const hook = eval(hookName);
    hook(() => {
      console.log(`[${componentName}] ${hookName} called`);
    });
  });
}
```

#### 1.2.2 组件通信模式
```javascript
// 父子组件通信
// 父组件
<template>
  <ChildComponent 
    :message="parentMessage"
    :user="user"
    @update:message="handleMessageUpdate"
    @child-event="handleChildEvent"
  />
</template>

<script>
import { ref, reactive } from 'vue';
import ChildComponent from './ChildComponent.vue';

export default {
  components: { ChildComponent },
  setup() {
    const parentMessage = ref('Hello from parent');
    const user = reactive({ name: 'John', age: 30 });
    
    const handleMessageUpdate = (newMessage) => {
      parentMessage.value = newMessage;
    };
    
    const handleChildEvent = (data) => {
      console.log('Received event from child:', data);
    };
    
    return {
      parentMessage,
      user,
      handleMessageUpdate,
      handleChildEvent
    };
  }
};
</script>

// 子组件
<template>
  <div>
    <p>Parent message: {{ message }}</p>
    <p>User: {{ user.name }} ({{ user.age }})</p>
    <button @click="updateMessage">Update Message</button>
    <button @click="emitEvent">Emit Event</button>
  </div>
</template>

<script>
export default {
  props: {
    message: String,
    user: Object
  },
  emits: ['update:message', 'child-event'],
  setup(props, { emit }) {
    const updateMessage = () => {
      emit('update:message', 'Hello from child');
    };
    
    const emitEvent = () => {
      emit('child-event', { type: 'click', timestamp: Date.now() });
    };
    
    return { updateMessage, emitEvent };
  }
};
</script>

// Provide/Inject 跨层级通信
// 祖先组件
import { provide, ref, reactive } from 'vue';

export default {
  setup() {
    const theme = ref('light');
    const user = reactive({ name: 'John', role: 'admin' });
    
    // 提供响应式数据
    provide('theme', theme);
    provide('user', user);
    
    // 提供方法
    provide('updateTheme', (newTheme) => {
      theme.value = newTheme;
    });
    
    return { theme };
  }
};

// 后代组件
import { inject } from 'vue';

export default {
  setup() {
    const theme = inject('theme');
    const user = inject('user');
    const updateTheme = inject('updateTheme');
    
    // 提供默认值
    const config = inject('config', { api: 'default', debug: false });
    
    return { theme, user, updateTheme, config };
  }
};

// 状态管理 (类似Vuex的简单实现)
import { reactive, computed, provide, inject } from 'vue';

const StoreSymbol = Symbol('store');

export function createStore(options) {
  const state = reactive(options.state || {});
  const getters = {};
  const mutations = {};
  const actions = {};
  
  // 处理getters
  if (options.getters) {
    Object.keys(options.getters).forEach(key => {
      getters[key] = computed(() => options.getters[key](state));
    });
  }
  
  // 处理mutations
  if (options.mutations) {
    Object.keys(options.mutations).forEach(key => {
      mutations[key] = (payload) => options.mutations[key](state, payload);
    });
  }
  
  // 处理actions
  if (options.actions) {
    Object.keys(options.actions).forEach(key => {
      actions[key] = (payload) => options.actions[key](
        { state, getters, commit, dispatch },
        payload
      );
    });
  }
  
  function commit(mutationName, payload) {
    if (mutations[mutationName]) {
      mutations[mutationName](payload);
    }
  }
  
  function dispatch(actionName, payload) {
    if (actions[actionName]) {
      return actions[actionName](payload);
    }
  }
  
  const store = {
    state,
    getters,
    commit,
    dispatch
  };
  
  return store;
}

export function provideStore(store) {
  provide(StoreSymbol, store);
}

export function useStore() {
  const store = inject(StoreSymbol);
  if (!store) {
    throw new Error('Store not provided');
  }
  return store;
}
```

## 2. Vue 3 Composition API深入

### 2.1 响应式API详解

#### 2.1.1 ref和reactive的使用
```javascript
import { ref, reactive, toRef, toRefs, unref, isRef, shallowRef, triggerRef } from 'vue';

// ref - 创建响应式引用
const count = ref(0);
const message = ref('Hello Vue');

// 访问和修改
console.log(count.value); // 0
count.value = 1;

// 在模板中自动解包
// <template>{{ count }}</template> // 不需要 .value

// reactive - 创建响应式对象
const state = reactive({
  count: 0,
  user: {
    name: 'John',
    age: 30
  }
});

// 直接访问属性
console.log(state.count); // 0
state.count = 1;

// toRef - 创建对象的响应式引用
const userCount = toRef(state, 'count');
console.log(userCount.value); // 0

// toRefs - 解构响应式对象
const { count, user } = toRefs(state);
console.log(count.value); // 0

// unref - 获取ref或普通值的值
function getValue(param) {
  return unref(param); // 如果是ref返回.value，否则返回原值
}

// isRef - 检查是否为ref
if (isRef(count)) {
  console.log('count is a ref');
}

// shallowRef - 浅层响应式
const shallowState = shallowRef({ count: 0 });
shallowState.value.count = 1; // 不会触发更新
shallowState.value = { count: 1 }; // 会触发更新

// triggerRef - 手动触发shallowRef更新
triggerRef(shallowState);

// customRef - 自定义ref
function useDebouncedRef(value, delay = 200) {
  let timeout;
  return customRef((track, trigger) => ({
    get() {
      track(); // 追踪依赖
      return value;
    },
    set(newValue) {
      clearTimeout(timeout);
      timeout = setTimeout(() => {
        value = newValue;
        trigger(); // 触发更新
      }, delay);
    }
  }));
}

const debouncedText = useDebouncedRef('hello');

// readonly - 创建只读代理
const original = reactive({ count: 0 });
const copy = readonly(original);

// copy.count = 1; // 警告：不能修改只读对象
```

#### 2.1.2 computed和watch
```javascript
import { ref, computed, watch, watchEffect, watchPostEffect, watchSyncEffect } from 'vue';

// computed - 计算属性
const count = ref(1);
const doubled = computed(() => count.value * 2);

// 可写的计算属性
const writableComputed = computed({
  get() {
    return count.value * 2;
  },
  set(newValue) {
    count.value = newValue / 2;
  }
});

writableComputed.value = 4; // count.value 变为 2

// 计算属性缓存
const expensiveComputed = computed(() => {
  console.log('Computing expensive value...');
  return heavyCalculation();
});

// watch - 监听器
const message = ref('Hello');
const user = reactive({ name: 'John', age: 30 });

// 监听单个ref
watch(message, (newValue, oldValue) => {
  console.log(`Message changed from ${oldValue} to ${newValue}`);
});

// 监听响应式对象
watch(
  () => user.age,
  (newAge, oldAge) => {
    console.log(`Age changed from ${oldAge} to ${newAge}`);
  }
);

// 监听多个源
watch(
  [count, () => user.name],
  ([newCount, newName], [oldCount, oldName]) => {
    console.log('Multiple values changed');
  }
);

// 深度监听
watch(
  user,
  (newValue, oldValue) => {
    console.log('User object changed');
  },
  { deep: true }
);

// 立即执行
watch(
  count,
  (value) => {
    console.log(`Count is ${value}`);
  },
  { immediate: true }
);

// watchEffect - 自动收集依赖的监听器
watchEffect(() => {
  console.log(`Count: ${count.value}, Name: ${user.name}`);
});

// watchPostEffect - 在DOM更新后执行
watchPostEffect(() => {
  console.log('DOM updated, new count:', count.value);
});

// watchSyncEffect - 同步执行
watchSyncEffect(() => {
  console.log('Sync effect, count:', count.value);
});

// 停止监听
const stopWatcher = watch(count, (value) => {
  console.log('Count changed:', value);
});

// 稍后停止监听
stopWatcher();

// 清理副作用
watch(
  count,
  (value, oldValue, onCleanup) => {
    const timer = setTimeout(() => {
      console.log('Delayed effect:', value);
    }, 1000);
    
    onCleanup(() => {
      clearTimeout(timer); // 清理定时器
    });
  }
);

// 自定义监听器Hook
function useWatchWithHistory(source, initialValue) {
  const history = ref([initialValue]);
  
  watch(
    source,
    (newValue) => {
      history.value.push(newValue);
      // 限制历史记录长度
      if (history.value.length > 10) {
        history.value.shift();
      }
    }
  );
  
  return { history };
}

const { history } = useWatchWithHistory(count, 0);
```

### 2.2 组合式函数(Composables)

#### 2.2.1 自定义Hook编写
```javascript
// useCounter.js - 计数器Hook
import { ref, computed } from 'vue';

export function useCounter(initialValue = 0) {
  const count = ref(initialValue);
  
  const doubled = computed(() => count.value * 2);
  const tripled = computed(() => count.value * 3);
  
  const increment = () => count.value++;
  const decrement = () => count.value--;
  const reset = () => count.value = initialValue;
  const setValue = (value) => count.value = value;
  
  return {
    count,
    doubled,
    tripled,
    increment,
    decrement,
    reset,
    setValue
  };
}

// useLocalStorage.js - 本地存储Hook
import { ref, watch, onMounted } from 'vue';

export function useLocalStorage(key, defaultValue) {
  const storedValue = ref(defaultValue);
  
  // 组件挂载时从localStorage读取
  onMounted(() => {
    try {
      const item = window.localStorage.getItem(key);
      if (item) {
        storedValue.value = JSON.parse(item);
      }
    } catch (error) {
      console.error('Error reading localStorage:', error);
    }
  });
  
  // 监听值变化并保存到localStorage
  watch(
    storedValue,
    (newValue) => {
      try {
        window.localStorage.setItem(key, JSON.stringify(newValue));
      } catch (error) {
        console.error('Error writing to localStorage:', error);
      }
    },
    { deep: true }
  );
  
  return storedValue;
}

// useFetch.js - 数据获取Hook
import { ref, onMounted, onUnmounted } from 'vue';

export function useFetch(url, options = {}) {
  const data = ref(null);
  const error = ref(null);
  const loading = ref(false);
  
  let controller = null;
  
  const fetchData = async () => {
    loading.value = true;
    error.value = null;
    
    try {
      controller = new AbortController();
      const response = await fetch(url, {
        ...options,
        signal: controller.signal
      });
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      
      data.value = await response.json();
    } catch (err) {
      if (err.name !== 'AbortError') {
        error.value = err.message;
      }
    } finally {
      loading.value = false;
    }
  };
  
  onMounted(fetchData);
  
  onUnmounted(() => {
    if (controller) {
      controller.abort();
    }
  });
  
  return {
    data,
    error,
    loading,
    refetch: fetchData
  };
}

// useDebounce.js - 防抖Hook
import { ref, watch } from 'vue';

export function useDebounce(value, delay = 300) {
  const debouncedValue = ref(value.value);
  
  let timeoutId = null;
  
  watch(
    value,
    (newValue) => {
      clearTimeout(timeoutId);
      timeoutId = setTimeout(() => {
        debouncedValue.value = newValue;
      }, delay);
    },
    { immediate: true }
  );
  
  return debouncedValue;
}

// usePagination.js - 分页Hook
import { ref, computed } from 'vue';

export function usePagination(items, itemsPerPage = 10) {
  const currentPage = ref(1);
  
  const totalPages = computed(() => 
    Math.ceil(items.value.length / itemsPerPage)
  );
  
  const paginatedItems = computed(() => {
    const start = (currentPage.value - 1) * itemsPerPage;
    const end = start + itemsPerPage;
    return items.value.slice(start, end);
  });
  
  const nextPage = () => {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
    }
  };
  
  const prevPage = () => {
    if (currentPage.value > 1) {
      currentPage.value--;
    }
  };
  
  const goToPage = (page) => {
    if (page >= 1 && page <= totalPages.value) {
      currentPage.value = page;
    }
  };
  
  return {
    currentPage,
    totalPages,
    paginatedItems,
    nextPage,
    prevPage,
    goToPage
  };
}

// useValidation.js - 表单验证Hook
import { ref, computed } from 'vue';

export function useValidation(rules = {}) {
  const values = ref({});
  const errors = ref({});
  const touched = ref({});
  
  const setValue = (field, value) => {
    values.value[field] = value;
    validateField(field);
  };
  
  const setTouched = (field) => {
    touched.value[field] = true;
    validateField(field);
  };
  
  const validateField = (field) => {
    const fieldRules = rules[field];
    if (!fieldRules) return true;
    
    const fieldValue = values.value[field];
    const fieldErrors = [];
    
    for (const rule of fieldRules) {
      if (typeof rule === 'function') {
        const error = rule(fieldValue);
        if (error) {
          fieldErrors.push(error);
        }
      } else if (rule.required && (!fieldValue || fieldValue.toString().trim() === '')) {
        fieldErrors.push('This field is required');
      } else if (rule.min && fieldValue.length < rule.min) {
        fieldErrors.push(`Minimum length is ${rule.min}`);
      } else if (rule.max && fieldValue.length > rule.max) {
        fieldErrors.push(`Maximum length is ${rule.max}`);
      } else if (rule.pattern && !rule.pattern.test(fieldValue)) {
        fieldErrors.push(rule.message || 'Invalid format');
      }
    }
    
    if (fieldErrors.length > 0) {
      errors.value[field] = fieldErrors;
      return false;
    } else {
      delete errors.value[field];
      return true;
    }
  };
  
  const validateAll = () => {
    let isValid = true;
    Object.keys(rules).forEach(field => {
      if (!validateField(field)) {
        isValid = false;
      }
    });
    return isValid;
  };
  
  const isValid = computed(() => {
    return Object.keys(errors.value).length === 0;
  });
  
  const getFieldError = (field) => {
    return touched.value[field] ? errors.value[field] : [];
  };
  
  return {
    values,
    errors,
    touched,
    isValid,
    setValue,
    setTouched,
    validateField,
    validateAll,
    getFieldError
  };
}
```

#### 2.2.2 复杂状态管理
```javascript
// useStore.js - 简单状态管理
import { reactive, computed, provide, inject } from 'vue';

const StoreSymbol = Symbol('store');

export function createStore(initialState = {}) {
  const state = reactive(initialState);
  const mutations = {};
  const actions = {};
  const getters = {};
  
  // 注册mutation
  function registerMutation(name, handler) {
    mutations[name] = (payload) => {
      handler(state, payload);
    };
  }
  
  // 注册action
  function registerAction(name, handler) {
    actions[name] = async (payload) => {
      await handler({ state, commit, dispatch }, payload);
    };
  }
  
  // 注册getter
  function registerGetter(name, handler) {
    getters[name] = computed(() => handler(state));
  }
  
  // 提交mutation
  function commit(name, payload) {
    if (mutations[name]) {
      mutations[name](payload);
    }
  }
  
  // 分发action
  function dispatch(name, payload) {
    if (actions[name]) {
      return actions[name](payload);
    }
  }
  
  const store = {
    state,
    getters,
    commit,
    dispatch,
    registerMutation,
    registerAction,
    registerGetter
  };
  
  return store;
}

export function provideStore(store) {
  provide(StoreSymbol, store);
}

export function useStore() {
  const store = inject(StoreSymbol);
  if (!store) {
    throw new Error('Store not provided');
  }
  return store;
}

// 使用示例
const store = createStore({
  user: null,
  token: null,
  theme: 'light'
});

store.registerMutation('SET_USER', (state, user) => {
  state.user = user;
});

store.registerMutation('SET_TOKEN', (state, token) => {
  state.token = token;
});

store.registerAction('login', async ({ commit }, { username, password }) => {
  const response = await api.login(username, password);
  commit('SET_USER', response.user);
  commit('SET_TOKEN', response.token);
  return response;
});

store.registerGetter('isAuthenticated', (state) => {
  return !!state.token;
});

// useState.js - 状态管理Hook
import { reactive, computed, watch } from 'vue';

export function useState(initialState, reducers = {}) {
  const state = reactive(initialState);
  
  const actions = {};
  Object.keys(reducers).forEach(key => {
    actions[key] = (payload) => {
      reducers[key](state, payload);
    };
  });
  
  // 状态持久化
  const persistState = (key) => {
    const savedState = localStorage.getItem(key);
    if (savedState) {
      Object.assign(state, JSON.parse(savedState));
    }
    
    watch(
      state,
      (newState) => {
        localStorage.setItem(key, JSON.stringify(newState));
      },
      { deep: true }
    );
  };
  
  return {
    state,
    actions,
    persistState
  };
}

// useAsyncState.js - 异步状态管理
import { ref } from 'vue';

export function useAsyncState(asyncFn, initialState = null) {
  const state = ref(initialState);
  const loading = ref(false);
  const error = ref(null);
  
  const execute = async (...args) => {
    loading.value = true;
    error.value = null;
    
    try {
      const result = await asyncFn(...args);
      state.value = result;
      return result;
    } catch (err) {
      error.value = err;
      throw err;
    } finally {
      loading.value = false;
    }
  };
  
  return {
    state,
    loading,
    error,
    execute
  };
}

// useCache.js - 缓存Hook
import { ref } from 'vue';

export function useCache(ttl = 5 * 60 * 1000) { // 默认5分钟
  const cache = new Map();
  
  const set = (key, value) => {
    cache.set(key, {
      value,
      timestamp: Date.now()
    });
  };
  
  const get = (key) => {
    const item = cache.get(key);
    if (!item) return null;
    
    if (Date.now() - item.timestamp > ttl) {
      cache.delete(key);
      return null;
    }
    
    return item.value;
  };
  
  const has = (key) => {
    return get(key) !== null;
  };
  
  const clear = () => {
    cache.clear();
  };
  
  const deleteExpired = () => {
    const now = Date.now();
    for (const [key, item] of cache.entries()) {
      if (now - item.timestamp > ttl) {
        cache.delete(key);
      }
    }
  };
  
  return {
    set,
    get,
    has,
    clear,
    deleteExpired
  };
}
```

## 3. Vue Router深入应用

### 3.1 路由配置和导航

#### 3.1.1 高级路由配置
```javascript
// router/index.js
import { createRouter, createWebHistory } from 'vue-router';

const routes = [
  // 基础路由
  {
    path: '/',
    name: 'Home',
    component: () => import('@/views/Home.vue'),
    meta: {
      title: '首页',
      requiresAuth: false
    }
  },
  
  // 动态路由
  {
    path: '/user/:id',
    name: 'UserProfile',
    component: () => import('@/views/UserProfile.vue'),
    props: true, // 将路由参数作为props传递
    meta: {
      title: '用户资料',
      requiresAuth: true
    }
  },
  
  // 嵌套路由
  {
    path: '/admin',
    component: () => import('@/layouts/AdminLayout.vue'),
    meta: { requiresAuth: true, role: 'admin' },
    children: [
      {
        path: '',
        name: 'AdminDashboard',
        component: () => import('@/views/admin/Dashboard.vue')
      },
      {
        path: 'users',
        name: 'AdminUsers',
        component: () => import('@/views/admin/Users.vue')
      },
      {
        path: 'settings',
        name: 'AdminSettings',
        component: () => import('@/views/admin/Settings.vue')
      }
    ]
  },
  
  // 命名视图
  {
    path: '/app',
    component: () => import('@/layouts/AppLayout.vue'),
    children: [
      {
        path: '',
        components: {
          default: () => import('@/views/AppMain.vue'),
          sidebar: () => import('@/views/AppSidebar.vue'),
          header: () => import('@/views/AppHeader.vue')
        }
      }
    ]
  },
  
  // 重定向和别名
  {
    path: '/home',
    redirect: '/'
  },
  {
    path: '/index',
    alias: '/'
  },
  
  // 404页面
  {
    path: '/:pathMatch(.*)*',
    name: 'NotFound',
    component: () => import('@/views/NotFound.vue')
  }
];

const router = createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior(to, from, savedPosition) {
    if (savedPosition) {
      return savedPosition;
    } else if (to.hash) {
      return { el: to.hash };
    } else {
      return { top: 0 };
    }
  }
});

// 路由守卫
router.beforeEach(async (to, from, next) => {
  // 设置页面标题
  document.title = to.meta.title || 'Vue App';
  
  // 权限检查
  if (to.meta.requiresAuth) {
    const isAuthenticated = await checkAuth();
    if (!isAuthenticated) {
      next('/login');
      return;
    }
  }
  
  // 角色检查
  if (to.meta.role) {
    const user = await getCurrentUser();
    if (!user || user.role !== to.meta.role) {
      next('/403');
      return;
    }
  }
  
  next();
});

router.afterEach((to, from) => {
  // 页面访问统计
  analytics.trackPageView(to.path);
});

export default router;

// 路由权限控制
function createPermissionGuard(router) {
  router.beforeEach(async (to, from, next) => {
    const authStore = useAuthStore();
    
    // 检查是否需要认证
    if (to.meta.requiresAuth && !authStore.isAuthenticated) {
      next({
        path: '/login',
        query: { redirect: to.fullPath }
      });
      return;
    }
    
    // 检查角色权限
    if (to.meta.roles && !to.meta.roles.includes(authStore.user.role)) {
      next('/403');
      return;
    }
    
    // 动态路由权限
    if (to.meta.permission) {
      const hasPermission = await authStore.hasPermission(to.meta.permission);
      if (!hasPermission) {
        next('/403');
        return;
      }
    }
    
    next();
  });
}
```

#### 3.1.2 编程式导航和路由Hook
```javascript
// useNavigation.js - 导航Hook
import { useRouter, useRoute } from 'vue-router';
import { ref } from 'vue';

export function useNavigation() {
  const router = useRouter();
  const route = useRoute();
  const loading = ref(false);
  
  // 导航方法
  const navigateTo = (path, options = {}) => {
    loading.value = true;
    return router.push(path).finally(() => {
      loading.value = false;
    });
  };
  
  const replaceTo = (path) => {
    return router.replace(path);
  };
  
  const goBack = () => {
    router.back();
  };
  
  const goForward = () => {
    router.forward();
  };
  
  const go = (delta) => {
    router.go(delta);
  };
  
  // 带确认的导航
  const navigateWithConfirm = (path, message = '确定要离开当前页面吗？') => {
    return new Promise((resolve) => {
      if (confirm(message)) {
        navigateTo(path).then(resolve);
      }
    });
  };
  
  // 带保存的导航
  const navigateWithSave = async (path, saveFunction) => {
    try {
      await saveFunction();
      await navigateTo(path);
    } catch (error) {
      console.error('保存失败:', error);
    }
  };
  
  return {
    route,
    loading,
    navigateTo,
    replaceTo,
    goBack,
    goForward,
    go,
    navigateWithConfirm,
    navigateWithSave
  };
}

// useRouteQuery.js - 查询参数Hook
import { useRoute, useRouter } from 'vue-router';
import { computed, watch } from 'vue';

export function useRouteQuery(key, defaultValue = '') {
  const route = useRoute();
  const router = useRouter();
  
  const query = computed({
    get() {
      return route.query[key] || defaultValue;
    },
    set(value) {
      router.replace({
        query: {
          ...route.query,
          [key]: value
        }
      });
    }
  });
  
  return query;
}

// useRouteParams.js - 路由参数Hook
export function useRouteParams(key) {
  const route = useRoute();
  
  const param = computed(() => route.params[key]);
  
  return param;
}

// useBreadcrumb.js - 面包屑导航Hook
import { computed } from 'vue';

export function useBreadcrumb() {
  const route = useRoute();
  
  const breadcrumb = computed(() => {
    const matched = route.matched.filter(item => item.meta && item.meta.title);
    
    return matched.map((item, index) => ({
      title: item.meta.title,
      path: item.path,
      isLast: index === matched.length - 1
    }));
  });
  
  return { breadcrumb };
}

// 路由过渡动画
<template>
  <router-view v-slot="{ Component, route }">
    <transition :name="transitionName" mode="out-in">
      <component :is="Component" :key="route.path" />
    </transition>
  </router-view>
</template>

<script>
import { ref, watch } from 'vue';
import { useRoute } from 'vue-router';

export default {
  setup() {
    const route = useRoute();
    const transitionName = ref('slide-left');
    
    watch(
      () => route.path,
      (toPath, fromPath) => {
        const toDepth = toPath.split('/').length;
        const fromDepth = fromPath.split('/').length;
        
        transitionName.value = toDepth < fromDepth ? 'slide-right' : 'slide-left';
      }
    );
    
    return { transitionName };
  }
};
</script>

<style>
.slide-left-enter-active,
.slide-left-leave-active,
.slide-right-enter-active,
.slide-right-leave-active {
  transition: all 0.3s ease;
}

.slide-left-enter-from {
  transform: translateX(100%);
  opacity: 0;
}

.slide-left-leave-to {
  transform: translateX(-100%);
  opacity: 0;
}

.slide-right-enter-from {
  transform: translateX(-100%);
  opacity: 0;
}

.slide-right-leave-to {
  transform: translateX(100%);
  opacity: 0;
}
</style>
```

### 3.2 路由守卫和权限控制

#### 3.2.1 权限管理系统
```javascript
// auth.js - 认证服务
class AuthService {
  constructor() {
    this.token = localStorage.getItem('token');
    this.user = JSON.parse(localStorage.getItem('user') || 'null');
  }
  
  async login(credentials) {
    const response = await api.post('/auth/login', credentials);
    const { token, user } = response.data;
    
    this.token = token;
    this.user = user;
    
    localStorage.setItem('token', token);
    localStorage.setItem('user', JSON.stringify(user));
    
    return response;
  }
  
  async logout() {
    await api.post('/auth/logout');
    this.token = null;
    this.user = null;
    
    localStorage.removeItem('token');
    localStorage.removeItem('user');
  }
  
  async refreshToken() {
    const response = await api.post('/auth/refresh');
    const { token } = response.data;
    
    this.token = token;
    localStorage.setItem('token', token);
    
    return token;
  }
  
  async hasPermission(permission) {
    if (!this.user) return false;
    
    const response = await api.get(`/auth/check-permission/${permission}`);
    return response.data.hasPermission;
  }
  
  isAuthenticated() {
    return !!this.token;
  }
  
  hasRole(role) {
    return this.user && this.user.role === role;
  }
}

export const authService = new AuthService();

// permission.js - 权限指令
import { createApp } from 'vue';

const permissionDirective = {
  mounted(el, binding) {
    const { value } = binding;
    
    if (value && !hasPermission(value)) {
      el.parentNode && el.parentNode.removeChild(el);
    }
  },
  
  updated(el, binding) {
    const { value, oldValue } = binding;
    
    if (value !== oldValue) {
      if (value && !hasPermission(value)) {
        el.style.display = 'none';
      } else {
        el.style.display = '';
      }
    }
  }
};

function hasPermission(permission) {
  return authService.hasPermission(permission);
}

// 注册指令
const app = createApp(App);
app.directive('permission', permissionDirective);

// usePermission.js - 权限Hook
import { computed, ref } from 'vue';

export function usePermission() {
  const permissions = ref([]);
  
  const hasPermission = (permission) => {
    return permissions.value.includes(permission);
  };
  
  const hasRole = (role) => {
    return authService.hasRole(role);
  };
  
  const hasAnyPermission = (permissionList) => {
    return permissionList.some(permission => hasPermission(permission));
  };
  
  const hasAllPermissions = (permissionList) => {
    return permissionList.every(permission => hasPermission(permission));
  };
  
  const canAccess = (requiredPermissions) => {
    if (!requiredPermissions || requiredPermissions.length === 0) {
      return true;
    }
    
    return hasAllPermissions(requiredPermissions);
  };
  
  // 加载用户权限
  const loadPermissions = async () => {
    try {
      const response = await api.get('/auth/permissions');
      permissions.value = response.data;
    } catch (error) {
      console.error('Failed to load permissions:', error);
    }
  };
  
  return {
    permissions,
    hasPermission,
    hasRole,
    hasAnyPermission,
    hasAllPermissions,
    canAccess,
    loadPermissions
  };
}

// 路由权限配置
function createPermissionRoutes() {
  const routes = [
    {
      path: '/admin',
      component: () => import('@/layouts/AdminLayout.vue'),
      meta: {
        requiresAuth: true,
        permissions: ['admin.access']
      },
      children: [
        {
          path: 'users',
          component: () => import('@/views/admin/Users.vue'),
          meta: {
            permissions: ['admin.users.read']
          }
        },
        {
          path: 'users/create',
          component: () => import('@/views/admin/CreateUser.vue'),
          meta: {
            permissions: ['admin.users.create']
          }
        },
        {
          path: 'users/:id/edit',
          component: () => import('@/views/admin/EditUser.vue'),
          meta: {
            permissions: ['admin.users.update']
          }
        }
      ]
    }
  ];
  
  return routes;
}

// 动态路由添加
async function addDynamicRoutes(router) {
  const user = await getCurrentUser();
  const permissions = await getUserPermissions(user.id);
  
  const dynamicRoutes = createDynamicRoutes(permissions);
  
  dynamicRoutes.forEach(route => {
    router.addRoute(route);
  });
}

function createDynamicRoutes(permissions) {
  const routes = [];
  
  if (permissions.includes('dashboard.view')) {
    routes.push({
      path: '/dashboard',
      component: () => import('@/views/Dashboard.vue'),
      meta: { requiresAuth: true }
    });
  }
  
  if (permissions.includes('reports.view')) {
    routes.push({
      path: '/reports',
      component: () => import('@/views/Reports.vue'),
      meta: { requiresAuth: true }
    });
  }
  
  return routes;
}
```

## 4. Vuex/Pinia状态管理

### 4.1 Pinia状态管理

#### 4.1.1 Store定义和使用
```javascript
// stores/user.js - 用户状态管理
import { defineStore } from 'pinia';
import { ref, computed } from 'vue';
import { authService } from '@/services/auth';

export const useUserStore = defineStore('user', () => {
  // State
  const user = ref(null);
  const token = ref(null);
  const loading = ref(false);
  const error = ref(null);
  
  // Getters
  const isAuthenticated = computed(() => !!token.value);
  const userName = computed(() => user.value?.name || '');
  const userRole = computed(() => user.value?.role || '');
  const isAdmin = computed(() => userRole.value === 'admin');
  
  // Actions
  const login = async (credentials) => {
    loading.value = true;
    error.value = null;
    
    try {
      const response = await authService.login(credentials);
      user.value = response.user;
      token.value = response.token;
      
      // 设置API默认token
      api.defaults.headers.common['Authorization'] = `Bearer ${token.value}`;
      
      return response;
    } catch (err) {
      error.value = err.message;
      throw err;
    } finally {
      loading.value = false;
    }
  };
  
  const logout = async () => {
    try {
      await authService.logout();
    } finally {
      user.value = null;
      token.value = null;
      delete api.defaults.headers.common['Authorization'];
    }
  };
  
  const refreshToken = async () => {
    try {
      const newToken = await authService.refreshToken();
      token.value = newToken;
      api.defaults.headers.common['Authorization'] = `Bearer ${newToken}`;
      return newToken;
    } catch (err) {
      await logout();
      throw err;
    }
  };
  
  const updateProfile = async (profileData) => {
    loading.value = true;
    error.value = null;
    
    try {
      const response = await api.put('/user/profile', profileData);
      user.value = { ...user.value, ...response.data };
      return response.data;
    } catch (err) {
      error.value = err.message;
      throw err;
    } finally {
      loading.value = false;
    }
  };
  
  // 初始化
  const initialize = async () => {
    const savedToken = localStorage.getItem('token');
    const savedUser = localStorage.getItem('user');
    
    if (savedToken && savedUser) {
      token.value = savedToken;
      user.value = JSON.parse(savedUser);
      api.defaults.headers.common['Authorization'] = `Bearer ${savedToken}`;
      
      // 验证token是否有效
      try {
        await api.get('/auth/verify');
      } catch (err) {
        await logout();
      }
    }
  };
  
  return {
    // State
    user,
    token,
    loading,
    error,
    
    // Getters
    isAuthenticated,
    userName,
    userRole,
    isAdmin,
    
    // Actions
    login,
    logout,
    refreshToken,
    updateProfile,
    initialize
  };
});

// stores/cart.js - 购物车状态管理
import { defineStore } from 'pinia';
import { ref, computed } from 'vue';

export const useCartStore = defineStore('cart', () => {
  const items = ref([]);
  const coupon = ref(null);
  const shipping = ref(0);
  
  // 计算属性
  const itemCount = computed(() => 
    items.value.reduce((total, item) => total + item.quantity, 0)
  );
  
  const subtotal = computed(() => 
    items.value.reduce((total, item) => total + item.price * item.quantity, 0)
  );
  
  const discount = computed(() => {
    if (!coupon.value) return 0;
    return coupon.value.type === 'percentage' 
      ? subtotal.value * (coupon.value.value / 100)
      : coupon.value.value;
  });
  
  const total = computed(() => 
    subtotal.value - discount.value + shipping.value
  );
  
  // Actions
  const addItem = (product, quantity = 1) => {
    const existingItem = items.value.find(item => item.id === product.id);
    
    if (existingItem) {
      existingItem.quantity += quantity;
    } else {
      items.value.push({
        ...product,
        quantity
      });
    }
    
    saveToLocalStorage();
  };
  
  const removeItem = (productId) => {
    const index = items.value.findIndex(item => item.id === productId);
    if (index > -1) {
      items.value.splice(index, 1);
      saveToLocalStorage();
    }
  };
  
  const updateQuantity = (productId, quantity) => {
    const item = items.value.find(item => item.id === productId);
    if (item) {
      item.quantity = Math.max(0, quantity);
      if (item.quantity === 0) {
        removeItem(productId);
      } else {
        saveToLocalStorage();
      }
    }
  };
  
  const clearCart = () => {
    items.value = [];
    coupon.value = null;
    saveToLocalStorage();
  };
  
  const applyCoupon = (couponCode) => {
    // 这里应该调用API验证优惠券
    coupon.value = {
      code: couponCode,
      type: 'percentage',
      value: 10
    };
    saveToLocalStorage();
  };
  
  const removeCoupon = () => {
    coupon.value = null;
    saveToLocalStorage();
  };
  
  const setShipping = (cost) => {
    shipping.value = cost;
    saveToLocalStorage();
  };
  
  // 本地存储
  const saveToLocalStorage = () => {
    localStorage.setItem('cart', JSON.stringify({
      items: items.value,
      coupon: coupon.value,
      shipping: shipping.value
    }));
  };
  
  const loadFromLocalStorage = () => {
    const savedCart = localStorage.getItem('cart');
    if (savedCart) {
      const { items: savedItems, coupon: savedCoupon, shipping: savedShipping } = JSON.parse(savedCart);
      items.value = savedItems || [];
      coupon.value = savedCoupon || null;
      shipping.value = savedShipping || 0;
    }
  };
  
  return {
    // State
    items,
    coupon,
    shipping,
    
    // Getters
    itemCount,
    subtotal,
    discount,
    total,
    
    // Actions
    addItem,
    removeItem,
    updateQuantity,
    clearCart,
    applyCoupon,
    removeCoupon,
    setShipping,
    loadFromLocalStorage
  };
});

// stores/settings.js - 设置状态管理
export const useSettingsStore = defineStore('settings', () => {
  const theme = ref('light');
  const language = ref('zh-CN');
  const notifications = ref(true);
  const autoSave = ref(true);
  
  const isDarkTheme = computed(() => theme.value === 'dark');
  
  const setTheme = (newTheme) => {
    theme.value = newTheme;
    document.documentElement.setAttribute('data-theme', newTheme);
    localStorage.setItem('theme', newTheme);
  };
  
  const setLanguage = (newLanguage) => {
    language.value = newLanguage;
    localStorage.setItem('language', newLanguage);
  };
  
  const toggleNotifications = () => {
    notifications.value = !notifications.value;
    localStorage.setItem('notifications', notifications.value);
  };
  
  const toggleAutoSave = () => {
    autoSave.value = !autoSave.value;
    localStorage.setItem('autoSave', autoSave.value);
  };
  
  const loadSettings = () => {
    theme.value = localStorage.getItem('theme') || 'light';
    language.value = localStorage.getItem('language') || 'zh-CN';
    notifications.value = localStorage.getItem('notifications') !== 'false';
    autoSave.value = localStorage.getItem('autoSave') !== 'false';
    
    document.documentElement.setAttribute('data-theme', theme.value);
  };
  
  return {
    theme,
    language,
    notifications,
    autoSave,
    isDarkTheme,
    setTheme,
    setLanguage,
    toggleNotifications,
    toggleAutoSave,
    loadSettings
  };
});
```

#### 4.1.2 Store插件和中间件
```javascript
// plugins/piniaLogger.js - Pinia日志插件
export function piniaLoggerPlugin({ store }) {
  store.$onAction(({ name, args, after, onError }) => {
    const startTime = Date.now();
    console.log(`🍍 ${store.$id}:${name} with args`, args);
    
    after((result) => {
      console.log(`✅ ${store.$id}:${name} finished in ${Date.now() - startTime}ms`, result);
    });
    
    onError((error) => {
      console.error(`❌ ${store.$id}:${name} failed`, error);
    });
  });
  
  store.$subscribe((mutation, state) => {
    console.log(`🔄 ${store.$id} state changed:`, mutation);
  });
}

// plugins/piniaPersist.js - 持久化插件
export function piniaPersistPlugin({ store, options }) {
  if (!options.persist) return;
  
  const { key = store.$id, storage = localStorage, paths = [] } = options.persist;
  
  // 从存储中恢复状态
  const fromStorage = storage.getItem(key);
  if (fromStorage) {
    try {
      const data = JSON.parse(fromStorage);
      if (paths.length === 0) {
        store.$patch(data);
      } else {
        const partialData = {};
        paths.forEach(path => {
          if (data[path] !== undefined) {
            partialData[path] = data[path];
          }
        });
        store.$patch(partialData);
      }
    } catch (error) {
      console.error(`Failed to restore ${store.$id} from storage:`, error);
    }
  }
  
  // 监听状态变化并保存到存储
  store.$subscribe((mutation, state) => {
    try {
      const toStore = paths.length === 0 ? state : {};
      if (paths.length > 0) {
        paths.forEach(path => {
          toStore[path] = state[path];
        });
      }
      storage.setItem(key, JSON.stringify(toStore));
    } catch (error) {
      console.error(`Failed to persist ${store.$id} to storage:`, error);
    }
  });
}

// plugins/piniaReset.js - 重置插件
export function piniaResetPlugin({ store }) {
  const initialState = JSON.parse(JSON.stringify(store.$state));
  
  store.$reset = () => {
    store.$patch(JSON.parse(JSON.stringify(initialState)));
  };
}

// 使用插件
// main.js
import { createPinia } from 'pinia';
import { piniaLoggerPlugin, piniaPersistPlugin, piniaResetPlugin } from './plugins';

const pinia = createPinia();

pinia.use(piniaLoggerPlugin);
pinia.use(piniaPersistPlugin);
pinia.use(piniaResetPlugin);

app.use(pinia);

// Store中使用持久化
export const useUserStore = defineStore('user', () => {
  // ... store logic
}, {
  persist: {
    key: 'user-store',
    paths: ['user', 'token'] // 只持久化这些字段
  }
});

// Store中间件模式
function createStoreWithMiddleware(id, setup, options = {}) {
  const store = defineStore(id, setup, options);
  
  // 添加中间件支持
  store.use = function(middleware) {
    middleware(this);
    return this;
  };
  
  return store;
}

// 使用示例
const userStore = createStoreWithMiddleware('user', () => {
  // ... setup logic
}).use((store) => {
  // 中间件逻辑
  console.log('User store middleware applied');
});
```

## 5. Vue.js性能优化

### 5.1 组件性能优化

#### 5.1.1 懒加载和异步组件
```javascript
// 路由懒加载
const routes = [
  {
    path: '/about',
    component: () => import(/* webpackChunkName: "about" */ '@/views/About.vue')
  }
];

// 异步组件
import { defineAsyncComponent } from 'vue';

const AsyncComponent = defineAsyncComponent(() => 
  import('./components/HeavyComponent.vue')
);

// 带加载状态的异步组件
const AsyncComponentWithLoading = defineAsyncComponent({
  loader: () => import('./components/HeavyComponent.vue'),
  loadingComponent: LoadingComponent,
  errorComponent: ErrorComponent,
  delay: 200,
  timeout: 3000
});

// 组件懒加载Hook
function useLazyComponent(componentLoader) {
  const component = ref(null);
  const loading = ref(false);
  const error = ref(null);
  
  const load = async () => {
    if (component.value) return;
    
    loading.value = true;
    error.value = null;
    
    try {
      const loadedComponent = await componentLoader();
      component.value = loadedComponent.default || loadedComponent;
    } catch (err) {
      error.value = err;
    } finally {
      loading.value = false;
    }
  };
  
  return { component, loading, error, load };
}

// 使用示例
const { component, loading, error, load } = useLazyComponent(() => 
  import('./components/HeavyComponent.vue')
);

// 模板中使用
<template>
  <div>
    <button @click="load" v-if="!component && !loading">加载组件</button>
    <LoadingSpinner v-if="loading" />
    <ErrorMessage v-if="error" :error="error" />
    <component :is="component" v-if="component" />
  </div>
</template>
```

#### 5.1.2 虚拟滚动和列表优化
```javascript
// 虚拟滚动组件
<template>
  <div class="virtual-scroll-container" @scroll="handleScroll">
    <div class="virtual-scroll-content" :style="{ height: totalHeight + 'px' }">
      <div 
        class="virtual-scroll-spacer" 
        :style="{ height: offsetY + 'px' }"
      ></div>
      <div
        v-for="item in visibleItems"
        :key="item.id"
        class="virtual-scroll-item"
        :style="{ height: itemHeight + 'px' }"
      >
        <slot :item="item" :index="item.index" />
      </div>
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted, onUnmounted } from 'vue';

export default {
  props: {
    items: Array,
    itemHeight: { type: Number, default: 50 },
    containerHeight: { type: Number, default: 400 },
    bufferSize: { type: Number, default: 5 }
  },
  
  setup(props) {
    const scrollTop = ref(0);
    const containerRef = ref(null);
    
    const totalHeight = computed(() => props.items.length * props.itemHeight);
    
    const startIndex = computed(() => {
      return Math.max(0, Math.floor(scrollTop.value / props.itemHeight) - props.bufferSize);
    });
    
    const endIndex = computed(() => {
      const visibleCount = Math.ceil(props.containerHeight / props.itemHeight);
      return Math.min(
        props.items.length - 1,
        startIndex.value + visibleCount + props.bufferSize * 2
      );
    });
    
    const offsetY = computed(() => startIndex.value * props.itemHeight);
    
    const visibleItems = computed(() => {
      return props.items.slice(startIndex.value, endIndex.value + 1).map((item, index) => ({
        ...item,
        index: startIndex.value + index
      }));
    });
    
    const handleScroll = (event) => {
      scrollTop.value = event.target.scrollTop;
    };
    
    return {
      scrollTop,
      totalHeight,
      offsetY,
      visibleItems,
      handleScroll
    };
  }
};
</script>

<style>
.virtual-scroll-container {
  height: 400px;
  overflow-y: auto;
  border: 1px solid #ddd;
}

.virtual-scroll-content {
  position: relative;
}

.virtual-scroll-item {
  position: absolute;
  width: 100%;
  box-sizing: border-box;
}
</style>

// 列表优化Hook
function useListOptimization(items, options = {}) {
  const {
    pageSize = 20,
    threshold = 100,
    filterFn = null,
    sortFn = null
  } = options;
  
  const currentPage = ref(1);
  const loading = ref(false);
  const hasMore = ref(true);
  
  const filteredItems = computed(() => {
    if (!filterFn) return items.value;
    return items.value.filter(filterFn);
  });
  
  const sortedItems = computed(() => {
    if (!sortFn) return filteredItems.value;
    return [...filteredItems.value].sort(sortFn);
  });
  
  const paginatedItems = computed(() => {
    const start = 0;
    const end = currentPage.value * pageSize;
    return sortedItems.value.slice(start, end);
  });
  
  const loadMore = () => {
    if (loading.value || !hasMore.value) return;
    
    loading.value = true;
    
    // 模拟异步加载
    setTimeout(() => {
      currentPage.value++;
      hasMore.value = paginatedItems.value.length < sortedItems.value.length;
      loading.value = false;
    }, 300);
  };
  
  const reset = () => {
    currentPage.value = 1;
    hasMore.value = true;
    loading.value = false;
  };
  
  // 监听items变化重置分页
  watch(items, reset);
  
  return {
    paginatedItems,
    loading,
    hasMore,
    loadMore,
    reset
  };
}

// 防抖搜索Hook
function useDebouncedSearch(searchFunction, delay = 300) {
  const searchQuery = ref('');
  const results = ref([]);
  const loading = ref(false);
  const error = ref(null);
  
  let timeoutId = null;
  
  const search = async (query) => {
    if (timeoutId) {
      clearTimeout(timeoutId);
    }
    
    timeoutId = setTimeout(async () => {
      if (!query.trim()) {
        results.value = [];
        return;
      }
      
      loading.value = true;
      error.value = null;
      
      try {
        results.value = await searchFunction(query);
      } catch (err) {
        error.value = err.message;
        results.value = [];
      } finally {
        loading.value = false;
      }
    }, delay);
  };
  
  // 监听搜索查询
  watch(searchQuery, (newQuery) => {
    search(newQuery);
  });
  
  return {
    searchQuery,
    results,
    loading,
    error
  };
}
```

### 5.2 渲染性能优化

#### 5.2.1 v-memo和v-once优化
```vue
<template>
  <!-- v-once - 只渲染一次 -->
  <div v-once>
    <h1>{{ staticTitle }}</h1>
    <p>{{ staticDescription }}</p>
  </div>
  
  <!-- v-memo - 条件记忆 -->
  <div v-for="item in items" :key="item.id" v-memo="[item.id, item.updated]">
    <ExpensiveComponent :data="item" />
  </div>
  
  <!-- 计算属性缓存 -->
  <div>{{ expensiveComputedValue }}</div>
  
  <!-- 函数式组件 -->
  <FunctionalComponent :data="data" />
</template>

<script>
import { computed } from 'vue';

export default {
  props: {
    items: Array
  },
  
  setup(props) {
    const staticTitle = ref('Static Title');
    const staticDescription = ref('This content never changes');
    
    // 计算属性自动缓存
    const expensiveComputedValue = computed(() => {
      console.log('Computing expensive value...');
      return heavyCalculation(props.items);
    });
    
    return {
      staticTitle,
      staticDescription,
      expensiveComputedValue
    };
  }
};

// 函数式组件
const FunctionalComponent = (props, context) => {
  return h('div', { class: 'functional-component' }, props.data.value);
};
</script>
```

#### 5.2.2 性能监控和调试
```javascript
// 性能监控Hook
function usePerformanceMonitor() {
  const metrics = ref({
    renderTime: 0,
    componentCount: 0,
    updateCount: 0
  });
  
  const startMeasure = (name) => {
    performance.mark(`${name}-start`);
  };
  
  const endMeasure = (name) => {
    performance.mark(`${name}-end`);
    performance.measure(name, `${name}-start`, `${name}-end`);
    
    const measure = performance.getEntriesByName(name)[0];
    return measure.duration;
  };
  
  const measureRenderTime = (componentName) => {
    const duration = endMeasure(`render-${componentName}`);
    metrics.value.renderTime += duration;
    return duration;
  };
  
  const trackComponentUpdate = () => {
    metrics.value.updateCount++;
  };
  
  const trackComponentMount = () => {
    metrics.value.componentCount++;
  };
  
  return {
    metrics,
    startMeasure,
    endMeasure,
    measureRenderTime,
    trackComponentUpdate,
    trackComponentMount
  };
}

// 组件性能装饰器
function withPerformanceMonitoring(component) {
  return {
    ...component,
    setup(props, context) {
      const monitor = usePerformanceMonitor();
      
      monitor.startMeasure(component.name || 'Component');
      
      const result = component.setup ? component.setup(props, context) : {};
      
      // 监听组件更新
      onUpdated(() => {
        monitor.trackComponentUpdate();
      });
      
      onMounted(() => {
        monitor.trackComponentMount();
        const renderTime = monitor.measureRenderTime(component.name || 'Component');
        console.log(`Component ${component.name} rendered in ${renderTime}ms`);
      });
      
      return result;
    }
  };
}

// 使用示例
export default withPerformanceMonitoring({
  name: 'MyComponent',
  setup() {
    // 组件逻辑
  }
});

// 内存泄漏检测
function useMemoryLeakDetection() {
  const observers = ref([]);
  const timers = ref([]);
  const eventListeners = ref([]);
  
  const addObserver = (observer) => {
    observers.value.push(observer);
  };
  
  const addTimer = (timer) => {
    timers.value.push(timer);
  };
  
  const addEventListener = (element, event, handler) => {
    element.addEventListener(event, handler);
    eventListeners.value.push({ element, event, handler });
  };
  
  const cleanup = () => {
    // 清理观察者
    observers.value.forEach(observer => observer.disconnect());
    observers.value = [];
    
    // 清理定时器
    timers.value.forEach(timer => clearTimeout(timer));
    timers.value = [];
    
    // 清理事件监听器
    eventListeners.value.forEach(({ element, event, handler }) => {
      element.removeEventListener(event, handler);
    });
    eventListeners.value = [];
  };
  
  onUnmounted(() => {
    cleanup();
  });
  
  return {
    addObserver,
    addTimer,
    addEventListener,
    cleanup
  };
}

// 性能优化工具
export const performanceUtils = {
  // 防抖
  debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
      const later = () => {
        clearTimeout(timeout);
        func(...args);
      };
      clearTimeout(timeout);
      timeout = setTimeout(later, wait);
    };
  },
  
  // 节流
  throttle(func, limit) {
    let inThrottle;
    return function(...args) {
      if (!inThrottle) {
        func.apply(this, args);
        inThrottle = true;
        setTimeout(() => inThrottle = false, limit);
      }
    };
  },
  
  // 批量更新
  batchUpdate(fn) {
    return new Promise(resolve => {
      requestAnimationFrame(() => {
        fn();
        resolve();
      });
    });
  },
  
  // 懒加载图片
  lazyLoadImage(imageElement, src) {
    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          const img = entry.target;
          img.src = src;
          observer.unobserve(img);
        }
      });
    });
    
    observer.observe(imageElement);
    return observer;
  }
};
```

## 6. Vue.js生态系统集成

### 6.1 UI框架集成

#### 6.1.1 Element Plus集成
```javascript
// plugins/element.js
import ElementPlus from 'element-plus';
import 'element-plus/dist/index.css';
import * as ElementPlusIconsVue from '@element-plus/icons-vue';

export function setupElementPlus(app) {
  app.use(ElementPlus);
  
  // 注册所有图标
  for (const [key, component] of Object.entries(ElementPlusIconsVue)) {
    app.component(key, component);
  }
  
  // 全局配置
  app.config.globalProperties.$ELEMENT = {
    size: 'default',
    zIndex: 3000
  };
}

// 主题定制
// styles/element-theme.scss
$--color-primary: #409eff;
$--color-success: #67c23a;
$--color-warning: #e6a23c;
$--color-danger: #f56c6c;
$--color-info: #909399;

// 导入并覆盖变量
@forward "element-plus/theme-chalk/src/common/var.scss" with (
  $colors: (
    "primary": (
      "base": $--color-primary,
    ),
    "success": (
      "base": $--color-success,
    ),
    "warning": (
      "base": $--color-warning,
    ),
    "danger": (
      "base": $--color-danger,
    ),
    "info": (
      "base": $--color-info,
    ),
  )
);

// 导入所有样式
@use "element-plus/theme-chalk/src/index.scss" as *;

// 组件中使用
<template>
  <el-config-provider :locale="locale">
    <router-view />
  </el-config-provider>
</template>

<script>
import { defineComponent } from 'vue';
import { ElConfigProvider } from 'element-plus';
import zhCn from 'element-plus/dist/locale/zh-cn.mjs';

export default defineComponent({
  name: 'App',
  components: {
    ElConfigProvider
  },
  setup() {
    return {
      locale: zhCn
    };
  }
});
</script>
```

#### 6.1.2 Ant Design Vue集成
```javascript
// plugins/antd.js
import Antd from 'ant-design-vue';
import 'ant-design-vue/dist/antd.css';

export function setupAntd(app) {
  app.use(Antd);
  
  // 全局配置
  app.config.globalProperties.$message = Antd.message;
  app.config.globalProperties.$notification = Antd.notification;
  app.config.globalProperties.$modal = Antd.Modal;
}

// 主题定制
// styles/antd-theme.less
@import '~ant-design-vue/dist/antd.less';

// 主色
@primary-color: #1890ff;
@link-color: #1890ff;
@success-color: #52c41a;
@warning-color: #faad14;
@error-color: #f5222d;
@font-size-base: 14px;
@heading-color: rgba(0, 0, 0, 0.85);
@text-color: rgba(0, 0, 0, 0.65);
@text-color-secondary: rgba(0, 0, 0, 0.45);
@disabled-color: rgba(0, 0, 0, 0.25);
@border-radius-base: 6px;
@box-shadow-base: 0 3px 6px -4px rgba(0, 0, 0, 0.12), 0 6px 16px 0 rgba(0, 0, 0, 0.08), 0 9px 28px 8px rgba(0, 0, 0, 0.05);

// 表单组件封装
<template>
  <a-form
    :model="formState"
    :rules="rules"
    :layout="layout"
    @finish="handleSubmit"
  >
    <a-form-item
      v-for="field in fields"
      :key="field.name"
      :label="field.label"
      :name="field.name"
    >
      <component
        :is="getFieldComponent(field.type)"
        v-model:value="formState[field.name]"
        v-bind="field.props"
      />
    </a-form-item>
    
    <a-form-item>
      <a-button type="primary" html-type="submit" :loading="loading">
        {{ submitText }}
      </a-button>
      <a-button style="margin-left: 10px" @click="handleReset">
        重置
      </a-button>
    </a-form-item>
  </a-form>
</template>

<script>
import { defineComponent, ref, reactive } from 'vue';

export default defineComponent({
  name: 'DynamicForm',
  props: {
    fields: Array,
    rules: Object,
    layout: { type: String, default: 'horizontal' },
    submitText: { type: String, default: '提交' },
    loading: Boolean
  },
  
  emits: ['submit', 'reset'],
  
  setup(props, { emit }) {
    const formState = reactive({});
    
    // 初始化表单状态
    props.fields.forEach(field => {
      formState[field.name] = field.defaultValue || '';
    });
    
    const getFieldComponent = (type) => {
      const componentMap = {
        input: 'a-input',
        textarea: 'a-textarea',
        select: 'a-select',
        radio: 'a-radio-group',
        checkbox: 'a-checkbox-group',
        date: 'a-date-picker',
        number: 'a-input-number'
      };
      
      return componentMap[type] || 'a-input';
    };
    
    const handleSubmit = (values) => {
      emit('submit', values);
    };
    
    const handleReset = () => {
      emit('reset');
    };
    
    return {
      formState,
      getFieldComponent,
      handleSubmit,
      handleReset
    };
  }
});
</script>
```

### 6.2 工具库集成

#### 6.2.1 Axios集成和拦截器
```javascript
// utils/request.js
import axios from 'axios';
import { ElMessage, ElMessageBox } from 'element-plus';
import { useUserStore } from '@/stores/user';

// 创建axios实例
const service = axios.create({
  baseURL: process.env.VUE_APP_BASE_API,
  timeout: 10000
});

// 请求拦截器
service.interceptors.request.use(
  (config) => {
    const userStore = useUserStore();
    
    // 添加token
    if (userStore.token) {
      config.headers['Authorization'] = `Bearer ${userStore.token}`;
    }
    
    // 添加请求ID
    config.headers['X-Request-ID'] = generateRequestId();
    
    // 添加时间戳
    config.headers['X-Timestamp'] = Date.now();
    
    return config;
  },
  (error) => {
    console.error('Request error:', error);
    return Promise.reject(error);
  }
);

// 响应拦截器
service.interceptors.response.use(
  (response) => {
    const { data, config } = response;
    
    // 记录请求日志
    logRequest(config, data);
    
    // 处理业务错误
    if (data.code !== 200) {
      handleBusinessError(data);
      return Promise.reject(new Error(data.message || '请求失败'));
    }
    
    return data;
  },
  async (error) => {
    const { response, config } = error;
    
    // 记录错误日志
    logError(config, error);
    
    // 处理HTTP错误
    if (response) {
      await handleHttpError(response, config);
    } else if (error.code === 'ECONNABORTED') {
      ElMessage.error('请求超时，请重试');
    } else {
      ElMessage.error('网络错误，请检查网络连接');
    }
    
    return Promise.reject(error);
  }
);

// 处理业务错误
function handleBusinessError(data) {
  switch (data.code) {
    case 401:
      ElMessage.error('登录已过期，请重新登录');
      redirectToLogin();
      break;
    case 403:
      ElMessage.error('权限不足');
      break;
    case 404:
      ElMessage.error('请求的资源不存在');
      break;
    case 500:
      ElMessage.error('服务器内部错误');
      break;
    default:
      ElMessage.error(data.message || '请求失败');
  }
}

// 处理HTTP错误
async function handleHttpError(response, config) {
  const { status, data } = response;
  
  switch (status) {
    case 401:
      // 尝试刷新token
      if (!config._retry) {
        config._retry = true;
        try {
          await refreshToken();
          return service(config);
        } catch (refreshError) {
          redirectToLogin();
        }
      } else {
        redirectToLogin();
      }
      break;
    case 403:
      ElMessage.error('权限不足');
      break;
    case 404:
      ElMessage.error('请求的资源不存在');
      break;
    case 422:
      // 表单验证错误
      if (data.errors) {
        const errors = Object.values(data.errors).flat();
        ElMessage.error(errors[0]);
      }
      break;
    case 429:
      ElMessage.error('请求过于频繁，请稍后再试');
      break;
    case 500:
      ElMessage.error('服务器内部错误');
      break;
    default:
      ElMessage.error(`请求失败 (${status})`);
  }
}

// 刷新token
async function refreshToken() {
  const userStore = useUserStore();
  await userStore.refreshToken();
}

// 重定向到登录页
function redirectToLogin() {
  const userStore = useUserStore();
  userStore.logout();
  window.location.href = '/login';
}

// 生成请求ID
function generateRequestId() {
  return Math.random().toString(36).substr(2, 9);
}

// 记录请求日志
function logRequest(config, data) {
  console.log(`✅ ${config.method?.toUpperCase()} ${config.url}`, {
    request: config.data,
    response: data,
    duration: Date.now() - parseInt(config.headers['X-Timestamp'])
  });
}

// 记录错误日志
function logError(config, error) {
  console.error(`❌ ${config.method?.toUpperCase()} ${config.url}`, {
    request: config.data,
    error: error.message,
    response: error.response?.data
  });
}

// API方法封装
export const api = {
  get(url, params = {}) {
    return service.get(url, { params });
  },
  
  post(url, data = {}) {
    return service.post(url, data);
  },
  
  put(url, data = {}) {
    return service.put(url, data);
  },
  
  delete(url, params = {}) {
    return service.delete(url, { params });
  },
  
  upload(url, formData, onProgress) {
    return service.post(url, formData, {
      headers: {
        'Content-Type': 'multipart/form-data'
      },
      onUploadProgress: onProgress
    });
  },
  
  download(url, params = {}) {
    return service.get(url, {
      params,
      responseType: 'blob'
    });
  }
};

export default service;
```

#### 6.2.2 工具函数库
```javascript
// utils/index.js
import dayjs from 'dayjs';
import { ElMessage } from 'element-plus';

// 日期工具
export const dateUtils = {
  format(date, format = 'YYYY-MM-DD HH:mm:ss') {
    return dayjs(date).format(format);
  },
  
  fromNow(date) {
    return dayjs(date).fromNow();
  },
  
  isToday(date) {
    return dayjs(date).isSame(dayjs(), 'day');
  },
  
  isYesterday(date) {
    return dayjs(date).isSame(dayjs().subtract(1, 'day'), 'day');
  },
  
  startOfDay(date) {
    return dayjs(date).startOf('day').toDate();
  },
  
  endOfDay(date) {
    return dayjs(date).endOf('day').toDate();
  }
};

// 存储工具
export const storageUtils = {
  set(key, value, expire = null) {
    const data = {
      value,
      expire: expire ? Date.now() + expire : null
    };
    localStorage.setItem(key, JSON.stringify(data));
  },
  
  get(key) {
    const item = localStorage.getItem(key);
    if (!item) return null;
    
    try {
      const data = JSON.parse(item);
      if (data.expire && Date.now() > data.expire) {
        localStorage.removeItem(key);
        return null;
      }
      return data.value;
    } catch {
      return null;
    }
  },
  
  remove(key) {
    localStorage.removeItem(key);
  },
  
  clear() {
    localStorage.clear();
  }
};

// 文件工具
export const fileUtils = {
  formatFileSize(bytes) {
    if (bytes === 0) return '0 Bytes';
    
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
  },
  
  getFileExtension(filename) {
    return filename.slice((filename.lastIndexOf('.') - 1 >>> 0) + 2);
  },
  
  downloadFile(url, filename) {
    const link = document.createElement('a');
    link.href = url;
    link.download = filename;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  },
  
  previewFile(file) {
    return new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.onload = (e) => resolve(e.target.result);
      reader.onerror = reject;
      reader.readAsDataURL(file);
    });
  }
};

// 字符串工具
export const stringUtils = {
  truncate(str, length, suffix = '...') {
    if (str.length <= length) return str;
    return str.substring(0, length) + suffix;
  },
  
  capitalize(str) {
    return str.charAt(0).toUpperCase() + str.slice(1);
  },
  
  camelCase(str) {
    return str.replace(/-([a-z])/g, (g) => g[1].toUpperCase());
  },
  
  kebabCase(str) {
    return str.replace(/([a-z0-9])([A-Z])/g, '$1-$2').toLowerCase();
  },
  
  generateId(length = 8) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    let result = '';
    for (let i = 0; i < length; i++) {
      result += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return result;
  }
};

// 数组工具
export const arrayUtils = {
  unique(arr) {
    return [...new Set(arr)];
  },
  
  groupBy(arr, key) {
    return arr.reduce((groups, item) => {
      const group = item[key];
      groups[group] = groups[group] || [];
      groups[group].push(item);
      return groups;
    }, {});
  },
  
  sortBy(arr, key, order = 'asc') {
    return arr.sort((a, b) => {
      if (order === 'desc') {
        return b[key] > a[key] ? 1 : -1;
      }
      return a[key] > b[key] ? 1 : -1;
    });
  },
  
  chunk(arr, size) {
    const chunks = [];
    for (let i = 0; i < arr.length; i += size) {
      chunks.push(arr.slice(i, i + size));
    }
    return chunks;
  }
};

// 对象工具
export const objectUtils = {
  deepClone(obj) {
    return JSON.parse(JSON.stringify(obj));
  },
  
  pick(obj, keys) {
    return keys.reduce((result, key) => {
      if (obj.hasOwnProperty(key)) {
        result[key] = obj[key];
      }
      return result;
    }, {});
  },
  
  omit(obj, keys) {
    const result = { ...obj };
    keys.forEach(key => delete result[key]);
    return result;
  },
  
  isEmpty(obj) {
    return Object.keys(obj).length === 0;
  }
};

// 验证工具
export const validateUtils = {
  email(email) {
    const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return re.test(email);
  },
  
  phone(phone) {
    const re = /^1[3-9]\d{9}$/;
    return re.test(phone);
  },
  
  url(url) {
    try {
      new URL(url);
      return true;
    } catch {
      return false;
    }
  },
  
  idCard(idCard) {
    const re = /(^\d{15}$)|(^\d{18}$)|(^\d{17}(\d|X|x)$)/;
    return re.test(idCard);
  }
};

// 消息工具
export const messageUtils = {
  success(message) {
    ElMessage.success(message);
  },
  
  error(message) {
    ElMessage.error(message);
  },
  
  warning(message) {
    ElMessage.warning(message);
  },
  
  info(message) {
    ElMessage.info(message);
  },
  
  confirm(message, title = '确认') {
    return ElMessageBox.confirm(message, title, {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    });
  }
};

// 防抖节流
export const debounce = (func, wait) => {
  let timeout;
  return function executedFunction(...args) {
    const later = () => {
      clearTimeout(timeout);
      func(...args);
    };
    clearTimeout(timeout);
    timeout = setTimeout(later, wait);
  };
};

export const throttle = (func, limit) => {
  let inThrottle;
  return function(...args) {
    if (!inThrottle) {
      func.apply(this, args);
      inThrottle = true;
      setTimeout(() => inThrottle = false, limit);
    }
  };
};

// 导出所有工具
export default {
  dateUtils,
  storageUtils,
  fileUtils,
  stringUtils,
  arrayUtils,
  objectUtils,
  validateUtils,
  messageUtils,
  debounce,
  throttle
};
```

## 7. 总结

Vue.js是一个功能强大且灵活的前端框架，通过深入学习其核心概念和高级特性，可以构建出高性能、可维护的现代Web应用。

### 7.1 关键要点
1. **响应式系统**: 理解Vue的响应式原理和依赖收集机制
2. **组件系统**: 掌握组件生命周期和通信模式
3. **Composition API**: 熟练使用组合式API和自定义Hook
4. **路由系统**: 深入理解Vue Router的配置和权限控制
5. **状态管理**: 掌握Pinia/Vuex的使用和最佳实践
6. **性能优化**: 应用各种优化技巧提升应用性能
7. **生态集成**: 熟练集成UI框架和工具库

### 7.2 学习路径
1. **基础阶段**: 响应式原理、组件基础、路由基础
2. **进阶阶段**: Composition API、状态管理、路由守卫
3. **高级阶段**: 性能优化、插件开发、架构设计
4. **实践阶段**: 项目实战、最佳实践、团队协作

### 7.3 实践建议
1. **渐进式学习**: 从基础开始，逐步掌握高级特性
2. **项目驱动**: 通过实际项目巩固所学知识
3. **源码阅读**: 深入理解Vue.js的实现原理
4. **社区参与**: 关注Vue.js生态发展和最佳实践
5. **持续更新**: 跟随Vue.js版本更新，学习新特性

Vue.js的强大之处在于其简洁的API设计和强大的功能特性，通过系统学习和实践，可以充分发挥其优势，构建出优秀的Web应用。
