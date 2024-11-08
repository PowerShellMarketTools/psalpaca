<#
.SYNOPSIS
Sets Alpaca API configuration information including API key and API secret, either saving them to a file or as environment variables.

.DESCRIPTION
The `Set-AlpacaApiConfiguration` cmdlet sets Alpaca API configuration information, encoding the API key and secret.
By default, it saves these credentials as environment variables in memory.
If the `-SaveProfile` switch is provided, the credentials are saved to a JSON file in the user's profile directory.

.PARAMETER ApiKey
Specifies the Alpaca API key. This parameter is required.

.PARAMETER ApiSecret
Specifies the Alpaca API secret. This parameter is required.

.PARAMETER SaveProfile
If specified, the credentials are saved to a JSON file in the user's profile directory. If not specified, the credentials are saved as environment variables.

.EXAMPLE
Set-AlpacaApiConfiguration -ApiKey "your-api-key" -ApiSecret "your-api-secret"

This example sets the Alpaca API configuration and saves it as environment variables in memory.

.EXAMPLE
Set-AlpacaApiConfiguration -ApiKey "your-api-key" -ApiSecret "your-api-secret" -SaveProfile

This example sets the Alpaca API configuration and saves it to a JSON file.
#>
Function Set-AlpacaApiConfiguration {
    [CmdletBinding(
        SupportsShouldProcess,
        ConfirmImpact = 'High'
    )]
    Param (
        [Parameter(Mandatory = $true)]
        [string]$ApiKey,

        [Parameter(Mandatory = $true)]
        [string]$ApiSecret,

        [Parameter(Mandatory = $false)]
        [switch]$SaveProfile
    )

    # Encode API key and API secret
    $EncodedApiKey = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($ApiKey))
    $EncodedApiSecret = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($ApiSecret))

    # Create credentials object
    $Credentials = @{
        ApiKey    = $EncodedApiKey
        ApiSecret = $EncodedApiSecret
    }

    if ($SaveProfile) {
        # Determine the credentials path based on the OS
        $CredentialsPath = switch ([Environment]::OSVersion.Platform) {
            [PlatformID]::Win32NT { Join-Path $env:USERPROFILE ".alpaca-credentials" }
            default { Join-Path $HOME ".alpaca-credentials" }
        }

        if (Test-Path $CredentialsPath) {
            if ($PSCmdlet.ShouldProcess("The file $CredentialsPath already exists. Do you want to overwrite it?")) {
                $Credentials | ConvertTo-Json | Set-Content -Path $CredentialsPath -Force
                Write-Verbose "Alpaca API credentials profile saved successfully."
            }
            else {
                Write-Verbose "Operation cancelled by the user. Existing profile not modified."
            }
        }
        else {
            $Credentials | ConvertTo-Json | Set-Content -Path $CredentialsPath -Force
            Write-Verbose "Alpaca API credentials profile saved successfully."
        }
    }
    else {
        # Save credentials as environment variables
        [Environment]::SetEnvironmentVariable("ALPACA_API_KEY", $EncodedApiKey, "User")
        [Environment]::SetEnvironmentVariable("ALPACA_API_SECRET", $EncodedApiSecret, "User")
        Write-Verbose "Alpaca API credentials saved as environment variables in memory."
    }
}
