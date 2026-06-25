Import-Module powershell-yaml

$repo = "microsoft/coreutils"
$packageId = "mscoreutils"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$tools = Join-Path $root "tools"
$nuspecPath = Join-Path $root "mscoreutils.nuspec"
$installPath = Join-Path $tools "chocolateyinstall.ps1"

Write-Host "Root: $root"
Write-Host "Fetching latest release..."

$release = Invoke-RestMethod "https://api.github.com/repos/$repo/releases/latest"

if (-not $release.tag_name) {
    throw "No release tag returned"
}

$version = $release.tag_name.TrimStart("v")

[xml]$nuspec = Get-Content $nuspecPath

$lastVersion = $nuspec.package.metadata.version.Trim()

Write-Host "Current package version: $lastVersion"
Write-Host "Latest release version: $version"

if ($version -eq $lastVersion) {
    Write-Host "No new version"
    Add-Content $env:GITHUB_OUTPUT "updated=false"
    exit 0
}

Write-Host "Updating to $version"

$manifestUrl =
"https://raw.githubusercontent.com/microsoft/winget-pkgs/master/manifests/m/Microsoft/Coreutils/$version/Microsoft.Coreutils.installer.yaml"

Write-Host "Fetching winget manifest..."

$yaml = Invoke-WebRequest $manifestUrl -ErrorAction Stop
$manifest = ConvertFrom-Yaml $yaml.Content

$x64 = $manifest.Installers |
    Where-Object Architecture -eq "x64" |
    Select-Object -First 1

if (-not $x64) {
    throw "x64 installer not found"
}

$url = $x64.InstallerUrl
$sha = $x64.InstallerSha256

Write-Host "URL: $url"
Write-Host "SHA: $sha"

$installScript = @"
`$packageArgs = @{
    packageName    = '$packageId'
    fileType       = 'exe'

    url64bit       = '$url'

    checksum64     = '$sha'
    checksumType64 = 'sha256'

    silentArgs     = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-'
}

Install-ChocolateyPackage @packageArgs
"@

$utf8 = New-Object System.Text.UTF8Encoding($false)

if (-not (Test-Path $tools)) {
    New-Item -ItemType Directory -Path $tools | Out-Null
}

[System.IO.File]::WriteAllText(
    $installPath,
    ($installScript -replace "`r", ""),
    $utf8
)

Write-Host "Updated chocolateyinstall.ps1"

$node = $nuspec.SelectSingleNode("//metadata/version")

if (-not $node) {
    throw "nuspec version node not found"
}

$node.InnerText = $version

$temp = Join-Path $root "tmp.xml"

$nuspec.Save($temp)

$content = Get-Content $temp -Raw

[System.IO.File]::WriteAllText(
    $nuspecPath,
    ($content -replace "`r", ""),
    $utf8
)

Remove-Item $temp -Force -ErrorAction SilentlyContinue

Invoke-WebRequest `
    "https://raw.githubusercontent.com/microsoft/coreutils/main/LICENSE" |
    Set-Content "$tools\LICENSE.txt" -Encoding UTF8

Add-Content $env:GITHUB_OUTPUT "updated=true"

Write-Host "DONE"

