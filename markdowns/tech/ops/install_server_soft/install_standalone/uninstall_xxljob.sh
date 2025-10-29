#!/bin/bash

# XXL-JOB分布式任务调度平台卸载脚本
# 完全卸载XXL-JOB及相关组件
# 支持CentOS/RHEL和Ubuntu/Debian系统
# 执行方式： ssh root@your-server 'bash -s' < ./scripts/install_server_soft/install_standalone/uninstall_xxljob.sh

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# XXL-JOB配置
XXLJOB_USER="xxljob"
XXLJOB_GROUP="xxljob"
XXLJOB_HOME="/opt/xxl-job"
XXLJOB_SERVICE="xxl-job"
XXLJOB_DB_NAME="xxl_job"
XXLJOB_DB_USER="xxljob"

# 备份目录
BACKUP_DIR="/tmp/xxljob_backup_$(date +%Y%m%d_%H%M%S)"

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
    echo "================================================="
    echo "          XXL-JOB卸载确认"
    echo "================================================="
    echo ""
    echo "警告: 此操作将完全卸载XXL-JOB及其相关组件！"
    echo ""
    echo "将要执行的操作:"
    echo "  1. 停止XXL-JOB服务"
    echo "  2. 删除systemd服务文件"
    echo "  3. 删除XXL-JOB安装目录"
    echo "  4. 删除XXL-JOB用户和用户组"
    echo "  5. 删除XXL-JOB数据库和用户（可选）"
    echo "  6. 清理防火墙规则"
    echo "  7. 清理系统配置"
    echo ""
    echo "注意事项:"
    echo "  - 所有任务配置和执行日志将被删除"
    echo "  - 数据库数据将被永久删除（如选择删除数据库）"
    echo "  - 建议在卸载前备份重要数据"
    echo ""
    
    read -p "是否继续卸载？(y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "取消卸载操作"
        exit 0
    fi
    
    echo ""
    read -p "是否同时删除XXL-JOB数据库？(y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        DELETE_DATABASE=true
        log_warn "将删除XXL-JOB数据库，所有数据将丢失！"
    else
        DELETE_DATABASE=false
        log_info "保留XXL-JOB数据库"
    fi
    
    echo ""
    read -p "是否创建配置备份？(Y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        CREATE_BACKUP=true
        log_info "将创建配置备份到: $BACKUP_DIR"
    else
        CREATE_BACKUP=false
        log_info "不创建备份"
    fi
}

# 创建备份
create_backup() {
    if [ "$CREATE_BACKUP" = true ]; then
        log_step "创建配置备份..."
        
        mkdir -p "$BACKUP_DIR"
        
        # 备份配置文件
        if [ -f "$XXLJOB_HOME/application.properties" ]; then
            cp "$XXLJOB_HOME/application.properties" "$BACKUP_DIR/"
            log_info "已备份应用配置文件"
        fi
        
        # 备份服务文件
        if [ -f "/etc/systemd/system/$XXLJOB_SERVICE.service" ]; then
            cp "/etc/systemd/system/$XXLJOB_SERVICE.service" "$BACKUP_DIR/"
            log_info "已备份systemd服务文件"
        fi
        
        # 备份数据库（如果不删除数据库）
        if [ "$DELETE_DATABASE" = false ] && command -v mysqldump >/dev/null 2>&1; then
            if mysql -u"$XXLJOB_DB_USER" -e "USE $XXLJOB_DB_NAME;" 2>/dev/null; then
                read -s -p "请输入XXL-JOB数据库密码: " DB_PASSWORD
                echo
                if mysqldump -u"$XXLJOB_DB_USER" -p"$DB_PASSWORD" "$XXLJOB_DB_NAME" > "$BACKUP_DIR/xxl_job_backup.sql" 2>/dev/null; then
                    log_info "已备份XXL-JOB数据库"
                else
                    log_warn "数据库备份失败，请手动备份"
                fi
            fi
        fi
        
        # 创建备份说明文件
        cat > "$BACKUP_DIR/README.txt" << EOF
XXL-JOB卸载备份
================

备份时间: $(date)
备份内容:
- application.properties: XXL-JOB应用配置文件
- xxl-job.service: systemd服务配置文件
- xxl_job_backup.sql: 数据库备份文件（如果存在）

恢复说明:
1. 重新安装XXL-JOB
2. 停止服务: systemctl stop xxl-job
3. 恢复配置: cp application.properties /opt/xxl-job/
4. 恢复数据库: mysql -uxxljob -p xxl_job < xxl_job_backup.sql
5. 启动服务: systemctl start xxl-job
EOF
        
        log_info "备份创建完成: $BACKUP_DIR"
    fi
}

