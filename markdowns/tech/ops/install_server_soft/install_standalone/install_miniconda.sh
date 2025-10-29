#!/bin/bash

# Miniconda Python环境管理器安装脚本
# 支持CentOS/RHEL、Ubuntu/Debian和macOS系统
# 版本: v1.0.0
# 安装事项： 要把脚本上传到服务器上执行，不要在本地执行。


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
LOG_FILE="$LOG_DIR/install_miniconda_$(date +%Y%m%d_%H%M%S).log"

# Miniconda配置
MINICONDA_VERSION="latest"
MINICONDA_INSTALL_DIR="$HOME/miniconda3"
MINICONDA_INSTALLER_DIR="/tmp"
CONDA_INIT_SHELL="bash"
ADD_TO_PATH="yes"
INSTALL_FOR_ALL_USERS="no"

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
    log_info "Miniconda安装日志: $LOG_FILE"
}

# 显示横幅
show_banner() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                  Miniconda Python环境管理器安装              ║"
    echo "║                                                              ║"
    echo "║  Miniconda是一个轻量级的Python发行版                        ║"
    echo "║  包含conda包管理器和Python解释器                            ║"
    echo "║  支持系统: CentOS/RHEL 7+, Ubuntu 18.04+, Debian 9+, macOS ║"
    echo "║  作者: DevOps Team                                           ║"
    echo "║  版本: v1.0.0                                               ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}\n"
}

# 检测操作系统
detect_os() {
    log_step "检测操作系统..."
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        OS_VERSION=$(sw_vers -productVersion)
        PACKAGE_MANAGER="brew"
    elif [[ -f /etc/redhat-release ]]; then
        OS="centos"
        OS_VERSION=$(grep -oE '[0-9]+\.[0-9]+' /etc/redhat-release | head -1)
        PACKAGE_MANAGER="yum"
    elif [[ -f /etc/lsb-release ]] || [[ -f /etc/debian_version ]]; then
        OS="ubuntu"
        OS_VERSION=$(lsb_release -rs 2>/dev/null || cat /etc/debian_version)
        PACKAGE_MANAGER="apt"
    else
        log_error "不支持的操作系统"
        exit 1
    fi
    
    ARCH=$(uname -m)
    if [[ "$ARCH" == "x86_64" ]]; then
        ARCH="x86_64"
    elif [[ "$ARCH" == "aarch64" ]] || [[ "$ARCH" == "arm64" ]]; then
        ARCH="aarch64"
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
    
    # 检查磁盘空间 (至少需要2GB)
    local available_space
    if [[ "$OS" == "macos" ]]; then
        available_space=$(df -g "$HOME" | awk 'NR==2 {print $4}')
    else
        available_space=$(df -BG "$HOME" | awk 'NR==2 {print $4}' | sed 's/G//')
    fi
    
    if [[ $available_space -lt 2 ]]; then
        log_warn "磁盘可用空间不足2GB，可能影响安装"
    fi
    
    # 检查网络连接
    if ! ping -c 1 repo.anaconda.com >/dev/null 2>&1; then
        log_warn "无法连接到Anaconda仓库，请检查网络连接"
    fi
    
    # 检查是否已安装conda
    if command -v conda >/dev/null 2>&1; then
        local existing_conda=$(conda --version 2>/dev/null || echo "unknown")
        log_warn "检测到已安装的conda: $existing_conda"
        echo -e "${YELLOW}是否继续安装？这可能会覆盖现有安装 [y/N]: ${NC}"
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            log_info "用户取消安装"
            exit 0
        fi
    fi
    
    log_success "系统要求检查通过"
}

# 安装依赖包
install_dependencies() {
    log_step "安装依赖包..."
    
    if [[ "$OS" == "centos" ]]; then
        if command -v yum >/dev/null 2>&1; then
            yum update -y
            yum install -y wget curl bzip2
        elif command -v dnf >/dev/null 2>&1; then
            dnf update -y
            dnf install -y wget curl bzip2
        fi
    elif [[ "$OS" == "ubuntu" ]]; then
        apt update
        apt install -y wget curl bzip2
    elif [[ "$OS" == "macos" ]]; then
        # macOS通常已包含curl，检查是否需要安装其他工具
        if ! command -v wget >/dev/null 2>&1; then
            if command -v brew >/dev/null 2>&1; then
                brew install wget
            else
                log_warn "建议安装Homebrew以便管理依赖包"
            fi
        fi
    fi
    
    log_success "依赖包安装完成"
}

