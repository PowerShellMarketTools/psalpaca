function Set-AlpacaApiConfiguration {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string]$ApiKey,
        
        [Parameter(Mandatory = $true)]
        [string]$ApiSecret,
        
        [Parameter(Mandatory = $false)]
        [System.Management.Automation.PSCredential]$AlpacaCredential,
        
        [switch]$SaveProfile
    )

    # Store API keys in environment variables temporarily
    $env:ALPACA_API_KEY = $ApiKey
    $env:ALPACA_API_SECRET = $ApiSecret

    $Credentials = @{
        api_key = $ApiKey
        api_secret = $ApiSecret
    }

    if ($AlpacaCredential) {
        $username = $AlpacaCredential.UserName
        $password = $AlpacaCredential.GetNetworkCredential().Password

        # Add broker credentials to the hashtable as a nested object
        $Credentials['broker_credential'] = @{
            username = $username
            password = $password
        }
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
