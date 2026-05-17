#Requires -Version 7.4

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$InputCsv = ".\scripts\avd\samples\remove-avd-sessionhost-targets.sample.csv",

    [Parameter(Mandatory = $false)]
    [string]$OutputCsv = ".\scripts\avd\output\remove-avd-sessionhost-result.csv",

    [Parameter(Mandatory = $false)]
    [switch]$Execute
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
    $sessionHostName = $target.SessionHostName
    $vmResourceGroup = $target.VmResourceGroup
    $vmName = $target.VmName

    $result = [ordered]@{
        HostPoolResourceGroup = $hostPoolResourceGroup
        HostPoolName = $hostPoolName
        SessionHostName = $sessionHostName
        VmResourceGroup = $vmResourceGroup
        VmName = $vmName
        Mode = if ($Execute) { "Execute" } else { "DryRun" }
        Result = "Pending"
        Reason = ""
    }

    if ([string]::IsNullOrWhiteSpace($hostPoolResourceGroup) -or
        [string]::IsNullOrWhiteSpace($hostPoolName) -or
        [string]::IsNullOrWhiteSpace($sessionHostName)) {
        $result.Result = "Skipped"
        $result.Reason = "MissingSessionHostInput"
        $results.Add([pscustomobject]$result)
        continue
    }

    Write-Host "Checking target: $sessionHostName"

    try {
        $sessionHost = az desktopvirtualization session-host show `
            --resource-group $hostPoolResourceGroup `
            --host-pool-name $hostPoolName `
            --name $sessionHostName `
            --output json | ConvertFrom-Json
    }
    catch {
        $result.Result = "Skipped"
        $result.Reason = "SessionHostNotFound"
        $results.Add([pscustomobject]$result)
        continue
    }

    try {
        $userSessions = az desktopvirtualization user-session list `
            --resource-group $hostPoolResourceGroup `
            --host-pool-name $hostPoolName `
            --session-host-name $sessionHostName `
            --output json | ConvertFrom-Json
    }
    catch {
        $userSessions = @()
    }

    if ($userSessions -and $userSessions.Count -gt 0) {
        $result.Result = "Skipped"
        $result.Reason = "ActiveOrDisconnectedSessionExists"
        $results.Add([pscustomobject]$result)
        continue
    }

    if (-not $Execute) {
        $result.Result = "Skipped"
        $result.Reason = "DryRunOnly"
        $results.Add([pscustomobject]$result)
        continue
    }

    try {
        az desktopvirtualization session-host delete `
            --resource-group $hostPoolResourceGroup `
            --host-pool-name $hostPoolName `
            --name $sessionHostName `
            --yes | Out-Null

        if (-not [string]::IsNullOrWhiteSpace($vmResourceGroup) -and -not [string]::IsNullOrWhiteSpace($vmName)) {
            az vm delete `
                --resource-group $vmResourceGroup `
                --name $vmName `
                --yes | Out-Null
        }

        $result.Result = "Success"
        $result.Reason = "Deleted"
    }
    catch {
        $result.Result = "Failed"
        $result.Reason = "DeleteFailed"
    }

    $results.Add([pscustomobject]$result)
}

$results | Export-Csv -Path $OutputCsv -NoTypeInformation -Encoding utf8

Write-Host "Result output: $OutputCsv"
Write-Host "Mode: $(if ($Execute) { 'Execute' } else { 'DryRun' })"
