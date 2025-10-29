#!/bin/bash

# MySQL数据库卸载脚本
# 卸载MySQL 8.0
# 支持CentOS/RHEL和Ubuntu/Debian系统

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

# 停止MySQL服务
stop_mysql() {
    log_step "停止MySQL服务..."
    
    if [ "$OS" = "centos" ]; then
        if systemctl is-active --quiet mysqld 2>/dev/null; then
            systemctl stop mysqld
            log_info "MySQL服务已停止"
        else
            log_warn "MySQL服务未运行"
        fi
    else
        if systemctl is-active --quiet mysql 2>/dev/null; then
            systemctl stop mysql
            log_info "MySQL服务已停止"
        else
            log_warn "MySQL服务未运行"
        fi
    fi
}

# 卸载MySQL
uninstall_mysql() {
    log_step "卸载MySQL数据库..."
    
    if [ "$OS" = "centos" ]; then
        # CentOS/RHEL卸载MySQL
        yum remove -y mysql-community-server mysql-community-client mysql-community-common mysql-community-libs
        
        # 删除MySQL官方仓库
        if rpm -qa | grep -q mysql80-community-release; then
            rpm -e mysql80-community-release
        fi
        
        log_info "MySQL卸载完成"
    else
        # Ubuntu/Debian卸载MySQL
        apt remove -y --purge mysql-server mysql-client mysql-common 
        apt autoremove -y
        apt autoclean
        
        log_info "MySQL卸载完成"
    fi
}

# 删除MySQL数据和配置文件
cleanup_files() {
    log_step "清理MySQL数据和配置文件..."
    
    # 停止MySQL服务（再次确保）
    stop_mysql
    
    # 删除数据目录
    if [ "$OS" = "centos" ]; then
        rm -rf /var/lib/mysql/
        rm -f /etc/my.cnf
        rm -f /etc/my.cnf.backup
    else
        rm -rf /var/lib/mysql/
        rm -rf /etc/mysql/
    fi
    
    # 删除日志文件
    if [ "$OS" = "centos" ]; then
        rm -f /var/log/mysqld.log
    else
        rm -f /var/log/mysql/
        rm -f /var/log/mysql.*
    fi
    
    # 删除用户
    userdel -r mysql 2>/dev/null || true
    
    log_info "MySQL数据和配置文件清理完成"
}

# 配置防火墙
configure_firewall() {
    log_step "配置防火墙规则..."
    
    if [ "$OS" = "centos" ]; then
        # CentOS使用firewalld
        if systemctl is-active --quiet firewalld; then
            firewall-cmd --permanent --remove-port=3306/tcp 2>/dev/null || true
            firewall-cmd --reload
            log_info "防火墙规则已移除 (端口: 3306)"
        else
            log_warn "firewalld未运行，跳过防火墙配置"
        fi
    else
        # Ubuntu使用ufw
        if command -v ufw >/dev/null 2>&1; then
            ufw delete allow 3306/tcp 2>/dev/null || true
            log_info "防火墙规则已移除 (端口: 3306)"
        else
            log_warn "ufw未安装，跳过防火墙配置"
        fi
    fi
}

# 验证卸载
verify_uninstallation() {
    log_step "验证MySQL卸载结果..."
    
    echo "==================== MySQL卸载验证 ===================="
    
    # 验证MySQL服务状态
    echo "MySQL服务状态:"
    if [ "$OS" = "centos" ]; then
        systemctl status mysqld --no-pager -l 2>&1 || true
    else
        systemctl status mysql --no-pager -l 2>&1 || true
    fi
    echo ""
    
    # 验证MySQL是否还能运行
    echo "MySQL版本检查:"
    mysql --version 2>&1 || true
    echo ""
    
    # 检查相关文件是否还存在
    echo "MySQL相关目录和文件检查:"
    if [ "$OS" = "centos" ]; then
        ls -la /var/lib/mysql/ 2>&1 || true
        ls -la /etc/my.cnf 2>&1 || true
    else
        ls -la /var/lib/mysql/ 2>&1 || true
        ls -la /etc/mysql/ 2>&1 || true
    fi
    echo ""
    
    log_info "MySQL卸载验证完成"
}

# 显示卸载信息
show_info() {
    echo ""
    echo "==================== MySQL卸载完成 ===================="
    log_info "MySQL数据库卸载完成！"
    echo ""
    echo "卸载操作包括:"
    echo "  1. 停止MySQL服务"
    echo "  2. 卸载MySQL软件包"
    echo "  3. 删除MySQL数据目录"
    echo "  4. 删除MySQL配置文件"
    echo "  5. 删除MySQL日志文件"
    echo "  6. 移除防火墙规则"
    echo ""
    echo "注意事项:"
    echo "  1. 所有MySQL数据已永久删除"
    echo "  2. 所有MySQL配置已移除"
    echo "  3. 如需重新安装，请运行安装脚本"
    echo ""
    echo "================================================="
}

# 主函数
main() {
    log_info "开始卸载MySQL数据库..."
    
    # 检查是否为root用户
    if [ "$EUID" -ne 0 ]; then
        log_error "请使用root用户运行此脚本"
        exit 1
    fi
    
    # 确认卸载操作
    echo -e "${RED}警告: 此操作将完全卸载MySQL并删除所有数据，无法恢复!${NC}"
    # read -p "确认继续卸载? (输入 'yes' 确认): " confirmation
    
    # if [ "$confirmation" != "yes" ]; then
    #     log_info "用户取消卸载操作"
    #     exit 0
    # fi
    
    # 执行卸载步骤
    detect_os
    stop_mysql
    uninstall_mysql
    cleanup_files
    configure_firewall
    verify_uninstallation
    show_info
    
    log_info "MySQL卸载脚本执行完成！"
}

# 执行主函数
main "$@"