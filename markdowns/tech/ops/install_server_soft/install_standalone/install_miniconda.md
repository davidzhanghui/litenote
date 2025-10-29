# Miniconda Python环境管理器安装脚本

## 概述

本脚本用于在Linux和macOS系统上自动安装和配置Miniconda。Miniconda是一个轻量级的Python发行版，包含conda包管理器和Python解释器，是管理Python环境和包的理想工具。

## 支持的系统

- **CentOS/RHEL**: 7.0+
- **Ubuntu**: 18.04+
- **Debian**: 9+
- **macOS**: 10.13+
- **架构**: x86_64 (amd64), ARM64 (aarch64/arm64)

## 功能特性

### 核心功能
- 自动检测操作系统和架构
- 下载并安装最新版本的Miniconda
- 支持自定义安装目录
- 自动配置环境变量和shell初始化
- 可选择安装常用Python科学计算包
- 支持单用户和全局安装模式
- 完整的日志记录和错误处理

### 交互式配置
- 安装目录选择
- PATH环境变量配置
- Shell初始化选择（bash/zsh/fish）
- 常用包安装选项
- 全局安装模式（root用户）

## 安装配置

### 默认配置

| 配置项 | 默认值 | 说明 |
|--------|--------|------|
| 安装目录 | `$HOME/miniconda3` | 用户安装目录 |
| 全局安装目录 | `/opt/miniconda3` | root用户安装目录 |
| 添加到PATH | `yes` | 自动配置环境变量 |
| Shell初始化 | `bash` | 默认初始化的shell |
| 安装包目录 | `/tmp` | 临时下载目录 |

### 目录结构

```
~/miniconda3/                    # 默认安装目录
├── bin/
│   ├── conda                    # conda包管理器
│   ├── python                   # Python解释器
│   ├── pip                      # pip包管理器
│   └── jupyter                  # Jupyter Notebook (可选)
├── lib/
│   └── python3.x/               # Python库目录
├── envs/                        # conda环境目录
├── pkgs/                        # 包缓存目录
└── etc/
    └── profile.d/               # 环境配置
```

## 使用方法

### 基本安装

```bash
# 下载脚本
wget https://raw.githubusercontent.com/your-repo/scripts/install_miniconda.sh

# 添加执行权限
chmod +x install_miniconda.sh

# 运行安装脚本
./install_miniconda.sh
```

### 静默安装

可以通过预设环境变量进行静默安装:

```bash
# 设置安装配置
export MINICONDA_INSTALL_DIR="/opt/miniconda3"
export ADD_TO_PATH="yes"
export CONDA_INIT_SHELL="zsh"
export INSTALL_FOR_ALL_USERS="yes"

# 运行脚本
sudo ./install_miniconda.sh
```

### 自定义安装

脚本支持交互式配置，运行时会询问:

1. **安装目录**: 默认为 `$HOME/miniconda3`
2. **PATH配置**: 是否添加到环境变量
3. **Shell初始化**: 选择要初始化的shell
4. **常用包**: 是否安装科学计算包
5. **全局安装**: root用户可选择全局安装

## 环境管理

### conda基本命令

```bash
# 查看conda版本
conda --version

# 更新conda
conda update conda

# 查看环境列表
conda env list

# 创建新环境
conda create -n myenv python=3.9

# 激活环境
conda activate myenv

# 退出环境
conda deactivate

# 删除环境
conda env remove -n myenv
```

### 包管理

```bash
# 搜索包
conda search package_name

# 安装包
conda install package_name

# 从指定频道安装
conda install -c conda-forge package_name

# 列出已安装的包
conda list

# 更新包
conda update package_name

# 删除包
conda remove package_name

# 导出环境
conda env export > environment.yml

# 从文件创建环境
conda env create -f environment.yml
```

### 频道管理

```bash
# 添加频道
conda config --add channels conda-forge

# 查看频道列表
conda config --show channels

# 设置频道优先级
conda config --set channel_priority strict

# 删除频道
conda config --remove channels channel_name
```

## 配置文件

### .condarc配置

Conda的主配置文件位于 `~/.condarc`:

```yaml
# 频道配置
channels:
  - conda-forge
  - defaults

# 频道优先级
channel_priority: strict

# 自动激活base环境
auto_activate_base: false

# 包缓存目录
pkgs_dirs:
  - ~/miniconda3/pkgs

# 环境目录
envs_dirs:
  - ~/miniconda3/envs
  - ~/.conda/envs

# 代理设置（如需要）
proxy_servers:
  http: http://proxy.company.com:8080
  https: https://proxy.company.com:8080

# SSL验证
ssl_verify: true

# 显示频道URL
show_channel_urls: true
```

### Shell配置

脚本会自动配置shell，也可以手动配置:

**Bash (~/.bashrc):**
```bash
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/path/to/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/path/to/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/path/to/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/path/to/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
```

**Zsh (~/.zshrc):**
```zsh
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/path/to/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/path/to/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/path/to/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/path/to/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
```

## 常用环境配置

### 数据科学环境

```bash
# 创建数据科学环境
conda create -n datascience python=3.9 \
    numpy pandas matplotlib seaborn \
    scikit-learn jupyter ipython \
    plotly bokeh

# 激活环境
conda activate datascience

# 安装额外包
conda install -c conda-forge \
    tensorflow pytorch \
    xgboost lightgbm
```

### Web开发环境

```bash
# 创建Web开发环境
conda create -n webdev python=3.9 \
    flask django fastapi \
    requests beautifulsoup4 \
    selenium pytest

# 激活环境
conda activate webdev

# 使用pip安装conda中没有的包
pip install streamlit dash
```

### 机器学习环境

