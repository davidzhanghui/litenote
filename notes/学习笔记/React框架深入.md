# React框架深入学习笔记

## 1. React核心概念回顾

### 1.1 组件化思想

#### 1.1.1 组件的本质
React的核心思想是将用户界面拆分成独立、可复用的组件。每个组件都像是一个独立的JavaScript函数，它接收输入（props）并返回描述UI的React元素。

```jsx
// 函数组件的基本结构
function Welcome(props) {
  return <h1>Hello, {props.name}</h1>;
}

// 类组件的基本结构
class Welcome extends React.Component {
  render() {
    return <h1>Hello, {this.props.name}</h1>;
  }
}

// 组件的使用
function App() {
  return (
    <div>
      <Welcome name="Alice" />
      <Welcome name="Bob" />
      <Welcome name="Charlie" />
    </div>
  );
}
```

#### 1.1.2 组件的设计原则
1. **单一职责**: 每个组件只负责一个功能
2. **可复用性**: 组件应该可以在不同的上下文中使用
3. **可组合性**: 小组件可以组合成更复杂的组件
4. **可测试性**: 组件应该易于测试

```jsx
// 好的组件设计示例
// Button组件 - 单一职责，可复用
function Button({ children, onClick, variant = "primary", size = "medium" }) {
  const baseClasses = "btn";
  const variantClasses = {
    primary: "btn-primary",
    secondary: "btn-secondary",
    danger: "btn-danger"
  };
  const sizeClasses = {
    small: "btn-sm",
    medium: "btn-md",
    large: "btn-lg"
  };

  return (
    <button
      className={`${baseClasses} ${variantClasses[variant]} ${sizeClasses[size]}`}
      onClick={onClick}
    >
      {children}
    </button>
  );
}

// Card组件 - 可组合
function Card({ children, title, actions }) {
  return (
    <div className="card">
      {title && <div className="card-header">{title}</div>}
      <div className="card-body">{children}</div>
      {actions && <div className="card-footer">{actions}</div>}
    </div>
  );
}

// 组合使用
function UserCard({ user, onEdit, onDelete }) {
  return (
    <Card title={user.name}>
      <p>Email: {user.email}</p>
      <p>Phone: {user.phone}</p>
      <div className="card-actions">
        <Button onClick={() => onEdit(user)}>Edit</Button>
        <Button variant="danger" onClick={() => onDelete(user.id)}>
          Delete
        </Button>
      </div>
    </Card>
  );
}
```

### 1.2 JSX语法深入

#### 1.2.1 JSX的本质
JSX是JavaScript的语法扩展，它允许我们在JavaScript代码中编写类似HTML的语法。JSX在编译时会被转换为React.createElement()调用。

```jsx
// JSX语法
const element = <h1 className="greeting">Hello, world!</h1>;

// 编译后的JavaScript
const element = React.createElement(
  "h1",
  { className: "greeting" },
  "Hello, world!"
);

// 更复杂的JSX示例
const element = (
  <div className="container">
    <h1 style={{ color: "blue", fontSize: "24px" }}>
      Welcome to React
    </h1>
    <ul>
      {items.map(item => (
        <li key={item.id}>
          {item.name} - {item.price}
        </li>
      ))}
    </ul>
  </div>
);

// 对应的React.createElement调用
const element = React.createElement(
  "div",
  { className: "container" },
  React.createElement(
    "h1",
    { style: { color: "blue", fontSize: "24px" } },
    "Welcome to React"
  ),
  React.createElement(
    "ul",
    null,
    items.map(item =>
      React.createElement(
        "li",
        { key: item.id },
        `${item.name} - ${item.price}`
      )
    )
  )
);
```

#### 1.2.2 JSX的高级特性
```jsx
// 1. 条件渲染
function Greeting({ isLoggedIn, userName }) {
  if (isLoggedIn) {
    return <h1>Welcome back, {userName}!</h1>;
  }
  return <h1>Please sign in.</h1>;
}

// 使用三元运算符
function Greeting({ isLoggedIn, userName }) {
  return (
    <div>
      {isLoggedIn ? (
        <h1>Welcome back, {userName}!</h1>
      ) : (
        <h1>Please sign in.</h1>
      )}
    </div>
  );
}

// 使用逻辑与运算符
function Notification({ message }) {
  return (
    <div>
      {message && <div className="notification">{message}</div>}
    </div>
  );
}

// 2. 列表渲染
function TodoList({ todos }) {
  return (
    <ul>
      {todos.map(todo => (
        <li key={todo.id} className={todo.completed ? "completed" : ""}>
          {todo.text}
        </li>
      ))}
    </ul>
  );
}

// 带索引的列表渲染
function NumberList({ numbers }) {
  return (
    <ul>
      {numbers.map((number, index) => (
        <li key={index}>
          {number}
        </li>
      ))}
    </ul>
  );
}

// 3. 事件处理
function Button() {
  const handleClick = (event) => {
    console.log("Button clicked!", event);
  };

  const handleCustomClick = (name, event) => {
    console.log(`Button clicked by ${name}!`, event);
  };

  return (
    <div>
      <button onClick={handleClick}>
        Click me
      </button>
      <button onClick={(e) => handleCustomClick("Alice", e)}>
        Click me too
      </button>
    </div>
  );
}

// 4. 表单处理
function NameForm() {
  const [value, setValue] = React.useState("");

  const handleSubmit = (event) => {
    event.preventDefault();
    alert(`A name was submitted: ${value}`);
  };

  const handleChange = (event) => {
    setValue(event.target.value);
  };

  return (
    <form onSubmit={handleSubmit}>
      <label>
        Name:
        <input type="text" value={value} onChange={handleChange} />
      </label>
      <button type="submit">Submit</button>
    </form>
  );
}

// 5. 受控组件和非受控组件
// 受控组件
function ControlledInput() {
  const [inputValue, setInputValue] = React.useState("");

  return (
    <input
      type="text"
      value={inputValue}
      onChange={(e) => setInputValue(e.target.value)}
    />
  );
}

// 非受控组件
function UncontrolledInput() {
  const inputRef = React.useRef();

  const handleSubmit = (event) => {
    event.preventDefault();
    alert(`Input value: ${inputRef.current.value}`);
  };

  return (
    <form onSubmit={handleSubmit}>
      <input type="text" ref={inputRef} />
      <button type="submit">Submit</button>
    </form>
  );
}
```

## 2. React Hooks深入

### 2.1 State Hooks

