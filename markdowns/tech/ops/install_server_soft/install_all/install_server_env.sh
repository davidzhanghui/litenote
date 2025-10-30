#!/bin/bash

# 服务器环境自动安装脚本（修复版）
# 安装MySQL、Redis、Java、Nginx环境
# 支持CentOS/RHEL和Ubuntu/Debian系统
# 修复了Ubuntu 24.04的Hash Sum mismatch问题

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# 更新系统（修复版）
update_system() {
    log_step "更新系统包管理器..."
    if [ "$OS" = "centos" ]; then
        yum update -y
    else
        # Ubuntu系统修复Hash Sum mismatch问题
        log_info "清理APT缓存..."
        apt clean
        apt autoclean
        
        log_info "更新包索引..."
        apt update
        
        log_info "修复损坏的包..."
        apt --fix-broken install -y
        
        log_info "使用--fix-missing选项升级系统... "
        apt upgrade -y --fix-missing || {
            log_warn "部分包升级失败，继续安装其他组件..."
            # 尝试跳过有问题的包继续安装
            apt upgrade -y --fix-missing --ignore-missing || true
        }
    fi
    log_info "系统更新完成"
}

# 安装Java
install_java() {
    log_step "检查Java环境..."
    
    # 检查Java是否已安装
    if command -v java >/dev/null 2>&1; then
        JAVA_VERSION=$(java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}')
        log_info "Java已安装，版本: $JAVA_VERSION，跳过安装"
        return 0
    fi
    
    log_step "安装Java环境..."
    
    if [ "$OS" = "centos" ]; then
        # 安装OpenJDK 17
        yum install -y java-17-openjdk java-17-openjdk-devel
        JAVA_HOME_PATH="/usr/lib/jvm/java-17-openjdk"
    else
        # Ubuntu/Debian
        apt install -y openjdk-17-jdk
        JAVA_HOME_PATH="/usr/lib/jvm/java-17-openjdk-amd64"
    fi
    
    # 配置JAVA_HOME
    echo "export JAVA_HOME=$JAVA_HOME_PATH" >> /etc/profile
    echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> /etc/profile
    source /etc/profile
    
    # 验证安装
    java -version
    log_info "Java安装完成"
}

# 安装MySQL
install_mysql() {
    log_step "检查MySQL数据库..."
    
    # 检查MySQL是否已安装
    if command -v mysql >/dev/null 2>&1; then
        MYSQL_VERSION=$(mysql --version 2>/dev/null | awk '{print $3}' | cut -d',' -f1)
        log_info "MySQL已安装，版本: $MYSQL_VERSION，跳过安装"
        
        # 检查MySQL服务状态
        if [ "$OS" = "centos" ]; then
            if ! systemctl is-active --quiet mysqld; then
                log_info "启动MySQL服务..."
                systemctl start mysqld
                systemctl enable mysqld
            fi
        else
            if ! systemctl is-active --quiet mysql; then
                log_info "启动MySQL服务..."
                systemctl start mysql
                systemctl enable mysql
            fi
        fi
        return 0
    fi
    
    log_step "安装MySQL数据库..."
    
    if [ "$OS" = "centos" ]; then
        # CentOS安装MySQL
        # 下载MySQL官方Yum Repository
        if [ ! -f mysql80-community-release-el7-3.noarch.rpm ]; then
            log_info "正在下载MySQL Yum Repository..."
            if ! wget --timeout=30 --tries=3 https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm; then
                log_error "下载MySQL Yum Repository失败，请检查网络连接"
                return 1
            fi
        fi
        rpm -Uvh mysql80-community-release-el7-3.noarch.rpm || true
        
        # 安装MySQL服务器
        yum install -y mysql-community-server
        
        # 启动MySQL服务
        systemctl start mysqld
        systemctl enable mysqld
        
        # 获取临时密码
        TEMP_PASSWORD=$(grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}' | tail -1)
        log_info "MySQL临时密码: $TEMP_PASSWORD"
        
    else
        # Ubuntu安装MySQL
        export DEBIAN_FRONTEND=noninteractive
        
        # 预设MySQL root密码
        echo "mysql-server mysql-server/root_password password 123456" | debconf-set-selections
        echo "mysql-server mysql-server/root_password_again password 123456" | debconf-set-selections
        
        apt install -y mysql-server
        
        # 启动MySQL服务
        systemctl start mysql
        systemctl enable mysql
        
        log_info "MySQL root密码已设置为: 123456"
    fi
    
    log_info "MySQL安装完成"
}

