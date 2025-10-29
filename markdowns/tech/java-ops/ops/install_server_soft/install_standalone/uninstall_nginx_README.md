# Nginx Web服务器卸载脚本说明

## 脚本概述

`uninstall_nginx.sh` 是一个自动化卸载Nginx Web服务器的Shell脚本，支持在CentOS/RHEL和Ubuntu/Debian系统上完整卸载和清理Nginx服务及相关配置文件。

## ⚠️ 重要警告

**此脚本将完全卸载Nginx并删除所有配置文件和日志文件，网站文件将保留在 `/var/www/html` 目录中。执行前请确保已备份重要的Nginx配置。**

## 功能特性

- ✅ 自动检测操作系统类型（CentOS/Ubuntu）
- ✅ 安全停止Nginx服务并禁用自启动
- ✅ 完全卸载Nginx软件包
- ✅ 彻底删除所有Nginx配置文件和日志文件
- ✅ 移除防火墙规则
- ✅ 删除官方仓库配置
- ✅ 删除Nginx用户和用户组
- ✅ 卸载后验证
- ✅ 彩色日志输出，便于查看执行状态
- ✅ 执行前二次确认，防止误操作
- ✅ 保留网站文件，避免数据丢失

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
chmod +x uninstall_nginx.sh
```

### 3. 执行卸载
```bash
# 使用root用户执行
sudo ./uninstall_nginx.sh

# 或者切换到root用户后执行
su -
./uninstall_nginx.sh
```

### 4. 确认操作
执行脚本后，系统会提示确认操作：
```
警告: 此操作将完全卸载Nginx并删除所有配置文件，网站文件将保留!
确认继续卸载? (输入 'yes' 确认): 
```
输入 `yes` 继续卸载，输入其他内容或直接回车将取消操作。

## 卸载内容

### 服务管理
- 停止Nginx服务
- 禁用Nginx服务自启动

### 软件包卸载
**CentOS/RHEL系统:**
- `nginx`
- 删除Nginx官方仓库配置 (`/etc/yum.repos.d/nginx.repo`)
- 删除相关GPG密钥

**Ubuntu/Debian系统:**
- `nginx`
- `nginx-common`
- `nginx-core`
- 删除Nginx官方仓库配置 (`/etc/apt/sources.list.d/nginx.list`)
- 删除仓库优先级配置 (`/etc/apt/preferences.d/99nginx`)
- 删除相关GPG密钥

### 数据清理
- 删除配置目录: `/etc/nginx/`
- 删除日志目录: `/var/log/nginx/`
- 删除缓存目录: `/var/cache/nginx/`
- 删除PID文件: `/var/run/nginx.pid`
- 删除系统用户: `nginx`
- 删除用户组: `nginx`
- **保留网站目录**: `/var/www/html/` (需要手动删除)

### 防火墙配置
- 移除HTTP服务规则
- 移除HTTPS服务规则
- 移除80端口的防火墙规则
- 移除443端口的防火墙规则

## 预期输出示例

```
[INFO] 开始卸载Nginx Web服务器...
[INFO] 检测到Ubuntu/Debian系统
警告: 此操作将完全卸载Nginx并删除所有配置文件，网站文件将保留!
确认继续卸载? (输入 'yes' 确认): yes
[STEP] 停止Nginx服务...
[INFO] Nginx服务已停止并禁用自启动
[STEP] 卸载Nginx Web服务器...
[INFO] Nginx官方仓库配置已删除
[INFO] Nginx仓库优先级配置已删除
[INFO] Nginx卸载完成
[STEP] 清理Nginx数据和配置文件...
[INFO] Nginx配置目录已删除: /etc/nginx
[INFO] Nginx日志目录已删除: /var/log/nginx
[INFO] Nginx缓存目录已删除: /var/cache/nginx
[WARN] 网站根目录保留: /var/www/html (如需删除请手动执行: rm -rf /var/www/html)
[INFO] Nginx用户已删除: nginx
[INFO] Nginx用户组已删除: nginx
[INFO] Nginx数据和配置文件清理完成
[STEP] 移除防火墙规则...
[INFO] 防火墙规则已移除 (ufw)
[STEP] 验证Nginx卸载结果...
==================== Nginx卸载验证 ====================
Nginx服务状态:
Nginx服务不存在或已停止

