#!/bin/bash

# Miniconda Python环境管理器卸载脚本
# 支持CentOS/RHEL和Ubuntu/Debian系统
# 版本: v1.0.0
# 使用方法: bash uninstall_miniconda.sh

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
LOG_FILE="$LOG_DIR/uninstall_miniconda_$(date +%Y%m%d_%H%M%S).log"

# Miniconda配置（与安装脚本保持一致）
DEFAULT_INSTALL_DIR="$HOME/miniconda3"
CONDA_INIT_SCRIPT="$HOME/.bashrc"
CONDA_PROFILE_SCRIPT="/etc/profile.d/conda.sh"

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
    log_info "Miniconda卸载日志: $LOG_FILE"
}

# 显示横幅
show_banner() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                  Miniconda Python环境管理器卸载              ║"
    echo "║                                                              ║"
    echo "║  此脚本将完全卸载Miniconda及其相关组件                      ║"
    echo "║  包括安装目录、环境变量配置和shell初始化                    ║"
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
    elif [[ -f /etc/lsb-release ]] || [[ -f /etc/debian_version ]]; then
        OS="ubuntu"
        OS_VERSION=$(lsb_release -rs 2>/dev/null || cat /etc/debian_version)
    else
        log_error "不支持的操作系统"
        exit 1
    fi
    
    log_info "操作系统: $OS $OS_VERSION"
}