#### 2.1.1 useState深入理解
```jsx
// 基础用法
function Counter() {
  const [count, setCount] = React.useState(0);

  return (
    <div>
      <p>You clicked {count} times</p>
      <button onClick={() => setCount(count + 1)}>
        Click me
      </button>
    </div>
  );
}

// 函数式更新
function Counter() {
  const [count, setCount] = React.useState(0);

  const handleIncrement = () => {
    setCount(prevCount => prevCount + 1);
  };

  const handleIncrementMultiple = () => {
    setCount(prevCount => prevCount + 1);
    setCount(prevCount => prevCount + 1);
    setCount(prevCount => prevCount + 1);
  };

  return (
    <div>
      <p>Count: {count}</p>
      <button onClick={handleIncrement}>Increment</button>
      <button onClick={handleIncrementMultiple}>Increment by 3</button>
    </div>
  );
}

// 惰性初始状态
function UserProfile({ userId }) {
  const [user, setUser] = React.useState(() => {
    // 只在初始渲染时执行一次
    return fetchUser(userId);
  });

  return <div>{user.name}</div>;
}

// 复杂状态管理
function UserForm() {
  const [formData, setFormData] = React.useState({
    name: "",
    email: "",
    age: "",
    address: {
      street: "",
      city: "",
      zipCode: ""
    }
  });

  const handleChange = (field, value) => {
    setFormData(prev => ({
      ...prev,
      [field]: value
    }));
  };

  const handleAddressChange = (field, value) => {
    setFormData(prev => ({
      ...prev,
      address: {
        ...prev.address,
        [field]: value
      }
    }));
  };

  return (
    <form>
      <input
        type="text"
        placeholder="Name"
        value={formData.name}
        onChange={(e) => handleChange("name", e.target.value)}
      />
      <input
        type="email"
        placeholder="Email"
        value={formData.email}
        onChange={(e) => handleChange("email", e.target.value)}
      />
      <input
        type="text"
        placeholder="Street"
        value={formData.address.street}
        onChange={(e) => handleAddressChange("street", e.target.value)}
      />
    </form>
  );
}

// 使用useReducer管理复杂状态
function todoReducer(state, action) {
  switch (action.type) {
    case "ADD_TODO":
      return {
        ...state,
        todos: [...state.todos, action.payload]
      };
    case "TOGGLE_TODO":
      return {
        ...state,
        todos: state.todos.map(todo =>
          todo.id === action.payload
            ? { ...todo, completed: !todo.completed }
            : todo
        )
      };
    case "DELETE_TODO":
      return {
        ...state,
        todos: state.todos.filter(todo => todo.id !== action.payload)
      };
    default:
      return state;
  }
}

function TodoApp() {
  const [state, dispatch] = React.useReducer(todoReducer, {
    todos: []
  });

  const addTodo = (text) => {
    dispatch({
      type: "ADD_TODO",
      payload: {
        id: Date.now(),
        text,
        completed: false
      }
    });
  };

  const toggleTodo = (id) => {
    dispatch({ type: "TOGGLE_TODO", payload: id });
  };

  const deleteTodo = (id) => {
    dispatch({ type: "DELETE_TODO", payload: id });
  };

  return (
    <div>
      <TodoForm onSubmit={addTodo} />
      <TodoList
        todos={state.todos}
        onToggle={toggleTodo}
        onDelete={deleteTodo}
      />
    </div>
  );
}
```

#### 2.1.2 useReducer高级用法
```jsx
// 复杂的状态管理逻辑
function appReducer(state, action) {
  switch (action.type) {
    case "FETCH_START":
      return {
        ...state,
        loading: true,
        error: null
      };
    case "FETCH_SUCCESS":
      return {
        ...state,
        loading: false,
        data: action.payload,
        error: null
      };
    case "FETCH_ERROR":
      return {
        ...state,
        loading: false,
        error: action.payload
      };
    case "UPDATE_FILTER":
      return {
        ...state,
        filter: {
          ...state.filter,
          ...action.payload
        }
      };
    default:
      return state;
  }
}

function DataProvider({ children }) {
  const [state, dispatch] = React.useReducer(appReducer, {
    data: [],
    loading: false,
    error: null,
    filter: {
      search: "",
      category: "all",
      sortBy: "name"
    }
  });

  const fetchData = React.useCallback(async () => {
    dispatch({ type: "FETCH_START" });
    try {
      const response = await fetch("/api/data");
      const data = await response.json();
      dispatch({ type: "FETCH_SUCCESS", payload: data });
    } catch (error) {
      dispatch({ type: "FETCH_ERROR", payload: error.message });
    }
  }, []);

  const updateFilter = React.useCallback((filter) => {
    dispatch({ type: "UPDATE_FILTER", payload: filter });
  }, []);

  const value = {
    ...state,
    fetchData,
    updateFilter
  };

  return (
    <DataContext.Provider value={value}>
      {children}
    </DataContext.Provider>
  );
}

// 使用Context结合useReducer
const DataContext = React.createContext();

function useData() {
  const context = React.useContext(DataContext);
  if (!context) {
    throw new Error("useData must be used within a DataProvider");
  }
  return context;
}

function DataList() {
  const { data, loading, error, filter } = useData();

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error}</div>;

  const filteredData = data.filter(item => {
    if (filter.search && !item.name.includes(filter.search)) {
      return false;
    }
    if (filter.category !== "all" && item.category !== filter.category) {
      return false;
    }
    return true;
  }).sort((a, b) => {
    if (filter.sortBy === "name") {
      return a.name.localeCompare(b.name);
    }
    if (filter.sortBy === "date") {
      return new Date(b.date) - new Date(a.date);
    }
    return 0;
  });

  return (
    <ul>
      {filteredData.map(item => (
        <li key={item.id}>{item.name}</li>
      ))}
    </ul>
  );
}
```

### 2.2 Effect Hooks

#### 2.2.1 useEffect深入
```jsx
// 基础用法
function Timer() {
  const [count, setCount] = React.useState(0);

  React.useEffect(() => {
    // 副作用：设置定时器
    const timerId = setInterval(() => {
      setCount(prevCount => prevCount + 1);
    }, 1000);

    // 清理函数
    return () => {
      clearInterval(timerId);
    };
  }, []); // 空依赖数组表示只在挂载时运行一次

  return <div>Count: {count}</div>;
}

// 依赖数组的使用
function UserProfile({ userId }) {
  const [user, setUser] = React.useState(null);
  const [loading, setLoading] = React.useState(true);

  React.useEffect(() => {
    setLoading(true);
    
    fetchUser(userId)
      .then(userData => {
        setUser(userData);
        setLoading(false);
      })
      .catch(error => {
        console.error("Failed to fetch user:", error);
        setLoading(false);
      });
  }, [userId]); // 当userId改变时重新执行

  if (loading) return <div>Loading...</div>;
  if (!user) return <div>User not found</div>;

  return <div>{user.name}</div>;
}

// 多个effect的使用
function ChatRoom({ roomId }) {
  const [messages, setMessages] = React.useState([]);
  const [users, setUsers] = React.useState([]);

  // 获取消息
  React.useEffect(() => {
    const unsubscribe = subscribeToMessages(roomId, (newMessage) => {
      setMessages(prev => [...prev, newMessage]);
    });

    return unsubscribe;
  }, [roomId]);

  // 获取在线用户
  React.useEffect(() => {
    const unsubscribe = subscribeToUsers(roomId, (userList) => {
      setUsers(userList);
    });

    return unsubscribe;
  }, [roomId]);

  return (
    <div>
      <UserList users={users} />
      <MessageList messages={messages} />
    </div>
  );
}

// 自定义Hook封装effect逻辑
function useDocumentTitle(title) {
  React.useEffect(() => {
    document.title = title;

    return () => {
      // 清理：恢复原始标题
      document.title = "React App";
    };
  }, [title]);
}

function Page({ title }) {
  useDocumentTitle(title);
  return <div>Page content</div>;
}

// 数据获取的自定义Hook
function useApi(url) {
  const [data, setData] = React.useState(null);
  const [loading, setLoading] = React.useState(true);
  const [error, setError] = React.useState(null);

  React.useEffect(() => {
    let cancelled = false;

    const fetchData = async () => {
      try {
        setLoading(true);
        setError(null);
        
        const response = await fetch(url);
        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        const result = await response.json();
        
        if (!cancelled) {
          setData(result);
          setLoading(false);
        }
      } catch (err) {
        if (!cancelled) {
          setError(err.message);
          setLoading(false);
        }
      }
    };

    fetchData();

    return () => {
      cancelled = true;
    };
  }, [url]);

  return { data, loading, error };
}

// 使用自定义Hook
function UserProfile({ userId }) {
  const { data: user, loading, error } = useApi(`/api/users/${userId}`);

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error}</div>;
  if (!user) return <div>User not found</div>;

  return (
    <div>
      <h1>{user.name}</h1>
      <p>Email: {user.email}</p>
    </div>
  );
}
```

