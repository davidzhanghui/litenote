# XXL-JOB安装脚本说明文档

## 概述

`install_xxljob.sh` 是一个自动化安装XXL-JOB分布式任务调度平台的Shell脚本，支持在CentOS/RHEL和Ubuntu/Debian系统上一键部署XXL-JOB及其依赖环境。

## 功能特性

### 核心功能
- **多系统支持**: 自动检测并支持CentOS/RHEL和Ubuntu/Debian系统
- **完整部署**: 自动安装Java环境、MySQL数据库、XXL-JOB应用
- **智能检测**: 自动检测已安装的服务，避免重复安装
- **数据库初始化**: 自动创建数据库、表结构和初始数据
- **服务管理**: 配置systemd服务，支持开机自启

### 配置优化
- **数据库优化**: 配置连接池参数，提高数据库性能
- **JVM调优**: 预设合理的内存参数
- **安全配置**: 创建专用用户，配置安全权限
- **防火墙配置**: 自动开放必要端口
- **日志管理**: 配置日志轮转和保留策略

## 系统要求

### 支持的操作系统
- **CentOS/RHEL**: 7.x, 8.x, 9.x
- **Ubuntu**: 18.04, 20.04, 22.04, 24.04
- **Debian**: 9, 10, 11, 12

### 硬件要求
- **CPU**: x86_64架构，最少2核
- **内存**: 最少2GB RAM（推荐4GB+）
- **存储**: 最少10GB可用空间
- **网络**: 需要互联网连接下载软件包

### 软件依赖
- **Java**: 自动安装OpenJDK 8
- **MySQL**: 自动安装MySQL 5.7+/8.0+
- **系统工具**: wget, curl, netstat等

### 权限要求
- 必须以root用户身份运行
- 需要sudo权限进行系统配置

## 使用方法

### 基本使用

```bash
# 1. 下载脚本
wget https://your-domain.com/install_xxljob.sh
# 或
curl -O https://your-domain.com/install_xxljob.sh

# 2. 添加执行权限
chmod +x install_xxljob.sh

# 3. 运行安装脚本
sudo ./install_xxljob.sh
```

### 远程安装

```bash
# 通过SSH远程安装
ssh root@your-server 'bash -s' < ./install_xxljob.sh

# 或者直接下载并执行
ssh root@your-server "curl -fsSL https://your-domain.com/install_xxljob.sh | bash"
```

### 自定义配置

在运行脚本前，可以修改脚本中的配置变量：

```bash
# 编辑脚本配置
vim install_xxljob.sh

# 主要配置项：
XXLJOB_VERSION="2.4.1"          # XXL-JOB版本
XXLJOB_PORT="8080"              # 服务端口
XXLJOB_DB_PASSWORD="xxljob123"  # 数据库密码
MYSQL_ROOT_PASSWORD="root123456" # MySQL root密码
XXLJOB_ACCESS_TOKEN="your_token" # 访问令牌
```

## 安装过程

### 安装步骤

1. **系统检测**: 检测操作系统类型和版本
2. **系统更新**: 更新系统包管理器
3. **Java安装**: 安装OpenJDK 8环境
4. **MySQL安装**: 安装MySQL数据库服务
5. **数据库配置**: 创建XXL-JOB数据库和用户
6. **表结构初始化**: 创建XXL-JOB所需的数据表
7. **用户创建**: 创建XXL-JOB运行用户
8. **应用下载**: 下载XXL-JOB应用程序
9. **配置文件**: 生成应用配置文件
10. **服务配置**: 创建systemd服务文件
11. **服务启动**: 启动XXL-JOB服务
12. **防火墙配置**: 开放必要端口
13. **安装验证**: 验证各组件运行状态

### 预计安装时间

- **网络良好**: 5-10分钟
- **网络一般**: 10-20分钟
- **网络较差**: 20-30分钟

## 配置说明

### 默认配置

| 配置项 | 默认值 | 说明 |
|--------|--------|------|
| 服务端口 | 8080 | XXL-JOB Web管理界面端口 |
| 数据库名 | xxl_job | XXL-JOB数据库名称 |
| 数据库用户 | xxljob | XXL-JOB数据库用户 |
| 数据库密码 | xxljob123 | XXL-JOB数据库密码 |
| MySQL端口 | 3306 | MySQL数据库端口 |
| 安装目录 | /opt/xxl-job | XXL-JOB安装目录 |
| 运行用户 | xxljob | XXL-JOB运行用户 |
| 管理员账号 | admin | 默认管理员用户名 |
| 管理员密码 | 123456 | 默认管理员密码 |

