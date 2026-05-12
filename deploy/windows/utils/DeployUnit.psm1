Set-StrictMode -Version Latest

$script:DeployUnitSlots = @(
    "StageName",
    "Name",
    "AvailabilityCheck",
    "Prepare",
    "Install",
    "Render",
    "Link",
    "Update",
    "Tags"
)

# 校验 deploy unit manifest 是否显式声明全部槽位
function Test-DeployUnitManifest {
    param(
        [Parameter(Mandatory)]
        [hashtable]$Unit
    )

    foreach ($slot in $script:DeployUnitSlots) {
        if (-not $Unit.ContainsKey($slot)) {
            throw "deploy unit manifest 槽位未设置：$slot"
        }
    }

    foreach ($slot in @("StageName", "Name")) {
        if ([string]::IsNullOrWhiteSpace([string]$Unit[$slot])) {
            throw "deploy unit manifest 槽位不能为空：$slot"
        }
    }

    foreach ($slot in @("AvailabilityCheck", "Prepare", "Install", "Render", "Link", "Update")) {
        $value = $Unit[$slot]
        if ($null -ne $value -and $value -isnot [scriptblock]) {
            throw "$($Unit.Name) 的 $slot 阶段必须是 scriptblock 或 null"
        }
    }

    $tags = $Unit["Tags"]
    if ($null -ne $tags -and $tags -isnot [string[]] -and $tags -isnot [array]) {
        throw "$($Unit.Name) 的 Tags 必须是 string 数组或 null"
    }

    return $true
}

# 执行可选阶段
function Invoke-DeployUnitPhase {
    param(
        [AllowNull()]
        [scriptblock]$ScriptBlock
    )

    if ($null -eq $ScriptBlock) {
        return
    }

    & $ScriptBlock
}

# 判断 deploy unit 是否可用
function Test-DeployUnitAvailable {
    param(
        [Parameter(Mandatory)]
        [scriptblock]$AvailabilityCheck
    )

    return [bool](& $AvailabilityCheck)
}

# 执行一个 deploy unit 生命周期
function Invoke-DeployUnit {
    param(
        [Parameter(Mandatory)]
        [hashtable]$Unit,

        [Parameter(Mandatory)]
        [hashtable]$DeployContext
    )

    Test-DeployUnitManifest -Unit $Unit | Out-Null

    $unitName = [string]$Unit.Name
    $availabilityCheck = $Unit.AvailabilityCheck

    # 过滤检查
    $unitTags = $Unit.Tags
    if ($null -eq $unitTags) { $unitTags = @() }
    if (-not (Test-UnitSelected -UnitName $unitName -UnitTags $unitTags -DeployContext $DeployContext)) {
        Write-SKIP "$unitName 被过滤，跳过"
        return
    }

    Invoke-DeployUnitPhase -ScriptBlock $Unit.Prepare

    if ($null -ne $availabilityCheck -and (Test-DeployUnitAvailable -AvailabilityCheck $availabilityCheck)) {
        if ($null -ne $Unit.Install) {
            Write-SKIP "$unitName 已可用，跳过安装"
        }
    } else {
        Invoke-DeployUnitPhase -ScriptBlock $Unit.Install
    }

    if ($null -ne $availabilityCheck -and -not (Test-DeployUnitAvailable -AvailabilityCheck $availabilityCheck)) {
        Write-WARNING "没有 $unitName，跳过 $unitName 配置"
        throw (New-DeployStageSkippedException)
    }

    Invoke-DeployUnitPhase -ScriptBlock $Unit.Render
    Invoke-DeployUnitPhase -ScriptBlock $Unit.Link
    Invoke-DeployUnitPhase -ScriptBlock $Unit.Update
}

# 以顶层部署阶段执行一个 deploy unit 生命周期
function Invoke-DeployUnitStage {
    param(
        [Parameter(Mandatory)]
        [hashtable]$Unit,

        [Parameter(Mandatory)]
        [hashtable]$DeployContext
    )

    Test-DeployUnitManifest -Unit $Unit | Out-Null

    $scriptBlock = {
        Invoke-DeployUnit -Unit $Unit -DeployContext $DeployContext
    }.GetNewClosure()

    Invoke-DeployStage -Name $Unit.StageName -ScriptBlock $scriptBlock
}

Export-ModuleMember -Function Invoke-DeployUnit, Invoke-DeployUnitStage
