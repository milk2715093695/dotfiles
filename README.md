# dotfiles

这是一个用于管理个人配置的仓库（dotfiles）。

- [dotfiles](#dotfiles)
  - [1. 效果展示](#1-效果展示)
  - [2. 目录结构](#2-目录结构)
  - [3. 配置路径约定](#3-配置路径约定)
  - [4. 部署](#4-部署)
    - [4.1. Ubuntu](#41-ubuntu)
    - [4.2. macOS](#42-macos)
    - [4.3. Windows](#43-windows)
    - [4.4. Android-termux](#44-android-termux)
  - [5. 未来计划](#5-未来计划)
  - [许可证](#许可证)

## 1. 效果展示

<details>
<summary>cava</summary>

cava 配置了主题颜色：

![cava 配置效果](assets/screenshots/cava.webp)

</details>


<details>
<summary>nvim</summary>

nvim 基本继承了 LazyVim 的配置，添加了部分插件：

![nvim 配置效果](assets/screenshots/nvim.webp)

</details>


<details>
<summary>pwsh & zsh</summary>

基本上都是命令行的效果，无需展示。

</details>


<details>
<summary>starship</summary>

为 starship 配置了 prompt：

![starship 配置效果](assets/screenshots/starship.webp)

</details>


<details>
<summary>tmux</summary>

为 tmux 配置了状态栏以及常见插件。

![tmux 配置效果](assets/screenshots/tmux.webp)

</details>


<details>
<summary>WezTerm</summary>

为 wezterm 配置了主题：

![wezterm 配置效果](assets/screenshots/wezterm.webp)

</details>


<details>
<summary>Yazi</summary>

为 yazi 配置了主题以及常用插件：

![yazi 配置效果](assets/screenshots/yazi.webp)

</details>

## 2. 目录结构

```text
.
├── cava                    # cava 配置
│   ├── macos               # macOS
│   ├── termux              # Android-termux
│   ├── ubuntu              # Ubuntu
│   └── windows             # Windows
├── deploy                  # 部署脚本
│   ├── macos.sh            # macOS
│   ├── ubuntu.sh           # Ubuntu（其他 Linux 系列未尝试）
│   └── windows.ps1         # Windows
├── LICENSE
├── nvim                    # LazyVim 配置
├── pwsh                                        # pwsh 配置
│   ├── Microsoft.PowerShell_profile.ps1        # pwsh 配置文件一级入口
│   └── pwsh
│       ├── Aliases.ps1                         # 别名配置
│       ├── Conda.ps1                           # conda 初始化脚本（懒加载）
│       ├── Env.ps1                             # 环境变量配置
│       ├── Functions.ps1                       # 自定义函数
│       ├── Hook.ps1                            # hook
│       ├── Microsoft.PowerShell_profile.ps1    # pwsh 配置文件二级入口
│       ├── Options.ps1                         # zsh 选项配置
│       ├── Plugins.ps1                         # 插件配置
│       └── Secrets                             # 密码管理（除了示例文件外不会被追踪）
│           └── Example.ps1                     # 示例
├── README.md
├── starship
│   └── starship.toml       # starship 配置
├── tmux                    # tmux 配置
│   ├── plugins             # tmux 插件目录
│   └── tmux.conf           # tmux 配置文件
├── wezterm                 # WezTerm 配置以及文件
├── yazi                    # yazi 配置
│   ├── flavors             # yazi 主题目录
│   ├── init.lua            # yazi lua 初始化脚本
│   ├── keymap.toml         # yazi 快捷键配置
│   ├── package.toml        # yazi 插件配置
│   ├── plugins             # yazi 插件目录
│   ├── theme.toml          # yazi 主题配置
│   ├── vfs.toml            # yazi 文件系统配置
│   └── yazi.toml           # yazi 主配置文件
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

## 3. 配置路径约定

本仓库采用以下约定：
**仓库只存放“源文件”，实际配置通过符号链接（symlink）映射到真实路径。**

例如：

- `~/.config/wezterm/`  ->  `dotfiles/wezterm/`
- `~/.zshrc` -> `dotfiles/zsh/.zshrc`，`~/.config/zsh/` -> `dotfiles/zsh/zsh/`
- `~/.config/starship.toml` -> `dotfiles/starship/starship.toml`
- `~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1` -> `dotfiles\pwsh\PowerShell_profile.ps1`，`~\.config\pwsh\` -> `dotfiles\pwsh\pwsh\`
- `~/.config/yazi/` -> `dotfiles/yazi/` 或 `%AppData\config\yazi\` -> `dotfiles\yazi\`
- `~/.config/cava/` -> `dotfiles/cava/<对应系统>`
- `~/.config/nvim` -> `dotfiles/nvim/` 或 `%LocalAppData\nvim\` -> `dotfiles\nvim\`
- `~/.config/tmux` -> `dotfiles/tmux/`

## 4. 部署

部署脚本会：

- 创建必要的目录
- 自动创建符号链接
- 对已有文件做提示，避免误覆盖
- 可以自动确认安装类操作，但配置覆盖策略需要单独指定

> 使用过程中请注意提示与警告！以免错过重要信息！
>
> 国内建议提前配置代理或镜像源

部署参数：

- POSIX（macOS / Ubuntu / Termux）：
  - `--yes-install`：自动确认安装或更新软件包、插件等安装类操作。
  - `--config-mode ask|backup|replace|replace-link`：配置目标已存在时的处理方式，默认 `ask`。
- Windows：
  - `-YesInstall`：自动确认安装或更新软件包、插件等安装类操作。
  - `-ConfigMode ask|backup|replace|replace-link`：配置目标已存在时的处理方式，默认 `ask`。

配置处理方式：

- `ask`：每次遇到已存在的配置目标时询问。交互时使用小写字母只对本次生效，使用大写字母会对后续全部生效。
- `backup`：备份已有符号链接、文件或目录，再创建新链接。
- `replace`：删除已有符号链接、文件或目录，再创建新链接。
- `replace-link`：已有符号链接时替换；已有文件或目录时备份。

> `--yes-install` / `-YesInstall` 只会自动确认安装类操作，不会自动确认配置覆盖、删除、备份、快捷方式、默认 shell 等其他操作。

示例：

```bash
./deploy/macos.sh --yes-install --config-mode replace-link
```

```powershell
.\deploy\windows.ps1 -YesInstall -ConfigMode replace-link
```

### 4.1. Ubuntu

推荐拥有 `flatpak` 与 `Linuxbrew` 作为前置，同时有 `zsh` 作为默认的 shell。

在新机器上执行以下步骤即可部署配置：

```bash
git clone --recurse-submodules https://github.com/milk2715093695/dotfiles.git
cd ./dotfiles
chmod +x ./deploy/ubuntu.sh
./deploy/ubuntu.sh
```

### 4.2. macOS

推荐拥有 `Homebrew` 作为前置。

在新机器上执行以下步骤即可部署配置：

```bash
git clone --recurse-submodules https://github.com/milk2715093695/dotfiles.git
cd ./dotfiles
chmod +x ./deploy/macos.sh
./deploy/macos.sh
```

### 4.3. Windows

- 推荐拥有 `scoop` 作为前置。
- 推荐以管理员身份的 `Powershell` 或 `pwsh`（推荐）运行部署脚本。

在 powershell 上执行以下步骤即可部署配置：

```powershell
git clone --recurse-submodules https://github.com/milk2715093695/dotfiles.git
cd .\dotfiles
Set-ExecutionPolicy Bypass -Scope Process -Force
.\deploy\windows.ps1
```

### 4.4. Android-termux

在 termux 上执行以下步骤即可部署配置：

```bash
git clone --recurse-submodules https://github.com/milk2715093695/dotfiles.git
cd ./dotfiles
chmod +x ./deploy/termux.sh
./deploy/termux.sh
```

## 5. 未来计划

- 配置
  - [X] WezTerm 配置
  - [X] zsh 配置
  - [X] starship 配置
  - [X] pwsh 配置
  - [X] yazi 配置
  - [X] cava 配置
  - [X] tmux 配置
  - [X] nvim 配置
- 部署
  - [X] Ubuntu 部署脚本
  - [X] macOS 部署脚本
  - [X] Windows 部署脚本
  - [X] Android-termux 部署脚本

## 许可证

本仓库采用 MIT 许可证。详情见 [LICENSE](./LICENSE) 文件。

关于配置中使用到了 AltDrag（GPLv3）的问题：本仓库不包含 AltDrag 源码或可执行文件，部署时会自动从官方仓库下载并安装。AltDrag 许可请参见：[AltDrag 仓库](https://github.com/RamonUnch/AltSnap)
