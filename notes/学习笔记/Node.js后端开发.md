# Node.js后端开发学习笔记

## 1. Node.js基础回顾

### 1.1 Node.js核心概念

#### 1.1.1 事件循环机制
Node.js采用事件驱动、非阻塞I/O模型，其核心是事件循环（Event Loop）。理解事件循环对于编写高性能的Node.js应用至关重要。

```javascript
// 事件循环阶段演示
console.log("Start");

setTimeout(() => {
  console.log("Timeout callback");
}, 0);

Promise.resolve().then(() => {
  console.log("Promise callback");
});

process.nextTick(() => {
  console.log("NextTick callback");
});

console.log("End");

// 输出顺序：
// Start
// End
// NextTick callback
// Promise callback
// Timeout callback

// 事件循环的六个阶段
// 1. Timers: setTimeout、setInterval
// 2. Pending callbacks: I/O异常回调
// 3. Idle, prepare: 内部使用
// 4. Poll: 获取新的I/O事件
// 5. Check: setImmediate回调
// 6. Close callbacks: 关闭回调

// setImmediate vs setTimeout
setTimeout(() => {
  console.log("setTimeout");
}, 0);

setImmediate(() => {
  console.log("setImmediate");
});

// 在I/O循环中，setImmediate总是先执行
const fs = require("fs");

fs.readFile(__filename, () => {
  setTimeout(() => console.log("timeout"), 0);
  setImmediate(() => console.log("immediate"));
});
```

#### 1.1.2 模块系统
Node.js使用CommonJS模块系统，每个文件都是一个独立的模块。

```javascript
// math.js - 导出模块
function add(a, b) {
  return a + b;
}

function subtract(a, b) {
  return a - b;
}

// 多种导出方式
module.exports = {
  add,
  subtract
};

// 或者
exports.add = add;
exports.subtract = subtract;

// 或者单个导出
module.exports = function(a, b) {
  return a + b;
};

// app.js - 导入模块
const math = require("./math");
const { add, subtract } = require("./math");

console.log(add(5, 3)); // 8
console.log(subtract(10, 4)); // 6

// 内置模块
const fs = require("fs");
const path = require("path");
const http = require("http");

// 第三方模块
const express = require("express");
const lodash = require("lodash");

// 模块缓存
console.log(require.cache); // 查看模块缓存

// 删除模块缓存
delete require.cache[require.resolve("./math")];
```

#### 1.1.3 全局对象和进程
```javascript
// 全局对象
console.log(__filename); // 当前文件路径
console.log(__dirname); // 当前目录路径
console.log(process.cwd()); // 当前工作目录

// process对象
console.log(process.pid); // 进程ID
console.log(process.platform); // 操作系统平台
console.log(process.env.NODE_ENV); // 环境变量

// 进程事件
process.on("exit", (code) => {
  console.log(`Process exiting with code: ${code}`);
});

process.on("uncaughtException", (err) => {
  console.error("Uncaught Exception:", err);
  process.exit(1);
});

process.on("unhandledRejection", (reason, promise) => {
  console.error("Unhandled Rejection at:", promise, "reason:", reason);
});

// 命令行参数
console.log(process.argv); // [node, script.js, arg1, arg2]

// 退出进程
process.exit(0); // 正常退出
process.exit(1); // 异常退出

// 内存使用情况
console.log(process.memoryUsage());
// {
//   rss: 50331648,
//   heapTotal: 20971520,
//   heapUsed: 15728640,
//   external: 1048576,
//   arrayBuffers: 1048576
// }
```

### 1.2 异步编程模式

#### 1.2.1 回调函数
```javascript
// 基础回调函数
function fetchData(callback) {
  setTimeout(() => {
    const data = { id: 1, name: "John" };
    callback(null, data);
  }, 1000);
}

fetchData((error, data) => {
  if (error) {
    console.error("Error:", error);
    return;
  }
  console.log("Data:", data);
});

// 回调地狱问题
function getUser(userId, callback) {
  setTimeout(() => {
    callback(null, { id: userId, name: "User " + userId });
  }, 500);
}

function getPosts(user, callback) {
  setTimeout(() => {
    callback(null, [
      { id: 1, title: "Post 1", userId: user.id },
      { id: 2, title: "Post 2", userId: user.id }
    ]);
  }, 500);
}

function getComments(post, callback) {
  setTimeout(() => {
    callback(null, [
      { id: 1, text: "Comment 1", postId: post.id },
      { id: 2, text: "Comment 2", postId: post.id }
    ]);
  }, 500);
}

// 回调地狱
getUser(1, (error, user) => {
  if (error) return callback(error);
  
  getPosts(user, (error, posts) => {
    if (error) return callback(error);
    
    getComments(posts[0], (error, comments) => {
      if (error) return callback(error);
      
      console.log({ user, posts, comments });
    });
  });
});
```

#### 1.2.2 Promise
```javascript
// 创建Promise
function fetchData() {
  return new Promise((resolve, reject) => {
    setTimeout(() => {
      const data = { id: 1, name: "John" };
      resolve(data);
    }, 1000);
  });
}

// 使用Promise
fetchData()
  .then(data => console.log(data))
  .catch(error => console.error(error));

// Promise链式调用
function getUser(userId) {
  return new Promise((resolve, reject) => {
    setTimeout(() => {
      resolve({ id: userId, name: "User " + userId });
    }, 500);
  });
}

function getPosts(user) {
  return new Promise((resolve, reject) => {
    setTimeout(() => {
      resolve([
        { id: 1, title: "Post 1", userId: user.id },
        { id: 2, title: "Post 2", userId: user.id }
      ]);
    }, 500);
  });
}

function getComments(post) {
  return new Promise((resolve, reject) => {
    setTimeout(() => {
      resolve([
        { id: 1, text: "Comment 1", postId: post.id },
        { id: 2, text: "Comment 2", postId: post.id }
      ]);
    }, 500);
  });
}

// 链式调用避免回调地狱
getUser(1)
  .then(user => getPosts(user))
  .then(posts => getComments(posts[0]))
  .then(comments => console.log(comments))
  .catch(error => console.error(error));

// Promise.all - 并行执行
Promise.all([
  getUser(1),
  getUser(2),
  getUser(3)
])
  .then(users => console.log(users))
  .catch(error => console.error(error));

// Promise.race - 返回最先完成的结果
Promise.race([
  fetchData(),
  new Promise((resolve, reject) => 
    setTimeout(() => reject(new Error("Timeout")), 2000)
  )
])
  .then(data => console.log(data))
  .catch(error => console.error(error));
```

#### 1.2.3 Async/Await
```javascript
// 基础async/await
async function fetchData() {
  return { id: 1, name: "John" };
}

async function main() {
  try {
    const data = await fetchData();
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// 并行执行
async function fetchMultipleUsers() {
  const [user1, user2, user3] = await Promise.all([
    getUser(1),
    getUser(2),
    getUser(3)
  ]);
  
  return { user1, user2, user3 };
}

// 顺序执行vs并行执行
async function sequentialVsParallel() {
  console.time("Sequential");
  const user1 = await getUser(1);
  const user2 = await getUser(2);
  const user3 = await getUser(3);
  console.timeEnd("Sequential"); // 约1500ms
  
  console.time("Parallel");
  const [u1, u2, u3] = await Promise.all([
    getUser(1),
    getUser(2),
    getUser(3)
  ]);
  console.timeEnd("Parallel"); // 约500ms
}

// 错误处理
async function errorHandling() {
  try {
    const data = await Promise.reject(new Error("Something went wrong"));
  } catch (error) {
    console.error("Caught error:", error.message);
  }
}

// async/await重写之前的例子
async function getUserData(userId) {
  try {
    const user = await getUser(userId);
    const posts = await getPosts(user);
    const comments = await getComments(posts[0]);
    
    return { user, posts, comments };
  } catch (error) {
    console.error("Error fetching user data:", error);
    throw error;
  }
}
```

## 2. Express.js框架深入

### 2.1 Express基础

#### 2.1.1 应用创建和配置
```javascript
const express = require("express");
const path = require("path");
const cookieParser = require("cookie-parser");
const logger = require("morgan");

// 创建Express应用
const app = express();

// 基础中间件
app.use(logger("dev")); // 日志中间件
app.use(express.json()); // 解析JSON请求体
app.use(express.urlencoded({ extended: false })); // 解析URL编码请求体
app.use(cookieParser()); // Cookie解析
app.use(express.static(path.join(__dirname, "public"))); // 静态文件服务

// 视图引擎配置
app.set("views", path.join(__dirname, "views"));
app.set("view engine", "ejs");

// 自定义中间件
app.use((req, res, next) => {
  req.requestTime = new Date();
  next();
});

// 路由定义
app.get("/", (req, res) => {
  res.render("index", { 
    title: "Express App",
    requestTime: req.requestTime
  });
});

// 错误处理中间件
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).send("Something broke!");
});

// 404处理
app.use((req, res, next) => {
  res.status(404).send("Sorry, can't find that!");
});

// 启动服务器
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```

