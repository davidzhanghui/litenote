#  ECS 服务器安全加固指南

## 概述

本文档提供系统化的ECS 服务器安全加固方案，涵盖网络层、系统层、应用层和数据安全，帮助降低黑客入侵概率。

## 1. 网络层安全

### 安全组配置（控制台）

**入站规则配置：**
- **SSH**: 22 端口 → 限制源 IP（你的办公网 IP【使用curl ip.sb获取局域网的出口ip】 或 VPN IP）
- **HTTP**: 80 端口 → 0.0.0.0/0（如需要）
- **HTTPS**: 443 端口 → 0.0.0.0/0（如需要）
- **应用端口** → 限制源 IP

**出站规则配置：**
- 默认允许全部（按需限制）

⚠️ **重要**：不要对 SSH 开放 0.0.0.0/0，这是最常见的入侵点

## 2. SSH 加固（系统层最重要）

### 生成 SSH 密钥对（本地执行）

```bash
# 生成 ed25519 密钥对
ssh-keygen -t ed25519 -f ~/.ssh/tencent_ecs -C "your-email@example.com"

# 上传公钥到服务器（初始连接使用密码）
ssh-copy-id -i ~/.ssh/tencent_ecs.pub root@your-server-ip
```

### SSH 配置加固（服务器执行）

```bash
# 备份原配置文件
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
sudo nano /etc/ssh/sshd_config
```

**修改配置参数：**

```ssh
# 禁用密码登录，仅允许密钥
PasswordAuthentication no
PubkeyAuthentication yes

# 禁用 root 直接登录
PermitRootLogin no

# 更改默认端口（可选，增加扫描难度）
Port 2222

# 禁用空密码
PermitEmptyPasswords no

# 限制登录尝试
MaxAuthTries 3
MaxSessions 10

# 禁用 X11 转发
X11Forwarding no

# 禁用 TCP 转发
AllowTcpForwarding no
```

### 重启和验证

```bash
# 重启 SSH 服务
sudo systemctl restart sshd

# 验证配置（新终端测试，不要关闭当前连接）
ssh -i ~/.ssh/tencent_ecs -p 2222 your-user@your-server-ip
```

## 3. 系统层加固

### 用户权限管理

```bash
# 更新系统
sudo apt update && sudo apt upgrade -y

# 创建普通用户（不用 root）
sudo useradd -m -s /bin/bash deploy
sudo usermod -aG sudo deploy

# 设置 sudo 免密（可选）
echo "deploy ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/deploy

# 禁用 root 密码登录
sudo passwd -l root
```

### 防火墙配置

```bash
# 安装 UFW 防火墙
sudo apt install ufw -y

# 配置默认策略
sudo ufw default deny incoming
sudo ufw default allow outgoing

# 开放必要端口
sudo ufw allow 2222/tcp  # SSH 新端口
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS

# 启用防火墙
sudo ufw enable
```

### 防暴力破解

```bash
# 安装 fail2ban
sudo apt install fail2ban -y

# 启动服务
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# 查看状态
sudo systemctl status fail2ban
```

## 4. 监控和日志

### 日志审计

```bash
# 查看登录日志
sudo tail -f /var/log/auth.log

# 查看 SSH 连接状态
sudo ss -tunap | grep ssh

# 安装日志监控工具
sudo apt install logwatch -y
```

### 配置 logwatch

```bash
sudo nano /etc/logwatch/conf/logwatch.conf
```

**配置选项：**
```
Output = mail
Format = html
```

## 5. 应用层安全

### Docker 安全安装

```bash
# 安装 Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 将用户添加到 docker 组
sudo usermod -aG docker deploy
```

### 自动更新配置

```bash
# 安装无人值守更新
sudo apt install unattended-upgrades -y
sudo dpkg-reconfigure -plow unattended-upgrades
```

### 病毒防护

```bash
# 安装 ClamAV
sudo apt install clamav clamav-daemon -y

# 更新病毒库
sudo freshclam

# 启动服务
sudo systemctl enable clamav-daemon
sudo systemctl start clamav-daemon
```

## 6. 数据安全

### 云备份配置

**腾讯云控制台操作：**
1. 创建快照计划
2. 设置每日自动备份
3. 配置跨区域备份（可选）

### 本地备份脚本

```bash
# 创建数据库备份脚本
cat > /home/deploy/backup.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/backup"
DATE=$(date +%Y%m%d_%H%M%S)

# 创建备份目录
mkdir -p $BACKUP_DIR

# 数据库备份
mysqldump -u root -p'password' --all-databases > $BACKUP_DIR/db_$DATE.sql
gzip $BACKUP_DIR/db_$DATE.sql

# 文件备份
tar -czf $BACKUP_DIR/files_$DATE.tar.gz /usr/web

# 清理 7 天前的备份
find $BACKUP_DIR -name "*.sql.gz" -mtime +7 -delete
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete

echo "Backup completed: $DATE"
EOF

# 设置执行权限
chmod +x /home/deploy/backup.sh

# 添加到 crontab（每日凌晨 2 点）
echo "0 2 * * * /home/deploy/backup.sh >> /home/deploy/backup.log 2>&1" | sudo crontab -
```

### 文件加密

```bash
# 安装加密工具
sudo apt install ecryptfs-utils -y

# 加密重要目录（按需使用）
# sudo ecryptfs-setup-private
```

## 7. 定期检查清单

