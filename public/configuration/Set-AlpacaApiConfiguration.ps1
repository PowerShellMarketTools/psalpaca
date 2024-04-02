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

        # Check if credentials file already exists
        if (Test-Path $CredentialsPath) {
            if ($PSCmdlet.ShouldProcess("Alpaca API credentials profile already exists. Do you want to replace it?")) {
                $Credentials | ConvertTo-Json | Set-Content -Path $CredentialsPath -Force
                Write-Host "Alpaca API credentials profile saved successfully."
            } else {
                Write-Host "Operation cancelled by the user. Existing profile not modified."
            }
        } else {
            # Save credentials
            if ($PSCmdlet.ShouldProcess("Save Alpaca API credentials profile?")) {
                $Credentials | ConvertTo-Json | Set-Content -Path $CredentialsPath -Force
                Write-Host "Alpaca API credentials profile saved successfully."
            } else {
                Write-Host "Operation cancelled by the user. Profile not saved."
            }
        }
    }
}
