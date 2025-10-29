#!/bin/bash

# Nginx Web服务器安装脚本
# 安装Nginx最新稳定版本
# 支持CentOS/RHEL和Ubuntu/Debian系统
# 再你自己的电脑上执行： ssh root@14.103.191.82 'bash -s' < ./scripts/other/install_nginx.sh
# 安装完成后验证： curl http://14.103.191.82

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Nginx配置
NGINX_USER="nginx"
NGINX_GROUP="nginx"
NGINX_HOME="/etc/nginx"
NGINX_LOG_DIR="/var/log/nginx"
NGINX_CACHE_DIR="/var/cache/nginx"
NGINX_RUN_DIR="/var/run"
WEB_ROOT="/var/www/html"
NGINX_PORT="80"
NGINX_SSL_PORT="443"

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# 检测操作系统
detect_os() {
    if [ -f /etc/redhat-release ]; then
        OS="centos"
        log_info "检测到CentOS/RHEL系统"
    elif [ -f /etc/debian_version ]; then
        OS="ubuntu"
        log_info "检测到Ubuntu/Debian系统"
    else
        log_error "不支持的操作系统"
        exit 1
    fi
}

# 更新系统
update_system() {
    log_step "更新系统包管理器..."
    if [ "$OS" = "centos" ]; then
        yum update -y
    else
        apt update && apt upgrade -y
    fi
    log_info "系统更新完成"
}

