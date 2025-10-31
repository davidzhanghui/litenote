# MySQL数据库安装脚本说明

## 脚本概述

`install_mysql.sh` 是一个自动化安装MySQL 8.0数据库的Shell脚本，支持在CentOS/RHEL和Ubuntu/Debian系统上完整安装和配置MySQL服务。脚本会安装MySQL服务器，配置root用户密码，启用远程连接，并自动配置防火墙规则。

## 功能特性

- ✅ 自动检测操作系统类型（CentOS/RHEL 和 Ubuntu/Debian）
- ✅ 智能检查MySQL服务状态，避免重复安装
- ✅ 安装MySQL 8.0社区版
- ✅ 自动配置root密码（默认：123456）
- ✅ 配置root用户远程连接支持
- ✅ 自动配置防火墙规则（开放3306端口）
- ✅ 安装后验证和信息展示
- ✅ 彩色日志输出，便于查看执行状态
- ✅ 错误处理机制（set -e），遇到错误立即退出
- ✅ 支持远程执行，无需登录服务器

## 系统要求

### 支持的操作系统

- CentOS 7/8
- RHEL 7/8
- Ubuntu 18.04/20.04/22.04
- Debian 9/10/11

### 硬件要求

- 内存：至少1GB RAM
- 磁盘：至少2GB可用空间
- 网络：需要互联网连接下载软件包

### 权限要求

- 必须使用root用户执行
- 需要网络连接以下载MySQL软件包

## 使用方法

### 1. 下载脚本

```bash
# 如果脚本已在服务器上
cd /path/to/scripts

# 或者从远程下载
wget https://your-server.com/install_mysql.sh
```

### 2. 添加执行权限

```bash
chmod +x install_mysql.sh
```

### 3. 执行安装

#### 本地执行

```bash
# 使用root用户执行
sudo ./install_mysql.sh

# 或者切换到root用户后执行
su -
./install_mysql.sh
```

#### 远程执行

```bash
# 从本地电脑直接在远程服务器执行
ssh root@<服务器IP> 'bash -s' < install_mysql.sh
```

## 默认配置

### 数据库配置

- **MySQL版本**: 8.0 社区版
- **端口**: 3306
- **Root密码**: 123456
- **字符集**: utf8mb4（默认）

### 安全配置

- 启用远程连接（bind-address = 0.0.0.0）
- 创建本地和远程用户权限
- 自动配置防火墙规则

## 安装内容

### CentOS/RHEL系统

- 添加MySQL官方仓库
- 安装 `mysql-community-server`
- 配置文件：`/etc/my.cnf`
- 日志文件：`/var/log/mysqld.log`
- 服务名：`mysqld`

### Ubuntu/Debian系统

- 安装 `mysql-server`
- 配置文件：`/etc/mysql/mysql.conf.d/mysqld.cnf`
- 日志文件：`/var/log/mysql/error.log`
- 服务名：`mysql`

## 验证安装

安装完成后，脚本会自动执行验证，您也可以手动验证：

```bash
# 检查MySQL服务状态
systemctl status mysqld  # CentOS
systemctl status mysql   # Ubuntu

# 查看MySQL版本
mysql --version

# 测试数据库连接
mysql -uroot -p123456 -e "SELECT VERSION();"

# 查看数据库列表
mysql -uroot -p123456 -e "SHOW DATABASES;"
```

## 连接方式

### 本地连接

```bash
# 使用root用户
mysql -uroot -p123456
```

### 远程连接

```bash
# 使用root用户远程连接
mysql -uroot -p123456 -h <服务器IP>
```

### 应用程序连接字符串

```
# JDBC连接字符串（需要先创建数据库）
jdbc:mysql://<服务器IP>:3306/<数据库名>?useSSL=false&serverTimezone=UTC&characterEncoding=utf8

# 用户名: root
# 密码: 123456
```

## 预期输出示例

```
[INFO] 开始安装MySQL数据库...
[INFO] 检测到Ubuntu/Debian系统
[STEP] 更新系统包管理器...
[INFO] 系统更新完成
[STEP] 检查MySQL服务状态...
[STEP] 安装MySQL数据库...
[INFO] MySQL安装完成
[STEP] 配置MySQL数据库...
[INFO] MySQL配置完成
[STEP] 配置防火墙规则...
[INFO] 防火墙规则已添加 (端口: 3306)
[STEP] 验证MySQL安装结果...
==================== MySQL安装验证 ====================
...
[INFO] MySQL安装验证完成
==================== MySQL安装完成 ====================
[INFO] MySQL数据库安装完成！
```

