# Git 常用命令详解

## 目录

- [配置](#配置)
- [创建与克隆仓库](#创建与克隆仓库)
- [基本操作](#基本操作)
- [分支管理](#分支管理)
- [远程仓库操作](#远程仓库操作)
- [标签管理](#标签管理)
- [查看信息](#查看信息)
- [撤销与重置](#撤销与重置)
- [高级操作](#高级操作)
- [Git 工作流](#git-工作流)

## 配置

```bash
# 设置全局用户名和邮箱
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# 查看配置信息
git config --list

# 设置默认编辑器
git config --global core.editor "vim"

# 设置别名
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
```

## 创建与克隆仓库

```bash
# 初始化新仓库
git init

# 克隆远程仓库
git clone https://github.com/username/repository.git

# 克隆特定分支
git clone -b branch-name https://github.com/username/repository.git

# 克隆到指定目录
git clone https://github.com/username/repository.git folder-name
```

## 基本操作

```bash
# 查看文件状态
git status

# 添加文件到暂存区
git add filename            # 添加单个文件
git add .                   # 添加所有修改的文件
git add *.js                # 添加所有JavaScript文件
git add directory/          # 添加整个目录

# 提交更改
git commit -m "提交信息"    # 提交暂存区的更改
git commit -am "提交信息"   # 添加所有更改并提交（仅对已跟踪文件有效）

# 查看提交历史
git log
git log --oneline          # 简洁模式
git log --graph            # 图形化显示
git log -p                 # 显示每次提交的差异
git log -n 5              # 显示最近5次提交
```

## 分支管理

```bash
# 查看分支
git branch                 # 列出本地分支
git branch -r              # 列出远程分支
git branch -a              # 列出所有分支

# 创建分支
git branch branch-name     # 创建新分支
git checkout -b branch-name # 创建并切换到新分支

# 切换分支
git checkout branch-name
git switch branch-name     # Git 2.23+ 新命令

# 合并分支
git merge branch-name      # 将指定分支合并到当前分支
git merge --no-ff branch-name # 禁用快进模式合并

# 删除分支
git branch -d branch-name  # 删除已合并的分支
git branch -D branch-name  # 强制删除分支

# 重命名分支
git branch -m old-name new-name
```

## 远程仓库操作

```bash
# 查看远程仓库
git remote -v

# 添加远程仓库
git remote add origin https://github.com/username/repository.git

# 从远程仓库获取更新
git fetch origin
git fetch --all            # 获取所有远程仓库的更新

# 拉取远程更新并合并
git pull origin branch-name

# 推送到远程仓库
git push origin branch-name
git push -u origin branch-name # 设置上游分支并推送

# 删除远程分支
git push origin --delete branch-name

# 重命名远程仓库
git remote rename old-name new-name

# 修改远程仓库URL
git remote set-url origin https://github.com/username/new-repository.git
```

## 标签管理

```bash
# 列出标签
git tag
git tag -l "v1.*"          # 列出匹配模式的标签

# 创建标签
git tag v1.0.0             # 创建轻量标签
git tag -a v1.0.0 -m "版本1.0.0发布" # 创建附注标签

# 查看标签信息
git show v1.0.0

# 给历史提交打标签
git tag -a v0.9.0 commit-id

# 推送标签到远程
git push origin v1.0.0     # 推送特定标签
git push origin --tags     # 推送所有标签

# 删除标签
git tag -d v1.0.0          # 删除本地标签
git push origin :refs/tags/v1.0.0 # 删除远程标签
```

## 查看信息

```bash
# 查看变更
git diff                   # 查看工作区与暂存区的差异
git diff --staged          # 查看暂存区与最新提交的差异
git diff commit1 commit2   # 查看两次提交之间的差异

# 查看文件历史
git blame filename         # 查看文件的每一行是谁在什么时候修改的

# 查看提交详情
git show commit-id

# 查看分支合并图
git log --graph --pretty=oneline --abbrev-commit
```

## 撤销与重置

```bash
# 撤销工作区修改
git checkout -- filename   # 撤销单个文件的修改
git restore filename       # Git 2.23+ 新命令

# 撤销暂存区修改
git reset HEAD filename    # 将文件从暂存区移回工作区
git restore --staged filename # Git 2.23+ 新命令

# 修改最后一次提交
git commit --amend         # 修改最后一次提交信息
git commit --amend --no-edit # 不修改提交信息，只更新提交内容

# 重置到指定提交
git reset --soft commit-id # 保留工作区和暂存区的修改
git reset --mixed commit-id # 默认模式，保留工作区但清空暂存区
git reset --hard commit-id # 丢弃所有修改

# 撤销已推送的提交
git revert commit-id       # 创建一个新的提交来撤销指定提交的更改
```

## 高级操作

```bash
# 储藏工作区
git stash                  # 储藏当前工作区
git stash save "储藏信息"   # 带描述信息的储藏
git stash list             # 查看储藏列表
git stash apply stash@{0}  # 应用指定储藏
git stash pop              # 应用并删除最新储藏
git stash drop stash@{0}   # 删除指定储藏

# 变基操作
git rebase branch-name     # 将当前分支变基到指定分支
git rebase -i HEAD~3       # 交互式变基，修改最近3次提交

# 拣选提交
git cherry-pick commit-id  # 将指定提交应用到当前分支

# 子模块
git submodule add https://github.com/username/repository.git path/to/submodule
git submodule init
git submodule update

# 清理工作区
git clean -f               # 删除未跟踪的文件
git clean -fd              # 删除未跟踪的文件和目录
git clean -n               # 预览将被删除的文件
```

## Git 工作流

### 功能分支工作流

```bash
# 创建功能分支
git checkout -b feature/new-feature

# 开发完成后合并到主分支
git checkout main
git merge feature/new-feature

# 删除功能分支
git branch -d feature/new-feature
```

### Gitflow 工作流

```bash
# 开发新功能
git checkout -b feature/new-feature develop
# 完成功能开发
git checkout develop
git merge --no-ff feature/new-feature

# 创建发布分支
git checkout -b release/1.0.0 develop
# 完成发布准备
git checkout main
git merge --no-ff release/1.0.0
git tag -a v1.0.0 -m "版本1.0.0"

# 修复线上问题
git checkout -b hotfix/bug-fix main
# 完成修复
git checkout main
git merge --no-ff hotfix/bug-fix
git tag -a v1.0.1 -m "修复版本1.0.1"
```

### 常见问题解决

```bash
# 解决合并冲突
# 当发生冲突时，手动编辑冲突文件，然后：
git add conflicted-file
git commit -m "解决合并冲突"

# 查找引入Bug的提交
git bisect start
git bisect bad              # 标记当前版本有问题
git bisect good v1.0.0      # 标记已知的好版本
# Git会自动二分查找，每次检出一个提交后，测试并标记：
git bisect good             # 当前检出的版本没问题
git bisect bad              # 当前检出的版本有问题
# 找到问题提交后
git bisect reset            # 结束查找
```

---

这个文档涵盖了Git的大部分常用命令和操作场景，适合作为日常参考。对于更复杂的Git操作和高级用法，建议查阅Git官方文档或专业书籍。