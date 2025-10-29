#!/bin/bash

# Docker容器化平台卸载脚本
# 完全卸载Docker CE及相关组件
# 支持CentOS/RHEL和Ubuntu/Debian系统
# 在你自己的电脑上执行： ssh root@14.103.191.82 'bash -s' < ./scripts/other/uninstall_docker.sh

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Docker配置
DOCKER_USER="docker"
DOCKER_GROUP="docker"
DOCKER_DATA_ROOT="/var/lib/docker"
DOCKER_CONFIG_DIR="/etc/docker"
DOCKER_COMPOSE_PATH="/usr/local/bin/docker-compose"
DOCKER_COMPOSE_LINK="/usr/bin/docker-compose"

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
    log_warn "此操作将完全卸载Docker及其所有数据！"
    echo "这将删除："
    echo "  - 所有Docker容器和镜像"
    echo "  - Docker配置文件"
    echo "  - Docker数据目录 ($DOCKER_DATA_ROOT)"
    echo "  - Docker Compose"
    echo "  - Docker用户组权限"
    echo ""
    read -p "确定要继续吗？(y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "取消卸载操作"
        exit 0
    fi
}

# 停止并禁用Docker服务
stop_docker_service() {
    log_step "停止Docker服务..."
    
    # 检查Docker服务是否存在
    if systemctl list-unit-files | grep -q docker.service; then
        # 停止Docker服务
        if systemctl is-active --quiet docker; then
            systemctl stop docker
            log_info "Docker服务已停止"
        fi
        
        # 禁用Docker服务
        if systemctl is-enabled --quiet docker; then
            systemctl disable docker
            log_info "Docker服务已禁用"
        fi
    else
        log_info "Docker服务不存在，跳过停止操作"
    fi
    
    # 停止containerd服务
    if systemctl list-unit-files | grep -q containerd.service; then
        if systemctl is-active --quiet containerd; then
            systemctl stop containerd
            log_info "Containerd服务已停止"
        fi
        if systemctl is-enabled --quiet containerd; then
            systemctl disable containerd
            log_info "Containerd服务已禁用"
        fi
    fi
}

# 清理Docker容器和镜像
cleanup_docker_data() {
    log_step "清理Docker容器和镜像..."
    
    # 检查docker命令是否可用
    if command -v docker >/dev/null 2>&1; then
        # 停止所有运行的容器
        if [ "$(docker ps -q)" ]; then
            docker stop $(docker ps -q)
            log_info "已停止所有运行的容器"
        fi
        
        # 删除所有容器
        if [ "$(docker ps -aq)" ]; then
            docker rm -f $(docker ps -aq)
            log_info "已删除所有容器"
        fi
        
        # 删除所有镜像
        if [ "$(docker images -q)" ]; then
            docker rmi -f $(docker images -q)
            log_info "已删除所有镜像"
        fi
        
        # 清理系统
        docker system prune -af --volumes 2>/dev/null || true
        log_info "已清理Docker系统数据"
    else
        log_info "Docker命令不可用，跳过数据清理"
    fi
}

# 卸载Docker包
uninstall_docker_packages() {
    log_step "卸载Docker软件包..."
    
    if [ "$OS" = "centos" ]; then
        # CentOS/RHEL卸载Docker
        yum remove -y docker-ce \
                      docker-ce-cli \
                      containerd.io \
                      docker-buildx-plugin \
                      docker-compose-plugin \
                      docker-ce-rootless-extras 2>/dev/null || true
        
        # 删除Docker仓库
        if [ -f /etc/yum.repos.d/docker-ce.repo ]; then
            rm -f /etc/yum.repos.d/docker-ce.repo
            log_info "已删除Docker仓库配置"
        fi
        
    else
        # Ubuntu/Debian卸载Docker
        apt remove -y docker-ce \
                      docker-ce-cli \
                      containerd.io \
                      docker-buildx-plugin \
                      docker-compose-plugin \
                      docker-ce-rootless-extras 2>/dev/null || true
        
        # 删除Docker仓库和GPG密钥
        if [ -f /etc/apt/sources.list.d/docker.list ]; then
            rm -f /etc/apt/sources.list.d/docker.list
            log_info "已删除Docker仓库配置"
        fi
        
        if [ -f /usr/share/keyrings/docker-archive-keyring.gpg ]; then
            rm -f /usr/share/keyrings/docker-archive-keyring.gpg
            log_info "已删除Docker GPG密钥"
        fi
        
        # 更新包索引
        apt update
    fi
    
    log_info "Docker软件包卸载完成"
}

