# XXL-JOB 卸载脚本说明文档

## 概述

本脚本用于完全卸载 XXL-JOB 分布式任务调度平台及其相关组件。支持 CentOS/RHEL 和 Ubuntu/Debian 系统，提供安全的卸载流程和可选的数据备份功能。

### 卸载内容

- XXL-JOB 应用程序和配置文件
- systemd 服务配置
- 系统用户和用户组
- 数据库和数据库用户（可选）
- 防火墙规则
- 系统配置和环境变量
- 临时文件和日志

### 支持系统

- **CentOS/RHEL**: 7.x, 8.x, 9.x
- **Ubuntu**: 18.04, 20.04, 22.04 LTS
- **Debian**: 9, 10, 11, 12

## 功能特性

### 安全卸载

- **交互式确认**: 多重确认机制防止误操作
- **备份选项**: 可选择备份配置文件和数据库
- **渐进式卸载**: 按步骤执行，出错时可中断
- **验证机制**: 卸载后自动验证清理结果

### 灵活配置

- **选择性删除**: 可选择是否删除数据库
- **备份管理**: 自动创建带时间戳的备份目录
- **恢复指导**: 提供详细的恢复说明文档
- **日志记录**: 详细的操作日志和状态反馈

### 系统兼容

- **多系统支持**: 自动检测操作系统类型
- **防火墙适配**: 支持 firewalld 和 ufw
- **服务管理**: 完整的 systemd 服务清理
- **权限处理**: 安全的用户和权限清理

## 系统要求

### 基本要求

- **操作系统**: CentOS 7+, Ubuntu 18.04+, Debian 9+
- **权限**: root 用户权限
- **磁盘空间**: 至少 100MB 可用空间（用于备份）
- **网络**: 无需网络连接

### 依赖检查

脚本会自动检查以下组件：
- systemctl（systemd 管理）
- MySQL 客户端（数据库操作）
- 防火墙管理工具（规则清理）

## 使用方法

### 基本使用

```bash
# 下载脚本
wget https://raw.githubusercontent.com/your-repo/scripts/install_server_soft/install_standalone/uninstall_xxljob.sh

# 添加执行权限
chmod +x uninstall_xxljob.sh

# 执行卸载
sudo ./uninstall_xxljob.sh
```

### 远程执行

```bash
# 通过 SSH 远程执行
ssh root@your-server 'bash -s' < ./uninstall_xxljob.sh

# 或者先上传再执行
scp uninstall_xxljob.sh root@your-server:/tmp/
ssh root@your-server "chmod +x /tmp/uninstall_xxljob.sh && /tmp/uninstall_xxljob.sh"
```

### 批量卸载

```bash
# 创建服务器列表
echo "server1.example.com" > servers.txt
echo "server2.example.com" >> servers.txt

# 批量执行卸载
while read server; do
    echo "正在卸载 $server..."
    ssh root@$server 'bash -s' < ./uninstall_xxljob.sh
done < servers.txt
```

## 卸载过程

### 交互式确认

脚本启动后会显示确认界面：

```
=================================================
          XXL-JOB卸载确认
=================================================

警告: 此操作将完全卸载XXL-JOB及其相关组件！

将要执行的操作:
  1. 停止XXL-JOB服务
  2. 删除systemd服务文件
  3. 删除XXL-JOB安装目录
  4. 删除XXL-JOB用户和用户组
  5. 删除XXL-JOB数据库和用户（可选）
  6. 清理防火墙规则
  7. 清理系统配置

是否继续卸载？(y/N):
```

### 选项配置

1. **数据库删除选择**
   ```
   是否同时删除XXL-JOB数据库？(y/N):
   ```
   - 选择 `y`: 删除数据库和数据库用户
   - 选择 `N`: 保留数据库（默认）

2. **备份创建选择**
   ```
   是否创建配置备份？(Y/n):
   ```
   - 选择 `Y`: 创建备份（默认）
   - 选择 `n`: 不创建备份

### 卸载步骤

1. **停止服务**: 停止 XXL-JOB 服务并禁用开机自启
2. **删除服务文件**: 移除 systemd 服务配置
3. **清理安装目录**: 删除 `/opt/xxl-job` 目录
4. **删除用户**: 移除 `xxljob` 用户和用户组
5. **数据库清理**: 删除数据库和数据库用户（可选）
6. **防火墙清理**: 移除相关端口规则
7. **系统配置清理**: 清理环境变量和配置文件
8. **验证卸载**: 检查卸载结果

## 备份和恢复

### 备份内容

脚本会自动备份以下内容到 `/tmp/xxljob_backup_YYYYMMDD_HHMMSS/` 目录：

- `application.properties`: XXL-JOB 应用配置文件
- `xxl-job.service`: systemd 服务配置文件
- `xxl_job_backup.sql`: 数据库备份文件（如果选择保留数据库）
- `README.txt`: 备份说明和恢复指导

### 恢复步骤

如需恢复 XXL-JOB，请按以下步骤操作：

1. **重新安装 XXL-JOB**
   ```bash
   ./install_xxljob.sh
   ```

2. **停止服务**
   ```bash
   systemctl stop xxl-job
   ```

3. **恢复配置文件**
   ```bash
   cp /tmp/xxljob_backup_*/application.properties /opt/xxl-job/
   ```

4. **恢复数据库**（如果有备份）
   ```bash
   mysql -uxxljob -p xxl_job < /tmp/xxljob_backup_*/xxl_job_backup.sql
   ```

5. **启动服务**
   ```bash
   systemctl start xxl-job
   systemctl enable xxl-job
   ```

