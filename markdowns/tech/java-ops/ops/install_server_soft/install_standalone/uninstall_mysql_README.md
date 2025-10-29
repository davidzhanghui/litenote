# MySQL数据库卸载脚本说明

## 脚本概述

`uninstall_mysql.sh` 是一个自动化卸载MySQL 8.0数据库的Shell脚本，支持在CentOS/RHEL和Ubuntu/Debian系统上完整卸载和清理MySQL服务及相关数据。

## ⚠️ 重要警告

**此脚本将完全卸载MySQL并删除所有数据，包括数据库、配置文件和日志文件，且无法恢复。执行前请确保已备份重要数据。**

## 功能特性

- ✅ 自动检测操作系统类型（CentOS/Ubuntu）
- ✅ 安全停止MySQL服务
- ✅ 完全卸载MySQL软件包
- ✅ 彻底删除所有MySQL数据和配置文件
- ✅ 移除防火墙规则
- ✅ 卸载后验证
- ✅ 彩色日志输出，便于查看执行状态
- ✅ 执行前二次确认，防止误操作

## 系统要求

### 支持的操作系统
- CentOS 7/8
- RHEL 7/8
- Ubuntu 18.04/20.04/22.04
- Debian 9/10/11

### 权限要求
- 必须使用root用户执行

## 使用方法

### 1. 下载脚本
```bash
# 如果脚本已在服务器上
cd /path/to/scripts
```

### 2. 添加执行权限
```bash
chmod +x uninstall_mysql.sh
```

### 3. 执行卸载
```bash
# 使用root用户执行
sudo ./uninstall_mysql.sh

# 或者切换到root用户后执行
su -
./uninstall_mysql.sh
```

### 4. 确认操作
执行脚本后，系统会提示确认操作：
```
警告: 此操作将完全卸载MySQL并删除所有数据，无法恢复!
确认继续卸载? (输入 'yes' 确认): 
```
输入 `yes` 继续卸载，输入其他内容或直接回车将取消操作。

## 卸载内容

### 服务管理
- 停止MySQL服务
- 禁用MySQL服务自启动

### 软件包卸载
**CentOS/RHEL系统:**
- `mysql-community-server`
- `mysql-community-client`
- `mysql-community-common`
- `mysql-community-libs`
- `mysql80-community-release` (仓库配置)

**Ubuntu/Debian系统:**
- `mysql-server`
- `mysql-client`
- `mysql-common`
- `mysql-community-server`
- `mysql-community-client`

### 数据清理
- 删除数据目录: `/var/lib/mysql/`
- 删除配置文件: `/etc/my.cnf` (CentOS) 或 `/etc/mysql/` (Ubuntu)
- 删除日志文件: `/var/log/mysqld.log` (CentOS) 或 `/var/log/mysql/` (Ubuntu)
- 删除系统用户: `mysql`

### 防火墙配置
- 移除3306端口的防火墙规则

## 预期输出示例

```
[INFO] 开始卸载MySQL数据库...
[INFO] 检测到Ubuntu/Debian系统
[STEP] 停止MySQL服务...
[INFO] MySQL服务已停止
[STEP] 卸载MySQL数据库...
[INFO] MySQL卸载完成
[STEP] 清理MySQL数据和配置文件...
[INFO] MySQL数据和配置文件清理完成
[STEP] 配置防火墙规则...
[INFO] 防火墙规则已移除 (端口: 3306)
[STEP] 验证MySQL卸载结果...
==================== MySQL卸载验证 ====================
...
[INFO] MySQL卸载验证完成
==================== MySQL卸载完成 ====================
[INFO] MySQL数据库卸载完成！
```

## 验证卸载

卸载完成后，脚本会自动执行验证，您也可以手动验证：

```bash
# 检查MySQL服务状态
systemctl status mysqld  # CentOS
systemctl status mysql   # Ubuntu

# 查看MySQL版本（应提示命令未找到）
mysql --version

# 检查数据目录是否已删除
ls -la /var/lib/mysql/

# 检查配置文件是否已删除
ls -la /etc/my.cnf      # CentOS
ls -la /etc/mysql/      # Ubuntu
```

## 常见问题

### Q1: 脚本执行失败，提示权限不足
**A:** 确保使用root用户执行脚本：
```bash
sudo ./uninstall_mysql.sh
```

### Q2: 想要保留数据，只卸载软件包
**A:** 当前脚本设计为完全卸载，包括数据清理。如需保留数据，请手动卸载：

**CentOS/RHEL:**
```bash
systemctl stop mysqld
yum remove mysql-community-server
```

**Ubuntu/Debian:**
```bash
systemctl stop mysql
apt remove mysql-server
```

### Q3: 卸载后仍能连接MySQL
**A:** 可能是使用了其他MySQL发行版或Docker容器，请检查：
```bash
# 检查进程
ps aux | grep mysql

# 检查Docker容器
docker ps | grep mysql
```

## 重新安装

卸载完成后，如需重新安装MySQL，可以使用安装脚本：
```bash
./install_mysql.sh
```

## 技术支持

如遇到问题，请检查：
1. 系统版本是否支持
2. 是否使用root权限执行
3. 是否有其他MySQL相关进程在运行