Nginx版本检查:
Nginx命令不存在

Nginx相关目录和文件检查:
配置目录: 不存在
日志目录: 不存在
缓存目录: 不存在
网站目录: /var/www/html

端口监听检查:
端口 80 未被监听
端口 443 未被监听

[INFO] Nginx卸载验证完成

==================== Nginx卸载完成 ====================
[INFO] Nginx Web服务器卸载完成！

卸载操作包括:
  1. 停止并禁用Nginx服务
  2. 卸载Nginx软件包
  3. 删除Nginx配置目录: /etc/nginx
  4. 删除Nginx日志目录: /var/log/nginx
  5. 删除Nginx缓存目录: /var/cache/nginx
  6. 删除Nginx用户和用户组
  7. 移除防火墙规则 (端口: 80, 443)
  8. 删除官方仓库配置

保留的内容:
  - 网站根目录: /var/www/html (需要手动删除)

注意事项:
  1. 所有Nginx配置文件已删除
  2. 所有Nginx日志文件已删除
  3. 网站文件已保留，如需删除请手动执行: rm -rf /var/www/html
  4. 如需重新安装，请运行安装脚本

重新安装命令:
  ./install_nginx.sh

=================================================
[INFO] Nginx卸载脚本执行完成！
```

## 故障排除

### 常见问题

1. **权限不足**
   ```
   [ERROR] 请使用root用户运行此脚本
   ```
   **解决方案**: 使用 `sudo` 或切换到root用户执行脚本

2. **Nginx服务无法停止**
   ```
   [WARN] Nginx服务未运行
   ```
   **说明**: 这是正常情况，表示Nginx服务已经停止或未安装

3. **防火墙配置失败**
   ```
   [WARN] firewalld未运行，跳过防火墙配置
   ```
   **说明**: 系统未启用防火墙服务，这是正常情况

4. **某些文件或目录不存在**
   ```
   配置目录: 不存在
   ```
   **说明**: 这表示相关组件已经被删除或从未安装，这是正常情况

### 手动清理

如果脚本执行过程中出现问题，可以手动执行以下清理操作：

```bash
# 停止服务
systemctl stop nginx
systemctl disable nginx

# 卸载软件包 (CentOS)
yum remove -y nginx
rm -f /etc/yum.repos.d/nginx.repo

# 卸载软件包 (Ubuntu)
apt remove -y --purge nginx nginx-common nginx-core
rm -f /etc/apt/sources.list.d/nginx.list
rm -f /etc/apt/preferences.d/99nginx
apt update

# 删除文件和目录
rm -rf /etc/nginx
rm -rf /var/log/nginx
rm -rf /var/cache/nginx
rm -f /var/run/nginx.pid

# 删除用户和组
userdel nginx
groupdel nginx

# 移除防火墙规则 (firewalld)
firewall-cmd --permanent --remove-service=http
firewall-cmd --permanent --remove-service=https
firewall-cmd --reload

# 移除防火墙规则 (ufw)
ufw delete allow 80/tcp
ufw delete allow 443/tcp
ufw delete allow 'Nginx Full'
```

## 重新安装

如果需要重新安装Nginx，请执行安装脚本：

```bash
./install_nginx.sh
```

## 备份建议

在执行卸载脚本之前，建议备份以下重要文件：

```bash
# 备份Nginx配置
cp -r /etc/nginx /backup/nginx-config-$(date +%Y%m%d)

# 备份网站文件
cp -r /var/www/html /backup/website-$(date +%Y%m%d)

# 备份SSL证书
cp -r /etc/nginx/ssl /backup/nginx-ssl-$(date +%Y%m%d)
```

## 相关脚本

- `install_nginx.sh` - Nginx安装脚本
- `install_nginx_README.md` - Nginx安装脚本说明文档

## 技术支持

如果在使用过程中遇到问题，请检查：

1. 操作系统是否受支持
2. 是否使用root权限执行
3. 网络连接是否正常
4. 系统日志中的错误信息

## 版本信息

- 脚本版本: 1.0
- 支持的Nginx版本: 所有版本
- 最后更新: 2024年
- 兼容性: CentOS/RHEL 7+, Ubuntu/Debian 18.04+