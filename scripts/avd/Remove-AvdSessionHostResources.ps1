#Requires -Version 7.4

<#
.SYNOPSIS
AVD SessionHost、対応するAzure VM、NIC、Managed Diskを段階的に削除する公開用サンプルです。

.DESCRIPTION
実務で利用したAVD SessionHost削除スクリプトの処理思想を一般化したものです。
顧客名、実環境名、実Resource Group名、実HostPool名、実UPNなどは含めません。

主な処理:
- CSVで対象VMを指定
- HostPool上のSessionHostを特定
- Active sessionがある場合はスキップ
- 非Active sessionをサインアウト
- セッション再確認
- SessionHost削除
- Azure VM削除
- VM削除完了確認
- NIC削除
- Managed Disk削除
- 最終残存確認
- ログとSummary出力

注意:
- 既定ではDryRunです。実変更する場合のみ -Execute を明示します。
- 本番利用時は、承認済み変更手順、利用者影響確認、バックアップ/Lock/業務データ有無の確認が必要です。
- 公開用サンプルでは、環境固有値を含めない前提です。
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$CsvPath = ".\scripts\avd\samples\remove-avd-sessionhost-targets.sample.csv",

    [Parameter(Mandatory = $true)]
    [string]$AvdResourceGroupName,

    [Parameter(Mandatory = $true)]
    [string]$HostPoolName,

    [Parameter(Mandatory = $false)]
    [switch]$Execute,

    [Parameter(Mandatory = $false)]
    [int]$WaitAfterLogoffSec = 20,

    [Parameter(Mandatory = $false)]
    [int]$SessionRecheckMaxCount = 3,

    [Parameter(Mandatory = $false)]
    [int]$VmDeleteTimeoutSec = 900,

    [Parameter(Mandatory = $false)]
    [int]$VmDeletePollIntervalSec = 15
)

$DryRun = -not $Execute.IsPresent
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [System.Text.UTF8Encoding]::new($false)

$scriptFolder = Split-Path -Parent $MyInvocation.MyCommand.Path
$logFolder    = Join-Path $scriptFolder "output"

if (-not (Test-Path $logFolder)) {
    New-Item -Path $logFolder -ItemType Directory | Out-Null
}

$timestamp   = Get-Date -Format "yyyyMMdd-HHmmss"
$logFilePath = Join-Path $logFolder "delete-result-$timestamp.log"

$summary = [ordered]@{
    TotalTargets                 = 0
    CsvInvalid                   = 0
    AuthenticationError          = 0
    SessionHostNotFound          = 0
    ActiveSessionSkipped         = 0
    PrecheckReady                = 0
    SessionLogoffSuccess         = 0
    SessionLogoffError           = 0
    SessionRemainSkipped         = 0
    SessionHostDeleteSuccess     = 0
    SessionHostDeleteError       = 0
    VmDeleteRequestSuccess       = 0
    VmDeleteRequestError         = 0
    VmDeleteConfirmed            = 0
    VmDeleteTimeout              = 0
    VmStillExists                = 0
    NicDeleteSuccess             = 0
    NicDeleteError               = 0
    DiskDeleteSuccess            = 0
    DiskDeleteError              = 0
    FinalCheckSuccess            = 0
    FinalCheckWarning            = 0
    Partial                      = 0
    DryRunCount                  = 0
}

function Write-LogLine {
    param(
        [string]$RowNo = "",
        [string]$Phase = "",
        [string]$HostPool = "",
        [string]$VmRg = "",
        [string]$VmName = "",
        [string]$SessionHost = "",
        [string]$Action = "",
        [string]$Result = "",
        [string]$Detail = ""
    )

    $dt = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "$dt | RowNo=$RowNo | Phase=$Phase | HostPool=$HostPool | VmRg=$VmRg | VmName=$VmName | SessionHost=$SessionHost | Action=$Action | Result=$Result | Detail=$Detail"
    Add-Content -Path $logFilePath -Value $line -Encoding UTF8
    Write-Host $line
}

function Get-LeafNameFromResourceId {
    param([string]$Id)
    if ([string]::IsNullOrWhiteSpace($Id)) { return $null }
    return ($Id -split "/")[-1]
}