### 重要文件位置

```
/opt/xxl-job/
├── xxl-job-admin.jar          # 主程序文件
├── application.properties     # 应用配置文件
└── logs/                      # 应用日志目录

/etc/systemd/system/
└── xxl-job.service           # systemd服务文件
```

## 服务管理

### 基本命令

```bash
# 启动服务
sudo systemctl start xxl-job

# 停止服务
sudo systemctl stop xxl-job

# 重启服务
sudo systemctl restart xxl-job

# 查看服务状态
sudo systemctl status xxl-job

# 查看服务日志
sudo journalctl -u xxl-job -f

# 开机自启
sudo systemctl enable xxl-job

# 禁用自启
sudo systemctl disable xxl-job
```

### 日志查看

```bash
# 查看应用日志
tail -f /opt/xxl-job/logs/xxl-job-admin.log

# 查看系统日志
journalctl -u xxl-job --since "1 hour ago"

# 查看错误日志
journalctl -u xxl-job -p err
```

## 访问和使用

### Web管理界面

1. **访问地址**: `http://服务器IP:8080/xxl-job-admin`
2. **默认账号**: `admin`
3. **默认密码**: `123456`

### 首次使用步骤

1. **登录系统**: 使用默认账号密码登录
2. **修改密码**: 进入用户管理修改默认密码
3. **创建执行器**: 在执行器管理中创建执行器
4. **配置任务**: 在任务管理中创建定时任务
5. **启动任务**: 启动任务并监控执行状态

## 故障排除

### 常见问题

#### 1. 服务启动失败

```bash
# 检查服务状态
systemctl status xxl-job

# 查看详细日志
journalctl -u xxl-job -n 50

# 检查端口占用
netstat -tlnp | grep 8080

# 检查Java环境
java -version
```

#### 2. 数据库连接失败

```bash
# 检查MySQL服务
systemctl status mysql
# 或
systemctl status mysqld

# 测试数据库连接
mysql -uxxljob -pxxljob123 -h127.0.0.1 xxl_job

# 检查数据库配置
cat /opt/xxl-job/application.properties | grep datasource
```

#### 3. 无法访问Web界面

```bash
# 检查防火墙状态
firewall-cmd --list-ports  # CentOS/RHEL
ufw status                 # Ubuntu

# 检查端口监听
ss -tlnp | grep 8080

# 检查应用日志
tail -f /opt/xxl-job/logs/xxl-job-admin.log
```

### 解决方案

#### 重新安装

```bash
# 停止服务
systemctl stop xxl-job

# 删除服务文件
rm -f /etc/systemd/system/xxl-job.service

# 删除安装目录
rm -rf /opt/xxl-job

# 重新运行安装脚本
./install_xxljob.sh
```

#### 重置数据库

```bash
# 登录MySQL
mysql -uroot -p

# 删除数据库
DROP DATABASE xxl_job;

# 重新创建数据库
CREATE DATABASE xxl_job DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

# 重新运行初始化脚本
# （脚本会自动检测并重新初始化）
```

## 安全建议

### 生产环境配置

1. **修改默认密码**
   ```bash
   # 修改管理员密码
   # 在Web界面：系统管理 -> 用户管理 -> 修改密码
   ```

2. **修改数据库密码**
   ```bash
   # 修改MySQL密码
   mysql -uroot -p
   ALTER USER 'xxljob'@'%' IDENTIFIED BY 'new_strong_password';
   
   # 更新配置文件
   vim /opt/xxl-job/application.properties
   # 修改 spring.datasource.password=new_strong_password
   
   # 重启服务
   systemctl restart xxl-job
   ```

3. **配置访问令牌**
   ```bash
   # 修改配置文件
   vim /opt/xxl-job/application.properties
   # 修改 xxl.job.accessToken=your_secure_token
   
   # 重启服务
   systemctl restart xxl-job
   ```

4. **配置SSL证书**（可选）
   ```bash
   # 在配置文件中添加SSL配置
   server.ssl.enabled=true
   server.ssl.key-store=/path/to/keystore.p12
   server.ssl.key-store-password=password
   server.ssl.key-store-type=PKCS12
   ```

### 网络安全

1. **防火墙配置**
   ```bash
   # 只允许特定IP访问
   firewall-cmd --permanent --add-rich-rule="rule family='ipv4' source address='192.168.1.0/24' port protocol='tcp' port='8080' accept"
   firewall-cmd --reload
   ```

