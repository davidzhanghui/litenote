#!/bin/bash

# MinIO 对象存储服务安装脚本
# 支持CentOS/RHEL和Ubuntu/Debian系统
# 版本: v1.0.0
# 再你自己的电脑上执行： ssh root@14.103.191.82 'bash -s' < ./scripts/other/install_minio.sh
# 安装完成后验证： curl http://14.103.191.82:9000/minio/health/live
# 登录MinIO控制台： http://14.103.191.82:9001 admin/admin

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 脚本配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$SCRIPT_DIR/logs"
LOG_FILE="$LOG_DIR/install_minio_$(date +%Y%m%d_%H%M%S).log"

# MinIO配置
MINIO_VERSION="latest"
MINIO_USER="minio"
MINIO_GROUP="minio"
MINIO_HOME="/opt/minio"
MINIO_DATA_DIR="/data/minio"
MINIO_CONFIG_DIR="/etc/minio"
MINIO_ACCESS_KEY="minioadmin"
MINIO_SECRET_KEY="minioadmin123"
MINIO_PORT="9000"
MINIO_CONSOLE_PORT="9001"

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

log_step() {
    echo -e "${PURPLE}[STEP]${NC} $1" | tee -a "$LOG_FILE"
}

log_header() {
    echo -e "\n${CYAN}[HEADER]${NC} $1" | tee -a "$LOG_FILE"
}

# 初始化日志目录
init_logging() {
    mkdir -p "$LOG_DIR"
    log_info "MinIO安装日志: $LOG_FILE"
}

# 显示横幅
show_banner() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    MinIO 对象存储服务安装                    ║"
    echo "║                                                              ║"
    echo "║  MinIO是一个高性能的分布式对象存储服务                      ║"
    echo "║  兼容Amazon S3 API，适用于云原生应用                        ║"
    echo "║  支持系统: CentOS/RHEL 7+, Ubuntu 18.04+, Debian 9+        ║"
    echo "║  作者: DevOps Team                                           ║"
    echo "║  版本: v1.0.0                                               ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}\n"
}

# 检测操作系统
detect_os() {
    log_step "检测操作系统..."
    
    if [[ -f /etc/redhat-release ]]; then
        OS="centos"
        OS_VERSION=$(grep -oE '[0-9]+\.[0-9]+' /etc/redhat-release | head -1)
        PACKAGE_MANAGER="yum"
        SERVICE_MANAGER="systemctl"
    elif [[ -f /etc/lsb-release ]] || [[ -f /etc/debian_version ]]; then
        OS="ubuntu"
        OS_VERSION=$(lsb_release -rs 2>/dev/null || cat /etc/debian_version)
        PACKAGE_MANAGER="apt"
        SERVICE_MANAGER="systemctl"
    else
        log_error "不支持的操作系统"
        exit 1
    fi
    
    ARCH=$(uname -m)
    if [[ "$ARCH" == "x86_64" ]]; then
        ARCH="amd64"
    elif [[ "$ARCH" == "aarch64" ]]; then
        ARCH="arm64"
    else
        log_error "不支持的系统架构: $ARCH"
        exit 1
    fi
    
    log_info "操作系统: $OS $OS_VERSION"
    log_info "系统架构: $ARCH"
}

# 检查系统要求
check_requirements() {
    log_step "检查系统要求..."
    
    # 检查root权限
    if [[ $EUID -ne 0 ]]; then
        log_error "此脚本需要root权限运行"
        exit 1
    fi
    
    # 检查内存
    local total_mem=$(free -m | awk 'NR==2{printf "%.0f", $2/1024}')
    if [[ $total_mem -lt 1 ]]; then
        log_warn "系统内存不足1GB，MinIO可能无法正常运行"
    fi
    
    # 检查磁盘空间
    local available_space=$(df / | awk 'NR==2 {print $4}')
    if [[ $available_space -lt 1048576 ]]; then  # 1GB in KB
        log_warn "根分区可用空间不足1GB"
    fi
    
    # 检查网络连接
    if ! ping -c 1 dl.min.io >/dev/null 2>&1; then
        log_warn "无法连接到MinIO下载服务器，请检查网络连接"
    fi
    
    log_success "系统要求检查通过"
}

