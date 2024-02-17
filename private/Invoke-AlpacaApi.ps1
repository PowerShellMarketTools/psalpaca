function Invoke-AlpacaApi {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [ValidateSet("Broker", "Trading", "Data")]
        [string]$ApiName,

        [Parameter(Mandatory = $true)]
        [string]$Endpoint,

        [Parameter(Mandatory = $true)]
        [string]$Method,
        
        [Parameter(Mandatory = $false)]
        [hashtable]$Arguments,
        
        [bool]$Paper
    )

    # Load API configuration
    Write-Verbose -Message "Loading config data."
    $Config = Get-AlpacaApiConfiguration
    
    if ($null -eq $Config) {
        Write-Error "No Alpaca API configuration found. Use Set-AlpacaApiConfiguration cmdlet."
        return
    }

    Write-Verbose -Message "Assigning ApiNameUriPart."
    $ApiNameUriPart = switch ($ApiName) {
        "Trading" { if ($Paper) { "paper-api" } else { "api" } }
        "Data" { if ($Paper) { "data.sandbox" } else { "data" } }
        "Broker" { if ($Paper) { "broker-api.sandbox" } else { "broker-api" } }
    }
    Write-Verbose -Message "ApiNameUriPart = $($ApiNameUriPart)"

    $ApiVersion = switch ($ApiName) {
        "Broker" { "v1" }
        "Trading" { "v2" }
        "Data" { "v1beta1" }
    }
    
    # Construct base URL
    $BaseUrl = "https://${ApiNameUriPart}.alpaca.markets/$ApiVersion/$Endpoint"
    Write-Verbose -Message "Building query parameter string and URI."
    if ($null -ne $Arguments) {
        $Query = ($Arguments.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join "&"
        $Url = "$BaseUrl?$Query"
    }
    else {
        $Url = $BaseUrl
    }
    Write-Verbose -Message "Full URI query string: $Url"

    # Prepare headers for authentication
    if ($ApiName -eq "Broker") {
        if ($null -eq $Config.BrokerCredential) {
            Write-Error "Broker credentials are required for Broker API. Use Set-AlpacaApiConfiguration to set them."
            return
        }
        $encodedCredentials = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($Config.BrokerCredential.UserName + ':' + $Config.BrokerCredential.GetNetworkCredential().Password))
        $Headers = @{
            "Authorization" = "Basic $encodedCredentials"
        }
    }
    else {
        $Headers = @{
            "APCA-API-KEY-ID"     = $Config.ApiKey
            "APCA-API-SECRET-KEY" = $Config.ApiSecret
        }
    }
    
    # Make the API request
    try {
        $Response = Invoke-RestMethod -Uri $Url -Headers $Headers -Method $Method -ContentType "application/json"
    }
    catch {
        Write-Error "Failed to invoke Alpaca API: $_"
        return $null
    }
    
    return $Response
}
