# 公共引导：source 所有跨平台共享的工具和包模块
_BOOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$_BOOT_DIR/utils/colors.sh"                      # 颜色变量
source "$_BOOT_DIR/utils/output_view.sh"                 # 输出视图
source "$_BOOT_DIR/utils/context.sh"                     # 部署上下文
source "$_BOOT_DIR/utils/prompt.sh"                      # 提示函数
source "$_BOOT_DIR/utils/link_action.sh"                 # 链接策略
source "$_BOOT_DIR/utils/link.sh"                        # 链接函数
source "$_BOOT_DIR/utils/software_availability.sh"       # 软件可用性检测
source "$_BOOT_DIR/utils/package_mapping.sh"             # 软件包映射
source "$_BOOT_DIR/utils/package_manager_selection.sh"   # 包管理器选择
source "$_BOOT_DIR/utils/install_package.sh"             # 安装包函数
source "$_BOOT_DIR/utils/deploy_unit.sh"                 # 部署单元生命周期
source "$_BOOT_DIR/utils/render_config.sh"               # 配置渲染工具
source "$_BOOT_DIR/utils/tool_check.sh"                  # 系统工具预检

source "$_BOOT_DIR/packages/fonts.sh"                    # 安装字体
source "$_BOOT_DIR/packages/cli_tools.sh"                # 常用命令行工具
source "$_BOOT_DIR/packages/wezterm.sh"                  # WezTerm 配置
source "$_BOOT_DIR/packages/zsh.sh"                      # zsh 配置
source "$_BOOT_DIR/packages/zsh_plugins.sh"              # zsh 插件配置
source "$_BOOT_DIR/packages/starship.sh"                 # Starship 安装
source "$_BOOT_DIR/packages/yazi.sh"                     # Yazi 配置
source "$_BOOT_DIR/packages/lazyvim.sh"                  # LazyVim 配置
source "$_BOOT_DIR/packages/tmux.sh"                     # tmux 配置
source "$_BOOT_DIR/packages/cava.sh"                     # Cava 配置
source "$_BOOT_DIR/packages/fastfetch.sh"                # fastfetch 配置

source "$_BOOT_DIR/main.sh"                              # 入口函数
