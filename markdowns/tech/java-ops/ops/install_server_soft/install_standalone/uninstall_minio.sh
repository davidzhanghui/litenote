#!/bin/bash

# MinIO 对象存储服务卸载脚本
# 支持CentOS/RHEL和Ubuntu/Debian系统
# 版本: v1.0.0
# 使用方法: bash uninstall_minio.sh

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
LOG_FILE="$LOG_DIR/uninstall_minio_$(date +%Y%m%d_%H%M%S).log"

# MinIO配置（与安装脚本保持一致）
MINIO_USER="minio"
MINIO_GROUP="minio"
MINIO_HOME="/opt/minio"
MINIO_DATA_DIR="/data/minio"
MINIO_CONFIG_DIR="/etc/minio"
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
    log_info "MinIO卸载日志: $LOG_FILE"
}

# 显示横幅
show_banner() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    MinIO 对象存储服务卸载                    ║"
    echo "║                                                              ║"
    echo "║  此脚本将完全卸载MinIO及其相关组件                          ║"
    echo "║  包括服务、配置文件、数据目录和用户账户                      ║"
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
    
    log_info "操作系统: $OS $OS_VERSION"
}

# 检查权限
check_permissions() {
    log_step "检查权限..."
    
    if [[ $EUID -ne 0 ]]; then
        log_error "此脚本需要root权限运行"
        exit 1
    fi
    
    log_success "权限检查通过"
}

# 确认卸载
confirm_uninstall() {
    log_step "确认卸载操作..."
    
    echo -e "${YELLOW}警告: 此操作将完全卸载MinIO及其所有数据！${NC}"
    echo -e "${YELLOW}包括以下内容:${NC}"
    echo -e "  • MinIO服务和进程"
    echo -e "  • 所有配置文件"
    echo -e "  • 数据目录: $MINIO_DATA_DIR"
    echo -e "  • 安装目录: $MINIO_HOME"
    echo -e "  • 用户账户: $MINIO_USER"
    echo -e "  • 防火墙规则"
    echo ""
    echo -e "${RED}此操作不可逆转！请确保已备份重要数据！${NC}"
    echo ""
    
    read -p "确定要继续卸载MinIO吗？ [y/N]: " -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        log_info "用户取消卸载操作"
        exit 0
    fi
    
    log_info "用户确认卸载操作"
}

# 停止MinIO服务
stop_minio_service() {
    log_step "停止MinIO服务..."
    
    if systemctl is-active --quiet minio 2>/dev/null; then
        log_info "正在停止MinIO服务..."
        systemctl stop minio
        log_success "MinIO服务已停止"
    else
        log_info "MinIO服务未运行"
    fi
    
    # 禁用服务自启动
    if systemctl is-enabled --quiet minio 2>/dev/null; then
        log_info "禁用MinIO服务自启动..."
        systemctl disable minio
        log_success "已禁用MinIO服务自启动"
    fi
}

# 删除systemd服务文件
remove_systemd_service() {
    log_step "删除systemd服务文件..."
    
    if [[ -f /etc/systemd/system/minio.service ]]; then
        rm -f /etc/systemd/system/minio.service
        systemctl daemon-reload
        log_success "已删除MinIO systemd服务文件"
    else
        log_info "MinIO systemd服务文件不存在"
    fi
}

# 删除MinIO可执行文件
remove_minio_binaries() {
    log_step "删除MinIO可执行文件..."
    
    # 删除MinIO服务器
    if [[ -f /usr/local/bin/minio ]]; then
        rm -f /usr/local/bin/minio
        log_success "已删除MinIO服务器可执行文件"
    else
        log_info "MinIO服务器可执行文件不存在"
    fi
    
    # 删除MinIO客户端
    if [[ -f /usr/local/bin/mc ]]; then
        rm -f /usr/local/bin/mc
        log_success "已删除MinIO客户端可执行文件"
    else
        log_info "MinIO客户端可执行文件不存在"
    fi
}

