# Redis缓存服务安装脚本说明

## 脚本概述

`install_redis.sh` 是一个自动化安装Redis缓存服务的Shell脚本，支持在CentOS/RHEL和Ubuntu/Debian系统上完整安装和配置Redis 7.x版本。

## 功能特性

- ✅ 自动检测操作系统类型（CentOS/Ubuntu）
- ✅ 智能检查Redis服务状态，避免重复安装
- ✅ 安装Redis 7.x最新版本
- ✅ 自动配置Redis密码认证
- ✅ 配置持久化存储（RDB + AOF）
- ✅ 配置远程连接支持
- ✅ 自动配置防火墙规则
- ✅ 创建专用用户和目录结构
- ✅ 安装后验证和信息展示
- ✅ 彩色日志输出，便于查看执行状态

## 系统要求

### 支持的操作系统

- CentOS 7/8
- RHEL 7/8
- Ubuntu 18.04/20.04/22.04
- Debian 9/10/11

### 硬件要求

- 内存：至少512MB RAM
- 磁盘：至少1GB可用空间
- 网络：需要互联网连接下载软件包

### 权限要求

- 必须使用root用户执行
- 需要网络连接以下载Redis软件包

## 使用方法

### 1. 下载脚本

```bash
# 如果脚本已在服务器上
cd /path/to/scripts

# 或者从远程下载
wget https://your-server.com/install_redis.sh
```

### 2. 添加执行权限

```bash
chmod +x install_redis.sh
```

### 3. 执行安装

```bash
# 使用root用户执行
sudo ./install_redis.sh

# 或者切换到root用户后执行
su -
./install_redis.sh
```

## 默认配置

### Redis配置

- **Redis版本**: 7.x
- **端口**: 6379
- **密码**: 123456
- **数据库数量**: 16
- **绑定地址**: 0.0.0.0（允许远程连接）

### 目录结构

- **配置目录**: /etc/redis
- **数据目录**: /var/lib/redis
- **日志目录**: /var/log/redis
- **运行目录**: /var/run/redis

### 持久化配置

- **RDB持久化**: 启用（900秒内1次变更、300秒内10次变更、60秒内10000次变更）
- **AOF持久化**: 启用（每秒同步）
- **数据文件**: dump.rdb, appendonly.aof

## 安装内容

### CentOS/RHEL系统

- 启用EPEL仓库
- 安装 `redis` 软件包
- 配置文件：`/etc/redis.conf`
- 服务名：`redis`
- 创建systemd服务文件

### Ubuntu/Debian系统

- 安装 `redis-server` 软件包
- 配置文件：`/etc/redis/redis.conf`
- 服务名：`redis-server`
- 使用系统默认服务配置

## 验证安装

安装完成后，脚本会自动执行验证，您也可以手动验证：

```bash
# 检查Redis服务状态
systemctl status redis        # CentOS
systemctl status redis-server # Ubuntu

# 查看Redis版本
redis-server --version

# 测试Redis连接
redis-cli -a 123456 ping

# 查看Redis信息
redis-cli -a 123456 info server

# 测试基本操作
redis-cli -a 123456 set test "Hello Redis"
redis-cli -a 123456 get test
```

## 连接方式

### 本地连接

```bash
# 使用密码连接
redis-cli -a 123456

# 或者连接后认证
redis-cli
127.0.0.1:6379> AUTH 123456
```

### 远程连接

```bash
# 远程连接
redis-cli -h <服务器IP> -p 6379 -a 123456
```

### 应用程序连接

```python
# Python示例
import redis

r = redis.Redis(
    host='服务器IP',
    port=6379,
    password='123456',
    decode_responses=True
)

# 测试连接
print(r.ping())
```

```java
// Java示例
Jedis jedis = new Jedis("服务器IP", 6379);
jedis.auth("123456");
System.out.println(jedis.ping());
```

## 预期输出示例

```
[INFO] 开始安装Redis缓存服务...
[INFO] 检测到Ubuntu/Debian系统
[STEP] 更新系统包管理器...
[INFO] 系统更新完成
[STEP] 检查Redis服务状态...
[STEP] 安装Redis缓存服务...
[INFO] Redis安装完成
[STEP] 配置Redis服务...
[INFO] Redis配置完成
[STEP] 配置防火墙规则...
[INFO] 防火墙规则已添加 (端口: 6379)
[STEP] 验证Redis安装结果...
==================== Redis安装验证 ====================
...
[INFO] Redis安装验证完成
==================== Redis安装完成 ====================
[INFO] Redis缓存服务安装完成！
```

## 常见问题

### Q1: 脚本执行失败，提示权限不足

**A:** 确保使用root用户执行脚本：

```bash
sudo ./install_redis.sh
```

### Q2: Redis服务启动失败

**A:** 检查配置文件和日志：

```bash
# 查看Redis日志
tail -f /var/log/redis/redis-server.log

# 检查配置文件语法
redis-server /etc/redis/redis.conf --test-config
```

### Q3: 远程连接被拒绝

**A:** 检查防火墙和绑定地址：

```bash
# 检查端口是否开放
netstat -tlnp | grep 6379

# 检查绑定地址
grep "bind" /etc/redis/redis.conf
```

### Q4: 内存不足警告

**A:** 配置系统内存过量使用：

