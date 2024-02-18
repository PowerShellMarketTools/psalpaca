function Get-AlpacaApiConfiguration {
    [CmdletBinding()]
    Param ()

    # Initialize variables to null
    $ApiKey = $null
    $ApiSecret = $null
    $BrokerCredentialEncoded = $null

    # Determine the credentials path based on the OS platform using a switch statement
    $CredentialsPath = switch ([Environment]::OSVersion.Platform) {
        [PlatformID]::Win32NT { Join-Path $env:USERPROFILE ".alpaca-credentials" }
        default { Join-Path $HOME ".alpaca-credentials" }
    }

    # Attempt to read credentials from the environment variables or the credentials file
    if (Test-Path $CredentialsPath) {
        $Credentials = Get-Content -Path $CredentialsPath | ConvertFrom-Json
        $ApiKey = $Credentials.api_key
        $ApiSecret = $Credentials.api_secret

        if ($Credentials.broker_credential) {
            $username = $Credentials.broker_credential.username
            $password = $Credentials.broker_credential.password
            $BrokerCredentialEncoded = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("$($username):$($password)"))
        }
    }

    # Validate if necessary credentials are available
    if ($null -eq $ApiKey -or $null -eq $ApiSecret) {
        Write-Error "No Alpaca API key and secret found. Use Set-AlpacaApiConfiguration."
        return $null
    }

    # Return the configuration as a custom object
    return @{
        ApiKey = $ApiKey
        ApiSecret = $ApiSecret
        BrokerCredentialEncoded = $BrokerCredentialEncoded
    }
}