# 获取Miniconda下载URL
get_miniconda_url() {
    log_step "获取Miniconda下载链接..."
    
    local base_url="https://repo.anaconda.com/miniconda"
    local filename
    
    if [[ "$OS" == "macos" ]]; then
        if [[ "$ARCH" == "aarch64" ]]; then
            filename="Miniconda3-latest-MacOSX-arm64.sh"
        else
            filename="Miniconda3-latest-MacOSX-x86_64.sh"
        fi
    else
        # Linux
        if [[ "$ARCH" == "aarch64" ]]; then
            filename="Miniconda3-latest-Linux-aarch64.sh"
        else
            filename="Miniconda3-latest-Linux-x86_64.sh"
        fi
    fi
    
    MINICONDA_URL="$base_url/$filename"
    MINICONDA_INSTALLER="$MINICONDA_INSTALLER_DIR/$filename"
    
    log_info "下载链接: $MINICONDA_URL"
    log_info "安装包路径: $MINICONDA_INSTALLER"
}

# 下载Miniconda
download_miniconda() {
    log_step "下载Miniconda安装包..."
    
    # 如果文件已存在，检查是否需要重新下载
    if [[ -f "$MINICONDA_INSTALLER" ]]; then
        log_info "发现已存在的安装包: $MINICONDA_INSTALLER"
        echo -e "${YELLOW}是否重新下载？ [y/N]: ${NC}"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            rm -f "$MINICONDA_INSTALLER"
        else
            log_info "使用现有安装包"
            return 0
        fi
    fi
    
    log_info "正在下载Miniconda..."
    
    if command -v wget >/dev/null 2>&1; then
        wget -O "$MINICONDA_INSTALLER" "$MINICONDA_URL"
    elif command -v curl >/dev/null 2>&1; then
        curl -L -o "$MINICONDA_INSTALLER" "$MINICONDA_URL"
    else
        log_error "未找到wget或curl命令"
        exit 1
    fi
    
    if [[ ! -f "$MINICONDA_INSTALLER" ]]; then
        log_error "下载失败"
        exit 1
    fi
    
    log_success "Miniconda下载完成"
}

# 验证安装包
verify_installer() {
    log_step "验证安装包..."
    
    # 检查文件大小
    local file_size
    if [[ "$OS" == "macos" ]]; then
        file_size=$(stat -f%z "$MINICONDA_INSTALLER")
    else
        file_size=$(stat -c%s "$MINICONDA_INSTALLER")
    fi
    
    # Miniconda安装包通常大于50MB
    if [[ $file_size -lt 52428800 ]]; then
        log_error "安装包文件大小异常: $file_size bytes"
        exit 1
    fi
    
    # 检查文件头
    if ! head -c 4 "$MINICONDA_INSTALLER" | grep -q "#!/"; then
        log_error "安装包格式错误"
        exit 1
    fi
    
    log_success "安装包验证通过"
}

# 配置安装选项
configure_installation() {
    log_step "配置安装选项..."
    
    # 如果是root用户，询问是否为所有用户安装
    if [[ $EUID -eq 0 ]]; then
        echo -e "${YELLOW}检测到root用户，是否为所有用户安装Miniconda？ [y/N]: ${NC}"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            INSTALL_FOR_ALL_USERS="yes"
            MINICONDA_INSTALL_DIR="/opt/miniconda3"
        fi
    fi
    
    # 询问安装目录
    echo -e "${YELLOW}请输入安装目录 [默认: $MINICONDA_INSTALL_DIR]: ${NC}"
    read -r custom_dir
    if [[ -n "$custom_dir" ]]; then
        MINICONDA_INSTALL_DIR="$custom_dir"
    fi
    
    # 询问是否添加到PATH
    echo -e "${YELLOW}是否将conda添加到PATH环境变量？ [Y/n]: ${NC}"
    read -r response
    if [[ "$response" =~ ^[Nn]$ ]]; then
        ADD_TO_PATH="no"
    fi
    
    # 询问初始化shell
    echo -e "${YELLOW}选择要初始化的shell [bash/zsh/fish/none，默认: $CONDA_INIT_SHELL]: ${NC}"
    read -r shell_choice
    if [[ -n "$shell_choice" ]]; then
        CONDA_INIT_SHELL="$shell_choice"
    fi
    
    log_info "安装配置:"
    log_info "  安装目录: $MINICONDA_INSTALL_DIR"
    log_info "  添加到PATH: $ADD_TO_PATH"
    log_info "  初始化shell: $CONDA_INIT_SHELL"
    log_info "  全局安装: $INSTALL_FOR_ALL_USERS"
}

