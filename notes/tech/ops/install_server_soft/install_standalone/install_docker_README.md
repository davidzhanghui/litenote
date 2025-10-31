# Docker安装脚本说明文档

## 概述

`install_docker.sh` 是一个自动化安装Docker容器化平台的Shell脚本，支持在CentOS/RHEL和Ubuntu/Debian系统上安装Docker CE最新版本及Docker Compose。

## 功能特性

### 核心功能
- **多系统支持**: 自动检测并支持CentOS/RHEL和Ubuntu/Debian系统
- **完整安装**: 安装Docker CE、Docker Compose和相关组件
- **智能检测**: 自动检测已安装的Docker服务，避免重复安装
- **旧版清理**: 自动卸载旧版本Docker，确保干净安装
- **权限配置**: 自动配置用户权限，支持非root用户使用Docker

### 配置优化
- **镜像加速**: 预配置国内镜像源，提高镜像下载速度
- **存储优化**: 使用overlay2存储驱动，提供更好的性能
- **日志管理**: 配置日志轮转，防止日志文件过大
- **网络配置**: 优化Docker网络设置
- **资源限制**: 合理配置并发下载和上传限制

## 系统要求

### 支持的操作系统
- **CentOS/RHEL**: 7.x, 8.x, 9.x
- **Ubuntu**: 18.04, 20.04, 22.04, 24.04
- **Debian**: 9, 10, 11, 12

### 硬件要求
- **CPU**: x86_64架构
- **内存**: 最少2GB RAM
- **存储**: 最少20GB可用空间
- **网络**: 需要互联网连接下载软件包

### 权限要求
- 必须以root用户身份运行
- 需要sudo权限进行系统配置

## 使用方法

### 基本使用

```bash
# 1. 下载脚本
wget https://your-domain.com/install_docker.sh
# 或
curl -O https://your-domain.com/install_docker.sh

# 2. 添加执行权限
chmod +x install_docker.sh

# 3. 以root用户运行
sudo ./install_docker.sh
```

### 一键安装

```bash
# 直接下载并执行
curl -fsSL https://your-domain.com/install_docker.sh | sudo bash
```

## 默认配置

### Docker配置
- **数据目录**: `/var/lib/docker`
- **配置文件**: `/etc/docker/daemon.json`
- **存储驱动**: `overlay2`
- **用户组**: `docker`

### 镜像源配置
```json
{
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com",
    "https://mirror.baidubce.com"
  ]
}
```

### 日志配置
- **日志驱动**: `json-file`
- **最大文件大小**: `10MB`
- **保留文件数**: `3个`

### 网络配置
- **桥接网络**: `172.17.0.1/16`
- **固定CIDR**: `172.17.0.0/16`
- **IPv6支持**: `2001:db8:1::/64`

## 安装内容

### Docker组件
1. **Docker CE**: 社区版Docker引擎
2. **Docker CLI**: Docker命令行工具
3. **containerd**: 容器运行时
4. **Docker Buildx**: 多平台构建插件
5. **Docker Compose Plugin**: Compose插件

### Docker Compose
- **独立版本**: 最新稳定版本
- **安装路径**: `/usr/local/bin/docker-compose`
- **软链接**: `/usr/bin/docker-compose`

### 系统服务
- **服务名称**: `docker.service`
- **自动启动**: 已启用
- **服务状态**: 运行中

## 验证安装

### 自动验证
脚本会自动执行以下验证步骤：

```bash
# 1. 检查服务状态
systemctl status docker

# 2. 验证版本信息
docker --version
docker-compose --version

# 3. 查看系统信息
docker info

# 4. 运行测试容器
docker run --rm hello-world
```

### 手动验证

```bash
# 检查Docker服务
sudo systemctl status docker

# 查看Docker版本
docker --version

# 查看Docker信息
docker info

# 列出镜像
docker images

# 列出容器
docker ps -a

# 测试Docker Compose
docker-compose --version
```

