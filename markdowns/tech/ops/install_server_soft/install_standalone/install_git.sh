#!/bin/bash

# Git环境安装脚本
# 安装最新版本的Git
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

# 安装Git
install_git() {
    log_step "检查Git环境..."
    
    # 检查Git是否已安装
    if command -v git >/dev/null 2>&1; then
        GIT_VERSION=$(git --version | awk '{print $3}')
        log_info "Git已安装，版本: $GIT_VERSION，跳过安装"
        return 0
    fi
    
    log_step "安装Git环境..."
    
    if [ "$OS" = "centos" ]; then
        # CentOS/RHEL系统
        # 先安装开发工具和依赖
        yum groupinstall -y "Development Tools"
        yum install -y gettext-devel openssl-devel perl-CPAN perl-devel zlib-devel curl-devel
        
        # 安装Git
        yum install -y git
    else
        # Ubuntu/Debian系统
        # 安装依赖
        apt install -y make libssl-dev libghc-zlib-dev libcurl4-gnutls-dev libncurses5-dev libncursesw5-dev libedit-dev
        
        # 安装Git
        apt install -y git
    fi
    
    log_info "Git安装完成"
}

# 配置Git（可选）
configure_git() {
    log_step "配置Git全局设置..."
    
    # 设置默认分支名为main
    git config --global init.defaultBranch main
    
    # 设置换行符处理
    if [ "$OS" = "centos" ]; then
        git config --global core.autocrlf input
    else
        git config --global core.autocrlf input
    fi
    
    # 设置编辑器
    git config --global core.editor vim
    
    log_info "Git基础配置完成"
    log_warn "请手动配置用户信息："
    echo "  git config --global user.name \"Your Name\""
    echo "  git config --global user.email \"your.email@example.com\""
}

# 验证安装
verify_installation() {
    log_step "验证Git安装结果..."
    
    echo "==================== Git安装验证 ===================="
    
    # 验证Git
    echo "Git版本:"
    git --version
    echo ""
    
    # 显示Git配置
    echo "Git全局配置:"
    git config --global --list 2>/dev/null || echo "暂无全局配置"
    echo ""
    
    # 显示Git安装路径
    echo "Git安装路径:"
    which git
    echo ""
    
    log_info "Git安装验证完成"
}

# 显示安装信息
show_info() {
    echo ""
    echo "==================== Git安装完成 ===================="
    log_info "Git环境安装完成！"
    echo ""
    echo "Git信息:"
    echo "  版本: $(git --version | awk '{print $3}')"
    echo "  安装路径: $(which git)"
    echo "  默认分支: main"
    echo ""
    echo "常用命令:"
    echo "  查看Git版本: git --version"
    echo "  查看Git配置: git config --global --list"
    echo "  配置用户名: git config --global user.name \"Your Name\""
    echo "  配置邮箱: git config --global user.email \"your.email@example.com\""
    echo ""
    echo "注意事项:"
    echo "  1. 请配置用户名和邮箱后再使用Git"
    echo "  2. 默认分支名已设置为main"
    echo "  3. 如需卸载，请运行对应的卸载脚本"
    echo ""
    echo "================================================="
}

# 主函数
main() {
    log_info "开始安装Git环境..."
    
    # 检查是否为root用户
    if [ "$EUID" -ne 0 ]; then
        log_error "请使用root用户运行此脚本"
        exit 1
    fi
    
    # 执行安装步骤
    detect_os
    update_system
    install_git
    configure_git
    verify_installation
    show_info
    
    log_info "Git安装脚本执行完成！"
}

# 执行主函数
main "$@"