# dotfiles

这是一个用于管理个人配置的仓库（dotfiles）。

- [dotfiles](#dotfiles)
  - [1. 效果展示](#1-效果展示)
  - [2. 目录结构](#2-目录结构)
  - [3. 配置路径约定](#3-配置路径约定)
  - [4. 部署](#4-部署)
    - [4.1. 预设覆盖](#41-预设覆盖)
    - [4.2. Ubuntu / Linux（Ubuntu 优先）](#42-ubuntu--linuxubuntu-优先)
    - [4.3. macOS](#43-macos)
    - [4.4. Windows](#44-windows)
    - [4.5. Termux](#45-termux)
  - [5. 未来计划](#5-未来计划)
  - [许可证](#许可证)

## 1. 效果展示

<details>
<summary>aerospace</summary>

aerospace 是 macOS 的 i3 风格的平铺窗口管理器：

![aerospace 配置效果](assets/screenshots/aerospace.webp)

</details>


<details>
<summary>borders</summary>

borders 是 macOS 的窗口边框管理器，搭配 aerospace 使用，用于高亮被聚焦的窗口：

![borders 配置效果](assets/screenshots/borders.webp)

</details>


<details>
<summary>cava</summary>

cava 配置了主题颜色：

![cava 配置效果](assets/screenshots/cava.webp)

</details>


<details>
<summary>fastfetch</summary>

为 fastfetch 配置了系统信息展示布局：

![fastfetch 配置效果](assets/screenshots/fastfetch.webp)

</details>


<details>
<summary>gitlogue</summary>

gitlogue 是 Git 历史 cinematics 回放工具，配置了主题偏好：

![gitlogue 配置效果](assets/screenshots/gitlogue.webp)

</details>


<details>
<summary>nvim</summary>

nvim 目前以 LazyVim 为主，只做了少量覆写，并接入了 tmux 导航等插件：

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
├── aerospace               # macOS AeroSpace 配置
│   ├── aerospace.toml      # 通用基础配置（tracked）
│   └── locals/             # 本地应用规则（gitignored）
├── assets                  # README 截图资源
├── borders                 # macOS borders 配置
├── cava                    # cava 配置
│   ├── base.config         # 所有平台共享配置
│   ├── common              # cava 跨平台资源
│   ├── macos               # macOS 平台差异（input.conf）
│   ├── termux              # Android-termux 平台差异（input.conf）
│   ├── ubuntu              # Ubuntu 平台差异（input.conf）
│   └── windows             # Windows 平台差异（input.conf）
├── deploy                  # 部署脚本
│   ├── macos.sh            # macOS
│   ├── termux.sh           # Termux
│   ├── ubuntu.sh           # Ubuntu 优先的 Linux 部署入口
│   └── windows.ps1         # Windows
├── fastfetch               # fastfetch 配置
│   └── config.jsonc        # fastfetch 系统信息展示配置
├── generated/              # 渲染产物目录（gitignored）：部署时由 render 阶段生成
├── gitlogue                # gitlogue 配置
├── LICENSE
├── nvim                    # 基于 LazyVim 的轻量定制配置
├── pwsh                    # pwsh 配置
│   ├── Microsoft.PowerShell_profile.ps1        # pwsh 配置文件一级入口
│   └── pwsh
│       ├── Aliases.ps1                         # 别名配置
│       ├── Conda.ps1                           # conda 初始化脚本（懒加载）
│       ├── Env.ps1                             # 环境变量配置
│       ├── Functions.ps1                       # 自定义函数
│       ├── Hook.ps1                            # hook
│       ├── Microsoft.PowerShell_profile.ps1    # pwsh 配置文件二级入口
│       ├── Options.ps1                         # pwsh 选项配置
│       ├── Plugins.ps1                         # 插件配置
│       └── Secrets                             # 密码管理（除了示例文件外不会被追踪）
│           └── Example.ps1                     # 示例
├── README.md
├── sketchybar              # SketchyBar 配置子模块（独立维护，当前未纳入主部署脚本）
├── starship
│   └── starship.toml       # starship 配置
├── tmux                    # tmux 配置
│   ├── plugins             # tpm 子模块与本地插件目录
│   └── tmux.conf           # tmux 配置文件
├── wezterm                 # WezTerm 配置以及背景资源
├── yazi                    # yazi 配置
│   ├── init.lua            # yazi lua 初始化脚本
│   ├── keymap.toml         # yazi 快捷键配置（tracked，SFTP 快捷键在 locals/ 中）
│   ├── locals              # yazi 本地隐私配置（gitignored）
│   │   ├── keymap-sftp.toml
│   │   └── vfs.toml
│   ├── package.toml        # yazi 插件配置
│   ├── theme.toml          # yazi 主题配置
│   ├── vfs.toml            # yazi SFTP 服务定义标记文件（tracked，实际定义在 locals/ 中）
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

本仓库采用以下约定：**仓库只存放"源文件"，实际配置通过符号链接（symlink）映射到真实路径。**

对于**脚本型**配置（zsh、pwsh、wezterm、nvim、tmux），源目录直接链接到目标路径，本地覆盖通过各自 `locals/` 子目录在运行时加载。

对于**纯文件型**配置（aerospace、cava、starship、yazi），部署时通过 render 阶段将基础配置与 `locals/` 本地差异合并，输出到统一的 `/generated/` 目录（gitignored），再链接到目标路径。基础配置中可使用 `# @platform:<file>` 或 `# @locals:<file>` 注释标记精确控制内容插入位置。

例如：

- `~/.config/wezterm/`  ->  `dotfiles/wezterm/`
- `~/.zshrc` -> `dotfiles/zsh/.zshrc`，`~/.config/zsh/` -> `dotfiles/zsh/zsh/`
- `~/.config/starship.toml` -> `dotfiles/generated/starship/starship.toml`
- `$PROFILE` -> `dotfiles\pwsh\Microsoft.PowerShell_profile.ps1`，`~\.config\pwsh\` -> `dotfiles\pwsh\pwsh\`
- `~/.config/yazi/` -> `dotfiles/generated/yazi/` 或 `%AppData%\yazi\config\` -> `dotfiles\generated\yazi\`
- `~/.config/cava` -> `dotfiles/generated/cava`
- `~/.config/nvim` -> `dotfiles/nvim/` 或 `%LocalAppData\nvim\` -> `dotfiles\nvim\`
- `~/.config/tmux` -> `dotfiles/tmux/`
- `~/.config/aerospace/` -> `dotfiles/generated/aerospace/`
- `~/.config/borders/` -> `dotfiles/borders/`
- `~/.config/sketchybar/` -> `dotfiles/sketchybar/`
- `~/.config/fastfetch/` -> `dotfiles/fastfetch/`
- `~/.config/gitlogue/` -> `dotfiles/gitlogue/`

`locals/` 目录用于存放机器特定的本地覆盖配置，不进入 Git 追踪。它与 `generated/` 渲染目录配合：

- **脚本型 config**（zsh、pwsh）：`locals/` 在运行时被 `source`/`dofile` 加载。例如 conda 使用懒加载——首次输入 `conda` 命令时，才会 source `~/.config/zsh/locals/conda.zsh`（或 Windows 下的 `~\.config\pwsh\Locals\Conda.ps1`）。用户需运行 `conda init zsh`（或 `conda init powershell`），然后将输出的初始化块放入对应文件即可。
- **纯文件型 config**（aerospace、cava、starship、yazi）：基础配置中通过 `# @locals:<file>` 标记预留插入点，部署 render 阶段将 locals 内容注入标记位置，输出到 `generated/`。

`generated/` 是统一的渲染产物目录（gitignored），由 deploy 的 render 阶段自动生成。纯文件型配置的符号链接指向 `generated/` 而非源目录。

## 4. 部署

部署脚本分为两套实现：

- POSIX：`deploy/macos.sh`、`deploy/ubuntu.sh`、`deploy/termux.sh`
- Windows：`deploy/windows.ps1`

两套实现共享同一套部署思路，按 deploy unit 生命周期执行：

- `prepare -> install（若缺失）-> recheck availability -> render -> link -> update`
- 软件安装与配置链接分离；软件仍不可用时，会跳过后续 render/link/update，而不是强行继续
- render 阶段负责将基础配置与平台差异（`@platform:`）和本地差异（`@locals:`）合并，输出到 `generated/`；无标记时走快路径（直接复制）
- 配置部署以符号链接为主，冲突处理统一由 `--config-mode` / `-ConfigMode` 控制

部署脚本会：

- 创建必要的目录
- 自动创建符号链接
- 对已有文件做提示，避免误覆盖
- 可以自动确认安装类操作，但配置覆盖策略需要单独指定

当前实际覆盖范围：

- macOS：字体、WezTerm、CLI 工具、zsh 插件、Starship、zsh、Yazi、Cava、LazyVim、fastfetch、gitlogue、tmux，以及 Aerospace + borders + SketchyBar 窗口管理栈
- Ubuntu / Linux：共享 POSIX 主流程，入口脚本以 Ubuntu 为主；包管理器优先级是 `apt -> dnf -> pacman -> brew`，实测除了字体安装被跳过以外其余在 Ubuntu 均可以成功
- Windows：AltSnap、JetBrains Mono、WezTerm、PSGallery、CLI 工具、Starship、PowerShell、Yazi、Cava、LazyVim、fastfetch、gitlogue
- Termux：共享 POSIX 主流程，但 WezTerm 会被显式跳过，考虑到手机上使用 Termux 作为终端。

补充说明：

- 仓库当前包含 `tmux/plugins/tpm` 与 `sketchybar/` 两个子模块，因此示例中的克隆命令保留 `--recurse-submodules`。

已知约束：

- Linux 部署目前是 Ubuntu 优先，不应理解为完整通用 Linux 部署器
- Ubuntu 上的 Cava 使用独立的 `cava/ubuntu` 配置
- Windows 的 `PSFzf` 部署单元已移除（fzf 可用性由 CLI Tools 覆盖）
- 自动字体安装目前主要覆盖 macOS；Windows 只单独处理 JetBrains Mono
- POSIX 在无交互 TTY 时无法确认安装类操作，这类步骤会倾向于跳过

可能的系统副作用：

- macOS 可能添加 `FelixKratz/formulae` Homebrew tap
- Ubuntu 可能添加 WezTerm 官方 APT 源
- Debian / Ubuntu 上可能创建 `/usr/local/bin/fd -> fdfind` 兼容链接
- Windows 可能注册 `PSGallery`，并在确认后把 OpenSSH 默认 shell 改成 `pwsh` 后重启 `sshd`
- Windows 未开启开发者模式且未以管理员身份运行时，符号链接创建可能失败

> 使用过程中请注意提示与警告！以免错过重要信息！
>
> 国内建议提前配置代理或镜像源

部署参数：

- POSIX（macOS / Ubuntu / Termux）：
  - `--yes-install`：自动确认安装或更新软件包、插件等安装类操作。
  - `--config-mode ask|backup|replace|replace-link|skip`：配置目标已存在时的处理方式，默认 `ask`。
  - `--preset beautification|beauty|development|dev`：按预设过滤部署单元（逗号分隔取并集）。
  - `--skip UNIT,...`：排除指定部署单元（逗号分隔，不区分大小写）。
  - `--only UNIT,...`：仅部署指定单元（逗号分隔，不区分大小写；与 `--preset` 互斥）。
- Windows：
  - `-YesInstall`：自动确认安装或更新软件包、插件等安装类操作。
  - `-ConfigMode ask|backup|replace|replace-link|skip`：配置目标已存在时的处理方式，默认 `ask`。
  - `-Preset beautification|beauty|development|dev`：按预设过滤部署单元（逗号分隔取并集）。
  - `-Skip UNIT,...`：排除指定部署单元（逗号分隔，不区分大小写）。
  - `-Only UNIT,...`：仅部署指定单元（逗号分隔，不区分大小写；与 `-Preset` 互斥）。

配置处理方式：

- `ask`：每次遇到已存在的配置目标时询问。交互时使用小写字母只对本次生效，使用大写字母会对后续全部生效。
- `backup`：备份已有符号链接、文件或目录，再创建新链接。
- `replace`：删除已有符号链接、文件或目录，再创建新链接。
- `replace-link`：已有符号链接时替换；已有文件或目录时备份。
- `skip`：已有目标时直接跳过，不创建新链接。

> `--yes-install` / `-YesInstall` 只会自动确认安装类操作，不会自动确认配置覆盖、删除、备份、快捷方式、默认 shell 等其他操作。

### 4.1. 预设覆盖

| POSIX 单元 | Windows 单元 | beauty | dev |
|------------|-------------|--------|-----|
| Fonts | JetBrains | x | x |
| WezTerm | WezTerm | x | x |
| — | — | | |
| CLI Tools | CLI Tools | | x |
| zsh Plugins | — | | x |
| zsh | PWSH | | x |
| — | AltSnap | | x |
| Starship | Starship | x | x |
| Yazi | Yazi | x | x |
| LazyVim | LazyVim | x | x |
| tmux | — | x | x |
| Cava | Cava | x | |
| fastfetch | fastfetch | x | |
| gitlogue | gitlogue | x | |
| Aerospace | — | x | |
| borders | — | x | |
| SketchyBar | — | x | |

示例：

```bash
./deploy/macos.sh --yes-install --config-mode replace-link
./deploy/macos.sh --preset beauty
./deploy/macos.sh --preset dev --skip Cava
./deploy/macos.sh --only WezTerm,LazyVim
```

```powershell
.\deploy\windows.ps1 -YesInstall -ConfigMode replace-link
.\deploy\windows.ps1 -Preset beauty
.\deploy\windows.ps1 -Preset dev -Skip Cava
.\deploy\windows.ps1 -Only WezTerm,LazyVim
```

### 4.2. Ubuntu / Linux（Ubuntu 优先）

推荐在 Ubuntu 上使用，并确保至少有可用的 `apt`。脚本内部对 `dnf`、`pacman`、`brew` 有部分 fallback 支持，但当前入口和实际测试范围仍以 Ubuntu 为主。

在新机器上执行以下步骤即可部署配置：

```bash
git clone --recurse-submodules https://github.com/milk2715093695/dotfiles.git
cd ./dotfiles
chmod +x ./deploy/ubuntu.sh
./deploy/ubuntu.sh
```

### 4.3. macOS

推荐提前安装 `Homebrew`。

在新机器上执行以下步骤即可部署配置：

```bash
git clone --recurse-submodules https://github.com/milk2715093695/dotfiles.git
cd ./dotfiles
chmod +x ./deploy/macos.sh
./deploy/macos.sh
```

### 4.4. Windows

- 推荐使用 `pwsh` 运行。
- 包管理器优先级为 `scoop -> winget`；至少准备其中一个。
- 推荐以管理员身份运行，或先开启 Windows 开发者模式，否则符号链接可能失败。
- 如果确认将 OpenSSH 默认 shell 切换到 `pwsh`，脚本会修改注册表并重启 `sshd`。

> **Scoop 需要手动安装**：部署脚本推荐以管理员身份运行（创建符号链接需要管理员权限），但 Scoop 官方要求非管理员安装，而 Windows 不支持对部分命令降权。考虑到安全性与官方推荐，脚本不会自动安装 Scoop，请按以下步骤手动准备：
>
> ```powershell
> # 以普通用户身份（非管理员）打开 PowerShell，执行：
> Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
> irm get.scoop.sh | iex
> ```

部署步骤：

```powershell
git clone --recurse-submodules https://github.com/milk2715093695/dotfiles.git
cd .\dotfiles
Set-ExecutionPolicy Bypass -Scope Process -Force
.\deploy\windows.ps1
```

### 4.5. Termux

Termux 使用 `pkg` 作为包管理器，并会跳过 WezTerm。zsh 插件除了 `zsh-completions` 外，还会把 `zsh-autosuggestions` 与 `zsh-syntax-highlighting` 克隆到 `~/.zsh/`。

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
  - [X] AeroSpace 配置
  - [X] Sketchybar 配置
  - [X] fastfetch 配置
  - [X] gitlogue 配置
- 部署
  - [X] Ubuntu 部署脚本
  - [X] macOS 部署脚本
  - [X] Windows 部署脚本
  - [X] Android-termux 部署脚本
  - [X] Sketchybar 主部署集成
- 重构
  - 配置文件拆分
    - [X] AeroSpace 配置拆分
    - [X] cava 配置拆分
  - 部署脚本优化
    - [X] 消除重复代码

## 许可证

本仓库采用 MIT 许可证。详情见 [LICENSE](./LICENSE) 文件。

关于 Windows 配置中使用 AltSnap（GPLv3）的问题：AltSnap 是 Stefan Sundin 的 AltDrag 的 fork；本仓库不包含 AltSnap / AltDrag 源码或可执行文件，部署时会从 `RamonUnch/AltSnap` 发布页下载并安装。AltSnap 许可、Wiki 与更新记录请参见：[AltSnap 仓库](https://github.com/RamonUnch/AltSnap)；AltDrag 原始文档仅作历史参考：[AltDrag 原始文档](https://stefansundin.github.io/altdrag/doc/)。