```bash
echo 'vm.overcommit_memory = 1' >> /etc/sysctl.conf
sysctl vm.overcommit_memory=1
```

### Q5: 持久化文件权限问题

**A:** 检查数据目录权限：

```bash
chown -R redis:redis /var/lib/redis
chmod 755 /var/lib/redis
```

## 性能优化

### 内存优化

```bash
# 在redis.conf中添加或修改
maxmemory 2gb
maxmemory-policy allkeys-lru

# 禁用透明大页
echo never > /sys/kernel/mm/transparent_hugepage/enabled
echo never > /sys/kernel/mm/transparent_hugepage/defrag
```

### 网络优化

```bash
# 增加TCP连接队列
echo 'net.core.somaxconn = 65535' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_max_syn_backlog = 65535' >> /etc/sysctl.conf
sysctl -p
```

### 持久化优化

```bash
# 在redis.conf中调整
# RDB优化
save 900 1
save 300 10
save 60 10000
rdbcompression yes

# AOF优化
appendfsync everysec
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb
```

## 安全配置

### 生产环境安全建议

1. **修改默认密码**：

```bash
# 编辑配置文件
vim /etc/redis/redis.conf
# 修改密码
requirepass 新的强密码

# 重启服务
systemctl restart redis
```

2. **限制访问IP**：

```bash
# 只允许特定IP访问
bind 127.0.0.1 192.168.1.100
```

3. **禁用危险命令**：

```bash
# 在redis.conf中添加
rename-command FLUSHDB ""
rename-command FLUSHALL ""
rename-command KEYS ""
rename-command CONFIG "CONFIG_9a8b7c6d"
```

4. **启用SSL/TLS**（Redis 6.0+）：

```bash
# 生成证书后在配置文件中添加
port 0
tls-port 6380
tls-cert-file /path/to/redis.crt
tls-key-file /path/to/redis.key
tls-ca-cert-file /path/to/ca.crt
```

## 监控和维护

### 监控命令

```bash
# 查看Redis信息
redis-cli -a 123456 info

# 查看内存使用
redis-cli -a 123456 info memory

# 查看连接数
redis-cli -a 123456 info clients

# 查看慢查询
redis-cli -a 123456 slowlog get 10

# 实时监控命令
redis-cli -a 123456 monitor
```

### 备份和恢复

```bash
# 手动触发RDB备份
redis-cli -a 123456 BGSAVE

# 备份数据文件
cp /var/lib/redis/dump.rdb /backup/redis-backup-$(date +%Y%m%d).rdb

# 恢复数据（停止Redis后）
systemctl stop redis
cp /backup/redis-backup-20231201.rdb /var/lib/redis/dump.rdb
chown redis:redis /var/lib/redis/dump.rdb
systemctl start redis
```

## 服务管理

### 基本服务命令

```bash
# 启动Redis
systemctl start redis        # CentOS
systemctl start redis-server # Ubuntu

# 停止Redis
systemctl stop redis         # CentOS
systemctl stop redis-server  # Ubuntu

# 重启Redis
systemctl restart redis      # CentOS
systemctl restart redis-server # Ubuntu

# 查看状态
systemctl status redis       # CentOS
systemctl status redis-server # Ubuntu

# 开机自启
systemctl enable redis       # CentOS
systemctl enable redis-server # Ubuntu
```

### 配置重载

```bash
# 重新加载配置（部分配置支持）
redis-cli -a 123456 CONFIG REWRITE

# 查看当前配置
redis-cli -a 123456 CONFIG GET '*'
```

## 卸载方法

如需卸载Redis：

### CentOS/RHEL

```bash
# 停止服务
systemctl stop redis
systemctl disable redis

# 卸载软件包
yum remove redis

# 删除数据和配置（注意备份）
rm -rf /var/lib/redis
rm -rf /var/log/redis
rm -rf /etc/redis
rm -f /etc/systemd/system/redis.service

# 删除用户
userdel redis
```

### Ubuntu/Debian

```bash
# 停止服务
systemctl stop redis-server
systemctl disable redis-server

# 卸载软件包
apt remove --purge redis-server
apt autoremove

# 删除数据和配置（注意备份）
rm -rf /var/lib/redis
rm -rf /var/log/redis
rm -rf /etc/redis
```

## 故障排除

### 常见错误及解决方案

1. **内存不足**：

```bash
# 检查内存使用
redis-cli -a 123456 info memory
# 设置内存限制
redis-cli -a 123456 CONFIG SET maxmemory 1gb
```

2. **连接数过多**：

```bash
# 查看当前连接
redis-cli -a 123456 info clients
# 增加最大连接数
redis-cli -a 123456 CONFIG SET maxclients 20000
```

3. **持久化失败**：

```bash
# 检查磁盘空间
df -h /var/lib/redis
# 检查权限
ls -la /var/lib/redis
```

## 技术支持

如遇到问题，请检查：

1. 系统版本是否支持
2. 网络连接是否正常
3. 磁盘空间是否充足（至少1GB）
4. 内存是否充足（至少512MB）
5. 是否使用root权限执行
6. 防火墙配置是否正确

## 更新日志

- v1.0 - 初始版本，支持Redis 7.x安装
- 支持CentOS/RHEL和Ubuntu/Debian系统
- 自动密码和持久化配置
- 远程连接支持
- 防火墙自动配置
- 完整的监控和维护功能