# 卸载Docker Compose
uninstall_docker_compose() {
    log_step "卸载Docker Compose..."
    
    # 删除Docker Compose二进制文件
    if [ -f "$DOCKER_COMPOSE_PATH" ]; then
        rm -f "$DOCKER_COMPOSE_PATH"
        log_info "已删除Docker Compose二进制文件"
    fi
    
    # 删除软链接
    if [ -L "$DOCKER_COMPOSE_LINK" ]; then
        rm -f "$DOCKER_COMPOSE_LINK"
        log_info "已删除Docker Compose软链接"
    fi
    
    log_info "Docker Compose卸载完成"
}

# 删除Docker配置和数据
remove_docker_files() {
    log_step "删除Docker配置文件和数据目录..."
    
    # 删除Docker配置目录
    if [ -d "$DOCKER_CONFIG_DIR" ]; then
        rm -rf "$DOCKER_CONFIG_DIR"
        log_info "已删除Docker配置目录: $DOCKER_CONFIG_DIR"
    fi
    
    # 删除Docker数据目录
    if [ -d "$DOCKER_DATA_ROOT" ]; then
        log_warn "正在删除Docker数据目录: $DOCKER_DATA_ROOT"
        rm -rf "$DOCKER_DATA_ROOT"
        log_info "已删除Docker数据目录"
    fi
    
    # 删除其他可能的Docker相关目录
    local other_dirs=(
        "/var/lib/containerd"
        "/var/lib/docker-engine"
        "/etc/systemd/system/docker.service.d"
        "/etc/systemd/system/containerd.service.d"
    )
    
    for dir in "${other_dirs[@]}"; do
        if [ -d "$dir" ]; then
            rm -rf "$dir"
            log_info "已删除目录: $dir"
        fi
    done
    
    # 重新加载systemd配置
    systemctl daemon-reload
    
    log_info "Docker文件清理完成"
}

# 移除用户组权限
remove_user_permissions() {
    log_step "移除用户组权限..."
    
    # 获取当前用户（如果通过sudo执行）
    if [ -n "$SUDO_USER" ]; then
        CURRENT_USER="$SUDO_USER"
    else
        CURRENT_USER="$(whoami)"
    fi
    
    # 从docker组中移除用户
    if [ "$CURRENT_USER" != "root" ] && getent group $DOCKER_GROUP >/dev/null; then
        if groups "$CURRENT_USER" | grep -q "\b$DOCKER_GROUP\b"; then
            gpasswd -d "$CURRENT_USER" $DOCKER_GROUP 2>/dev/null || true
            log_info "用户 $CURRENT_USER 已从docker组中移除"
        fi
    fi
    
    # 删除docker用户组（如果没有其他用户）
    if getent group $DOCKER_GROUP >/dev/null; then
        # 检查是否还有其他用户在docker组中
        local group_members=$(getent group $DOCKER_GROUP | cut -d: -f4)
        if [ -z "$group_members" ]; then
            groupdel $DOCKER_GROUP 2>/dev/null || true
            log_info "已删除docker用户组"
        else
            log_warn "docker组中还有其他用户，保留用户组"
        fi
    fi
    
    log_info "用户权限清理完成"
}

# 清理网络配置
cleanup_network() {
    log_step "清理Docker网络配置..."
    
    # 删除Docker创建的网络接口
    local interfaces=$(ip link show | grep docker | awk -F: '{print $2}' | tr -d ' ' || true)
    for interface in $interfaces; do
        if [ -n "$interface" ]; then
            ip link delete "$interface" 2>/dev/null || true
            log_info "已删除网络接口: $interface"
        fi
    done
    
    # 清理iptables规则（谨慎操作）
    if command -v iptables >/dev/null 2>&1; then
        # 删除Docker相关的iptables规则
        iptables -t nat -F DOCKER 2>/dev/null || true
        iptables -t filter -F DOCKER 2>/dev/null || true
        iptables -t filter -F DOCKER-ISOLATION-STAGE-1 2>/dev/null || true
        iptables -t filter -F DOCKER-ISOLATION-STAGE-2 2>/dev/null || true
        iptables -t filter -F DOCKER-USER 2>/dev/null || true
        
        iptables -t nat -X DOCKER 2>/dev/null || true
        iptables -t filter -X DOCKER 2>/dev/null || true
        iptables -t filter -X DOCKER-ISOLATION-STAGE-1 2>/dev/null || true
        iptables -t filter -X DOCKER-ISOLATION-STAGE-2 2>/dev/null || true
        iptables -t filter -X DOCKER-USER 2>/dev/null || true
        
        log_info "已清理Docker相关的iptables规则"
    fi
    
    log_info "网络配置清理完成"
}

