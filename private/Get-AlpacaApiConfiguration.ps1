function Get-AlpacaApiConfiguration {
    [CmdletBinding()]
    Param ()

    $AlpacaUserCredential = $env:ALPACA_USER_CREDENTIAL
    $ApiKey = $env:ALPACA_API_KEY
    $ApiSecret = $env:ALPACA_API_SECRET
    $Username = $null
    $Password = $null

    if (-not $ApiKey -or -not $ApiSecret -or -not $AlpacaUserCredential) {
        $CredentialsPath = if ([Environment]::OSVersion.Platform -eq [PlatformID]::Win32NT) {
            Join-Path $env:USERPROFILE ".alpaca-credentials"
        } else {
            Join-Path $HOME ".alpaca-credentials"
        }

        if (Test-Path $CredentialsPath) {
            $Credentials = Get-Content -Path $CredentialsPath | ConvertFrom-Json
            $ApiKey = $Credentials.ApiKey
            $ApiSecret = $Credentials.ApiSecret
            if ($Credentials.Username -and $Credentials.EncodedPassword) {
                $Username = $Credentials.Username
                $EncodedPassword = $Credentials.EncodedPassword
                $PasswordBytes = [Convert]::FromBase64String($EncodedPassword)
                $Password = [Text.Encoding]::UTF8.GetString($PasswordBytes)
            }
        }
    }

    if (-not $ApiKey -or -not $ApiSecret) {
        Write-Error "No Alpaca API configuration found. Use Set-AlpacaApiConfiguration."
        return $null
    }

    $BrokerCredential = $null
    if ($Username -and $Password) {
        $SecurePassword = $Password | ConvertTo-SecureString -AsPlainText -Force
        $BrokerCredential = New-Object System.Management.Automation.PSCredential ($Username, $SecurePassword)
    }

    return @{
        ApiKey = $ApiKey
        ApiSecret = $ApiSecret
        BrokerCredential = $BrokerCredential
    }
}
