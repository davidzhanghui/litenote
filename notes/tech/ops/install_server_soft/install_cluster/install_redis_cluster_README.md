# Redis集群安装脚本

本目录包含三个不同的Redis集群安装脚本，分别适用于不同的系统环境和部署需求。

## 脚本概览

| 脚本名称 | 适用系统 | 安装方式 | 优点 | 缺点 |
|---------|---------|---------|------|------|
| `install_redis_cluster_apt.sh` | Ubuntu/Debian | APT包管理器 | 简单快速，系统集成好，自动配置systemd服务，优化系统参数 | 版本可能较旧 |
| `install_redis_cluster_yum.sh` | CentOS/RHEL/Rocky/AlmaLinux | YUM/DNF包管理器 | 简单快速，系统集成好，自动配置SELinux和firewalld，优化系统参数 | 版本可能较旧 |
| `install_redis_cluster_docker.sh` | 所有支持Docker的系统 | Docker容器 | 版本新，隔离性好，易管理 | 需要Docker环境 |

## 快速选择指南

### 推荐使用Docker版本 (`install_redis_cluster_docker.sh`)

**适合场景：**
- 开发环境
- 测试环境
- 需要快速部署和清理
- 需要版本隔离
- 多环境部署

**优势：**
- ✅ 最新的Redis版本
- ✅ 完全隔离，不影响系统
- ✅ 一键启动/停止/重启
- ✅ 易于备份和迁移
- ✅ 跨平台兼容

### 使用包管理器版本

**适合场景：**
- 生产环境
- 需要系统级集成
- 不允许使用Docker
- 需要与系统监控集成

**Ubuntu/Debian系统：** 使用 `install_redis_cluster_apt.sh`
**CentOS/RHEL系统：** 使用 `install_redis_cluster_yum.sh`

## 安装前准备

### 系统要求
- 操作系统：Ubuntu 18.04+, Debian 9+, CentOS 7+, RHEL 7+
- 内存：至少2GB可用内存
- 磁盘：至少5GB可用空间
- 网络：确保防火墙允许Redis端口通信

### 权限要求
所有脚本都需要root权限运行：
```bash
sudo bash install_redis_cluster_xxx.sh
```

## 详细使用说明

### 1. Docker版本安装

```bash
# 下载并执行脚本
sudo bash install_redis_cluster_docker.sh

# 安装完成后的管理命令
cd /opt/redis-cluster

# 启动集群
./start.sh

# 停止集群
./stop.sh

# 重启集群
./restart.sh

# 查看状态
./status.sh

# 连接Redis
./connect.sh        # 连接到7001端口
./connect.sh 7002   # 连接到7002端口
```

### 2. APT版本安装 (Ubuntu/Debian)

```bash
# 下载并执行脚本
sudo bash install_redis_cluster_apt.sh

# 服务管理
sudo systemctl status redis-cluster-7001
sudo systemctl restart redis-cluster-7001
sudo systemctl stop redis-cluster-7001

# 连接Redis
redis-cli -c -p 7001 -a 123456

# 查看安装日志
tail -f /tmp/redis_cluster_install.log
```

**功能特点:**
- 自动检测Ubuntu/Debian系统
- 自动安装EPEL仓库(如需要)
- 自动创建Redis专用用户
- 自动优化系统参数(THP, overcommit_memory)
- 自动配置防火墙规则(UFW)
- 详细的安装日志记录(/tmp/redis_cluster_install.log)

### 3. YUM版本安装 (CentOS/RHEL)

```bash
# 下载并执行脚本
sudo bash install_redis_cluster_yum.sh

# 服务管理
sudo systemctl status redis-cluster-7001
sudo systemctl restart redis-cluster-7001
sudo systemctl stop redis-cluster-7001

# 连接Redis
redis-cli -c -p 7001 -a 123456

# 查看安装日志
tail -f /tmp/redis_cluster_install.log
```

**功能特点:**
- 自动检测CentOS/RHEL/Rocky/AlmaLinux系统
- 自动安装EPEL仓库
- 自动创建Redis专用用户
- 自动优化系统参数(THP, overcommit_memory)
- 自动配置SELinux策略
- 自动配置firewalld/iptables规则
- 详细的安装日志记录(/tmp/redis_cluster_install.log)

## 配置说明

### 默认配置
- **端口：** 7001, 7002, 7003
- **密码：** 123456
- **集群模式：** 3个主节点，无从节点
- **数据目录：** `/opt/redis-cluster`
- **最大内存：** 256MB per节点
- **日志文件：** `/tmp/redis_cluster_install.log` (安装日志)
- **系统用户：** `redis` (专用用户)
- **集群总线端口：** 17001, 17002, 17003

### 自定义配置

在执行脚本前，可以修改脚本顶部的配置变量：

