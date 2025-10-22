# Maven 常用命令详解

## 目录

- [Maven 简介](#maven-简介)
- [基本命令](#基本命令)
- [生命周期与阶段](#生命周期与阶段)
- [依赖管理](#依赖管理)
- [插件使用](#插件使用)
- [配置管理](#配置管理)
- [多模块项目](#多模块项目)
- [常见问题解决](#常见问题解决)
- [最佳实践](#最佳实践)

## Maven 简介

Maven 是一个项目管理和构建自动化工具，主要用于 Java 项目。它使用项目对象模型（POM）的概念，通过一小段描述信息来管理项目的构建、报告和文档。

主要功能包括：

- 项目构建
- 依赖管理
- 统一的项目结构
- 项目信息管理
- 项目发布管理

## 基本命令

```bash
# 创建 Maven 项目
mvn archetype:generate -DgroupId=com.example -DartifactId=my-app -DarchetypeArtifactId=maven-archetype-quickstart -DarchetypeVersion=1.4 -DinteractiveMode=false

# 简化版创建项目
mvn archetype:generate -DgroupId=com.example -DartifactId=my-app -DinteractiveMode=false

# 编译项目
mvn compile

# 打包项目
mvn package

# 安装到本地仓库
mvn install

# 清理项目
mvn clean

# 运行测试
mvn test

# 生成站点文档
mvn site

# 查看项目依赖
mvn dependency:tree

# 查看有效的 POM 配置
mvn help:effective-pom

# 显示 Maven 版本信息
mvn -version
```

## 生命周期与阶段

Maven 有三个标准的生命周期：

1. **clean**：清理项目
2. **default**：构建项目
3. **site**：生成项目站点文档

### Clean 生命周期

```bash
# 清理项目，删除 target 目录
mvn clean
```

### Default 生命周期的主要阶段

```bash
# 验证项目是否正确
mvn validate

# 编译项目源代码
mvn compile

# 运行测试
mvn test

# 打包项目
mvn package

# 在本地仓库安装项目
mvn install

# 部署项目到远程仓库
mvn deploy

# 组合使用多个阶段
mvn clean compile
mvn clean test
mvn clean package
mvn clean install
```

### Site 生命周期

```bash
# 生成项目站点文档
mvn site

# 生成站点文档并部署
mvn site-deploy
```

## 依赖管理

```bash
# 查看项目依赖树
mvn dependency:tree

# 分析依赖
mvn dependency:analyze

# 查找依赖冲突
mvn dependency:analyze-duplicate

# 列出过时的依赖
mvn versions:display-dependency-updates

# 列出可用的插件更新
mvn versions:display-plugin-updates

# 下载源码
mvn dependency:sources

# 下载 Javadoc
mvn dependency:resolve -Dclassifier=javadoc

# 复制依赖到指定目录
mvn dependency:copy-dependencies -DoutputDirectory=lib

# 排除传递性依赖
# 在 pom.xml 中使用 <exclusions> 标签
```

## 插件使用

```bash
# 使用 Maven Compiler 插件指定 Java 版本
mvn compile -Dmaven.compiler.source=11 -Dmaven.compiler.target=11

# 使用 Maven Surefire 插件运行单个测试类
mvn test -Dtest=TestClassName

# 跳过测试
mvn package -DskipTests

# 使用 Maven Jar 插件创建可执行 JAR
mvn package -Djar.finalName=my-executable-app

# 使用 Maven Assembly 插件创建包含依赖的 JAR
mvn assembly:single

# 使用 Maven Shade 插件创建 Uber JAR
mvn package shade:shade

# 使用 Maven Jetty 插件运行 Web 应用
mvn jetty:run

# 使用 Maven Tomcat 插件运行 Web 应用
mvn tomcat7:run

# 使用 Maven Spring Boot 插件运行应用
mvn spring-boot:run

# 使用 Maven Enforcer 插件强制规则
mvn enforcer:enforce

# 使用 Maven Checkstyle 插件检查代码风格
mvn checkstyle:check

# 使用 Maven PMD 插件进行代码分析
mvn pmd:check

# 使用 Maven JaCoCo 插件生成测试覆盖率报告
mvn jacoco:report
```

## 配置管理

```bash
# 查看有效的 POM 配置
mvn help:effective-pom

# 查看有效的 settings.xml 配置
mvn help:effective-settings

# 使用指定的配置文件
mvn -s /path/to/settings.xml clean install

# 使用指定的 POM 文件
mvn -f /path/to/pom.xml clean install

# 使用指定的 profile
mvn -P profile-name clean install

# 列出所有可用的 profiles
mvn help:all-profiles

# 显示激活的 profiles
mvn help:active-profiles

# 设置系统属性
mvn -Dproperty=value clean install

# 离线模式运行
mvn -o clean install

# 强制更新快照
mvn -U clean install
```

## 多模块项目

```bash
# 在根项目执行命令，会递归到所有子模块
mvn clean install

# 只构建指定的模块
mvn -pl module-name clean install

# 构建指定模块及其依赖的模块
mvn -pl module-name -am clean install

# 构建指定模块及依赖于它的模块
mvn -pl module-name -amd clean install

# 从指定模块开始构建
mvn -rf module-name clean install

# 并行构建多模块项目
mvn -T 4 clean install  # 使用4个线程
```

## 常见问题解决

```bash
# 强制更新快照依赖
mvn clean install -U

# 跳过测试但编译测试类
mvn install -DskipTests

# 完全跳过测试（不编译测试类）
mvn install -Dmaven.test.skip=true

# 调试 Maven 构建
mvn -X clean install

# 显示过时的 Maven 插件
mvn versions:display-plugin-updates

# 显示过时的依赖
mvn versions:display-dependency-updates

# 更新所有依赖到最新版本
mvn versions:use-latest-versions

# 清理本地仓库中损坏的依赖
mvn dependency:purge-local-repository

# 验证项目完整性
mvn verify

# 检查 POM 文件是否有问题
mvn validate
```

## 最佳实践

### 依赖管理最佳实践

```bash
# 分析未使用的依赖
mvn dependency:analyze

# 使用依赖范围优化依赖
# 在 pom.xml 中使用 <scope> 标签：compile, provided, runtime, test, system, import

# 使用依赖排除解决冲突
# 在 pom.xml 中使用 <exclusions> 标签

# 使用 BOM (Bill of Materials) 管理依赖版本
# 在 pom.xml 中使用 <dependencyManagement> 标签
```

### 构建性能优化

```bash
# 并行构建
mvn -T 1C clean install  # 每个核心一个线程

# 增量构建
mvn incremental:build

# 离线构建（如果依赖已在本地仓库）
mvn -o clean install

# 跳过不必要的插件
mvn install -Dmaven.javadoc.skip=true -Dmaven.source.skip=true
```

### 常用的 Maven Wrapper 命令

```bash
# 使用 Maven Wrapper 安装
mvn -N io.takari:maven:wrapper

# 使用 Maven Wrapper 指定 Maven 版本
mvn -N io.takari:maven:wrapper -Dmaven=3.8.4

# 使用 Maven Wrapper 执行命令
./mvnw clean install  # Linux/Mac
mvnw.cmd clean install  # Windows
```

### 发布项目

```bash
# 部署到远程仓库
mvn deploy

# 发布站点
mvn site-deploy

# 使用 release 插件发布版本
mvn release:prepare
mvn release:perform

# 部署到本地文件系统
mvn deploy -DaltDeploymentRepository=local::default::file:///path/to/deploy
```

---

这个文档涵盖了 Maven 的大部分常用命令和操作场景，适合作为日常开发参考。对于更复杂的 Maven 配置和高级用法，建议查阅 Maven 官方文档或专业书籍。