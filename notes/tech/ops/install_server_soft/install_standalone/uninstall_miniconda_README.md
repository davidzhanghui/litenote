# Miniconda Python环境管理器卸载脚本

## 概述

`uninstall_miniconda.sh` 是一个全面的Miniconda Python环境管理器卸载脚本，用于完全移除Miniconda及其相关组件。该脚本支持CentOS/RHEL和Ubuntu/Debian系统，提供智能检测、安全卸载的完整解决方案。

## 功能特性

### 🔧 智能检测
- 自动检测多个Miniconda安装
- 支持自定义安装路径
- 识别conda命令和环境
- 检测常见安装位置

### 🛡️ 安全卸载
- 用户确认机制，防止误操作
- 配置文件自动备份
- 用户数据保护选项
- 详细的操作日志记录

### 🧹 彻底清理
- 删除所有conda环境和包
- 清理shell配置文件
- 移除环境变量配置
- 清理缓存和临时文件
- 处理全局配置文件

### 📊 灵活选择
- 支持选择性卸载特定安装
- 支持卸载所有检测到的安装
- 用户数据保留选项
- 配置文件备份保护

## 系统要求

- **操作系统**: CentOS/RHEL 7+, Ubuntu 18.04+, Debian 9+
- **Shell**: bash, zsh, fish等
- **依赖**: 标准Unix工具（sed, grep, rm等）

## 使用方法

### 基本使用

```bash
# 添加执行权限
chmod +x uninstall_miniconda.sh

# 执行卸载脚本
./uninstall_miniconda.sh
```

### 静默卸载（高级用户）

```bash
# 设置环境变量进行静默卸载
export MINICONDA_UNINSTALL_SILENT=true
./uninstall_miniconda.sh
```

## 卸载流程

### 1. 系统检查
- 检测操作系统类型和版本
- 扫描可能的Miniconda安装位置
- 检查conda命令可用性

### 2. 安装检测
脚本会检测以下位置的Miniconda安装：
- `$HOME/miniconda3`
- `$HOME/miniconda`
- `/opt/miniconda3`
- `/opt/miniconda`
- `/usr/local/miniconda3`
- `/usr/local/miniconda`
- 通过`conda info --base`检测的路径

### 3. 安装选择
如果检测到多个安装，脚本会提供选择菜单：
- 选择特定安装进行卸载
- 输入自定义路径
- 卸载所有检测到的安装

### 4. 用户确认
- 显示将要删除的组件列表
- 明确警告数据丢失风险
- 要求用户明确确认

### 5. 环境停用
- 停用当前激活的conda环境
- 确保没有conda进程干扰卸载

### 6. 配置清理
- 清理shell配置文件（.bashrc, .zshrc等）
- 移除conda初始化代码
- 清理环境变量配置
- 备份原始配置文件

### 7. 文件删除
- 删除Miniconda安装目录
- 清理全局配置文件
- 处理用户数据目录（可选保留）

### 8. 缓存清理
- 清理conda缓存
- 删除pip缓存
- 清理临时安装文件

### 9. 验证确认
- 检查卸载完整性
- 验证命令可用性
- 报告剩余组件

## 安全注意事项

### ⚠️ 重要警告

1. **环境备份**: 卸载前请备份重要的conda环境
2. **项目依赖**: 确认项目不依赖特定的Python环境
3. **配置保存**: 重要的conda配置请提前备份
4. **不可逆操作**: 卸载过程不可逆转

### 🔒 安全措施

- 自动备份shell配置文件
- 用户数据目录保护选项
- 详细的确认提示
- 完整的操作日志

## 配置文件处理

### 自动处理的配置文件

脚本会自动处理以下配置文件：

```bash
~/.bashrc          # Bash配置
~/.bash_profile    # Bash登录配置
~/.zshrc           # Zsh配置
~/.profile         # 通用shell配置
~/.cshrc           # C Shell配置
~/.tcshrc          # TC Shell配置
~/.fish/config.fish # Fish Shell配置
```

### 备份机制

每个配置文件在修改前都会创建备份：
```bash
~/.bashrc.backup_20231201_143022
```

### 清理内容

- conda初始化代码块
- conda相关的PATH配置
- 特定安装路径的引用

## 用户数据处理

### 可选保留的数据

脚本会询问是否保留以下用户数据：

- `~/.conda/` - conda用户配置和缓存
- `~/.condarc` - conda配置文件
- `~/.continuum/` - Anaconda相关数据

### 自动清理的缓存

- `~/.cache/conda/` - conda包缓存
- `~/.cache/pip/` - pip包缓存
- `/tmp/conda-*` - 临时conda文件
- `/tmp/pip-*` - 临时pip文件

## 故障排除

