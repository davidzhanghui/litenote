#!/bin/bash

# Redis集群安装脚本 - 使用yum包管理器
# 支持CentOS/RHEL系统
# 作者: David
# 日期: $(date +%Y-%m-%d)

set -e  # 遇到错误立即退出

# 配置变量
REDIS_PORTS=(7001 7002 7003)
REDIS_PASSWORD="123456"
BASE_DIR="/opt/redis-cluster"
REDIS_USER="redis"
LOG_FILE="/tmp/redis_cluster_install.log"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1" | tee -a "$LOG_FILE"
}

log_warn() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] WARNING:${NC} $1" | tee -a "$LOG_FILE"
}

log_info() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')] INFO:${NC} $1" | tee -a "$LOG_FILE"
}

# 检查是否为root用户
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "此脚本需要root权限运行"
        exit 1
    fi
}

# 检测操作系统
detect_os() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
    elif [[ -f /etc/redhat-release ]]; then
        OS=$(cat /etc/redhat-release | awk '{print $1}')
        VER=$(cat /etc/redhat-release | grep -oE '[0-9]+\.[0-9]+' | head -1)
    else
        log_error "无法检测操作系统"
        exit 1
    fi
    
    log_info "检测到操作系统: $OS $VER"
    
    # 检查是否为CentOS/RHEL/Rocky/AlmaLinux
    if [[ "$OS" != *"CentOS"* ]] && [[ "$OS" != *"Red Hat"* ]] && [[ "$OS" != *"Rocky"* ]] && [[ "$OS" != *"AlmaLinux"* ]]; then
        log_error "此脚本仅支持CentOS/RHEL/Rocky/AlmaLinux系统"
        log_info "如需支持Ubuntu/Debian，请使用apt版本的脚本"
        exit 1
    fi
}

# 安装EPEL仓库
install_epel() {
    log "安装EPEL仓库..."
    
    # 检查系统版本
    if [[ "$VER" == "7"* ]]; then
        yum install -y epel-release
    elif [[ "$VER" == "8"* ]] || [[ "$VER" == "9"* ]]; then
        # CentOS 8/9 或 RHEL 8/9
        if command -v dnf &> /dev/null; then
            dnf install -y epel-release
        else
            yum install -y epel-release
        fi
    else
        log_warn "未知的系统版本，尝试安装EPEL..."
        yum install -y epel-release || dnf install -y epel-release || true
    fi
}

# 更新系统包
update_system() {
    log "更新系统包..."
    
    if command -v dnf &> /dev/null; then
        dnf update -y
        dnf install -y curl wget which
    else
        yum update -y
        yum install -y curl wget which
    fi
}

# 安装Redis
install_redis() {
    log "安装Redis服务器..."
    
    # 检查Redis是否已安装
    if command -v redis-server &> /dev/null; then
        log_warn "Redis已安装，版本: $(redis-server --version)"
        read -p "是否继续安装？这将覆盖现有配置 (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log "用户取消安装"
            exit 0
        fi
    fi
    
    # 安装Redis
    if command -v dnf &> /dev/null; then
        dnf install -y redis
    else
        yum install -y redis
    fi
    
    # 停止默认Redis服务
    systemctl stop redis || true
    systemctl disable redis || true
    
    log "Redis安装完成，版本: $(redis-server --version)"
}

# 创建Redis用户
create_redis_user() {
    if ! id "$REDIS_USER" &>/dev/null; then
        log "创建Redis用户: $REDIS_USER"
        useradd -r -s /bin/false -d /var/lib/redis "$REDIS_USER"
    else
        log_info "Redis用户已存在"
    fi
}

# 创建目录结构
create_directories() {
    log "创建Redis集群目录结构..."
    
    for port in "${REDIS_PORTS[@]}"; do
        mkdir -p "$BASE_DIR/$port/conf"
        mkdir -p "$BASE_DIR/$port/data"
        mkdir -p "$BASE_DIR/$port/logs"
        
        # 设置目录权限
        chown -R "$REDIS_USER:$REDIS_USER" "$BASE_DIR/$port"
        chmod 755 "$BASE_DIR/$port"
        chmod 755 "$BASE_DIR/$port/conf"
        chmod 755 "$BASE_DIR/$port/data"
        chmod 755 "$BASE_DIR/$port/logs"
    done
    
    log "目录结构创建完成"
}

