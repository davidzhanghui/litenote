#!/bin/bash

# XXL-JOB分布式任务调度平台安装脚本
# 安装XXL-JOB最新版本
# 支持CentOS/RHEL和Ubuntu/Debian系统
# 执行方式： ssh root@your-server 'bash -s' < ./scripts/install_server_soft/install_standalone/install_xxljob.sh

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# XXL-JOB配置
XXLJOB_VERSION="2.4.1"
XXLJOB_USER="xxljob"
XXLJOB_GROUP="xxljob"
XXLJOB_HOME="/opt/xxl-job"
XXLJOB_PORT="8080"
XXLJOB_DB_NAME="xxl_job"
XXLJOB_DB_USER="xxljob"
XXLJOB_DB_PASSWORD="xxljob123"
XXLJOB_ADMIN_PASSWORD="123456"
XXLJOB_ACCESS_TOKEN="default_token"

# MySQL配置
MYSQL_ROOT_PASSWORD="root123456"
MYSQL_PORT="3306"

# Java配置
JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"

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

# 安装Java环境
install_java() {
    log_step "检查Java环境..."
    
    # 检查Java是否已安装
    if command -v java >/dev/null 2>&1; then
        JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}' | awk -F '.' '{print $1$2}')
        if [ "$JAVA_VERSION" -ge "18" ]; then
            log_info "Java环境已存在，版本: $(java -version 2>&1 | head -n 1)"
            return 0
        fi
    fi
    
    log_step "安装Java 8环境..."
    
    if [ "$OS" = "centos" ]; then
        yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel
        JAVA_HOME="/usr/lib/jvm/java-1.8.0-openjdk"
    else
        apt install -y openjdk-8-jdk openjdk-8-jre
        JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"
    fi
    
    # 配置JAVA_HOME环境变量
    echo "export JAVA_HOME=$JAVA_HOME" >> /etc/profile
    echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> /etc/profile
    source /etc/profile
    
    log_info "Java环境安装完成"
}

# 安装MySQL数据库
install_mysql() {
    log_step "检查MySQL服务状态..."
    
    # 检查MySQL是否已安装并运行
    if systemctl is-active --quiet mysql 2>/dev/null || systemctl is-active --quiet mysqld 2>/dev/null; then
        log_info "MySQL服务已在运行，跳过安装"
        return 0
    fi
    
    log_step "安装MySQL数据库..."
    
    if [ "$OS" = "centos" ]; then
        # CentOS安装MySQL
        yum install -y mysql-server mysql
        systemctl start mysqld
        systemctl enable mysqld
        
        # 获取临时密码
        TEMP_PASSWORD=$(grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}' | tail -1)
        
        # 设置root密码
        mysql -uroot -p"$TEMP_PASSWORD" --connect-expired-password -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';" 2>/dev/null || {
            # 如果没有临时密码，直接设置
            mysqladmin -uroot password "$MYSQL_ROOT_PASSWORD" 2>/dev/null || true
        }
    else
        # Ubuntu安装MySQL
        export DEBIAN_FRONTEND=noninteractive
        apt install -y mysql-server mysql-client
        
        # 启动MySQL服务
        systemctl start mysql
        systemctl enable mysql
        
        # 设置root密码
        mysql -uroot -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$MYSQL_ROOT_PASSWORD';" 2>/dev/null || {
            mysqladmin -uroot password "$MYSQL_ROOT_PASSWORD" 2>/dev/null || true
        }
    fi
    
    log_info "MySQL数据库安装完成"
}

# 创建XXL-JOB数据库和用户
setup_database() {
    log_step "创建XXL-JOB数据库和用户..."
    
    # 创建数据库
    mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS $XXLJOB_DB_NAME DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    
    # 创建用户并授权
    mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "CREATE USER IF NOT EXISTS '$XXLJOB_DB_USER'@'%' IDENTIFIED BY '$XXLJOB_DB_PASSWORD';"
    mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "GRANT ALL PRIVILEGES ON $XXLJOB_DB_NAME.* TO '$XXLJOB_DB_USER'@'%';"
    mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "FLUSH PRIVILEGES;"
    
    log_info "数据库创建完成"
}

