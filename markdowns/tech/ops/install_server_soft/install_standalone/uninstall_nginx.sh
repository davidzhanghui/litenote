#!/bin/bash

# Nginx Web服务器卸载脚本
# 卸载Nginx最新稳定版本
# 支持CentOS/RHEL和Ubuntu/Debian系统
# 使用方式：通过scp命令上传到服务器后，再通过ssh命令登录到服务器执行这个脚本。不要在本地执行。

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

# 停止Nginx服务
stop_nginx() {
    log_step "停止Nginx服务..."
    
    if systemctl is-active --quiet nginx 2>/dev/null; then
        systemctl stop nginx
        systemctl disable nginx
        log_info "Nginx服务已停止并禁用自启动"
    else
        log_warn "Nginx服务未运行"
    fi
}

# 卸载Nginx
uninstall_nginx() {
    log_step "卸载Nginx Web服务器..."
    
    if [ "$OS" = "centos" ]; then
        # CentOS/RHEL卸载Nginx
        yum remove -y nginx
        
        # 删除Nginx官方仓库
        if [ -f /etc/yum.repos.d/nginx.repo ]; then
            rm -f /etc/yum.repos.d/nginx.repo
            log_info "Nginx官方仓库配置已删除"
        fi
        
        # 删除GPG密钥
        rpm -e gpg-pubkey-* 2>/dev/null | grep -i nginx || true
        
        log_info "Nginx卸载完成"
    else
        # Ubuntu/Debian卸载Nginx
        apt remove -y --purge nginx nginx-common nginx-core
        apt autoremove -y
        apt autoclean
        
        # 删除Nginx官方仓库
        if [ -f /etc/apt/sources.list.d/nginx.list ]; then
            rm -f /etc/apt/sources.list.d/nginx.list
            log_info "Nginx官方仓库配置已删除"
        fi
        
        # 删除仓库优先级配置
        if [ -f /etc/apt/preferences.d/99nginx ]; then
            rm -f /etc/apt/preferences.d/99nginx
            log_info "Nginx仓库优先级配置已删除"
        fi
        
        # 删除GPG密钥
        apt-key del nginx 2>/dev/null || true
        
        # 更新包索引
        apt update
        
        log_info "Nginx卸载完成"
    fi
}

# 删除Nginx数据和配置文件
cleanup_files() {
    log_step "清理Nginx数据和配置文件..."
    
    # 停止Nginx服务（再次确保）
    stop_nginx
    
    # 删除配置目录
    if [ -d "$NGINX_HOME" ]; then
        rm -rf "$NGINX_HOME"
        log_info "Nginx配置目录已删除: $NGINX_HOME"
    fi
    
    # 删除日志目录
    if [ -d "$NGINX_LOG_DIR" ]; then
        rm -rf "$NGINX_LOG_DIR"
        log_info "Nginx日志目录已删除: $NGINX_LOG_DIR"
    fi
    
    # 删除缓存目录
    if [ -d "$NGINX_CACHE_DIR" ]; then
        rm -rf "$NGINX_CACHE_DIR"
        log_info "Nginx缓存目录已删除: $NGINX_CACHE_DIR"
    fi
    
    # 删除网站根目录（可选，根据需要决定是否删除）
    if [ -d "$WEB_ROOT" ]; then
        log_warn "网站根目录保留: $WEB_ROOT (如需删除请手动执行: rm -rf $WEB_ROOT)"
    fi
    
    # 删除PID文件
    if [ -f "$NGINX_RUN_DIR/nginx.pid" ]; then
        rm -f "$NGINX_RUN_DIR/nginx.pid"
        log_info "Nginx PID文件已删除"
    fi
    
    # 删除systemd服务文件（如果存在自定义的）
    if [ -f "/etc/systemd/system/nginx.service" ]; then
        rm -f "/etc/systemd/system/nginx.service"
        systemctl daemon-reload
        log_info "自定义Nginx服务文件已删除"
    fi
    
    # 删除用户和组（如果是安装脚本创建的）
    if id "$NGINX_USER" &>/dev/null; then
        userdel "$NGINX_USER" 2>/dev/null || true
        log_info "Nginx用户已删除: $NGINX_USER"
    fi
    
    if getent group "$NGINX_GROUP" &>/dev/null; then
        groupdel "$NGINX_GROUP" 2>/dev/null || true
        log_info "Nginx用户组已删除: $NGINX_GROUP"
    fi
    
    log_info "Nginx数据和配置文件清理完成"
}