| 项目 | 频率 | 检查命令 | 说明 |
|------|------|----------|------|
| 系统更新 | 每周 | `sudo apt update && sudo apt upgrade` | 保持系统最新 |
| 日志审计 | 每日 | `sudo tail -f /var/log/auth.log` | 检查异常登录 |
| 开放端口 | 每月 | `sudo ss -tunap` | 确认端口开放合理 |
| 用户账户 | 每月 | `sudo cat /etc/passwd` | 检查异常用户 |
| 磁盘空间 | 每周 | `df -h` | 防止磁盘满 |
| 进程监控 | 实时 | `htop` 或 `top` | 监控系统进程 |
| SSH 配置 | 每月 | `sudo sshd -t` | 验证配置正确性 |

## 8. 腾讯云特定安全服务

### 云安全产品

1. **云防火墙**
   - 在腾讯云控制台启用
   - 配置访问控制策略

2. **DDoS 防护**
   - 基础版免费提供
   - 高防版本按需购买

3. **安全组规则审计**
   - 定期检查安全组配置
   - 移除不必要的规则

4. **VPC 隔离**
   - 将应用服务器放在私有子网
   - 使用 NAT 网关访问外网

## 9. 应急响应

### 入侵检测命令

```bash
# 1. 检查异常进程
ps aux | grep -E 'bash|sh|nc|ncat|python|perl|ruby'

# 2. 检查异常网络连接
sudo netstat -tulnap | grep ESTABLISHED

# 3. 检查 cron 任务
sudo crontab -l
sudo cat /etc/crontab
ls -la /etc/cron.*

# 4. 查看最近登录记录
sudo last -f /var/log/wtmp
sudo lastb -f /var/log/btmp

# 5. 检查 SSH 密钥
cat ~/.ssh/authorized_keys
ls -la ~/.ssh/

# 6. 检查系统文件完整性
sudo debsums -c
sudo rkhunter --check --skip-keypress
```

### 应急处理步骤

1. **立即隔离**
   ```bash
   # 断开网络（谨慎使用）
   # sudo iptables -P INPUT DROP
   # sudo iptables -P OUTPUT DROP
   ```

2. **保存证据**
   ```bash
   # 保存内存信息
   sudo dd if=/dev/mem of=/tmp/mem.dump bs=1k
   
   # 保存磁盘镜像
   sudo dd if=/dev/sda of=/tmp/disk.img
   ```

3. **系统恢复**
   ```bash
   # 从备份恢复
   # 重装系统并导入备份数据
   ```

## 10. 安全检查脚本

创建自动化安全检查脚本：

```bash
# 创建安全检查脚本
cat > /home/deploy/security-check.sh << 'EOF'
#!/bin/bash

echo "=== 服务器安全检查报告 ==="
echo "检查时间: $(date)"
echo "=========================="

# 1. 检查用户账户
echo "1. 用户账户检查:"
sudo cat /etc/passwd | grep -E "bash|sh"

# 2. 检查登录用户
echo -e "\n2. 当前登录用户:"
who

# 3. 检查开放端口
echo -e "\n3. 开放端口检查:"
sudo ss -tunlp | grep LISTEN

# 4. 检查失败登录
echo -e "\n4. 失败登录尝试:"
sudo grep "Failed password" /var/log/auth.log | tail -10

# 5. 检查磁盘使用
echo -e "\n5. 磁盘使用情况:"
df -h

# 6. 检查进程
echo -e "\n6. 可疑进程:"
ps aux | grep -E "bash|sh|nc|ncat" | grep -v grep

# 7. 检查定时任务
echo -e "\n7. 定时任务检查:"
sudo crontab -l
echo -e "\n系统定时任务:"
sudo cat /etc/crontab

# 8. 检查防火墙状态
echo -e "\n8. 防火墙状态:"
sudo ufw status

# 9. 检查 SSH 配置
echo -e "\n9. SSH 配置检查:"
sudo grep -E "PasswordAuthentication|PermitRootLogin|Port" /etc/ssh/sshd_config

# 10. 检查系统更新
echo -e "\n10. 系统更新检查:"
sudo apt list --upgradable 2>/dev/null | grep -v "WARNING"

echo -e "\n=== 检查完成 ==="
EOF

# 设置执行权限
chmod +x /home/deploy/security-check.sh

# 添加到 crontab（每周执行一次）
echo "0 9 * * 1 /home/deploy/security-check.sh > /home/deploy/security-report.txt 2>&1" | sudo crontab -
```

## 11. 安全加固优先级

### 🔥 立即执行（高优先级）
1. **SSH 密钥认证** - 禁用密码登录
2. **禁用 root 直接登录**
3. **安全组限制 SSH 源 IP**
4. **创建普通用户，禁用 root**

### 📅 本周内完成（中优先级）
1. **配置 UFW 防火墙**
2. **安装 fail2ban**
3. **系统更新和基础安全补丁**
4. **配置备份策略**

### 🔄 持续维护（低优先级）
1. **日志监控和审计**
2. **定期安全检查**
3. **权限审计**
4. **性能监控**

## 12. 最佳实践建议

### 密码策略
- 使用复杂密码（16位以上，包含大小写、数字、特殊字符）
- 定期更换密码
- 不同系统使用不同密码

### 网络安全
- 使用 VPN 或专线访问
- 不要在公共场所使用 SSH
- 启用双因素认证（2FA）

### 应用安全
- 定期更新依赖库
- 使用 HTTPS
- 实施最小权限原则

### 监控告警
- 配置登录失败告警
- 设置磁盘空间告警
- 配置 CPU/内存使用率告警

---

## 总结

按照本指南执行安全加固，可以有效降低服务器被入侵的风险：

- **SSH 加固** 能阻止 90% 的自动化攻击
- **防火墙和安全组** 提供网络层防护
- **fail2ban** 防止暴力破解
- **定期监控** 及时发现异常

建议按优先级逐步实施，确保每个步骤都经过测试验证。

**记住：安全是一个持续的过程，不是一次性任务。**