# 初始化XXL-JOB数据库表
init_database_tables() {
    log_step "初始化XXL-JOB数据库表..."
    
    # 创建数据库初始化SQL
    cat > /tmp/xxl_job_init.sql << 'EOF'
-- XXL-JOB数据库初始化脚本

-- 调度任务表
CREATE TABLE IF NOT EXISTS `xxl_job_info` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `job_group` int(11) NOT NULL COMMENT '执行器主键ID',
  `job_desc` varchar(255) NOT NULL,
  `add_time` datetime DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `author` varchar(64) DEFAULT NULL COMMENT '作者',
  `alarm_email` varchar(255) DEFAULT NULL COMMENT '报警邮件',
  `schedule_type` varchar(50) NOT NULL DEFAULT 'NONE' COMMENT '调度类型',
  `schedule_conf` varchar(128) DEFAULT NULL COMMENT '调度配置，值含义取决于调度类型',
  `misfire_strategy` varchar(50) NOT NULL DEFAULT 'DO_NOTHING' COMMENT '调度过期策略',
  `executor_route_strategy` varchar(50) DEFAULT NULL COMMENT '执行器路由策略',
  `executor_handler` varchar(255) DEFAULT NULL COMMENT '执行器任务handler',
  `executor_param` varchar(512) DEFAULT NULL COMMENT '执行器任务参数',
  `executor_block_strategy` varchar(50) DEFAULT NULL COMMENT '阻塞处理策略',
  `executor_timeout` int(11) NOT NULL DEFAULT '0' COMMENT '任务执行超时时间，单位秒',
  `executor_fail_retry_count` int(11) NOT NULL DEFAULT '0' COMMENT '失败重试次数',
  `glue_type` varchar(50) NOT NULL COMMENT 'GLUE类型',
  `glue_source` mediumtext COMMENT 'GLUE源代码',
  `glue_remark` varchar(128) DEFAULT NULL COMMENT 'GLUE备注',
  `glue_updatetime` datetime DEFAULT NULL COMMENT 'GLUE更新时间',
  `child_jobid` varchar(255) DEFAULT NULL COMMENT '子任务ID，多个逗号分隔',
  `trigger_status` tinyint(4) NOT NULL DEFAULT '0' COMMENT '调度状态：0-停止，1-运行',
  `trigger_last_time` bigint(13) NOT NULL DEFAULT '0' COMMENT '上次调度时间',
  `trigger_next_time` bigint(13) NOT NULL DEFAULT '0' COMMENT '下次调度时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 调度日志表
CREATE TABLE IF NOT EXISTS `xxl_job_log` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `job_group` int(11) NOT NULL COMMENT '执行器主键ID',
  `job_id` int(11) NOT NULL COMMENT '任务，主键ID',
  `executor_address` varchar(255) DEFAULT NULL COMMENT '执行器地址，本次执行的地址',
  `executor_handler` varchar(255) DEFAULT NULL COMMENT '执行器任务handler',
  `executor_param` varchar(512) DEFAULT NULL COMMENT '执行器任务参数',
  `executor_sharding_param` varchar(20) DEFAULT NULL COMMENT '执行器任务分片参数，格式如 1/2',
  `executor_fail_retry_count` int(11) NOT NULL DEFAULT '0' COMMENT '失败重试次数',
  `trigger_time` datetime DEFAULT NULL COMMENT '调度-时间',
  `trigger_code` int(11) NOT NULL COMMENT '调度-结果',
  `trigger_msg` text COMMENT '调度-日志',
  `handle_time` datetime DEFAULT NULL COMMENT '执行-时间',
  `handle_code` int(11) NOT NULL COMMENT '执行-状态',
  `handle_msg` text COMMENT '执行-日志',
  `alarm_status` tinyint(4) NOT NULL DEFAULT '0' COMMENT '告警状态：0-默认、1-无需告警、2-告警成功、3-告警失败',
  PRIMARY KEY (`id`),
  KEY `I_trigger_time` (`trigger_time`),
  KEY `I_handle_code` (`handle_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 调度日志报表表
CREATE TABLE IF NOT EXISTS `xxl_job_log_report` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `trigger_day` datetime DEFAULT NULL COMMENT '调度-时间',
  `running_count` int(11) NOT NULL DEFAULT '0' COMMENT '运行中-日志数量',
  `suc_count` int(11) NOT NULL DEFAULT '0' COMMENT '执行成功-日志数量',
  `fail_count` int(11) NOT NULL DEFAULT '0' COMMENT '执行失败-日志数量',
  `update_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `i_trigger_day` (`trigger_day`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 执行器信息表
CREATE TABLE IF NOT EXISTS `xxl_job_group` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `app_name` varchar(64) NOT NULL COMMENT '执行器AppName',
  `title` varchar(12) NOT NULL COMMENT '执行器名称',
  `address_type` tinyint(4) NOT NULL DEFAULT '0' COMMENT '执行器地址类型：0=自动注册、1=手动录入',
  `address_list` text COMMENT '执行器地址列表，多地址逗号分隔',
  `update_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 用户表
CREATE TABLE IF NOT EXISTS `xxl_job_user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL COMMENT '账号',
  `password` varchar(50) NOT NULL COMMENT '密码',
  `role` tinyint(4) NOT NULL COMMENT '角色：0-普通用户、1-管理员',
  `permission` varchar(255) DEFAULT NULL COMMENT '权限：执行器ID列表，多个逗号分割',
  PRIMARY KEY (`id`),
  UNIQUE KEY `i_username` (`username`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 权限表
CREATE TABLE IF NOT EXISTS `xxl_job_lock` (
  `lock_name` varchar(50) NOT NULL COMMENT '锁名称',
  PRIMARY KEY (`lock_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 插入默认数据
INSERT IGNORE INTO `xxl_job_group`(`id`, `app_name`, `title`, `address_type`, `address_list`, `update_time`) VALUES (1, 'xxl-job-executor-sample', '示例执行器', 0, NULL, '2018-11-03 22:21:31' );
INSERT IGNORE INTO `xxl_job_info`(`id`, `job_group`, `job_desc`, `add_time`, `update_time`, `author`, `alarm_email`, `schedule_type`, `schedule_conf`, `misfire_strategy`, `executor_route_strategy`, `executor_handler`, `executor_param`, `executor_block_strategy`, `executor_timeout`, `executor_fail_retry_count`, `glue_type`, `glue_source`, `glue_remark`, `glue_updatetime`, `child_jobid`, `trigger_status`, `trigger_last_time`, `trigger_next_time`) VALUES (1, 1, '测试任务1', '2018-11-03 22:21:31', '2018-11-03 22:21:31', 'XXL', '', 'CRON', '0 0 0 * * ? *', 'DO_NOTHING', 'FIRST', 'demoJobHandler', '', 'SERIAL_EXECUTION', 0, 0, 'BEAN', '', 'GLUE代码初始化', '2018-11-03 22:21:31', '', 0, 0, 0);
INSERT IGNORE INTO `xxl_job_user`(`id`, `username`, `password`, `role`, `permission`) VALUES (1, 'admin', 'e10adc3949ba59abbe56e057f20f883e', 1, NULL);
INSERT IGNORE INTO `xxl_job_lock` ( `lock_name`) VALUES ( 'schedule_lock');
EOF
    
    # 执行初始化SQL
    mysql -u"$XXLJOB_DB_USER" -p"$XXLJOB_DB_PASSWORD" "$XXLJOB_DB_NAME" < /tmp/xxl_job_init.sql
    
    # 清理临时文件
    rm -f /tmp/xxl_job_init.sql
    
    log_info "数据库表初始化完成"
}

# 创建XXL-JOB用户
create_xxljob_user() {
    log_step "创建XXL-JOB系统用户..."
    
    # 检查用户是否已存在
    if id "$XXLJOB_USER" >/dev/null 2>&1; then
        log_info "用户 $XXLJOB_USER 已存在，跳过创建"
        return 0
    fi
    
    # 创建用户组
    groupadd -f "$XXLJOB_GROUP"
    
    # 创建用户
    useradd -r -g "$XXLJOB_GROUP" -s /bin/bash -d "$XXLJOB_HOME" "$XXLJOB_USER"
    
    log_info "用户创建完成"
}

# 下载并安装XXL-JOB
install_xxljob() {
    log_step "下载并安装XXL-JOB..."
    
    # 创建安装目录
    mkdir -p "$XXLJOB_HOME"
    cd "$XXLJOB_HOME"
    
    # 下载XXL-JOB
    log_info "下载XXL-JOB v$XXLJOB_VERSION..."
    
    # 尝试从GitHub下载
    if ! wget -O xxl-job-admin-$XXLJOB_VERSION.jar "https://github.com/xuxueli/xxl-job/releases/download/v$XXLJOB_VERSION/xxl-job-admin-$XXLJOB_VERSION.jar" 2>/dev/null; then
        # 备用：从镜像站下载
        log_warn "GitHub下载失败，尝试从镜像站下载..."
        if ! wget -O xxl-job-admin-$XXLJOB_VERSION.jar "https://ghproxy.com/https://github.com/xuxueli/xxl-job/releases/download/v$XXLJOB_VERSION/xxl-job-admin-$XXLJOB_VERSION.jar"; then
            log_error "下载失败，请检查网络连接"
            exit 1
        fi
    fi
    
    # 创建符号链接
    ln -sf xxl-job-admin-$XXLJOB_VERSION.jar xxl-job-admin.jar
    
    log_info "XXL-JOB下载完成"
}

# 配置XXL-JOB
configure_xxljob() {
    log_step "配置XXL-JOB..."
    
    # 创建配置文件
    cat > "$XXLJOB_HOME/application.properties" << EOF
# XXL-JOB配置文件

# 服务端口
server.port=$XXLJOB_PORT
server.servlet.context-path=/xxl-job-admin

# 数据库配置
spring.datasource.url=jdbc:mysql://127.0.0.1:$MYSQL_PORT/$XXLJOB_DB_NAME?useUnicode=true&characterEncoding=UTF-8&autoReconnect=true&serverTimezone=Asia/Shanghai
spring.datasource.username=$XXLJOB_DB_USER
spring.datasource.password=$XXLJOB_DB_PASSWORD
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver

# 数据库连接池配置
spring.datasource.type=com.zaxxer.hikari.HikariDataSource
spring.datasource.hikari.minimum-idle=10
spring.datasource.hikari.maximum-pool-size=30
spring.datasource.hikari.auto-commit=true
spring.datasource.hikari.idle-timeout=30000
spring.datasource.hikari.pool-name=HikariCP
spring.datasource.hikari.max-lifetime=900000
spring.datasource.hikari.connection-timeout=10000
spring.datasource.hikari.connection-test-query=SELECT 1

# 邮件配置（可选）
spring.mail.host=smtp.qq.com
spring.mail.port=25
spring.mail.username=xxx@qq.com
spring.mail.password=xxx
spring.mail.properties.mail.smtp.auth=true
spring.mail.properties.mail.smtp.starttls.enable=true
spring.mail.properties.mail.smtp.starttls.required=true
spring.mail.properties.mail.smtp.socketFactory.class=javax.net.ssl.SSLSocketFactory

# 调度中心通讯TOKEN [选填]：非空时启用；
xxl.job.accessToken=$XXLJOB_ACCESS_TOKEN

# 调度中心国际化配置 [必填]： 默认为 "zh_CN"/中文简体, 可选范围为 "zh_CN"/中文简体, "zh_TC"/中文繁体 and "en"/英文；
xxl.job.i18n=zh_CN

# 调度线程池最大线程配置【必填】
xxl.job.triggerpool.fast.max=200
xxl.job.triggerpool.slow.max=100

# 调度中心日志表数据保存天数 [必填]：过期日志自动清理；限制大于等于7时生效，否则, 如-1，关闭自动清理功能；
xxl.job.logretentiondays=30
EOF
    
    # 创建日志目录
    mkdir -p "$XXLJOB_HOME/logs"
    
    # 设置文件权限
    chown -R "$XXLJOB_USER:$XXLJOB_GROUP" "$XXLJOB_HOME"
    chmod +x "$XXLJOB_HOME/xxl-job-admin.jar"
    
    log_info "XXL-JOB配置完成"
}

# 创建systemd服务
create_systemd_service() {
    log_step "创建systemd服务..."
    
    cat > /etc/systemd/system/xxl-job.service << EOF
[Unit]
Description=XXL-JOB Distributed Task Scheduling Platform
After=network.target mysql.service
Requires=mysql.service

[Service]
Type=simple
User=$XXLJOB_USER
Group=$XXLJOB_GROUP
WorkingDirectory=$XXLJOB_HOME
ExecStart=/usr/bin/java -Xms512m -Xmx1024m -jar $XXLJOB_HOME/xxl-job-admin.jar --spring.config.location=$XXLJOB_HOME/application.properties
ExecStop=/bin/kill -TERM \$MAINPID
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=xxl-job

# 环境变量
Environment=JAVA_HOME=$JAVA_HOME
Environment=PATH=$JAVA_HOME/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# 安全配置
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ReadWritePaths=$XXLJOB_HOME

[Install]
WantedBy=multi-user.target
EOF
    
    # 重新加载systemd配置
    systemctl daemon-reload
    
    log_info "systemd服务创建完成"
}

# 启动XXL-JOB服务
start_xxljob_service() {
    log_step "启动XXL-JOB服务..."
    
    # 启动并设置开机自启
    systemctl enable xxl-job
    systemctl start xxl-job
    
    # 等待服务启动
    sleep 10
    
    # 检查服务状态
    if systemctl is-active --quiet xxl-job; then
        log_info "XXL-JOB服务启动成功"
    else
        log_error "XXL-JOB服务启动失败"
        systemctl status xxl-job
        exit 1
    fi
}

# 配置防火墙
configure_firewall() {
    log_step "配置防火墙..."
    
    if command -v firewall-cmd >/dev/null 2>&1; then
        # CentOS/RHEL防火墙配置
        firewall-cmd --permanent --add-port=$XXLJOB_PORT/tcp
        firewall-cmd --reload
        log_info "防火墙配置完成（CentOS/RHEL）"
    elif command -v ufw >/dev/null 2>&1; then
        # Ubuntu防火墙配置
        ufw allow $XXLJOB_PORT/tcp
        log_info "防火墙配置完成（Ubuntu）"
    else
        log_warn "未检测到防火墙管理工具，请手动开放端口 $XXLJOB_PORT"
    fi
}

# 验证安装
verify_installation() {
    log_step "验证安装..."
    
    # 检查Java版本
    if command -v java >/dev/null 2>&1; then
        log_info "Java版本: $(java -version 2>&1 | head -n 1)"
    else
        log_error "Java未正确安装"
        exit 1
    fi
    
    # 检查MySQL服务
    if systemctl is-active --quiet mysql 2>/dev/null || systemctl is-active --quiet mysqld 2>/dev/null; then
        log_info "MySQL服务运行正常"
    else
        log_error "MySQL服务未运行"
        exit 1
    fi
    
    # 检查XXL-JOB服务
    if systemctl is-active --quiet xxl-job; then
        log_info "XXL-JOB服务运行正常"
    else
        log_error "XXL-JOB服务未运行"
        exit 1
    fi
    
    # 检查端口监听
    if netstat -tlnp | grep ":$XXLJOB_PORT " >/dev/null 2>&1; then
        log_info "XXL-JOB端口 $XXLJOB_PORT 监听正常"
    else
        log_warn "XXL-JOB端口 $XXLJOB_PORT 未监听，可能正在启动中"
    fi
    
    log_info "安装验证完成"
}

# 显示安装信息
show_info() {
    echo ""
    echo "================================================="
    echo "          XXL-JOB安装完成！"
    echo "================================================="
    echo ""
    echo "安装信息:"
    echo "  版本: XXL-JOB v$XXLJOB_VERSION"
    echo "  安装目录: $XXLJOB_HOME"
    echo "  运行用户: $XXLJOB_USER"
    echo "  服务端口: $XXLJOB_PORT"
    echo "  访问地址: http://$(hostname -I | awk '{print $1}'):$XXLJOB_PORT/xxl-job-admin"
    echo "  默认账号: admin"
    echo "  默认密码: $XXLJOB_ADMIN_PASSWORD"
    echo ""
    echo "数据库信息:"
    echo "  数据库名: $XXLJOB_DB_NAME"
    echo "  数据库用户: $XXLJOB_DB_USER"
    echo "  数据库密码: $XXLJOB_DB_PASSWORD"
    echo "  MySQL端口: $MYSQL_PORT"
    echo ""
    echo "服务管理命令:"
    echo "  启动服务: systemctl start xxl-job"
    echo "  停止服务: systemctl stop xxl-job"
    echo "  重启服务: systemctl restart xxl-job"
    echo "  查看状态: systemctl status xxl-job"
    echo "  查看日志: journalctl -u xxl-job -f"
    echo "  开机自启: systemctl enable xxl-job"
    echo "  禁用自启: systemctl disable xxl-job"
    echo ""
    echo "配置文件:"
    echo "  应用配置: $XXLJOB_HOME/application.properties"
    echo "  系统服务: /etc/systemd/system/xxl-job.service"
    echo "  应用日志: $XXLJOB_HOME/logs/"
    echo "  系统日志: journalctl -u xxl-job"
    echo ""
    echo "常用功能:"
    echo "  1. 登录管理后台创建执行器"
    echo "  2. 配置定时任务"
    echo "  3. 监控任务执行状态"
    echo "  4. 查看执行日志"
    echo "  5. 配置报警通知"
    echo ""
    echo "注意事项:"
    echo "  1. 首次登录请及时修改默认密码"
    echo "  2. 生产环境请修改数据库密码和访问令牌"
    echo "  3. 建议配置邮件服务用于任务报警"
    echo "  4. 定期备份数据库数据"
    echo "  5. 监控服务运行状态和日志"
    echo ""
    echo "================================================="
}

# 主函数
main() {
    log_info "开始安装XXL-JOB分布式任务调度平台..."
    
    # 检查是否为root用户
    if [ "$EUID" -ne 0 ]; then
        log_error "请使用root用户运行此脚本"
        exit 1
    fi
    
    # 执行安装步骤
    detect_os
    update_system
    install_java
    install_mysql
    setup_database
    init_database_tables
    create_xxljob_user
    install_xxljob
    configure_xxljob
    create_systemd_service
    start_xxljob_service
    configure_firewall
    verify_installation
    show_info
    
    log_info "XXL-JOB安装脚本执行完成！"
}

# 执行主函数
main "$@"