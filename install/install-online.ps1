param(
  [string]$Url = "http://localhost:8080",
  [string]$AppKey,
  [string]$DbPassword = "change-me-db",
  [string]$MysqlRootPassword = "change-me-root",
  [string]$DataDir = "/opt/dotob-lo",
  [string]$Compose = "compose.dotob-lo.prod.online.yaml",
  [string]$ProjectName = "dotob-lo"
)
$ErrorActionPreference = "Stop"
if (-not $AppKey -or $AppKey.Trim().Length -lt 16) {
  $AppKey = -join ((33..126) | Get-Random -Count 24 | ForEach-Object {[char]$_})
}
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not [System.IO.Path]::IsPathRooted($Compose)) {
  $composeSrc = Join-Path $scriptRoot $Compose
} else {
  $composeSrc = $Compose
}
New-Item -ItemType Directory -Force -Path $DataDir | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $DataDir "storage") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $DataDir "mysql") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $DataDir "redis") | Out-Null
$composeDest = Join-Path $DataDir "compose.yml"
Copy-Item -Force -Path $composeSrc -Destination $composeDest
$content = Get-Content -Raw -Path $composeDest
$content = $content -replace 'URL=http://SERVER_IP_OR_DOMAIN:8080', ("URL={0}" -f $Url)
$content = $content -replace 'APP_KEY=REPLACE_ME_>=16CHARS', ("APP_KEY={0}" -f $AppKey)
$content = $content -replace 'DB_PASSWORD=REPLACE_ME', ("DB_PASSWORD={0}" -f $DbPassword)
$content = $content -replace 'MYSQL_ROOT_PASSWORD=REPLACE_ME', ("MYSQL_ROOT_PASSWORD={0}" -f $MysqlRootPassword)
Set-Content -Path $composeDest -Value $content -Encoding UTF8
docker compose -p $ProjectName -f $composeDest up -d
Write-Output "OK"