# 安装依赖包
install_dependencies() {
    log_step "安装依赖包..."
    
    if [[ "$OS" == "centos" ]]; then
        yum update -y
        yum install -y wget curl tar gzip
    elif [[ "$OS" == "ubuntu" ]]; then
        apt update
        apt install -y wget curl tar gzip
    fi
    
    log_success "依赖包安装完成"
}

# 创建MinIO用户
create_minio_user() {
    log_step "创建MinIO用户..."
    
    if ! id "$MINIO_USER" &>/dev/null; then
        groupadd -r "$MINIO_GROUP"
        useradd -r -g "$MINIO_GROUP" -d "$MINIO_HOME" -s /bin/false "$MINIO_USER"
        log_info "已创建MinIO用户: $MINIO_USER"
    else
        log_info "MinIO用户已存在: $MINIO_USER"
    fi
}

# 创建目录结构
create_directories() {
    log_step "创建目录结构..."
    
    mkdir -p "$MINIO_HOME/bin"
    mkdir -p "$MINIO_DATA_DIR"
    mkdir -p "$MINIO_CONFIG_DIR"
    mkdir -p "/var/log/minio"
    
    # 设置目录权限
    chown -R "$MINIO_USER:$MINIO_GROUP" "$MINIO_HOME"
    chown -R "$MINIO_USER:$MINIO_GROUP" "$MINIO_DATA_DIR"
    chown -R "$MINIO_USER:$MINIO_GROUP" "$MINIO_CONFIG_DIR"
    chown -R "$MINIO_USER:$MINIO_GROUP" "/var/log/minio"
    
    chmod 755 "$MINIO_HOME"
    chmod 755 "$MINIO_DATA_DIR"
    chmod 750 "$MINIO_CONFIG_DIR"
    
    log_success "目录结构创建完成"
}

# 下载并安装MinIO
install_minio() {
    log_step "下载并安装MinIO..."

    # 如果 /root/soft/目录下有minio文件，则直接使用该文件
    if [[ -f /root/soft/minio ]]; then
        log_info "已存在MinIO安装文件，直接使用该文件"
        cp /root/soft/minio /usr/local/bin/minio
        chmod +x /usr/local/bin/minio
        chown "$MINIO_USER:$MINIO_GROUP" /usr/local/bin/minio
        return
    fi
    
    local download_url="https://dl.minio.io/server/minio/release/linux-${ARCH}/minio"
    local temp_file="/tmp/minio"
    
    log_info "从 $download_url 下载MinIO..."
    
    if wget -O "$temp_file" "$download_url"; then
        chmod +x "$temp_file"
        mv "${temp_file}" "/usr/local/bin/minio"
        chown "$MINIO_USER:$MINIO_GROUP" "/usr/local/bin/minio"
        
        log_success "MinIO安装完成"
    else
        log_error "MinIO下载失败"
        exit 1
    fi
}

# 下载并安装MinIO Client (mc)
install_minio_client() {
    log_step "下载并安装MinIO Client..."

    # 如果 /root/soft/目录下有mc文件，则直接使用该文件
    if [[ -f /root/soft/mc ]]; then
        log_info "已存在MinIO Client安装文件，直接使用该文件"
        cp /root/soft/mc /usr/local/bin/mc
        chmod +x /usr/local/bin/mc
        chown "$MINIO_USER:$MINIO_GROUP" /usr/local/bin/mc
        return
    fi
    
    local download_url="https://dl.minio.io/client/mc/release/linux-${ARCH}/mc"
    local temp_file="/tmp/mc"
    
    log_info "从 $download_url 下载MinIO Client..."
    
    if wget -O "$temp_file" "$download_url"; then
        chmod +x "$temp_file"
        mv "${temp_file}" "/usr/local/bin/mc"
        chown "$MINIO_USER:$MINIO_GROUP" "/usr/local/bin/mc"
        
        log_success "MinIO Client安装完成"
    else
        log_warn "MinIO Client下载失败，跳过安装"
    fi
}

