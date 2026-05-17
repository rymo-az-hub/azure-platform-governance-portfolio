#Requires -Version 7.4

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$InputCsv = ".\scripts\avd\samples\start-vm-targets.sample.csv",

    [Parameter(Mandatory = $false)]
    [string]$OutputCsv = ".\scripts\avd\output\start-vm-result.csv",

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
    $resourceGroupName = $target.ResourceGroupName
    $vmName = $target.VmName

    $result = [ordered]@{
        ResourceGroupName = $resourceGroupName
        VmName = $vmName
        Mode = if ($Execute) { "Execute" } else { "DryRun" }
        PowerStateBefore = ""
        PowerStateAfter = ""
        Result = "Pending"
        Reason = ""
    }

    if ([string]::IsNullOrWhiteSpace($resourceGroupName) -or [string]::IsNullOrWhiteSpace($vmName)) {
        $result.Result = "Skipped"
        $result.Reason = "MissingVmInput"
        $results.Add([pscustomobject]$result)
        continue
    }

    Write-Host "Checking VM: $resourceGroupName / $vmName"

    try {
        $vmStatus = az vm get-instance-view `
            --resource-group $resourceGroupName `
            --name $vmName `
            --query "instanceView.statuses[?starts_with(code, 'PowerState/')].displayStatus | [0]" `
            --output tsv
    }
    catch {
        $result.Result = "Skipped"
        $result.Reason = "VmNotFoundOrStatusFailed"
        $results.Add([pscustomobject]$result)
        continue
    }

    $result.PowerStateBefore = $vmStatus

    if ($vmStatus -eq "VM running") {
        $result.PowerStateAfter = $vmStatus
        $result.Result = "Skipped"
        $result.Reason = "AlreadyRunning"
        $results.Add([pscustomobject]$result)
        continue
    }

    if (-not $Execute) {
        $result.PowerStateAfter = $vmStatus
        $result.Result = "Skipped"
        $result.Reason = "DryRunOnly"
        $results.Add([pscustomobject]$result)
        continue
    }

    try {
        az vm start `
            --resource-group $resourceGroupName `
            --name $vmName | Out-Null

        $vmStatusAfter = az vm get-instance-view `
            --resource-group $resourceGroupName `
            --name $vmName `
            --query "instanceView.statuses[?starts_with(code, 'PowerState/')].displayStatus | [0]" `
            --output tsv

        $result.PowerStateAfter = $vmStatusAfter
        $result.Result = "Success"
        $result.Reason = "Started"
    }
    catch {
        $result.Result = "Failed"
        $result.Reason = "StartFailed"
    }

    $results.Add([pscustomobject]$result)
}

$results | Export-Csv -Path $OutputCsv -NoTypeInformation -Encoding utf8

Write-Host "Result output: $OutputCsv"
Write-Host "Mode: $(if ($Execute) { 'Execute' } else { 'DryRun' })"
