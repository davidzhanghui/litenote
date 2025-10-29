#!/bin/bash

# Docker容器化平台安装脚本
# 安装Docker CE最新版本
# 支持CentOS/RHEL和Ubuntu/Debian系统
# 再你自己的电脑上执行： ssh root@14.103.191.82 'bash -s' < ./scripts/other/install_docker.sh

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

# 卸载旧版本Docker
remove_old_docker() {
    log_step "检查并卸载旧版本Docker..."
    
    if [ "$OS" = "centos" ]; then
        # CentOS卸载旧版本
        yum remove -y docker \
                      docker-client \
                      docker-client-latest \
                      docker-common \
                      docker-latest \
                      docker-latest-logrotate \
                      docker-logrotate \
                      docker-engine 2>/dev/null || true
    else
        # Ubuntu卸载旧版本
        apt remove -y docker \
                      docker-engine \
                      docker.io \
                      containerd \
                      runc 2>/dev/null || true
    fi
    
    log_info "旧版本Docker清理完成"
}

# 安装Docker
install_docker() {
    log_step "检查Docker服务状态..."
    
    # 检查Docker是否已安装并运行
    if systemctl is-active --quiet docker 2>/dev/null; then
        log_info "Docker服务已在运行，跳过安装"
        return 0
    fi
    
    log_step "安装Docker容器化平台..."
    
    if [ "$OS" = "centos" ]; then
        # CentOS/RHEL安装Docker
        # 安装必要的软件包
        yum install -y yum-utils device-mapper-persistent-data lvm2
        
        # 添加Docker国内镜像仓库（阿里云）
        yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
        
        # 备用：如果阿里云源失败，使用官方源
        if ! yum makecache fast; then
            log_warn "阿里云Docker源连接失败，使用官方源"
            yum-config-manager --disable docker-ce-stable
            yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        fi
        
        # 安装Docker CE
        yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        
    else
        # Ubuntu/Debian安装Docker
        # 安装必要的软件包
        apt install -y apt-transport-https ca-certificates curl gnupg lsb-release
        
        # 尝试使用阿里云Docker镜像源
        if curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg 2>/dev/null; then
            # 添加阿里云Docker仓库
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
            log_info "使用阿里云Docker镜像源"
        else
            # 备用：使用官方源
            log_warn "阿里云Docker源连接失败，使用官方源"
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
        fi
        
        # 更新包索引
        apt update
        
        # 安装Docker CE
        apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    fi
    
    log_info "Docker安装完成"
}

# 配置Docker
configure_docker() {
    log_step "配置Docker服务..."
    
    # 创建Docker配置目录
    mkdir -p $DOCKER_CONFIG_DIR
    
    # 创建Docker配置文件
    cat > $DOCKER_CONFIG_DIR/daemon.json <<EOF
{
  "data-root": "$DOCKER_DATA_ROOT",
  "storage-driver": "overlay2",
  "insecure-registries": [],
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com",
    "https://mirror.baidubce.com",
    "https://dockerproxy.com",
    "https://mirror.ccs.tencentyun.com",
    "https://reg-mirror.qiniu.com"
  ],
  "bip": "172.17.0.1/16",
  "fixed-cidr": "172.17.0.0/16",
  "fixed-cidr-v6": "2001:db8:1::/64",
  "iptables": true,
  "live-restore": true,
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "max-concurrent-downloads": 10,
  "max-concurrent-uploads": 5,
  "default-shm-size": "64M"
}
EOF
    
    # 创建docker用户组
    if ! getent group $DOCKER_GROUP >/dev/null; then
        groupadd $DOCKER_GROUP
        log_info "创建docker用户组"
    fi
    
    # 启动Docker服务
    systemctl start docker
    systemctl enable docker
    
    # 验证Docker服务状态
    if systemctl is-active --quiet docker; then
        log_info "Docker服务启动成功"
    else
        log_error "Docker服务启动失败"
        exit 1
    fi
    
    log_info "Docker配置完成"
}