#### 2.1.2 路由系统
```javascript
// 基础路由
app.get("/users", (req, res) => {
  res.json([{ id: 1, name: "John" }, { id: 2, name: "Jane" }]);
});

app.post("/users", (req, res) => {
  const user = req.body;
  // 创建用户逻辑
  res.status(201).json(user);
});

app.put("/users/:id", (req, res) => {
  const userId = req.params.id;
  const userData = req.body;
  // 更新用户逻辑
  res.json({ id: userId, ...userData });
});

app.delete("/users/:id", (req, res) => {
  const userId = req.params.id;
  // 删除用户逻辑
  res.status(204).send();
});

// 路由参数
app.get("/users/:id/posts/:postId", (req, res) => {
  const { id, postId } = req.params;
  res.json({ userId: id, postId });
});

// 查询参数
app.get("/search", (req, res) => {
  const { q, page = 1, limit = 10 } = req.query;
  res.json({ query: q, page: parseInt(page), limit: parseInt(limit) });
});

// 路由模块化
// routes/users.js
const express = require("express");
const router = express.Router();

// 中间件 - 所有用户路由都会执行
router.use((req, res, next) => {
  console.log("User route accessed");
  next();
});

// GET /users
router.get("/", (req, res) => {
  res.json([{ id: 1, name: "John" }]);
});

// GET /users/:id
router.get("/:id", (req, res) => {
  const user = { id: req.params.id, name: "User " + req.params.id };
  res.json(user);
});

// POST /users
router.post("/", (req, res) => {
  const user = req.body;
  user.id = Date.now();
  res.status(201).json(user);
});

module.exports = router;

// 在主应用中使用路由
const userRoutes = require("./routes/users");
app.use("/users", userRoutes);
```

### 2.2 中间件系统

#### 2.2.1 应用级中间件
```javascript
// 应用级中间件 - 绑定到app对象
app.use((req, res, next) => {
  console.log(`${req.method} ${req.url}`);
  next();
});

// 路径特定的中间件
app.use("/api", (req, res, next) => {
  req.apiVersion = "v1";
  next();
});

// 错误处理中间件
app.use((err, req, res, next) => {
  console.error(err.stack);
  
  if (err.type === "validation") {
    return res.status(400).json({
      error: "Validation Error",
      message: err.message
    });
  }
  
  res.status(500).json({
    error: "Internal Server Error",
    message: process.env.NODE_ENV === "development" ? err.message : "Something went wrong"
  });
});

// 自定义中间件工厂
function requireAuth(role = "user") {
  return (req, res, next) => {
    const token = req.headers.authorization;
    
    if (!token) {
      return res.status(401).json({ error: "No token provided" });
    }
    
    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      req.user = decoded;
      
      if (role === "admin" && decoded.role !== "admin") {
        return res.status(403).json({ error: "Admin access required" });
      }
      
      next();
    } catch (error) {
      res.status(401).json({ error: "Invalid token" });
    }
  };
}

// 使用中间件
app.get("/admin/users", requireAuth("admin"), (req, res) => {
  res.json({ users: [] });
});
```

#### 2.2.2 内置中间件和第三方中间件
```javascript
// 内置中间件
app.use(express.static("public")); // 静态文件服务
app.use(express.json()); // JSON解析
app.use(express.urlencoded({ extended: true })); // URL编码解析

// 第三方中间件
const cors = require("cors");
const helmet = require("helmet");
const compression = require("compression");
const rateLimit = require("express-rate-limit");

// CORS配置
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(",") || ["http://localhost:3000"],
  credentials: true,
  methods: ["GET", "POST", "PUT", "DELETE"],
  allowedHeaders: ["Content-Type", "Authorization"]
}));

// 安全头设置
app.use(helmet());

// 响应压缩
app.use(compression());

// 速率限制
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15分钟
  max: 100, // 限制每个IP 15分钟内最多100个请求
  message: {
    error: "Too many requests from this IP, please try again later."
  }
});

app.use("/api/", limiter);

// 登录特定的速率限制
const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5,
  message: "Too many login attempts, please try again later."
});

app.post("/api/login", loginLimiter, (req, res) => {
  // 登录逻辑
});
```

### 2.3 错误处理和验证

#### 2.3.1 错误处理策略
```javascript
// 自定义错误类
class AppError extends Error {
  constructor(message, statusCode) {
    super(message);
    this.statusCode = statusCode;
    this.status = `${statusCode}`.startsWith("4") ? "fail" : "error";
    this.isOperational = true;
    
    Error.captureStackTrace(this, this.constructor);
  }
}

// 异步错误处理包装器
const catchAsync = (fn) => {
  return (req, res, next) => {
    fn(req, res, next).catch(next);
  };
};

// 使用示例
app.get("/users/:id", catchAsync(async (req, res, next) => {
  const user = await User.findById(req.params.id);
  
  if (!user) {
    return next(new AppError("User not found", 404));
  }
  
  res.json(user);
}));

// 全局错误处理中间件
const globalErrorHandler = (err, req, res, next) => {
  err.statusCode = err.statusCode || 500;
  err.status = err.status || "error";
  
  if (process.env.NODE_ENV === "development") {
    sendErrorDev(err, res);
  } else {
    sendErrorProd(err, res);
  }
};

const sendErrorDev = (err, res) => {
  res.status(err.statusCode).json({
    status: err.status,
    error: err,
    message: err.message,
    stack: err.stack
  });
};

const sendErrorProd = (err, res) => {
  // 操作性错误：发送给客户端
  if (err.isOperational) {
    res.status(err.statusCode).json({
      status: err.status,
      message: err.message
    });
  } else {
    // 编程错误：不泄露错误详情
    console.error("ERROR 💥", err);
    res.status(500).json({
      status: "error",
      message: "Something went wrong!"
    });
  }
};

// 处理未捕获的异步错误
process.on("unhandledRejection", (err, promise) => {
  console.log("UNHANDLED REJECTION! 💥 Shutting down...");
  console.log(err.name, err.message);
  process.exit(1);
});

// 处理未捕获的异常
process.on("uncaughtException", (err) => {
  console.log("UNCAUGHT EXCEPTION! 💥 Shutting down...");
  console.log(err.name, err.message);
  process.exit(1);
});
```

#### 2.3.2 请求数据验证
```javascript
// 使用express-validator进行验证
const { body, validationResult } = require("express-validator");

// 用户注册验证规则
const validateUserRegistration = [
  body("email")
    .isEmail()
    .normalizeEmail()
    .withMessage("Please provide a valid email"),
  
  body("password")
    .isLength({ min: 8 })
    .withMessage("Password must be at least 8 characters long")
    .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
    .withMessage("Password must contain at least one lowercase letter, one uppercase letter, and one digit"),
  
  body("name")
    .trim()
    .isLength({ min: 2, max: 50 })
    .withMessage("Name must be between 2 and 50 characters"),
  
  body("age")
    .optional()
    .isInt({ min: 0, max: 150 })
    .withMessage("Age must be a number between 0 and 150")
];

// 验证结果检查中间件
const checkValidationResult = (req, res, next) => {
  const errors = validationResult(req);
  
  if (!errors.isEmpty()) {
    const errorMessages = errors.array().map(error => error.msg);
    return next(new AppError(errorMessages.join(", "), 400));
  }
  
  next();
};

// 使用验证
app.post(
  "/api/users/register",
  validateUserRegistration,
  checkValidationResult,
  catchAsync(async (req, res, next) => {
    const { email, password, name, age } = req.body;
    
    // 检查用户是否已存在
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return next(new AppError("User already exists", 400));
    }
    
    // 创建用户
    const user = await User.create({
      email,
      password: await bcrypt.hash(password, 12),
      name,
      age
    });
    
    // 生成JWT
    const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, {
      expiresIn: process.env.JWT_EXPIRES_IN
    });
    
    res.status(201).json({
      status: "success",
      token,
      data: {
        user: {
          id: user._id,
          email: user.email,
          name: user.name
        }
      }
    });
  })
);

// 自定义验证器
const customValidator = (value, { req }) => {
  if (value !== req.body.passwordConfirm) {
    throw new Error("Password confirmation does not match");
  }
  return true;
};

app.post(
  "/api/users/update-password",
  [
    body("password").isLength({ min: 8 }),
    body("passwordConfirm").custom(customValidator)
  ],
  checkValidationResult,
  (req, res) => {
    // 更新密码逻辑
  }
);
```

## 3. 数据库集成

### 3.1 MongoDB集成

