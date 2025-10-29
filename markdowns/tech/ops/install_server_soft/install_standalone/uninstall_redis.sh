#!/bin/bash

# Redis缓存服务卸载脚本
# 完全卸载Redis 7.x
# 支持CentOS/RHEL和Ubuntu/Debian系统
# 使用方式：通过scp命令上传到服务器后，再通过ssh命令登录到服务器执行这个脚本。不要在本地执行。

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Redis配置
REDIS_PORT=6379
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

# 确认卸载
confirm_uninstall() {
    echo ""
    echo "==================== 警告 ===================="
    log_warn "即将完全卸载Redis缓存服务！"
    echo "此操作将："
    echo "  1. 停止Redis服务"
    echo "  2. 删除Redis软件包"
    echo "  3. 删除所有配置文件"
    echo "  4. 删除所有数据文件（包括持久化数据）"
    echo "  5. 删除Redis用户"
    echo "  6. 删除防火墙规则"
    echo "  7. 清理所有相关目录"
    echo ""
    log_error "注意：此操作不可逆，所有Redis数据将被永久删除！"
    echo "============================================="
    echo ""
    
    read -p "确认要继续卸载Redis吗？(输入 'YES' 确认): " confirm
    if [ "$confirm" != "YES" ]; then
        log_info "取消卸载操作"
        exit 0
    fi
}

