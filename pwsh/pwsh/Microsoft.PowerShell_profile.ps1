$MY_PWSH_CONFIG="$HOME\.config\pwsh"

. "$MY_PWSH_CONFIG\Env.ps1"         # 加载环境变量
. "$MY_PWSH_CONFIG\Options.ps1"     # 加载 pwsh 选项
. "$MY_PWSH_CONFIG\Aliases.ps1"     # 加载别名
. "$MY_PWSH_CONFIG\Functions.ps1"   # 加载函数
. "$MY_PWSH_CONFIG\Hook.ps1"        # 加载钩子
. "$MY_PWSH_CONFIG\Plugins.ps1"     # 加载插件

Remove-Variable MY_PWSH_CONFIG -Scope Global
