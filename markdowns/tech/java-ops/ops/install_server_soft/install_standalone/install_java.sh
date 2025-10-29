#!/bin/bash

# Java环境安装脚本
# 安装OpenJDK 17
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

# 安装Java
install_java() {
    log_step "检查Java环境..."
    
    # 检查Java是否已安装
    if command -v java >/dev/null 2>&1; then
        JAVA_VERSION=$(java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}')
        log_info "Java已安装，版本: $JAVA_VERSION，跳过安装"
        return 0
    fi
    
    log_step "安装Java环境..."
    
    if [ "$OS" = "centos" ]; then
        # 安装OpenJDK 17
        yum install -y java-17-openjdk java-17-openjdk-devel
        JAVA_HOME_PATH="/usr/lib/jvm/java-17-openjdk"
    else
        # Ubuntu/Debian
        apt install -y openjdk-17-jdk
        JAVA_HOME_PATH="/usr/lib/jvm/java-17-openjdk-amd64"
    fi
    
    # 配置JAVA_HOME
    echo "export JAVA_HOME=$JAVA_HOME_PATH" >> /etc/profile
    echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> /etc/profile
    source /etc/profile
    
    # 验证安装
    java -version
    log_info "Java安装完成"
}

# 验证安装
verify_installation() {
    log_step "验证Java安装结果..."
    
    echo "==================== Java安装验证 ===================="
    
    # 验证Java
    echo "Java版本:"
    java -version
    echo ""
    
    # 验证javac
    echo "Java编译器版本:"
    javac -version
    echo ""
    
    # 显示JAVA_HOME
    echo "JAVA_HOME: $JAVA_HOME"
    echo ""
    
    log_info "Java安装验证完成"
}

# 显示安装信息
show_info() {
    echo ""
    echo "==================== Java安装完成 ===================="
    log_info "Java环境安装完成！"
    echo ""
    echo "Java信息:"
    echo "  版本: OpenJDK 17"
    echo "  JAVA_HOME: $JAVA_HOME_PATH"
    echo "  PATH: 已添加到系统PATH"
    echo ""
    echo "验证命令:"
    echo "  查看Java版本: java -version"
    echo "  查看编译器版本: javac -version"
    echo "  查看环境变量: echo \$JAVA_HOME"
    echo ""
    echo "注意事项:"
    echo "  1. 环境变量已添加到/etc/profile，重新登录后生效"
    echo "  2. 当前会话可能需要执行: source /etc/profile"
    echo "  3. 如需卸载: yum remove java-17-openjdk* (CentOS) 或 apt remove openjdk-17-jdk (Ubuntu)"
    echo ""
    echo "================================================="
}

# 主函数
main() {
    log_info "开始安装Java环境..."
    
    # 检查是否为root用户
    if [ "$EUID" -ne 0 ]; then
        log_error "请使用root用户运行此脚本"
        exit 1
    fi
    
    # 执行安装步骤
    detect_os
    update_system
    install_java
    verify_installation
    show_info
    
    log_info "Java安装脚本执行完成！"
}

# 执行主函数
main "$@"