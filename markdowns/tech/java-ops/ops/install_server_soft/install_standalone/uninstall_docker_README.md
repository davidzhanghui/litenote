# Docker卸载脚本使用说明

## 概述

`uninstall_docker.sh` 是一个完整的Docker卸载脚本，用于彻底移除Docker CE及其所有相关组件。该脚本支持CentOS/RHEL和Ubuntu/Debian系统。

## 功能特性

### 完整卸载
- **Docker CE引擎** - 完全移除Docker核心引擎
- **Docker CLI工具** - 移除Docker命令行工具
- **Containerd运行时** - 卸载容器运行时
- **Docker Compose** - 移除Docker Compose工具
- **Docker插件** - 清理所有Docker插件

### 数据清理
- **容器和镜像** - 删除所有Docker容器和镜像
- **配置文件** - 清理`/etc/docker/`目录
- **数据目录** - 删除`/var/lib/docker/`数据目录
- **网络配置** - 清理Docker网络接口和iptables规则

### 权限清理
- **用户组** - 移除用户的docker组权限
- **系统服务** - 停止并禁用Docker相关服务
- **仓库配置** - 删除Docker软件仓库配置

## 系统要求

### 支持的操作系统
- CentOS 7/8/9
- RHEL 7/8/9
- Ubuntu 18.04/20.04/22.04
- Debian 9/10/11

### 权限要求
- 必须以root用户身份运行
- 需要sudo权限（如果不是root用户）

## 使用方法

### 本地执行

```bash
# 进入脚本目录
cd /path/to/my-blog/scripts/other

# 给脚本添加执行权限
chmod +x uninstall_docker.sh

# 执行卸载脚本
sudo ./uninstall_docker.sh
```

### 远程执行

```bash
# 通过SSH远程执行
ssh root@your-server-ip 'bash -s' < ./scripts/other/uninstall_docker.sh

# 或者先上传再执行
scp ./scripts/other/uninstall_docker.sh root@your-server-ip:/tmp/
ssh root@your-server-ip 'chmod +x /tmp/uninstall_docker.sh && /tmp/uninstall_docker.sh'
```

## 卸载流程

### 1. 系统检测
- 自动检测操作系统类型（CentOS/Ubuntu）
- 验证用户权限

### 2. 确认操作
- 显示将要删除的内容
- 要求用户确认继续操作
- 支持取消操作（输入N或直接回车）

### 3. 服务停止
- 停止Docker服务
- 停止Containerd服务
- 禁用自动启动

### 4. 数据清理
- 停止所有运行的容器
- 删除所有容器和镜像
- 清理Docker系统数据

### 5. 软件卸载
- 卸载Docker CE相关包
- 删除软件仓库配置
- 清理GPG密钥（Ubuntu/Debian）

### 6. 文件清理
- 删除配置目录`/etc/docker/`
- 删除数据目录`/var/lib/docker/`
- 清理其他相关目录

### 7. 权限清理
- 从docker组移除用户
- 删除docker用户组（如果为空）

### 8. 网络清理
- 删除Docker网络接口
- 清理iptables规则

### 9. 验证结果
- 检查服务状态
- 验证命令可用性
- 确认文件删除

## 安全注意事项

### ⚠️ 重要警告
- **数据丢失**: 此操作将永久删除所有Docker容器、镜像和数据
- **不可逆**: 卸载操作无法撤销，请确保已备份重要数据
- **网络影响**: 可能影响其他依赖Docker网络的服务

### 卸载前检查
```bash
# 查看当前容器
docker ps -a

# 查看镜像
docker images

# 查看数据卷
docker volume ls

# 备份重要数据
docker export container_name > backup.tar
```

## 故障排除

### 常见问题

#### 1. 权限不足
```bash
# 错误信息
[ERROR] 请使用root用户运行此脚本

# 解决方案
sudo ./uninstall_docker.sh
```

#### 2. 服务停止失败
```bash
# 手动停止服务
sudo systemctl stop docker
sudo systemctl stop containerd

# 强制杀死进程
sudo pkill -f docker
sudo pkill -f containerd
```

#### 3. 文件删除失败
```bash
# 检查文件占用
sudo lsof +D /var/lib/docker

# 强制删除
sudo rm -rf /var/lib/docker
```

#### 4. 网络清理失败
```bash
# 手动清理网络接口
sudo ip link delete docker0

# 重启网络服务
sudo systemctl restart networking  # Ubuntu/Debian
sudo systemctl restart network     # CentOS/RHEL
```

### 日志查看
```bash
# 查看系统日志
sudo journalctl -u docker
sudo journalctl -u containerd

# 查看内核日志
dmesg | grep docker
```

## 重新安装

如果需要重新安装Docker，请使用对应的安装脚本：

```bash
# 重新安装Docker
./scripts/other/install_docker.sh
```

## 脚本输出示例

```
[INFO] 开始卸载Docker容器化平台...
[INFO] 检测到Ubuntu/Debian系统
此操作将完全卸载Docker及其所有数据！
这将删除：
  - 所有Docker容器和镜像
  - Docker配置文件
  - Docker数据目录 (/var/lib/docker)
  - Docker Compose
  - Docker用户组权限

确定要继续吗？(y/N): y
[STEP] 停止Docker服务...
[INFO] Docker服务已停止
[STEP] 清理Docker容器和镜像...
[INFO] 已停止所有运行的容器
[INFO] 已删除所有容器
[INFO] 已删除所有镜像
[STEP] 卸载Docker软件包...
[INFO] Docker软件包卸载完成
[STEP] 卸载Docker Compose...
[INFO] Docker Compose卸载完成
[STEP] 删除Docker配置文件和数据目录...
[INFO] Docker文件清理完成
[STEP] 移除用户组权限...
[INFO] 用户权限清理完成
[STEP] 清理Docker网络配置...
[INFO] 网络配置清理完成
[STEP] 验证Docker卸载结果...
[INFO] Docker卸载验证完成
[INFO] Docker容器化平台卸载完成！
```

## 相关文档

- [Docker安装脚本说明](./install_docker_README.md)
- [Docker官方文档](https://docs.docker.com/)
- [Docker卸载官方指南](https://docs.docker.com/engine/install/ubuntu/#uninstall-docker-engine)

## 技术支持

如果在使用过程中遇到问题，请：

1. 查看本文档的故障排除部分
2. 检查系统日志获取详细错误信息
3. 确保系统满足要求
4. 联系系统管理员获取帮助

---

**注意**: 此脚本会完全移除Docker及其所有数据，请在执行前确保已备份重要数据。