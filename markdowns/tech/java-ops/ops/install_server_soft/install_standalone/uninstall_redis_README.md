# Redis卸载脚本使用说明

## 概述

`uninstall_redis.sh` 是一个用于完全卸载Redis缓存服务的自动化脚本。该脚本支持CentOS/RHEL和Ubuntu/Debian系统，能够安全、彻底地移除Redis及其所有相关组件。

## 功能特性

### 🔧 核心功能
- **完全卸载**：彻底移除Redis软件包和所有相关组件
- **数据备份**：卸载前可选择备份现有数据
- **安全确认**：多重确认机制防止误操作
- **智能检测**：自动检测操作系统类型
- **残留清理**：清理所有可能的残留文件和配置
- **验证机制**：卸载后自动验证清理结果

### 🗂️ 清理范围
- Redis服务进程
- Redis软件包
- 配置文件和目录
- 数据文件和持久化文件
- 日志文件
- Redis用户账户
- 防火墙规则
- systemd服务文件
- 运行时文件

## 系统要求

### 支持的操作系统
- **CentOS/RHEL** 7.x, 8.x, 9.x
- **Ubuntu** 18.04, 20.04, 22.04, 24.04
- **Debian** 9, 10, 11, 12

### 权限要求
- 必须使用 **root** 用户或具有 **sudo** 权限的用户执行

## 使用方法

### 1. 下载脚本
```bash
# 如果脚本在本地
cd /path/to/scripts/other/

# 或者从远程下载
wget https://your-domain.com/scripts/uninstall_redis.sh
```

### 2. 设置执行权限
```bash
chmod +x uninstall_redis.sh
```

### 3. 执行卸载
```bash
# 使用root用户执行
sudo ./uninstall_redis.sh

# 或者切换到root用户
su -
./uninstall_redis.sh
```

## 执行流程

### 第一步：系统检测
脚本会自动检测当前操作系统类型，确保兼容性。

### 第二步：安全确认
```
==================== 警告 ====================
即将完全卸载Redis缓存服务！
此操作将：
  1. 停止Redis服务
  2. 删除Redis软件包
  3. 删除所有配置文件
  4. 删除所有数据文件（包括持久化数据）
  5. 删除Redis用户
  6. 删除防火墙规则
  7. 清理所有相关目录

注意：此操作不可逆，所有Redis数据将被永久删除！
==============================================

确认要继续卸载Redis吗？(输入 'YES' 确认):
```

**重要**：必须输入 `YES`（大写）才能继续，任何其他输入都会取消操作。

### 第三步：数据备份（可选）
如果检测到现有数据，脚本会询问是否备份：
```
检测到Redis数据文件，是否备份？(y/N):
```

选择 `y` 会将数据备份到 `/tmp/redis_backup_YYYYMMDD_HHMMSS/` 目录。

### 第四步：执行卸载
脚本会按以下顺序执行卸载操作：
1. 停止Redis服务
2. 删除systemd服务文件
3. 卸载Redis软件包
4. 删除配置文件和目录
5. 删除数据文件和目录
6. 删除Redis用户
7. 删除防火墙规则
8. 清理残留文件

### 第五步：验证卸载
脚本会自动验证卸载结果，检查：
- Redis进程状态
- 服务文件状态
- 软件包状态
- 配置文件状态
- 数据目录状态
- 用户账户状态
- 端口占用状态

## 输出示例

