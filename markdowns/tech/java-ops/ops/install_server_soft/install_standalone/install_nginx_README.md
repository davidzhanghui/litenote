# Nginx安装脚本说明文档

## 概述

`install_nginx.sh` 是一个自动化安装Nginx Web服务器的Shell脚本，支持在CentOS/RHEL和Ubuntu/Debian系统上安装Nginx最新稳定版本，并提供完整的配置优化和SSL支持。

## 功能特性

### 核心功能
- **多系统支持**: 自动检测并支持CentOS/RHEL和Ubuntu/Debian系统
- **官方源安装**: 使用Nginx官方仓库，确保获得最新稳定版本
- **智能检测**: 自动检测已安装的Nginx服务，避免重复安装
- **完整配置**: 提供优化的配置文件和安全设置
- **SSL支持**: 自动生成自签名证书，支持HTTPS访问

### 性能优化
- **Gzip压缩**: 自动启用多种文件类型的压缩
- **静态文件缓存**: 配置浏览器缓存策略
- **Worker优化**: 自动调整worker进程数和连接数
- **Keep-Alive**: 优化HTTP连接复用
- **安全头部**: 添加多种安全HTTP头部

### 安全配置
- **隐藏版本**: 禁用服务器版本信息显示
- **访问控制**: 禁止访问隐藏文件和目录
- **SSL配置**: 提供安全的SSL/TLS配置
- **错误页面**: 自定义美观的错误页面
- **文件上传限制**: 合理的文件上传大小限制

## 系统要求

### 支持的操作系统
- **CentOS/RHEL**: 7.x, 8.x, 9.x
- **Ubuntu**: 18.04, 20.04, 22.04, 24.04
- **Debian**: 9, 10, 11, 12

### 硬件要求
- **CPU**: x86_64架构
- **内存**: 最少512MB RAM
- **存储**: 最少5GB可用空间
- **网络**: 需要互联网连接下载软件包

### 权限要求
- 必须以root用户身份运行
- 需要sudo权限进行系统配置

## 使用方法

### 基本使用

```bash
# 1. 下载脚本
wget https://your-domain.com/install_nginx.sh
# 或
curl -O https://your-domain.com/install_nginx.sh

# 2. 添加执行权限
chmod +x install_nginx.sh

# 3. 以root用户运行
sudo ./install_nginx.sh
```

### 一键安装

```bash
# 直接下载并执行
curl -fsSL https://your-domain.com/install_nginx.sh | sudo bash
```

## 默认配置

### 基本配置
- **HTTP端口**: `80`
- **HTTPS端口**: `443`
- **用户/组**: `nginx:nginx`
- **配置目录**: `/etc/nginx`
- **网站根目录**: `/var/www/html`
- **日志目录**: `/var/log/nginx`

### 性能配置
```nginx
worker_processes auto;
worker_connections 1024;
keepalive_timeout 65;
client_max_body_size 100M;
```

### Gzip配置
```nginx
gzip on;
gzip_vary on;
gzip_min_length 1000;
gzip_comp_level 6;
gzip_types text/plain text/css application/json application/javascript;
```

### SSL配置
```nginx
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384;
ssl_prefer_server_ciphers off;
```

## 安装内容

### Nginx组件
1. **Nginx主程序**: 最新稳定版本
2. **配置文件**: 优化的nginx.conf
3. **默认站点**: 美观的欢迎页面
4. **错误页面**: 自定义404和50x页面
5. **SSL证书**: 自签名测试证书

### 目录结构
```
/etc/nginx/
├── nginx.conf              # 主配置文件
├── conf.d/                 # 站点配置目录
│   └── ssl-example.conf.disabled  # SSL配置示例
└── ssl/                    # SSL证书目录
    ├── nginx.crt           # SSL证书
    └── nginx.key           # SSL私钥

/var/www/html/
├── index.html              # 默认首页
├── 404.html                # 404错误页面
└── 50x.html                # 50x错误页面

/var/log/nginx/
├── access.log              # 访问日志
└── error.log               # 错误日志
```

