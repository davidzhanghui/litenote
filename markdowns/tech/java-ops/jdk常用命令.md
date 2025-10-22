# JDK 常用命令详解

## 目录

- [编译和运行](#编译和运行)
  - [javac - Java 编译器](#javac---java-编译器)
  - [java - Java 应用启动器](#java---java-应用启动器)
- [打包和部署](#打包和部署)
  - [jar - Java 归档工具](#jar---java-归档工具)
  - [jlink - 自定义运行时映像生成器](#jlink---自定义运行时映像生成器)
  - [jpackage - 打包工具](#jpackage---打包工具)
- [监控和诊断](#监控和诊断)
  - [jps - JVM 进程状态工具](#jps---jvm-进程状态工具)
  - [jstat - JVM 统计监控工具](#jstat---jvm-统计监控工具)
  - [jinfo - 配置信息工具](#jinfo---配置信息工具)
  - [jmap - 内存映射工具](#jmap---内存映射工具)
  - [jstack - 堆栈跟踪工具](#jstack---堆栈跟踪工具)
  - [jcmd - JVM 诊断命令工具](#jcmd---jvm-诊断命令工具)
- [调试和分析](#调试和分析)
  - [jdb - Java 调试器](#jdb---java-调试器)
  - [jvisualvm - 可视化工具](#jvisualvm---可视化工具)
  - [jmc - Java Mission Control](#jmc---java-mission-control)
- [安全工具](#安全工具)
  - [keytool - 密钥和证书管理工具](#keytool---密钥和证书管理工具)
  - [jarsigner - JAR 签名工具](#jarsigner---jar-签名工具)
- [国际化工具](#国际化工具)
  - [native2ascii - 本地编码到ASCII转换器](#native2ascii---本地编码到ascii转换器)
- [远程方法调用](#远程方法调用)
  - [rmic - RMI 编译器](#rmic---rmi-编译器)
  - [rmiregistry - 远程对象注册表](#rmiregistry---远程对象注册表)
- [IDL 和 RMI-IIOP](#idl-和-rmi-iiop)
  - [idlj - IDL 到 Java 编译器](#idlj---idl-到-java-编译器)
  - [orbd - 对象请求代理守护进程](#orbd---对象请求代理守护进程)
- [Java 9+ 模块工具](#java-9-模块工具)
  - [jdeps - Java 类依赖分析器](#jdeps---java-类依赖分析器)
  - [jmod - JMOD 文件操作工具](#jmod---jmod-文件操作工具)

## 编译和运行

### javac - Java 编译器

`javac` 命令用于将 Java 源代码文件（.java）编译为字节码文件（.class）。

**基本语法：**

```bash
javac [options] [sourcefiles]
```

**常用选项：**

```bash
-d <directory>          # 指定放置生成的类文件的位置
-classpath <path>       # 指定查找用户类文件和注释处理器的位置
-cp <path>              # 同 -classpath
-sourcepath <path>      # 指定查找输入源文件的位置
-source <release>       # 指定使用的 Java 版本（如 8, 11, 17）
-target <release>       # 指定生成的类文件的 Java 版本
-encoding <encoding>    # 指定源文件使用的字符编码
-g                      # 生成所有调试信息
-g:none                 # 不生成任何调试信息
-verbose                # 输出有关编译器正在执行的操作的消息
-deprecation            # 输出使用已过时的 API 的源位置
-Xlint                  # 启用推荐的警告
-Xlint:all              # 启用所有警告
-Xlint:none             # 禁用所有警告
-Werror                 # 出现警告时终止编译
```

**示例：**

```bash
# 编译单个文件
javac HelloWorld.java

# 编译多个文件
javac File1.java File2.java File3.java

# 使用通配符编译所有 Java 文件
javac *.java

# 指定输出目录
javac -d bin src/com/example/Main.java

# 指定类路径
javac -classpath lib/dependency.jar:. Main.java

# 指定源代码版本和目标版本
javac -source 11 -target 11 Main.java

# 指定编码
javac -encoding UTF-8 Main.java

# 启用所有警告
javac -Xlint:all Main.java

# 将警告视为错误
javac -Werror Main.java
```

### java - Java 应用启动器

`java` 命令用于启动 Java 应用程序，它通过启动 JVM，加载指定的类，并调用该类的 main 方法。

**基本语法：**

```bash
java [options] <mainclass> [args...]
java [options] -jar <jarfile> [args...]
java [options] -m <module>[/<mainclass>] [args...]
```

**常用选项：**

```bash
-classpath <path>       # 指定查找类文件的位置
-cp <path>              # 同 -classpath
-D<name>=<value>        # 设置系统属性
-verbose:class          # 输出类加载信息
-verbose:gc             # 输出 GC 事件信息
-verbose:jni            # 输出 JNI 信息
-jar                    # 从 JAR 文件执行程序
-ea                     # 启用断言
-da                     # 禁用断言
-Xms<size>              # 设置初始 Java 堆大小
-Xmx<size>              # 设置最大 Java 堆大小
-Xss<size>              # 设置 Java 线程堆栈大小
-XX:+UseG1GC            # 使用 G1 垃圾收集器
-XX:+UseParallelGC      # 使用并行垃圾收集器
-XX:+UseConcMarkSweepGC # 使用 CMS 垃圾收集器
-XX:+UseZGC             # 使用 Z 垃圾收集器（JDK 11+）
-XX:+HeapDumpOnOutOfMemoryError # 内存溢出时生成堆转储
```

**示例：**

```bash
# 运行带有 main 方法的类
java HelloWorld

# 运行带有包名的类
java com.example.Main

# 指定类路径
java -classpath bin:lib/dependency.jar com.example.Main

# 运行 JAR 文件
java -jar application.jar

# 设置系统属性
java -Dserver.port=8080 -Dspring.profiles.active=dev -jar application.jar

# 设置内存参数
java -Xms512m -Xmx2g -jar application.jar

# 启用详细的 GC 日志
java -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCDateStamps -Xloggc:gc.log -jar application.jar

# 使用 G1 垃圾收集器
java -XX:+UseG1GC -jar application.jar

# 启用堆转储
java -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/tmp/heapdump.hprof -jar application.jar

# 运行模块（Java 9+）
java -m com.example.app/com.example.Main
```

## 打包和部署

### jar - Java 归档工具

`jar` 命令用于创建和管理 JAR（Java Archive）文件，这些文件用于打包类文件、资源文件和元数据。

**基本语法：**

```bash
jar [options] [jar-file] [manifest-file] [entry-point] [-C dir] files...
```

**常用选项：**

```bash
c                       # 创建新的 JAR 文件
t                       # 列出 JAR 文件的内容表
x                       # 从 JAR 文件提取指定的（或所有）文件
u                       # 更新现有的 JAR 文件
f                       # 指定 JAR 文件名
m                       # 包含指定清单文件中的清单信息
e                       # 为捆绑到可执行 jar 文件的独立应用程序指定应用程序入口点
v                       # 生成详细输出
0                       # 不压缩（存储）
M                       # 不创建条目的清单文件
-C <dir>                # 更改为指定的目录并包含以下文件
```

**示例：**

```bash
# 创建 JAR 文件
jar cf myapp.jar *.class

# 创建带有清单的 JAR 文件
jar cfm myapp.jar manifest.txt *.class

# 创建可执行 JAR 文件
jar cfe myapp.jar com.example.Main *.class

# 查看 JAR 文件内容
jar tf myapp.jar

# 查看 JAR 文件详细内容
jar tvf myapp.jar

# 提取 JAR 文件内容
jar xf myapp.jar

# 更新 JAR 文件
jar uf myapp.jar NewClass.class

# 从特定目录创建 JAR 文件
jar cf myapp.jar -C classes .

# 创建多模块 JAR 文件
jar cf myapp.jar -C classes . -C resources .
```

### jlink - 自定义运行时映像生成器

`jlink` 命令（Java 9+）用于创建自定义的运行时映像，只包含应用程序所需的模块，从而减小分发大小。

**基本语法：**

```bash
jlink [options] --module-path <modulepath> --add-modules <module>[,<module>...] --output <path>
```

**常用选项：**

```bash
--module-path <path>     # 指定模块路径
--add-modules <module>   # 指定要解析的根模块
--output <path>          # 输出路径
--compress=<0|1|2>       # 启用压缩：0=无压缩，1=常量字符串共享，2=ZIP
--no-header-files        # 排除 include 头文件
--no-man-pages           # 排除 man 页面
--strip-debug            # 剥离调试信息
--launcher <name>=<module>[/<mainclass>] # 创建启动器脚本
```

**示例：**

```bash
# 创建自定义运行时映像
jlink --module-path $JAVA_HOME/jmods:mods --add-modules com.example.app --output myapp

# 创建带有启动器的自定义运行时映像
jlink --module-path $JAVA_HOME/jmods:mods --add-modules com.example.app --launcher start=com.example.app/com.example.Main --output myapp

# 创建优化的自定义运行时映像
jlink --module-path $JAVA_HOME/jmods:mods --add-modules com.example.app --compress=2 --strip-debug --no-header-files --no-man-pages --output myapp
```

### jpackage - 打包工具

`jpackage` 命令（Java 14+）用于将 Java 应用程序打包为特定平台的安装包（如 .msi、.deb、.dmg 等）。

**基本语法：**

```bash
jpackage [options]
```

**常用选项：**

```bash
--type <type>            # 包类型（exe, msi, rpm, deb, dmg, pkg）
--name <name>            # 应用程序名称
--app-version <version>  # 应用程序版本
--input <path>           # 输入目录（包含要打包的文件）
--dest <path>            # 目标目录（生成的安装包位置）
--main-jar <jarfile>     # 主 JAR 文件
--main-class <classname> # 主类名
--module <modulename>    # 主模块名
--icon <path>            # 应用程序图标
--description <text>     # 应用程序描述
--vendor <name>          # 应用程序供应商
--copyright <text>       # 版权信息
--java-options <options> # JVM 选项
--runtime-image <path>   # 自定义运行时映像路径
```

**示例：**

```bash
# 从 JAR 文件创建安装包
jpackage --input target --main-jar myapp.jar --name MyApp --dest output

# 指定应用程序版本和图标
jpackage --input target --main-jar myapp.jar --name MyApp --app-version 1.0.0 --icon src/main/resources/icon.png --dest output

# 创建特定类型的安装包
jpackage --type msi --input target --main-jar myapp.jar --name MyApp --dest output

# 使用自定义运行时映像
jpackage --runtime-image custom-runtime --input target --main-jar myapp.jar --name MyApp --dest output

# 从模块创建安装包
jpackage --module com.example.app/com.example.Main --name MyApp --dest output
```

## 监控和诊断

### jps - JVM 进程状态工具

`jps` 命令列出系统上所有的 Java 虚拟机（JVM）进程。

**基本语法：**

```bash
jps [options]
```

**常用选项：**

```bash
-l                       # 显示完整的包名和应用主类名
-m                       # 显示传递给 main 方法的参数
-v                       # 显示传递给 JVM 的参数
-q                       # 只显示进程 ID
```

**示例：**

```bash
# 列出所有 Java 进程
jps

# 显示完整的类名
jps -l

# 显示 JVM 参数
jps -v

# 显示 main 方法参数
jps -m

# 只显示进程 ID
jps -q

# 组合使用选项
jps -lvm
```

### jstat - JVM 统计监控工具

`jstat` 命令用于监控 JVM 的各种统计信息，如类加载、编译、垃圾收集、内存使用等。

**基本语法：**

```bash
jstat [options] <vmid> [interval [count]]
```

**常用选项：**

```bash
-class                   # 显示类加载统计信息
-compiler                # 显示 JIT 编译统计信息
-gc                      # 显示垃圾收集统计信息
-gccapacity              # 显示各代的容量及使用情况
-gccause                 # 显示垃圾收集统计信息（同 -gcutil），附加最近一次 GC 的原因
-gcnew                   # 显示新生代统计信息
-gcnewcapacity           # 显示新生代容量及使用情况
-gcold                   # 显示老年代统计信息
-gcoldcapacity           # 显示老年代容量及使用情况
-gcutil                  # 显示垃圾收集统计摘要
-printcompilation        # 显示 JIT 编译方法统计信息
```

**示例：**

```bash
# 显示进程 ID 为 1234 的 JVM 的 GC 统计信息
jstat -gc 1234

# 每隔 1000 毫秒（1 秒）显示一次 GC 统计信息，共显示 10 次
jstat -gc 1234 1000 10

# 显示 GC 使用率摘要
jstat -gcutil 1234

# 显示类加载统计信息
jstat -class 1234

# 显示 JIT 编译统计信息
jstat -compiler 1234

# 显示新生代统计信息
jstat -gcnew 1234

# 显示老年代统计信息
jstat -gcold 1234
```

### jinfo - 配置信息工具

`jinfo` 命令用于查看和动态修改运行中的 Java 应用程序的 JVM 参数。

**基本语法：**

```bash
jinfo [options] <pid>
```

**常用选项：**

```bash
-flag <name>             # 打印指定的 JVM 参数值
-flag [+|-]<name>        # 启用或禁用指定的 JVM 布尔参数
-flag <name>=<value>     # 设置指定的 JVM 参数值
-flags                   # 打印所有 JVM 参数
-sysprops                # 打印 Java 系统属性
```

**示例：**

```bash
# 显示进程的所有 JVM 参数
jinfo -flags 1234

# 显示进程的系统属性
jinfo -sysprops 1234

# 查看特定 JVM 参数的值
jinfo -flag MaxHeapSize 1234

# 启用特定的布尔参数
jinfo -flag +HeapDumpOnOutOfMemoryError 1234

# 禁用特定的布尔参数
jinfo -flag -HeapDumpOnOutOfMemoryError 1234

# 设置特定参数的值
jinfo -flag NewSize=134217728 1234
```

### jmap - 内存映射工具

`jmap` 命令用于获取运行中的 Java 进程的内存相关信息，如堆转储、对象统计等。

**基本语法：**

```bash
jmap [options] <pid>
```

**常用选项：**

```bash
-heap                    # 显示堆摘要信息
-histo[:live]            # 显示堆中对象的统计信息，如果指定了 :live，则只统计活动对象
-clstats                 # 打印类加载器统计信息
-finalizerinfo           # 显示等待终结的对象信息
-dump:<dump-options>     # 生成 Java 堆转储，格式为：
                         # live,format=b,file=<filename> - 只转储活动对象
```

**示例：**

```bash
# 显示堆摘要信息
jmap -heap 1234

# 显示堆中对象的统计信息
jmap -histo 1234

# 只显示活动对象的统计信息
jmap -histo:live 1234

# 生成堆转储文件
jmap -dump:format=b,file=heap.bin 1234

# 只转储活动对象
jmap -dump:live,format=b,file=heap.bin 1234

# 显示类加载器统计信息
jmap -clstats 1234

# 显示等待终结的对象信息
jmap -finalizerinfo 1234
```

### jstack - 堆栈跟踪工具

`jstack` 命令用于生成 Java 线程的堆栈跟踪信息，对于分析线程死锁、阻塞等问题非常有用。

**基本语法：**

```bash
jstack [options] <pid>
```

**常用选项：**

```bash
-l                       # 长列表，打印关于锁的附加信息
-F                       # 强制线程转储（当 jstack <pid> 没有响应时使用）
-m                       # 打印 Java 和本机帧（混合模式）
```

**示例：**

```bash
# 生成线程堆栈跟踪
jstack 1234

# 生成包含锁信息的线程堆栈跟踪
jstack -l 1234

# 强制生成线程堆栈跟踪
jstack -F 1234

# 生成混合模式的线程堆栈跟踪
jstack -m 1234
```

### jcmd - JVM 诊断命令工具

`jcmd` 命令是一个多功能工具，可以向 JVM 发送诊断命令请求，它可以替代 jmap、jstack 等工具。

**基本语法：**

```bash
jcmd <pid | main-class> <command> [arguments]
jcmd -l
jcmd -h
```

**常用命令：**

```bash
help                     # 列出可用命令
help <command>           # 显示命令的帮助信息
VM.uptime                # 显示 JVM 的启动时间
VM.flags                 # 显示 JVM 标志
VM.system_properties     # 显示系统属性
VM.command_line          # 显示命令行参数
VM.version               # 显示 JVM 版本信息
VM.native_memory         # 显示本机内存使用情况
GC.class_histogram       # 显示类的直方图
GC.heap_dump             # 生成堆转储
GC.run                   # 运行垃圾收集
GC.run_finalization      # 运行终结
Thread.print             # 显示线程堆栈跟踪
JFR.start                # 启动 JFR 记录
JFR.stop                 # 停止 JFR 记录
JFR.dump                 # 转储 JFR 记录数据
JFR.check                # 检查正在运行的 JFR 记录
```

**示例：**

```bash
# 列出所有 Java 进程
jcmd -l

# 列出进程可用的所有命令
jcmd 1234 help

# 显示 JVM 版本信息
jcmd 1234 VM.version

# 显示系统属性
jcmd 1234 VM.system_properties

# 显示 JVM 标志
jcmd 1234 VM.flags

# 生成堆转储
jcmd 1234 GC.heap_dump filename=heap.hprof

# 显示类的直方图
jcmd 1234 GC.class_histogram

# 显示线程堆栈跟踪
jcmd 1234 Thread.print

# 运行垃圾收集
jcmd 1234 GC.run

# 启动 JFR 记录
jcmd 1234 JFR.start name=MyRecording settings=profile duration=60s filename=recording.jfr

# 停止 JFR 记录
jcmd 1234 JFR.stop name=MyRecording
```

## 调试和分析

### jdb - Java 调试器

`jdb` 命令是一个命令行调试工具，用于查找和修复 Java 程序中的错误。

**基本语法：**

```bash
jdb [options] [class] [arguments]
```

**常用选项：**

```bash
-attach <address>        # 连接到指定地址的调试服务器
-listen <address>        # 等待调试客户端在指定地址连接
-launch                  # 立即启动调试应用程序
-sourcepath <path>       # 指定查找源文件的路径
-classpath <path>        # 指定查找类文件的路径
```

**常用命令：**

```bash
help                     # 显示帮助信息
run                      # 开始执行调试程序
break <class>:<line>     # 在指定类的指定行设置断点
break <class>.<method>   # 在指定类的指定方法设置断点
clear <class>:<line>     # 清除指定类的指定行的断点
step                     # 单步执行（进入方法）
stepi                    # 单步执行一条指令
next                     # 单步执行（不进入方法）
cont                     # 继续执行程序
print <expr>             # 打印表达式的值
dump <expr>              # 打印对象的所有信息
threads                  # 列出所有线程
thread <thread_id>       # 切换到指定线程
where                    # 显示当前线程的调用堆栈
wherei                   # 显示当前线程的调用堆栈和程序计数器
list                     # 显示源代码
locals                   # 显示当前帧中的所有本地变量
monitor <command>        # 每次程序停止时执行命令
monitor                  # 列出所有监视器
unmonitor <monitor_id>   # 删除指定的监视器
exit                     # 退出调试器
```

**示例：**

```bash
# 启动调试器并运行类
jdb HelloWorld

# 连接到正在运行的 Java 进程
jdb -attach 8000

# 等待调试客户端连接
jdb -listen 8000

# 指定源代码路径
jdb -sourcepath src HelloWorld

# 在 Java 程序中启用调试
java -agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=8000 HelloWorld
```

### jvisualvm - 可视化工具

`jvisualvm` 是一个图形化工具，用于监控、分析和排除 Java 应用程序故障。

**基本语法：**

```bash
jvisualvm [options]
```

**常用选项：**

```bash
--openjmx <url>          # 打开 JMX 连接
--openpid <pid>          # 打开本地 Java 进程
--openfile <file>        # 打开快照文件
```

**主要功能：**

- 监控本地和远程 Java 应用程序
- 分析应用程序性能和内存使用情况
- 生成和分析堆转储
- 分析 CPU 和内存分析数据
- 监控 GC 活动
- 监控线程活动

**示例：**

```bash
# 启动 JVisualVM
jvisualvm

# 打开特定的 Java 进程
jvisualvm --openpid 1234

# 打开 JMX 连接
jvisualvm --openjmx service:jmx:rmi:///jndi/rmi://localhost:9999/jmxrmi

# 打开堆转储文件
jvisualvm --openfile heap.hprof
```

### jmc - Java Mission Control

`jmc` 是一个用于监控和管理 Java 应用程序的高级工具，包括 Java Flight Recorder（JFR）功能。

**基本语法：**

```bash
jmc [options]
```

**主要功能：**

- 实时监控 Java 应用程序
- 分析 Java Flight Recorder 记录
- 检测性能问题和内存泄漏
- 分析 GC 行为
- 监控线程和锁
- 分析代码热点

**示例：**

```bash
# 启动 Java Mission Control
jmc

# 在 Java 应用程序中启用 JFR
java -XX:+FlightRecorder -XX:StartFlightRecording=duration=60s,filename=recording.jfr MyApp
```

## 安全工具

### keytool - 密钥和证书管理工具

`keytool` 命令用于管理密钥库（keystore）中的密钥和证书。

**基本语法：**

```bash
keytool [commands]
```

**常用命令：**

```bash
-genkeypair              # 生成密钥对
-importcert              # 导入证书或证书链
-exportcert              # 导出证书
-list                    # 列出密钥库中的条目
-delete                  # 删除密钥库中的条目
-storepasswd             # 更改密钥库密码
-keypasswd               # 更改密钥密码
-certreq                 # 生成证书请求
-printcert               # 打印证书内容
```

**常用选项：**

```bash
-keystore <file>         # 密钥库文件名
-storepass <password>    # 密钥库密码
-keypass <password>      # 密钥密码
-alias <alias>           # 条目的别名
-file <file>             # 输入/输出文件名
-validity <days>         # 证书有效期（天）
-keyalg <algorithm>      # 密钥算法（如 RSA）
-keysize <size>          # 密钥大小（如 2048）
-storetype <type>        # 密钥库类型（如 JKS, PKCS12）
```

**示例：**

```bash
# 生成密钥对
keytool -genkeypair -alias mykey -keyalg RSA -keysize 2048 -validity 365 -keystore keystore.jks

# 列出密钥库中的条目
keytool -list -keystore keystore.jks

# 导出证书
keytool -exportcert -alias mykey -file cert.cer -keystore keystore.jks

# 导入证书
keytool -importcert -alias cacert -file cacert.cer -keystore keystore.jks

# 生成证书请求
keytool -certreq -alias mykey -file certreq.csr -keystore keystore.jks

# 打印证书内容
keytool -printcert -file cert.cer

# 删除密钥库中的条目
keytool -delete -alias mykey -keystore keystore.jks

# 更改密钥库密码
keytool -storepasswd -keystore keystore.jks

# 更改密钥密码
keytool -keypasswd -alias mykey -keystore keystore.jks
```

### jarsigner - JAR 签名工具

`jarsigner` 命令用于签名和验证 JAR 文件。

**基本语法：**

```bash
jarsigner [options] jar-file alias
jarsigner -verify [options] jar-file
```

**常用选项：**

```bash
-keystore <file>         # 密钥库文件名
-storepass <password>    # 密钥库密码
-keypass <password>      # 密钥密码
-signedjar <file>        # 已签名的 JAR 文件名
-verify                  # 验证 JAR 文件签名
-verbose                 # 生成详细输出
-tsa <url>               # 时间戳授权 URL
```

**示例：**

```bash
# 签名 JAR 文件
jarsigner -keystore keystore.jks -storepass password myapp.jar mykey

# 签名 JAR 文件并指定输出文件
jarsigner -keystore keystore.jks -storepass password -signedjar signed.jar myapp.jar mykey

# 验证 JAR 文件签名
jarsigner -verify myapp.jar

# 详细验证 JAR 文件签名
jarsigner -verify -verbose myapp.jar

# 使用时间戳签名 JAR 文件
jarsigner -keystore keystore.jks -tsa http://timestamp.digicert.com myapp.jar mykey
```

## 国际化工具

### native2ascii - 本地编码到ASCII转换器

`native2ascii` 命令用于将包含非 ASCII 字符的文件转换为 ASCII 编码的 Unicode 转义序列。

**基本语法：**

```bash
native2ascii [options] [inputfile [outputfile]]
```

**常用选项：**

```bash
-encoding <encoding>     # 指定输入文件的编码
-reverse                 # 执行反向操作（将 ASCII 编码的 Unicode 转义序列转换为本地编码）
```

**示例：**

```bash
# 将本地编码文件转换为 ASCII
native2ascii input.txt output.txt

# 指定输入文件的编码
native2ascii -encoding UTF-8 input.txt output.txt

# 执行反向操作
native2ascii -reverse input.txt output.txt
```

## 远程方法调用

### rmic - RMI 编译器

`rmic` 命令用于生成远程方法调用（RMI）存根和骨架类。

**基本语法：**

```bash
rmic [options] <class>
```

**常用选项：**

```bash
-classpath <path>        # 指定查找类文件的位置
-d <directory>           # 指定放置生成的类文件的位置
-keep                    # 保留生成的源文件
-v1.1                    # 创建 1.1 存根协议版本
-v1.2                    # 创建 1.2 存根协议版本（默认）
-iiop                    # 创建 IIOP 存根和骨架
```

**示例：**

```bash
# 为类生成 RMI 存根
rmic com.example.MyRemoteImpl

# 指定输出目录
rmic -d output com.example.MyRemoteImpl

# 指定类路径
rmic -classpath classes com.example.MyRemoteImpl

# 保留生成的源文件
rmic -keep com.example.MyRemoteImpl
```

### rmiregistry - 远程对象注册表

`rmiregistry` 命令用于创建和启动远程对象注册表。

**基本语法：**

```bash
rmiregistry [port]
```

**示例：**

```bash
# 在默认端口（1099）启动 RMI 注册表
rmiregistry

# 在指定端口启动 RMI 注册表
rmiregistry 8000
```

## IDL 和 RMI-IIOP

### idlj - IDL 到 Java 编译器

`idlj` 命令用于将 IDL（接口定义语言）文件转换为 Java 文件。

**基本语法：**

```bash
idlj [options] <idl-file>
```

**常用选项：**

```bash
-fall                    # 生成所有绑定
-fclient                 # 生成客户端绑定
-fserver                 # 生成服务器绑定
-fserverTIE              # 生成服务器 TIE 绑定
-td <directory>          # 指定输出目录
-keep                    # 保留生成的源文件
-pkgPrefix <type> <pkg>  # 为指定类型指定包前缀
```

**示例：**

```bash
# 生成所有绑定
idlj -fall example.idl

# 生成客户端绑定
idlj -fclient example.idl

# 生成服务器绑定
idlj -fserver example.idl

# 指定输出目录
idlj -td output example.idl

# 为类型指定包前缀
idlj -pkgPrefix example com.example example.idl
```

### orbd - 对象请求代理守护进程

`orbd` 命令用于启用客户端透明地定位和调用服务器上的持久对象。

**基本语法：**

```bash
orbd [options]
```

**常用选项：**

```bash
-port <port>             # 激活端口号
-defaultdb <directory>   # 数据库目录
-serverid <id>           # 服务器 ID
-ORBInitialPort <port>   # 初始端口
```

**示例：**

```bash
# 启动 ORBD
orbd

# 指定端口
orbd -port 1050

# 指定数据库目录
orbd -defaultdb /var/orbd
```

## Java 9+ 模块工具

### jdeps - Java 类依赖分析器

`jdeps` 命令用于分析 Java 类的依赖关系。

**基本语法：**

```bash
jdeps [options] <path> ...
```

**常用选项：**

```bash
-s, --summary            # 只打印摘要
-v, --verbose            # 打印所有类级别的依赖关系
-p, --package <pkg>      # 查找与给定包名匹配的依赖关系
-e, --regex <regex>      # 查找与给定模式匹配的依赖关系
--class-path <path>      # 指定查找类文件的位置
--module-path <path>     # 指定模块路径
--multi-release <version> # 指定多版本 JAR 文件的版本
--generate-module-info <dir> # 生成 module-info.java 到指定目录
--check <module>         # 分析给定模块的依赖关系
--list-deps              # 列出依赖模块
--list-reduced-deps      # 列出缩减的依赖模块
--print-module-deps      # 以逗号分隔的列表打印模块依赖关系
--ignore-missing-deps    # 忽略缺少的依赖关系
```

**示例：**

```bash
# 分析类文件的依赖关系
jdeps MyClass.class

# 分析 JAR 文件的依赖关系
jdeps myapp.jar

# 打印摘要
jdeps -s myapp.jar

# 打印详细信息
jdeps -v myapp.jar

# 分析特定包的依赖关系
jdeps -p com.example myapp.jar

# 生成模块信息
jdeps --generate-module-info output myapp.jar

# 列出模块依赖关系
jdeps --list-deps myapp.jar

# 打印模块依赖关系
jdeps --print-module-deps myapp.jar
```

### jmod - JMOD 文件操作工具

`jmod` 命令（Java 9+）用于创建和操作 JMOD 文件，这些文件是 Java 模块的打包格式。

**基本语法：**

```bash
jmod (create|extract|list|describe|hash) [options] <jmod-file>
```

**常用命令：**

```bash
create                   # 创建新的 JMOD 文件
extract                  # 提取 JMOD 文件的所有文件
list                     # 列出 JMOD 文件的所有条目
describe                 # 打印 JMOD 文件的模块详细信息
hash                     # 记录依赖模块的哈希值
```

**常用选项：**

```bash
--class-path <path>      # 指定类路径
--cmds <path>            # 指定本机命令目录
--config <path>          # 指定用户可编辑配置文件目录
--dir <path>             # 指定提取目标目录
--dry-run                # 哈希模式的试运行
--hash-modules <regex>   # 计算和记录匹配模式的模块的哈希值
--help                   # 打印帮助信息
--legal-notices <path>   # 指定法律声明目录
--libs <path>            # 指定本机库目录
--main-class <class>     # 指定主类
--module-path <path>     # 指定模块路径
--module-version <version> # 指定模块版本
--target-platform <platform> # 指定目标平台
```

**示例：**

```bash
# 创建 JMOD 文件
jmod create --class-path mods/com.example.app --main-class com.example.Main com.example.app.jmod

# 列出 JMOD 文件内容
jmod list com.example.app.jmod

# 描述 JMOD 文件
jmod describe com.example.app.jmod

# 提取 JMOD 文件内容
jmod extract --dir output com.example.app.jmod

# 计算哈希值
jmod hash --module-path mods --hash-modules java.base com.example.app.jmod
```

---

这个文档涵盖了 JDK 自带的大部分常用命令及其用法，适合作为日常开发参考。对于更详细的信息和高级用法，建议查阅 Oracle 或 OpenJDK 的官方文档。