# 删除配置文件和目录
remove_config_files() {
    log_step "删除配置文件和目录..."
    
    # 删除配置目录
    if [[ -d "$MINIO_CONFIG_DIR" ]]; then
        rm -rf "$MINIO_CONFIG_DIR"
        log_success "已删除配置目录: $MINIO_CONFIG_DIR"
    else
        log_info "配置目录不存在: $MINIO_CONFIG_DIR"
    fi
    
    # 删除安装目录
    if [[ -d "$MINIO_HOME" ]]; then
        rm -rf "$MINIO_HOME"
        log_success "已删除安装目录: $MINIO_HOME"
    else
        log_info "安装目录不存在: $MINIO_HOME"
    fi
    
    # 删除日志目录
    if [[ -d "/var/log/minio" ]]; then
        rm -rf "/var/log/minio"
        log_success "已删除日志目录: /var/log/minio"
    else
        log_info "日志目录不存在: /var/log/minio"
    fi
}

# 处理数据目录
handle_data_directory() {
    log_step "处理数据目录..."
    
    if [[ -d "$MINIO_DATA_DIR" ]]; then
        echo -e "${YELLOW}发现数据目录: $MINIO_DATA_DIR${NC}"
        echo -e "${YELLOW}此目录可能包含重要数据！${NC}"
        echo ""
        
        read -p "是否删除数据目录？ [y/N]: " -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            rm -rf "$MINIO_DATA_DIR"
            log_success "已删除数据目录: $MINIO_DATA_DIR"
        else
            log_info "保留数据目录: $MINIO_DATA_DIR"
        fi
    else
        log_info "数据目录不存在: $MINIO_DATA_DIR"
    fi
}

# 删除用户和组
remove_user_and_group() {
    log_step "删除用户和组..."
    
    # 删除用户
    if id "$MINIO_USER" &>/dev/null; then
        userdel "$MINIO_USER"
        log_success "已删除用户: $MINIO_USER"
    else
        log_info "用户不存在: $MINIO_USER"
    fi
    
    # 删除组
    if getent group "$MINIO_GROUP" &>/dev/null; then
        groupdel "$MINIO_GROUP"
        log_success "已删除组: $MINIO_GROUP"
    else
        log_info "组不存在: $MINIO_GROUP"
    fi
}

# 清理防火墙规则
cleanup_firewall() {
    log_step "清理防火墙规则..."
    
    if command -v firewall-cmd >/dev/null 2>&1; then
        # CentOS/RHEL firewalld
        if systemctl is-active --quiet firewalld; then
            if firewall-cmd --list-ports | grep -q "$MINIO_PORT/tcp"; then
                firewall-cmd --permanent --remove-port="$MINIO_PORT/tcp"
                log_info "已移除防火墙规则: $MINIO_PORT/tcp"
            fi
            
            if firewall-cmd --list-ports | grep -q "$MINIO_CONSOLE_PORT/tcp"; then
                firewall-cmd --permanent --remove-port="$MINIO_CONSOLE_PORT/tcp"
                log_info "已移除防火墙规则: $MINIO_CONSOLE_PORT/tcp"
            fi
            
            firewall-cmd --reload
            log_success "防火墙规则清理完成"
        fi
    elif command -v ufw >/dev/null 2>&1; then
        # Ubuntu UFW
        if ufw status | grep -q "Status: active"; then
            ufw --force delete allow "$MINIO_PORT/tcp" 2>/dev/null || true
            ufw --force delete allow "$MINIO_CONSOLE_PORT/tcp" 2>/dev/null || true
            log_success "UFW规则清理完成"
        fi
    fi
}

# 清理进程
cleanup_processes() {
    log_step "清理MinIO进程..."
    
    # 查找并终止MinIO进程
    local minio_pids=$(pgrep -f "minio server" 2>/dev/null || true)
    
    if [[ -n "$minio_pids" ]]; then
        log_info "发现MinIO进程，正在终止..."
        echo "$minio_pids" | xargs kill -TERM 2>/dev/null || true
        
        # 等待进程终止
        sleep 3
        
        # 强制终止仍在运行的进程
        local remaining_pids=$(pgrep -f "minio server" 2>/dev/null || true)
        if [[ -n "$remaining_pids" ]]; then
            echo "$remaining_pids" | xargs kill -KILL 2>/dev/null || true
            log_warn "强制终止了一些MinIO进程"
        fi
        
        log_success "MinIO进程清理完成"
    else
        log_info "未发现运行中的MinIO进程"
    fi
}