# 停止XXL-JOB服务
stop_xxljob_service() {
    log_step "停止XXL-JOB服务..."
    
    # 检查服务是否存在
    if systemctl list-unit-files | grep -q "$XXLJOB_SERVICE.service"; then
        # 停止服务
        if systemctl is-active --quiet "$XXLJOB_SERVICE"; then
            systemctl stop "$XXLJOB_SERVICE"
            log_info "XXL-JOB服务已停止"
        else
            log_info "XXL-JOB服务未运行"
        fi
        
        # 禁用开机自启
        if systemctl is-enabled --quiet "$XXLJOB_SERVICE" 2>/dev/null; then
            systemctl disable "$XXLJOB_SERVICE"
            log_info "已禁用XXL-JOB开机自启"
        fi
    else
        log_info "XXL-JOB服务不存在，跳过停止操作"
    fi
}

# 删除systemd服务文件
remove_systemd_service() {
    log_step "删除systemd服务文件..."
    
    SERVICE_FILE="/etc/systemd/system/$XXLJOB_SERVICE.service"
    
    if [ -f "$SERVICE_FILE" ]; then
        rm -f "$SERVICE_FILE"
        systemctl daemon-reload
        log_info "systemd服务文件已删除"
    else
        log_info "systemd服务文件不存在，跳过删除"
    fi
}

# 删除XXL-JOB安装目录
remove_xxljob_files() {
    log_step "删除XXL-JOB安装目录..."
    
    if [ -d "$XXLJOB_HOME" ]; then
        # 确保目录不被占用
        if lsof "$XXLJOB_HOME" 2>/dev/null; then
            log_warn "安装目录被占用，强制删除"
            fuser -k "$XXLJOB_HOME" 2>/dev/null || true
            sleep 2
        fi
        
        rm -rf "$XXLJOB_HOME"
        log_info "XXL-JOB安装目录已删除"
    else
        log_info "XXL-JOB安装目录不存在，跳过删除"
    fi
}

# 删除XXL-JOB用户和用户组
remove_xxljob_user() {
    log_step "删除XXL-JOB用户和用户组..."
    
    # 删除用户
    if id "$XXLJOB_USER" >/dev/null 2>&1; then
        # 终止用户进程
        pkill -u "$XXLJOB_USER" 2>/dev/null || true
        sleep 2
        
        # 删除用户
        userdel -r "$XXLJOB_USER" 2>/dev/null || {
            # 如果家目录删除失败，强制删除用户
            userdel "$XXLJOB_USER" 2>/dev/null || true
        }
        log_info "用户 $XXLJOB_USER 已删除"
    else
        log_info "用户 $XXLJOB_USER 不存在，跳过删除"
    fi
    
    # 删除用户组
    if getent group "$XXLJOB_GROUP" >/dev/null 2>&1; then
        groupdel "$XXLJOB_GROUP" 2>/dev/null || true
        log_info "用户组 $XXLJOB_GROUP 已删除"
    else
        log_info "用户组 $XXLJOB_GROUP 不存在，跳过删除"
    fi
}

# 删除数据库
remove_database() {
    if [ "$DELETE_DATABASE" = true ]; then
        log_step "删除XXL-JOB数据库..."
        
        # 检查MySQL是否运行
        if ! (systemctl is-active --quiet mysql 2>/dev/null || systemctl is-active --quiet mysqld 2>/dev/null); then
            log_warn "MySQL服务未运行，跳过数据库删除"
            return 0
        fi
        
        # 获取root密码
        read -s -p "请输入MySQL root密码: " MYSQL_ROOT_PASSWORD
        echo
        
        # 测试连接
        if ! mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "SELECT 1;" >/dev/null 2>&1; then
            log_error "MySQL连接失败，跳过数据库删除"
            return 1
        fi
        
        # 删除数据库
        mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "DROP DATABASE IF EXISTS $XXLJOB_DB_NAME;" 2>/dev/null
        log_info "数据库 $XXLJOB_DB_NAME 已删除"
        
        # 删除数据库用户
        mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "DROP USER IF EXISTS '$XXLJOB_DB_USER'@'%';" 2>/dev/null
        mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "DROP USER IF EXISTS '$XXLJOB_DB_USER'@'localhost';" 2>/dev/null
        mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "FLUSH PRIVILEGES;" 2>/dev/null
        log_info "数据库用户 $XXLJOB_DB_USER 已删除"
    else
        log_info "保留XXL-JOB数据库"
    fi
}

