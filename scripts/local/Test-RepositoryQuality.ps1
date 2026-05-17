#Requires -Version 7.4

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [System.Text.UTF8Encoding]::new($false)

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
Set-Location $repoRoot

Write-Host "Repository root: $repoRoot"
Write-Host ""

Write-Host "[1/5] Git status"
$gitStatus = git status --short
if ($gitStatus) {
    Write-Host $gitStatus
    throw "Working tree is not clean. Commit, stash, or discard local changes before quality check."
}
Write-Host "OK: working tree clean"
Write-Host ""

Write-Host "[2/5] Required file check"
$requiredFiles = @(
    "README.md",
    "docs/00_overview/README.md",
    "docs/00_overview/architecture_overview.md",
    "docs/00_overview/design_principles.md",
    "docs/01_main_azure_governance_baseline/requirements.md",
    "docs/01_main_azure_governance_baseline/governance_design.md",
    "docs/01_main_azure_governance_baseline/policy_baseline.md",
    "docs/02_sub_avd_operations_standardization/avd_ops_design.md",
    "docs/02_sub_avd_operations_standardization/operation_checklist.md",
    "docs/03_adr/adr-001-landing-zone-lite-scope.md",
    "docs/04_evidence/06-validation-summary.md",
    "infra/main.bicep",
    "infra/parameters/dev.bicepparam",
    "scripts/cli/Invoke-WhatIf.ps1",
    "scripts/cli/Invoke-Deploy.ps1",
    "scripts/avd/Export-AvdHostPoolInventory.ps1",
    "scripts/avd/Remove-AvdSessionHostResources.ps1",
    "scripts/avd/Set-AvdPersonalDesktopAssignment.ps1",
    "scripts/avd/Start-AzVmFromCsv.ps1"
)

foreach ($file in $requiredFiles) {
    if (-not (Test-Path $file)) {
        throw "Required file not found: $file"
    }
    Write-Host "OK: $file"
}
Write-Host ""

Write-Host "[3/5] Bicep build"
az bicep build --file .\infra\main.bicep
if (Test-Path ".\infra\main.json") {
    Remove-Item ".\infra\main.json" -Force
    Write-Host "Removed generated file: infra/main.json"
}
Write-Host "OK: Bicep build"
Write-Host ""

Write-Host "[4/5] PowerShell syntax check"
$scriptFiles = @()
$scriptFiles += Get-ChildItem -Path ".\scripts\cli" -Filter "*.ps1" -File
$scriptFiles += Get-ChildItem -Path ".\scripts\avd" -Filter "*.ps1" -File
$scriptFiles += Get-ChildItem -Path ".\scripts\local" -Filter "*.ps1" -File

foreach ($script in $scriptFiles) {
    $tokens = $null
    $errors = $null

    [System.Management.Automation.Language.Parser]::ParseFile(
        $script.FullName,
        [ref]$tokens,
        [ref]$errors
    ) | Out-Null

    if ($errors.Count -gt 0) {
        Write-Host "Syntax error: $($script.FullName)" -ForegroundColor Red
        $errors | Format-List
        throw "PowerShell syntax check failed."
    }

    Write-Host "OK: $($script.FullName.Replace($repoRoot + [System.IO.Path]::DirectorySeparatorChar, ''))"
}
Write-Host ""

Write-Host "[5/5] Git status after checks"
$gitStatusAfter = git status --short
if ($gitStatusAfter) {
    Write-Host $gitStatusAfter
    throw "Working tree changed during quality check. Review generated files or cleanup rules."
}
Write-Host "OK: no generated files remain"
Write-Host ""

Write-Host "Repository quality check completed successfully."