## 验证安装

### 自动验证
脚本会自动执行以下验证步骤：

```bash
# 1. 检查服务状态
systemctl status nginx

# 2. 验证版本信息
nginx -v

# 3. 测试配置文件
nginx -t

# 4. 检查监听端口
netstat -tlnp | grep nginx

# 5. 测试HTTP响应
curl -I http://localhost
```

### 手动验证

```bash
# 检查Nginx服务
sudo systemctl status nginx

# 查看Nginx版本
nginx -version

# 测试配置文件语法
sudo nginx -t

# 查看监听端口
sudo netstat -tlnp | grep :80
sudo netstat -tlnp | grep :443

# 测试网站访问
curl http://localhost
curl -k https://localhost

# 查看进程
ps aux | grep nginx
```

## 常用命令

### 服务管理

```bash
# 启动Nginx
sudo systemctl start nginx

# 停止Nginx
sudo systemctl stop nginx

# 重启Nginx
sudo systemctl restart nginx

# 重载配置（不中断服务）
sudo systemctl reload nginx

# 查看服务状态
sudo systemctl status nginx

# 启用开机自启
sudo systemctl enable nginx

# 禁用开机自启
sudo systemctl disable nginx
```

### 配置管理

```bash
# 测试配置文件语法
sudo nginx -t

# 查看配置文件
sudo cat /etc/nginx/nginx.conf

# 编辑主配置文件
sudo nano /etc/nginx/nginx.conf

# 创建新站点配置
sudo nano /etc/nginx/conf.d/mysite.conf

# 重载配置
sudo nginx -s reload
```

### 日志管理

```bash
# 查看访问日志
sudo tail -f /var/log/nginx/access.log

# 查看错误日志
sudo tail -f /var/log/nginx/error.log

# 查看实时日志
sudo journalctl -u nginx -f

# 清空日志
sudo truncate -s 0 /var/log/nginx/access.log
sudo truncate -s 0 /var/log/nginx/error.log
```

## 站点配置

### 添加新站点

```bash
# 1. 创建站点配置文件
sudo nano /etc/nginx/conf.d/example.com.conf
```

```nginx
server {
    listen 80;
    server_name example.com www.example.com;
    root /var/www/example.com;
    index index.html index.htm index.php;
    
    location / {
        try_files $uri $uri/ =404;
    }
    
    # PHP支持（如需要）
    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
    
    # 静态文件缓存
    location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

```bash
# 2. 创建站点目录
sudo mkdir -p /var/www/example.com

# 3. 设置权限
sudo chown -R nginx:nginx /var/www/example.com

# 4. 测试配置
sudo nginx -t

# 5. 重载配置
sudo systemctl reload nginx
```

### SSL配置

```bash
# 1. 复制SSL示例配置
sudo cp /etc/nginx/conf.d/ssl-example.conf.disabled /etc/nginx/conf.d/ssl-site.conf

# 2. 编辑SSL配置
sudo nano /etc/nginx/conf.d/ssl-site.conf
```

```nginx
server {
    listen 443 ssl http2;
    server_name your-domain.com;
    
    # SSL证书配置
    ssl_certificate /etc/nginx/ssl/your-domain.crt;
    ssl_certificate_key /etc/nginx/ssl/your-domain.key;
    
    # SSL安全配置
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    
    root /var/www/html;
    index index.html;
    
    location / {
        try_files $uri $uri/ =404;
    }
}

# HTTP重定向到HTTPS
server {
    listen 80;
    server_name your-domain.com;
    return 301 https://$server_name$request_uri;
}
```

## 常见问题

### Q1: Nginx启动失败
**问题**: Nginx服务无法启动

**解决方案**:
```bash
# 查看详细错误信息
sudo journalctl -u nginx.service -l

# 检查配置文件语法
sudo nginx -t

# 检查端口占用
sudo netstat -tlnp | grep :80
sudo netstat -tlnp | grep :443