#### 3.1.1 Mongoose基础
```javascript
const mongoose = require("mongoose");

// 连接MongoDB
const connectDB = async () => {
  try {
    const conn = await mongoose.connect(process.env.MONGODB_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    
    console.log(`MongoDB Connected: ${conn.connection.host}`);
  } catch (error) {
    console.error("Database connection error:", error);
    process.exit(1);
  }
};

// 定义Schema
const userSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, "Name is required"],
    trim: true,
    maxlength: [50, "Name cannot exceed 50 characters"]
  },
  email: {
    type: String,
    required: [true, "Email is required"],
    unique: true,
    lowercase: true,
    validate: {
      validator: function(email) {
        return /^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/.test(email);
      },
      message: "Please provide a valid email"
    }
  },
  password: {
    type: String,
    required: [true, "Password is required"],
    minlength: [8, "Password must be at least 8 characters long"],
    select: false // 默认查询时不返回密码
  },
  role: {
    type: String,
    enum: ["user", "admin"],
    default: "user"
  },
  age: {
    type: Number,
    min: [0, "Age cannot be negative"],
    max: [150, "Age cannot exceed 150"]
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true, // 自动添加createdAt和updatedAt
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// 虚拟字段
userSchema.virtual("posts", {
  ref: "Post",
  localField: "_id",
  foreignField: "author"
});

// 实例方法
userSchema.methods.correctPassword = async function(candidatePassword) {
  return await bcrypt.compare(candidatePassword, this.password);
};

userSchema.methods.changedPasswordAfter = function(JWTTimestamp) {
  if (this.passwordChangedAt) {
    const changedTimestamp = parseInt(
      this.passwordChangedAt.getTime() / 1000,
      10
    );
    return JWTTimestamp < changedTimestamp;
  }
  return false;
};

// 静态方法
userSchema.statics.findByEmail = function(email) {
  return this.findOne({ email });
};

// 中间件
userSchema.pre("save", async function(next) {
  // 密码加密
  if (!this.isModified("password")) return next();
  
  this.password = await bcrypt.hash(this.password, 12);
  this.passwordConfirm = undefined;
  next();
});

userSchema.pre("save", function(next) {
  // 更新时间戳
  this.updatedAt = Date.now();
  next();
});

// 创建Model
const User = mongoose.model("User", userSchema);

// CRUD操作
class UserService {
  static async createUser(userData) {
    const user = await User.create(userData);
    return user;
  }
  
  static async getUserById(id) {
    const user = await User.findById(id).populate("posts");
    if (!user) {
      throw new AppError("User not found", 404);
    }
    return user;
  }
  
  static async getAllUsers(filter = {}, options = {}) {
    const users = await User.find(filter)
      .select("-password") // 排除密码字段
      .sort(options.sort || "-createdAt")
      .limit(options.limit || 10)
      .skip(options.skip || 0);
    
    const total = await User.countDocuments(filter);
    
    return { users, total };
  }
  
  static async updateUser(id, updateData) {
    const user = await User.findByIdAndUpdate(
      id,
      updateData,
      { new: true, runValidators: true }
    );
    
    if (!user) {
      throw new AppError("User not found", 404);
    }
    
    return user;
  }
  
  static async deleteUser(id) {
    const user = await User.findByIdAndDelete(id);
    
    if (!user) {
      throw new AppError("User not found", 404);
    }
    
    return user;
  }
}
```

#### 3.1.2 高级查询和聚合
```javascript
// 复杂查询
class UserRepository {
  static async findUsersByAgeRange(minAge, maxAge) {
    return await User.find({
      age: { $gte: minAge, $lte: maxAge }
    }).sort({ age: 1 });
  }
  
  static async searchUsers(query) {
    return await User.find({
      $or: [
        { name: { $regex: query, $options: "i" } },
        { email: { $regex: query, $options: "i" } }
      ]
    });
  }
  
  static async getUsersWithPosts() {
    return await User.aggregate([
      {
        $lookup: {
          from: "posts",
          localField: "_id",
          foreignField: "author",
          as: "posts"
        }
      },
      {
        $addFields: {
          postsCount: { $size: "$posts" }
        }
      },
      {
        $match: {
          postsCount: { $gt: 0 }
        }
      },
      {
        $sort: { postsCount: -1 }
      }
    ]);
  }
  
  static async getUserStatistics() {
    return await User.aggregate([
      {
        $group: {
          _id: "$role",
          count: { $sum: 1 },
          avgAge: { $avg: "$age" }
        }
      },
      {
        $project: {
          role: "$_id",
          count: 1,
          avgAge: { $round: ["$avgAge", 2] },
          _id: 0
        }
      }
    ]);
  }
}

// 分页查询
class PaginationService {
  static async getPaginatedResults(model, filter = {}, options = {}) {
    const page = options.page || 1;
    const limit = options.limit || 10;
    const skip = (page - 1) * limit;
    
    const [data, total] = await Promise.all([
      model.find(filter)
        .sort(options.sort || "-createdAt")
        .limit(limit)
        .skip(skip)
        .select(options.select || ""),
      model.countDocuments(filter)
    ]);
    
    const totalPages = Math.ceil(total / limit);
    
    return {
      data,
      pagination: {
        page,
        limit,
        total,
        totalPages,
        hasNext: page < totalPages,
        hasPrev: page > 1
      }
    };
  }
}

// 使用示例
app.get("/api/users", catchAsync(async (req, res) => {
  const { page = 1, limit = 10, search, role } = req.query;
  
  let filter = {};
  if (role) filter.role = role;
  if (search) {
    filter.$or = [
      { name: { $regex: search, $options: "i" } },
      { email: { $regex: search, $options: "i" } }
    ];
  }
  
  const result = await PaginationService.getPaginatedResults(
    User,
    filter,
    {
      page: parseInt(page),
      limit: parseInt(limit),
      sort: "-createdAt",
      select: "-password"
    }
  );
  
  res.json(result);
}));
```

### 3.2 MySQL集成

#### 3.2.1 Sequelize ORM
```javascript
const { Sequelize, DataTypes } = require("sequelize");

// 创建Sequelize实例
const sequelize = new Sequelize(
  process.env.DB_NAME,
  process.env.DB_USER,
  process.env.DB_PASSWORD,
  {
    host: process.env.DB_HOST,
    dialect: "mysql",
    port: process.env.DB_PORT || 3306,
    logging: process.env.NODE_ENV === "development" ? console.log : false,
    pool: {
      max: 5,
      min: 0,
      acquire: 30000,
      idle: 10000
    }
  }
);

// 定义模型
const User = sequelize.define("User", {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  name: {
    type: DataTypes.STRING(50),
    allowNull: false,
    validate: {
      len: [2, 50],
      notEmpty: true
    }
  },
  email: {
    type: DataTypes.STRING(100),
    allowNull: false,
    unique: true,
    validate: {
      isEmail: true
    }
  },
  password: {
    type: DataTypes.STRING(255),
    allowNull: false,
    validate: {
      len: [8, 255]
    }
  },
  role: {
    type: DataTypes.ENUM("user", "admin"),
    defaultValue: "user"
  },
  age: {
    type: DataTypes.INTEGER,
    validate: {
      min: 0,
      max: 150,
      isInt: true
    }
  },
  isActive: {
    type: DataTypes.BOOLEAN,
    defaultValue: true
  }
}, {
  tableName: "users",
  timestamps: true,
  createdAt: "created_at",
  updatedAt: "updated_at",
  indexes: [
    {
      unique: true,
      fields: ["email"]
    }
  ]
});

// 定义关联
const Post = sequelize.define("Post", {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  title: {
    type: DataTypes.STRING(200),
    allowNull: false
  },
  content: {
    type: DataTypes.TEXT,
    allowNull: false
  },
  authorId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: User,
      key: "id"
    }
  }
});

// 设置关联
User.hasMany(Post, { foreignKey: "authorId", as: "posts" });
Post.belongsTo(User, { foreignKey: "authorId", as: "author" });

// 模型方法
User.prototype.toJSON = function() {
  const values = Object.assign({}, this.get());
  delete values.password;
  return values;
};

// 实例方法
User.prototype.getFullName = function() {
  return this.name;
};

// 类方法
User.findByEmail = function(email) {
  return this.findOne({ where: { email } });
};

// Hooks
User.beforeCreate(async (user) => {
  if (user.password) {
    const salt = await bcrypt.genSalt(12);
    user.password = await bcrypt.hash(user.password, salt);
  }
});

User.beforeUpdate(async (user) => {
  if (user.changed("password")) {
    const salt = await bcrypt.genSalt(12);
    user.password = await bcrypt.hash(user.password, salt);
  }
});

// 数据库操作服务
class UserService {
  static async createUser(userData) {
    const user = await User.create(userData);
    return user;
  }
  
  static async getUserById(id) {
    const user = await User.findByPk(id, {
      include: [
        {
          model: Post,
          as: "posts",
          attributes: ["id", "title", "createdAt"]
        }
      ]
    });
    
    if (!user) {
      throw new AppError("User not found", 404);
    }
    
    return user;
  }
  
  static async getAllUsers(options = {}) {
    const { page = 1, limit = 10, search, role } = options;
    
    const where = {};
    if (role) where.role = role;
    if (search) {
      where[Sequelize.Op.or] = [
        { name: { [Sequelize.Op.like]: `%${search}%` } },
        { email: { [Sequelize.Op.like]: `%${search}%` } }
      ];
    }
    
    const offset = (page - 1) * limit;
    
    const { count, rows } = await User.findAndCountAll({
      where,
      limit: parseInt(limit),
      offset,
      order: [["createdAt", "DESC"]],
      attributes: { exclude: ["password"] }
    });
    
    const totalPages = Math.ceil(count / limit);
    
    return {
      users: rows,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: count,
        totalPages,
        hasNext: page < totalPages,
        hasPrev: page > 1
      }
    };
  }
  
  static async updateUser(id, updateData) {
    const [updatedRowsCount] = await User.update(updateData, {
      where: { id },
      returning: true
    });
    
    if (updatedRowsCount === 0) {
      throw new AppError("User not found", 404);
    }
    
    return await User.findByPk(id);
  }
  
  static async deleteUser(id) {
    const deletedRowsCount = await User.destroy({
      where: { id }
    });
    
    if (deletedRowsCount === 0) {
      throw new AppError("User not found", 404);
    }
    
    return true;
  }
}

// 数据库连接和同步
const connectDB = async () => {
  try {
    await sequelize.authenticate();
    console.log("MySQL connection established successfully");
    
    if (process.env.NODE_ENV === "development") {
      await sequelize.sync({ alter: true });
      console.log("Database synchronized");
    }
  } catch (error) {
    console.error("Unable to connect to the database:", error);
    process.exit(1);
  }
};

module.exports = {
  sequelize,
  User,
  Post,
  connectDB
};
```