```bash
# 创建机器学习环境
conda create -n ml python=3.9 \
    numpy pandas scikit-learn \
    tensorflow-gpu pytorch \
    jupyter matplotlib seaborn

# 激活环境
conda activate ml

# 安装CUDA支持（如有GPU）
conda install cudatoolkit cudnn
```

## 性能优化

### 加速包安装

1. **使用mamba**（更快的conda替代品）:

```bash
# 安装mamba
conda install mamba -n base -c conda-forge

# 使用mamba代替conda
mamba install package_name
mamba create -n myenv python=3.9
```

2. **配置镜像源**（中国用户）:

```bash
# 清华大学镜像
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/r
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/pro
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/msys2

# 中科大镜像
conda config --add channels https://mirrors.ustc.edu.cn/anaconda/pkgs/main/
conda config --add channels https://mirrors.ustc.edu.cn/anaconda/pkgs/free/
conda config --add channels https://mirrors.ustc.edu.cn/anaconda/cloud/conda-forge/

# 设置搜索时显示通道地址
conda config --set show_channel_urls yes
```

### 清理缓存

```bash
# 清理包缓存
conda clean --packages

# 清理tar包
conda clean --tarballs

# 清理所有缓存
conda clean --all

# 清理未使用的包
conda clean --packages --tarballs
```

## 故障排除

### 常见问题

1. **conda命令未找到**:

```bash
# 检查PATH设置
echo $PATH

# 手动添加到PATH
export PATH="/path/to/miniconda3/bin:$PATH"

# 重新初始化shell
/path/to/miniconda3/bin/conda init bash
source ~/.bashrc
```

2. **环境激活失败**:

```bash
# 检查conda初始化
conda info

# 重新初始化
conda init
source ~/.bashrc

# 手动激活
source /path/to/miniconda3/etc/profile.d/conda.sh
conda activate myenv
```

3. **包安装失败**:

```bash
# 更新conda
conda update conda

# 清理缓存
conda clean --all

# 尝试不同频道
conda install -c conda-forge package_name

# 使用pip作为备选
pip install package_name
```

4. **权限问题**:

```bash
# 检查目录权限
ls -la ~/miniconda3

# 修复权限
chown -R $USER:$USER ~/miniconda3

# 重新安装到用户目录
rm -rf ~/miniconda3
./install_miniconda.sh
```

5. **网络连接问题**:

```bash
# 测试网络连接
ping repo.anaconda.com

# 配置代理
conda config --set proxy_servers.http http://proxy:port
conda config --set proxy_servers.https https://proxy:port

# 使用镜像源
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main
```

### 日志分析

```bash
# 查看conda信息
conda info

# 查看详细日志
conda install package_name --verbose

# 查看环境信息
conda info --envs

# 检查包依赖
conda search package_name --info
```

## 最佳实践

### 环境管理

1. **为每个项目创建独立环境**:

```bash
# 项目特定环境
conda create -n project1 python=3.9
conda create -n project2 python=3.8
```

2. **使用环境文件管理依赖**:

```bash
# 导出环境
conda env export > environment.yml

# 分享给团队
git add environment.yml

# 其他人重建环境
conda env create -f environment.yml
```

3. **定期清理和更新**:

```bash
# 每月清理缓存
conda clean --all

# 更新conda和包
conda update --all

# 删除不用的环境
conda env remove -n old_env
```

### 包管理

1. **优先使用conda，必要时使用pip**:

```bash
# 首选conda
conda install package_name

# conda没有时使用pip
pip install package_name

# 在环境文件中混合使用
name: myenv
dependencies:
  - python=3.9
  - numpy
  - pandas
  - pip
  - pip:
    - some-pip-only-package
```

2. **固定版本号**:

```bash
# 生产环境固定版本
conda install numpy=1.21.0 pandas=1.3.0

# 开发环境可以使用最新版
conda install numpy pandas
```

## 卸载

### 完全卸载Miniconda

```bash
# 1. 删除安装目录
rm -rf ~/miniconda3
# 或者全局安装的情况
sudo rm -rf /opt/miniconda3

# 2. 清理shell配置
# 编辑 ~/.bashrc, ~/.zshrc 等文件，删除conda相关配置
vim ~/.bashrc
# 删除 >>> conda initialize >>> 到 <<< conda initialize <<< 之间的内容

# 3. 删除配置文件
rm -rf ~/.conda
rm -f ~/.condarc

# 4. 清理环境变量
# 从PATH中移除conda路径
export PATH=$(echo $PATH | tr ':' '\n' | grep -v miniconda3 | tr '\n' ':')

# 5. 删除全局配置（如果存在）
sudo rm -f /etc/profile.d/miniconda.sh

# 6. 重新加载shell配置
source ~/.bashrc
# 或重启终端
```

### 部分卸载

```bash
# 只删除特定环境
conda env remove -n env_name

# 重置conda配置
conda config --remove-key channels
conda config --remove-key proxy_servers

# 清理缓存但保留安装
conda clean --all
```

## 版本信息

- **脚本版本**: v1.0.0
- **支持的Miniconda版本**: 最新稳定版
- **Python版本**: 3.7+
- **最后更新**: 2024年
- **维护者**: DevOps Team

## 许可证

本脚本遵循MIT许可证。Miniconda本身遵循BSD许可证。

## 相关链接

- [Miniconda官方网站](https://docs.conda.io/en/latest/miniconda.html)
- [Conda文档](https://docs.conda.io/)
- [Conda-forge频道](https://conda-forge.org/)
- [Anaconda包仓库](https://anaconda.org/)
- [Mamba项目](https://github.com/mamba-org/mamba)
- [环境管理最佳实践](https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html)