### 成功卸载输出
```
[INFO] 开始卸载Redis缓存服务...
[INFO] 检测到Ubuntu/Debian系统
[STEP] 停止Redis服务...
[INFO] Redis服务已停止并禁用
[STEP] 删除systemd服务文件...
[STEP] 卸载Redis软件包...
[INFO] Redis软件包已卸载
[STEP] 删除配置文件和目录...
[INFO] 已删除Redis配置文件: /etc/redis/redis.conf
[STEP] 删除数据文件和目录...
[INFO] 已删除Redis数据目录: /var/lib/redis
[STEP] 删除Redis用户...
[INFO] 已删除Redis用户: redis
[STEP] 删除防火墙规则...
[INFO] 防火墙规则已删除 (端口: 6379)
[STEP] 清理残留文件...
[STEP] 验证Redis卸载结果...

==================== Redis卸载验证 ====================
[INFO] ✓ 没有发现Redis进程
[INFO] ✓ Redis服务已完全删除
[INFO] ✓ Redis软件包已卸载
[INFO] ✓ Redis配置文件已删除
[INFO] ✓ Redis数据目录已删除
[INFO] ✓ Redis用户已删除
[INFO] ✓ 端口6379已释放
====================================================

==================== Redis卸载完成 ====================
[INFO] Redis缓存服务已完全卸载！

已执行的操作：
  ✓ 停止并禁用Redis服务
  ✓ 卸载Redis软件包
  ✓ 删除所有配置文件
  ✓ 删除所有数据文件
  ✓ 删除Redis用户
  ✓ 删除防火墙规则
  ✓ 清理所有相关目录
  ✓ 清理残留文件
====================================================
```

## 重要注意事项

### ⚠️ 数据安全
- **不可逆操作**：卸载过程会永久删除所有Redis数据
- **备份重要**：卸载前请确保已备份重要数据
- **生产环境**：生产环境使用前请先在测试环境验证

### 🔒 安全考虑
- **权限检查**：脚本会检查root权限，非root用户无法执行
- **确认机制**：多重确认防止误操作
- **进程检查**：会检查并强制终止所有Redis进程

### 📁 文件清理
脚本会删除以下文件和目录：
```
/etc/redis/                    # 配置目录
/etc/redis.conf               # 配置文件（CentOS）
/var/lib/redis/               # 数据目录
/var/log/redis/               # 日志目录
/var/run/redis/               # 运行时目录
/etc/systemd/system/redis.service  # systemd服务文件
```

## 故障排除

### 常见问题

#### 1. 权限不足
```
[ERROR] 请使用root用户运行此脚本
```
**解决方案**：使用 `sudo` 或切换到root用户

#### 2. 进程无法停止
```
[WARN] 发现残留的Redis进程，正在强制终止...
```
**说明**：脚本会自动处理，强制终止残留进程

#### 3. 软件包未找到
```
[WARN] Redis软件包未安装
```
**说明**：正常情况，表示Redis未通过包管理器安装

#### 4. 防火墙规则删除失败
```
[WARN] 未找到Redis防火墙规则
```
**说明**：正常情况，表示防火墙中没有Redis相关规则

### 手动清理

如果脚本执行失败，可以手动执行以下清理步骤：

```bash
# 1. 停止服务
sudo systemctl stop redis redis-server
sudo systemctl disable redis redis-server

# 2. 卸载软件包
# CentOS/RHEL
sudo yum remove -y redis
# Ubuntu/Debian
sudo apt remove --purge -y redis-server redis-tools

# 3. 删除文件和目录
sudo rm -rf /etc/redis
sudo rm -f /etc/redis.conf
sudo rm -rf /var/lib/redis
sudo rm -rf /var/log/redis
sudo rm -rf /var/run/redis
sudo rm -f /etc/systemd/system/redis.service

# 4. 删除用户
sudo userdel redis

# 5. 重新加载systemd
sudo systemctl daemon-reload

# 6. 删除防火墙规则
# CentOS/RHEL
sudo firewall-cmd --permanent --remove-port=6379/tcp
sudo firewall-cmd --reload
# Ubuntu/Debian
sudo ufw delete allow 6379/tcp
```

## 相关脚本

- **安装脚本**：`install_redis.sh` - 用于安装Redis服务
- **安装说明**：`install_redis_README.md` - Redis安装脚本说明文档

## 技术支持

如果在使用过程中遇到问题，请：

1. 检查系统日志：`journalctl -u redis` 或 `journalctl -u redis-server`
2. 查看脚本执行日志
3. 确认操作系统版本和权限
4. 参考故障排除章节

## 版本信息

- **脚本版本**：1.0.0
- **支持Redis版本**：7.x
- **最后更新**：2024年
- **兼容性**：CentOS/RHEL 7+, Ubuntu 18.04+, Debian 9+

---

**警告**：此脚本会永久删除所有Redis数据，请在使用前确保已备份重要数据！