# 安装Docker Compose（独立版本）
install_docker_compose() {
    log_step "安装Docker Compose..."
    
    # 检查是否已安装
    if command -v docker-compose >/dev/null 2>&1; then
        log_info "Docker Compose已安装，跳过安装"
        return 0
    fi
    
    # 获取最新版本号
    COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    
    if [ -z "$COMPOSE_VERSION" ]; then
        COMPOSE_VERSION="v2.21.0"  # 备用版本
        log_warn "无法获取最新版本，使用备用版本: $COMPOSE_VERSION"
    fi
    
    # 下载Docker Compose（优先使用国内镜像源）
    COMPOSE_BINARY="docker-compose-$(uname -s)-$(uname -m)"
    # COMPOSE_BINARY 改为小写
    COMPOSE_BINARY=$(echo "$COMPOSE_BINARY" | tr '[:upper:]' '[:lower:]')
    log_info "下载Docker Compose版本: $COMPOSE_BINARY"
    DOWNLOAD_SUCCESS=false
    
    # 先看 /tmp目录下是否存在COMPOSE_BINARY文件，如果存在直接使用，不需要到镜像站区下载
    if [ -f "/tmp/$COMPOSE_BINARY" ]; then
        log_info "发现 /tmp 目录下已存在 $COMPOSE_BINARY 文件，直接使用"
        chmod 755 "/tmp/$COMPOSE_BINARY"
        cp "/tmp/$COMPOSE_BINARY" /usr/local/bin/docker-compose
        chmod 755 /usr/local/bin/docker-compose 
        DOWNLOAD_SUCCESS=true
        log_info "从 /tmp 目录复制成功"
    fi 

    # 从镜像站下载
    if [ "$DOWNLOAD_SUCCESS" = false ]; then
        # 尝试从GitHub镜像站下载
        log_info "尝试从GitHub镜像站下载Docker Compose..."
        if curl -L "https://ghproxy.com/https://github.com/docker/compose/releases/download/$COMPOSE_VERSION/$COMPOSE_BINARY" -o /usr/local/bin/docker-compose 2>/dev/null; then
            DOWNLOAD_SUCCESS=true
            log_info "从GitHub镜像站下载成功"
        fi
    fi
    
    # 如果镜像站失败，尝试官方源
    if [ "$DOWNLOAD_SUCCESS" = false ]; then
        log_warn "GitHub镜像站下载失败，尝试官方源..."
        if curl -L "https://github.com/docker/compose/releases/download/$COMPOSE_VERSION/$COMPOSE_BINARY" -o /usr/local/bin/docker-compose; then
            DOWNLOAD_SUCCESS=true
            log_info "从官方源下载成功"
        fi
    fi
    
    # 检查下载是否成功
    if [ "$DOWNLOAD_SUCCESS" = false ]; then
        log_error "Docker Compose下载失败"
        exit 1
    fi
    
    # 添加执行权限
    chmod +x /usr/local/bin/docker-compose
    
    # 创建软链接
    ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
    
    log_info "Docker Compose安装完成"
}

# 配置用户权限
configure_user_permissions() {
    log_step "配置用户权限..."
    
    # 获取当前用户（如果通过sudo执行）
    if [ -n "$SUDO_USER" ]; then
        CURRENT_USER="$SUDO_USER"
    else
        CURRENT_USER="$(whoami)"
    fi
    
    # 将用户添加到docker组
    if [ "$CURRENT_USER" != "root" ]; then
        usermod -aG $DOCKER_GROUP $CURRENT_USER
        log_info "用户 $CURRENT_USER 已添加到docker组"
        log_warn "请重新登录或执行 'newgrp docker' 使权限生效"
    fi
}

# 配置Docker镜像源
configure_docker_mirrors() {
    log_step "配置Docker国内镜像源..."
    
    # 备份原配置文件
    if [ -f "$DOCKER_CONFIG_DIR/daemon.json" ]; then
        cp "$DOCKER_CONFIG_DIR/daemon.json" "$DOCKER_CONFIG_DIR/daemon.json.backup.$(date +%Y%m%d_%H%M%S)"
        log_info "已备份原Docker配置文件"
    fi
    
    # 确保配置目录存在
    mkdir -p $DOCKER_CONFIG_DIR
    
    # 重新配置镜像源，确保使用最新的国内镜像源
    cat > $DOCKER_CONFIG_DIR/daemon.json <<EOF
{
  "data-root": "$DOCKER_DATA_ROOT",
  "storage-driver": "overlay2",
  "insecure-registries": [],
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com",
    "https://mirror.baidubce.com",
    "https://dockerproxy.com",
    "https://mirror.ccs.tencentyun.com",
    "https://reg-mirror.qiniu.com"
  ],
  "bip": "172.17.0.1/16",
  "fixed-cidr": "172.17.0.0/16",
  "fixed-cidr-v6": "2001:db8:1::/64",
  "iptables": true,
  "live-restore": true,
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "max-concurrent-downloads": 10,
  "max-concurrent-uploads": 5,
  "default-shm-size": "64M"
}
EOF
    
    # 重新加载Docker配置
    systemctl daemon-reload
    systemctl restart docker
    
    # 等待Docker服务重启
    sleep 3
    
    # 验证Docker服务状态
    if systemctl is-active --quiet docker; then
        log_info "Docker镜像源配置完成，服务重启成功"
        log_info "已配置的镜像源："
        log_info "  - 中科大镜像源: https://docker.mirrors.ustc.edu.cn"
        log_info "  - 网易镜像源: https://hub-mirror.c.163.com"
        log_info "  - 百度镜像源: https://mirror.baidubce.com"
        log_info "  - DockerProxy镜像源: https://dockerproxy.com"
        log_info "  - 腾讯云镜像源: https://mirror.ccs.tencentyun.com"
        log_info "  - 七牛云镜像源: https://reg-mirror.qiniu.com"
    else
        log_error "Docker服务重启失败"
        exit 1
    fi
}