```bash
# 修改端口(同时会自动设置对应的集群总线端口为1+端口号)
REDIS_PORTS=(7001 7002 7003)

# 修改密码
REDIS_PASSWORD="your_password"

# 修改安装目录
BASE_DIR="/opt/redis-cluster"

# 修改Redis运行用户(APT/YUM版本)
REDIS_USER="redis"

# 修改日志级别(APT/YUM版本)
LOG_LEVEL="notice"
```

## 常用操作

### 集群管理

```bash
# 查看集群信息
redis-cli -p 7001 -a 123456 cluster info

# 查看节点信息
redis-cli -p 7001 -a 123456 cluster nodes

# 添加新节点
redis-cli --cluster add-node 新节点IP:端口 现有节点IP:端口 -a 123456

# 重新分片
redis-cli --cluster reshard 节点IP:端口 -a 123456
```

### 数据操作

```bash
# 连接集群（自动重定向）
redis-cli -c -p 7001 -a 123456

# 设置数据
set key1 value1

# 获取数据
get key1

# 查看key分布
cluster keyslot key1
```

### 监控和日志

```bash
# 查看Redis日志
tail -f /opt/redis-cluster/7001/logs/redis-7001.log

# 查看系统服务状态（非Docker版本）
systemctl status redis-cluster-7001

# 查看Docker容器状态（Docker版本）
docker-compose ps
docker-compose logs redis-7001
```

## 故障排除

### 常见问题

1. **端口被占用**
   ```bash
   # 检查端口占用
   netstat -tlnp | grep 7001
   
   # 修改脚本中的端口配置
   REDIS_PORTS=(7004 7005 7006)
   ```

2. **内存不足**
   ```bash
   # 检查内存使用
   free -h
   
   # 减少Redis内存限制
   # 在配置文件中修改：maxmemory 128mb
   ```

3. **防火墙阻止连接**
   ```bash
   # Ubuntu/Debian
   sudo ufw allow 7001:7003/tcp
   
   # CentOS/RHEL
   sudo firewall-cmd --permanent --add-port=7001-7003/tcp
   sudo firewall-cmd --reload
   ```

4. **SELinux问题（CentOS/RHEL）**
   ```bash
   # 临时禁用SELinux
   sudo setenforce 0
   
   # 永久禁用SELinux
   sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
   ```

### 日志位置

- **安装日志：** `/tmp/redis_cluster_install.log`
- **Redis日志：** `/opt/redis-cluster/[端口]/logs/redis-[端口].log`
- **系统日志：** `journalctl -u redis-cluster-7001`

## 卸载说明

### Docker版本卸载
```bash
cd /opt/redis-cluster
docker-compose down
docker rmi redis:7-alpine
rm -rf /opt/redis-cluster
```

### 包管理器版本卸载
```bash
# 停止服务
sudo systemctl stop redis-cluster-{7001,7002,7003}
sudo systemctl disable redis-cluster-{7001,7002,7003}

# 删除服务文件
sudo rm /etc/systemd/system/redis-cluster-*.service
sudo systemctl daemon-reload

# 删除数据目录
sudo rm -rf /opt/redis-cluster

# 卸载Redis（可选）
# Ubuntu/Debian
sudo apt remove redis-server redis-tools

# CentOS/RHEL
sudo yum remove redis
```

## 性能优化建议

### 系统级优化
```bash
# 内存过量分配
echo 'vm.overcommit_memory = 1' >> /etc/sysctl.conf

# 禁用透明大页
echo never > /sys/kernel/mm/transparent_hugepage/enabled

# 增加文件描述符限制
echo 'redis soft nofile 65535' >> /etc/security/limits.conf
echo 'redis hard nofile 65535' >> /etc/security/limits.conf
```

### Redis配置优化
```bash
# 调整内存策略
maxmemory-policy allkeys-lru

# 启用压缩
rdbcompression yes

# 调整保存策略
save 900 1
save 300 10
save 60 10000
```

## 安全建议

1. **修改默认密码**
   - 使用强密码替换默认的 "123456"

2. **网络安全**
   - 仅允许必要的IP访问Redis端口
   - 使用VPN或内网访问

3. **定期备份**
   ```bash
   # 创建备份脚本
   #!/bin/bash
   DATE=$(date +%Y%m%d_%H%M%S)
   tar -czf /backup/redis_cluster_$DATE.tar.gz /opt/redis-cluster/*/data
   ```

4. **监控告警**
   - 监控内存使用率
   - 监控连接数
   - 监控集群健康状态

## 支持和反馈

如果在使用过程中遇到问题，请：

1. 检查安装日志：`/tmp/redis_cluster_install.log`
2. 查看Redis日志：`/opt/redis-cluster/[端口]/logs/redis-[端口].log`
3. 确认系统要求是否满足
4. 参考故障排除章节

---

**注意：** 这些脚本主要用于开发和测试环境。生产环境部署时，请根据实际需求进行安全加固和性能调优。