$packageArgs = @{
    packageName    = 'mscoreutils'
    fileType       = 'exe'

    url64bit       = 'https://github.com/microsoft/coreutils/releases/download/v2026.6.16/coreutils-2026.6.16-x64.exe'

    checksum64     = 'F862B1AA433310420AE20F9B1384F3F974A26BA98AE37AC548061116A3EF6C62'
    checksumType64 = 'sha256'

    silentArgs     = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-'
}

Install-ChocolateyPackage @packageArgs