# Git环境安装脚本说明

## 脚本概述

`install_git.sh` 是一个自动化安装Git环境的Shell脚本，支持在CentOS/RHEL和Ubuntu/Debian系统上安装最新版本的Git。

## 功能特性

- ✅ 自动检测操作系统类型（CentOS/Ubuntu）
- ✅ 智能检查Git是否已安装，避免重复安装
- ✅ 安装Git及必要的开发依赖
- ✅ 自动配置Git基础设置（默认分支、编辑器等）
- ✅ 安装后验证和信息展示
- ✅ 彩色日志输出，便于查看执行状态
- ✅ 提供用户配置指导

## 系统要求

### 支持的操作系统
- CentOS 7/8
- RHEL 7/8
- Ubuntu 18.04/20.04/22.04
- Debian 9/10/11

### 权限要求
- 必须使用root用户执行
- 需要网络连接以下载软件包

## 使用方法

### 1. 下载脚本
```bash
# 如果脚本已在服务器上
cd /path/to/scripts

# 或者从远程下载
wget https://your-server.com/install_git.sh
```

### 2. 添加执行权限
```bash
chmod +x install_git.sh
```

### 3. 执行安装
```bash
# 使用root用户执行
sudo ./install_git.sh

# 或者切换到root用户后执行
su -
./install_git.sh
```

## 安装内容

### CentOS/RHEL系统
- 安装包：`git` 及开发工具包
- 依赖包：`gettext-devel`, `openssl-devel`, `perl-CPAN`, `perl-devel`, `zlib-devel`, `curl-devel`
- 开发工具：`Development Tools` 组

### Ubuntu/Debian系统
- 安装包：`git`
- 依赖包：`make`, `libssl-dev`, `libghc-zlib-dev`, `libcurl4-gnutls-dev`, `libncurses5-dev`, `libncursesw5-dev`, `libedit-dev`

### 自动配置项
脚本会自动配置以下Git设置：
```bash
# 设置默认分支名
git config --global init.defaultBranch main

# 设置换行符处理
git config --global core.autocrlf input

# 设置默认编辑器
git config --global core.editor vim
```

## 验证安装

安装完成后，脚本会自动执行验证，您也可以手动验证：

```bash
# 查看Git版本
git --version

# 查看Git配置
git config --global --list

# 查看Git安装路径
which git

# 测试Git功能
git help
```

## 用户配置

安装完成后，需要配置用户信息才能正常使用Git：

```bash
# 配置用户名
git config --global user.name "Your Name"

# 配置邮箱
git config --global user.email "your.email@example.com"

# 验证配置
git config --global --list
```

## 预期输出示例

```
[INFO] 开始安装Git环境...
[INFO] 检测到Ubuntu/Debian系统
[STEP] 更新系统包管理器...
[INFO] 系统更新完成
[STEP] 检查Git环境...
[STEP] 安装Git环境...
[INFO] Git安装完成
[STEP] 配置Git全局设置...
[INFO] Git基础配置完成
[WARN] 请手动配置用户信息：
  git config --global user.name "Your Name"
  git config --global user.email "your.email@example.com"
[STEP] 验证Git安装结果...
==================== Git安装验证 ====================
Git版本:
git version 2.x.x
...
[INFO] Git安装验证完成
==================== Git安装完成 ====================
[INFO] Git环境安装完成！
```

## 常见问题

### Q1: 脚本执行失败，提示权限不足
**A:** 确保使用root用户执行脚本：
```bash
sudo ./install_git.sh
```

### Q2: 网络连接问题导致下载失败
**A:** 检查网络连接，或配置代理：
```bash
export http_proxy=http://proxy-server:port
export https_proxy=http://proxy-server:port
```

### Q3: 系统已安装Git但版本较旧
**A:** 脚本会检测到已安装的Git并跳过安装。如需升级：
```bash
# CentOS/RHEL
yum update git

# Ubuntu/Debian
apt update && apt upgrade git
```

### Q4: Git命令提示用户信息未配置
**A:** 按照脚本提示配置用户信息：
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### Q5: 在企业环境中使用代理
**A:** 配置Git代理设置：
```bash
# HTTP代理
git config --global http.proxy http://proxy-server:port

# HTTPS代理
git config --global https.proxy https://proxy-server:port

# 取消代理
git config --global --unset http.proxy
git config --global --unset https.proxy
```

## 高级配置

### SSH密钥配置
```bash
# 生成SSH密钥
ssh-keygen -t rsa -b 4096 -C "your.email@example.com"

# 添加到SSH代理
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa

# 查看公钥（添加到Git服务器）
cat ~/.ssh/id_rsa.pub
```

### 常用Git配置
```bash
# 设置默认推送行为
git config --global push.default simple

# 启用颜色输出
git config --global color.ui auto

# 设置别名
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
```

## 卸载方法

如需卸载Git环境，请使用对应的卸载脚本：
```bash
./uninstall_git.sh
```

或手动卸载：

### CentOS/RHEL
```bash
yum remove git
```

### Ubuntu/Debian
```bash
apt remove git
apt autoremove
```

### 清理配置文件
```bash
# 删除全局配置
rm -f ~/.gitconfig

# 删除系统配置
rm -f /etc/gitconfig
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
2. 网络连接是否正常
3. 磁盘空间是否充足
4. 是否使用root权限执行
5. 防火墙或代理设置是否正确

## 更新日志

- v1.0 - 初始版本，支持Git安装
- 支持CentOS/RHEL和Ubuntu/Debian系统
- 自动基础配置
- 安装验证功能
- 用户配置指导

## 相关脚本

- `install_git.sh` - Git安装脚本
- `uninstall_git.sh` - Git卸载脚本
- `install_git_README.md` - 安装说明文档
- `uninstall_git_README.md` - 卸载说明文档