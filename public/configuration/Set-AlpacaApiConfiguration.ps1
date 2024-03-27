<#
.SYNOPSIS
Sets the Alpaca API configuration by providing the API key, API secret, and optional broker credentials.

.DESCRIPTION
The Set-AlpacaApiConfiguration cmdlet is used to set the Alpaca API configuration by providing the API key and API secret required for accessing the Alpaca trading platform. Optionally, broker credentials can also be provided. If the SaveProfile switch is specified, the provided credentials are stored in a JSON file in the user's home directory for future use.

.PARAMETER ApiKey
Specifies the Alpaca API key. This parameter is mandatory.

.PARAMETER ApiSecret
Specifies the Alpaca API secret. This parameter is mandatory.

.PARAMETER SaveProfile
Indicates whether to save the provided credentials to a file for future use. If this switch is provided, the credentials are saved; otherwise, they are not saved. This parameter is optional.

.EXAMPLE
Set-AlpacaApiConfiguration -ApiKey "YOUR_API_KEY" -ApiSecret "YOUR_API_SECRET"

This example sets the Alpaca API configuration by providing the API key and API secret.

#>

function Set-AlpacaApiConfiguration {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string]$ApiKey,

        [Parameter(Mandatory = $true)]
        [string]$ApiSecret,

        [switch]$SaveProfile
    )

    # Store API keys in environment variables temporarily
    $env:ALPACA_API_KEY = $ApiKey
    $env:ALPACA_API_SECRET = $ApiSecret

    $Credentials = @{
        api_key = $ApiKey
        api_secret = $ApiSecret
    }

    if ($SaveProfile) {
        $CredentialsPath = switch ([Environment]::OSVersion.Platform) {
            [PlatformID]::Win32NT { Join-Path $env:USERPROFILE ".alpaca-credentials" }
            default { Join-Path $HOME ".alpaca-credentials" }
        }

        # Check if credentials file already exists and prompt user for action
        if (Test-Path $CredentialsPath) {
            $overwrite = $false
            $message = "The Alpaca API credentials profile already exists. Do you want to replace it? [Y/N]: "
            $response = Read-Host -Prompt $message
            if ($response -eq 'Y' -or $response -eq 'y') {
                $overwrite = $true
            }

            if (-not $overwrite) {
                Write-Host "Operation cancelled by the user. Existing profile not modified."
                return
            }
        }
        
        # Save or overwrite credentials
        $Credentials | ConvertTo-Json | Set-Content -Path $CredentialsPath -Force
        Write-Host "Alpaca API credentials profile saved successfully."
    }
}