#### 3.2.2 原生SQL查询
```javascript
// 使用原生SQL查询
class UserRepository {
  static async getUserStatistics() {
    const [results] = await sequelize.query(`
      SELECT 
        role,
        COUNT(*) as count,
        AVG(age) as avg_age,
        MIN(age) as min_age,
        MAX(age) as max_age
      FROM users
      WHERE is_active = true
      GROUP BY role
      ORDER BY count DESC
    `);
    
    return results;
  }
  
  static async getUsersWithPostCount() {
    const [results] = await sequelize.query(`
      SELECT 
        u.id,
        u.name,
        u.email,
        COUNT(p.id) as post_count
      FROM users u
      LEFT JOIN posts p ON u.id = p.author_id
      WHERE u.is_active = true
      GROUP BY u.id, u.name, u.email
      HAVING post_count > 0
      ORDER BY post_count DESC
      LIMIT 10
    `);
    
    return results;
  }
  
  static async searchUsers(query) {
    const [results] = await sequelize.query(`
      SELECT id, name, email, role, created_at
      FROM users
      WHERE is_active = true
      AND (
        name LIKE :query
        OR email LIKE :query
      )
      ORDER BY name
    `, {
      replacements: { query: `%${query}%` },
      type: Sequelize.QueryTypes.SELECT
    });
    
    return results;
  }
}

// 事务处理
class TransactionService {
  static async transferFunds(fromUserId, toUserId, amount) {
    const transaction = await sequelize.transaction();
    
    try {
      // 扣除发送者余额
      const sender = await User.findByPk(fromUserId, { transaction });
      if (sender.balance < amount) {
        throw new Error("Insufficient balance");
      }
      
      await sender.update(
        { balance: sender.balance - amount },
        { transaction }
      );
      
      // 增加接收者余额
      const receiver = await User.findByPk(toUserId, { transaction });
      await receiver.update(
        { balance: receiver.balance + amount },
        { transaction }
      );
      
      // 创建交易记录
      await Transaction.create({
        fromUserId,
        toUserId,
        amount,
        status: "completed"
      }, { transaction });
      
      await transaction.commit();
      
      return { sender, receiver };
    } catch (error) {
      await transaction.rollback();
      throw error;
    }
  }
}
```

## 4. 认证和授权

### 4.1 JWT认证

#### 4.1.1 JWT实现
```javascript
const jwt = require("jsonwebtoken");
const crypto = require("crypto");
const { promisify } = require("util");

// JWT工具类
class JWTService {
  static generateToken(payload, expiresIn = process.env.JWT_EXPIRES_IN) {
    return jwt.sign(payload, process.env.JWT_SECRET, {
      expiresIn,
      issuer: process.env.JWT_ISSUER,
      audience: process.env.JWT_AUDIENCE
    });
  }
  
  static async verifyToken(token) {
    return await promisify(jwt.verify)(token, process.env.JWT_SECRET);
  }
  
  static generateRefreshToken() {
    return crypto.randomBytes(64).toString("hex");
  }
  
  static async generateAuthTokens(user) {
    const payload = {
      id: user.id,
      email: user.email,
      role: user.role
    };
    
    const accessToken = this.generateToken(payload);
    const refreshToken = this.generateRefreshToken();
    
    // 保存refresh token到数据库
    await RefreshToken.create({
      token: refreshToken,
      userId: user.id,
      expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000) // 7天
    });
    
    return {
      accessToken,
      refreshToken,
      expiresIn: process.env.JWT_EXPIRES_IN
    };
  }
}

// 认证中间件
const authenticate = async (req, res, next) => {
  try {
    // 1. 获取token
    let token;
    if (req.headers.authorization && req.headers.authorization.startsWith("Bearer")) {
      token = req.headers.authorization.split(" ")[1];
    }
    
    if (!token) {
      return next(new AppError("You are not logged in! Please log in to get access.", 401));
    }
    
    // 2. 验证token
    const decoded = await JWTService.verifyToken(token);
    
    // 3. 检查用户是否仍然存在
    const currentUser = await User.findById(decoded.id);
    if (!currentUser) {
      return next(new AppError("The user belonging to this token does no longer exist.", 401));
    }
    
    // 4. 检查用户是否在JWT签发后更改了密码
    if (await currentUser.changedPasswordAfter(decoded.iat)) {
      return next(new AppError("User recently changed password! Please log in again.", 401));
    }
    
    // 5. 授权访问受保护的路由
    req.user = currentUser;
    next();
  } catch (error) {
    return next(new AppError("Invalid token", 401));
  }
};

// 权限授权中间件
const restrictTo = (...roles) => {
  return (req, res, next) => {
    if (!roles.includes(req.user.role)) {
      return next(new AppError("You do not have permission to perform this action", 403));
    }
    next();
  };
};

// 登录控制器
class AuthController {
  static login = catchAsync(async (req, res, next) => {
    const { email, password } = req.body;
    
    // 1. 检查邮箱和密码是否提供
    if (!email || !password) {
      return next(new AppError("Please provide email and password!", 400));
    }
    
    // 2. 检查用户是否存在且密码正确
    const user = await User.findOne({ email }).select("+password");
    
    if (!user || !(await user.correctPassword(password, user.password))) {
      return next(new AppError("Incorrect email or password", 401));
    }
    
    // 3. 如果一切正常，发送token给客户端
    const tokens = await JWTService.generateAuthTokens(user);
    
    // 设置HTTP-only cookie
    res.cookie("jwt", tokens.accessToken, {
      expires: new Date(
        Date.now() + process.env.JWT_COOKIE_EXPIRES_IN * 24 * 60 * 60 * 1000
      ),
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      sameSite: "strict"
    });
    
    res.status(200).json({
      status: "success",
      tokens,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        role: user.role
      }
    });
  });
  
  static signup = catchAsync(async (req, res, next) => {
    const { name, email, password, passwordConfirm } = req.body;
    
    const newUser = await User.create({
      name,
      email,
      password,
      passwordConfirm
    });
    
    const tokens = await JWTService.generateAuthTokens(newUser);
    
    res.cookie("jwt", tokens.accessToken, {
      expires: new Date(
        Date.now() + process.env.JWT_COOKIE_EXPIRES_IN * 24 * 60 * 60 * 1000
      ),
      httpOnly: true,
      secure: process.env.NODE_ENV === "production"
    });
    
    newUser.password = undefined; // 不在响应中返回密码
    
    res.status(201).json({
      status: "success",
      tokens,
      user: newUser
    });
  });
  
  static logout = (req, res) => {
    res.cookie("jwt", "loggedout", {
      expires: new Date(Date.now() + 10 * 1000),
      httpOnly: true
    });
    
    res.status(200).json({ status: "success" });
  };
  
  static refreshToken = catchAsync(async (req, res, next) => {
    const { refreshToken } = req.body;
    
    if (!refreshToken) {
      return next(new AppError("Refresh token is required", 400));
    }
    
    // 查找refresh token
    const tokenDoc = await RefreshToken.findOne({
      where: { token: refreshToken },
      include: [{ model: User, as: "user" }]
    });
    
    if (!tokenDoc || tokenDoc.expiresAt < new Date()) {
      return next(new AppError("Invalid or expired refresh token", 401));
    }
    
    // 生成新的access token
    const payload = {
      id: tokenDoc.user.id,
      email: tokenDoc.user.email,
      role: tokenDoc.user.role
    };
    
    const accessToken = JWTService.generateToken(payload);
    
    res.json({
      status: "success",
      accessToken,
      expiresIn: process.env.JWT_EXPIRES_IN
    });
  });
}

// 使用认证中间件
app.post("/api/auth/login", AuthController.login);
app.post("/api/auth/signup", AuthController.signup);
app.post("/api/auth/logout", AuthController.logout);
app.post("/api/auth/refresh-token", AuthController.refreshToken);

// 保护路由
app.use("/api/protected", authenticate);

// 角色授权
app.get("/api/admin/users", authenticate, restrictTo("admin"), async (req, res) => {
  const users = await User.find({});
  res.json({ users });
});
```

