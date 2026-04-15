$MY_PWSH_CONFIG = "$HOME\.config\pwsh"

# 配置加载顺序：
# Env       环境变量、PATH、默认编辑器等
# Options   PSReadLine、历史记录、补全行为等
# Aliases   简单别名
# Functions 自定义函数和命令包装器
# Hook      事件钩子
# Plugins   第三方插件、prompt 初始化，通常最后加载
$profileParts = @(
    "Env"
    "Options"
    "Aliases"
    "Functions"
    "Hook"
    "Plugins"
)

foreach ($part in $profileParts) {
    $profilePart = "$MY_PWSH_CONFIG\$part.ps1"
    . $profilePart

    $localProfilePart = "$MY_PWSH_CONFIG\locals\$part.ps1"
    if (Test-Path -LiteralPath $localProfilePart -PathType Leaf) {
        . $localProfilePart
    }
}

Remove-Variable MY_PWSH_CONFIG, profileParts, part, profilePart, localProfilePart -Scope Global -ErrorAction SilentlyContinue