#### 2.2.2 useLayoutEffect和useInsertionEffect
```jsx
// useLayoutEffect - 在DOM更新后同步执行
function Tooltip({ children, text }) {
  const [position, setPosition] = React.useState({ top: 0, left: 0 });
  const triggerRef = React.useRef(null);
  const tooltipRef = React.useRef(null);

  React.useLayoutEffect(() => {
    if (triggerRef.current && tooltipRef.current) {
      const triggerRect = triggerRef.current.getBoundingClientRect();
      const tooltipRect = tooltipRef.current.getBoundingClientRect();
      
      setPosition({
        top: triggerRect.top - tooltipRect.height - 10,
        left: triggerRect.left + (triggerRect.width - tooltipRect.width) / 2
      });
    }
  }, [text]);

  return (
    <div style={{ position: "relative", display: "inline-block" }}>
      <div ref={triggerRef}>{children}</div>
      <div
        ref={tooltipRef}
        style={{
          position: "fixed",
          top: position.top,
          left: position.left,
          background: "black",
          color: "white",
          padding: "4px 8px",
          borderRadius: "4px",
          fontSize: "12px"
        }}
      >
        {text}
      </div>
    </div>
  );
}

// useInsertionEffect - CSS-in-JS库中使用
function useStyle(css) {
  React.useInsertionEffect(() => {
    const style = document.createElement("style");
    style.innerHTML = css;
    document.head.appendChild(style);

    return () => {
      document.head.removeChild(style);
    };
  }, [css]);
}

function StyledComponent() {
  useStyle(`
    .styled-button {
      background: linear-gradient(45deg, #ff6b6b, #4ecdc4);
      border: none;
      color: white;
      padding: 10px 20px;
      border-radius: 5px;
      cursor: pointer;
    }
  `);

  return <button className="styled-button">Styled Button</button>;
}
```

### 2.3 Context Hooks

#### 2.3.1 useContext深入
```jsx
// 创建Context
const ThemeContext = React.createContext("light");
const UserContext = React.createContext(null);

// Context Provider
function App() {
  const [theme, setTheme] = React.useState("light");
  const [user, setUser] = React.useState({ name: "John", role: "admin" });

  const toggleTheme = () => {
    setTheme(prevTheme => prevTheme === "light" ? "dark" : "light");
  };

  return (
    <ThemeContext.Provider value={{ theme, toggleTheme }}>
      <UserContext.Provider value={user}>
        <MainContent />
      </UserContext.Provider>
    </ThemeContext.Provider>
  );
}

// 消费Context
function MainContent() {
  const { theme, toggleTheme } = React.useContext(ThemeContext);
  const user = React.useContext(UserContext);

  return (
    <div className={`app ${theme}`}>
      <h1>Welcome, {user.name}!</h1>
      <button onClick={toggleTheme}>
        Switch to {theme === "light" ? "dark" : "light"} mode
      </button>
      <Content />
    </div>
  );
}

// 自定义Hook简化Context使用
function useTheme() {
  const context = React.useContext(ThemeContext);
  if (!context) {
    throw new Error("useTheme must be used within a ThemeProvider");
  }
  return context;
}

function useUser() {
  const context = React.useContext(UserContext);
  if (!context) {
    throw new Error("useUser must be used within a UserProvider");
  }
  return context;
}

// 使用自定义Hook
function Header() {
  const { theme, toggleTheme } = useTheme();
  const user = useUser();

  return (
    <header className={`header ${theme}`}>
      <h1>Hello, {user.name}</h1>
      <button onClick={toggleTheme}>
        Current theme: {theme}
      </button>
    </header>
  );
}

// 复杂的Context结构
const AppContext = React.createContext();

function AppProvider({ children }) {
  const [state, dispatch] = React.useReducer(appReducer, initialState);
  const [theme, setTheme] = React.useState("light");
  const [notifications, setNotifications] = React.useState([]);

  const addNotification = React.useCallback((notification) => {
    setNotifications(prev => [...prev, { ...notification, id: Date.now() }]);
  }, []);

  const removeNotification = React.useCallback((id) => {
    setNotifications(prev => prev.filter(n => n.id !== id));
  }, []);

  const value = {
    ...state,
    theme,
    setTheme,
    notifications,
    addNotification,
    removeNotification,
    dispatch
  };

  return (
    <AppContext.Provider value={value}>
      {children}
    </AppContext.Provider>
  );
}

function useApp() {
  const context = React.useContext(AppContext);
  if (!context) {
    throw new Error("useApp must be used within an AppProvider");
  }
  return context;
}
```

### 2.4 Ref Hooks

#### 2.4.1 useRef深入
```jsx
// 基础用法 - 访问DOM元素
function TextInputWithFocusButton() {
  const inputRef = React.useRef(null);

  const focusInput = () => {
    inputRef.current.focus();
  };

  return (
    <div>
      <input ref={inputRef} type="text" />
      <button onClick={focusInput}>Focus the input</button>
    </div>
  );
}

// 保存可变值
function Timer() {
  const [count, setCount] = React.useState(0);
  const intervalRef = React.useRef(null);

  React.useEffect(() => {
    intervalRef.current = setInterval(() => {
      setCount(prevCount => prevCount + 1);
    }, 1000);

    return () => {
      clearInterval(intervalRef.current);
    };
  }, []);

  const stopTimer = () => {
    clearInterval(intervalRef.current);
  };

  return (
    <div>
      <p>Count: {count}</p>
      <button onClick={stopTimer}>Stop Timer</button>
    </div>
  );
}

// 获取前一个值
function usePrevious(value) {
  const ref = React.useRef();
  React.useEffect(() => {
    ref.current = value;
  });
  return ref.current;
}

function Counter() {
  const [count, setCount] = React.useState(0);
  const previousCount = usePrevious(count);

  return (
    <div>
      <p>Current: {count}</p>
      <p>Previous: {previousCount}</p>
      <button onClick={() => setCount(count + 1)}>Increment</button>
    </div>
  );
}

// 自定义Hook使用useRef
function useHover() {
  const [isHovering, setIsHovering] = React.useState(false);
  const ref = React.useRef(null);

  const handleMouseEnter = () => setIsHovering(true);
  const handleMouseLeave = () => setIsHovering(false);

  React.useEffect(() => {
    const node = ref.current;
    if (node) {
      node.addEventListener("mouseenter", handleMouseEnter);
      node.addEventListener("mouseleave", handleMouseLeave);

      return () => {
        node.removeEventListener("mouseenter", handleMouseEnter);
        node.removeEventListener("mouseleave", handleMouseLeave);
      };
    }
  }, []);

  return [ref, isHovering];
}

function HoverComponent() {
  const [ref, isHovering] = useHover();

  return (
    <div
      ref={ref}
      style={{
        background: isHovering ? "lightblue" : "lightgray",
        padding: "20px",
        cursor: "pointer"
      }}
    >
      {isHovering ? "Hovering!" : "Hover over me"}
    </div>
  );
}
```

#### 2.4.2 useImperativeHandle和forwardRef
```jsx
// forwardRef - 转发ref到子组件
const FancyInput = React.forwardRef((props, ref) => {
  const inputRef = React.useRef();

  React.useImperativeHandle(ref, () => ({
    focus: () => {
      inputRef.current.focus();
    },
    blur: () => {
      inputRef.current.blur();
    },
    getValue: () => {
      return inputRef.current.value;
    },
    setValue: (value) => {
      inputRef.current.value = value;
    }
  }));

  return <input ref={inputRef} {...props} />;
});

function ParentComponent() {
  const fancyInputRef = React.useRef();

  const handleFocusClick = () => {
    fancyInputRef.current.focus();
  };

  const handleGetValueClick = () => {
    const value = fancyInputRef.current.getValue();
    console.log("Input value:", value);
  };

  return (
    <div>
      <FancyInput ref={fancyInputRef} placeholder="Type something..." />
      <button onClick={handleFocusClick}>Focus Input</button>
      <button onClick={handleGetValueClick}>Get Value</button>
    </div>
  );
}

// 复杂的自定义组件示例
const CustomModal = React.forwardRef((props, ref) => {
  const [isOpen, setIsOpen] = React.useState(false);
  const modalRef = React.useRef();

  React.useImperativeHandle(ref, () => ({
    open: () => setIsOpen(true),
    close: () => setIsOpen(false),
    toggle: () => setIsOpen(prev => !prev),
    isOpen: () => isOpen
  }));

  const handleOverlayClick = (e) => {
    if (e.target === modalRef.current) {
      setIsOpen(false);
    }
  };

  if (!isOpen) return null;

  return (
    <div
      className="modal-overlay"
      ref={modalRef}
      onClick={handleOverlayClick}
    >
      <div className="modal-content">
        <button onClick={() => setIsOpen(false)}>Close</button>
        {props.children}
      </div>
    </div>
  );
});

function ModalExample() {
  const modalRef = React.useRef();

  return (
    <div>
      <button onClick={() => modalRef.current.open()}>
        Open Modal
      </button>
      <CustomModal ref={modalRef}>
        <h2>Modal Content</h2>
        <p>This is a custom modal component.</p>
      </CustomModal>
    </div>
  );
}
```

## 3. React性能优化

### 3.1 组件优化策略

#### 3.1.1 React.memo
```jsx
// 基础的React.memo使用
const ExpensiveComponent = React.memo(function ExpensiveComponent({ name, age }) {
  console.log("Rendering ExpensiveComponent");
  
  // 模拟昂贵的计算
  const expensiveValue = React.useMemo(() => {
    console.log("Performing expensive calculation");
    return name.length * age;
  }, [name, age]);

  return (
    <div>
      <p>Name: {name}</p>
      <p>Age: {age}</p>
      <p>Expensive Value: {expensiveValue}</p>
    </div>
  );
});

function ParentComponent() {
  const [count, setCount] = React.useState(0);
  const [name, setName] = React.useState("Alice");

  return (
    <div>
      <button onClick={() => setCount(count + 1)}>
        Count: {count}
      </button>
      <button onClick={() => setName(name === "Alice" ? "Bob" : "Alice")}>
        Change Name
      </button>
      <ExpensiveComponent name={name} age={25} />
    </div>
  );
}

// 自定义比较函数
const UserComponent = React.memo(function UserComponent({ user, onUpdate }) {
  console.log("Rendering UserComponent");
  
  return (
    <div>
      <h3>{user.name}</h3>
      <p>Email: {user.email}</p>
      <button onClick={() => onUpdate(user.id)}>Update</button>
    </div>
  );
}, (prevProps, nextProps) => {
  // 只有当user.id或user.name改变时才重新渲染
  return (
    prevProps.user.id === nextProps.user.id &&
    prevProps.user.name === nextProps.user.name
  );
});

// 使用React.memo的注意事项
function TodoList({ todos, onToggle, onDelete }) {
  return (
    <ul>
      {todos.map(todo => (
        <TodoItem
          key={todo.id}
          todo={todo}
          onToggle={onToggle}
          onDelete={onDelete}
        />
      ))}
    </ul>
  );
}

const TodoItem = React.memo(function TodoItem({ todo, onToggle, onDelete }) {
  return (
    <li className={todo.completed ? "completed" : ""}>
      <span onClick={() => onToggle(todo.id)}>{todo.text}</span>
      <button onClick={() => onDelete(todo.id)}>Delete</button>
    </li>
  );
});
```

#### 3.1.2 useMemo和useCallback
```jsx
// useMemo - 缓存计算结果
function FibonacciCalculator({ n }) {
  const fibonacci = React.useMemo(() => {
    console.log("Calculating Fibonacci...");
    
    const fib = (num) => {
      if (num <= 1) return num;
      return fib(num - 1) + fib(num - 2);
    };
    
    return fib(n);
  }, [n]);

  return (
    <div>
      <p>Fibonacci({n}) = {fibonacci}</p>
    </div>
  );
}

// 复杂的计算缓存
function FilteredList({ items, filter }) {
  const filteredItems = React.useMemo(() => {
    console.log("Filtering items...");
    
    return items.filter(item => {
      if (filter.search && !item.name.toLowerCase().includes(filter.search.toLowerCase())) {
        return false;
      }
      if (filter.category && filter.category !== "all" && item.category !== filter.category) {
        return false;
      }
      if (filter.minPrice && item.price < filter.minPrice) {
        return false;
      }
      if (filter.maxPrice && item.price > filter.maxPrice) {
        return false;
      }
      return true;
    });
  }, [items, filter]);

  const sortedItems = React.useMemo(() => {
    console.log("Sorting items...");
    
    return [...filteredItems].sort((a, b) => {
      switch (filter.sortBy) {
        case "name":
          return a.name.localeCompare(b.name);
        case "price":
          return a.price - b.price;
        case "rating":
          return b.rating - a.rating;
        default:
          return 0;
      }
    });
  }, [filteredItems, filter.sortBy]);

  return (
    <div>
      <p>Found {sortedItems.length} items</p>
      <ul>
        {sortedItems.map(item => (
          <li key={item.id}>
            {item.name} - ${item.price}
          </li>
        ))}
      </ul>
    </div>
  );
}

// useCallback - 缓存函数
function TodoApp() {
  const [todos, setTodos] = React.useState([]);
  const [inputValue, setInputValue] = React.useState("");

  const addTodo = React.useCallback((text) => {
    setTodos(prevTodos => [
      ...prevTodos,
      {
        id: Date.now(),
        text,
        completed: false
      }
    ]);
  }, []);

  const toggleTodo = React.useCallback((id) => {
    setTodos(prevTodos =>
      prevTodos.map(todo =>
        todo.id === id
          ? { ...todo, completed: !todo.completed }
          : todo
      )
    );
  }, []);

  const deleteTodo = React.useCallback((id) => {
    setTodos(prevTodos => prevTodos.filter(todo => todo.id !== id));
  }, []);

  const handleSubmit = React.useCallback((e) => {
    e.preventDefault();
    if (inputValue.trim()) {
      addTodo(inputValue.trim());
      setInputValue("");
    }
  }, [inputValue, addTodo]);

  return (
    <div>
      <form onSubmit={handleSubmit}>
        <input
          type="text"
          value={inputValue}
          onChange={(e) => setInputValue(e.target.value)}
          placeholder="Add a todo..."
        />
        <button type="submit">Add</button>
      </form>
      <TodoList
        todos={todos}
        onToggle={toggleTodo}
        onDelete={deleteTodo}
      />
    </div>
  );
}

// 优化的事件处理器
function SearchComponent({ onSearch }) {
  const [searchTerm, setSearchTerm] = React.useState("");

  // 防抖搜索
  const debouncedSearch = React.useMemo(
    () => debounce(onSearch, 300),
    [onSearch]
  );

  React.useEffect(() => {
    debouncedSearch(searchTerm);
  }, [searchTerm, debouncedSearch]);

  return (
    <input
      type="text"
      value={searchTerm}
      onChange={(e) => setSearchTerm(e.target.value)}
      placeholder="Search..."
    />
  );
}

// 防抖函数实现
function debounce(func, wait) {
  let timeout;
  return function executedFunction(...args) {
    const later = () => {
      clearTimeout(timeout);
      func(...args);
    };
    clearTimeout(timeout);
    timeout = setTimeout(later, wait);
  };
}
```

### 3.2 代码分割和懒加载

#### 3.2.1 React.lazy和Suspense
```jsx
// 基础的懒加载
const LazyComponent = React.lazy(() => import("./LazyComponent"));

function App() {
  return (
    <div>
      <h1>My App</h1>
      <React.Suspense fallback={<div>Loading...</div>}>
        <LazyComponent />
      </React.Suspense>
    </div>
  );
}

// 路由级别的代码分割
import { BrowserRouter as Router, Routes, Route, Link } from "react-router-dom";

const Home = React.lazy(() => import("./pages/Home"));
const About = React.lazy(() => import("./pages/About"));
const Contact = React.lazy(() => import("./pages/Contact"));

function App() {
  return (
    <Router>
      <nav>
        <Link to="/">Home</Link>
        <Link to="/about">About</Link>
        <Link to="/contact">Contact</Link>
      </nav>
      
      <React.Suspense fallback={<div>Loading page...</div>}>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/about" element={<About />} />
          <Route path="/contact" element={<Contact />} />
        </Routes>
      </React.Suspense>
    </Router>
  );
}

// 条件懒加载
function ConditionalComponent({ showComponent }) {
  const [Component, setComponent] = React.useState(null);

  React.useEffect(() => {
    if (showComponent) {
      import("./ConditionalComponent").then(module => {
        setComponent(() => module.default);
      });
    }
  }, [showComponent]);

  if (!Component) return <div>Component not loaded</div>;

  return (
    <React.Suspense fallback={<div>Loading component...</div>}>
      <Component />
    </React.Suspense>
  );
}

// 自定义Suspense边界
class ErrorBoundary extends React.Component {
  constructor(props) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error) {
    return { hasError: true, error };
  }

  componentDidCatch(error, errorInfo) {
    console.error("Error caught by boundary:", error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return (
        <div>
          <h2>Something went wrong.</h2>
          <details>
            {this.state.error && this.state.error.toString()}
          </details>
        </div>
      );
    }

    return this.props.children;
  }
}

function AppWithErrorHandling() {
  return (
    <ErrorBoundary>
      <React.Suspense fallback={<div>Loading...</div>}>
        <LazyComponent />
      </React.Suspense>
    </ErrorBoundary>
  );
}
```

#### 3.2.2 高级代码分割策略
```jsx
// 基于用户交互的懒加载
function InteractiveComponent() {
  const [showDetails, setShowDetails] = React.useState(false);
  const DetailsComponent = React.useMemo(
    () => React.lazy(() => import("./DetailsComponent")),
    []
  );

  return (
    <div>
      <button onClick={() => setShowDetails(true)}>
        Show Details
      </button>
      {showDetails && (
        <React.Suspense fallback={<div>Loading details...</div>}>
          <DetailsComponent />
        </React.Suspense>
      )}
    </div>
  );
}

// 预加载组件
function usePreloadComponent(importFunc) {
  const [component, setComponent] = React.useState(null);
  const [loading, setLoading] = React.useState(false);
  const [error, setError] = React.useState(null);

  const preload = React.useCallback(() => {
    if (component) return;

    setLoading(true);
    setError(null);

    importFunc()
      .then(module => {
        setComponent(() => module.default);
        setLoading(false);
      })
      .catch(err => {
        setError(err);
        setLoading(false);
      });
  }, [importFunc, component]);

  return { component, loading, error, preload };
}

function PreloadExample() {
  const { component: HeavyComponent, loading, error, preload } = 
    usePreloadComponent(() => import("./HeavyComponent"));

  React.useEffect(() => {
    // 预加载组件
    const timer = setTimeout(preload, 2000);
    return () => clearTimeout(timer);
  }, [preload]);

  return (
    <div>
      <button onClick={preload}>
        {loading ? "Loading..." : "Preload Component"}
      </button>
      {error && <div>Error: {error.message}</div>}
      {component && (
        <React.Suspense fallback={<div>Loading...</div>}>
          <HeavyComponent />
        </React.Suspense>
      )}
    </div>
  );
}

// 动态导入多个组件
function loadComponents() {
  return Promise.all([
    import("./Component1"),
    import("./Component2"),
    import("./Component3")
  ]);
}

function MultipleComponentsExample() {
  const [components, setComponents] = React.useState({});
  const [loading, setLoading] = React.useState(false);

  const loadAllComponents = React.useCallback(async () => {
    setLoading(true);
    try {
      const [module1, module2, module3] = await loadComponents();
      setComponents({
        Component1: module1.default,
        Component2: module2.default,
        Component3: module3.default
      });
    } catch (error) {
      console.error("Failed to load components:", error);
    } finally {
      setLoading(false);
    }
  }, []);

  return (
    <div>
      <button onClick={loadAllComponents} disabled={loading}>
        {loading ? "Loading..." : "Load All Components"}
      </button>
      
      <React.Suspense fallback={<div>Loading components...</div>}>
        {components.Component1 && <components.Component1 />}
        {components.Component2 && <components.Component2 />}
        {components.Component3 && <components.Component3 />}
      </React.Suspense>
    </div>
  );
}
```

## 4. React生态系统

### 4.1 状态管理

#### 4.1.1 Redux集成
```jsx
// Redux store配置
import { configureStore, createSlice } from "@reduxjs/toolkit";

// 创建slice
const counterSlice = createSlice({
  name: "counter",
  initialState: {
    value: 0,
    status: "idle"
  },
  reducers: {
    increment: (state) => {
      state.value += 1;
    },
    decrement: (state) => {
      state.value -= 1;
    },
    incrementByAmount: (state, action) => {
      state.value += action.payload;
    }
  }
});

const userSlice = createSlice({
  name: "user",
  initialState: {
    currentUser: null,
    loading: false,
    error: null
  },
  reducers: {
    setUser: (state, action) => {
      state.currentUser = action.payload;
    },
    setLoading: (state, action) => {
      state.loading = action.payload;
    },
    setError: (state, action) => {
      state.error = action.payload;
    }
  }
});

// 导出actions
export const { increment, decrement, incrementByAmount } = counterSlice.actions;
export const { setUser, setLoading, setError } = userSlice.actions;

// 配置store
const store = configureStore({
  reducer: {
    counter: counterSlice.reducer,
    user: userSlice.reducer
  },
  middleware: (getDefaultMiddleware) =>
    getDefaultMiddleware({
      serializableCheck: {
        ignoredActions: ["user/setUser"]
      }
    })
});

// React-Redux hooks
import { useSelector, useDispatch } from "react-redux";

function Counter() {
  const count = useSelector((state) => state.counter.value);
  const dispatch = useDispatch();

  return (
    <div>
      <h2>Count: {count}</h2>
      <button onClick={() => dispatch(increment())}>+</button>
      <button onClick={() => dispatch(decrement())}>-</button>
      <button onClick={() => dispatch(incrementByAmount(5))}>+5</button>
    </div>
  );
}

// 异步thunk
const fetchUser = createAsyncThunk(
  "user/fetchUser",
  async (userId, { rejectWithValue }) => {
    try {
      const response = await fetch(`/api/users/${userId}`);
      const data = await response.json();
      return data;
    } catch (error) {
      return rejectWithValue(error.message);
    }
  }
);

// 更新userSlice
const userSlice = createSlice({
  name: "user",
  initialState: {
    currentUser: null,
    loading: false,
    error: null
  },
  reducers: {
    setUser: (state, action) => {
      state.currentUser = action.payload;
    }
  },
  extraReducers: (builder) => {
    builder
      .addCase(fetchUser.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(fetchUser.fulfilled, (state, action) => {
        state.loading = false;
        state.currentUser = action.payload;
      })
      .addCase(fetchUser.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      });
  }
});

function UserProfile({ userId }) {
  const { currentUser, loading, error } = useSelector((state) => state.user);
  const dispatch = useDispatch();

  React.useEffect(() => {
    dispatch(fetchUser(userId));
  }, [dispatch, userId]);

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error}</div>;
  if (!currentUser) return <div>User not found</div>;

  return (
    <div>
      <h1>{currentUser.name}</h1>
      <p>Email: {currentUser.email}</p>
    </div>
  );
}
```

#### 4.1.2 Recoil状态管理
```jsx
// Recoil基础配置
import { atom, selector, useRecoilState, useRecoilValue } from "recoil";

// 定义atom
const textState = atom({
  key: "textState",
  default: ""
});

const todoListState = atom({
  key: "todoListState",
  default: []
});

// 定义selector
const charCountState = selector({
  key: "charCountState",
  get: ({ get }) => {
    const text = get(textState);
    return text.length;
  }
});

const filteredTodoListState = selector({
  key: "filteredTodoListState",
  get: ({ get }) => {
    const filter = get(filterState);
    const list = get(todoListState);
    
    switch (filter) {
      case "Show Completed":
        return list.filter((item) => item.isComplete);
      case "Show Uncompleted":
        return list.filter((item) => !item.isComplete);
      default:
        return list;
    }
  }
});

// 使用atom和selector
function TextInput() {
  const [text, setText] = useRecoilState(textState);
  const charCount = useRecoilValue(charCountState);

  const onChange = (event) => {
    setText(event.target.value);
  };

  return (
    <div>
      <input type="text" value={text} onChange={onChange} />
      <br />
      Character Count: {charCount}
    </div>
  );
}

// TodoList组件
function TodoList() {
  const todoList = useRecoilValue(filteredTodoListState);

  return (
    <ul>
      {todoList.map((todoItem) => (
        <TodoItem key={todoItem.id} item={todoItem} />
      ))}
    </ul>
  );
}

function TodoItem({ item }) {
  const [todoList, setTodoList] = useRecoilState(todoListState);
  const index = todoList.findIndex((listItem) => listItem === item);

  const editItemText = ({ target: { value } }) => {
    const newList = replaceItemAtIndex(todoList, index, {
      ...item,
      text: value
    });
    setTodoList(newList);
  };

  const toggleItemCompletion = () => {
    const newList = replaceItemAtIndex(todoList, index, {
      ...item,
      isComplete: !item.isComplete
    });
    setTodoList(newList);
  };

  const deleteItem = () => {
    const newList = removeItemAtIndex(todoList, index);
    setTodoList(newList);
  };

  return (
    <li>
      <input
        type="text"
        value={item.text}
        onChange={editItemText}
      />
      <input
        type="checkbox"
        checked={item.isComplete}
        onChange={toggleItemCompletion}
      />
      <button onClick={deleteItem}>X</button>
    </li>
  );
}

// 辅助函数
function replaceItemAtIndex(arr, index, newValue) {
  return [...arr.slice(0, index), newValue, ...arr.slice(index + 1)];
}

function removeItemAtIndex(arr, index) {
  return [...arr.slice(0, index), ...arr.slice(index + 1)];
}

// 异步selector
const currentUserNameQuery = selector({
  key: "CurrentUserNameQuery",
  get: async ({ get }) => {
    const response = await fetch("/api/current-user");
    const data = await response.json();
    return data.name;
  }
});

function CurrentUserInfo() {
  const userName = useRecoilValue(currentUserNameQuery);
  return <div>{userName}</div>;
}

// 错误处理和加载状态
const currentUserIDState = atom({
  key: "CurrentUserIDState",
  default: 1
});

const currentUserQuery = selector({
  key: "CurrentUserQuery",
  get: async ({ get }) => {
    const userID = get(currentUserIDState);
    const response = await fetch(`/api/users/${userID}`);
    if (response.status >= 400) {
      throw new Error("User not found");
    }
    const data = await response.json();
    return data;
  }
});

function CurrentUser() {
  const userID = useRecoilValue(currentUserIDState);
  const userQuery = useRecoilValue(currentUserQuery);

  return (
    <div>
      <h1>{userQuery.name}</h1>
      <p>{userQuery.email}</p>
    </div>
  );
}

function ErrorBoundary({ children }) {
  return (
    <React.Suspense fallback={<div>Loading...</div>}>
      <RecoilErrorBoundary children={children} />
    </React.Suspense>
  );
}
```

### 4.2 路由管理

#### 4.2.1 React Router深入
```jsx
// 基础路由配置
import { BrowserRouter as Router, Routes, Route, Link, Navigate } from "react-router-dom";

function App() {
  return (
    <Router>
      <nav>
        <Link to="/">Home</Link>
        <Link to="/about">About</Link>
        <Link to="/contact">Contact</Link>
      </nav>
      
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/about" element={<About />} />
        <Route path="/contact" element={<Contact />} />
        <Route path="/old-path" element={<Navigate to="/new-path" replace />} />
        <Route path="*" element={<NotFound />} />
      </Routes>
    </Router>
  );
}

// 动态路由
function UserList() {
  const [users, setUsers] = React.useState([]);

  React.useEffect(() => {
    fetchUsers().then(setUsers);
  }, []);

  return (
    <div>
      <h2>Users</h2>
      <ul>
        {users.map(user => (
          <li key={user.id}>
            <Link to={`/users/${user.id}`}>{user.name}</Link>
          </li>
        ))}
      </ul>
    </div>
  );
}

function UserDetail() {
  const { userId } = useParams();
  const [user, setUser] = React.useState(null);

  React.useEffect(() => {
    fetchUser(userId).then(setUser);
  }, [userId]);

  if (!user) return <div>Loading...</div>;

  return (
    <div>
      <h2>{user.name}</h2>
      <p>Email: {user.email}</p>
      <Link to="/users">Back to Users</Link>
    </div>
  );
}

// 嵌套路由
function Layout() {
  return (
    <div>
      <header>
        <nav>
          <Link to="/">Home</Link>
          <Link to="/dashboard">Dashboard</Link>
        </nav>
      </header>
      
      <main>
        <Outlet />
      </main>
      
      <footer>
        <p>&copy; 2023 My App</p>
      </footer>
    </div>
  );
}

function Dashboard() {
  return (
    <div>
      <h2>Dashboard</h2>
      <nav>
        <Link to="overview">Overview</Link>
        <Link to="settings">Settings</Link>
        <Link to="reports">Reports</Link>
      </nav>
      
      <Routes>
        <Route path="/" element={<DashboardOverview />} />
        <Route path="overview" element={<DashboardOverview />} />
        <Route path="settings" element={<DashboardSettings />} />
        <Route path="reports" element={<DashboardReports />} />
      </Routes>
    </div>
  );
}

// 路由守卫
function PrivateRoute({ children }) {
  const [isAuthenticated, setIsAuthenticated] = React.useState(false);
  const [loading, setLoading] = React.useState(true);

  React.useEffect(() => {
    checkAuth().then(authenticated => {
      setIsAuthenticated(authenticated);
      setLoading(false);
    });
  }, []);

  if (loading) {
    return <div>Loading...</div>;
  }

  return isAuthenticated ? children : <Navigate to="/login" replace />;
}

function ProtectedPage() {
  return (
    <PrivateRoute>
      <div>This is a protected page</div>
    </PrivateRoute>
  );
}

// 查询参数处理
function SearchResults() {
  const [searchParams] = useSearchParams();
  const query = searchParams.get("q");
  const category = searchParams.get("category");
  const page = searchParams.get("page") || "1";

  const [results, setResults] = React.useState([]);

  React.useEffect(() => {
    searchItems({ query, category, page }).then(setResults);
  }, [query, category, page]);

  return (
    <div>
      <h2>Search Results</h2>
      <p>Query: {query}</p>
      <p>Category: {category}</p>
      <p>Page: {page}</p>
      
      <ul>
        {results.map(item => (
          <li key={item.id}>{item.title}</li>
        ))}
      </ul>
    </div>
  );
}

// 程序化导航
function NavigationExample() {
  const navigate = useNavigate();
  const location = useLocation();

  const goToHome = () => {
    navigate("/");
  };

  const goBack = () => {
    navigate(-1);
  };

  const goForward = () => {
    navigate(1);
  };

  const replaceCurrentPage = () => {
    navigate("/new-page", { replace: true });
  };

  return (
    <div>
      <p>Current path: {location.pathname}</p>
      <button onClick={goToHome}>Go Home</button>
      <button onClick={goBack}>Go Back</button>
      <button onClick={goForward}>Go Forward</button>
      <button onClick={replaceCurrentPage}>Replace Current</button>
    </div>
  );
}
```

#### 4.2.2 高级路由模式
```jsx
// 自定义路由组件
function AppRouter() {
  const [isAuthenticated, setIsAuthenticated] = React.useState(false);
  const [userRole, setUserRole] = React.useState("user");

  const routes = [
    {
      path: "/",
      element: <Home />,
      public: true
    },
    {
      path: "/login",
      element: <Login />,
      public: true
    },
    {
      path: "/dashboard",
      element: <Dashboard />,
      roles: ["user", "admin"]
    },
    {
      path: "/admin",
      element: <AdminPanel />,
      roles: ["admin"]
    },
    {
      path: "/profile",
      element: <UserProfile />,
      roles: ["user", "admin"]
    }
  ];

  const renderRoute = (route) => {
    if (!route.public && !isAuthenticated) {
      return <Navigate to="/login" replace />;
    }

    if (route.roles && !route.roles.includes(userRole)) {
      return <Navigate to="/unauthorized" replace />;
    }

    return route.element;
  };

  return (
    <Router>
      <Routes>
        {routes.map((route, index) => (
          <Route
            key={index}
            path={route.path}
            element={renderRoute(route)}
          />
        ))}
        <Route path="*" element={<NotFound />} />
      </Routes>
    </Router>
  );
}

// 路由动画
import { CSSTransition, TransitionGroup } from "react-transition-group";

function AnimatedRoutes() {
  const location = useLocation();

  return (
    <TransitionGroup>
      <CSSTransition
        key={location.key}
        timeout={300}
        classNames="fade"
      >
        <Routes location={location}>
          <Route path="/" element={<Home />} />
          <Route path="/about" element={<About />} />
          <Route path="/contact" element={<Contact />} />
        </Routes>
      </CSSTransition>
    </TransitionGroup>
  );
}

// 懒加载路由
const Home = React.lazy(() => import("./pages/Home"));
const About = React.lazy(() => import("./pages/About"));
const Contact = React.lazy(() => import("./pages/Contact"));

function LazyRoutes() {
  return (
    <Router>
      <React.Suspense fallback={<div>Loading page...</div>}>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/about" element={<About />} />
          <Route path="/contact" element={<Contact />} />
        </Routes>
      </React.Suspense>
    </Router>
  );
}

// 路由配置文件
export const routeConfig = [
  {
    path: "/",
    component: React.lazy(() => import("./pages/Home")),
    exact: true,
    title: "Home"
  },
  {
    path: "/about",
    component: React.lazy(() => import("./pages/About")),
    title: "About Us"
  },
  {
    path: "/products",
    component: React.lazy(() => import("./pages/Products")),
    title: "Products",
    children: [
      {
        path: "/products/:id",
        component: React.lazy(() => import("./pages/ProductDetail")),
        title: "Product Detail"
      }
    ]
  }
];

function ConfiguredRoutes() {
  const renderRoutes = (routes) => {
    return routes.map((route, index) => {
      if (route.children) {
        return (
          <Route key={index} path={route.path} element={<route.component />}>
            {renderRoutes(route.children)}
          </Route>
        );
      }
      return (
        <Route
          key={index}
          path={route.path}
          element={<route.component />}
        />
      );
    });
  };

  return (
    <Router>
      <React.Suspense fallback={<div>Loading...</div>}>
        <Routes>
          {renderRoutes(routeConfig)}
          <Route path="*" element={<NotFound />} />
        </Routes>
      </React.Suspense>
    </Router>
  );
}
```

## 5. React最佳实践

### 5.1 项目结构

#### 5.1.1 目录组织
```
src/
├── components/          # 可复用组件
│   ├── common/         # 通用组件
│   │   ├── Button/
│   │   │   ├── Button.jsx
│   │   │   ├── Button.module.css
│   │   │   └── index.js
│   │   ├── Input/
│   │   └── Modal/
│   └── features/       # 功能组件
│       ├── UserProfile/
│       └── TodoList/
├── pages/              # 页面组件
│   ├── Home/
│   ├── About/
│   └── Contact/
├── hooks/              # 自定义Hooks
│   ├── useAuth.js
│   ├── useApi.js
│   └── useLocalStorage.js
├── services/           # API服务
│   ├── api.js
│   ├── auth.js
│   └── users.js
├── utils/              # 工具函数
│   ├── helpers.js
│   ├── constants.js
│   └── validators.js
├── store/              # 状态管理
│   ├── index.js
│   ├── slices/
│   └── selectors/
├── styles/             # 样式文件
│   ├── globals.css
│   ├── variables.css
│   └── components/
└── assets/             # 静态资源
    ├── images/
    ├── icons/
    └── fonts/
```

#### 5.1.2 组件命名规范
```jsx
// 组件文件命名：PascalCase
// UserProfile.jsx
// TodoList.jsx
// Button.jsx

// 组件导出规范
// UserProfile.jsx
function UserProfile({ user }) {
  return (
    <div className="user-profile">
      <h2>{user.name}</h2>
      <p>{user.email}</p>
    </div>
  );
}

export default UserProfile;

// 或使用命名导出
export { UserProfile };

// index.js文件 - 重新导出
export { default as UserProfile } from "./UserProfile";
export { default as TodoList } from "./TodoList";
export { default as Button } from "./Button";

// 使用组件
import { UserProfile, TodoList, Button } from "../components";
```

### 5.2 代码规范

#### 5.2.1 ESLint和Prettier配置
```json
// .eslintrc.json
{
  "extends": [
    "react-app",
    "react-app/jest",
    "@typescript-eslint/recommended",
    "prettier"
  ],
  "plugins": ["@typescript-eslint", "prettier"],
  "rules": {
    "prettier/prettier": "error",
    "react/prop-types": "off",
    "react/react-in-jsx-scope": "off",
    "@typescript-eslint/explicit-function-return-type": "off",
    "@typescript-eslint/no-unused-vars": "error",
    "react-hooks/rules-of-hooks": "error",
    "react-hooks/exhaustive-deps": "warn"
  },
  "settings": {
    "react": {
      "version": "detect"
    }
  }
}
```

```json
// .prettierrc
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 80,
  "tabWidth": 2,
  "useTabs": false
}
```

#### 5.2.2 组件编写规范
```jsx
// 好的组件示例
import React, { useState, useEffect, useCallback } from "react";
import PropTypes from "prop-types";
import "./Button.module.css";

/**
 * 通用按钮组件
 * @param {Object} props - 组件属性
 * @param {string} props.children - 按钮内容
 * @param {function} props.onClick - 点击事件处理函数
 * @param {string} props.variant - 按钮变体 (primary, secondary, danger)
 * @param {string} props.size - 按钮大小 (small, medium, large)
 * @param {boolean} props.disabled - 是否禁用
 * @param {string} props.className - 额外的CSS类名
 */
function Button({
  children,
  onClick,
  variant = "primary",
  size = "medium",
  disabled = false,
  className = "",
  ...rest
}) {
  const [isPressed, setIsPressed] = useState(false);

  const handleClick = useCallback(
    (event) => {
      if (!disabled && onClick) {
        onClick(event);
      }
    },
    [disabled, onClick]
  );

  const handleMouseDown = useCallback(() => {
    if (!disabled) {
      setIsPressed(true);
    }
  }, [disabled]);

  const handleMouseUp = useCallback(() => {
    setIsPressed(false);
  }, []);

  const buttonClasses = [
    "btn",
    `btn--${variant}`,
    `btn--${size}`,
    isPressed && "btn--pressed",
    disabled && "btn--disabled",
    className
  ]
    .filter(Boolean)
    .join(" ");

  return (
    <button
      className={buttonClasses}
      onClick={handleClick}
      onMouseDown={handleMouseDown}
      onMouseUp={handleMouseUp}
      disabled={disabled}
      {...rest}
    >
      {children}
    </button>
  );
}

Button.propTypes = {
  children: PropTypes.node.isRequired,
  onClick: PropTypes.func,
  variant: PropTypes.oneOf(["primary", "secondary", "danger"]),
  size: PropTypes.oneOf(["small", "medium", "large"]),
  disabled: PropTypes.bool,
  className: PropTypes.string
};

Button.defaultProps = {
  onClick: null,
  variant: "primary",
  size: "medium",
  disabled: false,
  className: ""
};

export default Button;
```

### 5.3 测试策略

#### 5.3.1 单元测试
```jsx
// Button.test.js
import React from "react";
import { render, screen, fireEvent } from "@testing-library/react";
import "@testing-library/jest-dom";
import Button from "./Button";

describe("Button Component", () => {
  test("renders with default props", () => {
    render(<Button>Click me</Button>);
    
    const button = screen.getByRole("button", { name: /click me/i });
    expect(button).toBeInTheDocument();
    expect(button).toHaveClass("btn btn--primary btn--medium");
  });

  test("renders with custom variant and size", () => {
    render(
      <Button variant="secondary" size="large">
        Large Button
      </Button>
    );
    
    const button = screen.getByRole("button", { name: /large button/i });
    expect(button).toHaveClass("btn btn--secondary btn--large");
  });

  test("calls onClick when clicked", () => {
    const handleClick = jest.fn();
    render(<Button onClick={handleClick}>Click me</Button>);
    
    const button = screen.getByRole("button", { name: /click me/i });
    fireEvent.click(button);
    
    expect(handleClick).toHaveBeenCalledTimes(1);
  });

  test("does not call onClick when disabled", () => {
    const handleClick = jest.fn();
    render(
      <Button onClick={handleClick} disabled>
        Disabled Button
      </Button>
    );
    
    const button = screen.getByRole("button", { name: /disabled button/i });
    fireEvent.click(button);
    
    expect(handleClick).not.toHaveBeenCalled();
    expect(button).toBeDisabled();
  });

  test("applies pressed state on mouse down", () => {
    render(<Button>Press me</Button>);
    
    const button = screen.getByRole("button", { name: /press me/i });
    fireEvent.mouseDown(button);
    
    expect(button).toHaveClass("btn--pressed");
  });
});
```

#### 5.3.2 集成测试
```jsx
// TodoList.test.js
import React from "react";
import { render, screen, fireEvent, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import "@testing-library/jest-dom";
import TodoList from "./TodoList";

describe("TodoList Integration", () => {
  test("adds and toggles todos", async () => {
    const user = userEvent.setup();
    render(<TodoList />);
    
    // 添加新的todo
    const input = screen.getByPlaceholderText(/add a todo/i);
    const addButton = screen.getByRole("button", { name: /add/i });
    
    await user.type(input, "Learn React Testing");
    await user.click(addButton);
    
    // 验证todo已添加
    expect(screen.getByText("Learn React Testing")).toBeInTheDocument();
    
    // 切换todo状态
    const todo = screen.getByText("Learn React Testing");
    await user.click(todo);
    
    // 验证todo已完成
    expect(todo).toHaveClass("completed");
  });

  test("filters todos correctly", async () => {
    const user = userEvent.setup();
    render(<TodoList />);
    
    // 添加多个todos
    const todos = ["Task 1", "Task 2", "Task 3"];
    for (const todo of todos) {
      const input = screen.getByPlaceholderText(/add a todo/i);
      const addButton = screen.getByRole("button", { name: /add/i });
      
      await user.type(input, todo);
      await user.click(addButton);
    }
    
    // 完成第一个todo
    const firstTodo = screen.getByText("Task 1");
    await user.click(firstTodo);
    
    // 过滤已完成的todos
    const filterButton = screen.getByRole("button", { name: /show completed/i });
    await user.click(filterButton);
    
    // 验证只显示已完成的todos
    expect(screen.getByText("Task 1")).toBeInTheDocument();
    expect(screen.queryByText("Task 2")).not.toBeInTheDocument();
    expect(screen.queryByText("Task 3")).not.toBeInTheDocument();
  });
});
```

## 6. 总结

React作为现代前端开发的核心框架，提供了强大的组件化开发能力和丰富的生态系统。通过深入学习React的核心概念、Hooks、性能优化技巧和最佳实践，开发者可以构建高效、可维护的用户界面应用。

### 6.1 关键要点
1. **组件化思维**: 将UI拆分为独立、可复用的组件
2. **Hooks掌握**: 熟练使用各种Hooks管理状态和副作用
3. **性能优化**: 合理使用memo、useMemo、useCallback等优化手段
4. **生态系统**: 掌握Redux、Recoil、React Router等生态工具
5. **最佳实践**: 遵循代码规范，编写可测试、可维护的代码

### 6.2 学习路径
1. **基础阶段**: 掌握JSX、组件、Props、State
2. **进阶阶段**: 深入Hooks、Context、性能优化
3. **高级阶段**: 生态系统集成、架构设计、最佳实践
4. **实战阶段**: 参与实际项目，解决复杂问题

### 6.3 未来发展
- React Server Components
- React 18+的新特性
- 微前端架构
- React Native跨平台开发
- WebAssembly与React结合

持续学习和实践是掌握React的关键，建议结合实际项目不断深化理解和应用。