# 杀死占用端口的进程
sudo fuser -k 80/tcp
sudo fuser -k 443/tcp

# 重新启动
sudo systemctl start nginx
```

### Q2: 403 Forbidden错误
**问题**: 访问网站出现403错误

**解决方案**:
```bash
# 检查文件权限
ls -la /var/www/html/

# 设置正确权限
sudo chown -R nginx:nginx /var/www/html/
sudo chmod -R 755 /var/www/html/

# 检查SELinux（CentOS/RHEL）
sudo setsebool -P httpd_can_network_connect 1
sudo restorecon -R /var/www/html/
```

### Q3: 配置文件语法错误
**问题**: nginx -t 报告语法错误

**解决方案**:
```bash
# 查看具体错误
sudo nginx -t

# 备份当前配置
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup

# 恢复默认配置
sudo cp /etc/nginx/nginx.conf.backup.* /etc/nginx/nginx.conf

# 重新测试
sudo nginx -t
```

### Q4: SSL证书问题
**问题**: HTTPS访问出现证书错误

**解决方案**:
```bash
# 检查证书文件
sudo ls -la /etc/nginx/ssl/

# 重新生成自签名证书
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -subj "/C=CN/ST=Beijing/L=Beijing/O=Test/CN=localhost"

# 设置正确权限
sudo chmod 600 /etc/nginx/ssl/nginx.key
sudo chmod 644 /etc/nginx/ssl/nginx.crt

# 重载配置
sudo systemctl reload nginx
```

## 性能优化

### 系统级优化

```bash
# 增加文件描述符限制
echo "nginx soft nofile 65535" | sudo tee -a /etc/security/limits.conf
echo "nginx hard nofile 65535" | sudo tee -a /etc/security/limits.conf

# 优化内核参数
sudo tee -a /etc/sysctl.conf <<EOF
net.core.somaxconn = 65535
net.ipv4.tcp_max_syn_backlog = 65535
net.core.netdev_max_backlog = 5000
net.ipv4.tcp_fin_timeout = 30
EOF

# 应用内核参数
sudo sysctl -p
```

### Nginx配置优化

```nginx
# 在nginx.conf中添加或修改
worker_processes auto;
worker_rlimit_nofile 65535;

events {
    worker_connections 65535;
    use epoll;
    multi_accept on;
}

http {
    # 连接优化
    keepalive_timeout 60;
    keepalive_requests 100;
    
    # 缓冲区优化
    client_body_buffer_size 128k;
    client_header_buffer_size 32k;
    large_client_header_buffers 4 32k;
    
    # 超时优化
    client_header_timeout 60;
    client_body_timeout 60;
    send_timeout 60;
    
    # 压缩优化
    gzip_comp_level 6;
    gzip_min_length 1000;
    gzip_proxied any;
    gzip_vary on;
}
```

### 缓存配置

```nginx
# 添加到server块中
location ~* \.(jpg|jpeg|png|gif|ico|css|js|pdf|txt)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
    add_header Pragma public;
    add_header Vary Accept-Encoding;
}

location ~* \.(html|htm)$ {
    expires 1h;
    add_header Cache-Control "public";
}
```

## 安全加固

### 基础安全配置

```nginx
# 在http块中添加
server_tokens off;
add_header X-Frame-Options DENY;
add_header X-Content-Type-Options nosniff;
add_header X-XSS-Protection "1; mode=block";
add_header Referrer-Policy "strict-origin-when-cross-origin";
add_header Content-Security-Policy "default-src 'self'";

# 限制请求方法
if ($request_method !~ ^(GET|HEAD|POST)$ ) {
    return 405;
}

# 隐藏敏感文件
location ~ /\. {
    deny all;
}

location ~ ~$ {
    deny all;
}
```

### 访问控制

```nginx
# IP白名单
location /admin {
    allow 192.168.1.0/24;
    allow 10.0.0.0/8;
    deny all;
}