#### 4.1.2 OAuth2.0集成
```javascript
const passport = require("passport");
const GoogleStrategy = require("passport-google-oauth20").Strategy;
const FacebookStrategy = require("passport-facebook").Strategy;

// Google OAuth策略
passport.use(new GoogleStrategy({
  clientID: process.env.GOOGLE_CLIENT_ID,
  clientSecret: process.env.GOOGLE_CLIENT_SECRET,
  callbackURL: "/api/auth/google/callback"
}, async (accessToken, refreshToken, profile, done) => {
  try {
    let user = await User.findOne({ googleId: profile.id });
    
    if (user) {
      return done(null, user);
    }
    
    // 如果用户不存在，创建新用户
    user = await User.create({
      googleId: profile.id,
      name: profile.displayName,
      email: profile.emails[0].value,
      avatar: profile.photos[0].value,
      password: "default", // OAuth用户使用默认密码
      emailVerified: true
    });
    
    done(null, user);
  } catch (error) {
    done(error, null);
  }
}));

// Facebook OAuth策略
passport.use(new FacebookStrategy({
  clientID: process.env.FACEBOOK_APP_ID,
  clientSecret: process.env.FACEBOOK_APP_SECRET,
  callbackURL: "/api/auth/facebook/callback",
  profileFields: ["id", "displayName", "emails", "photos"]
}, async (accessToken, refreshToken, profile, done) => {
  try {
    let user = await User.findOne({ facebookId: profile.id });
    
    if (user) {
      return done(null, user);
    }
    
    user = await User.create({
      facebookId: profile.id,
      name: profile.displayName,
      email: profile.emails[0].value,
      avatar: profile.photos[0].value,
      password: "default",
      emailVerified: true
    });
    
    done(null, user);
  } catch (error) {
    done(error, null);
  }
}));

// 序列化和反序列化用户
passport.serializeUser((user, done) => {
  done(null, user.id);
});

passport.deserializeUser(async (id, done) => {
  try {
    const user = await User.findById(id);
    done(null, user);
  } catch (error) {
    done(error, null);
  }
});

// OAuth路由
app.get("/api/auth/google", passport.authenticate("google", {
  scope: ["profile", "email"]
}));

app.get("/api/auth/google/callback", 
  passport.authenticate("google", { session: false }),
  async (req, res) => {
    try {
      const tokens = await JWTService.generateAuthTokens(req.user);
      
      res.cookie("jwt", tokens.accessToken, {
        expires: new Date(Date.now() + process.env.JWT_COOKIE_EXPIRES_IN * 24 * 60 * 60 * 1000),
        httpOnly: true,
        secure: process.env.NODE_ENV === "production"
      });
      
      res.redirect(`${process.env.FRONTEND_URL}/auth/success?token=${tokens.accessToken}`);
    } catch (error) {
      res.redirect(`${process.env.FRONTEND_URL}/auth/error`);
    }
  }
);

app.get("/api/auth/facebook", passport.authenticate("facebook", {
  scope: ["email"]
}));

app.get("/api/auth/facebook/callback",
  passport.authenticate("facebook", { session: false }),
  async (req, res) => {
    try {
      const tokens = await JWTService.generateAuthTokens(req.user);
      
      res.cookie("jwt", tokens.accessToken, {
        expires: new Date(Date.now() + process.env.JWT_COOKIE_EXPIRES_IN * 24 * 60 * 60 * 1000),
        httpOnly: true,
        secure: process.env.NODE_ENV === "production"
      });
      
      res.redirect(`${process.env.FRONTEND_URL}/auth/success?token=${tokens.accessToken}`);
    } catch (error) {
      res.redirect(`${process.env.FRONTEND_URL}/auth/error`);
    }
  }
);
```

### 4.2 基于角色的访问控制

#### 4.2.1 RBAC系统设计
```javascript
// 权限模型
const Permission = sequelize.define("Permission", {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  name: {
    type: DataTypes.STRING(100),
    allowNull: false,
    unique: true
  },
  description: {
    type: DataTypes.STRING(255)
  },
  resource: {
    type: DataTypes.STRING(50),
    allowNull: false
  },
  action: {
    type: DataTypes.STRING(50),
    allowNull: false
  }
});

const Role = sequelize.define("Role", {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  name: {
    type: DataTypes.STRING(50),
    allowNull: false,
    unique: true
  },
  description: {
    type: DataTypes.STRING(255)
  }
});

// 多对多关联表
const RolePermission = sequelize.define("RolePermission", {}, {
  timestamps: false
});

const UserRole = sequelize.define("UserRole", {}, {
  timestamps: false
});

// 设置关联
Role.belongsToMany(Permission, { through: RolePermission });
Permission.belongsToMany(Role, { through: RolePermission });
User.belongsToMany(Role, { through: UserRole });
Role.belongsToMany(User, { through: UserRole });

// RBAC服务类
class RBACService {
  static async createRole(roleData, permissions = []) {
    const role = await Role.create(roleData);
    
    if (permissions.length > 0) {
      const permissionRecords = await Permission.findAll({
        where: { name: permissions }
      });
      await role.setPermissions(permissionRecords);
    }
    
    return role;
  }
  
  static async assignRoleToUser(userId, roleName) {
    const user = await User.findByPk(userId);
    const role = await Role.findOne({ where: { name: roleName } });
    
    if (!user || !role) {
      throw new AppError("User or role not found", 404);
    }
    
    await user.addRole(role);
    return true;
  }
  
  static async getUserPermissions(userId) {
    const user = await User.findByPk(userId, {
      include: [
        {
          model: Role,
          as: "roles",
          include: [
            {
              model: Permission,
              as: "permissions"
            }
          ]
        }
      ]
    });
    
    const permissions = new Set();
    user.roles.forEach(role => {
      role.permissions.forEach(permission => {
        permissions.add(permission.name);
      });
    });
    
    return Array.from(permissions);
  }
  
  static async checkPermission(userId, permissionName) {
    const userPermissions = await this.getUserPermissions(userId);
    return userPermissions.includes(permissionName);
  }
}

// 权限检查中间件
const requirePermission = (permissionName) => {
  return async (req, res, next) => {
    try {
      const hasPermission = await RBACService.checkPermission(
        req.user.id,
        permissionName
      );
      
      if (!hasPermission) {
        return next(new AppError("Insufficient permissions", 403));
      }
      
      next();
    } catch (error) {
      return next(new AppError("Permission check failed", 500));
    }
  };
};

// 资源权限检查中间件
const requireResourcePermission = (resource, action) => {
  return async (req, res, next) => {
    try {
      const permissionName = `${resource}:${action}`;
      const hasPermission = await RBACService.checkPermission(
        req.user.id,
        permissionName
      );
      
      if (!hasPermission) {
        return next(new AppError(`Insufficient permissions for ${action} on ${resource}`, 403));
      }
      
      next();
    } catch (error) {
      return next(new AppError("Permission check failed", 500));
    }
  };
};

// 使用RBAC中间件
app.get("/api/users", 
  authenticate, 
  requirePermission("users:read"), 
  async (req, res) => {
    const users = await User.findAll();
    res.json({ users });
  }
);

app.post("/api/users", 
  authenticate, 
  requirePermission("users:create"), 
  async (req, res) => {
    const user = await User.create(req.body);
    res.status(201).json({ user });
  }
);

app.put("/api/users/:id", 
  authenticate, 
  requireResourcePermission("users", "update"), 
  async (req, res) => {
    const user = await User.findByPk(req.params.id);
    if (!user) {
      return next(new AppError("User not found", 404));
    }
    
    await user.update(req.body);
    res.json({ user });
  }
);

// 初始化默认角色和权限
class RBACInitializer {
  static async initialize() {
    // 创建默认权限
    const permissions = [
      // 用户权限
      { name: "users:read", resource: "users", action: "read", description: "Read users" },
      { name: "users:create", resource: "users", action: "create", description: "Create users" },
      { name: "users:update", resource: "users", action: "update", description: "Update users" },
      { name: "users:delete", resource: "users", action: "delete", description: "Delete users" },
      
      // 文章权限
      { name: "posts:read", resource: "posts", action: "read", description: "Read posts" },
      { name: "posts:create", resource: "posts", action: "create", description: "Create posts" },
      { name: "posts:update", resource: "posts", action: "update", description: "Update posts" },
      { name: "posts:delete", resource: "posts", action: "delete", description: "Delete posts" },
      
      // 管理员权限
      { name: "admin:dashboard", resource: "admin", action: "dashboard", description: "Access admin dashboard" },
      { name: "admin:settings", resource: "admin", action: "settings", description: "Manage system settings" }
    ];
    
    for (const permission of permissions) {
      await Permission.findOrCreate({
        where: { name: permission.name },
        defaults: permission
      });
    }
    
    // 创建默认角色
    const roles = [
      { name: "admin", description: "System administrator" },
      { name: "editor", description: "Content editor" },
      { name: "user", description: "Regular user" }
    ];
    
    for (const role of roles) {
      await Role.findOrCreate({
        where: { name: role.name },
        defaults: role
      });
    }
    
    // 分配权限给角色
    const adminRole = await Role.findOne({ where: { name: "admin" } });
    const allPermissions = await Permission.findAll();
    await adminRole.setPermissions(allPermissions);
    
    const editorRole = await Role.findOne({ where: { name: "editor" } });
    const editorPermissions = await Permission.findAll({
      where: {
        name: {
          [Sequelize.Op.in]: [
            "posts:read", "posts:create", "posts:update", "users:read"
          ]
        }
      }
    });
    await editorRole.setPermissions(editorPermissions);
    
    const userRole = await Role.findOne({ where: { name: "user" } });
    const userPermissions = await Permission.findAll({
      where: {
        name: {
          [Sequelize.Op.in]: [
            "posts:read", "users:read"
          ]
        }
      }
    });
    await userRole.setPermissions(userPermissions);
    
    console.log("RBAC system initialized successfully");
  }
}
```

## 5. API设计和文档

### 5.1 RESTful API设计

