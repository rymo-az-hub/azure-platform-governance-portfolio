#Requires -Version 7.4

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$InputCsv = ".\scripts\avd\samples\avd-inventory-targets.sample.csv",

    [Parameter(Mandatory = $false)]
    [string]$OutputCsv = ".\scripts\avd\output\avd-hostpool-inventory.csv"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [System.Text.UTF8Encoding]::new($false)

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
Set-Location $repoRoot

if (-not (Test-Path $InputCsv)) {
    throw "Input CSV not found: $InputCsv"
}

$outputDir = Split-Path $OutputCsv -Parent
if ($outputDir -and -not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir | Out-Null
}

$targets = Import-Csv -Path $InputCsv
$results = New-Object System.Collections.Generic.List[object]

foreach ($target in $targets) {
    $hostPoolResourceGroup = $target.HostPoolResourceGroup
    $hostPoolName = $target.HostPoolName

    if ([string]::IsNullOrWhiteSpace($hostPoolResourceGroup) -or [string]::IsNullOrWhiteSpace($hostPoolName)) {
        $results.Add([pscustomobject]@{
            HostPoolResourceGroup = $hostPoolResourceGroup
            HostPoolName = $hostPoolName
            SessionHostName = $null
            AssignedUser = $null
            AllowNewSession = $null
            Status = "Skipped"
            Reason = "MissingHostPoolInput"
        })
        continue
    }

    Write-Host "Collecting session hosts: $hostPoolResourceGroup / $hostPoolName"

    try {
        $sessionHosts = az desktopvirtualization session-host list `
            --resource-group $hostPoolResourceGroup `
            --host-pool-name $hostPoolName `
            --output json | ConvertFrom-Json
    }
    catch {
        $results.Add([pscustomobject]@{
            HostPoolResourceGroup = $hostPoolResourceGroup
            HostPoolName = $hostPoolName
            SessionHostName = $null
            AssignedUser = $null
            AllowNewSession = $null
            Status = "Failed"
            Reason = "SessionHostListFailed"
        })
        continue
    }

    if (-not $sessionHosts) {
        $results.Add([pscustomobject]@{
            HostPoolResourceGroup = $hostPoolResourceGroup
            HostPoolName = $hostPoolName
            SessionHostName = $null
            AssignedUser = $null
            AllowNewSession = $null
            Status = "Skipped"
            Reason = "NoSessionHostsFound"
        })
        continue
    }

    foreach ($sessionHost in $sessionHosts) {
        $results.Add([pscustomobject]@{
            HostPoolResourceGroup = $hostPoolResourceGroup
            HostPoolName = $hostPoolName
            SessionHostName = $sessionHost.name
            AssignedUser = $sessionHost.assignedUser
            AllowNewSession = $sessionHost.allowNewSession
            Status = $sessionHost.status
            Reason = "Collected"
        })
    }
}

$results | Export-Csv -Path $OutputCsv -NoTypeInformation -Encoding utf8

Write-Host "Inventory output: $OutputCsv"