2. **反向代理**（推荐）
   ```nginx
   # Nginx配置示例
   server {
       listen 80;
       server_name xxljob.yourdomain.com;
       
       location / {
           proxy_pass http://127.0.0.1:8080;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
       }
   }
   ```

## 性能优化

### JVM参数调优

```bash
# 编辑服务文件
vim /etc/systemd/system/xxl-job.service

# 修改ExecStart行，调整JVM参数
ExecStart=/usr/bin/java -Xms1g -Xmx2g -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -jar /opt/xxl-job/xxl-job-admin.jar

# 重新加载配置
systemctl daemon-reload
systemctl restart xxl-job
```

### 数据库优化

```sql
-- MySQL配置优化
-- 在 /etc/mysql/mysql.conf.d/mysqld.cnf 中添加：
[mysqld]
innodb_buffer_pool_size = 1G
innodb_log_file_size = 256M
max_connections = 200
query_cache_size = 64M
```

## 备份和恢复

### 数据备份

```bash
# 创建备份脚本
cat > /opt/xxl-job/backup.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/opt/xxl-job/backup"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# 备份数据库
mysqldump -uxxljob -pxxljob123 xxl_job > $BACKUP_DIR/xxl_job_$DATE.sql

# 备份配置文件
cp /opt/xxl-job/application.properties $BACKUP_DIR/application.properties_$DATE

# 清理7天前的备份
find $BACKUP_DIR -name "*.sql" -mtime +7 -delete
find $BACKUP_DIR -name "application.properties_*" -mtime +7 -delete

echo "Backup completed: $DATE"
EOF

chmod +x /opt/xxl-job/backup.sh

# 设置定时备份
crontab -e
# 添加：0 2 * * * /opt/xxl-job/backup.sh
```

### 数据恢复

```bash
# 恢复数据库
mysql -uxxljob -pxxljob123 xxl_job < /opt/xxl-job/backup/xxl_job_20240101_020000.sql

# 恢复配置文件
cp /opt/xxl-job/backup/application.properties_20240101_020000 /opt/xxl-job/application.properties

# 重启服务
systemctl restart xxl-job
```

## 版本升级

### 升级步骤

```bash
# 1. 备份数据
/opt/xxl-job/backup.sh

# 2. 停止服务
systemctl stop xxl-job

# 3. 备份当前版本
cp /opt/xxl-job/xxl-job-admin.jar /opt/xxl-job/xxl-job-admin.jar.bak

# 4. 下载新版本
cd /opt/xxl-job
wget -O xxl-job-admin-2.4.2.jar "https://github.com/xuxueli/xxl-job/releases/download/v2.4.2/xxl-job-admin-2.4.2.jar"

# 5. 更新符号链接
ln -sf xxl-job-admin-2.4.2.jar xxl-job-admin.jar

# 6. 启动服务
systemctl start xxl-job

# 7. 验证升级
systemctl status xxl-job
```

## 卸载说明

如需完全卸载XXL-JOB，请参考 `uninstall_xxljob_README.md` 文档或运行卸载脚本：

```bash
./uninstall_xxljob.sh
```

## 技术支持

### 官方资源

- **官方网站**: https://www.xuxueli.com/xxl-job/
- **GitHub仓库**: https://github.com/xuxueli/xxl-job
- **官方文档**: https://www.xuxueli.com/xxl-job/#%E3%80%8A%E5%88%86%E5%B8%83%E5%BC%8F%E4%BB%BB%E5%8A%A1%E8%B0%83%E5%BA%A6%E5%B9%B3%E5%8F%B0XXL-JOB%E3%80%8B

### 社区支持

- **QQ群**: 227775696
- **微信群**: 添加作者微信拉群
- **Issues**: https://github.com/xuxueli/xxl-job/issues

### 常用链接

- **在线演示**: http://www.xuxueli.com/xxl-job-admin
- **快速入门**: https://www.xuxueli.com/xxl-job/#2.1%20%E5%BF%AB%E9%80%9F%E5%85%A5%E9%97%A8
- **执行器开发**: https://www.xuxueli.com/xxl-job/#2.2%20%E6%89%A7%E8%A1%8C%E5%99%A8%E5%BC%80%E5%8F%91

---

**注意**: 本脚本仅供学习和测试使用，生产环境部署请根据实际需求进行安全配置和性能调优。