### 常见问题

**Q: 卸载后conda命令仍然可用**
A: 重新启动终端或执行 `hash -r` 清除命令缓存

**Q: PATH中仍包含conda路径**
A: 重新登录或手动编辑shell配置文件

**Q: 某些配置文件未清理**
A: 检查备份文件，手动清理残留配置

**Q: 虚拟环境项目无法运行**
A: 重新配置项目的Python解释器路径

### 手动清理

如果自动卸载遇到问题，可以手动执行清理：

```bash
# 删除安装目录
rm -rf ~/miniconda3

# 清理配置文件
sed -i '/conda/d' ~/.bashrc
sed -i '/# >>> conda initialize >>>/,/# <<< conda initialize <<</d' ~/.bashrc

# 清理用户数据
rm -rf ~/.conda
rm -f ~/.condarc

# 清理缓存
rm -rf ~/.cache/conda
rm -rf ~/.cache/pip
```

### 恢复配置

如果需要恢复原始配置：

```bash
# 恢复备份的配置文件
cp ~/.bashrc.backup_YYYYMMDD_HHMMSS ~/.bashrc

# 重新加载配置
source ~/.bashrc
```

## 重新安装指南

### 完全重新安装

1. 确保卸载完全完成
2. 重启终端或重新登录
3. 下载最新的Miniconda安装器
4. 执行安装脚本
5. 重新创建所需的conda环境

### 环境迁移

如果需要迁移现有环境：

```bash
# 卸载前导出环境
conda env export -n myenv > myenv.yml

# 重新安装后恢复环境
conda env create -f myenv.yml
```

## 脚本输出示例

```
╔══════════════════════════════════════════════════════════════╗
║                  Miniconda Python环境管理器卸载              ║
║                                                              ║
║  此脚本将完全卸载Miniconda及其相关组件                      ║
║  包括安装目录、环境变量配置和shell初始化                    ║
║  支持系统: CentOS/RHEL 7+, Ubuntu 18.04+, Debian 9+        ║
║  作者: DevOps Team                                           ║
║  版本: v1.0.0                                               ║
╚══════════════════════════════════════════════════════════════╝

[STEP] 检测操作系统...
[INFO] 操作系统: ubuntu 20.04
[STEP] 检测Miniconda安装...
[INFO] 通过conda命令检测到安装: /home/user/miniconda3
[INFO] 检测到安装: /home/user/miniconda3
[STEP] 选择安装目录: /home/user/miniconda3
[STEP] 确认卸载操作...
警告: 此操作将完全卸载Miniconda及其所有环境和包！
...
[SUCCESS] Miniconda卸载成功！
```

## 日志文件

卸载过程会生成详细的日志文件：

- **位置**: `./logs/uninstall_miniconda_YYYYMMDD_HHMMSS.log`
- **内容**: 完整的卸载过程记录
- **用途**: 故障排除和审计

## 环境变量说明

### 脚本支持的环境变量

```bash
# 静默模式（跳过用户确认）
export MINICONDA_UNINSTALL_SILENT=true

# 强制删除用户数据
export MINICONDA_FORCE_REMOVE_USER_DATA=true

# 自定义日志目录
export MINICONDA_UNINSTALL_LOG_DIR="/custom/log/path"
```

## 兼容性说明

### 支持的Miniconda版本
- Miniconda3 (Python 3.x)
- Miniconda2 (Python 2.x, 已停止支持)
- Anaconda (部分兼容)

### 支持的Shell
- Bash
- Zsh
- Fish
- C Shell (csh)
- TC Shell (tcsh)

### 支持的安装方式
- 用户级安装
- 系统级安装
- 自定义路径安装

## 相关文档

- [Miniconda官方文档](https://docs.conda.io/en/latest/miniconda.html)
- [Conda用户指南](https://docs.conda.io/projects/conda/en/latest/user-guide/)
- [Miniconda安装脚本](install_miniconda.sh)
- [Python环境管理最佳实践](https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html)

## 技术支持

如果在使用过程中遇到问题：

1. 检查日志文件获取详细信息
2. 参考故障排除部分
3. 检查备份的配置文件
4. 查阅conda官方文档
5. 联系系统管理员

## 最佳实践

### 卸载前准备
1. 导出重要的conda环境配置
2. 备份自定义的conda配置文件
3. 记录项目的Python依赖
4. 确认没有重要进程在使用conda环境

### 卸载后检查
1. 重启终端验证环境变量
2. 检查项目的Python解释器配置
3. 验证系统Python环境正常
4. 清理可能的IDE配置

---

**注意**: 此脚本专门用于卸载Miniconda。如果您使用的是完整的Anaconda发行版，某些功能可能需要额外的清理步骤。