# 验证安装
verify_installation() {
    log_step "验证Docker安装结果..."
    
    echo "==================== Docker安装验证 ===================="
    
    # 验证Docker服务状态
    echo "Docker服务状态:"
    systemctl status docker --no-pager -l
    echo ""
    
    # 验证Docker版本
    echo "Docker版本:"
    docker --version
    echo ""
    
    # 验证Docker Compose版本
    echo "Docker Compose版本:"
    docker-compose --version
    echo ""
    
    # 验证Docker信息
    echo "Docker系统信息:"
    docker info | head -20
    echo ""
    
    # 运行测试容器
    echo "运行测试容器:"
    docker run --rm hello-world
    echo ""
    
    log_info "Docker安装验证完成"
}

# 显示安装信息
show_info() {
    echo ""
    echo "==================== Docker安装完成 ===================="
    log_info "Docker容器化平台安装完成！"
    echo ""
    echo "Docker信息:"
    echo "  版本: $(docker --version | awk '{print $3}' | sed 's/,//')"
    echo "  服务状态: $(systemctl is-active docker)"
    echo "  数据目录: $DOCKER_DATA_ROOT"
    echo "  配置文件: $DOCKER_CONFIG_DIR/daemon.json"
    echo ""
    echo "Docker Compose信息:"
    echo "  版本: $(docker-compose --version | awk '{print $4}' | sed 's/,//')"
    echo "  安装路径: /usr/local/bin/docker-compose"
    echo ""
    echo "常用命令:"
    echo "  查看版本: docker --version"
    echo "  查看信息: docker info"
    echo "  查看镜像: docker images"
    echo "  查看容器: docker ps -a"
    echo "  启动服务: systemctl start docker"
    echo "  停止服务: systemctl stop docker"
    echo "  重启服务: systemctl restart docker"
    echo "  查看状态: systemctl status docker"
    echo ""
    echo "Docker Compose命令:"
    echo "  启动服务: docker-compose up -d"
    echo "  停止服务: docker-compose down"
    echo "  查看日志: docker-compose logs"
    echo "  重建容器: docker-compose up --build"
    echo ""
    echo "镜像仓库:"
    echo "  Docker Hub: https://hub.docker.com"
    echo "  阿里云: https://cr.console.aliyun.com"
    echo "  腾讯云: https://cloud.tencent.com/product/tcr"
    echo ""
    echo "配置信息:"
    echo "  已配置国内镜像加速源:"
    echo "    - 中科大镜像源: https://docker.mirrors.ustc.edu.cn"
    echo "    - 网易镜像源: https://hub-mirror.c.163.com"
    echo "    - 百度镜像源: https://mirror.baidubce.com"
    echo "    - DockerProxy镜像源: https://dockerproxy.com"
    echo "    - 腾讯云镜像源: https://mirror.ccs.tencentyun.com"
    echo "    - 七牛云镜像源: https://reg-mirror.qiniu.com"
    echo "  已启用日志轮转（最大10MB，保留3个文件）"
    echo "  已配置存储驱动为overlay2"
    echo "  已启用live-restore功能"
    echo ""
    echo "用户权限:"
    if [ -n "$SUDO_USER" ]; then
        echo "  用户 $SUDO_USER 已添加到docker组"
        echo "  请重新登录或执行 'newgrp docker' 使权限生效"
    fi
    echo ""
    echo "注意事项:"
    echo "  1. 首次使用需要重新登录以获取docker组权限"
    echo "  2. 已配置多个国内镜像源，自动提高下载速度"
    echo "  3. Docker安装源已优化为阿里云镜像，加速安装过程"
    echo "  4. Docker Compose使用GitHub镜像站加速下载"
    echo "  5. 建议定期清理无用镜像和容器"
    echo "  6. 生产环境请根据需要调整资源限制"
    echo ""
    echo "================================================="
}

# 主函数
main() {
    log_info "开始安装Docker容器化平台..."
    
    # 检查是否为root用户
    if [ "$EUID" -ne 0 ]; then
        log_error "请使用root用户运行此脚本"
        exit 1
    fi
    
    # 执行安装步骤
    detect_os
    update_system
    remove_old_docker
    install_docker
    configure_docker
    install_docker_compose
    configure_user_permissions
    configure_docker_mirrors
    verify_installation
    show_info
    
    log_info "Docker安装脚本执行完成！"
}

# 执行主函数
main "$@"