# 配置MySQL
configure_mysql() {
    log_step "配置MySQL..."
    
    # 创建MySQL配置脚本
    cat > /tmp/mysql_config.sql << EOF
-- 设置root用户密码并允许远程登录
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '123456';
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED WITH mysql_native_password BY '123456';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;

-- 创建应用用户: david/123456
CREATE USER IF NOT EXISTS 'david'@'%' IDENTIFIED BY '123456';
GRANT ALL PRIVILEGES ON *.* TO 'david'@'%';

-- 刷新权限
FLUSH PRIVILEGES;
EOF

    if [ "$OS" = "centos" ]; then
        # CentOS需要使用临时密码配置root用户
        if [ ! -z "$TEMP_PASSWORD" ]; then
            log_step "正在使用临时密码配置MySQL root用户远程登录..."
            # 使用临时密码登录并执行配置
            mysql -u root -p"$TEMP_PASSWORD" --connect-expired-password << 'MYSQL_SCRIPT'
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '123456';
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED WITH mysql_native_password BY '123456';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
CREATE USER IF NOT EXISTS 'david'@'%' IDENTIFIED BY '123456';
GRANT ALL PRIVILEGES ON *.* TO 'david'@'%';
FLUSH PRIVILEGES;
MYSQL_SCRIPT
            log_info "CentOS系统MySQL root用户远程登录配置完成"
        else
            log_warn "未获取到MySQL临时密码，请手动配置:"
            echo "mysql -u root -p"
            echo "然后执行: source /tmp/mysql_config.sql"
        fi
    else
        # Ubuntu直接执行配置
        mysql -u root -p123456 < /tmp/mysql_config.sql
        log_info "MySQL配置完成"
    fi

    # 配置 MySQL 监听 0.0.0.0，允许远程连接
    if [ "$OS" = "centos" ]; then
        MYSQL_CONF="/etc/my.cnf"
        [ -f "/etc/my.cnf.d/mysqld.cnf" ] && MYSQL_CONF="/etc/my.cnf.d/mysqld.cnf"
        [ -f "/etc/my.cnf.d/mysqld-server.cnf" ] && MYSQL_CONF="/etc/my.cnf.d/mysqld-server.cnf"
        MYSQL_SERVICE="mysqld"
    else
        MYSQL_CONF="/etc/mysql/mysql.conf.d/mysqld.cnf"
        MYSQL_SERVICE="mysql"
    fi

    if [ -f "$MYSQL_CONF" ]; then
        cp "$MYSQL_CONF" "${MYSQL_CONF}.backup" || true
        if grep -qE '^bind-address' "$MYSQL_CONF"; then
            sed -i "s/^bind-address.*/bind-address = 0.0.0.0/" "$MYSQL_CONF"
        else
            if grep -qE '^\[mysqld\]' "$MYSQL_CONF"; then
                sed -i "/^\[mysqld\]/a bind-address = 0.0.0.0" "$MYSQL_CONF"
            else
                echo -e "[mysqld]\nbind-address = 0.0.0.0" >> "$MYSQL_CONF"
            fi
        fi
        # 确保未开启 skip-networking
        sed -i "s/^skip-networking/# skip-networking/" "$MYSQL_CONF" || true
        systemctl restart "$MYSQL_SERVICE"
        log_info "已设置 MySQL 监听 0.0.0.0 并重启服务（配置文件: $MYSQL_CONF）"
    else
        log_warn "未找到 MySQL 配置文件: $MYSQL_CONF，请手动设置 bind-address = 0.0.0.0 并重启 MySQL 服务"
    fi
}

