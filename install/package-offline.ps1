param(
  [switch]$NoCache,
  [switch]$IncludeApps
)

$ErrorActionPreference = 'Stop'

$Version = '1.0'
$LocalImage = "dotob-lo-admin:$Version"
$OutDir = "install\\dist"

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

$buildArgs = @('build', '-t', $LocalImage, '-f', 'Dockerfile', '.')
if ($NoCache) {
  $buildArgs = @('build', '--no-cache', '-t', $LocalImage, '-f', 'Dockerfile', '.')
}

docker @buildArgs

$coreImages = @(
  $LocalImage,
  'tecnativa/docker-socket-proxy:v0.4.1',
  'nginx:1.27-alpine',
  'traefik:v3.1',
  'registry:2',
  'mysql:8.0',
  'redis:7-alpine',
  'amir20/dozzle:v10.0'
)

if ($IncludeApps) {
  $coreImages += @(
    'ghcr.io/kiwix/kiwix-serve:3.8.1',
    'qdrant/qdrant:v1.16',
    'ollama/ollama:0.15.2',
    'ghcr.io/gchq/cyberchef:10.19.4',
    'dullage/flatnotes:v5.5.4',
    'treehouses/kolibri:0.12.8'
  )
}

foreach ($img in $coreImages) {
  if ($img -eq $LocalImage) { continue }
  docker pull $img | Out-Null
}

$tarPath = Join-Path $OutDir "dotob-lo_offline_$Version.tar"
docker save -o $tarPath @coreImages

$hash = (Get-FileHash -Algorithm SHA256 $tarPath).Hash.ToLowerInvariant()
$shaPath = "$tarPath.sha256"
"$hash  $(Split-Path -Leaf $tarPath)" | Set-Content -Path $shaPath -NoNewline

Write-Output "Created: $tarPath"
Write-Output "Created: $shaPath"