# 创建配置文件
create_config() {
    log_step "创建配置文件..."
    
    # 创建环境变量文件
    cat > "$MINIO_CONFIG_DIR/minio" << EOF
# MinIO配置文件
# 访问密钥
MINIO_ROOT_USER=$MINIO_ACCESS_KEY
MINIO_ROOT_PASSWORD=$MINIO_SECRET_KEY

# 数据目录
MINIO_VOLUMES=$MINIO_DATA_DIR

# 服务端口
MINIO_ADDRESS=0.0.0.0:$MINIO_PORT
MINIO_CONSOLE_ADDRESS=0.0.0.0:$MINIO_CONSOLE_PORT

# 其他配置
MINIO_BROWSER=on
MINIO_DOMAIN=
MINIO_SERVER_URL=
EOF
    
    chown "$MINIO_USER:$MINIO_GROUP" "$MINIO_CONFIG_DIR/minio"
    chmod 640 "$MINIO_CONFIG_DIR/minio"
    
    log_success "配置文件创建完成"
}

# 创建systemd服务
create_systemd_service() {
    log_step "创建systemd服务..."
    
    cat > /etc/systemd/system/minio.service << EOF
[Unit]
Description=MinIO Object Storage Server
Documentation=https://docs.min.io
Wants=network-online.target
After=network-online.target
AssertFileIsExecutable=/usr/local/bin/minio

[Service]
WorkingDirectory=$MINIO_HOME

User=$MINIO_USER
Group=$MINIO_GROUP
ProtectProc=invisible

EnvironmentFile=-$MINIO_CONFIG_DIR/minio
ExecStartPre=/bin/bash -c "if [ -z \"\${MINIO_VOLUMES}\" ]; then echo \"Variable MINIO_VOLUMES not set in $MINIO_CONFIG_DIR/minio\"; exit 1; fi"
ExecStart=/usr/local/bin/minio server \$MINIO_VOLUMES --address \$MINIO_ADDRESS --console-address \$MINIO_CONSOLE_ADDRESS

# Let systemd restart this service always
Restart=always

# Specifies the maximum file descriptor number that can be opened by this process
LimitNOFILE=65536

# Specifies the maximum number of threads this process can create
TasksMax=infinity

# Disable timeout logic and wait until process is stopped
TimeoutStopSec=infinity
SendSIGKILL=no

[Install]
WantedBy=multi-user.target
EOF
    
    systemctl daemon-reload
    systemctl enable minio
    # systemctl start minio
    # systemctl status minio
    
    log_success "systemd服务创建完成"
}

# 配置防火墙
configure_firewall() {
    log_step "配置防火墙..."
    
    if command -v firewall-cmd >/dev/null 2>&1; then
        # CentOS/RHEL firewalld
        if systemctl is-active --quiet firewalld; then
            firewall-cmd --permanent --add-port="$MINIO_PORT/tcp"
            firewall-cmd --permanent --add-port="$MINIO_CONSOLE_PORT/tcp"
            firewall-cmd --reload
            log_info "已配置firewalld规则"
        fi
    elif command -v ufw >/dev/null 2>&1; then
        # Ubuntu UFW
        if ufw status | grep -q "Status: active"; then
            ufw allow "$MINIO_PORT/tcp"
            ufw allow "$MINIO_CONSOLE_PORT/tcp"
            ufw reload
            log_info "已配置UFW规则"
        fi
    fi
    
    log_success "防火墙配置完成"
}

# 启动MinIO服务
start_minio() {
    log_step "启动MinIO服务..."
    
    systemctl restart minio
    
    # 等待服务启动
    sleep 5
    
    if systemctl is-active --quiet minio; then
        log_success "MinIO服务启动成功"
    else
        log_error "MinIO服务启动失败"
        systemctl status minio
        exit 1
    fi
}

