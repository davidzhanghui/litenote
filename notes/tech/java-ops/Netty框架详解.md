# Netty框架详解

## 目录
1. [Netty简介](#netty简介)
2. [核心架构](#核心架构)
3. [技术原理](#技术原理)
4. [项目中的使用](#项目中的使用)
5. [最佳实践](#最佳实践)
6. [性能优化](#性能优化)
7. [常见问题与解决方案](#常见问题与解决方案)

## Netty简介

Netty是一个异步事件驱动的网络应用程序框架，用于快速开发可维护的高性能协议服务器和客户端。它是基于Java NIO的网络编程框架，提供了简单易用的API来处理网络通信。

### 主要特性
- **异步和事件驱动**：基于NIO的非阻塞I/O模型
- **高性能**：零拷贝、内存池、对象池等优化技术
- **易用性**：简洁的API设计，降低网络编程复杂度
- **可扩展性**：支持多种传输类型和协议
- **稳定性**：经过大量生产环境验证

## 核心架构

### 整体架构图
```
┌─────────────────────────────────────────────────────────┐
│                    Application Layer                    │
├─────────────────────────────────────────────────────────┤
│                    ChannelHandler                       │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐       │
│  │   Encoder   │ │   Decoder   │ │   Business  │       │
│  │             │ │             │ │   Handler   │       │
│  └─────────────┘ └─────────────┘ └─────────────┘       │
├─────────────────────────────────────────────────────────┤
│                   ChannelPipeline                       │
├─────────────────────────────────────────────────────────┤
│                     EventLoop                           │
│  ┌─────────────────────────────────────────────────────┐│
│  │              NIO Selector Thread                   ││
│  └─────────────────────────────────────────────────────┘│
├─────────────────────────────────────────────────────────┤
│                      Channel                            │
│  ┌─────────────────────────────────────────────────────┐│
│  │                Socket Channel                       ││
│  └─────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────┘
```

### 核心组件

#### 1. Channel
Channel是Netty网络通信的核心抽象，代表一个打开的连接，可以进行读写操作。

```java
// Channel的主要类型
- NioSocketChannel：客户端TCP连接
- NioServerSocketChannel：服务端TCP连接
- NioDatagramChannel：UDP连接
- EpollSocketChannel：Linux下的高性能TCP连接
```

#### 2. EventLoop
EventLoop是Netty的核心线程模型，负责处理Channel的所有I/O操作。

```java
// EventLoop特性
- 一个EventLoop可以服务多个Channel
- 一个Channel只能注册到一个EventLoop
- EventLoop内部维护一个线程和任务队列
```

#### 3. ChannelPipeline
ChannelPipeline是处理器链，负责处理Channel的入站和出站事件。

```java
// Pipeline处理流程
Inbound:  Socket → Handler1 → Handler2 → Handler3 → Application
Outbound: Application → Handler3 → Handler2 → Handler1 → Socket
```

#### 4. ChannelHandler
ChannelHandler是业务逻辑的载体，处理I/O事件和数据转换。

```java
// Handler类型
- ChannelInboundHandler：处理入站事件
- ChannelOutboundHandler：处理出站事件
- ChannelDuplexHandler：同时处理入站和出站事件
```

#### 5. Bootstrap
Bootstrap是Netty应用程序的启动辅助类。

```java
// Bootstrap类型
- Bootstrap：客户端启动器
- ServerBootstrap：服务端启动器
```

## 技术原理

### 1. Reactor模式
Netty基于Reactor模式实现，将I/O操作从业务逻辑中分离出来。

```java
// Reactor模式的三种实现
1. 单Reactor单线程：一个线程处理所有I/O和业务逻辑
2. 单Reactor多线程：一个线程处理I/O，多个线程处理业务逻辑
3. 主从Reactor：主Reactor处理连接，从Reactor处理I/O
```

### 2. NIO模型
Netty使用Java NIO实现非阻塞I/O操作。

```java
// NIO核心组件
- Selector：多路复用器，监控多个Channel的I/O状态
- Channel：数据传输通道
- Buffer：数据缓冲区
```

### 3. 零拷贝技术
Netty通过多种技术实现零拷贝，减少数据复制次数。

```java
// 零拷贝实现方式
1. DirectBuffer：直接内存，避免JVM堆内存拷贝
2. CompositeByteBuf：组合缓冲区，避免合并时的拷贝
3. FileRegion：文件传输，使用sendfile系统调用
4. Slice：切片操作，共享底层数组
```

### 4. 内存管理
Netty实现了高效的内存管理机制。

```java
// 内存管理特性
- 内存池：PooledByteBufAllocator
- 对象池：Recycler
- 引用计数：ReferenceCounted
- 内存泄漏检测：ResourceLeakDetector
```

## 项目中的使用

### 1. 服务端开发

#### 基础服务端示例
```java
public class NettyServer {
    private final int port;
    
    public NettyServer(int port) {
        this.port = port;
    }
    
    public void start() throws Exception {
        EventLoopGroup bossGroup = new NioEventLoopGroup(1);
        EventLoopGroup workerGroup = new NioEventLoopGroup();
        
        try {
            ServerBootstrap bootstrap = new ServerBootstrap();
            bootstrap.group(bossGroup, workerGroup)
                    .channel(NioServerSocketChannel.class)
                    .option(ChannelOption.SO_BACKLOG, 128)
                    .childOption(ChannelOption.SO_KEEPALIVE, true)
                    .childHandler(new ChannelInitializer<SocketChannel>() {
                        @Override
                        protected void initChannel(SocketChannel ch) {
                            ChannelPipeline pipeline = ch.pipeline();
                            
                            // 添加编解码器
                            pipeline.addLast(new StringDecoder());
                            pipeline.addLast(new StringEncoder());
                            
                            // 添加业务处理器
                            pipeline.addLast(new ServerHandler());
                        }
                    });
            
            ChannelFuture future = bootstrap.bind(port).sync();
            System.out.println("Server started on port " + port);
            
            future.channel().closeFuture().sync();
        } finally {
            workerGroup.shutdownGracefully();
            bossGroup.shutdownGracefully();
        }
    }
}

// 业务处理器
public class ServerHandler extends ChannelInboundHandlerAdapter {
    @Override
    public void channelRead(ChannelHandlerContext ctx, Object msg) {
        String request = (String) msg;
        System.out.println("Received: " + request);
        
        // 处理业务逻辑
        String response = "Echo: " + request;
        ctx.writeAndFlush(response);
    }
    
    @Override
    public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) {
        cause.printStackTrace();
        ctx.close();
    }
}
```

#### HTTP服务端示例
```java
public class HttpServer {
    public void start(int port) throws Exception {
        EventLoopGroup bossGroup = new NioEventLoopGroup(1);
        EventLoopGroup workerGroup = new NioEventLoopGroup();
        
        try {
            ServerBootstrap bootstrap = new ServerBootstrap();
            bootstrap.group(bossGroup, workerGroup)
                    .channel(NioServerSocketChannel.class)
                    .childHandler(new ChannelInitializer<SocketChannel>() {
                        @Override
                        protected void initChannel(SocketChannel ch) {
                            ChannelPipeline pipeline = ch.pipeline();
                            
                            // HTTP编解码器
                            pipeline.addLast(new HttpServerCodec());
                            pipeline.addLast(new HttpObjectAggregator(65536));
                            
                            // 业务处理器
                            pipeline.addLast(new HttpServerHandler());
                        }
                    });
            
            ChannelFuture future = bootstrap.bind(port).sync();
            future.channel().closeFuture().sync();
        } finally {
            workerGroup.shutdownGracefully();
            bossGroup.shutdownGracefully();
        }
    }
}

public class HttpServerHandler extends SimpleChannelInboundHandler<FullHttpRequest> {
    @Override
    protected void channelRead0(ChannelHandlerContext ctx, FullHttpRequest request) {
        // 创建HTTP响应
        String content = "Hello, Netty HTTP Server!";
        FullHttpResponse response = new DefaultFullHttpResponse(
                HttpVersion.HTTP_1_1,
                HttpResponseStatus.OK,
                Unpooled.copiedBuffer(content, CharsetUtil.UTF_8)
        );
        
        // 设置响应头
        response.headers().set(HttpHeaderNames.CONTENT_TYPE, "text/plain; charset=UTF-8");
        response.headers().set(HttpHeaderNames.CONTENT_LENGTH, response.content().readableBytes());
        
        // 发送响应
        ctx.writeAndFlush(response).addListener(ChannelFutureListener.CLOSE);
    }
}
```

### 2. 客户端开发

#### 基础客户端示例
```java
public class NettyClient {
    private final String host;
    private final int port;
    
    public NettyClient(String host, int port) {
        this.host = host;
        this.port = port;
    }
    
    public void start() throws Exception {
        EventLoopGroup group = new NioEventLoopGroup();
        
        try {
            Bootstrap bootstrap = new Bootstrap();
            bootstrap.group(group)
                    .channel(NioSocketChannel.class)
                    .option(ChannelOption.TCP_NODELAY, true)
                    .handler(new ChannelInitializer<SocketChannel>() {
                        @Override
                        protected void initChannel(SocketChannel ch) {
                            ChannelPipeline pipeline = ch.pipeline();
                            
                            pipeline.addLast(new StringDecoder());
                            pipeline.addLast(new StringEncoder());
                            pipeline.addLast(new ClientHandler());
                        }
                    });
            
            ChannelFuture future = bootstrap.connect(host, port).sync();
            
            // 发送消息
            Channel channel = future.channel();
            channel.writeAndFlush("Hello, Netty Server!");
            
            future.channel().closeFuture().sync();
        } finally {
            group.shutdownGracefully();
        }
    }
}

public class ClientHandler extends ChannelInboundHandlerAdapter {
    @Override
    public void channelRead(ChannelHandlerContext ctx, Object msg) {
        String response = (String) msg;
        System.out.println("Received from server: " + response);
    }
    
    @Override
    public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) {
        cause.printStackTrace();
        ctx.close();
    }
}
```

### 3. 自定义协议实现

#### 协议定义
```java
// 自定义协议格式：魔数(4字节) + 版本(1字节) + 长度(4字节) + 数据
public class CustomProtocol {
    public static final int MAGIC_NUMBER = 0x12345678;
    public static final byte VERSION = 1;
    
    private int magicNumber;
    private byte version;
    private int length;
    private byte[] data;
    
    // getter/setter方法
}
```

#### 编码器
```java
public class CustomProtocolEncoder extends MessageToByteEncoder<CustomProtocol> {
    @Override
    protected void encode(ChannelHandlerContext ctx, CustomProtocol msg, ByteBuf out) {
        out.writeInt(msg.getMagicNumber());
        out.writeByte(msg.getVersion());
        out.writeInt(msg.getLength());
        out.writeBytes(msg.getData());
    }
}
```

#### 解码器
```java
public class CustomProtocolDecoder extends ByteToMessageDecoder {
    private static final int HEADER_LENGTH = 9; // 4 + 1 + 4
    
    @Override
    protected void decode(ChannelHandlerContext ctx, ByteBuf in, List<Object> out) {
        if (in.readableBytes() < HEADER_LENGTH) {
            return; // 数据不够，等待更多数据
        }
        
        // 标记读取位置
        in.markReaderIndex();
        
        // 读取协议头
        int magicNumber = in.readInt();
        if (magicNumber != CustomProtocol.MAGIC_NUMBER) {
            in.resetReaderIndex();
            throw new RuntimeException("Invalid magic number");
        }
        
        byte version = in.readByte();
        int length = in.readInt();
        
        // 检查数据是否完整
        if (in.readableBytes() < length) {
            in.resetReaderIndex();
            return; // 数据不完整，等待更多数据
        }
        
        // 读取数据
        byte[] data = new byte[length];
        in.readBytes(data);
        
        // 创建协议对象
        CustomProtocol protocol = new CustomProtocol();
        protocol.setMagicNumber(magicNumber);
        protocol.setVersion(version);
        protocol.setLength(length);
        protocol.setData(data);
        
        out.add(protocol);
    }
}
```

## 最佳实践

### 1. 线程模型优化

#### EventLoopGroup配置
```java
// 推荐配置
public class OptimizedServer {
    public void start() throws Exception {
        // Boss线程组：处理连接请求，通常1个线程足够
        EventLoopGroup bossGroup = new NioEventLoopGroup(1);
        
        // Worker线程组：处理I/O操作，建议CPU核心数的2倍
        int workerThreads = Runtime.getRuntime().availableProcessors() * 2;
        EventLoopGroup workerGroup = new NioEventLoopGroup(workerThreads);
        
        // 业务线程池：处理耗时的业务逻辑
        ExecutorService businessExecutor = Executors.newFixedThreadPool(
            Runtime.getRuntime().availableProcessors() * 4
        );
        
        try {
            ServerBootstrap bootstrap = new ServerBootstrap();
            bootstrap.group(bossGroup, workerGroup)
                    .channel(NioServerSocketChannel.class)
                    .childHandler(new ChannelInitializer<SocketChannel>() {
                        @Override
                        protected void initChannel(SocketChannel ch) {
                            ch.pipeline().addLast(
                                // I/O处理器在EventLoop线程中执行
                                new StringDecoder(),
                                new StringEncoder(),
                                // 业务处理器在业务线程池中执行
                                new DefaultEventExecutorGroup(businessExecutor),
                                new BusinessHandler()
                            );
                        }
                    });
            
            // 其他配置...
        } finally {
            // 优雅关闭
            bossGroup.shutdownGracefully();
            workerGroup.shutdownGracefully();
            businessExecutor.shutdown();
        }
    }
}
```

### 2. 内存管理优化

#### ByteBuf使用最佳实践
```java
public class ByteBufBestPractices {
    
    // 1. 使用池化的ByteBuf分配器
    private static final ByteBufAllocator ALLOCATOR = PooledByteBufAllocator.DEFAULT;
    
    // 2. 正确释放ByteBuf
    public void handleMessage(ByteBuf buf) {
        try {
            // 处理数据
            processData(buf);
        } finally {
            // 确保释放ByteBuf
            buf.release();
        }
    }
    
    // 3. 使用引用计数
    public void shareBuffer(ByteBuf buf) {
        // 增加引用计数
        buf.retain();
        
        // 在另一个线程中使用
        executor.submit(() -> {
            try {
                processInBackground(buf);
            } finally {
                buf.release(); // 减少引用计数
            }
        });
    }
    
    // 4. 使用CompositeByteBuf避免拷贝
    public ByteBuf combineBuffers(ByteBuf... buffers) {
        CompositeByteBuf composite = ALLOCATOR.compositeBuffer();
        for (ByteBuf buf : buffers) {
            composite.addComponent(true, buf);
        }
        return composite;
    }
    
    // 5. 使用slice()共享数据
    public void processSlice(ByteBuf original) {
        ByteBuf slice = original.slice(0, 100); // 共享底层数组
        // 处理slice，不需要单独释放
    }
}
```

### 3. 连接管理

#### 连接池实现
```java
public class ConnectionPool {
    private final Queue<Channel> availableChannels = new ConcurrentLinkedQueue<>();
    private final Set<Channel> allChannels = ConcurrentHashMap.newKeySet();
    private final Bootstrap bootstrap;
    private final String host;
    private final int port;
    private final int maxConnections;
    
    public ConnectionPool(String host, int port, int maxConnections) {
        this.host = host;
        this.port = port;
        this.maxConnections = maxConnections;
        this.bootstrap = createBootstrap();
    }
    
    public Channel acquire() throws Exception {
        Channel channel = availableChannels.poll();
        
        if (channel == null || !channel.isActive()) {
            if (allChannels.size() < maxConnections) {
                channel = createConnection();
                allChannels.add(channel);
            } else {
                throw new RuntimeException("Connection pool exhausted");
            }
        }
        
        return channel;
    }
    
    public void release(Channel channel) {
        if (channel.isActive()) {
            availableChannels.offer(channel);
        } else {
            allChannels.remove(channel);
        }
    }
    
    private Channel createConnection() throws Exception {
        ChannelFuture future = bootstrap.connect(host, port);
        return future.sync().channel();
    }
    
    public void close() {
        for (Channel channel : allChannels) {
            channel.close();
        }
        allChannels.clear();
        availableChannels.clear();
    }
}
```

### 4. 异常处理

#### 统一异常处理器
```java
public class GlobalExceptionHandler extends ChannelInboundHandlerAdapter {
    private static final Logger logger = LoggerFactory.getLogger(GlobalExceptionHandler.class);
    
    @Override
    public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) {
        if (cause instanceof IOException) {
            logger.warn("I/O exception: {}", cause.getMessage());
        } else if (cause instanceof TimeoutException) {
            logger.warn("Timeout exception: {}", cause.getMessage());
        } else {
            logger.error("Unexpected exception", cause);
        }
        
        // 发送错误响应
        if (ctx.channel().isActive()) {
            sendErrorResponse(ctx, cause);
        }
        
        // 关闭连接
        ctx.close();
    }
    
    private void sendErrorResponse(ChannelHandlerContext ctx, Throwable cause) {
        // 构造错误响应
        String errorMsg = "Internal server error: " + cause.getMessage();
        ctx.writeAndFlush(errorMsg).addListener(ChannelFutureListener.CLOSE);
    }
}
```

### 5. 心跳机制

#### 心跳处理器
```java
public class HeartbeatHandler extends ChannelInboundHandlerAdapter {
    private static final String HEARTBEAT_REQUEST = "PING";
    private static final String HEARTBEAT_RESPONSE = "PONG";
    
    @Override
    public void channelRead(ChannelHandlerContext ctx, Object msg) {
        String message = (String) msg;
        
        if (HEARTBEAT_REQUEST.equals(message)) {
            // 响应心跳
            ctx.writeAndFlush(HEARTBEAT_RESPONSE);
        } else {
            // 传递给下一个处理器
            ctx.fireChannelRead(msg);
        }
    }
    
    @Override
    public void userEventTriggered(ChannelHandlerContext ctx, Object evt) {
        if (evt instanceof IdleStateEvent) {
            IdleStateEvent event = (IdleStateEvent) evt;
            
            switch (event.state()) {
                case READER_IDLE:
                    // 读超时，关闭连接
                    ctx.close();
                    break;
                case WRITER_IDLE:
                    // 写超时，发送心跳
                    ctx.writeAndFlush(HEARTBEAT_REQUEST);
                    break;
                case ALL_IDLE:
                    // 读写都超时
                    ctx.close();
                    break;
            }
        }
    }
}

// 在Pipeline中添加空闲检测
pipeline.addLast(new IdleStateHandler(60, 30, 0, TimeUnit.SECONDS));
pipeline.addLast(new HeartbeatHandler());
```

## 性能优化

### 1. 系统参数调优

#### JVM参数优化
```bash
# 堆内存设置
-Xms4g -Xmx4g

# 新生代设置
-Xmn2g

# GC算法选择
-XX:+UseG1GC
-XX:MaxGCPauseMillis=200

# 直接内存设置
-XX:MaxDirectMemorySize=2g

# GC日志
-XX:+PrintGCDetails
-XX:+PrintGCTimeStamps
-Xloggc:gc.log
```

#### 操作系统参数调优
```bash
# 增加文件描述符限制
ulimit -n 65535

# TCP参数调优
echo 'net.core.somaxconn = 65535' >> /etc/sysctl.conf
echo 'net.core.netdev_max_backlog = 65535' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_max_syn_backlog = 65535' >> /etc/sysctl.conf

# 应用配置
sysctl -p
```

### 2. Netty参数调优

#### Channel选项优化
```java
public class PerformanceOptimizedServer {
    public void start() throws Exception {
        ServerBootstrap bootstrap = new ServerBootstrap();
        bootstrap.group(bossGroup, workerGroup)
                .channel(NioServerSocketChannel.class)
                // 服务端选项
                .option(ChannelOption.SO_BACKLOG, 1024)
                .option(ChannelOption.SO_REUSEADDR, true)
                
                // 客户端连接选项
                .childOption(ChannelOption.SO_KEEPALIVE, true)
                .childOption(ChannelOption.TCP_NODELAY, true)
                .childOption(ChannelOption.SO_SNDBUF, 32 * 1024)
                .childOption(ChannelOption.SO_RCVBUF, 32 * 1024)
                
                // Netty特有选项
                .childOption(ChannelOption.ALLOCATOR, PooledByteBufAllocator.DEFAULT)
                .childOption(ChannelOption.RCVBUF_ALLOCATOR, 
                    new AdaptiveRecvByteBufAllocator(64, 1024, 65536));
    }
}
```

### 3. 批量处理优化

#### 批量写入
```java
public class BatchWriteHandler extends ChannelOutboundHandlerAdapter {
    private final List<Object> pendingWrites = new ArrayList<>();
    private final int batchSize;
    private ScheduledFuture<?> flushTask;
    
    public BatchWriteHandler(int batchSize) {
        this.batchSize = batchSize;
    }
    
    @Override
    public void write(ChannelHandlerContext ctx, Object msg, ChannelPromise promise) {
        synchronized (pendingWrites) {
            pendingWrites.add(msg);
            
            if (pendingWrites.size() >= batchSize) {
                flushPendingWrites(ctx);
            } else if (flushTask == null) {
                // 设置定时刷新
                flushTask = ctx.executor().schedule(() -> {
                    synchronized (pendingWrites) {
                        if (!pendingWrites.isEmpty()) {
                            flushPendingWrites(ctx);
                        }
                    }
                }, 10, TimeUnit.MILLISECONDS);
            }
        }
    }
    
    private void flushPendingWrites(ChannelHandlerContext ctx) {
        if (flushTask != null) {
            flushTask.cancel(false);
            flushTask = null;
        }
        
        for (Object msg : pendingWrites) {
            ctx.write(msg);
        }
        ctx.flush();
        pendingWrites.clear();
    }
}
```

## 常见问题与解决方案

### 1. 内存泄漏问题

#### 问题诊断
```java
// 启用内存泄漏检测
System.setProperty("io.netty.leakDetection.level", "PARANOID");

// 自定义内存泄漏检测
public class LeakDetectionHandler extends ChannelInboundHandlerAdapter {
    @Override
    public void channelRead(ChannelHandlerContext ctx, Object msg) {
        if (msg instanceof ByteBuf) {
            ByteBuf buf = (ByteBuf) msg;
            if (buf.refCnt() > 0) {
                // 正常处理
                ctx.fireChannelRead(msg);
            } else {
                logger.warn("Received released ByteBuf: {}", buf);
            }
        } else {
            ctx.fireChannelRead(msg);
        }
    }
}
```

#### 解决方案
```java
public class ProperResourceManagement {
    
    // 1. 使用try-with-resources
    public void processWithAutoClose(ByteBuf buf) {
        try (ByteBuf localBuf = buf) {
            // 处理数据
            processData(localBuf);
        } // 自动释放
    }
    
    // 2. 在finally块中释放
    public void processWithFinally(ByteBuf buf) {
        try {
            processData(buf);
        } finally {
            if (buf.refCnt() > 0) {
                buf.release();
            }
        }
    }
    
    // 3. 使用ReferenceCountUtil
    public void processWithUtil(Object msg) {
        try {
            if (msg instanceof ByteBuf) {
                processData((ByteBuf) msg);
            }
        } finally {
            ReferenceCountUtil.release(msg);
        }
    }
}
```

### 2. 连接数过多问题

#### 连接监控
```java
public class ConnectionMonitor {
    private final AtomicInteger activeConnections = new AtomicInteger(0);
    private final int maxConnections;
    
    public ConnectionMonitor(int maxConnections) {
        this.maxConnections = maxConnections;
    }
    
    @Override
    public void channelActive(ChannelHandlerContext ctx) {
        int current = activeConnections.incrementAndGet();
        
        if (current > maxConnections) {
            logger.warn("Too many connections: {}, closing new connection", current);
            ctx.close();
            activeConnections.decrementAndGet();
            return;
        }
        
        logger.info("New connection established, total: {}", current);
        ctx.fireChannelActive();
    }
    
    @Override
    public void channelInactive(ChannelHandlerContext ctx) {
        int current = activeConnections.decrementAndGet();
        logger.info("Connection closed, remaining: {}", current);
        ctx.fireChannelInactive();
    }
}
```

### 3. 粘包拆包问题

#### 解决方案
```java
// 1. 固定长度解码器
pipeline.addLast(new FixedLengthFrameDecoder(1024));

// 2. 分隔符解码器
pipeline.addLast(new DelimiterBasedFrameDecoder(1024, Delimiters.lineDelimiter()));

// 3. 长度字段解码器
pipeline.addLast(new LengthFieldBasedFrameDecoder(
    1024,    // 最大帧长度
    0,       // 长度字段偏移量
    4,       // 长度字段长度
    0,       // 长度调整值
    4        // 跳过的字节数
));

// 4. 自定义解码器
public class CustomFrameDecoder extends ByteToMessageDecoder {
    @Override
    protected void decode(ChannelHandlerContext ctx, ByteBuf in, List<Object> out) {
        // 自定义解码逻辑
        while (in.readableBytes() >= 4) {
            int length = in.getInt(in.readerIndex());
            if (in.readableBytes() >= length + 4) {
                in.skipBytes(4); // 跳过长度字段
                ByteBuf frame = in.readBytes(length);
                out.add(frame);
            } else {
                break; // 等待更多数据
            }
        }
    }
}
```

### 4. 性能监控

#### 指标收集
```java
public class MetricsHandler extends ChannelDuplexHandler {
    private final MeterRegistry meterRegistry;
    private final Timer.Sample requestTimer;
    
    public MetricsHandler(MeterRegistry meterRegistry) {
        this.meterRegistry = meterRegistry;
    }
    
    @Override
    public void channelRead(ChannelHandlerContext ctx, Object msg) {
        // 记录请求数
        meterRegistry.counter("netty.requests.total").increment();
        
        // 开始计时
        Timer.Sample sample = Timer.start(meterRegistry);
        ctx.channel().attr(AttributeKey.valueOf("timer")).set(sample);
        
        ctx.fireChannelRead(msg);
    }
    
    @Override
    public void write(ChannelHandlerContext ctx, Object msg, ChannelPromise promise) {
        // 结束计时
        Timer.Sample sample = ctx.channel().attr(AttributeKey.<Timer.Sample>valueOf("timer")).get();
        if (sample != null) {
            sample.stop(Timer.builder("netty.request.duration").register(meterRegistry));
        }
        
        // 记录响应数
        meterRegistry.counter("netty.responses.total").increment();
        
        ctx.write(msg, promise);
    }
    
    @Override
    public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) {
        // 记录异常数
        meterRegistry.counter("netty.errors.total", 
            "exception", cause.getClass().getSimpleName()).increment();
        
        ctx.fireExceptionCaught(cause);
    }
}
```

## 总结

Netty作为一个高性能的网络编程框架，在正确使用的情况下能够提供卓越的性能和稳定性。关键要点包括：

1. **理解核心概念**：掌握Channel、EventLoop、Pipeline等核心组件的工作原理
2. **合理的线程模型**：正确配置EventLoopGroup和业务线程池
3. **内存管理**：正确使用ByteBuf，避免内存泄漏
4. **性能优化**：通过参数调优、批量处理等手段提升性能
5. **监控和诊断**：建立完善的监控体系，及时发现和解决问题

通过遵循这些最佳实践，可以构建出高性能、高可用的网络应用程序。