# 清理临时文件
cleanup_temp_files() {
    log_step "清理临时文件..."
    
    # 清理可能的临时文件
    rm -f /tmp/minio /tmp/mc 2>/dev/null || true
    
    log_success "临时文件清理完成"
}

# 验证卸载
verify_uninstall() {
    log_step "验证卸载结果..."
    
    local issues_found=false
    
    # 检查服务状态
    if systemctl list-unit-files | grep -q "minio.service"; then
        log_warn "systemd服务文件仍然存在"
        issues_found=true
    fi
    
    # 检查可执行文件
    if [[ -f /usr/local/bin/minio ]]; then
        log_warn "MinIO可执行文件仍然存在"
        issues_found=true
    fi
    
    if [[ -f /usr/local/bin/mc ]]; then
        log_warn "MinIO客户端仍然存在"
        issues_found=true
    fi
    
    # 检查目录
    if [[ -d "$MINIO_CONFIG_DIR" ]]; then
        log_warn "配置目录仍然存在: $MINIO_CONFIG_DIR"
        issues_found=true
    fi
    
    if [[ -d "$MINIO_HOME" ]]; then
        log_warn "安装目录仍然存在: $MINIO_HOME"
        issues_found=true
    fi
    
    # 检查用户
    if id "$MINIO_USER" &>/dev/null; then
        log_warn "用户仍然存在: $MINIO_USER"
        issues_found=true
    fi
    
    # 检查进程
    if pgrep -f "minio server" >/dev/null 2>&1; then
        log_warn "发现仍在运行的MinIO进程"
        issues_found=true
    fi
    
    if [[ "$issues_found" == "false" ]]; then
        log_success "卸载验证通过，MinIO已完全移除"
    else
        log_warn "卸载验证发现一些问题，请手动检查"
    fi
}

# 显示卸载信息
show_uninstall_info() {
    log_header "MinIO卸载完成！"
    
    echo -e "\n${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                        卸载信息                              ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}\n"
    
    echo -e "${CYAN}已删除的组件:${NC}"
    echo -e "  • MinIO服务和systemd配置"
    echo -e "  • MinIO可执行文件 (/usr/local/bin/minio)"
    echo -e "  • MinIO客户端 (/usr/local/bin/mc)"
    echo -e "  • 配置目录 ($MINIO_CONFIG_DIR)"
    echo -e "  • 安装目录 ($MINIO_HOME)"
    echo -e "  • 日志目录 (/var/log/minio)"
    echo -e "  • 用户和组 ($MINIO_USER:$MINIO_GROUP)"
    echo -e "  • 防火墙规则 (端口 $MINIO_PORT, $MINIO_CONSOLE_PORT)"
    
    if [[ ! -d "$MINIO_DATA_DIR" ]]; then
        echo -e "  • 数据目录 ($MINIO_DATA_DIR)"
    else
        echo -e "\n${YELLOW}保留的内容:${NC}"
        echo -e "  • 数据目录 ($MINIO_DATA_DIR) - 用户选择保留"
    fi
    
    echo -e "\n${CYAN}清理建议:${NC}"
    echo -e "  • 检查是否有其他应用依赖MinIO"
    echo -e "  • 清理可能的备份文件"
    echo -e "  • 检查日志文件是否需要保留"
    
    if [[ -d "$MINIO_DATA_DIR" ]]; then
        echo -e "  • 手动处理保留的数据目录: $MINIO_DATA_DIR"
    fi
    
    echo -e "\n${GREEN}MinIO卸载成功！${NC}\n"
}

# 主函数
main() {
    # 初始化
    init_logging
    show_banner
    
    # 系统检查
    detect_os
    check_permissions
    confirm_uninstall
    
    # 卸载过程
    cleanup_processes
    stop_minio_service
    remove_systemd_service
    remove_minio_binaries
    remove_config_files
    handle_data_directory
    remove_user_and_group
    cleanup_firewall
    cleanup_temp_files
    
    # 验证和总结
    verify_uninstall
    show_uninstall_info
    
    log_success "MinIO卸载脚本执行完成！"
}

# 错误处理
trap 'log_error "脚本执行失败，退出码: $?"; exit 1' ERR

# 执行主函数
main "$@"