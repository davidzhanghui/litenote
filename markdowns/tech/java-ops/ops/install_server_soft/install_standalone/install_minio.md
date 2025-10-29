# MinIO 对象存储服务安装脚本

## 概述

本脚本用于在Linux系统上自动安装和配置MinIO对象存储服务。MinIO是一个高性能的分布式对象存储服务，兼容Amazon S3 API，适用于云原生应用。

## 支持的系统

- **CentOS/RHEL**: 7.0+
- **Ubuntu**: 18.04+
- **Debian**: 9+
- **架构**: x86_64 (amd64), ARM64 (aarch64)

## 功能特性

### 核心功能
- 自动检测操作系统和架构
- 下载并安装最新版本的MinIO服务器
- 下载并安装MinIO客户端工具(mc)
- 创建专用的系统用户和用户组
- 配置systemd服务自动启动
- 设置防火墙规则
- 完整的日志记录和错误处理

### 安全特性
- 使用非特权用户运行服务
- 合理的文件和目录权限设置
- 配置文件权限保护
- 防火墙端口配置

## 安装配置

### 默认配置

| 配置项 | 默认值 | 说明 |
|--------|--------|------|
| MinIO用户 | `minio` | 运行服务的系统用户 |
| 安装目录 | `/opt/minio` | MinIO程序安装目录 |
| 数据目录 | `/data/minio` | 对象存储数据目录 |
| 配置目录 | `/etc/minio` | 配置文件目录 |
| API端口 | `9000` | MinIO API服务端口 |
| 控制台端口 | `9001` | Web管理控制台端口 |
| 访问密钥 | `minioadmin` | 默认管理员用户名 |
| 秘密密钥 | `minioadmin123` | 默认管理员密码 |

### 目录结构

```
/opt/minio/
├── bin/
│   ├── minio          # MinIO服务器程序
│   └── mc             # MinIO客户端工具
/data/minio/           # 数据存储目录
/etc/minio/
└── minio              # 环境变量配置文件
/var/log/minio/        # 日志目录
```

## 使用方法

### 基本安装

```bash
# 下载脚本
wget https://raw.githubusercontent.com/your-repo/scripts/install_minio.sh

# 添加执行权限
chmod +x install_minio.sh

# 以root权限运行
sudo ./install_minio.sh
```

### 自定义安装

可以通过修改脚本开头的配置变量来自定义安装:

```bash
# 编辑脚本
vim install_minio.sh

# 修改以下变量
MINIO_ACCESS_KEY="your_access_key"        # 自定义访问密钥
MINIO_SECRET_KEY="your_secret_key"        # 自定义秘密密钥
MINIO_DATA_DIR="/your/data/path"          # 自定义数据目录
MINIO_PORT="9000"                         # 自定义API端口
MINIO_CONSOLE_PORT="9001"                 # 自定义控制台端口
```

## 服务管理

### systemd 命令

```bash
# 启动服务
sudo systemctl start minio

# 停止服务
sudo systemctl stop minio

# 重启服务
sudo systemctl restart minio

# 查看服务状态
sudo systemctl status minio

# 开机自启动
sudo systemctl enable minio

# 禁用开机自启动
sudo systemctl disable minio

# 查看服务日志
sudo journalctl -u minio -f
```

### 配置文件

主配置文件位于 `/etc/minio/minio`，包含以下环境变量:

```bash
# 访问凭证
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=minioadmin123

# 数据目录
MINIO_VOLUMES=/data/minio

# 服务端口
MINIO_ADDRESS=:9000
MINIO_CONSOLE_ADDRESS=:9001

# 其他配置
MINIO_BROWSER=on
MINIO_DOMAIN=
MINIO_SERVER_URL=
```

修改配置后需要重启服务:

```bash
sudo systemctl restart minio
```

## 访问和使用

### Web控制台

安装完成后，可以通过浏览器访问MinIO控制台:

```
http://your-server-ip:9001
```

使用默认凭证登录:
- 用户名: `minioadmin`
- 密码: `minioadmin123`

### API访问

MinIO API端点:

```
http://your-server-ip:9000
```

### 使用MinIO客户端

```bash
# 配置客户端
mc alias set myminio http://localhost:9000 minioadmin minioadmin123

# 创建存储桶
mc mb myminio/mybucket

# 上传文件
mc cp /path/to/file myminio/mybucket/

# 列出存储桶
mc ls myminio

# 下载文件
mc cp myminio/mybucket/file /local/path/
```

## 安全配置

### 修改默认密钥

**重要**: 安装完成后请立即修改默认的访问密钥:

```bash
# 编辑配置文件
sudo vim /etc/minio/minio

# 修改以下行
MINIO_ROOT_USER=your_new_username
MINIO_ROOT_PASSWORD=your_strong_password

# 重启服务
sudo systemctl restart minio
```

### 配置HTTPS

为了提高安全性，建议配置HTTPS:

1. 准备SSL证书文件:
   - `private.key` - 私钥文件
   - `public.crt` - 证书文件

2. 将证书文件放置到 `/etc/minio/certs/` 目录:

