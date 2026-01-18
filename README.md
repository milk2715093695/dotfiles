# dotfiles

这是一个用于管理个人配置的仓库（dotfiles）。  

- [dotfiles](#dotfiles)
  - [目录结构](#目录结构)
  - [配置路径约定](#配置路径约定)
  - [部署（Ubuntu）](#部署ubuntu)
  - [未来计划](#未来计划)
  - [许可证](#许可证)

## 目录结构

```text
.
├── deploy      # 部署脚本
│   └── ubuntu.sh
└── wezterm     # WezTerm 配置文件及资源
    ├── Background.jpg
    └── wezterm.lua
```

- `wezterm/`：WezTerm 配置文件及资源
- `deploy/`：部署脚本

## 配置路径约定

本仓库采用以下约定：  
**仓库只存放“源文件”，实际配置通过符号链接（symlink）映射到真实路径。**

例如：

- `~/.config/wezterm/`  ->  `dotfiles/wezterm/`

## 部署（Ubuntu）

在新机器上执行以下步骤即可部署配置：

```bash
git clone https://github.com/milk2715093695/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x ./deploy/ubuntu.sh
./deploy/ubuntu.sh
```

部署脚本会：

- 创建必要的目录
- 自动创建符号链接
- 对已有文件做提示，避免误覆盖

> 使用过程中请注意提示与警告！以免错过重要信息！

## 未来计划

- [ ] zsh 配置
- [ ] vim/nvim 配置
- [ ] starship 配置

## 许可证

本仓库采用 MIT 许可证。详情见 [LICENSE](./LICENSE) 文件。
