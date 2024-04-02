<#
.SYNOPSIS
Sets Alpaca API configuration information including API key and API secret to a JSON file.

.DESCRIPTION
The Set-AlpacaApiConfiguration cmdlet sets Alpaca API configuration information to a JSON file, encoding the values and saving them securely.

.PARAMETER ApiKey
Specifies the Alpaca API key.

.PARAMETER ApiSecret
Specifies the Alpaca API secret.

.PARAMETER SaveProfile
Switch to indicate whether to save the profile to a file.

.EXAMPLE
Set-AlpacaApiConfiguration -ApiKey "your-api-key" -ApiSecret "your-api-secret" -SaveProfile

This example sets Alpaca API configuration information and saves it to the default credentials file location.
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
        [string]$ApiSecret
    )

    # Encode API key and API secret
    $EncodedApiKey = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($ApiKey))
    $EncodedApiSecret = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($ApiSecret))

    # Create credentials object
    $Credentials = @{
        ApiKey    = $EncodedApiKey
        ApiSecret = $EncodedApiSecret
    }

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