function Get-SessionHostShortName {
    param([string]$SessionHostName)
    if ([string]::IsNullOrWhiteSpace($SessionHostName)) { return $null }
    return ($SessionHostName -split "\.")[0]
}

function Assert-AzureContext {
    try {
        $ctx = Get-AzContext -ErrorAction Stop
        if (-not $ctx) {
            throw "Azure context not found."
        }
    }
    catch {
        throw "Azure にログインされていません。事前に Connect-AzAccount / Set-AzContext を実施してください。"
    }
}

function Test-AvdAccess {
    param(
        [string]$AvdResourceGroupName,
        [string]$HostPoolName
    )

    try {
        $null = Get-AzWvdSessionHost -ResourceGroupName $AvdResourceGroupName -HostPoolName $HostPoolName -ErrorAction Stop
    }
    catch {
        throw "AVD リソースへのアクセス確認に失敗しました。Connect-AzAccount -TenantId <対象TenantId> を実施してください。詳細: $($_.Exception.Message)"
    }
}

function Get-TargetSessionHostFromCache {
    param(
        [object[]]$SessionHosts,
        [string]$VmName
    )

    return $SessionHosts | Where-Object {
        $leaf = Get-LeafNameFromResourceId $_.Name
        $shortName = Get-SessionHostShortName $leaf
        $shortName -and ($shortName.ToLower() -eq $VmName.ToLower())
    } | Select-Object -First 1
}