# 验证卸载结果
verify_uninstall() {
    log_step "验证Docker卸载结果..."
    
    echo "==================== Docker卸载验证 ===================="
    
    # 检查Docker服务状态
    echo "Docker服务状态:"
    if systemctl list-unit-files | grep -q docker.service; then
        echo "  Docker服务仍然存在"
    else
        echo "  Docker服务已完全移除"
    fi
    echo ""
    
    # 检查Docker命令
    echo "Docker命令:"
    if command -v docker >/dev/null 2>&1; then
        echo "  Docker命令仍然可用"
    else
        echo "  Docker命令已移除"
    fi
    echo ""
    
    # 检查Docker Compose
    echo "Docker Compose:"
    if command -v docker-compose >/dev/null 2>&1; then
        echo "  Docker Compose仍然可用"
    else
        echo "  Docker Compose已移除"
    fi
    echo ""
    
    # 检查配置文件
    echo "配置文件:"
    if [ -d "$DOCKER_CONFIG_DIR" ]; then
        echo "  配置目录仍然存在: $DOCKER_CONFIG_DIR"
    else
        echo "  配置目录已删除"
    fi
    echo ""
    
    # 检查数据目录
    echo "数据目录:"
    if [ -d "$DOCKER_DATA_ROOT" ]; then
        echo "  数据目录仍然存在: $DOCKER_DATA_ROOT"
    else
        echo "  数据目录已删除"
    fi
    echo ""
    
    # 检查用户组
    echo "用户组:"
    if getent group $DOCKER_GROUP >/dev/null 2>&1; then
        echo "  docker用户组仍然存在"
    else
        echo "  docker用户组已删除"
    fi
    echo ""
    
    log_info "Docker卸载验证完成"
}

# 显示卸载信息
show_uninstall_info() {
    echo ""
    echo "==================== Docker卸载完成 ===================="
    log_info "Docker容器化平台卸载完成！"
    echo ""
    echo "已卸载的组件:"
    echo "  ✓ Docker CE引擎"
    echo "  ✓ Docker CLI工具"
    echo "  ✓ Containerd运行时"
    echo "  ✓ Docker Compose"
    echo "  ✓ Docker插件"
    echo ""
    echo "已删除的文件和目录:"
    echo "  ✓ 配置目录: $DOCKER_CONFIG_DIR"
    echo "  ✓ 数据目录: $DOCKER_DATA_ROOT"
    echo "  ✓ Docker Compose: $DOCKER_COMPOSE_PATH"
    echo "  ✓ 仓库配置文件"
    echo ""
    echo "已清理的配置:"
    echo "  ✓ 系统服务"
    echo "  ✓ 用户组权限"
    echo "  ✓ 网络配置"
    echo "  ✓ iptables规则"
    echo ""
    echo "注意事项:"
    echo "  1. 所有Docker容器和镜像已被删除"
    echo "  2. 如需重新安装，请运行install_docker.sh脚本"
    echo "  3. 用户可能需要重新登录以更新组权限"
    echo "  4. 某些网络配置可能需要重启系统才能完全清理"
    echo ""
    echo "如果需要重新安装Docker:"
    echo "  bash ./scripts/other/install_docker.sh"
    echo ""
    echo "================================================="
}

# 主函数
main() {
    log_info "开始卸载Docker容器化平台..."
    
    # 检查是否为root用户
    if [ "$EUID" -ne 0 ]; then
        log_error "请使用root用户运行此脚本"
        exit 1
    fi
    
    # 执行卸载步骤
    detect_os
    confirm_uninstall
    stop_docker_service
    cleanup_docker_data
    uninstall_docker_packages
    uninstall_docker_compose
    remove_docker_files
    remove_user_permissions
    cleanup_network
    verify_uninstall
    show_uninstall_info
    
    log_info "Docker卸载脚本执行完成！"
}

# 执行主函数
main "$@"