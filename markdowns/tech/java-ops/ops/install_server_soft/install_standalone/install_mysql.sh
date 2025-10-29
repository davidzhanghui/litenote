#!/bin/bash

# MySQL数据库安装脚本
# 安装MySQL 8.0
# 支持CentOS/RHEL和Ubuntu/Debian系统
# 在你的本地电脑上一键执行： ssh root@14.103.191.82 'bash -s' < install_mysql.sh
# 安装完成后验证： mysql -h 14.103.191.82 -P 3306 -u root -p


set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# MySQL配置
MYSQL_ROOT_PASSWORD="123456"
MYSQL_PORT=3306

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

# 安装MySQL
install_mysql() {
    log_step "检查MySQL服务状态..."
    
    # 检查MySQL是否已安装并运行
    if systemctl is-active --quiet mysqld 2>/dev/null || systemctl is-active --quiet mysql 2>/dev/null; then
        log_info "MySQL服务已在运行，跳过安装"
        return 0
    fi
    
    log_step "安装MySQL数据库..."
    
    if [ "$OS" = "centos" ]; then
        # CentOS/RHEL安装MySQL
        # 添加MySQL官方仓库
        if ! rpm -qa | grep -q mysql80-community-release; then
            yum install -y https://dev.mysql.com/get/mysql80-community-release-el8-1.noarch.rpm
        fi
        
        # 安装MySQL服务器
        yum install -y mysql-community-server
        
        # 启动MySQL服务
        systemctl start mysqld
        systemctl enable mysqld
        
        # 获取临时密码
        TEMP_PASSWORD=$(grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}' | tail -1)
        
    else
        # Ubuntu/Debian安装MySQL
        # 预设置MySQL root密码
        echo "mysql-server mysql-server/root_password password $MYSQL_ROOT_PASSWORD" | debconf-set-selections
        echo "mysql-server mysql-server/root_password_again password $MYSQL_ROOT_PASSWORD" | debconf-set-selections
        
        # 安装MySQL服务器
        apt install -y mysql-server
        
        # 启动MySQL服务
        systemctl start mysql
        systemctl enable mysql
        
        TEMP_PASSWORD="$MYSQL_ROOT_PASSWORD"
    fi
    
    log_info "MySQL安装完成"
}

# 配置MySQL
configure_mysql() {
    log_step "配置MySQL数据库..."
    
    if [ "$OS" = "centos" ]; then
        # CentOS需要重置root密码
        mysql --connect-expired-password -uroot -p"$TEMP_PASSWORD" <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
FLUSH PRIVILEGES;
EOF
    fi
    
    # 创建数据库和用户
    mysql -uroot -p"$MYSQL_ROOT_PASSWORD" <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$MYSQL_ROOT_PASSWORD';
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED WITH mysql_native_password BY '$MYSQL_ROOT_PASSWORD';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF
    
    # 配置MySQL允许远程连接
    if [ "$OS" = "centos" ]; then
        MYSQL_CONFIG="/etc/my.cnf"
    else
        MYSQL_CONFIG="/etc/mysql/mysql.conf.d/mysqld.cnf"
    fi
    
    # 备份原配置文件
    cp "$MYSQL_CONFIG" "$MYSQL_CONFIG.backup"
    
    # 修改配置文件
    if ! grep -q "bind-address" "$MYSQL_CONFIG"; then
        echo "bind-address = 0.0.0.0" >> "$MYSQL_CONFIG"
    else
        sed -i 's/bind-address.*/bind-address = 0.0.0.0/' "$MYSQL_CONFIG"
    fi
    
    # 重启MySQL服务
    if [ "$OS" = "centos" ]; then
        systemctl restart mysqld
    else
        systemctl restart mysql
    fi
    
    log_info "MySQL配置完成"
}

