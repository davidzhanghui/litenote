# MinIO 对象存储服务卸载脚本

## 概述

`uninstall_minio.sh` 是一个全面的MinIO对象存储服务卸载脚本，用于完全移除MinIO及其相关组件。该脚本支持CentOS/RHEL和Ubuntu/Debian系统，提供安全、彻底的卸载过程。

## 功能特性

### 🔧 完整卸载
- 停止并移除MinIO服务
- 删除MinIO可执行文件（服务器和客户端）
- 移除systemd服务配置
- 清理所有配置文件和目录
- 删除用户账户和组
- 清理防火墙规则

### 🛡️ 安全保护
- 用户确认机制，防止误操作
- 数据目录保护选项
- 详细的操作日志记录
- 完整的卸载验证

### 📊 智能检测
- 自动检测操作系统类型
- 识别MinIO安装状态
- 验证卸载完整性
- 提供详细的操作反馈

## 系统要求

- **操作系统**: CentOS/RHEL 7+, Ubuntu 18.04+, Debian 9+
- **权限**: 需要root权限
- **依赖**: bash, systemctl

## 使用方法

### 本地执行

```bash
# 添加执行权限
chmod +x uninstall_minio.sh

# 执行卸载脚本
sudo ./uninstall_minio.sh
```

### 远程执行

```bash
# 下载并执行
wget https://your-domain.com/scripts/uninstall_minio.sh
chmod +x uninstall_minio.sh
sudo ./uninstall_minio.sh
```

## 卸载流程

### 1. 系统检查
- 检测操作系统类型和版本
- 验证root权限
- 显示卸载警告信息

### 2. 用户确认
- 显示将要删除的组件列表
- 要求用户明确确认卸载操作
- 提供取消选项

### 3. 服务停止
- 停止MinIO服务进程
- 禁用服务自启动
- 清理运行中的进程

### 4. 文件清理
- 删除可执行文件
- 移除配置目录
- 清理日志文件
- 处理数据目录（可选保留）

### 5. 系统清理
- 删除用户账户和组
- 清理防火墙规则
- 移除systemd服务
- 清理临时文件

### 6. 验证确认
- 检查卸载完整性
- 报告剩余组件
- 显示卸载总结

## 安全注意事项

### ⚠️ 重要警告

1. **数据备份**: 卸载前请确保已备份重要数据
2. **不可逆操作**: 卸载过程不可逆转
3. **服务依赖**: 确认没有其他服务依赖MinIO
4. **网络影响**: 卸载会影响依赖MinIO的应用

### 🔒 安全措施

- 脚本要求明确的用户确认
- 数据目录提供保留选项
- 详细的操作日志记录
- 完整的卸载验证机制

## 配置说明

脚本中的默认配置（与安装脚本保持一致）：

```bash
MINIO_USER="minio"              # MinIO用户名
MINIO_GROUP="minio"             # MinIO用户组
MINIO_HOME="/opt/minio"         # 安装目录
MINIO_DATA_DIR="/data/minio"    # 数据目录
MINIO_CONFIG_DIR="/etc/minio"   # 配置目录
MINIO_PORT="9000"               # API端口
MINIO_CONSOLE_PORT="9001"       # 控制台端口
```

## 故障排除

### 常见问题

**Q: 卸载后仍能找到MinIO进程**
A: 检查是否有其他MinIO实例运行，手动终止相关进程

**Q: 配置文件未完全清理**
A: 手动检查并删除残留的配置文件

**Q: 用户账户删除失败**
A: 确保没有进程以该用户身份运行，然后手动删除

**Q: 防火墙规则未清理**
A: 手动检查并清理相关的防火墙规则

### 手动清理

如果自动卸载遇到问题，可以手动执行以下清理步骤：

```bash
# 停止服务
sudo systemctl stop minio
sudo systemctl disable minio

# 删除文件
sudo rm -f /usr/local/bin/minio
sudo rm -f /usr/local/bin/mc
sudo rm -f /etc/systemd/system/minio.service
sudo rm -rf /opt/minio
sudo rm -rf /etc/minio

# 删除用户
sudo userdel minio
sudo groupdel minio

# 清理防火墙（CentOS/RHEL）
sudo firewall-cmd --permanent --remove-port=9000/tcp
sudo firewall-cmd --permanent --remove-port=9001/tcp
sudo firewall-cmd --reload

# 清理防火墙（Ubuntu）
sudo ufw delete allow 9000/tcp
sudo ufw delete allow 9001/tcp
```

## 日志文件

卸载过程会生成详细的日志文件：

- **位置**: `./logs/uninstall_minio_YYYYMMDD_HHMMSS.log`
- **内容**: 完整的卸载过程记录
- **用途**: 故障排除和审计

## 重新安装

如果需要重新安装MinIO：

1. 确保卸载完全完成
2. 重启系统（推荐）
3. 使用对应的安装脚本重新安装
4. 恢复备份的配置和数据

## 脚本输出示例

```
╔══════════════════════════════════════════════════════════════╗
║                    MinIO 对象存储服务卸载                    ║
║                                                              ║
║  此脚本将完全卸载MinIO及其相关组件                          ║
║  包括服务、配置文件、数据目录和用户账户                      ║
║  支持系统: CentOS/RHEL 7+, Ubuntu 18.04+, Debian 9+        ║
║  作者: DevOps Team                                           ║
║  版本: v1.0.0                                               ║
╚══════════════════════════════════════════════════════════════╝

[STEP] 检测操作系统...
[INFO] 操作系统: ubuntu 20.04
[STEP] 检查权限...
[SUCCESS] 权限检查通过
[STEP] 确认卸载操作...
警告: 此操作将完全卸载MinIO及其所有数据！
...
[SUCCESS] MinIO卸载成功！
```

## 相关文档

- [MinIO官方文档](https://docs.min.io/)
- [MinIO安装脚本](install_minio.sh)
- [系统管理最佳实践](https://docs.min.io/docs/minio-server-configuration-guide.html)

## 技术支持

如果在使用过程中遇到问题：

1. 检查日志文件获取详细信息
2. 参考故障排除部分
3. 联系系统管理员
4. 查阅MinIO官方文档

---

**注意**: 此脚本仅用于完全卸载MinIO。如果只需要重启或重新配置服务，请使用相应的管理命令而不是卸载脚本。