try {
    Assert-AzureContext
    Test-AvdAccess -AvdResourceGroupName $AvdResourceGroupName -HostPoolName $HostPoolName

    if (-not (Test-Path $CsvPath)) {
        throw "CSVが見つかりません: $CsvPath"
    }

    $rows = Import-Csv -Path $CsvPath
    if (-not $rows -or $rows.Count -eq 0) {
        throw "CSVが空です。"
    }

    $requiredColumns = @("VmResourceGroupName", "VmName")
    foreach ($col in $requiredColumns) {
        if (-not ($rows[0].PSObject.Properties.Name -contains $col)) {
            throw "CSVに必須列がありません: $col"
        }
    }

    $cleanRows = @()
    $rowNo = 1
    foreach ($r in $rows) {
        $vmRg   = [string]$r.VmResourceGroupName
        $vmName = [string]$r.VmName

        if ([string]::IsNullOrWhiteSpace($vmRg) -or [string]::IsNullOrWhiteSpace($vmName)) {
            Write-LogLine -RowNo $rowNo -Phase "CSV" -HostPool $HostPoolName -VmRg $vmRg -VmName $vmName -Action "ValidateCsv" -Result "Skip" -Detail "必須値不足"
            $summary.CsvInvalid++
            $rowNo++
            continue
        }

        $cleanRows += [pscustomobject]@{
            RowNo               = $rowNo
            VmResourceGroupName = $vmRg.Trim()
            VmName              = $vmName.Trim()
        }

        $rowNo++
    }

    if (-not $cleanRows -or $cleanRows.Count -eq 0) {
        throw "有効なCSV行がありません。"
    }

    $summary.TotalTargets = $cleanRows.Count

    Write-LogLine -Phase "SCRIPT" -Action "Start" -Result "Start" -Detail "Delete process started. DryRun=$($DryRun)"

    # HostPool の SessionHost 一覧を一度だけ取得
    $sessionHostCache = Get-AzWvdSessionHost -ResourceGroupName $AvdResourceGroupName -HostPoolName $HostPoolName -ErrorAction Stop

    # フェーズ1: 事前確認
    $readyList = New-Object System.Collections.Generic.List[object]

    foreach ($row in $cleanRows) {
        $rowNo   = $row.RowNo
        $vmRg    = $row.VmResourceGroupName
        $vmName  = $row.VmName

        try {
            $sessionHost = Get-TargetSessionHostFromCache -SessionHosts $sessionHostCache -VmName $vmName
        }
        catch {
            $message = $_.Exception.Message
            Write-LogLine -RowNo $rowNo -Phase "PRECHECK" -HostPool $HostPoolName -VmRg $vmRg -VmName $vmName -Action "FindSessionHost" -Result "Error" -Detail $message
            if ($message -like "*Authentication failed*") {
                $summary.AuthenticationError++
            }
            else {
                $summary.SessionHostNotFound++
            }
            continue
        }

        if (-not $sessionHost) {
            Write-LogLine -RowNo $rowNo -Phase "PRECHECK" -HostPool $HostPoolName -VmRg $vmRg -VmName $vmName -Action "FindSessionHost" -Result "Skip" -Detail "HostPool上に一致するSessionHostが見つかりません"
            $summary.SessionHostNotFound++
            continue
        }

        $sessionHostName = Get-LeafNameFromResourceId $sessionHost.Name
        Write-LogLine -RowNo $rowNo -Phase "PRECHECK" -HostPool $HostPoolName -VmRg $vmRg -VmName $vmName -SessionHost $sessionHostName -Action "FindSessionHost" -Result "Success" -Detail "対象SessionHostを特定"

        try {
            $sessions = @(Get-AzWvdUserSession -ResourceGroupName $AvdResourceGroupName -HostPoolName $HostPoolName -SessionHostName $sessionHostName -ErrorAction Stop)
        }
        catch {
            Write-LogLine -RowNo $rowNo -Phase "PRECHECK" -HostPool $HostPoolName -VmRg $vmRg -VmName $vmName -SessionHost $sessionHostName -Action "GetSessions" -Result "Error" -Detail $_.Exception.Message
            continue
        }

        $activeSessions = @($sessions | Where-Object { $_.SessionState -eq "Active" })
        if ($activeSessions.Count -gt 0) {
            $activeNames = $activeSessions | Select-Object -ExpandProperty Name
            Write-LogLine -RowNo $rowNo -Phase "PRECHECK" -HostPool $HostPoolName -VmRg $vmRg -VmName $vmName -SessionHost $sessionHostName -Action "CheckSessions" -Result "Skip" -Detail ("Active session exists: " + ($activeNames -join ","))
            $summary.ActiveSessionSkipped++
            continue
        }

        $vm = Get-AzVM -ResourceGroupName $vmRg -Name $vmName -ErrorAction SilentlyContinue
        $nicIds = @()
        $diskIds = @()

        if ($vm) {
            if ($vm.NetworkProfile -and $vm.NetworkProfile.NetworkInterfaces) {
                $nicIds = @($vm.NetworkProfile.NetworkInterfaces.Id)
            }

            if ($vm.StorageProfile -and $vm.StorageProfile.OsDisk -and $vm.StorageProfile.OsDisk.ManagedDisk -and $vm.StorageProfile.OsDisk.ManagedDisk.Id) {
                $diskIds += $vm.StorageProfile.OsDisk.ManagedDisk.Id
            }

            if ($vm.StorageProfile -and $vm.StorageProfile.DataDisks) {
                foreach ($disk in $vm.StorageProfile.DataDisks) {
                    if ($disk.ManagedDisk -and $disk.ManagedDisk.Id) {
                        $diskIds += $disk.ManagedDisk.Id
                    }
                }
            }
        }

        $readyList.Add([pscustomobject]@{
            RowNo            = $rowNo
            VmResourceGroup  = $vmRg
            VmName           = $vmName
            SessionHostName  = $sessionHostName
            Sessions         = $sessions
            VmObj            = $vm
            NicIds           = $nicIds
            DiskIds          = $diskIds
            SessionHostGone  = $false
            VmDeleteIssued   = $false
            VmDeleteConfirmed= $false
        })

        Write-LogLine -RowNo $rowNo -Phase "PRECHECK" -HostPool $HostPoolName -VmRg $vmRg -VmName $vmName -SessionHost $sessionHostName -Action "Ready" -Result "Success" -Detail "削除候補として採用"
        $summary.PrecheckReady++
    }

    if ($readyList.Count -eq 0) {
        Write-LogLine -Phase "SCRIPT" -Action "NoTarget" -Result "Skip" -Detail "削除可能な対象がありません"
    }
    else {
        # フェーズ2: Drain設定 + 非Activeセッションサインアウト
        foreach ($item in $readyList) {
            if ($DryRun) {
                Write-LogLine -RowNo $item.RowNo -Phase "SESSION" -HostPool $HostPoolName -VmRg $item.VmResourceGroup -VmName $item.VmName -SessionHost $item.SessionHostName -Action "SetDrainMode" -Result "DryRun" -Detail "AllowNewSession=false を設定予定"
                $summary.DryRunCount++
            }
            else {
                try {
                    Update-AzWvdSessionHost -ResourceGroupName $AvdResourceGroupName -HostPoolName $HostPoolName -Name $item.SessionHostName -AllowNewSession:$false | Out-Null
                    Write-LogLine -RowNo $item.RowNo -Phase "SESSION" -HostPool $HostPoolName -VmRg $item.VmResourceGroup -VmName $item.VmName -SessionHost $item.SessionHostName -Action "SetDrainMode" -Result "Success" -Detail "AllowNewSession=false 設定完了"
                }
                catch {
                    Write-LogLine -RowNo $item.RowNo -Phase "SESSION" -HostPool $HostPoolName -VmRg $item.VmResourceGroup -VmName $item.VmName -SessionHost $item.SessionHostName -Action "SetDrainMode" -Result "Warning" -Detail $_.Exception.Message
                }
            }

            $nonActiveSessions = @($item.Sessions | Where-Object { $_.SessionState -ne "Active" })

            if ($nonActiveSessions.Count -eq 0) {
                Write-LogLine -RowNo $item.RowNo -Phase "SESSION" -HostPool $HostPoolName -VmRg $item.VmResourceGroup -VmName $item.VmName -SessionHost $item.SessionHostName -Action "LogoffSession" -Result "Info" -Detail "非Activeセッションなし"
                continue
            }

            foreach ($s in $nonActiveSessions) {
                $sessionId = Get-LeafNameFromResourceId $s.Id
                if (-not $sessionId) {
                    Write-LogLine -RowNo $item.RowNo -Phase "SESSION" -HostPool $HostPoolName -VmRg $item.VmResourceGroup -VmName $item.VmName -SessionHost $item.SessionHostName -Action "LogoffSession" -Result "Skip" -Detail "Session IDを取得できないためスキップ"
                    continue
                }

                if ($DryRun) {
                    Write-LogLine -RowNo $item.RowNo -Phase "SESSION" -HostPool $HostPoolName -VmRg $item.VmResourceGroup -VmName $item.VmName -SessionHost $item.SessionHostName -Action "LogoffSession" -Result "DryRun" -Detail "SessionId=$sessionId をサインアウト予定"
                    $summary.DryRunCount++
                }
                else {
                    try {
                        Remove-AzWvdUserSession -ResourceGroupName $AvdResourceGroupName -HostPoolName $HostPoolName -SessionHostName $item.SessionHostName -Id $sessionId -Force | Out-Null
                        Write-LogLine -RowNo $item.RowNo -Phase "SESSION" -HostPool $HostPoolName -VmRg $item.VmResourceGroup -VmName $item.VmName -SessionHost $item.SessionHostName -Action "LogoffSession" -Result "Success" -Detail "SessionId=$sessionId をサインアウト"
                        $summary.SessionLogoffSuccess++
                    }
                    catch {
                        Write-LogLine -RowNo $item.RowNo -Phase "SESSION" -HostPool $HostPoolName -VmRg $item.VmResourceGroup -VmName $item.VmName -SessionHost $item.SessionHostName -Action "LogoffSession" -Result "Error" -Detail $_.Exception.Message
                        $summary.SessionLogoffError++
                    }
                }
            }
        }

        # サインアウト後再確認（20秒 × 最大3回）
        $readyAfterSession = New-Object System.Collections.Generic.List[object]

        foreach ($item in $readyList) {
            if ($DryRun) {
                Write-LogLine -RowNo $item.RowNo -Phase "SESSION" -HostPool $HostPoolName -VmRg $item.VmResourceGroup -VmName $item.VmName -SessionHost $item.SessionHostName -Action "RecheckSessions" -Result "DryRun" -Detail "DryRunのため再確認フェーズ省略"
                $readyAfterSession.Add($item)
                continue
            }

            $sessionCleared = $false

            for ($attempt = 1; $attempt -le $SessionRecheckMaxCount; $attempt++) {
                Start-Sleep -Seconds $WaitAfterLogoffSec

                try {
                    $remainSessions = @(
                        Get-AzWvdUserSession `
                            -ResourceGroupName $AvdResourceGroupName `
                            -HostPoolName $HostPoolName `
                            -SessionHostName $item.SessionHostName `
                            -ErrorAction SilentlyContinue
                    )
                }
                catch {
                    Write-LogLine -RowNo $item.RowNo -Phase "SESSION" -HostPool $HostPoolName -VmRg $item.VmResourceGroup -VmName $item.VmName -SessionHost $item.SessionHostName -Action "RecheckSessions" -Result "Error" -Detail ("Attempt=$attempt : " + $_.Exception.Message)
                    continue
                }

                if ($remainSessions.Count -eq 0) {
                    Write-LogLine -RowNo $item.RowNo -Phase "SESSION" -HostPool $HostPoolName -VmRg $item.VmResourceGroup -VmName $item.VmName -SessionHost $item.SessionHostName -Action "RecheckSessions" -Result "Success" -Detail "Attempt=$attempt : セッション残存なし"
                    $sessionCleared = $true
                    break
                }
                else {
                    $remainNames = $remainSessions | Select-Object -ExpandProperty Name
                    Write-LogLine -RowNo $item.RowNo -Phase "SESSION" -HostPool $HostPoolName -VmRg $item.VmResourceGroup -VmName $item.VmName -SessionHost $item.SessionHostName -Action "RecheckSessions" -Result "Retry" -Detail ("Attempt=$attempt : セッション残存あり -> " + ($remainNames -join ","))
                }
            }

            if ($sessionCleared) {
                $readyAfterSession.Add($item)
            }
            else {
                Write-LogLine -RowNo $item.RowNo -Phase "SESSION" -HostPool $HostPoolName -VmRg $item.VmResourceGroup -VmName $item.VmName -SessionHost $item.SessionHostName -Action "RecheckSessions" -Result "Skip" -Detail "最大再確認回数到達後もセッション残存のため削除中止"
                $summary.SessionRemainSkipped++
            }
        }

        # フェーズ3: SessionHost削除
        $readyAfterSessionHostDelete = New-Object System.Collections.Generic.List[object]

        foreach ($item in $readyAfterSession) {
            if ($DryRun) {
                Write-LogLine -RowNo $item.RowNo -Phase "SESSIONHOST" -HostPool $HostPoolName -VmRg $item.VmResourceGroup -VmName $item.VmName -SessionHost $item.SessionHostName -Action "DeleteSessionHost" -Result "DryRun" -Detail "SessionHost 削除予定"
                $summary.DryRunCount++
                $item.SessionHostGone = $true
                $readyAfterSessionHostDelete.Add($item)
                continue
            }

            try {
                Remove-AzWvdSessionHost -ResourceGroupName $AvdResourceGroupName -HostPoolName $HostPoolName -Name $item.SessionHostName -Force | Out-Null
                Write-LogLine -RowNo $item.RowNo -Phase "SESSIONHOST" -HostPool $HostPoolName -VmRg $item.VmResourceGroup -VmName $item.VmName -SessionHost $item.SessionHostName -Action "DeleteSessionHost" -Result "Success" -Detail "SessionHost 削除完了"
                $summary.SessionHostDeleteSuccess++
                $item.SessionHostGone = $true
                $readyAfterSessionHostDelete.Add($item)
            }
            catch {
                Write-LogLine -RowNo $item.RowNo -Phase "SESSIONHOST" -HostPool $HostPoolName -VmRg $item.VmResourceGroup -VmName $item.VmName -SessionHost $item.SessionHostName -Action "DeleteSessionHost" -Result "Error" -Detail $_.Exception.Message
                $summary.SessionHostDeleteError++
            }
        }

        # フェーズ4: VM削除要求投入（-NoWait 版）
        foreach ($item in $readyAfterSessionHostDelete) {
            if (-not $item.VmObj) {
                Write-LogLine -RowNo $item.RowNo -Phase "VM" -HostPool $HostPoolName -VmRg $item.VmResourceGroup -VmName $item.VmName -SessionHost $item.SessionHostName -Action "DeleteVM" -Result "Partial" -Detail "VMが見つからないため SessionHost のみ削除"
                $summary.Partial++
                continue
            }

            if ($DryRun) {
                Write-LogLine -RowNo $item.RowNo -Phase "VM" -HostPool $HostPoolName -VmRg $item.VmResourceGroup -VmName $item.VmName -SessionHost $item.SessionHostName -Action "DeleteVM" -Result "DryRun" -Detail "VM 削除予定（-NoWait 想定）"
                $summary.DryRunCount++
                $item.VmDeleteIssued = $true
                continue
            }

            try {
                Remove-AzVM -ResourceGroupName $item.VmResourceGroup -Name $item.VmName -Force -NoWait | Out-Null
                Write-LogLine -RowNo $item.RowNo -Phase "VM" -HostPool $HostPoolName -VmRg $item.VmResourceGroup -VmName $item.VmName -SessionHost $item.SessionHostName -Action "DeleteVM" -Result "RequestAccepted" -Detail "VM 削除要求を非同期送信"
                $summary.VmDeleteRequestSuccess++
                $item.VmDeleteIssued = $true
            }
            catch {
                Write-LogLine -RowNo $item.RowNo -Phase "VM" -HostPool $HostPoolName -VmRg $item.VmResourceGroup -VmName $item.VmName -SessionHost $item.SessionHostName -Action "DeleteVM" -Result "Error" -Detail $_.Exception.Message
                $summary.VmDeleteRequestError++
            }
        }

        # フェーズ5: VM削除確認
        $vmConfirmedList = New-Object System.Collections.Generic.List[object]

        if ($DryRun) {
            foreach ($item in $readyAfterSessionHostDelete) {
                if ($item.VmDeleteIssued -or -not $item.VmObj) {
                    Write-LogLine -RowNo $item.RowNo -Phase "VM" -HostPool $HostPoolName -VmRg $item.VmResourceGroup -VmName $item.VmName -SessionHost $item.SessionHostName -Action "ConfirmDeleteVM" -Result "DryRun" -Detail "DryRunのため削除確認フェーズ省略"
                    $vmConfirmedList.Add($item)
                }
            }
        }
        else {
            $vmWaitTargets = @($readyAfterSessionHostDelete | Where-Object { $_.VmDeleteIssued -and $_.VmObj })

            if ($vmWaitTargets.Count -gt 0) {
                $deadline = (Get-Date).AddSeconds($VmDeleteTimeoutSec)
                $pending = New-Object System.Collections.Generic.List[object]
                foreach ($p in $vmWaitTargets) {
                    $pending.Add($p)
                }

                while ($pending.Count -gt 0 -and (Get-Date) -lt $deadline) {
                    $completedThisRound = @()

                    foreach ($item in $pending) {
                        $exists = $null -ne (Get-AzVM -ResourceGroupName $item.VmResourceGroup -Name $item.VmName -ErrorAction SilentlyContinue)
                        if (-not $exists) {
                            Write-LogLine -RowNo $item.RowNo -Phase "VM" -HostPool $HostPoolName -VmRg $item.VmResourceGroup -VmName $item.VmName -SessionHost $item.SessionHostName -Action "ConfirmDeleteVM" -Result "Success" -Detail "VM 削除確認完了"
                            $summary.VmDeleteConfirmed++
                            $item.VmDeleteConfirmed = $true
                            $vmConfirmedList.Add($item)
                            $completedThisRound += $item
                        }
                    }

                    foreach ($done in $completedThisRound) {
                        [void]$pending.Remove($done)
                    }

                    if ($pending.Count -gt 0) {
                        Start-Sleep -Seconds $VmDeletePollIntervalSec
                    }
                }

                foreach ($item in $pending) {
                    $exists = $null -ne (Get-AzVM -ResourceGroupName $item.VmResourceGroup -Name $item.VmName -ErrorAction SilentlyContinue)

                    if ($exists) {
                        Write-LogLine -RowNo $item.RowNo -Phase "VM" -HostPool $HostPoolName -VmRg $item.VmResourceGroup -VmName $item.VmName -SessionHost $item.SessionHostName -Action "ConfirmDeleteVM" -Result "Timeout" -Detail "VM 削除確認がタイムアウト"
                        $summary.VmDeleteTimeout++
                        $summary.VmStillExists++
                    }
                    else {
                        Write-LogLine -RowNo $item.RowNo -Phase "VM" -HostPool $HostPoolName -VmRg $item.VmResourceGroup -VmName $item.VmName -SessionHost $item.SessionHostName -Action "ConfirmDeleteVM" -Result "Success" -Detail "VM 削除確認完了"
                        $summary.VmDeleteConfirmed++
                        $item.VmDeleteConfirmed = $true
                        $vmConfirmedList.Add($item)
                    }
                }
            }

            foreach ($item in $readyAfterSessionHostDelete | Where-Object { -not $_.VmObj }) {
                $vmConfirmedList.Add($item)
            }
        }

        # フェーズ6: NIC / Disk削除
        foreach ($item in $vmConfirmedList) {
            if ($item.VmObj -and -not $item.VmDeleteConfirmed -and -not $DryRun) {
                Write-LogLine -RowNo $item.RowNo -Phase "RESOURCE" -HostPool $HostPoolName -VmRg $item.VmResourceGroup -VmName $item.VmName -SessionHost $item.SessionHostName -Action "DeleteAttachedResources" -Result "Skip" -Detail "VM削除未確認のため NIC/Disk 削除をスキップ"
                continue
            }

            foreach ($nicId in $item.NicIds) {
                $nicName = Get-LeafNameFromResourceId $nicId
                if (-not $nicName) { continue }

                if ($DryRun) {
                    Write-LogLine -RowNo $item.RowNo -Phase "RESOURCE" -HostPool $HostPoolName -VmRg $item.VmResourceGroup -VmName $item.VmName -SessionHost $item.SessionHostName -Action "DeleteNIC" -Result "DryRun" -Detail "$nicName 削除予定"
                    $summary.DryRunCount++
                }
                else {
                    try {
                        $nic = Get-AzNetworkInterface -ResourceGroupName $item.VmResourceGroup -Name $nicName -ErrorAction SilentlyContinue
                        if ($nic) {
                            Remove-AzNetworkInterface -ResourceGroupName $item.VmResourceGroup -Name $nicName -Force | Out-Null
                        }
                        Write-LogLine -RowNo $item.RowNo -Phase "RESOURCE" -HostPool $HostPoolName -VmRg $item.VmResourceGroup -VmName $item.VmName -SessionHost $item.SessionHostName -Action "DeleteNIC" -Result "Success" -Detail "$nicName 削除完了"
                        $summary.NicDeleteSuccess++
                    }
                    catch {
                        Write-LogLine -RowNo $item.RowNo -Phase "RESOURCE" -HostPool $HostPoolName -VmRg $item.VmResourceGroup -VmName $item.VmName -SessionHost $item.SessionHostName -Action "DeleteNIC" -Result "Error" -Detail $_.Exception.Message
                        $summary.NicDeleteError++
                    }
                }
            }

            foreach ($diskId in $item.DiskIds) {
                $diskName = Get-LeafNameFromResourceId $diskId
                if (-not $diskName) { continue }

                if ($DryRun) {
                    Write-LogLine -RowNo $item.RowNo -Phase "RESOURCE" -HostPool $HostPoolName -VmRg $item.VmResourceGroup -VmName $item.VmName -SessionHost $item.SessionHostName -Action "DeleteDisk" -Result "DryRun" -Detail "$diskName 削除予定"
                    $summary.DryRunCount++
                }
                else {
                    try {
                        $disk = Get-AzDisk -ResourceGroupName $item.VmResourceGroup -DiskName $diskName -ErrorAction SilentlyContinue
                        if ($disk) {
                            Remove-AzDisk -ResourceGroupName $item.VmResourceGroup -DiskName $diskName -Force | Out-Null
                        }
                        Write-LogLine -RowNo $item.RowNo -Phase "RESOURCE" -HostPool $HostPoolName -VmRg $item.VmResourceGroup -VmName $item.VmName -SessionHost $item.SessionHostName -Action "DeleteDisk" -Result "Success" -Detail "$diskName 削除完了"
                        $summary.DiskDeleteSuccess++
                    }
                    catch {
                        Write-LogLine -RowNo $item.RowNo -Phase "RESOURCE" -HostPool $HostPoolName -VmRg $item.VmResourceGroup -VmName $item.VmName -SessionHost $item.SessionHostName -Action "DeleteDisk" -Result "Error" -Detail $_.Exception.Message
                        $summary.DiskDeleteError++
                    }
                }
            }
        }

        # フェーズ7: 最終確認
        foreach ($item in $readyAfterSessionHostDelete) {
            if ($DryRun) {
                Write-LogLine -RowNo $item.RowNo -Phase "FINAL" -HostPool $HostPoolName -VmRg $item.VmResourceGroup -VmName $item.VmName -SessionHost $item.SessionHostName -Action "DeleteAll" -Result "DryRun" -Detail "変更なし"
                continue
            }

            $stillHost = Get-AzWvdSessionHost -ResourceGroupName $AvdResourceGroupName -HostPoolName $HostPoolName -ErrorAction SilentlyContinue | Where-Object {
                (Get-LeafNameFromResourceId $_.Name) -eq $item.SessionHostName
            }

            $stillVm = Get-AzVM -ResourceGroupName $item.VmResourceGroup -Name $item.VmName -ErrorAction SilentlyContinue

            $stillNicNames = @()
            foreach ($nid in $item.NicIds) {
                $nicName = Get-LeafNameFromResourceId $nid
                if (-not $nicName) { continue }
                $nic = Get-AzNetworkInterface -ResourceGroupName $item.VmResourceGroup -Name $nicName -ErrorAction SilentlyContinue
                if ($nic) { $stillNicNames += $nicName }
            }

            $stillDiskNames = @()
            foreach ($did in $item.DiskIds) {
                $diskName = Get-LeafNameFromResourceId $did
                if (-not $diskName) { continue }
                $disk = Get-AzDisk -ResourceGroupName $item.VmResourceGroup -DiskName $diskName -ErrorAction SilentlyContinue
                if ($disk) { $stillDiskNames += $diskName }
            }

            if ((-not $stillHost) -and (-not $stillVm) -and ($stillNicNames.Count -eq 0) -and ($stillDiskNames.Count -eq 0)) {
                Write-LogLine -RowNo $item.RowNo -Phase "FINAL" -HostPool $HostPoolName -VmRg $item.VmResourceGroup -VmName $item.VmName -SessionHost $item.SessionHostName -Action "DeleteAll" -Result "Success" -Detail "一連の削除処理完了"
                $summary.FinalCheckSuccess++
            }
            else {
                $detail = @()
                if ($stillHost)      { $detail += "SessionHost still exists" }
                if ($stillVm)        { $detail += "VM still exists" }
                if ($stillNicNames)  { $detail += ("NIC still exists: " + ($stillNicNames -join ",")) }
                if ($stillDiskNames) { $detail += ("Disk still exists: " + ($stillDiskNames -join ",")) }

                Write-LogLine -RowNo $item.RowNo -Phase "FINAL" -HostPool $HostPoolName -VmRg $item.VmResourceGroup -VmName $item.VmName -SessionHost $item.SessionHostName -Action "DeleteAll" -Result "Warning" -Detail ($detail -join "; ")
                $summary.FinalCheckWarning++
            }
        }
    }

    Add-Content -Path $logFilePath -Value "" -Encoding UTF8
    Add-Content -Path $logFilePath -Value "===== Summary =====" -Encoding UTF8

    Write-Host ""
    Write-Host "===== Summary ====="

    foreach ($key in $summary.Keys) {
        $line = "{0} = {1}" -f $key, $summary[$key]
        Add-Content -Path $logFilePath -Value $line -Encoding UTF8
        Write-Host $line
    }

    Write-Host ""
    Write-Host "完了: $logFilePath"
}
catch {
    Write-LogLine -Phase "SCRIPT" -Action "Error" -Result "Error" -Detail $_.Exception.Message
    throw
}