## 常见问题

### Q1: 脚本执行失败，提示权限不足

**A:** 确保使用root用户执行脚本：

```bash
sudo ./install_mysql.sh
```

### Q2: MySQL服务启动失败

**A:** 检查系统资源和日志：

```bash
# 查看系统内存
free -h

# 查看MySQL错误日志
tail -f /var/log/mysqld.log  # CentOS
tail -f /var/log/mysql/error.log  # Ubuntu
```

### Q3: 远程连接被拒绝

**A:** 检查防火墙和网络配置：

```bash
# 检查端口是否开放
netstat -tlnp | grep 3306

# 检查防火墙状态
systemctl status firewalld  # CentOS
ufw status  # Ubuntu
```

### Q4: 密码策略错误

**A:** MySQL 8.0有严格的密码策略，确保密码包含大小写字母、数字和特殊字符。

### Q5: 字符集问题

**A:** 脚本已配置utf8mb4字符集，支持完整的Unicode字符。

## 安全建议

### 生产环境配置

1. **修改默认密码**：

```sql
ALTER USER 'root'@'localhost' IDENTIFIED BY '新的强密码';
ALTER USER 'root'@'%' IDENTIFIED BY '新的强密码';
```

2. **创建应用用户**：

```sql
-- 创建专用的应用用户
CREATE DATABASE your_app_db;
CREATE USER 'app_user'@'%' IDENTIFIED BY '强密码';
GRANT ALL PRIVILEGES ON your_app_db.* TO 'app_user'@'%';
FLUSH PRIVILEGES;
```

3. **限制远程访问**：

```sql
-- 只允许特定IP访问
CREATE USER 'app_user'@'192.168.1.100' IDENTIFIED BY '密码';
GRANT ALL PRIVILEGES ON your_app_db.* TO 'app_user'@'192.168.1.100';
DROP USER 'app_user'@'%';
```

3. **启用SSL连接**：

```bash
# 在my.cnf中添加
[mysqld]
ssl-ca=/path/to/ca.pem
ssl-cert=/path/to/server-cert.pem
ssl-key=/path/to/server-key.pem
```

## 维护命令

### 服务管理

```bash
# 启动MySQL
systemctl start mysqld   # CentOS
systemctl start mysql    # Ubuntu

# 停止MySQL
systemctl stop mysqld    # CentOS
systemctl stop mysql     # Ubuntu

# 重启MySQL
systemctl restart mysqld # CentOS
systemctl restart mysql  # Ubuntu

# 查看状态
systemctl status mysqld  # CentOS
systemctl status mysql   # Ubuntu
```

### 备份和恢复

```bash
# 备份数据库
mysqldump -uroot -p <数据库名> > database_backup.sql

# 恢复数据库
mysql -uroot -p <数据库名> < database_backup.sql
```

## 卸载方法

如需卸载MySQL：

### CentOS/RHEL

```bash
# 停止服务
systemctl stop mysqld

# 卸载软件包
yum remove mysql-community-server mysql80-community-release

# 删除数据目录（注意备份）
rm -rf /var/lib/mysql
rm -rf /etc/my.cnf
```

### Ubuntu/Debian

```bash
# 停止服务
systemctl stop mysql

# 卸载软件包
apt remove --purge mysql-server mysql-client mysql-common
apt autoremove

# 删除数据目录（注意备份）
rm -rf /var/lib/mysql
rm -rf /etc/mysql
```

## 性能优化

### 基本优化配置

在配置文件中添加：

```ini
[mysqld]
# 缓冲池大小（建议为系统内存的70-80%）
innodb_buffer_pool_size = 1G

# 连接数限制
max_connections = 200

# 查询缓存
query_cache_size = 64M
query_cache_type = 1

# 慢查询日志
slow_query_log = 1
slow_query_log_file = /var/log/mysql/slow.log
long_query_time = 2
```

## 技术支持

如遇到问题，请检查：

1. 系统版本是否支持
2. 网络连接是否正常
3. 磁盘空间是否充足（至少2GB）
4. 内存是否充足（至少1GB）
5. 是否使用root权限执行

## 更新日志

- v1.0 - 初始版本，支持MySQL 8.0安装
- 支持CentOS/RHEL和Ubuntu/Debian系统
- 自动数据库和用户配置
- 远程连接支持
- 防火墙自动配置