# 安装Miniconda
install_miniconda() {
    log_step "安装Miniconda..."
    
    # 创建安装目录
    if [[ ! -d "$(dirname "$MINICONDA_INSTALL_DIR")" ]]; then
        mkdir -p "$(dirname "$MINICONDA_INSTALL_DIR")"
    fi
    
    # 设置安装参数
    local install_args="-b -p $MINICONDA_INSTALL_DIR"
    
    # 如果目录已存在，询问是否覆盖
    if [[ -d "$MINICONDA_INSTALL_DIR" ]]; then
        echo -e "${YELLOW}安装目录已存在，是否覆盖？ [y/N]: ${NC}"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            install_args="-b -f -p $MINICONDA_INSTALL_DIR"
        else
            log_error "安装目录已存在，取消安装"
            exit 1
        fi
    fi
    
    log_info "开始安装Miniconda..."
    
    # 执行安装
    chmod +x "$MINICONDA_INSTALLER"
    if bash "$MINICONDA_INSTALLER" $install_args; then
        log_success "Miniconda安装完成"
    else
        log_error "Miniconda安装失败"
        exit 1
    fi
    
    # 设置权限
    if [[ "$INSTALL_FOR_ALL_USERS" == "yes" ]]; then
        chmod -R 755 "$MINICONDA_INSTALL_DIR"
    fi
}

# 初始化conda
init_conda() {
    log_step "初始化conda环境..."
    
    local conda_bin="$MINICONDA_INSTALL_DIR/bin/conda"
    
    if [[ ! -f "$conda_bin" ]]; then
        log_error "找不到conda可执行文件: $conda_bin"
        exit 1
    fi
    
    # 初始化conda
    if [[ "$CONDA_INIT_SHELL" != "none" ]]; then
        log_info "初始化$CONDA_INIT_SHELL shell..."
        "$conda_bin" init "$CONDA_INIT_SHELL"
    fi
    
    # 接受服务条款
    log_info "接受conda服务条款..."
    "$conda_bin" tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main || true
    "$conda_bin" tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r || true
    
    # 更新conda
    log_info "更新conda到最新版本..."
    "$conda_bin" update -n base -c defaults conda -y
    
    log_success "conda初始化完成"
}

# 配置环境变量
configure_environment() {
    log_step "配置环境变量..."
    
    local conda_bin_dir="$MINICONDA_INSTALL_DIR/bin"
    
    if [[ "$ADD_TO_PATH" == "yes" ]]; then
        # 添加到当前会话
        export PATH="$conda_bin_dir:$PATH"
        
        # 根据shell类型添加到配置文件
        local shell_config
        if [[ "$CONDA_INIT_SHELL" == "zsh" ]]; then
            shell_config="$HOME/.zshrc"
        elif [[ "$CONDA_INIT_SHELL" == "fish" ]]; then
            shell_config="$HOME/.config/fish/config.fish"
        else
            shell_config="$HOME/.bashrc"
        fi
        
        # 检查是否已添加
        if [[ -f "$shell_config" ]] && ! grep -q "$conda_bin_dir" "$shell_config"; then
            echo "" >> "$shell_config"
            echo "# Added by Miniconda installer" >> "$shell_config"
            if [[ "$CONDA_INIT_SHELL" == "fish" ]]; then
                echo "set -gx PATH $conda_bin_dir \$PATH" >> "$shell_config"
            else
                echo "export PATH=\"$conda_bin_dir:\$PATH\"" >> "$shell_config"
            fi
            log_info "已添加到$shell_config"
        fi
    fi
    
    # 创建全局配置（如果是全局安装）
    if [[ "$INSTALL_FOR_ALL_USERS" == "yes" ]]; then
        cat > /etc/profile.d/miniconda.sh << EOF
#!/bin/bash
# Miniconda environment setup
export PATH="$conda_bin_dir:\$PATH"
EOF
        chmod 644 /etc/profile.d/miniconda.sh
        log_info "已创建全局环境配置"
    fi
    
    log_success "环境变量配置完成"
}

# 安装常用包
install_common_packages() {
    log_step "安装常用Python包..."
    
    local conda_bin="$MINICONDA_INSTALL_DIR/bin/conda"
    
    echo -e "${YELLOW}是否安装常用的Python包？ [Y/n]: ${NC}"
    read -r response
    if [[ "$response" =~ ^[Nn]$ ]]; then
        log_info "跳过常用包安装"
        return 0
    fi
    
    log_info "安装常用包: numpy, pandas, matplotlib, jupyter..."
    
    # 确保服务条款已接受
    "$conda_bin" tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main || true
    "$conda_bin" tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r || true
    
    # 安装常用科学计算包
    "$conda_bin" install -y numpy pandas matplotlib scipy scikit-learn jupyter ipython
    
    log_success "常用包安装完成"
}

