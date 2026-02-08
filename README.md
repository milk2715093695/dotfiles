# dotfiles

这是一个用于管理个人配置的仓库（dotfiles）。  

- [dotfiles](#dotfiles)
  - [目录结构](#目录结构)
  - [1. 配置路径约定](#1-配置路径约定)
  - [2. 部署](#2-部署)
    - [2.1. Ubuntu](#21-ubuntu)
    - [2.2. macOS](#22-macos)
    - [2.3. Windows](#23-windows)
  - [3. 未来计划](#3-未来计划)
  - [许可证](#许可证)

## 目录结构

```text
.
├── deploy                  # 部署脚本
│   ├── macos.sh            # macOS
│   ├── ubuntu.sh           # Ubuntu（其他 Linux 系列未尝试）
│   └── windows.ps1         # Windows
├── LICENSE
├── README.md
├── wezterm                 # WezTerm 配置以及文件
└── zsh                     # zsh 配置
    ├── .zshrc              # zsh 配置文件一级入口
    └── zsh
        ├── aliases.zsh     # 别名配置  
        ├── conda.zsh       # conda 初始化脚本（懒加载）
        ├── env.zsh         # 环境变量配置
        ├── functions.zsh   # 自定义函数
        ├── hook.zsh        # hook
        ├── options.zsh     # zsh 选项配置
        ├── plugins.zsh     # 插件配置
        ├── secrets         # 密码管理（除了示例文件外不会被追踪）
        │   └── example.sh  # 示例
        └── zshrc           # zsh 配置文件二级入口
```

- `wezterm/`：WezTerm 配置文件及资源
- `deploy/`：部署脚本

## 1. 配置路径约定

本仓库采用以下约定：  
**仓库只存放“源文件”，实际配置通过符号链接（symlink）映射到真实路径。**

例如：

- `~/.config/wezterm/`  ->  `dotfiles/wezterm/`
- `~/.zshrc` -> `dotfiles/zsh/.zshrc`，`~/.config/zsh/` -> `dotfiles/zsh/zsh/`

## 2. 部署

部署脚本会：

- 创建必要的目录
- 自动创建符号链接
- 对已有文件做提示，避免误覆盖
- 可以使用 `-y` 参数自动全部确认，但是不建议使用

> 使用过程中请注意提示与警告！以免错过重要信息！
>
> 国内建议提前配置代理或镜像源

### 2.1. Ubuntu

推荐拥有 `flatpak` 与 `Linuxbrew` 作为前置，同时有 `zsh` 作为默认的 shell。

在新机器上执行以下步骤即可部署配置：

```bash
git clone https://github.com/milk2715093695/dotfiles.git
cd ./dotfiles
chmod +x ./deploy/ubuntu.sh
./deploy/ubuntu.sh
```

### 2.2. macOS

推荐拥有 `Homebrew` 作为前置。

在新机器上执行以下步骤即可部署配置：

```bash
git clone https://github.com/milk2715093695/dotfiles.git
cd ./dotfiles
chmod +x ./deploy/macos.sh
./deploy/macos.sh
```

### 2.3. Windows

- 推荐拥有 `scoop` 作为前置。
- 推荐以管理员身份的 `Powershell` 或 `pwsh`（推荐）运行部署脚本。

在 powershell 上执行以下步骤即可部署配置：

```powershell
git clone https://github.com/milk2715093695/dotfiles.git
cd .\dotfiles
Set-ExecutionPolicy Bypass -Scope Process -Force
.\deploy\windows.ps1
```

## 3. 未来计划

- 配置
  - [X] WezTerm 配置
  - [X] zsh 配置
  - [ ] vim/nvim 配置
  - [ ] starship 配置
- 部署
  - [X] Ubuntu 部署脚本
  - [X] macOS 部署脚本
  - [X] Windows 部署脚本

## 许可证

本仓库采用 MIT 许可证。详情见 [LICENSE](./LICENSE) 文件。

关于配置中使用到了 AltDrag（GPLv3）的问题：本仓库不包含 AltDrag 源码或可执行文件，部署时会自动从官方仓库下载并安装。AltDrag 许可请参见：[AltDrag 仓库](https://github.com/RamonUnch/AltSnap)