# 生成Redis配置文件
generate_redis_config() {
    log "生成Redis配置文件..."
    
    for port in "${REDIS_PORTS[@]}"; do
        local config_file="$BASE_DIR/$port/conf/redis.conf"
        
        cat > "$config_file" << EOF
# Redis集群配置文件 - 端口 $port

# 基础配置
port $port
bind 0.0.0.0
protected-mode no
requirepass $REDIS_PASSWORD
masterauth $REDIS_PASSWORD

# Systemd支持
supervised systemd
daemonize no

# 数据持久化
dir $BASE_DIR/$port/data
dbfilename dump-$port.rdb
appendonly yes
appendfilename "appendonly-$port.aof"

# 日志配置
logfile $BASE_DIR/$port/logs/redis-$port.log
loglevel notice

# 集群配置
cluster-enabled yes
cluster-config-file $BASE_DIR/$port/conf/nodes-$port.conf
cluster-node-timeout 15000
cluster-announce-ip 0.0.0.0
cluster-announce-port $port
cluster-announce-bus-port 1$port
cluster-require-full-coverage no

# 内存配置
maxmemory 256mb
maxmemory-policy allkeys-lru

# 网络配置
tcp-keepalive 300
timeout 0

# 安全配置
rename-command FLUSHDB ""
rename-command FLUSHALL ""
rename-command DEBUG ""

# 性能配置
tcp-backlog 511
databases 1
save 900 1
save 300 10
save 60 10000
stop-writes-on-bgsave-error yes
rdbcompression yes
rdbchecksum yes
EOF
        
        # 设置配置文件权限
        chown "$REDIS_USER:$REDIS_USER" "$config_file"
        chmod 640 "$config_file"
        
        log_info "生成配置文件: $config_file"
    done
}

# 创建systemd服务文件
create_systemd_services() {
    log "创建systemd服务文件..."
    
    for port in "${REDIS_PORTS[@]}"; do
        local service_file="/etc/systemd/system/redis-cluster-$port.service"
        
        cat > "$service_file" << EOF
[Unit]
Description=Redis Cluster Node $port
After=network.target
Documentation=http://redis.io/documentation

[Service]
Type=notify
TimeoutStartSec=300
ExecStart=/usr/bin/redis-server $BASE_DIR/$port/conf/redis.conf
ExecStop=/bin/kill -s QUIT \$MAINPID
TimeoutStopSec=0
Restart=always
RestartSec=5
User=$REDIS_USER
Group=$REDIS_USER
RuntimeDirectory=redis-cluster-$port
RuntimeDirectoryMode=0755
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
        
        log_info "创建服务文件: $service_file"
    done
    
    # 重新加载systemd
    systemctl daemon-reload
}

# 启动Redis实例
start_redis_instances() {
    log "启动Redis集群实例..."
    
    for port in "${REDIS_PORTS[@]}"; do
        local service_name="redis-cluster-$port"
        
        log_info "启动服务: $service_name"
        systemctl enable "$service_name"
        systemctl start "$service_name"
        
        # 等待服务启动
        sleep 3
        
        # 检查服务状态
        if systemctl is-active --quiet "$service_name"; then
            log_info "✓ $service_name 启动成功"
            
            # 验证Redis连接
            if redis-cli -p "$port" -a "$REDIS_PASSWORD" ping &>/dev/null; then
                log_info "✓ Redis $port 连接测试成功"
            else
                log_error "✗ Redis $port 连接测试失败"
            fi
        else
            log_error "✗ $service_name 启动失败"
            systemctl status "$service_name" --no-pager
            return 1
        fi
    done
}

# 创建Redis集群
create_redis_cluster() {
    log "创建Redis集群..."
    
    # 构建集群节点列表
    local cluster_nodes=""
    for port in "${REDIS_PORTS[@]}"; do
        cluster_nodes="$cluster_nodes 127.0.0.1:$port"
    done
    
    # 等待所有节点准备就绪
    sleep 5
    
    log_info "集群节点: $cluster_nodes"
    
    # 创建集群
    echo "yes" | redis-cli --cluster create $cluster_nodes \
        --cluster-replicas 0 \
        -a "$REDIS_PASSWORD" || {
        log_error "集群创建失败"
        return 1
    }
    
    log "✓ Redis集群创建成功"
}

# 配置防火墙
configure_firewall() {
    log "配置防火墙规则..."
    
    if systemctl is-active --quiet firewalld; then
        for port in "${REDIS_PORTS[@]}"; do
            firewall-cmd --permanent --add-port="$port"/tcp
            firewall-cmd --permanent --add-port="1$port"/tcp
        done
        firewall-cmd --reload
        log_info "firewalld防火墙规则已添加"
    elif command -v iptables &> /dev/null; then
        for port in "${REDIS_PORTS[@]}"; do
            iptables -A INPUT -p tcp --dport "$port" -j ACCEPT
            iptables -A INPUT -p tcp --dport "1$port" -j ACCEPT
        done
        # 保存iptables规则
        if command -v iptables-save &> /dev/null; then
            iptables-save > /etc/sysconfig/iptables 2>/dev/null || true
        fi
        log_info "iptables防火墙规则已添加"
    else
        log_warn "未检测到防火墙管理工具，请手动开放端口: ${REDIS_PORTS[*]} 和 1${REDIS_PORTS[*]}"
    fi
}