# 限制请求频率
limit_req_zone $binary_remote_addr zone=login:10m rate=1r/s;
location /login {
    limit_req zone=login burst=5 nodelay;
}
```

## 监控和日志

### 日志配置

```nginx
# 自定义日志格式
log_format detailed '$remote_addr - $remote_user [$time_local] '
                   '"$request" $status $body_bytes_sent '
                   '"$http_referer" "$http_user_agent" '
                   '$request_time $upstream_response_time';

access_log /var/log/nginx/access.log detailed;
```

### 状态监控

```nginx
# 启用状态页面
location /nginx_status {
    stub_status on;
    access_log off;
    allow 127.0.0.1;
    deny all;
}
```

### 日志轮转

```bash
# 创建logrotate配置
sudo tee /etc/logrotate.d/nginx <<EOF
/var/log/nginx/*.log {
    daily
    missingok
    rotate 52
    compress
    delaycompress
    notifempty
    create 644 nginx nginx
    postrotate
        if [ -f /var/run/nginx.pid ]; then
            kill -USR1 `cat /var/run/nginx.pid`
        fi
    endscript
}
EOF
```

## 卸载方法

### 完全卸载Nginx

```bash
# 停止服务
sudo systemctl stop nginx
sudo systemctl disable nginx

# CentOS/RHEL系统
sudo yum remove -y nginx
sudo rm -rf /etc/nginx
sudo rm -rf /var/log/nginx
sudo rm -rf /var/cache/nginx
sudo rm -rf /var/www/html

# Ubuntu/Debian系统
sudo apt remove --purge -y nginx nginx-common
sudo rm -rf /etc/nginx
sudo rm -rf /var/log/nginx
sudo rm -rf /var/cache/nginx
sudo rm -rf /var/www/html

# 删除用户和组
sudo userdel nginx
sudo groupdel nginx

# 删除仓库配置
sudo rm -f /etc/yum.repos.d/nginx.repo
sudo rm -f /etc/apt/sources.list.d/nginx.list
```

## 故障排除

### 常用诊断命令

```bash
# 检查Nginx进程
ps aux | grep nginx

# 检查监听端口
sudo netstat -tlnp | grep nginx
sudo ss -tlnp | grep nginx

# 检查配置文件
sudo nginx -T

# 查看错误日志
sudo tail -f /var/log/nginx/error.log

# 检查系统资源
top -p $(pgrep nginx | tr '\n' ',' | sed 's/,$//')

# 测试网络连接
curl -I http://localhost
telnet localhost 80
```

### 性能诊断

```bash
# 检查连接数
netstat -an | grep :80 | wc -l

# 检查Nginx状态
curl http://localhost/nginx_status

# 分析访问日志
sudo awk '{print $1}' /var/log/nginx/access.log | sort | uniq -c | sort -nr | head -10

# 检查响应时间
sudo awk '{print $NF}' /var/log/nginx/access.log | sort -n | tail -10
```

## 技术支持

### 官方文档
- [Nginx官方文档](https://nginx.org/en/docs/)
- [Nginx配置指南](https://nginx.org/en/docs/beginners_guide.html)
- [Nginx模块文档](https://nginx.org/en/docs/)

### 社区支持
- [Nginx社区论坛](https://forum.nginx.org/)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/nginx)
- [GitHub Issues](https://github.com/nginx/nginx/issues)

### 商业支持
- [Nginx Plus](https://www.nginx.com/products/nginx/)
- [专业技术支持](https://www.nginx.com/support/)

## 更新日志

### v1.0.0 (2024-01-20)
- 初始版本发布
- 支持CentOS/RHEL和Ubuntu/Debian系统
- 集成性能优化配置
- 添加SSL支持和安全配置
- 实现自动化安装和配置

### 计划功能
- [ ] 支持更多Linux发行版
- [ ] 添加负载均衡配置
- [ ] 集成Let's Encrypt证书
- [ ] 添加WAF防护功能
- [ ] 支持容器化部署

---

**注意**: 本脚本仅供学习和测试使用，生产环境使用前请充分测试并根据实际需求调整配置。