# 清理防火墙规则
cleanup_firewall() {
    log_step "清理防火墙规则..."
    
    # 获取XXL-JOB端口（从配置文件或默认值）
    XXLJOB_PORT="8080"
    if [ -f "$BACKUP_DIR/application.properties" ]; then
        XXLJOB_PORT=$(grep "^server.port=" "$BACKUP_DIR/application.properties" 2>/dev/null | cut -d'=' -f2 | tr -d ' ' || echo "8080")
    fi
    
    if command -v firewall-cmd >/dev/null 2>&1; then
        # CentOS/RHEL防火墙清理
        if firewall-cmd --list-ports | grep -q "$XXLJOB_PORT/tcp"; then
            firewall-cmd --permanent --remove-port="$XXLJOB_PORT/tcp" 2>/dev/null || true
            firewall-cmd --reload 2>/dev/null || true
            log_info "已清理防火墙规则（CentOS/RHEL）"
        fi
    elif command -v ufw >/dev/null 2>&1; then
        # Ubuntu防火墙清理
        ufw --force delete allow "$XXLJOB_PORT/tcp" 2>/dev/null || true
        log_info "已清理防火墙规则（Ubuntu）"
    else
        log_warn "未检测到防火墙管理工具，请手动清理端口 $XXLJOB_PORT 的规则"
    fi
}

# 清理系统配置
cleanup_system_config() {
    log_step "清理系统配置..."
    
    # 清理环境变量（如果有的话）
    if grep -q "XXL_JOB" /etc/profile 2>/dev/null; then
        sed -i '/XXL_JOB/d' /etc/profile
        log_info "已清理环境变量"
    fi
    
    # 清理日志轮转配置（如果有的话）
    if [ -f "/etc/logrotate.d/xxl-job" ]; then
        rm -f "/etc/logrotate.d/xxl-job"
        log_info "已清理日志轮转配置"
    fi
    
    # 清理cron任务（如果有的话）
    if crontab -l 2>/dev/null | grep -q "xxl-job\|XXL-JOB"; then
        crontab -l 2>/dev/null | grep -v "xxl-job\|XXL-JOB" | crontab - 2>/dev/null || true
        log_info "已清理定时任务"
    fi
    
    log_info "系统配置清理完成"
}

# 清理临时文件
cleanup_temp_files() {
    log_step "清理临时文件..."
    
    # 清理可能的临时文件
    rm -f /tmp/xxl_job_*.sql 2>/dev/null || true
    rm -f /tmp/xxljob_*.log 2>/dev/null || true
    
    # 清理系统日志中的相关条目（可选）
    if command -v journalctl >/dev/null 2>&1; then
        # 清理journal日志（保留系统完整性，只是提醒）
        log_info "系统日志中的XXL-JOB相关条目将随时间自动清理"
    fi
    
    log_info "临时文件清理完成"
}

