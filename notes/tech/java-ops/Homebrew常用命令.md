# Homebrew 常用命令

Homebrew 是 macOS 和 Linux 系统上最受欢迎的包管理器，用于安装和管理软件包。

## 基础命令

### 安装和卸载

```bash
# 安装软件包
brew install <package_name>

# 安装特定版本
brew install <package_name>@<version>

# 卸载软件包
brew uninstall <package_name>

# 强制卸载（忽略依赖）
brew uninstall --force <package_name>

# 卸载并删除所有版本
brew uninstall --zap <package_name>
```

### 搜索和信息

```bash
# 搜索软件包
brew search <keyword>

# 显示软件包信息
brew info <package_name>

# 显示已安装的软件包
brew list

# 显示已安装的软件包（仅显示名称）
brew list --formula

# 显示过时的软件包
brew outdated

# 显示依赖关系
brew deps <package_name>

# 显示被依赖的软件包
brew uses <package_name>
```

## 更新和维护

### 更新 Homebrew

```bash
# 更新 Homebrew 本身
brew update

# 升级所有过时的软件包
brew upgrade

# 升级特定软件包
brew upgrade <package_name>

# 清理旧版本文件
brew cleanup

# 清理特定软件包的旧版本
brew cleanup <package_name>

# 显示可清理的文件大小
brew cleanup --dry-run
```

### 诊断和修复

```bash
# 检查系统问题
brew doctor

# 修复权限问题
brew fix-permissions

# 重新安装软件包
brew reinstall <package_name>

# 检查软件包完整性
brew audit <package_name>
```

## Cask 命令（GUI 应用）

### 安装和管理 GUI 应用

```bash
# 安装 GUI 应用
brew install --cask <app_name>

# 卸载 GUI 应用
brew uninstall --cask <app_name>

# 搜索 GUI 应用
brew search --cask <keyword>

# 显示已安装的 GUI 应用
brew list --cask

# 显示 GUI 应用信息
brew info --cask <app_name>

# 升级所有 GUI 应用
brew upgrade --cask

# 升级特定 GUI 应用
brew upgrade --cask <app_name>
```

## 服务管理

### 启动和停止服务

```bash
# 启动服务
brew services start <service_name>

# 停止服务
brew services stop <service_name>

# 重启服务
brew services restart <service_name>

# 显示所有服务状态
brew services list

# 开机自启动服务
brew services run <service_name>

# 清理无效服务
brew services cleanup
```

## 仓库管理

### Tap 管理

```bash
# 添加第三方仓库
brew tap <user/repo>

# 移除仓库
brew untap <user/repo>

# 显示已添加的仓库
brew tap

# 更新特定仓库
brew tap --repair
```

## 高级命令

### 配置和环境

```bash
# 显示 Homebrew 配置
brew config

# 显示 Homebrew 版本
brew --version

# 显示 Homebrew 安装路径
brew --prefix

# 显示特定软件包路径
brew --prefix <package_name>

# 显示 Cellar 路径
brew --cellar

# 显示缓存路径
brew --cache
```

### 依赖管理

```bash
# 显示依赖树
brew deps --tree <package_name>

# 显示所有依赖（包括间接依赖）
brew deps --include-build <package_name>

# 查找孤立的软件包（没有被依赖）
brew leaves

# 自动移除不需要的依赖
brew autoremove
```

## 实用技巧

### 常用组合命令

```bash
# 更新并升级所有软件
brew update && brew upgrade

# 清理并显示节省的空间
brew cleanup && brew cleanup --dry-run

# 检查并修复问题
brew doctor && brew fix-permissions

# 搜索并显示详细信息
brew search <keyword> && brew info <package_name>
```

### 批量操作

```bash
# 批量安装软件包
brew install package1 package2 package3

# 从文件安装软件包列表
brew bundle --file=Brewfile

# 导出已安装软件包列表
brew bundle dump --describe --force

# 批量卸载软件包
brew uninstall package1 package2 package3
```

## 环境变量

### 常用环境变量

```bash
# 设置 Homebrew 镜像源（中国用户）
export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.aliyun.com/homebrew/homebrew-bottles
export HOMEBREW_CORE_GIT_REMOTE=https://mirrors.aliyun.com/homebrew/homebrew-core.git

# 禁用自动更新
export HOMEBREW_NO_AUTO_UPDATE=1

# 启用详细输出
export HOMEBREW_VERBOSE=1

# 设置安装路径
export HOMEBREW_PREFIX=/opt/homebrew  # Apple Silicon Mac
export HOMEBREW_PREFIX=/usr/local     # Intel Mac
```

## 故障排除

### 常见问题解决

```bash
# 权限问题
sudo chown -R $(whoami) $(brew --prefix)/*

# 清理损坏的符号链接
brew cleanup --prune=all

# 重置 Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 修复 Xcode 命令行工具
xcode-select --install
```

### 性能优化

```bash
# 并行安装（加快安装速度）
export HOMEBREW_MAKE_JOBS=4

# 跳过不必要的检查
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_INSECURE_REDIRECT=1

# 使用浅克隆（节省空间）
export HOMEBREW_NO_SHALLOW_CLONE=0
```

## 常用软件包推荐

### 开发工具

```bash
# 版本控制
brew install git git-lfs

# 编程语言
brew install node python java go rust

# 数据库
brew install mysql postgresql redis mongodb

# 容器化
brew install docker docker-compose

# 文本编辑器
brew install --cask visual-studio-code sublime-text

# 终端工具
brew install zsh oh-my-zsh tmux
```

### 系统工具

```bash
# 系统监控
brew install htop neofetch

# 网络工具
brew install wget curl nmap

# 文件管理
brew install tree fd ripgrep

# 压缩工具
brew install unrar p7zip

# 媒体工具
brew install ffmpeg imagemagick
```

## 最佳实践

1. **定期更新**: 每周运行 `brew update && brew upgrade`
2. **清理缓存**: 定期运行 `brew cleanup` 释放磁盘空间
3. **检查健康**: 定期运行 `brew doctor` 检查系统状态
4. **备份配置**: 使用 `brew bundle dump` 备份软件包列表
5. **使用镜像**: 在中国大陆使用阿里云等镜像源加速下载

## 参考资源

- [Homebrew 官方网站](https://brew.sh/)
- [Homebrew 官方文档](https://docs.brew.sh/)
- [Homebrew GitHub 仓库](https://github.com/Homebrew/brew)
- [Homebrew Formulae 搜索](https://formulae.brew.sh/)