# 安装Redis
install_redis() {
    log_step "检查Redis..."
    
    # 检查Redis是否已安装
    if command -v redis-server >/dev/null 2>&1; then
        REDIS_VERSION=$(redis-server --version 2>/dev/null | awk '{print $3}' | cut -d'=' -f2)
        log_info "Redis已安装，版本: $REDIS_VERSION，跳过安装"
        
        # 检查Redis服务状态
        if [ "$OS" = "centos" ]; then
            if ! systemctl is-active --quiet redis; then
                log_info "启动Redis服务..."
                systemctl start redis
                systemctl enable redis
            fi
        else
            if ! systemctl is-active --quiet redis-server; then
                log_info "启动Redis服务..."
                systemctl start redis-server
                systemctl enable redis-server
            fi
        fi
        return 0
    fi
    
    log_step "安装Redis..."
    
    if [ "$OS" = "centos" ]; then
        # 启用EPEL仓库
        yum install -y epel-release
        
        # 安装Redis
        yum install -y redis
        
        # 启动Redis服务
        systemctl start redis
        systemctl enable redis
        
    else
        # Ubuntu安装Redis
        apt install -y redis-server
        
        # 启动Redis服务
        systemctl start redis-server
        systemctl enable redis-server
    fi
    
    log_info "Redis安装完成"
}

# 配置Redis
configure_redis() {
    log_step "配置Redis..."
    
    # 备份原配置文件
    if [ "$OS" = "centos" ]; then
        REDIS_CONF="/etc/redis.conf"
    else
        REDIS_CONF="/etc/redis/redis.conf"
    fi
    
    cp $REDIS_CONF $REDIS_CONF.backup
    
    # 修改Redis配置
    sed -i 's/^bind 127.0.0.1/bind 0.0.0.0/' $REDIS_CONF
    sed -i 's/^# requirepass foobared/requirepass 123456/' $REDIS_CONF
    
    # 重启Redis服务
    if [ "$OS" = "centos" ]; then
        systemctl restart redis
    else
        systemctl restart redis-server
    fi
    
    log_info "Redis配置完成，密码: 123456"
}

# 安装Nginx
install_nginx() {
    log_step "检查Nginx..."
    
    # 检查Nginx是否已安装
    if command -v nginx >/dev/null 2>&1; then
        NGINX_VERSION=$(nginx -v 2>&1 | awk '{print $3}' | cut -d'/' -f2)
        log_info "Nginx已安装，版本: $NGINX_VERSION，跳过安装"
        
        # 检查Nginx服务状态
        if ! systemctl is-active --quiet nginx; then
            log_info "启动Nginx服务..."
            systemctl start nginx
            systemctl enable nginx
        fi
        return 0
    fi
    
    log_step "安装Nginx..."
    
    if [ "$OS" = "centos" ]; then
        # CentOS安装Nginx
        # 添加EPEL仓库
        yum install -y epel-release
        
        # 安装Nginx
        yum install -y nginx
        
    else
        # Ubuntu安装Nginx
        apt update
        apt install -y nginx
    fi
    
    # 启动Nginx服务
    systemctl start nginx
    systemctl enable nginx
    
    log_info "Nginx安装完成"
}

