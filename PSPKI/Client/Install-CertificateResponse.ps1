function Install-CertificateResponse {
<#
.ExternalHelp PSPKI.Help.xml
#>
[CmdletBinding(DefaultParameterSetName = '__file')]
    param(
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelinebyPropertyName = $true,
            ParameterSetName = '__file')]
        [System.IO.FileInfo]$Path,
        [Parameter(Mandatory = $true, ParameterSetName = '__cert')]
        [System.Security.Cryptography.X509Certificates.X509Certificate2]$Certificate,
        [string]$Password = [string]::Empty,
        [SysadminsLV.PKI.Enrollment.InstallResponseFlags]$InstallOptions,
        [switch]$MachineContext
    )

    $b64Response
    switch ($PsCmdlet.ParameterSetName) {
        '__cert' {$b64Response = [convert]::ToBase64String($Certificate.RawData)}
        '__file' {$b64Response = [convert]::ToBase64String([SysadminsLV.PKI.CryptBinaryConverter]::CryptFileToBinary($Path.FullName))}
    }

    $enroll = New-Object -ComObject X509Enrollment.CX509Enrollment
    # initialize store context. Default is CurrentUser.
    if ($MachineContext) {
        $enroll.Initialize(2)
    } else {
        $enroll.Initialize(1)
    }
    $enroll.InstallResponse($InstallOptions, $b64Response, 0x1, $Password)

    Release-COM $enroll
}