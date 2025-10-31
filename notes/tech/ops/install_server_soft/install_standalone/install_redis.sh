#!/bin/bash

# Redis缓存服务安装脚本
# 安装Redis 7.x
# 支持CentOS/RHEL和Ubuntu/Debian系统
# 再你自己的电脑上执行： ssh root@14.103.191.82 'bash -s' < ./scripts/other/install_redis.sh
# 安装完成后验证： redis-cli -h 14.103.191.82 -p 6379 -a "123456" ping 

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Redis配置
REDIS_PORT=6379
REDIS_PASSWORD="123456"
REDIS_CONFIG_DIR="/etc/redis"
REDIS_DATA_DIR="/var/lib/redis"
REDIS_LOG_DIR="/var/log/redis"
REDIS_USER="redis"

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

# 安装Redis
install_redis() {
    log_step "检查Redis服务状态..."
    
    # 检查Redis是否已安装并运行
    if systemctl is-active --quiet redis 2>/dev/null || systemctl is-active --quiet redis-server 2>/dev/null; then
        log_info "Redis服务已在运行，跳过安装"
        return 0
    fi
    
    log_step "安装Redis缓存服务..."
    
    if [ "$OS" = "centos" ]; then
        # CentOS/RHEL安装Redis
        # 启用EPEL仓库
        yum install -y epel-release
        
        # 安装Redis
        yum install -y redis
        
        # 创建Redis用户（如果不存在）
        if ! id "$REDIS_USER" &>/dev/null; then
            useradd -r -s /bin/false $REDIS_USER
        fi
        
    else
        # Ubuntu/Debian安装Redis
        apt install -y redis-server
    fi
    
    log_info "Redis安装完成"
}

# 配置Redis
configure_redis() {
    log_step "配置Redis服务..."
    
    # 创建必要的目录
    mkdir -p $REDIS_DATA_DIR
    mkdir -p $REDIS_LOG_DIR
    
    # 设置目录权限
    chown -R $REDIS_USER:$REDIS_USER $REDIS_DATA_DIR
    chown -R $REDIS_USER:$REDIS_USER $REDIS_LOG_DIR
    
    # 确定配置文件路径
    if [ "$OS" = "centos" ]; then
        REDIS_CONFIG_FILE="/etc/redis.conf"
    else
        REDIS_CONFIG_FILE="/etc/redis/redis.conf"
    fi
    
    # 备份原配置文件
    if [ -f "$REDIS_CONFIG_FILE" ]; then
        cp "$REDIS_CONFIG_FILE" "$REDIS_CONFIG_FILE.backup"
        log_info "已备份原配置文件到 $REDIS_CONFIG_FILE.backup"
    fi
    
    # 使用Redis自带配置文件，只修改必要的配置项
    log_info "使用Redis自带配置文件，仅修改必要配置项..."
    
    # 修改bind配置以允许远程连接
    if grep -q "^bind" "$REDIS_CONFIG_FILE"; then
        sed -i 's/^bind.*/bind 0.0.0.0/' "$REDIS_CONFIG_FILE"
    else
        echo "bind 0.0.0.0" >> "$REDIS_CONFIG_FILE"
    fi
    
    # 设置密码
    if grep -q "^# requirepass" "$REDIS_CONFIG_FILE"; then
        sed -i "s/^# requirepass.*/requirepass $REDIS_PASSWORD/" "$REDIS_CONFIG_FILE"
    elif grep -q "^requirepass" "$REDIS_CONFIG_FILE"; then
        sed -i "s/^requirepass.*/requirepass $REDIS_PASSWORD/" "$REDIS_CONFIG_FILE"
    else
        echo "requirepass $REDIS_PASSWORD" >> "$REDIS_CONFIG_FILE"
    fi
    
    # 设置数据目录
    if grep -q "^dir" "$REDIS_CONFIG_FILE"; then
        sed -i "s|^dir.*|dir $REDIS_DATA_DIR|" "$REDIS_CONFIG_FILE"
    else
        echo "dir $REDIS_DATA_DIR" >> "$REDIS_CONFIG_FILE"
    fi
    
    # 设置日志文件
    if grep -q "^logfile" "$REDIS_CONFIG_FILE"; then
        sed -i "s|^logfile.*|logfile $REDIS_LOG_DIR/redis-server.log|" "$REDIS_CONFIG_FILE"
    else
        echo "logfile $REDIS_LOG_DIR/redis-server.log" >> "$REDIS_CONFIG_FILE"
    fi
    
    log_info "Redis配置文件修改完成，保留了大部分默认配置"
    
    # 创建systemd服务文件（如果需要）
    if [ "$OS" = "centos" ]; then
        # 创建Redis systemd服务文件
        cat > /etc/systemd/system/redis.service <<EOF
[Unit]
Description=Advanced key-value store
After=network.target
Documentation=http://redis.io/documentation, man:redis-server(1)

[Service]
Type=notify
ExecStart=/usr/bin/redis-server $REDIS_CONFIG_FILE
ExecStop=/bin/kill -s QUIT \$MAINPID
TimeoutStopSec=0
Restart=always
User=$REDIS_USER
Group=$REDIS_USER
RuntimeDirectory=redis
RuntimeDirectoryMode=0755

[Install]
WantedBy=multi-user.target
EOF
    fi
    
    # 创建运行时目录
    mkdir -p /var/run/redis
    chown $REDIS_USER:$REDIS_USER /var/run/redis
    
    # 重新加载systemd配置
    systemctl daemon-reload
    
    # 启动Redis服务
    if [ "$OS" = "centos" ]; then
        systemctl start redis
        systemctl enable redis
    else
        systemctl start redis-server
        systemctl enable redis-server
    fi
    
    log_info "Redis配置完成"
}

