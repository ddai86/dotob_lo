param(
  [string]$BundleTar = "install\\dist\\dotob-lo_offline_1.0.tar",
  [string]$ServerHost,
  [string]$DataDir = "/opt/dotob-lo",
  [string]$ProjectName = "dotob-lo",
  [string]$Compose = "compose.dotob-lo.prod.offline.yaml"
)

$ErrorActionPreference = "Stop"

function Get-LanIPv4() {
  try {
    $candidates = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction Stop |
      Where-Object { $_.IPAddress -and $_.IPAddress -ne '127.0.0.1' -and $_.PrefixOrigin -ne 'WellKnown' } |
      Sort-Object -Property InterfaceMetric, SkipAsSource
    $best = $candidates | Select-Object -First 1
    if ($best -and $best.IPAddress) { return $best.IPAddress }
  } catch {}
  return $null
}

if (-not $ServerHost -or $ServerHost.Trim() -eq "") {
  $ip = Get-LanIPv4
  if ($ip) { $ServerHost = $ip } else { $ServerHost = "localhost" }
}

$url = "http://$ServerHost:8080"
$gatewayUrl = "http://$ServerHost:8081"

if (-not (Test-Path $BundleTar)) {
  throw "Bundle tar not found: $BundleTar"
}

docker load -i $BundleTar | Out-Null

$appKey = [Guid]::NewGuid().ToString('N')
$dbPassword = [Guid]::NewGuid().ToString('N')
$mysqlRootPassword = [Guid]::NewGuid().ToString('N')

$installRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$composeSrc = Join-Path $installRoot $Compose

if (-not (Test-Path $composeSrc)) {
  throw "Compose not found: $composeSrc"
}

New-Item -ItemType Directory -Force -Path $DataDir | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $DataDir "storage") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $DataDir "mysql") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $DataDir "redis") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $DataDir "registry") | Out-Null

$composeDest = Join-Path $DataDir "compose.yml"
Copy-Item -Force -Path $composeSrc -Destination $composeDest

$content = Get-Content -Raw -Path $composeDest
$content = $content.Replace('URL=http://SERVER_IP_OR_DOMAIN:8080', ("URL={0}" -f $url))
$content = $content.Replace('DOTOB_APPS_GATEWAY_URL=http://SERVER_IP_OR_DOMAIN:8081', ("DOTOB_APPS_GATEWAY_URL={0}" -f $gatewayUrl))
$content = $content.Replace('APP_KEY=REPLACE_ME_>=16CHARS', ("APP_KEY={0}" -f $appKey))
$content = $content.Replace('DB_PASSWORD=REPLACE_ME', ("DB_PASSWORD={0}" -f $dbPassword))
$content = $content.Replace('MYSQL_ROOT_PASSWORD=REPLACE_ME', ("MYSQL_ROOT_PASSWORD={0}" -f $mysqlRootPassword))
$content = $content.Replace('MYSQL_PASSWORD=REPLACE_ME', ("MYSQL_PASSWORD={0}" -f $dbPassword))
Set-Content -Path $composeDest -Value $content -Encoding UTF8

docker compose -p $ProjectName -f $composeDest up -d

Write-Output "OK"
Write-Output "Admin: $url"
Write-Output "Gateway: $gatewayUrl"
Write-Output "DataDir: $DataDir"

