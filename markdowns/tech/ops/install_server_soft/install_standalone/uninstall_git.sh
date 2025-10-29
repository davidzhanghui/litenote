#!/bin/bash

# Git环境卸载脚本
# 卸载Git及相关配置
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

# 检查Git是否已安装
check_git_installed() {
    log_step "检查Git安装状态..."
    
    if ! command -v git >/dev/null 2>&1; then
        log_warn "Git未安装，无需卸载"
        exit 0
    fi
    
    GIT_VERSION=$(git --version | awk '{print $3}')
    log_info "检测到Git版本: $GIT_VERSION"
}

# 备份Git配置
backup_git_config() {
    log_step "备份Git配置..."
    
    BACKUP_DIR="/tmp/git_config_backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    # 备份全局配置
    if [ -f ~/.gitconfig ]; then
        cp ~/.gitconfig "$BACKUP_DIR/gitconfig_global"
        log_info "全局配置已备份到: $BACKUP_DIR/gitconfig_global"
    fi
    
    # 备份系统配置
    if [ -f /etc/gitconfig ]; then
        cp /etc/gitconfig "$BACKUP_DIR/gitconfig_system"
        log_info "系统配置已备份到: $BACKUP_DIR/gitconfig_system"
    fi
    
    # 查找用户目录下的Git配置
    for user_home in /home/*; do
        if [ -d "$user_home" ] && [ -f "$user_home/.gitconfig" ]; then
            username=$(basename "$user_home")
            cp "$user_home/.gitconfig" "$BACKUP_DIR/gitconfig_$username"
            log_info "用户 $username 的配置已备份到: $BACKUP_DIR/gitconfig_$username"
        fi
    done
    
    echo "配置备份目录: $BACKUP_DIR"
}

# 卸载Git
uninstall_git() {
    log_step "卸载Git..."
    
    if [ "$OS" = "centos" ]; then
        # CentOS/RHEL系统
        yum remove -y git
        
        # 清理依赖（可选，谨慎操作）
        log_warn "是否同时卸载开发工具包？这可能影响其他软件 (y/N)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            yum groupremove -y "Development Tools"
            yum remove -y gettext-devel openssl-devel perl-CPAN perl-devel zlib-devel curl-devel
        fi
    else
        # Ubuntu/Debian系统
        apt remove -y git
        apt autoremove -y
        
        # 清理依赖（可选，谨慎操作）
        log_warn "是否同时卸载Git相关依赖？这可能影响其他软件 (y/N)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            apt remove -y make libssl-dev libghc-zlib-dev libcurl4-gnutls-dev libncurses5-dev libncursesw5-dev libedit-dev
            apt autoremove -y
        fi
    fi
    
    log_info "Git卸载完成"
}

# 清理Git配置文件
clean_git_config() {
    log_step "清理Git配置文件..."
    
    log_warn "是否删除所有Git配置文件？(y/N)"
    read -r response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        # 删除全局配置
        if [ -f ~/.gitconfig ]; then
            rm -f ~/.gitconfig
            log_info "已删除全局配置文件: ~/.gitconfig"
        fi
        
        # 删除系统配置
        if [ -f /etc/gitconfig ]; then
            rm -f /etc/gitconfig
            log_info "已删除系统配置文件: /etc/gitconfig"
        fi
        
        # 删除用户配置
        for user_home in /home/*; do
            if [ -d "$user_home" ] && [ -f "$user_home/.gitconfig" ]; then
                username=$(basename "$user_home")
                rm -f "$user_home/.gitconfig"
                log_info "已删除用户 $username 的配置文件"
            fi
        done
    else
        log_info "保留Git配置文件"
    fi
}

# 验证卸载
verify_uninstallation() {
    log_step "验证Git卸载结果..."
    
    echo "==================== Git卸载验证 ===================="
    
    # 检查Git命令
    if command -v git >/dev/null 2>&1; then
        log_error "Git仍然存在，卸载可能未完成"
        echo "当前Git版本: $(git --version)"
        echo "Git路径: $(which git)"
    else
        log_info "Git已成功卸载"
    fi
    
    # 检查配置文件
    echo ""
    echo "剩余配置文件检查:"
    
    config_files=(
        "/etc/gitconfig"
        "$HOME/.gitconfig"
    )
    
    for config_file in "${config_files[@]}"; do
        if [ -f "$config_file" ]; then
            echo "  存在: $config_file"
        else
            echo "  不存在: $config_file"
        fi
    done
    
    echo ""
    log_info "Git卸载验证完成"
}

# 显示卸载信息
show_info() {
    echo ""
    echo "==================== Git卸载完成 ===================="
    log_info "Git环境卸载完成！"
    echo ""
    echo "卸载信息:"
    echo "  Git软件包: 已卸载"
    echo "  配置备份: $BACKUP_DIR"
    echo ""
    echo "注意事项:"
    echo "  1. Git配置文件已备份，如需恢复可从备份目录复制"
    echo "  2. 如果删除了配置文件，重新安装Git后需要重新配置"
    echo "  3. 本地Git仓库不受影响，但无法使用Git命令操作"
    echo "  4. 如需重新安装，请运行对应的安装脚本"
    echo ""
    echo "恢复配置示例:"
    echo "  cp $BACKUP_DIR/gitconfig_global ~/.gitconfig"
    echo ""
    echo "================================================="
}

# 主函数
main() {
    log_info "开始卸载Git环境..."
    
    # 检查是否为root用户
    if [ "$EUID" -ne 0 ]; then
        log_error "请使用root用户运行此脚本"
        exit 1
    fi
    
    # 确认卸载
    log_warn "确定要卸载Git吗？此操作不可逆 (y/N)"
    read -r confirm
    
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        log_info "取消卸载操作"
        exit 0
    fi
    
    # 执行卸载步骤
    detect_os
    check_git_installed
    backup_git_config
    uninstall_git
    clean_git_config
    verify_uninstallation
    show_info
    
    log_info "Git卸载脚本执行完成！"
}

# 执行主函数
main "$@"