#### 5.1.1 API设计原则
```javascript
// RESTful API路由设计
// 资源命名规范 - 使用名词复数
app.get("/api/v1/users"); // 获取用户列表
app.get("/api/v1/users/:id"); // 获取特定用户
app.post("/api/v1/users"); // 创建用户
app.put("/api/v1/users/:id"); // 更新用户
app.patch("/api/v1/users/:id"); // 部分更新用户
app.delete("/api/v1/users/:id"); // 删除用户

// 嵌套资源
app.get("/api/v1/users/:userId/posts"); // 获取用户的文章
app.post("/api/v1/users/:userId/posts"); // 为用户创建文章

// 查询参数设计
app.get("/api/v1/users", (req, res) => {
  const {
    page = 1,
    limit = 10,
    sort = "createdAt",
    order = "desc",
    search,
    role,
    isActive
  } = req.query;
  
  // 构建查询
  const filter = {};
  if (role) filter.role = role;
  if (isActive !== undefined) filter.isActive = isActive === "true";
  if (search) {
    filter.$or = [
      { name: { $regex: search, $options: "i" } },
      { email: { $regex: search, $options: "i" } }
    ];
  }
  
  const options = {
    page: parseInt(page),
    limit: parseInt(limit),
    sort: { [sort]: order === "desc" ? -1 : 1 }
  };
  
  // 执行查询...
});

// 响应格式标准化
const sendResponse = (res, statusCode, status, data, message = null) => {
  const response = {
    status,
    data
  };
  
  if (message) {
    response.message = message;
  }
  
  // 添加元数据（分页信息等）
  if (data.pagination) {
    response.pagination = data.pagination;
    response.data = data.data;
  }
  
  res.status(statusCode).json(response);
};

// 成功响应
app.get("/api/v1/users", async (req, res, next) => {
  try {
    const result = await UserService.getAllUsers(req.query);
    sendResponse(res, 200, "success", result);
  } catch (error) {
    next(error);
  }
});

// 错误响应处理
const sendError = (err, req, res, next) => {
  const statusCode = err.statusCode || 500;
  const status = err.status || "error";
  
  const response = {
    status,
    message: err.message
  };
  
  if (process.env.NODE_ENV === "development") {
    response.error = err;
    response.stack = err.stack;
  }
  
  // 验证错误的详细字段
  if (err.errors && Array.isArray(err.errors)) {
    response.errors = err.errors.map(error => ({
      field: error.field || error.param,
      message: error.msg
    }));
  }
  
  res.status(statusCode).json(response);
};

// API版本控制
// 1. URL版本控制
app.get("/api/v1/users", getUserHandlerV1);
app.get("/api/v2/users", getUserHandlerV2);

// 2. 请求头版本控制
app.get("/api/users", (req, res, next) => {
  const version = req.headers["api-version"] || "v1";
  
  if (version === "v1") {
    return getUserHandlerV1(req, res, next);
  } else if (version === "v2") {
    return getUserHandlerV2(req, res, next);
  }
  
  res.status(400).json({ error: "Unsupported API version" });
});

// 3. 查询参数版本控制
app.get("/api/users", (req, res, next) => {
  const version = req.query.version || "v1";
  
  if (version === "v1") {
    return getUserHandlerV1(req, res, next);
  } else if (version === "v2") {
    return getUserHandlerV2(req, res, next);
  }
  
  res.status(400).json({ error: "Unsupported API version" });
});
```

#### 5.1.2 高级API特性
```javascript
// 批量操作
app.post("/api/v1/users/batch", async (req, res, next) => {
  try {
    const { action, userIds, data } = req.body;
    
    let result;
    switch (action) {
      case "delete":
        result = await UserService.batchDelete(userIds);
        break;
      case "update":
        result = await UserService.batchUpdate(userIds, data);
        break;
      default:
        throw new AppError("Invalid batch action", 400);
    }
    
    sendResponse(res, 200, "success", result);
  } catch (error) {
    next(error);
  }
});

// 字段选择
app.get("/api/v1/users", async (req, res, next) => {
  try {
    const { fields } = req.query;
    
    let selectFields = {};
    if (fields) {
      fields.split(",").forEach(field => {
        selectFields[field.trim()] = 1;
      });
    }
    
    const users = await User.find({}).select(selectFields);
    sendResponse(res, 200, "success", { users });
  } catch (error) {
    next(error);
  }
});

// 数据导出
app.get("/api/v1/users/export", async (req, res, next) => {
  try {
    const { format = "json", fields } = req.query;
    
    const users = await UserService.getAllUsers();
    
    if (format === "csv") {
      const csv = convertToCSV(users, fields);
      res.setHeader("Content-Type", "text/csv");
      res.setHeader("Content-Disposition", "attachment; filename=users.csv");
      res.send(csv);
    } else if (format === "xlsx") {
      const workbook = createExcelWorkbook(users, fields);
      res.setHeader("Content-Type", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
      res.setHeader("Content-Disposition", "attachment; filename=users.xlsx");
      await workbook.xlsx.write(res);
      res.end();
    } else {
      sendResponse(res, 200, "success", { users });
    }
  } catch (error) {
    next(error);
  }
});

// 缓存控制
const cache = require("memory-cache");

const cacheMiddleware = (duration = 300) => {
  return (req, res, next) => {
    const key = req.originalUrl;
    const cachedBody = cache.get(key);
    
    if (cachedBody) {
      res.setHeader("X-Cache", "HIT");
      return res.send(cachedBody);
    }
    
    res.sendResponse = res.json;
    res.json = (body) => {
      cache.put(key, body, duration * 1000);
      res.setHeader("X-Cache", "MISS");
      res.sendResponse(body);
    };
    
    next();
  };
};

app.get("/api/v1/users/stats", cacheMiddleware(600), async (req, res, next) => {
  try {
    const stats = await UserService.getStatistics();
    sendResponse(res, 200, "success", stats);
  } catch (error) {
    next(error);
  }
});

// 条件请求（ETag）
const generateETag = (data) => {
  return crypto.createHash("md5").update(JSON.stringify(data)).digest("hex");
};

app.get("/api/v1/users/:id", async (req, res, next) => {
  try {
    const user = await UserService.getUserById(req.params.id);
    const etag = generateETag(user);
    
    res.setHeader("ETag", etag);
    
    if (req.headers["if-none-match"] === etag) {
      return res.status(304).end();
    }
    
    sendResponse(res, 200, "success", { user });
  } catch (error) {
    next(error);
  }
});

// 速率限制（基于用户）
const createUserRateLimit = (windowMs, max) => {
  const userRequests = new Map();
  
  return (req, res, next) => {
    const userId = req.user?.id || req.ip;
    const now = Date.now();
    const windowStart = now - windowMs;
    
    if (!userRequests.has(userId)) {
      userRequests.set(userId, []);
    }
    
    const requests = userRequests.get(userId);
    
    // 清理过期的请求记录
    const validRequests = requests.filter(timestamp => timestamp > windowStart);
    userRequests.set(userId, validRequests);
    
    if (validRequests.length >= max) {
      return res.status(429).json({
        error: "Too many requests",
        message: `Rate limit exceeded. Maximum ${max} requests per ${windowMs / 1000} seconds.`
      });
    }
    
    validRequests.push(now);
    next();
  };
};

app.post("/api/v1/users", 
  authenticate, 
  createUserRateLimit(15 * 60 * 1000, 5), // 15分钟内最多5次
  async (req, res, next) => {
    // 创建用户逻辑
  }
);
```

### 5.2 API文档生成