# 配置防火墙
configure_firewall() {
    log_step "配置防火墙规则..."
    
    if [ "$OS" = "centos" ]; then
        # CentOS使用firewalld
        if systemctl is-active --quiet firewalld; then
            firewall-cmd --permanent --add-port=$MYSQL_PORT/tcp
            firewall-cmd --reload
            log_info "防火墙规则已添加 (端口: $MYSQL_PORT)"
        else
            log_warn "firewalld未运行，跳过防火墙配置"
        fi
    else
        # Ubuntu使用ufw
        if command -v ufw >/dev/null 2>&1; then
            ufw allow $MYSQL_PORT/tcp
            log_info "防火墙规则已添加 (端口: $MYSQL_PORT)"
        else
            log_warn "ufw未安装，跳过防火墙配置"
        fi
    fi
}

# 验证安装
verify_installation() {
    log_step "验证MySQL安装结果..."
    
    echo "==================== MySQL安装验证 ===================="
    
    # 验证MySQL服务状态
    echo "MySQL服务状态:"
    if [ "$OS" = "centos" ]; then
        systemctl status mysqld --no-pager -l
    else
        systemctl status mysql --no-pager -l
    fi
    echo ""
    
    # 验证MySQL版本
    echo "MySQL版本:"
    mysql --version
    echo ""
    
    # 验证数据库连接
    echo "数据库连接测试:"
    mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "SELECT VERSION();"
    echo ""
    
    # 验证数据库和用户
    echo "数据库列表:"
    mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "SHOW DATABASES;"
    echo ""
    
    log_info "MySQL安装验证完成"
}

# 显示安装信息
show_info() {
    echo ""
    echo "==================== MySQL安装完成 ===================="
    log_info "MySQL数据库安装完成！"
    echo ""
    echo "MySQL信息:"
    echo "  版本: MySQL 8.0"
    echo "  端口: $MYSQL_PORT"
    echo "  服务状态: $(systemctl is-active mysqld 2>/dev/null || systemctl is-active mysql 2>/dev/null)"
    echo ""
    echo ""
    echo "用户信息:"
    echo "  Root用户: root"
    echo "  Root密码: $MYSQL_ROOT_PASSWORD"
    echo ""
    echo "连接信息:"
    echo "  本地连接: mysql -u root -p$MYSQL_ROOT_PASSWORD"
    echo "  远程连接: mysql -u root -p$MYSQL_ROOT_PASSWORD -h <服务器IP>"
    echo ""
    echo "配置文件:"
    if [ "$OS" = "centos" ]; then
        echo "  配置文件: /etc/my.cnf"
        echo "  日志文件: /var/log/mysqld.log"
        echo "  数据目录: /var/lib/mysql"
    else
        echo "  配置文件: /etc/mysql/mysql.conf.d/mysqld.cnf"
        echo "  日志文件: /var/log/mysql/error.log"
        echo "  数据目录: /var/lib/mysql"
    fi
    echo ""
    echo "常用命令:"
    echo "  启动服务: systemctl start $([ "$OS" = "centos" ] && echo "mysqld" || echo "mysql")"
    echo "  停止服务: systemctl stop $([ "$OS" = "centos" ] && echo "mysqld" || echo "mysql")"
    echo "  重启服务: systemctl restart $([ "$OS" = "centos" ] && echo "mysqld" || echo "mysql")"
    echo "  查看状态: systemctl status $([ "$OS" = "centos" ] && echo "mysqld" || echo "mysql")"
    echo ""
    echo "注意事项:"
    echo "  1. 请妥善保管数据库密码"
    echo "  2. 生产环境建议修改默认密码"
    echo "  3. 防火墙已开放端口$MYSQL_PORT"
    echo "  4. 已启用远程连接，注意安全设置"
    echo ""
    echo "================================================="
}

# 主函数
main() {
    log_info "开始安装MySQL数据库..."
    
    # 检查是否为root用户
    if [ "$EUID" -ne 0 ]; then
        log_error "请使用root用户运行此脚本"
        exit 1
    fi
    
    # 执行安装步骤
    detect_os
    update_system
    install_mysql
    configure_mysql
    configure_firewall
    verify_installation
    show_info
    
    log_info "MySQL安装脚本执行完成！"
}

# 执行主函数
main "$@"