# 配置防火墙
configure_firewall() {
    log_step "移除防火墙规则..."
    
    if [ "$OS" = "centos" ]; then
        # CentOS/RHEL防火墙配置
        if systemctl is-active --quiet firewalld; then
            firewall-cmd --permanent --remove-service=http 2>/dev/null || true
            firewall-cmd --permanent --remove-service=https 2>/dev/null || true
            firewall-cmd --permanent --remove-port=$NGINX_PORT/tcp 2>/dev/null || true
            firewall-cmd --permanent --remove-port=$NGINX_SSL_PORT/tcp 2>/dev/null || true
            firewall-cmd --reload
            log_info "防火墙规则已移除 (firewalld)"
        elif command -v iptables >/dev/null; then
            iptables -D INPUT -p tcp --dport $NGINX_PORT -j ACCEPT 2>/dev/null || true
            iptables -D INPUT -p tcp --dport $NGINX_SSL_PORT -j ACCEPT 2>/dev/null || true
            service iptables save 2>/dev/null || true
            log_info "防火墙规则已移除 (iptables)"
        fi
    else
        # Ubuntu/Debian防火墙配置
        if command -v ufw >/dev/null; then
            ufw delete allow $NGINX_PORT/tcp 2>/dev/null || true
            ufw delete allow $NGINX_SSL_PORT/tcp 2>/dev/null || true
            ufw delete allow 'Nginx Full' 2>/dev/null || true
            ufw delete allow 'Nginx HTTP' 2>/dev/null || true
            ufw delete allow 'Nginx HTTPS' 2>/dev/null || true
            log_info "防火墙规则已移除 (ufw)"
        elif command -v iptables >/dev/null; then
            iptables -D INPUT -p tcp --dport $NGINX_PORT -j ACCEPT 2>/dev/null || true
            iptables -D INPUT -p tcp --dport $NGINX_SSL_PORT -j ACCEPT 2>/dev/null || true
            iptables-save > /etc/iptables/rules.v4 2>/dev/null || true
            log_info "防火墙规则已移除 (iptables)"
        fi
    fi
}

# 验证卸载
verify_uninstallation() {
    log_step "验证Nginx卸载结果..."
    
    echo "==================== Nginx卸载验证 ===================="
    
    # 验证Nginx服务状态
    echo "Nginx服务状态:"
    systemctl status nginx --no-pager -l 2>&1 || echo "Nginx服务不存在或已停止"
    echo ""
    
    # 验证Nginx是否还能运行
    echo "Nginx版本检查:"
    nginx -v 2>&1 || echo "Nginx命令不存在"
    echo ""
    
    # 检查相关目录是否还存在
    echo "Nginx相关目录和文件检查:"
    echo "配置目录: $(ls -la $NGINX_HOME 2>&1 || echo '不存在')"
    echo "日志目录: $(ls -la $NGINX_LOG_DIR 2>&1 || echo '不存在')"
    echo "缓存目录: $(ls -la $NGINX_CACHE_DIR 2>&1 || echo '不存在')"
    echo "网站目录: $(ls -la $WEB_ROOT 2>&1 || echo '不存在')"
    echo ""
    
    # 检查监听端口
    echo "端口监听检查:"
    netstat -tlnp | grep :$NGINX_PORT || echo "端口 $NGINX_PORT 未被监听"
    netstat -tlnp | grep :$NGINX_SSL_PORT || echo "端口 $NGINX_SSL_PORT 未被监听"
    echo ""
    
    log_info "Nginx卸载验证完成"
}

# 显示卸载信息
show_info() {
    echo ""
    echo "==================== Nginx卸载完成 ===================="
    log_info "Nginx Web服务器卸载完成！"
    echo ""
    echo "卸载操作包括:"
    echo "  1. 停止并禁用Nginx服务"
    echo "  2. 卸载Nginx软件包"
    echo "  3. 删除Nginx配置目录: $NGINX_HOME"
    echo "  4. 删除Nginx日志目录: $NGINX_LOG_DIR"
    echo "  5. 删除Nginx缓存目录: $NGINX_CACHE_DIR"
    echo "  6. 删除Nginx用户和用户组"
    echo "  7. 移除防火墙规则 (端口: $NGINX_PORT, $NGINX_SSL_PORT)"
    echo "  8. 删除官方仓库配置"
    echo ""
    echo "保留的内容:"
    echo "  - 网站根目录: $WEB_ROOT (需要手动删除)"
    echo ""
    echo "注意事项:"
    echo "  1. 所有Nginx配置文件已删除"
    echo "  2. 所有Nginx日志文件已删除"
    echo "  3. 网站文件已保留，如需删除请手动执行: rm -rf $WEB_ROOT"
    echo "  4. 如需重新安装，请运行安装脚本"
    echo ""
    echo "重新安装命令:"
    echo "  ./install_nginx.sh"
    echo ""
    echo "================================================="
}

# 主函数
main() {
    log_info "开始卸载Nginx Web服务器..."
    
    # 检查是否为root用户
    if [ "$EUID" -ne 0 ]; then
        log_error "请使用root用户运行此脚本"
        exit 1
    fi
    
    # 确认卸载操作
    echo -e "${RED}警告: 此操作将完全卸载Nginx并删除所有配置文件，网站文件将保留!${NC}"
    read -p "确认继续卸载? (输入 'yes' 确认): " confirmation
    
    if [ "$confirmation" != "yes" ]; then
        log_info "用户取消卸载操作"
        exit 0
    fi
    
    # 执行卸载步骤
    detect_os
    stop_nginx
    uninstall_nginx
    cleanup_files
    configure_firewall
    verify_uninstallation
    show_info
    
    log_info "Nginx卸载脚本执行完成！"
}

# 执行主函数
main "$@"