```bash
sudo mkdir -p /etc/minio/certs
sudo cp private.key /etc/minio/certs/
sudo cp public.crt /etc/minio/certs/
sudo chown -R minio:minio /etc/minio/certs
sudo chmod 600 /etc/minio/certs/private.key
sudo chmod 644 /etc/minio/certs/public.crt
```

3. 重启服务:

```bash
sudo systemctl restart minio
```

### 防火墙配置

脚本会自动配置防火墙规则，如需手动配置:

**CentOS/RHEL (firewalld):**

```bash
sudo firewall-cmd --permanent --add-port=9000/tcp
sudo firewall-cmd --permanent --add-port=9001/tcp
sudo firewall-cmd --reload
```

**Ubuntu/Debian (UFW):**

```bash
sudo ufw allow 9000/tcp
sudo ufw allow 9001/tcp
```

## 性能优化

### 系统优化

1. **文件描述符限制**:

```bash
# 编辑limits配置
sudo vim /etc/security/limits.conf

# 添加以下行
minio soft nofile 65536
minio hard nofile 65536
```

2. **内核参数优化**:

```bash
# 编辑sysctl配置
sudo vim /etc/sysctl.conf

# 添加以下参数
net.core.rmem_default = 262144
net.core.rmem_max = 16777216
net.core.wmem_default = 262144
net.core.wmem_max = 16777216

# 应用配置
sudo sysctl -p
```

### 存储优化

1. **使用SSD存储**: 为获得最佳性能，建议使用SSD作为数据存储

2. **XFS文件系统**: 推荐使用XFS文件系统:

```bash
# 格式化磁盘
sudo mkfs.xfs /dev/sdb1

# 挂载到数据目录
sudo mount /dev/sdb1 /data/minio

# 添加到fstab
echo "/dev/sdb1 /data/minio xfs defaults 0 0" | sudo tee -a /etc/fstab
```

## 监控和维护

### 日志管理

```bash
# 查看实时日志
sudo journalctl -u minio -f

# 查看历史日志
sudo journalctl -u minio --since "1 hour ago"

# 查看错误日志
sudo journalctl -u minio -p err
```

### 健康检查

```bash
# 检查服务状态
sudo systemctl is-active minio

# 检查端口监听
sudo netstat -tlnp | grep -E ":(9000|9001)"

# 使用mc检查连接
mc admin info myminio
```

### 备份策略

1. **数据备份**:

```bash
# 使用mc镜像同步
mc mirror myminio/bucket /backup/path/

# 定期备份脚本
#!/bin/bash
DATE=$(date +%Y%m%d)
mc mirror myminio /backup/minio-$DATE/
```

2. **配置备份**:

```bash
# 备份配置文件
sudo cp -r /etc/minio /backup/minio-config-$(date +%Y%m%d)
```

## 故障排除

### 常见问题

1. **服务启动失败**:

```bash
# 查看详细错误信息
sudo journalctl -u minio -n 50

# 检查配置文件语法
sudo minio server --help
```

2. **端口被占用**:

```bash
# 查看端口占用
sudo netstat -tlnp | grep :9000

# 修改配置文件中的端口
sudo vim /etc/minio/minio
```

3. **权限问题**:

```bash
# 重新设置权限
sudo chown -R minio:minio /opt/minio
sudo chown -R minio:minio /data/minio
sudo chown -R minio:minio /etc/minio
```

4. **磁盘空间不足**:

```bash
# 检查磁盘使用情况
df -h /data/minio

# 清理旧数据或扩展存储
```

### 日志分析

常见错误模式:

- `Permission denied`: 权限问题
- `Address already in use`: 端口冲突
- `No space left on device`: 磁盘空间不足
- `Connection refused`: 网络连接问题

## 卸载

如需完全卸载MinIO:

```bash
# 停止并禁用服务
sudo systemctl stop minio
sudo systemctl disable minio

# 删除服务文件
sudo rm /etc/systemd/system/minio.service
sudo systemctl daemon-reload

# 删除用户和组
sudo userdel minio
sudo groupdel minio

# 删除文件和目录
sudo rm -rf /opt/minio
sudo rm -rf /etc/minio
sudo rm -rf /var/log/minio

# 删除符号链接
sudo rm -f /usr/local/bin/minio
sudo rm -f /usr/local/bin/mc

# 删除防火墙规则
sudo firewall-cmd --permanent --remove-port=9000/tcp
sudo firewall-cmd --permanent --remove-port=9001/tcp
sudo firewall-cmd --reload
```

**注意**: 删除数据目录前请确保已备份重要数据:

```bash
# 备份数据后删除
sudo rm -rf /data/minio
```

## 版本信息

- **脚本版本**: v1.0.0
- **支持的MinIO版本**: 最新稳定版
- **最后更新**: 2024年
- **维护者**: DevOps Team

## 许可证

本脚本遵循MIT许可证。MinIO本身遵循GNU AGPL v3许可证。

## 相关链接

- [MinIO官方网站](https://min.io/)
- [MinIO文档](https://docs.min.io/)
- [MinIO GitHub](https://github.com/minio/minio)
- [MinIO客户端文档](https://docs.min.io/docs/minio-client-complete-guide.html)