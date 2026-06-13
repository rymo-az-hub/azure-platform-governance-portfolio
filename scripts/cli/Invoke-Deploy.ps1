#Requires -Version 7.4

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $false)]
    [string]$Location = "japaneast",
    [Parameter(Mandatory = $false)]
    [string]$TemplateFile = ".\infra\main.bicep",
    [Parameter(Mandatory = $false)]
    [string]$ParameterFile = ".\infra\parameters\dev.bicepparam",
    [Parameter(Mandatory = $false)]
    [string]$DeploymentName = "apg-governance-baseline",
    [Parameter(Mandatory = $false)]
    [switch]$ConfirmDeploy
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [System.Text.UTF8Encoding]::new($false)

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
Set-Location $repoRoot

if (-not (Test-Path $TemplateFile)) {
    throw "Template file not found: $TemplateFile"
}

if (-not (Test-Path $ParameterFile)) {
    throw "Parameter file not found: $ParameterFile"
}

Write-Host "Deployment target"
Write-Host "Deployment: $DeploymentName"
Write-Host "Template  : $TemplateFile"
Write-Host "Parameter : $ParameterFile"
Write-Host "Location  : $Location"
Write-Host ""

if (-not $ConfirmDeploy) {
    Write-Host "Deployment was not executed."
    Write-Host "Run what-if first and review the planned changes before deployment."
    Write-Host ""
    Write-Host "What-if example:"
    Write-Host ".\scripts\cli\Invoke-WhatIf.ps1 -Location `"$Location`" -TemplateFile `"$TemplateFile`" -ParameterFile `"$ParameterFile`""
    Write-Host ""
    Write-Host "After confirming the what-if result, rerun this script with -ConfirmDeploy to execute az deployment sub create."
    return
}

if ($PSCmdlet.ShouldProcess("subscription deployment '$DeploymentName'", "az deployment sub create")) {
    az deployment sub create `
        --name $DeploymentName `
        --location $Location `
        --template-file $TemplateFile `
        --parameters $ParameterFile
}