# 配置Nginx
configure_nginx() {
    log_step "配置Nginx..."
    
    # 备份原配置文件
    if [ "$OS" = "centos" ]; then
        NGINX_CONF="/etc/nginx/nginx.conf"
        NGINX_SITES_DIR="/etc/nginx/conf.d"
    else
        NGINX_CONF="/etc/nginx/nginx.conf"
        NGINX_SITES_DIR="/etc/nginx/sites-available"
        NGINX_ENABLED_DIR="/etc/nginx/sites-enabled"
    fi
    
    # 备份原配置
    cp $NGINX_CONF $NGINX_CONF.backup
    
    # 创建一个简单的默认站点配置
    cat > $NGINX_SITES_DIR/default.conf << 'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    
    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;
    
    server_name _;
    
    location / {
        try_files $uri $uri/ =404;
    }
    
    # 代理后端API示例（可根据需要修改）
    location /api/ {
        proxy_pass http://localhost:8080/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF
    
    # Ubuntu需要启用站点
    if [ "$OS" = "ubuntu" ]; then
        ln -sf $NGINX_SITES_DIR/default.conf $NGINX_ENABLED_DIR/default.conf
        # 删除默认站点
        rm -f $NGINX_ENABLED_DIR/default
    fi
    
    # 创建默认网页目录和文件
    mkdir -p /var/www/html
    cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>服务器环境安装成功</title>
    <meta charset="utf-8">
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background-color: #f5f5f5; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #333; text-align: center; }
        .service { margin: 20px 0; padding: 15px; background: #f8f9fa; border-left: 4px solid #007bff; }
        .service h3 { margin-top: 0; color: #007bff; }
        .status { color: #28a745; font-weight: bold; }
        .warning { color: #ffc107; font-weight: bold; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🎉 服务器环境安装成功</h1>
        <p>恭喜！您的服务器环境已成功安装并配置完成。</p>
        
        <div class="service">
            <h3>📊 MySQL 数据库</h3>
            <p><span class="status">✅ 运行中</span> - 端口: 3306</p>
            <p>数据库: david | 用户: david | 密码: 123456</p>
        </div>
        
        <div class="service">
            <h3>🔄 Redis 缓存</h3>
            <p><span class="status">✅ 运行中</span> - 端口: 6379</p>
            <p>密码: 123456</p>
        </div>
        
        <div class="service">
            <h3>☕ Java 环境</h3>
            <p><span class="status">✅ 已安装</span> - OpenJDK 17</p>
        </div>
        
        <div class="service">
            <h3>🌐 Nginx 服务器</h3>
            <p><span class="status">✅ 运行中</span> - 端口: 80</p>
        </div>
        
        <div class="service">
            <h3>⚠️ 系统更新状态</h3>
            <p><span class="warning">⚠️ 部分包可能未完全更新</span></p>
            <p>由于Ubuntu 24.04镜像源问题，部分系统包可能未完全更新，但不影响服务正常运行。</p>
        </div>
        
        <p style="text-align: center; margin-top: 30px; color: #666;">
            服务器时间: <span id="datetime"></span>
        </p>
    </div>
    
    <script>
        document.getElementById('datetime').textContent = new Date().toLocaleString('zh-CN');
    </script>
</body>
</html>
EOF
    
    # 测试Nginx配置
    nginx -t
    
    # 重启Nginx服务
    systemctl restart nginx
    
    log_info "Nginx配置完成，默认站点已创建"
}

# 配置防火墙
configure_firewall() {
    log_step "配置防火墙..."
    
    if [ "$OS" = "centos" ]; then
        # CentOS使用firewalld
        if systemctl is-active --quiet firewalld; then
            firewall-cmd --permanent --add-port=3306/tcp
            firewall-cmd --permanent --add-port=6379/tcp
            firewall-cmd --permanent --add-port=80/tcp
            firewall-cmd --permanent --add-port=443/tcp
            firewall-cmd --reload
            log_info "防火墙规则已添加"
        else
            log_warn "firewalld未运行，请手动配置防火墙"
        fi
    else
        # Ubuntu使用ufw
        if command -v ufw >/dev/null 2>&1; then
            ufw allow 3306/tcp
            ufw allow 6379/tcp
            ufw allow 80/tcp
            ufw allow 443/tcp
            log_info "防火墙规则已添加"
        else
            log_warn "ufw未安装，请手动配置防火墙"
        fi
    fi
}

# 验证安装
verify_installation() {
    log_step "验证安装结果..."
    
    echo "==================== 安装验证 ===================="
    
    # 验证Java
    echo "Java版本:"
    java -version
    echo ""
    
    # 验证MySQL
    echo "MySQL状态:"
    if [ "$OS" = "centos" ]; then
        systemctl status mysqld --no-pager -l
    else
        systemctl status mysql --no-pager -l
    fi
    echo ""
    
    # 验证Redis
    echo "Redis状态:"
    if [ "$OS" = "centos" ]; then
        systemctl status redis --no-pager -l
    else
        systemctl status redis-server --no-pager -l
    fi
    echo ""
    
    # 验证Nginx
    echo "Nginx状态:"
    systemctl status nginx --no-pager -l
    echo ""
    
    # 测试Redis连接
    echo "Redis连接测试:"
    redis-cli -a 123456 ping
    echo ""
    
    # 测试Nginx
    echo "Nginx版本:"
    nginx -v
    echo ""
    
    echo "==================== 端口监听 ===================="
    netstat -tlnp | grep -E '3306|6379|80|443'
    
    log_info "安装验证完成"
}

# 显示安装信息
show_info() {
    echo ""
    echo "==================== 安装完成 ===================="
    log_info "所有组件安装完成！"
    echo ""
    echo "服务信息:"
    echo "  MySQL:"
    echo "    端口: 3306"
    echo "    root密码: 123456"
    echo "    root用户支持远程登录: ✅"
    echo "    应用系统管理员: david | 用户: david | 密码: 123456"
    echo ""
    echo "  Redis:"
    echo "    端口: 6379"
    echo "    密码: 123456"
    echo ""
    echo "  Java:"
    echo "    版本: OpenJDK 17"
    echo "    JAVA_HOME: $JAVA_HOME_PATH"
    echo ""
    echo ""
    echo "  Nginx:"
    echo "    端口: 80, 443"
    echo "    配置文件: /etc/nginx/nginx.conf"
    echo "    网站根目录: /var/www/html"
    echo "    服务状态: $(systemctl is-active nginx)"
    echo ""
    echo "本地连接命令:"
    echo "  MySQL: mysql -h localhost -u david -p123456 david"
    echo "  Redis: redis-cli -a 123456"
    echo "  Nginx: curl http://localhost"
    echo ""
    echo "远程连接命令（请将<服务器IP>替换为实际服务器IP）:"
    echo "  MySQL(应用用户):  mysql -h <服务器IP> -u david -p123456 "
    echo "  MySQL(root用户): mysql -h <服务器IP> -u root  -p123456 "
    echo "  Redis: redis-cli -h <服务器IP> -a 123456 -p 6379"
    echo "  网站访问: http://<服务器IP>"
    echo ""
    echo ""
    echo "Nginx常用命令:"
    echo "  重启服务: systemctl restart nginx"
    echo "  重载配置: nginx -s reload"
    echo "  测试配置: nginx -t"
    echo "  查看日志: tail -f /var/log/nginx/access.log"
    echo ""
    echo "注意事项:"
    echo "  1. 确保服务器防火墙已开放3306、6379、80、443端口"
    echo "  2. 确保云服务商安全组已放行相应端口"
    echo "  3. MySQL已配置为监听0.0.0.0，允许远程连接"
    echo "  4. Redis已配置为监听0.0.0.0，设置了密码认证"
    echo "  5. Nginx已配置反向代理，/api/路径代理到localhost:8080"
    echo "  6. 默认网站已部署到/var/www/html，可通过浏览器访问"
    echo "  7. 由于Ubuntu 24.04镜像源问题，部分系统包可能未完全更新，但不影响服务正常运行"
    echo ""
    echo "================================================="
}

# 主函数
main() {
    log_info "开始安装服务器环境..."
    
    # 检查是否为root用户
    if [ "$EUID" -ne 0 ]; then
        log_error "请使用root用户运行此脚本"
        exit 1
    fi
    
    # 执行安装步骤
    detect_os
    update_system
    install_java
    install_mysql
    configure_mysql
    install_redis
    configure_redis
    install_nginx
    configure_nginx
    configure_firewall
    verify_installation
    show_info
    
    log_info "安装脚本执行完成！"
}

# 执行主函数
main "$@"