# 备份数据（可选）
backup_data() {
    log_step "检查是否需要备份数据..."
    
    if [ -d "$REDIS_DATA_DIR" ] && [ "$(ls -A $REDIS_DATA_DIR 2>/dev/null)" ]; then
        read -p "检测到Redis数据文件，是否备份？(y/N): " backup_choice
        if [[ $backup_choice =~ ^[Yy]$ ]]; then
            BACKUP_DIR="/tmp/redis_backup_$(date +%Y%m%d_%H%M%S)"
            mkdir -p "$BACKUP_DIR"
            cp -r "$REDIS_DATA_DIR"/* "$BACKUP_DIR"/
            log_info "数据已备份到: $BACKUP_DIR"
        fi
    fi
}

# 停止Redis服务
stop_redis_service() {
    log_step "停止Redis服务..."
    
    # 检查并停止Redis服务
    if [ "$OS" = "centos" ]; then
        if systemctl is-active --quiet redis 2>/dev/null; then
            systemctl stop redis
            systemctl disable redis
            log_info "Redis服务已停止并禁用"
        else
            log_warn "Redis服务未运行"
        fi
    else
        if systemctl is-active --quiet redis-server 2>/dev/null; then
            systemctl stop redis-server
            systemctl disable redis-server
            log_info "Redis服务已停止并禁用"
        else
            log_warn "Redis服务未运行"
        fi
    fi
    
    # 强制杀死Redis进程（如果存在）
    if pgrep redis-server >/dev/null; then
        log_warn "发现残留的Redis进程，正在强制终止..."
        pkill -f redis-server
        sleep 2
    fi
}

# 删除systemd服务文件
remove_systemd_service() {
    log_step "删除systemd服务文件..."
    
    if [ "$OS" = "centos" ]; then
        if [ -f "/etc/systemd/system/redis.service" ]; then
            rm -f /etc/systemd/system/redis.service
            log_info "已删除Redis systemd服务文件"
        fi
    fi
    
    # 重新加载systemd配置
    systemctl daemon-reload
    systemctl reset-failed 2>/dev/null || true
}

# 卸载Redis软件包
uninstall_redis_package() {
    log_step "卸载Redis软件包..."
    
    if [ "$OS" = "centos" ]; then
        # CentOS/RHEL卸载Redis
        if rpm -q redis >/dev/null 2>&1; then
            yum remove -y redis
            log_info "Redis软件包已卸载"
        else
            log_warn "Redis软件包未安装"
        fi
    else
        # Ubuntu/Debian卸载Redis
        if dpkg -l | grep -q redis-server; then
            apt remove --purge -y redis-server redis-tools
            apt autoremove -y
            log_info "Redis软件包已卸载"
        else
            log_warn "Redis软件包未安装"
        fi
    fi
}

# 删除配置文件和目录
remove_config_files() {
    log_step "删除配置文件和目录..."
    
    # 删除配置文件
    if [ "$OS" = "centos" ]; then
        REDIS_CONFIG_FILE="/etc/redis.conf"
    else
        REDIS_CONFIG_FILE="/etc/redis/redis.conf"
    fi
    
    if [ -f "$REDIS_CONFIG_FILE" ]; then
        rm -f "$REDIS_CONFIG_FILE"
        log_info "已删除Redis配置文件: $REDIS_CONFIG_FILE"
    fi
    
    # 删除备份配置文件
    if [ -f "$REDIS_CONFIG_FILE.backup" ]; then
        rm -f "$REDIS_CONFIG_FILE.backup"
        log_info "已删除Redis配置备份文件"
    fi
    
    # 删除配置目录
    if [ -d "$REDIS_CONFIG_DIR" ]; then
        rm -rf "$REDIS_CONFIG_DIR"
        log_info "已删除Redis配置目录: $REDIS_CONFIG_DIR"
    fi
}

# 删除数据文件和目录
remove_data_files() {
    log_step "删除数据文件和目录..."
    
    # 删除数据目录
    if [ -d "$REDIS_DATA_DIR" ]; then
        rm -rf "$REDIS_DATA_DIR"
        log_info "已删除Redis数据目录: $REDIS_DATA_DIR"
    fi
    
    # 删除日志目录
    if [ -d "$REDIS_LOG_DIR" ]; then
        rm -rf "$REDIS_LOG_DIR"
        log_info "已删除Redis日志目录: $REDIS_LOG_DIR"
    fi
    
    # 删除运行时目录
    if [ -d "/var/run/redis" ]; then
        rm -rf /var/run/redis
        log_info "已删除Redis运行时目录"
    fi
}

# 删除Redis用户
remove_redis_user() {
    log_step "删除Redis用户..."
    
    if id "$REDIS_USER" &>/dev/null; then
        userdel "$REDIS_USER" 2>/dev/null || true
        log_info "已删除Redis用户: $REDIS_USER"
    else
        log_warn "Redis用户不存在"
    fi
}

# 删除防火墙规则
remove_firewall_rules() {
    log_step "删除防火墙规则..."
    
    if [ "$OS" = "centos" ]; then
        # CentOS使用firewalld
        if systemctl is-active --quiet firewalld; then
            if firewall-cmd --list-ports | grep -q "$REDIS_PORT/tcp"; then
                firewall-cmd --permanent --remove-port=$REDIS_PORT/tcp
                firewall-cmd --reload
                log_info "防火墙规则已删除 (端口: $REDIS_PORT)"
            else
                log_warn "未找到Redis防火墙规则"
            fi
        else
            log_warn "firewalld未运行，跳过防火墙配置"
        fi
    else
        # Ubuntu使用ufw
        if command -v ufw >/dev/null 2>&1; then
            ufw delete allow $REDIS_PORT/tcp 2>/dev/null || true
            log_info "防火墙规则已删除 (端口: $REDIS_PORT)"
        else
            log_warn "ufw未安装，跳过防火墙配置"
        fi
    fi
}

# 清理残留文件
cleanup_remaining_files() {
    log_step "清理残留文件..."
    
    # 清理可能的残留文件
    find /etc -name "*redis*" -type f 2>/dev/null | while read file; do
        if [[ $file == *redis* ]]; then
            rm -f "$file"
            log_info "已删除残留文件: $file"
        fi
    done
    
    # 清理systemd残留
    find /etc/systemd -name "*redis*" -type f 2>/dev/null | while read file; do
        rm -f "$file"
        log_info "已删除systemd残留文件: $file"
    done
    
    # 清理日志残留
    find /var/log -name "*redis*" -type f 2>/dev/null | while read file; do
        rm -f "$file"
        log_info "已删除日志残留文件: $file"
    done
}

# 验证卸载
verify_uninstall() {
    log_step "验证Redis卸载结果..."
    
    echo "==================== Redis卸载验证 ===================="
    
    # 检查Redis进程
    if pgrep redis-server >/dev/null; then
        log_error "发现Redis进程仍在运行"
    else
        log_info "✓ 没有发现Redis进程"
    fi
    
    # 检查Redis服务
    if [ "$OS" = "centos" ]; then
        if systemctl list-unit-files | grep -q redis; then
            log_warn "发现Redis服务残留"
        else
            log_info "✓ Redis服务已完全删除"
        fi
    else
        if systemctl list-unit-files | grep -q redis-server; then
            log_warn "发现Redis服务残留"
        else
            log_info "✓ Redis服务已完全删除"
        fi
    fi
    
    # 检查Redis软件包
    if [ "$OS" = "centos" ]; then
        if rpm -q redis >/dev/null 2>&1; then
            log_error "Redis软件包仍然存在"
        else
            log_info "✓ Redis软件包已卸载"
        fi
    else
        if dpkg -l | grep -q redis; then
            log_error "Redis软件包仍然存在"
        else
            log_info "✓ Redis软件包已卸载"
        fi
    fi
    
    # 检查配置文件
    if [ -d "$REDIS_CONFIG_DIR" ] || [ -f "/etc/redis.conf" ]; then
        log_error "发现Redis配置文件残留"
    else
        log_info "✓ Redis配置文件已删除"
    fi
    
    # 检查数据目录
    if [ -d "$REDIS_DATA_DIR" ]; then
        log_error "发现Redis数据目录残留"
    else
        log_info "✓ Redis数据目录已删除"
    fi
    
    # 检查用户
    if id "$REDIS_USER" &>/dev/null; then
        log_error "Redis用户仍然存在"
    else
        log_info "✓ Redis用户已删除"
    fi
    
    # 检查端口占用
    if netstat -tlnp 2>/dev/null | grep -q ":$REDIS_PORT "; then
        log_error "端口$REDIS_PORT仍被占用"
    else
        log_info "✓ 端口$REDIS_PORT已释放"
    fi
    
    echo "================================================="
    log_info "Redis卸载验证完成"
}

# 显示卸载完成信息
show_completion_info() {
    echo ""
    echo "==================== Redis卸载完成 ===================="
    log_info "Redis缓存服务已完全卸载！"
    echo ""
    echo "已执行的操作："
    echo "  ✓ 停止并禁用Redis服务"
    echo "  ✓ 卸载Redis软件包"
    echo "  ✓ 删除所有配置文件"
    echo "  ✓ 删除所有数据文件"
    echo "  ✓ 删除Redis用户"
    echo "  ✓ 删除防火墙规则"
    echo "  ✓ 清理所有相关目录"
    echo "  ✓ 清理残留文件"
    echo ""
    echo "注意事项："
    echo "  1. 所有Redis数据已被永久删除"
    echo "  2. 如有备份数据，请查看 /tmp/redis_backup_* 目录"
    echo "  3. 系统已恢复到安装Redis之前的状态"
    echo "  4. 如需重新安装，请运行install_redis.sh脚本"
    echo ""
    echo "================================================="
}

# 主函数
main() {
    log_info "开始卸载Redis缓存服务..."
    
    # 检查是否为root用户
    if [ "$EUID" -ne 0 ]; then
        log_error "请使用root用户运行此脚本"
        exit 1
    fi
    
    # 执行卸载步骤
    detect_os
    confirm_uninstall
    backup_data
    stop_redis_service
    remove_systemd_service
    uninstall_redis_package
    remove_config_files
    remove_data_files
    remove_redis_user
    remove_firewall_rules
    cleanup_remaining_files
    verify_uninstall
    show_completion_info
    
    log_info "Redis卸载脚本执行完成！"
}

# 执行主函数
main "$@"