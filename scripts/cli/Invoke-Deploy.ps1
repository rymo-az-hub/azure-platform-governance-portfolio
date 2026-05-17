#Requires -Version 7.4

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$Location = "japaneast",
    [Parameter(Mandatory = $false)]
    [string]$TemplateFile = ".\infra\main.bicep",
    [Parameter(Mandatory = $false)]
    [string]$ParameterFile = ".\infra\parameters\dev.bicepparam",
    [Parameter(Mandatory = $false)]
    [string]$DeploymentName = "apg-governance-baseline"
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

Write-Host "Starting deployment..."
Write-Host "Deployment: $DeploymentName"
Write-Host "Template  : $TemplateFile"
Write-Host "Parameter : $ParameterFile"
Write-Host "Location  : $Location"
Write-Host ""

az deployment sub create `
    --name $DeploymentName `
    --location $Location `
    --template-file $TemplateFile `
    --parameters $ParameterFile