# 安装Nginx
install_nginx() {
    log_step "检查Nginx服务状态..."
    
    # 检查Nginx是否已安装并运行
    if systemctl is-active --quiet nginx 2>/dev/null; then
        log_info "Nginx服务已在运行，跳过安装"
        return 0
    fi
    
    log_step "安装Nginx Web服务器..."
    
    if [ "$OS" = "centos" ]; then
        # CentOS/RHEL安装Nginx
        # 安装EPEL仓库
        yum install -y epel-release
        
        # 添加Nginx官方仓库
        cat > /etc/yum.repos.d/nginx.repo <<EOF
[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/\$releasever/\$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true

[nginx-mainline]
name=nginx mainline repo
baseurl=http://nginx.org/packages/mainline/centos/\$releasever/\$basearch/
gpgcheck=1
enabled=0
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
EOF
        
        # 导入GPG密钥
        rpm --import https://nginx.org/keys/nginx_signing.key
        
        # 安装Nginx
        yum install -y nginx
        
    else
        # Ubuntu/Debian安装Nginx
        # 安装必要的软件包
        apt install -y curl gnupg2 ca-certificates lsb-release
        
        # 添加Nginx官方GPG密钥
        curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add -
        
        # 添加Nginx官方仓库
        echo "deb http://nginx.org/packages/ubuntu $(lsb_release -cs) nginx" > /etc/apt/sources.list.d/nginx.list
        
        # 设置仓库优先级
        echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" > /etc/apt/preferences.d/99nginx
        
        # 更新包索引
        apt update
        
        # 安装Nginx
        apt install -y nginx
    fi
    
    log_info "Nginx安装完成"
}

# 配置Nginx
configure_nginx() {
    log_step "配置Nginx服务..."
    
    # 创建必要的目录
    mkdir -p $NGINX_LOG_DIR
    mkdir -p $NGINX_CACHE_DIR
    mkdir -p $WEB_ROOT
    mkdir -p $NGINX_HOME/conf.d
    mkdir -p $NGINX_HOME/ssl
    
    # 备份原始配置文件
    if [ -f $NGINX_HOME/nginx.conf ]; then
        cp $NGINX_HOME/nginx.conf $NGINX_HOME/nginx.conf.backup.$(date +%Y%m%d_%H%M%S)
    fi
    
    # 创建优化的nginx.conf配置文件
    cat > $NGINX_HOME/nginx.conf <<EOF
user $NGINX_USER;
worker_processes auto;
error_log $NGINX_LOG_DIR/error.log warn;
pid $NGINX_RUN_DIR/nginx.pid;

# 优化worker连接数
events {
    worker_connections 1024;
    use epoll;
    multi_accept on;
}

http {
    # 基础配置
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    
    # 日志格式
    log_format main '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                    '\$status \$body_bytes_sent "\$http_referer" '
                    '"\$http_user_agent" "\$http_x_forwarded_for"';
    
    access_log $NGINX_LOG_DIR/access.log main;
    
    # 性能优化
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    server_tokens off;
    
    # 文件上传大小限制
    client_max_body_size 100M;
    client_body_buffer_size 128k;
    
    # Gzip压缩
    gzip on;
    gzip_vary on;
    gzip_min_length 1000;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/json
        application/javascript
        application/xml+rss
        application/atom+xml
        image/svg+xml;
    
    # 安全头部
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header Referrer-Policy "strict-origin-when-cross-origin";
    
    # 包含其他配置文件
    include $NGINX_HOME/conf.d/*.conf;
    
    # 默认服务器配置
    server {
        listen $NGINX_PORT default_server;
        listen [::]:$NGINX_PORT default_server;
        server_name _;
        root $WEB_ROOT;
        index index.html index.htm index.nginx-debian.html;
        
        # 安全配置
        location ~ /\. {
            deny all;
        }
        
        location ~* \.(jpg|jpeg|png|gif|ico|css|js)\$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
        
        location / {
            try_files \$uri \$uri/ =404;
        }
        
        # 错误页面
        error_page 404 /404.html;
        error_page 500 502 503 504 /50x.html;
        
        location = /50x.html {
            root $WEB_ROOT;
        }
    }
}
EOF
    
    # 创建默认网站首页
    cat > $WEB_ROOT/index.html <<EOF
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>欢迎使用Nginx</title>
    <style>
        body {
            font-family: 'Arial', sans-serif;
            margin: 0;
            padding: 0;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
        }
        .container {
            text-align: center;
            background: rgba(255, 255, 255, 0.1);
            padding: 2rem;
            border-radius: 10px;
            backdrop-filter: blur(10px);
            box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.37);
        }
        h1 {
            font-size: 3rem;
            margin-bottom: 1rem;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }
        p {
            font-size: 1.2rem;
            margin-bottom: 1rem;
        }
        .info {
            background: rgba(255, 255, 255, 0.2);
            padding: 1rem;
            border-radius: 5px;
            margin-top: 2rem;
        }
        .version {
            font-size: 0.9rem;
            opacity: 0.8;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🎉 Nginx安装成功！</h1>
        <p>恭喜您，Nginx Web服务器已成功安装并运行。</p>
        <p>您现在可以开始部署您的网站了。</p>
        <div class="info">
            <p><strong>服务器信息：</strong></p>
            <p>服务器时间：<span id="datetime"></span></p>
            <p>服务器IP：<span id="serverip">$(hostname -I | awk '{print $1}')</span></p>
            <p class="version">Powered by Nginx</p>
        </div>
    </div>
    
    <script>
        function updateDateTime() {
            const now = new Date();
            document.getElementById('datetime').textContent = now.toLocaleString('zh-CN');
        }
        updateDateTime();
        setInterval(updateDateTime, 1000);
    </script>
</body>
</html>
EOF
    
    # 创建404错误页面
    cat > $WEB_ROOT/404.html <<EOF
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>404 - 页面未找到</title>
    <style>
        body {
            font-family: 'Arial', sans-serif;
            margin: 0;
            padding: 0;
            background: #f8f9fa;
            color: #333;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
        }
        .container {
            text-align: center;
            max-width: 500px;
            padding: 2rem;
        }
        h1 {
            font-size: 6rem;
            margin: 0;
            color: #dc3545;
        }
        h2 {
            font-size: 2rem;
            margin: 1rem 0;
        }
        p {
            font-size: 1.1rem;
            margin-bottom: 2rem;
            color: #666;
        }
        a {
            color: #007bff;
            text-decoration: none;
            font-weight: bold;
        }
        a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>404</h1>
        <h2>页面未找到</h2>
        <p>抱歉，您访问的页面不存在。</p>
        <p><a href="/">返回首页</a></p>
    </div>
</body>
</html>
EOF
    
    # 创建50x错误页面
    cat > $WEB_ROOT/50x.html <<EOF
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>服务器错误</title>
    <style>
        body {
            font-family: 'Arial', sans-serif;
            margin: 0;
            padding: 0;
            background: #f8f9fa;
            color: #333;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
        }
        .container {
            text-align: center;
            max-width: 500px;
            padding: 2rem;
        }
        h1 {
            font-size: 4rem;
            margin: 0;
            color: #dc3545;
        }
        h2 {
            font-size: 2rem;
            margin: 1rem 0;
        }
        p {
            font-size: 1.1rem;
            margin-bottom: 2rem;
            color: #666;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>5xx</h1>
        <h2>服务器内部错误</h2>
        <p>服务器遇到了一个错误，无法完成您的请求。</p>
        <p>请稍后再试。</p>
    </div>
</body>
</html>
EOF
    
    # 设置正确的文件权限
    chown -R $NGINX_USER:$NGINX_GROUP $WEB_ROOT
    chown -R $NGINX_USER:$NGINX_GROUP $NGINX_LOG_DIR
    chmod -R 755 $WEB_ROOT
    
    # 启动Nginx服务
    systemctl start nginx
    systemctl enable nginx
    
    # 验证Nginx服务状态
    if systemctl is-active --quiet nginx; then
        log_info "Nginx服务启动成功"
    else
        log_error "Nginx服务启动失败"
        exit 1
    fi
    
    log_info "Nginx配置完成"
}

# 配置防火墙
configure_firewall() {
    log_step "配置防火墙规则..."
    
    if [ "$OS" = "centos" ]; then
        # CentOS/RHEL防火墙配置
        if systemctl is-active --quiet firewalld; then
            firewall-cmd --permanent --add-service=http
            firewall-cmd --permanent --add-service=https
            firewall-cmd --permanent --add-port=$NGINX_PORT/tcp
            firewall-cmd --permanent --add-port=$NGINX_SSL_PORT/tcp
            firewall-cmd --reload
            log_info "防火墙规则已添加 (firewalld)"
        elif command -v iptables >/dev/null; then
            iptables -I INPUT -p tcp --dport $NGINX_PORT -j ACCEPT
            iptables -I INPUT -p tcp --dport $NGINX_SSL_PORT -j ACCEPT
            service iptables save 2>/dev/null || true
            log_info "防火墙规则已添加 (iptables)"
        fi
    else
        # Ubuntu/Debian防火墙配置
        if command -v ufw >/dev/null; then
            ufw allow $NGINX_PORT/tcp
            ufw allow $NGINX_SSL_PORT/tcp
            # 注意：某些系统可能没有预定义的'Nginx Full'配置文件
            ufw allow 'Nginx Full' 2>/dev/null || true
            log_info "防火墙规则已添加 (ufw)"
        elif command -v iptables >/dev/null; then
            iptables -I INPUT -p tcp --dport $NGINX_PORT -j ACCEPT
            iptables -I INPUT -p tcp --dport $NGINX_SSL_PORT -j ACCEPT
            iptables-save > /etc/iptables/rules.v4 2>/dev/null || true
            log_info "防火墙规则已添加 (iptables)"
        fi
    fi
}

# 创建SSL证书目录和自签名证书
setup_ssl() {
    log_step "设置SSL证书..."
    
    # 创建SSL证书目录
    mkdir -p $NGINX_HOME/ssl
    
    # 生成自签名SSL证书（仅用于测试）
    if [ ! -f $NGINX_HOME/ssl/nginx.crt ]; then
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
            -keyout $NGINX_HOME/ssl/nginx.key \
            -out $NGINX_HOME/ssl/nginx.crt \
            -subj "/C=CN/ST=Beijing/L=Beijing/O=Test/OU=IT/CN=localhost"
        
        chmod 600 $NGINX_HOME/ssl/nginx.key
        chmod 644 $NGINX_HOME/ssl/nginx.crt
        
        log_info "自签名SSL证书已生成"
    fi
    
    # 创建SSL配置示例
    cat > $NGINX_HOME/conf.d/ssl-example.conf.disabled <<EOF
# SSL配置示例 - 重命名为.conf启用
server {
    listen $NGINX_SSL_PORT ssl http2;
    listen [::]:$NGINX_SSL_PORT ssl http2;
    server_name your-domain.com;
    
    # SSL证书配置
    ssl_certificate $NGINX_HOME/ssl/nginx.crt;
    ssl_certificate_key $NGINX_HOME/ssl/nginx.key;
    
    # SSL安全配置
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    
    # HSTS
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    
    root $WEB_ROOT;
    index index.html index.htm;
    
    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF
}

# 验证安装
verify_installation() {
    log_step "验证Nginx安装结果..."
    
    echo "==================== Nginx安装验证 ===================="
    
    # 验证Nginx服务状态
    echo "Nginx服务状态:"
    systemctl status nginx --no-pager -l
    echo ""
    
    # 验证Nginx版本
    echo "Nginx版本:"
    nginx -v
    echo ""
    
    # 验证配置文件语法
    echo "配置文件语法检查:"
    nginx -t
    echo ""
    
    # 验证监听端口
    echo "监听端口:"
    netstat -tlnp | grep nginx || ss -tlnp | grep nginx
    echo ""
    
    # 测试HTTP响应
    echo "HTTP响应测试:"
    curl -s -o /dev/null -w "HTTP状态码: %{http_code}\n" http://localhost:$NGINX_PORT/ || echo "HTTP测试失败"
    echo ""
    
    log_info "Nginx安装验证完成"
}

# 显示安装信息
show_info() {
    echo ""
    echo "==================== Nginx安装完成 ===================="
    log_info "Nginx Web服务器安装完成！"
    echo ""
    echo "Nginx信息:"
    echo "  版本: $(nginx -v 2>&1 | awk '{print $3}' | cut -d'/' -f2)"
    echo "  服务状态: $(systemctl is-active nginx)"
    echo "  配置文件: $NGINX_HOME/nginx.conf"
    echo "  网站根目录: $WEB_ROOT"
    echo "  日志目录: $NGINX_LOG_DIR"
    echo "  SSL证书目录: $NGINX_HOME/ssl"
    echo ""
    echo "访问信息:"
    echo "  HTTP端口: $NGINX_PORT"
    echo "  HTTPS端口: $NGINX_SSL_PORT"
    echo "  本地访问: http://localhost:$NGINX_PORT"
    echo "  服务器IP: $(hostname -I | awk '{print $1}')"
    echo "  外部访问: http://$(hostname -I | awk '{print $1}'):$NGINX_PORT"
    echo ""
    echo "常用命令:"
    echo "  启动服务: systemctl start nginx"
    echo "  停止服务: systemctl stop nginx"
    echo "  重启服务: systemctl restart nginx"
    echo "  重载配置: systemctl reload nginx"
    echo "  查看状态: systemctl status nginx"
    echo "  测试配置: nginx -t"
    echo "  查看版本: nginx -v"
    echo ""
    echo "配置文件:"
    echo "  主配置: $NGINX_HOME/nginx.conf"
    echo "  站点配置: $NGINX_HOME/conf.d/"
    echo "  访问日志: $NGINX_LOG_DIR/access.log"
    echo "  错误日志: $NGINX_LOG_DIR/error.log"
    echo ""
    echo "SSL配置:"
    echo "  证书文件: $NGINX_HOME/ssl/nginx.crt"
    echo "  私钥文件: $NGINX_HOME/ssl/nginx.key"
    echo "  SSL示例: $NGINX_HOME/conf.d/ssl-example.conf.disabled"
    echo ""
    echo "网站文件:"
    echo "  网站根目录: $WEB_ROOT"
    echo "  默认首页: $WEB_ROOT/index.html"
    echo "  404页面: $WEB_ROOT/404.html"
    echo "  50x页面: $WEB_ROOT/50x.html"
    echo ""
    echo "性能优化:"
    echo "  已启用Gzip压缩"
    echo "  已配置静态文件缓存"
    echo "  已优化worker进程数"
    echo "  已配置安全头部"
    echo ""
    echo "注意事项:"
    echo "  1. 默认生成的SSL证书为自签名证书，仅用于测试"
    echo "  2. 生产环境请使用正式的SSL证书"
    echo "  3. 请根据实际需求调整配置文件"
    echo "  4. 建议定期更新Nginx版本"
    echo ""
    echo "================================================="
}

# 主函数
main() {
    log_info "开始安装Nginx Web服务器..."
    
    # 检查是否为root用户
    if [ "$EUID" -ne 0 ]; then
        log_error "请使用root用户运行此脚本"
        exit 1
    fi
    
    # 执行安装步骤
    detect_os
    update_system
    install_nginx
    configure_nginx
    configure_firewall
    setup_ssl
    verify_installation
    show_info
    
    log_info "Nginx安装脚本执行完成！"
}

# 执行主函数
main "$@"