# 验证安装
verify_installation() {
    log_step "验证安装..."
    
    # 检查MinIO版本
    local minio_version
    if minio_version=$("/usr/local/bin/minio" --version 2>/dev/null); then
        log_info "MinIO版本: $minio_version"
    else
        log_error "无法获取MinIO版本信息"
        exit 1
    fi
    
    # 检查服务状态
    if systemctl is-active --quiet minio; then
        log_success "MinIO服务运行正常"
    else
        log_error "MinIO服务未运行"
        exit 1
    fi
    
    # 检查端口监听
    if netstat -tlnp 2>/dev/null | grep -q ":$MINIO_PORT "; then
        log_success "MinIO API端口 $MINIO_PORT 监听正常"
    else
        log_warn "MinIO API端口 $MINIO_PORT 未监听"
    fi
    
    if netstat -tlnp 2>/dev/null | grep -q ":$MINIO_CONSOLE_PORT "; then
        log_success "MinIO控制台端口 $MINIO_CONSOLE_PORT 监听正常"
    else
        log_warn "MinIO控制台端口 $MINIO_CONSOLE_PORT 未监听"
    fi
}

# 显示安装信息
show_install_info() {
    log_header "MinIO安装完成！"
    
    echo -e "\n${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                        安装信息                              ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}\n"
    
    echo -e "${CYAN}MinIO服务信息:${NC}"
    echo -e "  • 安装目录: $MINIO_HOME"
    echo -e "  • 数据目录: $MINIO_DATA_DIR"
    echo -e "  • 配置目录: $MINIO_CONFIG_DIR"
    echo -e "  • 运行用户: $MINIO_USER"
    echo -e "  • API端口: $MINIO_PORT"
    echo -e "  • 控制台端口: $MINIO_CONSOLE_PORT"
    
    echo -e "\n${CYAN}访问信息:${NC}"
    echo -e "  • API地址: http://$(hostname -I | awk '{print $1}'):$MINIO_PORT"
    echo -e "  • 控制台地址: http://$(hostname -I | awk '{print $1}'):$MINIO_CONSOLE_PORT"
    echo -e "  • 访问密钥: $MINIO_ACCESS_KEY"
    echo -e "  • 秘密密钥: $MINIO_SECRET_KEY"
    
    echo -e "\n${CYAN}常用命令:${NC}"
    echo -e "  • 启动服务: systemctl start minio"
    echo -e "  • 停止服务: systemctl stop minio"
    echo -e "  • 重启服务: systemctl restart minio"
    echo -e "  • 查看状态: systemctl status minio"
    echo -e "  • 查看日志: journalctl -u minio -f"
    
    echo -e "\n${YELLOW}注意事项:${NC}"
    echo -e "  • 请及时修改默认的访问密钥和秘密密钥"
    echo -e "  • 建议配置HTTPS以提高安全性"
    echo -e "  • 定期备份重要数据"
    echo -e "  • 监控磁盘空间使用情况"
    
    echo -e "\n${GREEN}MinIO安装成功！${NC}\n"
}

# 清理临时文件
cleanup() {
    log_info "清理临时文件..."
    rm -f /tmp/minio /tmp/mc
}

# 主函数
main() {
    # 初始化
    init_logging
    show_banner
    
    # 系统检查
    detect_os
    check_requirements
    
    # 安装过程
    install_dependencies
    create_minio_user
    create_directories
    install_minio
    install_minio_client
    create_config
    create_systemd_service
    configure_firewall
    start_minio
    
    # 验证和清理
    verify_installation
    show_install_info
    cleanup
    
    log_success "MinIO安装脚本执行完成！"
}

# 错误处理
trap 'log_error "脚本执行失败，退出码: $?"; cleanup; exit 1' ERR

# 执行主函数
main "$@"