## 故障排除

### 常见问题

#### 1. 权限不足

**问题**: `Permission denied` 错误

**解决方案**:
```bash
# 确保使用 root 用户
sudo su -
./uninstall_xxljob.sh

# 或者使用 sudo
sudo ./uninstall_xxljob.sh
```

#### 2. 服务停止失败

**问题**: 服务无法停止或进程仍在运行

**解决方案**:
```bash
# 强制停止服务
systemctl kill xxl-job

# 查找并终止相关进程
ps aux | grep xxl-job
kill -9 <PID>

# 重新运行卸载脚本
./uninstall_xxljob.sh
```

#### 3. 数据库连接失败

**问题**: 无法连接到 MySQL 数据库

**解决方案**:
```bash
# 检查 MySQL 服务状态
systemctl status mysql
# 或
systemctl status mysqld

# 启动 MySQL 服务
systemctl start mysql

# 测试连接
mysql -uroot -p -e "SELECT 1;"
```

#### 4. 目录删除失败

**问题**: 安装目录无法删除

**解决方案**:
```bash
# 检查目录占用
lsof /opt/xxl-job

# 强制终止占用进程
fuser -k /opt/xxl-job

# 手动删除目录
rm -rf /opt/xxl-job
```

#### 5. 用户删除失败

**问题**: 无法删除 xxljob 用户

**解决方案**:
```bash
# 终止用户进程
pkill -u xxljob

# 强制删除用户
userdel -f xxljob

# 手动删除家目录
rm -rf /home/xxljob
```

### 日志分析

#### 查看系统日志

```bash
# 查看 systemd 日志
journalctl -u xxl-job -f

# 查看系统日志
tail -f /var/log/messages
# 或
tail -f /var/log/syslog
```

#### 查看 XXL-JOB 日志

```bash
# 应用日志
tail -f /opt/xxl-job/logs/xxl-job-admin.log

# 错误日志
tail -f /opt/xxl-job/logs/error.log
```

## 安全注意事项

### 数据安全

1. **备份重要数据**: 卸载前务必备份重要的任务配置和执行日志
2. **确认数据库删除**: 谨慎选择是否删除数据库，删除后数据无法恢复
3. **验证备份完整性**: 确保备份文件完整且可用

### 系统安全

1. **权限检查**: 确保只有授权用户可以执行卸载脚本
2. **网络安全**: 卸载后及时更新防火墙规则
3. **服务依赖**: 检查其他服务是否依赖 XXL-JOB

### 操作安全

1. **测试环境**: 建议先在测试环境验证卸载流程
2. **维护窗口**: 在维护窗口期间执行卸载操作
3. **回滚准备**: 准备快速恢复方案

## 性能影响

### 卸载性能

- **执行时间**: 通常 2-5 分钟完成
- **系统负载**: 卸载过程对系统负载影响较小
- **磁盘 I/O**: 删除文件时会产生一定的磁盘 I/O

### 系统影响

- **内存释放**: 卸载后释放 XXL-JOB 占用的内存
- **端口释放**: 释放 8080 等端口供其他服务使用
- **进程清理**: 清理所有相关进程

## 版本兼容性

### XXL-JOB 版本

- **支持版本**: 2.3.x, 2.4.x
- **配置兼容**: 自动识别不同版本的配置文件
- **数据库兼容**: 支持不同版本的数据库结构

### 系统版本

- **CentOS**: 7.x, 8.x, 9.x
- **Ubuntu**: 18.04, 20.04, 22.04 LTS
- **Debian**: 9, 10, 11, 12
- **RHEL**: 7.x, 8.x, 9.x

## 最佳实践

### 卸载前准备

1. **停止相关任务**: 确保所有定时任务已停止
2. **通知用户**: 提前通知相关用户系统维护
3. **备份数据**: 创建完整的数据备份
4. **文档记录**: 记录当前配置和自定义设置

### 卸载过程

1. **按步骤执行**: 不要跳过任何确认步骤
2. **监控日志**: 实时监控卸载过程的日志输出
3. **验证结果**: 卸载后验证所有组件已正确清理
4. **清理验证**: 确保没有残留文件或配置

### 卸载后处理

1. **系统检查**: 检查系统整体状态
2. **服务验证**: 确认其他服务正常运行
3. **资源监控**: 监控系统资源使用情况
4. **文档更新**: 更新系统文档和配置记录

## 技术支持

### 获取帮助

- **脚本问题**: 检查脚本日志输出
- **系统问题**: 查看系统日志和错误信息
- **数据库问题**: 检查 MySQL 服务状态和连接

### 联系方式

- **项目地址**: https://github.com/your-repo
- **问题反馈**: 通过 GitHub Issues 提交问题
- **文档更新**: 欢迎提交文档改进建议

### 常用命令

```bash
# 检查卸载状态
systemctl status xxl-job
ls -la /opt/xxl-job
id xxljob

# 手动清理（如果需要）
systemctl stop xxl-job
systemctl disable xxl-job
rm -f /etc/systemd/system/xxl-job.service
systemctl daemon-reload
userdel -r xxljob
rm -rf /opt/xxl-job

# 数据库清理（如果需要）
mysql -uroot -p -e "DROP DATABASE IF EXISTS xxl_job;"
mysql -uroot -p -e "DROP USER IF EXISTS 'xxljob'@'%';"
mysql -uroot -p -e "FLUSH PRIVILEGES;"
```

---

**注意**: 本脚本会完全删除 XXL-JOB 及其相关数据，请在执行前确保已备份重要数据。如有疑问，请先在测试环境中验证。