#### 5.2.1 Swagger集成
```javascript
const swaggerJsdoc = require("swagger-jsdoc");
const swaggerUi = require("swagger-ui-express");

// Swagger配置
const swaggerOptions = {
  definition: {
    openapi: "3.0.0",
    info: {
      title: "Node.js API Documentation",
      version: "1.0.0",
      description: "A comprehensive REST API built with Node.js and Express",
      contact: {
        name: "API Support",
        email: "support@example.com"
      },
      license: {
        name: "MIT",
        url: "https://opensource.org/licenses/MIT"
      }
    },
    servers: [
      {
        url: process.env.API_BASE_URL || "http://localhost:3000",
        description: "Development server"
      },
      {
        url: "https://api.example.com",
        description: "Production server"
      }
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: "http",
          scheme: "bearer",
          bearerFormat: "JWT"
        }
      },
      schemas: {
        User: {
          type: "object",
          required: ["name", "email", "password"],
          properties: {
            id: {
              type: "string",
              description: "User unique identifier",
              example: "507f1f77bcf86cd799439011"
            },
            name: {
              type: "string",
              description: "User's full name",
              example: "John Doe",
              minLength: 2,
              maxLength: 50
            },
            email: {
              type: "string",
              format: "email",
              description: "User's email address",
              example: "john.doe@example.com"
            },
            password: {
              type: "string",
              description: "User's password (min 8 characters)",
              example: "Password123",
              minLength: 8,
              writeOnly: true
            },
            role: {
              type: "string",
              enum: ["user", "admin"],
              description: "User's role",
              example: "user"
            },
            age: {
              type: "integer",
              minimum: 0,
              maximum: 150,
              description: "User's age",
              example: 25
            },
            isActive: {
              type: "boolean",
              description: "Whether the user account is active",
              example: true
            },
            createdAt: {
              type: "string",
              format: "date-time",
              description: "User creation timestamp",
              example: "2023-01-01T00:00:00.000Z"
            }
          }
        },
        Error: {
          type: "object",
          properties: {
            status: {
              type: "string",
              example: "error"
            },
            message: {
              type: "string",
              example: "Validation failed"
            },
            errors: {
              type: "array",
              items: {
                type: "object",
                properties: {
                  field: {
                    type: "string",
                    example: "email"
                  },
                  message: {
                    type: "string",
                    example: "Invalid email format"
                  }
                }
              }
            }
          }
        },
        PaginatedResponse: {
          type: "object",
          properties: {
            status: {
              type: "string",
              example: "success"
            },
            data: {
              type: "array",
              items: {
                $ref: "#/components/schemas/User"
              }
            },
            pagination: {
              type: "object",
              properties: {
                page: {
                  type: "integer",
                  example: 1
                },
                limit: {
                  type: "integer",
                  example: 10
                },
                total: {
                  type: "integer",
                  example: 100
                },
                totalPages: {
                  type: "integer",
                  example: 10
                },
                hasNext: {
                  type: "boolean",
                  example: true
                },
                hasPrev: {
                  type: "boolean",
                  example: false
                }
              }
            }
          }
        }
      }
    }
  },
  apis: ["./routes/*.js"] // 包含API注释的文件路径
};

const swaggerSpec = swaggerJsdoc(swaggerOptions);

// Swagger UI路由
app.use("/api-docs", swaggerUi.serve, swaggerUi.setup(swaggerSpec, {
  explorer: true,
  customCss: ".swagger-ui .topbar { display: none }",
  customSiteTitle: "Node.js API Documentation"
}));

// 提供JSON格式的API文档
app.get("/api-docs.json", (req, res) => {
  res.setHeader("Content-Type", "application/json");
  res.send(swaggerSpec);
});

// API路由注释示例
/**
 * @swagger
 * /api/v1/users:
 *   get:
 *     summary: Get a list of users
 *     description: Retrieve a paginated list of users with optional filtering and sorting
 *     tags: [Users]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *           minimum: 1
 *           default: 1
 *         description: Page number for pagination
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           minimum: 1
 *           maximum: 100
 *           default: 10
 *         description: Number of users per page
 *       - in: query
 *         name: search
 *         schema:
 *           type: string
 *         description: Search term to filter users by name or email
 *       - in: query
 *         name: role
 *         schema:
 *           type: string
 *           enum: [user, admin]
 *         description: Filter users by role
 *       - in: query
 *         name: sort
 *         schema:
 *           type: string
 *           enum: [name, email, createdAt, age]
 *           default: createdAt
 *         description: Field to sort by
 *       - in: query
 *         name: order
 *         schema:
 *           type: string
 *           enum: [asc, desc]
 *           default: desc
 *         description: Sort order
 *     responses:
 *       200:
 *         description: Users retrieved successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: "#/components/schemas/PaginatedResponse"
 *       401:
 *         description: Unauthorized - Authentication required
 *         content:
 *           application/json:
 *             schema:
 *               $ref: "#/components/schemas/Error"
 *       403:
 *         description: Forbidden - Insufficient permissions
 *         content:
 *           application/json:
 *             schema:
 *               $ref: "#/components/schemas/Error"
 */
router.get("/", authenticate, requirePermission("users:read"), async (req, res, next) => {
  try {
    const result = await UserService.getAllUsers(req.query);
    sendResponse(res, 200, "success", result);
  } catch (error) {
    next(error);
  }
});

/**
 * @swagger
 * /api/v1/users:
 *   post:
 *     summary: Create a new user
 *     description: Register a new user with the provided information
 *     tags: [Users]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - name
 *               - email
 *               - password
 *             properties:
 *               name:
 *                 type: string
 *                 minLength: 2
 *                 maxLength: 50
 *                 description: User's full name
 *                 example: John Doe
 *               email:
 *                 type: string
 *                 format: email
 *                 description: User's email address
 *                 example: john.doe@example.com
 *               password:
 *                 type: string
 *                 minLength: 8
 *                 description: User's password (must contain at least one uppercase letter, one lowercase letter, and one digit)
 *                 example: Password123
 *               age:
 *                 type: integer
 *                 minimum: 0
 *                 maximum: 150
 *                 description: User's age
 *                 example: 25
 *     responses:
 *       201:
 *         description: User created successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: string
 *                   example: success
 *                 data:
 *                   $ref: "#/components/schemas/User"
 *       400:
 *         description: Bad Request - Validation failed
 *         content:
 *           application/json:
 *             schema:
 *               $ref: "#/components/schemas/Error"
 *       401:
 *         description: Unauthorized - Authentication required
 *         content:
 *           application/json:
 *             schema:
 *               $ref: "#/components/schemas/Error"
 *       403:
 *         description: Forbidden - Insufficient permissions
 *         content:
 *           application/json:
 *             schema:
 *               $ref: "#/components/schemas/Error"
 *       409:
 *         description: Conflict - User already exists
 *         content:
 *           application/json:
 *             schema:
 *               $ref: "#/components/schemas/Error"
 */
router.post("/", 
  authenticate, 
  requirePermission("users:create"),
  validateUserRegistration,
  checkValidationResult,
  async (req, res, next) => {
    try {
      const user = await UserService.createUser(req.body);
      sendResponse(res, 201, "success", { user });
    } catch (error) {
      next(error);
    }
  }
);
```

## 6. 性能优化和部署

### 6.1 性能优化策略

#### 6.1.1 数据库优化
```javascript
// 数据库连接池优化
const sequelize = new Sequelize(database, username, password, {
  host: "localhost",
  dialect: "mysql",
  pool: {
    max: 20, // 最大连接数
    min: 5,  // 最小连接数
    acquire: 30000, // 获取连接的超时时间
    idle: 10000     // 空闲连接的超时时间
  },
  logging: false,
  benchmark: true,
  dialectOptions: {
    charset: "utf8mb4",
    collate: "utf8mb4_unicode_ci"
  }
});

// 查询优化
class OptimizedUserService {
  static async getUsersWithOptimizedQuery(options = {}) {
    const { page = 1, limit = 10, search } = options;
    
    // 使用索引优化的查询
    let whereClause = {};
    if (search) {
      whereClause = {
        [Sequelize.Op.or]: [
          { name: { [Sequelize.Op.like]: `%${search}%` } },
          { email: { [Sequelize.Op.like]: `%${search}%` } }
        ]
      };
    }
    
    // 使用原生查询进行复杂操作
    const query = `
      SELECT 
        u.id,
        u.name,
        u.email,
        u.created_at,
        COUNT(p.id) as post_count
      FROM users u
      LEFT JOIN posts p ON u.id = p.author_id
      WHERE u.is_active = true
      ${search ? 'AND (u.name LIKE :search OR u.email LIKE :search)' : ''}
      GROUP BY u.id, u.name, u.email, u.created_at
      ORDER BY u.created_at DESC
      LIMIT :limit OFFSET :offset
    `;
    
    const [users] = await sequelize.query(query, {
      replacements: {
        search: `%${search}%`,
        limit: parseInt(limit),
        offset: (parseInt(page) - 1) * parseInt(limit)
      },
      type: Sequelize.QueryTypes.SELECT
    });
    
    // 获取总数（使用独立的查询）
    const countQuery = `
      SELECT COUNT(*) as total
      FROM users u
      WHERE u.is_active = true
      ${search ? 'AND (u.name LIKE :search OR u.email LIKE :search)' : ''}
    `;
    
    const [{ total }] = await sequelize.query(countQuery, {
      replacements: { search: `%${search}%` },
      type: Sequelize.QueryTypes.SELECT
    });
    
    return {
      users,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: parseInt(total),
        totalPages: Math.ceil(total / limit)
      }
    };
  }
  
  // 批量操作优化
  static async bulkCreateUsers(usersData) {
    // 使用事务和批量插入
    const transaction = await sequelize.transaction();
    
    try {
      const users = await User.bulkCreate(usersData, {
        transaction,
        validate: true,
        individualHooks: true
      });
      
      await transaction.commit();
      return users;
    } catch (error) {
      await transaction.rollback();
      throw error;
    }
  }
  
  // 缓存热门数据
  static async getPopularUsers() {
    const cacheKey = "popular_users";
    const cached = await redis.get(cacheKey);
    
    if (cached) {
      return JSON.parse(cached);
    }
    
    const users = await User.findAll({
      where: { isActive: true },
      order: [["followersCount", "DESC"]],
      limit: 10,
      attributes: ["id", "name", "email", "followersCount"]
    });
    
    await redis.setex(cacheKey, 300, JSON.stringify(users)); // 缓存5分钟
    return users;
  }
}

// Redis缓存集成
const redis = require("redis");
const client = redis.createClient({
  host: process.env.REDIS_HOST,
  port: process.env.REDIS_PORT,
  password: process.env.REDIS_PASSWORD
});

class CacheService {
  static async get(key) {
    try {
      const data = await client.get(key);
      return data ? JSON.parse(data) : null;
    } catch (error) {
      console.error("Cache get error:", error);
      return null;
    }
  }
  
  static async set(key, data, ttl = 3600) {
    try {
      await client.setex(key, ttl, JSON.stringify(data));
    } catch (error) {
      console.error("Cache set error:", error);
    }
  }
  
  static async del(key) {
    try {
      await client.del(key);
    } catch (error) {
      console.error("Cache delete error:", error);
    }
  }
  
  static async invalidatePattern(pattern) {
    try {
      const keys = await client.keys(pattern);
      if (keys.length > 0) {
        await client.del(keys);
      }
    } catch (error) {
      console.error("Cache invalidate pattern error:", error);
    }
  }
}

// 缓存中间件
const cacheMiddleware = (ttl = 3600) => {
  return async (req, res, next) => {
    if (req.method !== "GET") {
      return next();
    }
    
    const key = `cache:${req.originalUrl}`;
    
    try {
      const cached = await CacheService.get(key);
      
      if (cached) {
        res.setHeader("X-Cache", "HIT");
        return res.json(cached);
      }
      
      // 重写res.json以缓存响应
      const originalJson = res.json;
      res.json = function(data) {
        CacheService.set(key, data, ttl);
        res.setHeader("X-Cache", "MISS");
        originalJson.call(this, data);
      };
      
      next();
    } catch (error) {
      next();
    }
  };
};
```