# 验证集群状态
verify_cluster() {
    log "验证Redis集群状态..."
    
    # 检查集群信息
    redis-cli -p "${REDIS_PORTS[0]}" -a "$REDIS_PASSWORD" cluster info
    
    echo
    log_info "集群节点信息:"
    redis-cli -p "${REDIS_PORTS[0]}" -a "$REDIS_PASSWORD" cluster nodes
    
    echo
    log "✓ Redis集群验证完成"
}

# 优化系统参数
optimize_system() {
    log "优化系统参数..."
    
    # 设置内存过量分配
    echo 'vm.overcommit_memory = 1' >> /etc/sysctl.conf
    
    # 禁用透明大页
    echo 'echo never > /sys/kernel/mm/transparent_hugepage/enabled' >> /etc/rc.local
    echo 'echo never > /sys/kernel/mm/transparent_hugepage/defrag' >> /etc/rc.local
    chmod +x /etc/rc.local
    
    # 应用设置
    sysctl -p
    
    # 立即应用透明大页设置
    echo never > /sys/kernel/mm/transparent_hugepage/enabled 2>/dev/null || true
    echo never > /sys/kernel/mm/transparent_hugepage/defrag 2>/dev/null || true
    
    log_info "系统参数优化完成"
}

# 配置SELinux
configure_selinux() {
    log "配置SELinux..."
    
    if command -v getenforce &> /dev/null; then
        local selinux_status=$(getenforce)
        if [[ "$selinux_status" == "Enforcing" ]]; then
            log_warn "SELinux处于强制模式，配置Redis端口策略..."
            
            for port in "${REDIS_PORTS[@]}"; do
                semanage port -a -t redis_port_t -p tcp "$port" 2>/dev/null || \
                semanage port -m -t redis_port_t -p tcp "$port" 2>/dev/null || true
                
                semanage port -a -t redis_port_t -p tcp "1$port" 2>/dev/null || \
                semanage port -m -t redis_port_t -p tcp "1$port" 2>/dev/null || true
            done
            
            # 设置文件上下文
            semanage fcontext -a -t redis_exec_t "$BASE_DIR(/.*)?" 2>/dev/null || true
            restorecon -R "$BASE_DIR" 2>/dev/null || true
            
            log_info "SELinux策略配置完成"
        else
            log_info "SELinux未启用或处于宽松模式"
        fi
    else
        log_info "系统未安装SELinux"
    fi
}

# 显示安装信息
show_installation_info() {
    echo
    echo "==========================================="
    echo "         Redis集群安装完成！"
    echo "==========================================="
    echo
    echo "集群信息:"
    echo "  节点端口: ${REDIS_PORTS[*]}"
    echo "  密码: $REDIS_PASSWORD"
    echo "  数据目录: $BASE_DIR"
    echo
    echo "常用命令:"
    echo "  查看集群状态: redis-cli -p ${REDIS_PORTS[0]} -a $REDIS_PASSWORD cluster info"
    echo "  查看节点信息: redis-cli -p ${REDIS_PORTS[0]} -a $REDIS_PASSWORD cluster nodes"
    echo "  连接集群: redis-cli -c -p ${REDIS_PORTS[0]} -a $REDIS_PASSWORD"
    echo
    echo "服务管理:"
    for port in "${REDIS_PORTS[@]}"; do
        echo "  systemctl status redis-cluster-$port"
    done
    echo
    echo "日志文件:"
    echo "  安装日志: $LOG_FILE"
    for port in "${REDIS_PORTS[@]}"; do
        echo "  Redis $port: $BASE_DIR/$port/logs/redis-$port.log"
    done
    echo
}

# 主函数
main() {
    log "开始安装Redis集群 (使用yum/dnf包管理器)"
    
    check_root
    detect_os
    install_epel
    update_system
    install_redis
    create_redis_user
    create_directories
    generate_redis_config
    create_systemd_services
    optimize_system
    configure_selinux
    start_redis_instances
    create_redis_cluster
    configure_firewall
    verify_cluster
    show_installation_info
    
    log "Redis集群安装完成！"
}

# 错误处理
trap 'log_error "脚本执行失败，请检查日志: $LOG_FILE"' ERR

# 执行主函数
main "$@"