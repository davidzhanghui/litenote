# Java环境安装脚本说明

## 脚本概述

`install_java.sh` 是一个自动化安装Java环境的Shell脚本，支持在CentOS/RHEL和Ubuntu/Debian系统上安装OpenJDK 17。

## 功能特性

- ✅ 自动检测操作系统类型（CentOS/Ubuntu）
- ✅ 智能检查Java是否已安装，避免重复安装
- ✅ 安装OpenJDK 17（包含JDK和开发工具）
- ✅ 自动配置JAVA_HOME环境变量
- ✅ 自动添加Java到系统PATH
- ✅ 安装后验证和信息展示
- ✅ 彩色日志输出，便于查看执行状态

## 系统要求

### 支持的操作系统
- CentOS 7/8
- RHEL 7/8
- Ubuntu 18.04/20.04/22.04
- Debian 9/10/11

### 权限要求
- 必须使用root用户执行
- 需要网络连接以下载软件包

## 使用方法

### 1. 下载脚本
```bash
# 如果脚本已在服务器上
cd /path/to/scripts

# 或者从远程下载
wget https://your-server.com/install_java.sh
```

### 2. 添加执行权限
```bash
chmod +x install_java.sh
```

### 3. 执行安装
```bash
# 使用root用户执行
sudo ./install_java.sh

# 或者切换到root用户后执行
su -
./install_java.sh
```

## 安装内容

### CentOS/RHEL系统
- 安装包：`java-17-openjdk` 和 `java-17-openjdk-devel`
- JAVA_HOME：`/usr/lib/jvm/java-17-openjdk`

### Ubuntu/Debian系统
- 安装包：`openjdk-17-jdk`
- JAVA_HOME：`/usr/lib/jvm/java-17-openjdk-amd64`

### 环境变量配置
脚本会自动在 `/etc/profile` 中添加以下配置：
```bash
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk
export PATH=$JAVA_HOME/bin:$PATH
```

## 验证安装

安装完成后，脚本会自动执行验证，您也可以手动验证：

```bash
# 查看Java版本
java -version

# 查看Java编译器版本
javac -version

# 查看JAVA_HOME环境变量
echo $JAVA_HOME

# 查看Java安装路径
which java
```

## 预期输出示例

```
[INFO] 开始安装Java环境...
[INFO] 检测到Ubuntu/Debian系统
[STEP] 更新系统包管理器...
[INFO] 系统更新完成
[STEP] 检查Java环境...
[STEP] 安装Java环境...
[INFO] Java安装完成
[STEP] 验证Java安装结果...
==================== Java安装验证 ====================
Java版本:
openjdk version "17.0.x" 2023-xx-xx
...
[INFO] Java安装验证完成
==================== Java安装完成 ====================
[INFO] Java环境安装完成！
```

## 常见问题

### Q1: 脚本执行失败，提示权限不足
**A:** 确保使用root用户执行脚本：
```bash
sudo ./install_java.sh
```

### Q2: 环境变量不生效
**A:** 重新登录系统或执行：
```bash
source /etc/profile
```

### Q3: 网络连接问题导致下载失败
**A:** 检查网络连接，或配置代理：
```bash
export http_proxy=http://proxy-server:port
export https_proxy=http://proxy-server:port
```

### Q4: 系统已安装其他版本Java
**A:** 脚本会检测到已安装的Java并跳过安装。如需更换版本，请先卸载：
```bash
# CentOS/RHEL
yum remove java-*-openjdk*

# Ubuntu/Debian
apt remove openjdk-*-jdk
```

## 卸载方法

如需卸载Java环境：

### CentOS/RHEL
```bash
yum remove java-17-openjdk java-17-openjdk-devel
```

### Ubuntu/Debian
```bash
apt remove openjdk-17-jdk
apt autoremove
```

### 清理环境变量
编辑 `/etc/profile` 文件，删除Java相关的export语句。

## 日志说明

脚本使用彩色日志输出：
- 🟢 **[INFO]** - 信息提示（绿色）
- 🔵 **[STEP]** - 执行步骤（蓝色）
- 🟡 **[WARN]** - 警告信息（黄色）
- 🔴 **[ERROR]** - 错误信息（红色）

## 技术支持

如遇到问题，请检查：
1. 系统版本是否支持
2. 网络连接是否正常
3. 磁盘空间是否充足
4. 是否使用root权限执行

## 更新日志

- v1.0 - 初始版本，支持OpenJDK 17安装
- 支持CentOS/RHEL和Ubuntu/Debian系统
- 自动环境变量配置
- 安装验证功能