# 配置防火墙
configure_firewall() {
    log_step "配置防火墙规则..."
    
    if [ "$OS" = "centos" ]; then
        # CentOS使用firewalld
        if systemctl is-active --quiet firewalld; then
            firewall-cmd --permanent --add-port=$REDIS_PORT/tcp
            firewall-cmd --reload
            log_info "防火墙规则已添加 (端口: $REDIS_PORT)"
        else
            log_warn "firewalld未运行，跳过防火墙配置"
        fi
    else
        # Ubuntu使用ufw
        if command -v ufw >/dev/null 2>&1; then
            ufw allow $REDIS_PORT/tcp
            log_info "防火墙规则已添加 (端口: $REDIS_PORT)"
        else
            log_warn "ufw未安装，跳过防火墙配置"
        fi
    fi
}

# 验证安装
verify_installation() {
    # 检查Redis服务是否运行
    if [ "$OS" = "centos" ]; then
        systemctl restart redis
    else
        systemctl restart redis-server
    fi

    log_step "验证Redis安装结果..."
    
    echo "==================== Redis安装验证 ===================="
    
    # 验证Redis服务状态
    echo "Redis服务状态:"
    if [ "$OS" = "centos" ]; then
        systemctl status redis --no-pager -l
    else
        systemctl status redis-server --no-pager -l
    fi
    echo ""
    
    # 验证Redis版本
    echo "Redis版本:"
    redis-server --version
    echo ""
    
    # 验证Redis连接
    echo "Redis连接测试:"
    redis-cli -a "$REDIS_PASSWORD" ping
    echo ""
    
    # 验证Redis信息
    echo "Redis服务器信息:"
    redis-cli -a "$REDIS_PASSWORD" info server | head -10
    echo ""
    
    log_info "Redis安装验证完成"
}

# 显示安装信息
show_info() {
    echo ""
    echo "==================== Redis安装完成 ===================="
    log_info "Redis缓存服务安装完成！"
    echo ""
    echo "Redis信息:"
    echo "  版本: Redis 7.x"
    echo "  端口: $REDIS_PORT"
    echo "  密码: $REDIS_PASSWORD"
    echo "  服务状态: $(systemctl is-active redis 2>/dev/null || systemctl is-active redis-server 2>/dev/null)"
    echo ""
    echo "配置文件:"
    echo "  配置文件: $REDIS_CONFIG_FILE"
    echo "  数据目录: $REDIS_DATA_DIR"
    echo "  日志目录: $REDIS_LOG_DIR"
    echo "  日志文件: $REDIS_LOG_DIR/redis-server.log"
    echo ""
    echo "连接信息:"
    echo "  本地连接: redis-cli -a $REDIS_PASSWORD"
    echo "  远程连接: redis-cli -h <服务器IP> -p $REDIS_PORT -a $REDIS_PASSWORD"
    echo ""
    echo "常用命令:"
    echo "  启动服务: systemctl start $([ "$OS" = "centos" ] && echo "redis" || echo "redis-server")"
    echo "  停止服务: systemctl stop $([ "$OS" = "centos" ] && echo "redis" || echo "redis-server")"
    echo "  重启服务: systemctl restart $([ "$OS" = "centos" ] && echo "redis" || echo "redis-server")"
    echo "  查看状态: systemctl status $([ "$OS" = "centos" ] && echo "redis" || echo "redis-server")"
    echo "  查看日志: tail -f $REDIS_LOG_DIR/redis-server.log"
    echo ""
    echo "Redis命令示例:"
    echo "  连接Redis: redis-cli -a $REDIS_PASSWORD"
    echo "  测试连接: redis-cli -a $REDIS_PASSWORD ping"
    echo "  查看信息: redis-cli -a $REDIS_PASSWORD info"
    echo "  设置键值: redis-cli -a $REDIS_PASSWORD set key value"
    echo "  获取键值: redis-cli -a $REDIS_PASSWORD get key"
    echo ""
    echo "注意事项:"
    echo "  1. 请妥善保管Redis密码"
    echo "  2. 生产环境建议修改默认密码"
    echo "  3. 防火墙已开放端口$REDIS_PORT"
    echo "  4. 使用Redis自带默认配置，仅修改了必要配置项"
    echo "  5. 已配置远程连接支持和密码认证"
    echo "  6. 原配置文件已备份为 .backup 后缀"
    echo ""
    echo "================================================="
}

# 主函数
main() {
    log_info "开始安装Redis缓存服务..."
    
    # 检查是否为root用户
    if [ "$EUID" -ne 0 ]; then
        log_error "请使用root用户运行此脚本"
        exit 1
    fi
    
    # 执行安装步骤
    detect_os
    update_system
    install_redis
    configure_redis
    configure_firewall
    verify_installation
    show_info
    
    log_info "Redis安装脚本执行完成！"
}

# 执行主函数
main "$@"