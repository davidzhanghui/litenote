# Git环境卸载脚本说明

## 脚本概述

`uninstall_git.sh` 是一个自动化卸载Git环境的Shell脚本，支持在CentOS/RHEL和Ubuntu/Debian系统上安全卸载Git及其相关配置。

## 功能特性

- ✅ 自动检测操作系统类型（CentOS/Ubuntu）
- ✅ 智能检查Git安装状态
- ✅ 自动备份Git配置文件
- ✅ 安全卸载Git软件包
- ✅ 可选择性清理依赖包
- ✅ 可选择性删除配置文件
- ✅ 卸载后验证和信息展示
- ✅ 彩色日志输出，便于查看执行状态
- ✅ 交互式确认，防止误操作

## 系统要求

### 支持的操作系统
- CentOS 7/8
- RHEL 7/8
- Ubuntu 18.04/20.04/22.04
- Debian 9/10/11

### 权限要求
- 必须使用root用户执行
- 需要确认卸载操作

## 使用方法

### 1. 下载脚本
```bash
# 如果脚本已在服务器上
cd /path/to/scripts

# 或者从远程下载
wget https://your-server.com/uninstall_git.sh
```

### 2. 添加执行权限
```bash
chmod +x uninstall_git.sh
```

### 3. 执行卸载
```bash
# 使用root用户执行
sudo ./uninstall_git.sh

# 或者切换到root用户后执行
su -
./uninstall_git.sh
```

## 卸载流程

### 1. 安全检查
- 检测操作系统类型
- 确认Git是否已安装
- 要求用户确认卸载操作

### 2. 配置备份
脚本会自动备份以下配置文件：
- 全局配置：`~/.gitconfig`
- 系统配置：`/etc/gitconfig`
- 所有用户配置：`/home/*/gitconfig`

备份位置：`/tmp/git_config_backup_YYYYMMDD_HHMMSS/`

### 3. 软件卸载

#### CentOS/RHEL系统
```bash
# 卸载Git
yum remove -y git

# 可选：卸载开发工具包（需用户确认）
yum groupremove -y "Development Tools"
yum remove -y gettext-devel openssl-devel perl-CPAN perl-devel zlib-devel curl-devel
```

#### Ubuntu/Debian系统
```bash
# 卸载Git
apt remove -y git
apt autoremove -y

# 可选：卸载相关依赖（需用户确认）
apt remove -y make libssl-dev libghc-zlib-dev libcurl4-gnutls-dev libncurses5-dev libncursesw5-dev libedit-dev
apt autoremove -y
```

### 4. 配置清理
用户可选择是否删除Git配置文件：
- 全局配置文件
- 系统配置文件
- 用户配置文件

### 5. 卸载验证
- 检查Git命令是否仍然存在
- 检查配置文件清理状态
- 显示卸载结果

## 交互式选项

### 1. 卸载确认
```
确定要卸载Git吗？此操作不可逆 (y/N)
```

### 2. 依赖包卸载确认
```
是否同时卸载开发工具包？这可能影响其他软件 (y/N)
是否同时卸载Git相关依赖？这可能影响其他软件 (y/N)
```

### 3. 配置文件删除确认
```
是否删除所有Git配置文件？(y/N)
```

## 预期输出示例

```
[INFO] 开始卸载Git环境...
[WARN] 确定要卸载Git吗？此操作不可逆 (y/N)
y
[INFO] 检测到Ubuntu/Debian系统
[STEP] 检查Git安装状态...
[INFO] 检测到Git版本: 2.x.x
[STEP] 备份Git配置...
[INFO] 全局配置已备份到: /tmp/git_config_backup_20231201_143022/gitconfig_global
[STEP] 卸载Git...
[WARN] 是否同时卸载Git相关依赖？这可能影响其他软件 (y/N)
n
[INFO] Git卸载完成
[STEP] 清理Git配置文件...
[WARN] 是否删除所有Git配置文件？(y/N)
y
[INFO] 已删除全局配置文件: ~/.gitconfig
[STEP] 验证Git卸载结果...
==================== Git卸载验证 ====================
[INFO] Git已成功卸载
...
[INFO] Git卸载验证完成
==================== Git卸载完成 ====================
[INFO] Git环境卸载完成！
```