#### 6.1.2 应用层优化
```javascript
// 响应压缩
const compression = require("compression");
app.use(compression({
  level: 6,
  threshold: 1024,
  filter: (req, res) => {
    if (req.headers["x-no-compression"]) {
      return false;
    }
    return compression.filter(req, res);
  }
}));

// 静态资源优化
app.use("/static", express.static("public", {
  maxAge: "1y",
  etag: true,
  lastModified: true,
  setHeaders: (res, path) => {
    if (path.endsWith(".html")) {
      res.setHeader("Cache-Control", "no-cache");
    }
  }
}));

// 请求去重
const pendingRequests = new Map();

const deduplicateRequests = (keyGenerator) => {
  return (req, res, next) => {
    const key = keyGenerator(req);
    
    if (pendingRequests.has(key)) {
      const pending = pendingRequests.get(key);
      pending.promise.then(response => {
        res.json(response);
      }).catch(error => {
        next(error);
      });
      return;
    }
    
    const deferred = {};
    deferred.promise = new Promise((resolve, reject) => {
      deferred.resolve = resolve;
      deferred.reject = reject;
    });
    
    pendingRequests.set(key, deferred);
    
    const originalJson = res.json;
    res.json = function(data) {
      originalJson.call(this, data);
      deferred.resolve(data);
      pendingRequests.delete(key);
    };
    
    const originalError = res.error;
    res.error = function(error) {
      originalError.call(this, error);
      deferred.reject(error);
      pendingRequests.delete(key);
    };
    
    next();
  };
};

// 使用请求去重
app.get("/api/v1/users/:id/stats",
  deduplicateRequests(req => `user_stats_${req.params.id}`),
  async (req, res, next) => {
    // 获取用户统计信息
  }
);

// 限流优化
const rateLimit = require("express-rate-limit");

const createRateLimit = (options) => {
  return rateLimit({
    windowMs: options.windowMs || 15 * 60 * 1000,
    max: options.max || 100,
    message: options.message || "Too many requests",
    standardHeaders: true,
    legacyHeaders: false,
    keyGenerator: options.keyGenerator || (req => req.ip),
    skip: options.skip || (() => false),
    onLimitReached: options.onLimitReached || ((req, res) => {
      console.log(`Rate limit exceeded for ${req.ip}`);
    })
  });
};

// 不同端点的不同限流策略
const apiLimiter = createRateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100
});

const authLimiter = createRateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5,
  message: "Too many authentication attempts, please try again later."
});

const uploadLimiter = createRateLimit({
  windowMs: 60 * 60 * 1000,
  max: 10,
  message: "Too many upload attempts, please try again later."
});

app.use("/api/", apiLimiter);
app.use("/api/auth/", authLimiter);
app.use("/api/upload/", uploadLimiter);
```

### 6.2 部署和监控

#### 6.2.1 Docker部署
```dockerfile
# Dockerfile
FROM node:18-alpine

# 设置工作目录
WORKDIR /app

# 复制package文件
COPY package*.json ./

# 安装依赖
RUN npm ci --only=production && npm cache clean --force

# 复制应用代码
COPY . .

# 创建非root用户
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodejs -u 1001

# 更改文件所有权
RUN chown -R nodejs:nodejs /app
USER nodejs

# 暴露端口
EXPOSE 3000

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

# 启动应用
CMD ["node", "server.js"]
```

```yaml
# docker-compose.yml
version: "3.8"

services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - DB_HOST=mysql
      - REDIS_HOST=redis
    depends_on:
      - mysql
      - redis
    restart: unless-stopped
    networks:
      - app-network

  mysql:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: ${DB_ROOT_PASSWORD}
      MYSQL_DATABASE: ${DB_NAME}
      MYSQL_USER: ${DB_USER}
      MYSQL_PASSWORD: ${DB_PASSWORD}
    volumes:
      - mysql_data:/var/lib/mysql
      - ./mysql/init.sql:/docker-entrypoint-initdb.d/init.sql
    ports:
      - "3306:3306"
    restart: unless-stopped
    networks:
      - app-network

  redis:
    image: redis:7-alpine
    command: redis-server --appendonly yes --requirepass ${REDIS_PASSWORD}
    volumes:
      - redis_data:/data
    ports:
      - "6379:6379"
    restart: unless-stopped
    networks:
      - app-network

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
      - ./nginx/ssl:/etc/nginx/ssl
    depends_on:
      - app
    restart: unless-stopped
    networks:
      - app-network

volumes:
  mysql_data:
  redis_data:

networks:
  app-network:
    driver: bridge
```

#### 6.2.2 监控和日志
```javascript
// 健康检查端点
app.get("/health", async (req, res) => {
  const health = {
    status: "ok",
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    memory: process.memoryUsage(),
    version: process.env.npm_package_version
  };
  
  try {
    // 检查数据库连接
    await sequelize.authenticate();
    health.database = "connected";
  } catch (error) {
    health.database = "disconnected";
    health.status = "error";
  }
  
  try {
    // 检查Redis连接
    await client.ping();
    health.redis = "connected";
  } catch (error) {
    health.redis = "disconnected";
    health.status = "error";
  }
  
  const statusCode = health.status === "ok" ? 200 : 503;
  res.status(statusCode).json(health);
});

// 指标收集
const prometheus = require("prom-client");

// 创建指标
const httpRequestDuration = new prometheus.Histogram({
  name: "http_request_duration_seconds",
  help: "Duration of HTTP requests in seconds",
  labelNames: ["method", "route", "status_code"]
});

const httpRequestTotal = new prometheus.Counter({
  name: "http_requests_total",
  help: "Total number of HTTP requests",
  labelNames: ["method", "route", "status_code"]
});

const activeConnections = new prometheus.Gauge({
  name: "active_connections",
  help: "Number of active connections"
});

// 指标中间件
const metricsMiddleware = (req, res, next) => {
  const start = Date.now();
  
  res.on("finish", () => {
    const duration = (Date.now() - start) / 1000;
    const route = req.route ? req.route.path : req.path;
    
    httpRequestDuration
      .labels(req.method, route, res.statusCode)
      .observe(duration);
    
    httpRequestTotal
      .labels(req.method, route, res.statusCode)
      .inc();
  });
  
  next();
};

app.use(metricsMiddleware);

// 指标端点
app.get("/metrics", (req, res) => {
  res.set("Content-Type", prometheus.register.contentType);
  res.end(prometheus.register.metrics());
});

// 结构化日志
const winston = require("winston");

const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || "info",
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  defaultMeta: { service: "nodejs-api" },
  transports: [
    new winston.transports.File({ filename: "logs/error.log", level: "error" }),
    new winston.transports.File({ filename: "logs/combined.log" })
  ]
});

if (process.env.NODE_ENV !== "production") {
  logger.add(new winston.transports.Console({
    format: winston.format.simple()
  }));
}

// 请求日志中间件
const requestLogger = (req, res, next) => {
  const start = Date.now();
  
  res.on("finish", () => {
    const duration = Date.now() - start;
    
    logger.info("HTTP Request", {
      method: req.method,
      url: req.url,
      status: res.statusCode,
      duration,
      userAgent: req.get("User-Agent"),
      ip: req.ip,
      userId: req.user?.id
    });
  });
  
  next();
};

app.use(requestLogger);

// 错误日志
app.use((err, req, res, next) => {
  logger.error("Unhandled Error", {
    error: err.message,
    stack: err.stack,
    method: req.method,
    url: req.url,
    userId: req.user?.id
  });
  
  next(err);
});
```

## 7. 总结

Node.js作为强大的后端JavaScript运行时，提供了构建高性能、可扩展Web应用的完整生态系统。通过深入学习Node.js的核心概念、Express框架、数据库集成、认证授权、API设计和性能优化，开发者可以构建企业级的后端应用。

### 7.1 关键要点
1. **异步编程**: 掌握事件循环、Promise、async/await
2. **Express框架**: 熟练使用路由、中间件、错误处理
3. **数据库集成**: MongoDB和MySQL的ORM使用
4. **认证授权**: JWT、OAuth2.0和RBAC系统设计
5. **API设计**: RESTful原则和Swagger文档
6. **性能优化**: 缓存、连接池、查询优化
7. **部署监控**: Docker容器化和监控指标

### 7.2 最佳实践
1. 使用TypeScript提高代码质量
2. 实施完整的错误处理策略
3. 采用分层架构设计
4. 实现API版本控制
5. 添加全面的测试覆盖
6. 使用环境变量管理配置
7. 实施安全最佳实践

### 7.3 学习路径
1. **基础阶段**: Node.js核心、Express基础
2. **进阶阶段**: 数据库集成、认证系统
3. **高级阶段**: 性能优化、微服务架构
4. **实战阶段**: 完整项目开发、部署运维

Node.js生态系统持续发展，保持学习新技术和最佳实践是成为优秀Node.js开发者的关键。建议结合实际项目不断深化理解和应用。