# 验证卸载
verify_uninstall() {
    log_step "验证卸载结果..."
    
    local issues=0
    
    # 检查服务是否已删除
    if systemctl list-unit-files | grep -q "$XXLJOB_SERVICE.service"; then
        log_warn "systemd服务文件仍然存在"
        issues=$((issues + 1))
    else
        log_info "✓ systemd服务文件已删除"
    fi
    
    # 检查安装目录是否已删除
    if [ -d "$XXLJOB_HOME" ]; then
        log_warn "安装目录仍然存在: $XXLJOB_HOME"
        issues=$((issues + 1))
    else
        log_info "✓ 安装目录已删除"
    fi
    
    # 检查用户是否已删除
    if id "$XXLJOB_USER" >/dev/null 2>&1; then
        log_warn "用户仍然存在: $XXLJOB_USER"
        issues=$((issues + 1))
    else
        log_info "✓ 用户已删除"
    fi
    
    # 检查用户组是否已删除
    if getent group "$XXLJOB_GROUP" >/dev/null 2>&1; then
        log_warn "用户组仍然存在: $XXLJOB_GROUP"
        issues=$((issues + 1))
    else
        log_info "✓ 用户组已删除"
    fi
    
    # 检查端口是否仍在监听
    if netstat -tlnp 2>/dev/null | grep -q ":8080 "; then
        log_warn "端口8080仍在监听，可能有其他服务使用"
    else
        log_info "✓ XXL-JOB端口已释放"
    fi
    
    # 检查数据库（如果选择删除）
    if [ "$DELETE_DATABASE" = true ]; then
        if command -v mysql >/dev/null 2>&1 && (systemctl is-active --quiet mysql 2>/dev/null || systemctl is-active --quiet mysqld 2>/dev/null); then
            if mysql -uroot -e "USE $XXLJOB_DB_NAME;" 2>/dev/null; then
                log_warn "数据库仍然存在: $XXLJOB_DB_NAME"
                issues=$((issues + 1))
            else
                log_info "✓ 数据库已删除"
            fi
        fi
    fi
    
    if [ $issues -eq 0 ]; then
        log_info "卸载验证通过，所有组件已成功删除"
    else
        log_warn "发现 $issues 个问题，请手动检查和清理"
    fi
}

# 显示卸载结果
show_uninstall_result() {
    echo ""
    echo "================================================="
    echo "          XXL-JOB卸载完成！"
    echo "================================================="
    echo ""
    echo "卸载摘要:"
    echo "  ✓ XXL-JOB服务已停止并删除"
    echo "  ✓ 安装目录已删除: $XXLJOB_HOME"
    echo "  ✓ 系统用户已删除: $XXLJOB_USER"
    echo "  ✓ systemd服务文件已删除"
    echo "  ✓ 防火墙规则已清理"
    echo "  ✓ 系统配置已清理"
    
    if [ "$DELETE_DATABASE" = true ]; then
        echo "  ✓ 数据库已删除: $XXLJOB_DB_NAME"
        echo "  ✓ 数据库用户已删除: $XXLJOB_DB_USER"
    else
        echo "  ⚠ 数据库已保留: $XXLJOB_DB_NAME"
    fi
    
    if [ "$CREATE_BACKUP" = true ]; then
        echo "  ✓ 配置备份已创建: $BACKUP_DIR"
    fi
    
    echo ""
    echo "注意事项:"
    echo "  1. Java和MySQL环境已保留（如需卸载请单独处理）"
    echo "  2. 系统日志中的相关条目将随时间自动清理"
    
    if [ "$CREATE_BACKUP" = true ]; then
        echo "  3. 如需恢复，请参考备份目录中的README.txt文件"
    fi
    
    if [ "$DELETE_DATABASE" = false ]; then
        echo "  4. 数据库已保留，如需删除请手动执行:"
        echo "     mysql -uroot -p -e \"DROP DATABASE $XXLJOB_DB_NAME;\""
        echo "     mysql -uroot -p -e \"DROP USER '$XXLJOB_DB_USER'@'%';\""
    fi
    
    echo ""
    echo "如需重新安装XXL-JOB，请运行安装脚本:"
    echo "  ./install_xxljob.sh"
    echo ""
    echo "================================================="
}

# 主函数
main() {
    log_info "开始卸载XXL-JOB分布式任务调度平台..."
    
    # 检查是否为root用户
    if [ "$EUID" -ne 0 ]; then
        log_error "请使用root用户运行此脚本"
        exit 1
    fi
    
    # 执行卸载步骤
    detect_os
    confirm_uninstall
    create_backup
    stop_xxljob_service
    remove_systemd_service
    remove_xxljob_files
    remove_xxljob_user
    remove_database
    cleanup_firewall
    cleanup_system_config
    cleanup_temp_files
    verify_uninstall
    show_uninstall_result
    
    log_info "XXL-JOB卸载脚本执行完成！"
}

# 执行主函数
main "$@"