## 备份和恢复

### 配置备份位置
```
/tmp/git_config_backup_YYYYMMDD_HHMMSS/
├── gitconfig_global      # 全局配置备份
├── gitconfig_system      # 系统配置备份
├── gitconfig_username1   # 用户1配置备份
└── gitconfig_username2   # 用户2配置备份
```

### 恢复配置
如需恢复Git配置：

```bash
# 恢复全局配置
cp /tmp/git_config_backup_*/gitconfig_global ~/.gitconfig

# 恢复系统配置
cp /tmp/git_config_backup_*/gitconfig_system /etc/gitconfig

# 恢复特定用户配置
cp /tmp/git_config_backup_*/gitconfig_username /home/username/.gitconfig
```

## 安全注意事项

### 1. 依赖包卸载风险
- 开发工具包可能被其他软件使用
- 建议谨慎选择是否卸载依赖包
- 如不确定，选择保留依赖包

### 2. 配置文件备份
- 所有配置文件都会自动备份
- 备份文件保存在 `/tmp` 目录
- 建议将重要配置复制到安全位置

### 3. 本地仓库影响
- Git卸载不会删除本地Git仓库
- 仓库文件和历史记录保持完整
- 重新安装Git后可继续使用

## 常见问题

### Q1: 卸载后如何重新安装Git？
**A:** 使用对应的安装脚本：
```bash
./install_git.sh
```

### Q2: 卸载后本地Git仓库还能用吗？
**A:** 仓库文件不受影响，但需要重新安装Git才能使用Git命令操作仓库。

### Q3: 如何恢复Git配置？
**A:** 从备份目录恢复：
```bash
cp /tmp/git_config_backup_*/gitconfig_global ~/.gitconfig
```

### Q4: 误删了配置文件怎么办？
**A:** 从自动备份中恢复，或重新配置：
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### Q5: 卸载失败怎么办？
**A:** 检查以下项目：
- 是否使用root权限
- 是否有其他进程占用Git
- 网络连接是否正常
- 包管理器是否正常工作

### Q6: 如何完全清理Git相关文件？
**A:** 手动清理剩余文件：
```bash
# 查找Git相关文件
find / -name "*git*" -type f 2>/dev/null

# 清理用户目录下的Git文件
rm -rf ~/.git*

# 清理系统Git文件（谨慎操作）
rm -rf /etc/git*
```

## 故障排除

### 1. 权限问题
```bash
# 确保使用root权限
sudo ./uninstall_git.sh
```

### 2. 包管理器问题
```bash
# CentOS/RHEL - 清理yum缓存
yum clean all

# Ubuntu/Debian - 修复包管理器
apt --fix-broken install
```

### 3. 进程占用问题
```bash
# 查找使用Git的进程
ps aux | grep git

# 终止相关进程
killall git
```

## 日志说明

脚本使用彩色日志输出：
- 🟢 **[INFO]** - 信息提示（绿色）
- 🔵 **[STEP]** - 执行步骤（蓝色）
- 🟡 **[WARN]** - 警告信息（黄色）
- 🔴 **[ERROR]** - 错误信息（红色）

## 技术支持

如遇到问题，请检查：
1. 系统版本是否支持
2. 是否使用root权限执行
3. Git是否正在被其他进程使用
4. 包管理器是否正常工作
5. 磁盘空间是否充足

## 更新日志

- v1.0 - 初始版本，支持Git卸载
- 支持CentOS/RHEL和Ubuntu/Debian系统
- 自动配置备份功能
- 交互式确认机制
- 卸载验证功能
- 安全清理选项

## 相关脚本

- `install_git.sh` - Git安装脚本
- `uninstall_git.sh` - Git卸载脚本
- `install_git_README.md` - 安装说明文档
- `uninstall_git_README.md` - 卸载说明文档