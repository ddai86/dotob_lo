param(
  [string]$PublicHost,
  [string]$DataDir = "/opt/dotob-lo",
  [string]$ProjectName = "dotob-lo",
  [string]$Compose = "compose.dotob-lo.prod.public.ip.yaml"
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

if (-not $PublicHost -or $PublicHost.Trim() -eq "") {
  $lanIp = Get-LanIPv4
  if ($lanIp) { $PublicHost = $lanIp } else { $PublicHost = "localhost" }
}

$publicUrl = "http://$PublicHost"

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
$content = $content.Replace('DOTOB_PUBLIC_URL=http://SERVER_IP_OR_DOMAIN', ("DOTOB_PUBLIC_URL={0}" -f $publicUrl))
$content = $content.Replace('URL=${DOTOB_PUBLIC_URL:-http://SERVER_IP_OR_DOMAIN}', ("URL={0}" -f $publicUrl))
$content = $content.Replace('DOTOB_APPS_GATEWAY_URL=${DOTOB_PUBLIC_URL:-http://SERVER_IP_OR_DOMAIN}', ("DOTOB_APPS_GATEWAY_URL={0}" -f $publicUrl))
$content = $content.Replace('APP_KEY=${APP_KEY}', ("APP_KEY={0}" -f $appKey))
$content = $content.Replace('DB_PASSWORD=${DB_PASSWORD}', ("DB_PASSWORD={0}" -f $dbPassword))
$content = $content.Replace('MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}', ("MYSQL_ROOT_PASSWORD={0}" -f $mysqlRootPassword))
Set-Content -Path $composeDest -Value $content -Encoding UTF8

docker compose -p $ProjectName -f $composeDest up -d

Write-Output "OK"
Write-Output "URL: $publicUrl"
Write-Output "DATA_DIR: $DataDir"

