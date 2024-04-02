<#
.SYNOPSIS
Retrieves Alpaca API configuration information including API key and API secret from a JSON file.

.DESCRIPTION
The Get-AlpacaApiConfiguration cmdlet retrieves Alpaca API configuration information from a JSON file and ensures that the required credentials are available.

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

    # Attempt to read credentials from the credentials file
    if (Test-Path $CredentialsPath) {
        $Credentials = Get-Content -Path $CredentialsPath -Raw | ConvertFrom-Json
        $ApiKey = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($Credentials.ApiKey))
        $ApiSecret = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($Credentials.ApiSecret))
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