# 检测Miniconda安装
detect_miniconda_installation() {
    log_step "检测Miniconda安装..."
    
    # 检测可能的安装路径
    POSSIBLE_PATHS=(
        "$HOME/miniconda3"
        "$HOME/miniconda"
        "/opt/miniconda3"
        "/opt/miniconda"
        "/usr/local/miniconda3"
        "/usr/local/miniconda"
    )
    
    FOUND_INSTALLATIONS=()
    
    # 检查conda命令是否可用
    if command -v conda >/dev/null 2>&1; then
        CONDA_PATH=$(which conda)
        CONDA_PREFIX=$(conda info --base 2>/dev/null || echo "")
        
        if [[ -n "$CONDA_PREFIX" && -d "$CONDA_PREFIX" ]]; then
            FOUND_INSTALLATIONS+=("$CONDA_PREFIX")
            log_info "通过conda命令检测到安装: $CONDA_PREFIX"
        fi
    fi
    
    # 检查预定义路径
    for path in "${POSSIBLE_PATHS[@]}"; do
        if [[ -d "$path" && -f "$path/bin/conda" ]]; then
            # 避免重复添加
            if [[ ! " ${FOUND_INSTALLATIONS[@]} " =~ " ${path} " ]]; then
                FOUND_INSTALLATIONS+=("$path")
                log_info "检测到安装: $path"
            fi
        fi
    done
    
    if [[ ${#FOUND_INSTALLATIONS[@]} -eq 0 ]]; then
        log_warn "未检测到Miniconda安装"
        return 1
    fi
    
    return 0
}

# 选择要卸载的安装
select_installation() {
    if [[ ${#FOUND_INSTALLATIONS[@]} -eq 1 ]]; then
        INSTALL_DIR="${FOUND_INSTALLATIONS[0]}"
        log_info "选择安装目录: $INSTALL_DIR"
    else
        echo -e "\n${YELLOW}检测到多个Miniconda安装:${NC}"
        for i in "${!FOUND_INSTALLATIONS[@]}"; do
            echo "  $((i+1)). ${FOUND_INSTALLATIONS[$i]}"
        done
        echo "  $((${#FOUND_INSTALLATIONS[@]}+1)). 自定义路径"
        echo "  $((${#FOUND_INSTALLATIONS[@]}+2)). 卸载所有检测到的安装"
        
        while true; do
            read -p "请选择要卸载的安装 [1-$((${#FOUND_INSTALLATIONS[@]}+2))]: " choice
            
            if [[ "$choice" =~ ^[0-9]+$ ]]; then
                if [[ $choice -ge 1 && $choice -le ${#FOUND_INSTALLATIONS[@]} ]]; then
                    INSTALL_DIR="${FOUND_INSTALLATIONS[$((choice-1))]}"
                    log_info "选择安装目录: $INSTALL_DIR"
                    break
                elif [[ $choice -eq $((${#FOUND_INSTALLATIONS[@]}+1)) ]]; then
                    read -p "请输入自定义安装路径: " INSTALL_DIR
                    if [[ -d "$INSTALL_DIR" && -f "$INSTALL_DIR/bin/conda" ]]; then
                        log_info "选择自定义安装目录: $INSTALL_DIR"
                        break
                    else
                        log_error "无效的Miniconda安装路径"
                    fi
                elif [[ $choice -eq $((${#FOUND_INSTALLATIONS[@]}+2)) ]]; then
                    UNINSTALL_ALL=true
                    log_info "选择卸载所有检测到的安装"
                    break
                fi
            fi
            
            log_error "无效选择，请重新输入"
        done
    fi
}

# 确认卸载
confirm_uninstall() {
    log_step "确认卸载操作..."
    
    echo -e "${YELLOW}警告: 此操作将完全卸载Miniconda及其所有环境和包！${NC}"
    echo -e "${YELLOW}包括以下内容:${NC}"
    
    if [[ "$UNINSTALL_ALL" == "true" ]]; then
        echo -e "  • 所有检测到的Miniconda安装:"
        for install in "${FOUND_INSTALLATIONS[@]}"; do
            echo -e "    - $install"
        done
    else
        echo -e "  • 安装目录: $INSTALL_DIR"
    fi
    
    echo -e "  • 所有conda环境和包"
    echo -e "  • 环境变量配置"
    echo -e "  • Shell初始化脚本"
    echo -e "  • 缓存和临时文件"
    echo ""
    echo -e "${RED}此操作不可逆转！请确保已备份重要环境和数据！${NC}"
    echo ""
    
    read -p "确定要继续卸载Miniconda吗？ [y/N]: " -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        log_info "用户取消卸载操作"
        exit 0
    fi
    
    log_info "用户确认卸载操作"
}

# 停用conda环境
deactivate_conda() {
    log_step "停用conda环境..."
    
    # 尝试停用当前环境
    if [[ -n "$CONDA_DEFAULT_ENV" ]]; then
        log_info "当前激活环境: $CONDA_DEFAULT_ENV"
        # 在子shell中执行，避免影响当前脚本
        (source "$INSTALL_DIR/etc/profile.d/conda.sh" 2>/dev/null && conda deactivate 2>/dev/null) || true
        log_success "已停用conda环境"
    else
        log_info "未检测到激活的conda环境"
    fi
}

# 清理环境变量
cleanup_environment_variables() {
    log_step "清理环境变量..."
    
    # 要清理的shell配置文件
    local shell_configs=(
        "$HOME/.bashrc"
        "$HOME/.bash_profile"
        "$HOME/.zshrc"
        "$HOME/.profile"
        "$HOME/.cshrc"
        "$HOME/.tcshrc"
        "$HOME/.fish/config.fish"
    )
    
    for config_file in "${shell_configs[@]}"; do
        if [[ -f "$config_file" ]]; then
            log_info "清理配置文件: $config_file"
            
            # 备份原文件
            cp "$config_file" "${config_file}.backup_$(date +%Y%m%d_%H%M%S)"
            
            # 移除conda相关配置
            if [[ "$UNINSTALL_ALL" == "true" ]]; then
                # 移除所有conda相关行
                sed -i.tmp '/# >>> conda initialize >>>/,/# <<< conda initialize <<</d' "$config_file" 2>/dev/null || true
                sed -i.tmp '/conda/d' "$config_file" 2>/dev/null || true
            else
                # 只移除特定安装路径的配置
                sed -i.tmp "\|$INSTALL_DIR|d" "$config_file" 2>/dev/null || true
                # 移除conda初始化块（如果包含该路径）
                if grep -q "$INSTALL_DIR" "$config_file" 2>/dev/null; then
                    sed -i.tmp '/# >>> conda initialize >>>/,/# <<< conda initialize <<</d' "$config_file" 2>/dev/null || true
                fi
            fi
            
            # 清理临时文件
            rm -f "${config_file}.tmp" 2>/dev/null || true
            
            log_success "已清理配置文件: $config_file"
        fi
    done
}

# 清理全局配置
cleanup_global_config() {
    log_step "清理全局配置..."
    
    # 清理全局profile脚本
    if [[ -f "$CONDA_PROFILE_SCRIPT" ]]; then
        if [[ "$UNINSTALL_ALL" == "true" ]] || grep -q "$INSTALL_DIR" "$CONDA_PROFILE_SCRIPT" 2>/dev/null; then
            rm -f "$CONDA_PROFILE_SCRIPT"
            log_success "已删除全局conda配置: $CONDA_PROFILE_SCRIPT"
        fi
    fi
    
    # 清理其他可能的全局配置
    local global_configs=(
        "/etc/conda"
        "/etc/profile.d/miniconda.sh"
    )
    
    for config in "${global_configs[@]}"; do
        if [[ -e "$config" ]]; then
            if [[ "$UNINSTALL_ALL" == "true" ]] || grep -q "$INSTALL_DIR" "$config" 2>/dev/null; then
                rm -rf "$config"
                log_success "已删除全局配置: $config"
            fi
        fi
    done
}

# 删除安装目录
remove_installation_directory() {
    local target_dir="$1"
    
    log_step "删除安装目录: $target_dir"
    
    if [[ -d "$target_dir" ]]; then
        # 确认这是一个conda安装目录
        if [[ -f "$target_dir/bin/conda" ]] || [[ -f "$target_dir/condabin/conda" ]]; then
            log_info "正在删除Miniconda安装目录..."
            rm -rf "$target_dir"
            log_success "已删除安装目录: $target_dir"
        else
            log_warn "目录不像是Miniconda安装，跳过: $target_dir"
        fi
    else
        log_info "安装目录不存在: $target_dir"
    fi
}

# 清理用户数据
cleanup_user_data() {
    log_step "清理用户数据..."
    
    # conda相关的用户目录
    local user_dirs=(
        "$HOME/.conda"
        "$HOME/.continuum"
        "$HOME/.condarc"
    )
    
    for dir in "${user_dirs[@]}"; do
        if [[ -e "$dir" ]]; then
            echo -e "${YELLOW}发现用户数据: $dir${NC}"
            read -p "是否删除？ [y/N]: " -r response
            if [[ "$response" =~ ^[Yy]$ ]]; then
                rm -rf "$dir"
                log_success "已删除用户数据: $dir"
            else
                log_info "保留用户数据: $dir"
            fi
        fi
    done
}

# 清理缓存和临时文件
cleanup_cache_and_temp() {
    log_step "清理缓存和临时文件..."
    
    # conda缓存目录
    local cache_dirs=(
        "$HOME/.cache/conda"
        "$HOME/.cache/pip"
        "/tmp/conda-*"
        "/tmp/pip-*"
    )
    
    for cache_pattern in "${cache_dirs[@]}"; do
        # 使用glob展开
        for cache_dir in $cache_pattern; do
            if [[ -e "$cache_dir" ]]; then
                rm -rf "$cache_dir"
                log_success "已清理缓存: $cache_dir"
            fi
        done
    done
    
    # 清理可能的临时安装文件
    rm -f /tmp/Miniconda*.sh 2>/dev/null || true
    
    log_success "缓存和临时文件清理完成"
}

# 清理PATH环境变量
cleanup_path_variable() {
    log_step "清理PATH环境变量..."
    
    # 当前会话的PATH清理（仅作提示）
    if [[ "$UNINSTALL_ALL" == "true" ]]; then
        for install in "${FOUND_INSTALLATIONS[@]}"; do
            if echo "$PATH" | grep -q "$install"; then
                log_info "检测到PATH中包含: $install"
            fi
        done
    else
        if echo "$PATH" | grep -q "$INSTALL_DIR"; then
            log_info "检测到PATH中包含: $INSTALL_DIR"
        fi
    fi
    
    log_info "PATH变量将在重新登录后生效"
}

# 验证卸载
verify_uninstall() {
    log_step "验证卸载结果..."
    
    local issues_found=false
    
    # 检查conda命令
    if command -v conda >/dev/null 2>&1; then
        local remaining_conda=$(which conda)
        log_warn "仍然检测到conda命令: $remaining_conda"
        issues_found=true
    fi
    
    # 检查安装目录
    if [[ "$UNINSTALL_ALL" == "true" ]]; then
        for install in "${FOUND_INSTALLATIONS[@]}"; do
            if [[ -d "$install" ]]; then
                log_warn "安装目录仍然存在: $install"
                issues_found=true
            fi
        done
    else
        if [[ -d "$INSTALL_DIR" ]]; then
            log_warn "安装目录仍然存在: $INSTALL_DIR"
            issues_found=true
        fi
    fi
    
    # 检查环境变量配置
    local shell_configs=("$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile")
    for config in "${shell_configs[@]}"; do
        if [[ -f "$config" ]] && grep -q "conda" "$config" 2>/dev/null; then
            log_warn "配置文件中仍有conda相关内容: $config"
            issues_found=true
        fi
    done
    
    if [[ "$issues_found" == "false" ]]; then
        log_success "卸载验证通过，Miniconda已完全移除"
    else
        log_warn "卸载验证发现一些问题，可能需要手动清理"
    fi
}

# 显示卸载信息
show_uninstall_info() {
    log_header "Miniconda卸载完成！"
    
    echo -e "\n${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                        卸载信息                              ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}\n"
    
    echo -e "${CYAN}已删除的组件:${NC}"
    
    if [[ "$UNINSTALL_ALL" == "true" ]]; then
        echo -e "  • 所有Miniconda安装目录:"
        for install in "${FOUND_INSTALLATIONS[@]}"; do
            echo -e "    - $install"
        done
    else
        echo -e "  • Miniconda安装目录: $INSTALL_DIR"
    fi
    
    echo -e "  • 所有conda环境和包"
    echo -e "  • Shell配置文件中的conda初始化"
    echo -e "  • 环境变量配置"
    echo -e "  • 缓存和临时文件"
    
    echo -e "\n${CYAN}重要提示:${NC}"
    echo -e "  • 请重新启动终端或重新登录以使环境变量更改生效"
    echo -e "  • 如果使用了虚拟环境，相关项目可能需要重新配置Python解释器"
    echo -e "  • 备份的配置文件保存在原文件同目录下（.backup_*后缀）"
    
    if [[ -d "$HOME/.conda" ]] || [[ -f "$HOME/.condarc" ]]; then
        echo -e "\n${YELLOW}保留的用户数据:${NC}"
        [[ -d "$HOME/.conda" ]] && echo -e "  • $HOME/.conda - 用户选择保留"
        [[ -f "$HOME/.condarc" ]] && echo -e "  • $HOME/.condarc - 用户选择保留"
    fi
    
    echo -e "\n${CYAN}重新安装:${NC}"
    echo -e "  • 如需重新安装，请从官网下载最新版本"
    echo -e "  • 官网地址: https://docs.conda.io/en/latest/miniconda.html"
    
    echo -e "\n${GREEN}Miniconda卸载成功！${NC}\n"
}

# 主函数
main() {
    # 初始化
    init_logging
    show_banner
    
    # 系统检查
    detect_os
    
    # 检测安装
    if ! detect_miniconda_installation; then
        log_error "未找到Miniconda安装，无需卸载"
        exit 0
    fi
    
    # 选择安装
    select_installation
    confirm_uninstall
    
    # 卸载过程
    if [[ "$UNINSTALL_ALL" == "true" ]]; then
        for install_dir in "${FOUND_INSTALLATIONS[@]}"; do
            INSTALL_DIR="$install_dir"
            deactivate_conda
            remove_installation_directory "$install_dir"
        done
        # 清理所有相关配置
        cleanup_environment_variables
        cleanup_global_config
    else
        deactivate_conda
        remove_installation_directory "$INSTALL_DIR"
        cleanup_environment_variables
        cleanup_global_config
    fi
    
    cleanup_user_data
    cleanup_cache_and_temp
    cleanup_path_variable
    
    # 验证和总结
    verify_uninstall
    show_uninstall_info
    
    log_success "Miniconda卸载脚本执行完成！"
}

# 错误处理
trap 'log_error "脚本执行失败，退出码: $?"; exit 1' ERR

# 执行主函数
main "$@"