# 验证安装
verify_installation() {
    log_step "验证安装..."
    
    local conda_bin="$MINICONDA_INSTALL_DIR/bin/conda"
    
    # 检查conda可执行文件
    if [[ ! -f "$conda_bin" ]]; then
        log_error "conda可执行文件不存在"
        exit 1
    fi
    
    # 检查conda版本
    local conda_version
    if conda_version=$("$conda_bin" --version 2>/dev/null); then
        log_info "conda版本: $conda_version"
    else
        log_error "无法获取conda版本信息"
        exit 1
    fi
    
    # 检查Python版本
    local python_bin="$MINICONDA_INSTALL_DIR/bin/python"
    if [[ -f "$python_bin" ]]; then
        local python_version
        if python_version=$("$python_bin" --version 2>/dev/null); then
            log_info "Python版本: $python_version"
        fi
    fi
    
    # 检查环境列表
    log_info "conda环境列表:"
    "$conda_bin" env list
    
    log_success "安装验证通过"
}

# 显示安装信息
show_install_info() {
    log_header "Miniconda安装完成！"
    
    echo -e "\n${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                        安装信息                              ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}\n"
    
    echo -e "${CYAN}Miniconda安装信息:${NC}"
    echo -e "  • 安装目录: $MINICONDA_INSTALL_DIR"
    echo -e "  • conda可执行文件: $MINICONDA_INSTALL_DIR/bin/conda"
    echo -e "  • Python可执行文件: $MINICONDA_INSTALL_DIR/bin/python"
    echo -e "  • 全局安装: $INSTALL_FOR_ALL_USERS"
    
    echo -e "\n${CYAN}环境配置:${NC}"
    if [[ "$ADD_TO_PATH" == "yes" ]]; then
        echo -e "  • 已添加到PATH环境变量"
    else
        echo -e "  • 未添加到PATH，需要手动配置"
    fi
    
    if [[ "$CONDA_INIT_SHELL" != "none" ]]; then
        echo -e "  • 已初始化$CONDA_INIT_SHELL shell"
    else
        echo -e "  • 未初始化shell，需要手动配置"
    fi
    
    echo -e "\n${CYAN}常用命令:${NC}"
    echo -e "  • 激活base环境: conda activate"
    echo -e "  • 创建新环境: conda create -n myenv python=3.9"
    echo -e "  • 激活环境: conda activate myenv"
    echo -e "  • 安装包: conda install package_name"
    echo -e "  • 列出环境: conda env list"
    echo -e "  • 更新conda: conda update conda"
    
    echo -e "\n${CYAN}使用方法:${NC}"
    if [[ "$ADD_TO_PATH" == "yes" ]]; then
        echo -e "  • 重新加载shell配置或重启终端后即可使用conda命令"
    else
        echo -e "  • 手动添加到PATH: export PATH=\"$MINICONDA_INSTALL_DIR/bin:\$PATH\""
    fi
    
    echo -e "\n${YELLOW}注意事项:${NC}"
    echo -e "  • 建议定期更新conda和已安装的包"
    echo -e "  • 使用虚拟环境管理不同项目的依赖"
    echo -e "  • 可以使用conda-forge频道获取更多包"
    echo -e "  • 配置文件位置: ~/.condarc"
    
    echo -e "\n${GREEN}Miniconda安装成功！${NC}\n"
}

# 清理临时文件
cleanup() {
    log_info "清理临时文件..."
    
    if [[ -f "$MINICONDA_INSTALLER" ]]; then
        echo -e "${YELLOW}是否删除安装包？ [Y/n]: ${NC}"
        read -r response
        if [[ ! "$response" =~ ^[Nn]$ ]]; then
            rm -f "$MINICONDA_INSTALLER"
            log_info "已删除安装包"
        fi
    fi
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
    get_miniconda_url
    download_miniconda
    verify_installer
    configure_installation
    install_miniconda
    init_conda
    configure_environment
    install_common_packages
    
    # 验证和清理
    verify_installation
    show_install_info
    cleanup
    
    log_success "Miniconda安装脚本执行完成！"
}

# 错误处理
trap 'log_error "脚本执行失败，退出码: $?"; cleanup; exit 1' ERR

# 执行主函数
main "$@"