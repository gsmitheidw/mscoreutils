Import-Module powershell-yaml

$repo = "microsoft/coreutils"
$packageId = "mscoreutils"

# ALWAYS anchor paths to script location
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$tools = Join-Path $root "tools"
$nuspecPath = Join-Path $root "mscoreutils.nuspec"
$installPath = Join-Path $tools "chocolateyinstall.ps1"

Write-Host "Root: $root"

Write-Host "Fetching latest release..."

$release = Invoke-RestMethod "https://api.github.com/repos/$repo/releases/latest"

$version = $release.tag_name.TrimStart("v")

Write-Host "Version: $version"

$manifestUrl =
"https://raw.githubusercontent.com/microsoft/winget-pkgs/master/manifests/m/Microsoft/Coreutils/$version/Microsoft.Coreutils.installer.yaml"

Write-Host "Fetching winget manifest..."

$yaml = Invoke-WebRequest $manifestUrl -ErrorAction Stop
$manifest = ConvertFrom-Yaml $yaml.Content

$x64 = $manifest.Installers | Where-Object Architecture -eq "x64"

if (-not $x64) {
    throw "x64 installer not found"
}

$url = $x64.InstallerUrl
$sha = $x64.InstallerSha256

Write-Host "URL: $url"
Write-Host "SHA: $sha"

# ----------------------------
# install script
# ----------------------------

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

$installScript = $installScript -replace "`r",""

# ENSURE tools folder exists
if (-not (Test-Path $tools)) {
    New-Item -ItemType Directory -Path $tools | Out-Null
}

[System.IO.File]::WriteAllText(
    $installPath,
    $installScript,
    $utf8
)

Write-Host "Updated chocolateyinstall.ps1"

# nuspec update
# -------------

[xml]$nuspec = Get-Content $nuspecPath

$node = $nuspec.SelectSingleNode("//metadata/version")

if (-not $node) {
    throw "nuspec version node not found"
}

$node.InnerText = $version

$temp = Join-Path $root "tmp.xml"
$nuspec.Save($temp)

$content = Get-Content $temp -Raw
$content = $content -replace "`r",""

[System.IO.File]::WriteAllText(
    $nuspecPath,
    $content,
    $utf8
)

Remove-Item $temp -Force -ErrorAction SilentlyContinue

Write-Host "Updated nuspec version"
Write-Host "DONE"

# Include MIT Licence
Invoke-WebRequest `
  "https://raw.githubusercontent.com/microsoft/coreutils/main/LICENSE" |
  Set-Content "tools\LICENSE.txt" -Encoding UTF8
