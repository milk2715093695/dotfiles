Set-StrictMode -Version Latest

# 预设定义：预设名 → 标签集合
# beautification: 看得到的 — 字体/终端/prompt/窗口管理/文件管理器/编辑器
# development:   用得着的 — CLI 工具/zsh 配置/插件/编辑器/文件管理器
$script:PresetTags = @{
    "beautification" = @("beauty")
    "beauty"         = @("beauty")
    "development"    = @("dev")
    "dev"            = @("dev")
}

# 将预设名（全名或短名，不区分大小写）映射为标签列表
function Get-PresetTags {
    param(
        [Parameter(Mandatory)]
        [string]$PresetName
    )

    $key = $PresetName.ToLowerInvariant()
    if ($script:PresetTags.ContainsKey($key)) {
        return $script:PresetTags[$key]
    }
    return $null
}

# 根据当前过滤设置判断 unit 是否被选中
function Test-UnitSelected {
    param(
        [Parameter(Mandatory)]
        [string]$UnitName,

        [Parameter(Mandatory)]
        [string[]]$UnitTags,

        [Parameter(Mandatory)]
        [hashtable]$DeployContext
    )

    $onlyUnits = Get-DeployOnlyUnits -DeployContext $DeployContext
    $skipUnits = Get-DeploySkipUnits -DeployContext $DeployContext
    $preset = Get-DeployPreset -DeployContext $DeployContext

    # --only: 仅部署指定 unit，忽略 preset 和 skip
    if ($onlyUnits) {
        return $onlyUnits -contains $UnitName.ToLowerInvariant()
    }

    # --skip: 排除指定 unit
    if ($skipUnits -and ($skipUnits -contains $UnitName.ToLowerInvariant())) {
        return $false
    }

    # --preset: 按标签交集过滤
    if ($preset) {
        $presetList = $preset -split ','
        $matched = $false

        foreach ($p in $presetList) {
            $tags = Get-PresetTags -PresetName $p.Trim()
            if (-not $tags) { continue }

            foreach ($tag in $UnitTags) {
                if ($tags -contains $tag.ToLowerInvariant()) {
                    $matched = $true
                    break 2
                }
            }
        }

        if (-not $matched) {
            return $false
        }
    }

    return $true
}

Export-ModuleMember -Function Get-PresetTags, Test-UnitSelected
