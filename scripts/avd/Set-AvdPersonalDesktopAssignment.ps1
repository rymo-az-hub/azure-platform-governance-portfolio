#Requires -Version 7.4

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$InputCsv = ".\scripts\avd\samples\personal-desktop-assignment.sample.csv",

    [Parameter(Mandatory = $false)]
    [string]$OutputCsv = ".\scripts\avd\output\personal-desktop-assignment-result.csv",

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
    $userPrincipalName = $target.UserPrincipalName

    $result = [ordered]@{
        HostPoolResourceGroup = $hostPoolResourceGroup
        HostPoolName = $hostPoolName
        SessionHostName = $sessionHostName
        UserPrincipalName = $userPrincipalName
        Mode = if ($Execute) { "Execute" } else { "DryRun" }
        CurrentAssignedUser = ""
        Result = "Pending"
        Reason = ""
    }

    if ([string]::IsNullOrWhiteSpace($hostPoolResourceGroup) -or
        [string]::IsNullOrWhiteSpace($hostPoolName) -or
        [string]::IsNullOrWhiteSpace($sessionHostName) -or
        [string]::IsNullOrWhiteSpace($userPrincipalName)) {
        $result.Result = "Skipped"
        $result.Reason = "MissingAssignmentInput"
        $results.Add([pscustomobject]$result)
        continue
    }

    Write-Host "Checking assignment target: $sessionHostName -> $userPrincipalName"

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

    $result.CurrentAssignedUser = $sessionHost.assignedUser

    if (-not [string]::IsNullOrWhiteSpace($sessionHost.assignedUser) -and $sessionHost.assignedUser -ne $userPrincipalName) {
        $result.Result = "Skipped"
        $result.Reason = "AlreadyAssignedToAnotherUser"
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
        az desktopvirtualization session-host update `
            --resource-group $hostPoolResourceGroup `
            --host-pool-name $hostPoolName `
            --name $sessionHostName `
            --assigned-user $userPrincipalName | Out-Null

        $result.Result = "Success"
        $result.Reason = "Assigned"
    }
    catch {
        $result.Result = "Failed"
        $result.Reason = "AssignmentFailed"
    }

    $results.Add([pscustomobject]$result)
}

$results | Export-Csv -Path $OutputCsv -NoTypeInformation -Encoding utf8

Write-Host "Result output: $OutputCsv"
Write-Host "Mode: $(if ($Execute) { 'Execute' } else { 'DryRun' })"
