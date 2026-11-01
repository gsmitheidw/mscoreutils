$ErrorActionPreference = 'Stop'

$packageArgs = @{
    packageName    = 'mscoreutils'
    fileType       = 'exe'

    url64bit       = 'https://github.com/microsoft/coreutils/releases/download/v2026.9.3/coreutils-2026.9.3-x64.exe'

    checksum64     = '5600CAF3EA219274FEB3E8F8B626A80263EB5C41D531E36A0ACBC72CC670A229'
    checksumType64 = 'sha256'

    silentArgs     = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-'
}

Install-ChocolateyPackage @packageArgs
