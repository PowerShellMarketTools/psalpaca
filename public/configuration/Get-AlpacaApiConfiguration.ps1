<#
.SYNOPSIS
Retrieves Alpaca API configuration information including API key, API secret, and broker credentials.

.DESCRIPTION
The Get-AlpacaApiConfiguration cmdlet is used to retrieve Alpaca API configuration information necessary for accessing the Alpaca trading platform. This cmdlet reads API credentials from a JSON file stored in the user's home directory. It ensures that the required credentials are available and provides them as output.

.PARAMETER None
This cmdlet does not accept any parameters.

.EXAMPLE
Get-AlpacaApiConfiguration

This example retrieves Alpaca API configuration information from the default credentials file location and displays it on the console.

#>

Function Get-AlpacaApiConfiguration {
    [CmdletBinding()]
    Param ()

    # Initialize variables to null
    $ApiKey = $null
    $ApiSecret = $null

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
    }
}
