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
        [string]$QueryString,
        
        [Parameter(Mandatory = $false)]
        [hashtable]$BodyArguments,
        
        [switch]$Paper
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
    $BaseUri = "https://${ApiNameUriPart}.alpaca.markets/$ApiVersion/$Endpoint"
    Write-Verbose -Message "Base url is: $($BaseUri)"

    # Prepare headers for authentication
    if ($ApiName -eq "Broker") {
        if ($null -eq $Config.BrokerCredentialEncoded) {
            Write-Error "Broker credentials are required for Broker API. Use Set-AlpacaApiConfiguration first."
            return
        }
        $Headers = @{
            'Access-Control-Allow-Origin' = '*'
            "authorization"               = "Basic $($Config.BrokerCredentialEncoded)"
        }
    }
    else {
        $Headers = @{
            "APCA-API-KEY-ID"     = $Config.ApiKey
            "APCA-API-SECRET-KEY" = $Config.ApiSecret
        }
    }

    if ($QueryString) {
        $Uri = "$($BaseUri)$($QueryString)"
    }
    else {
        $Uri = $BaseUri
    }

    Write-Verbose -Message ("Full Uri is: $($Uri)")

    $ApiParams = @{
        Uri = $Uri
        Headers = $Headers
        Method = $Method
        ContentType = "application/json"
    }

    if ($BodyArguments) {
        Write-Verbose -Message ("Body request: $($BodyArguments | Select-Object *)")
        $ApiParams.Add('Body', $($BodyArguments | ConvertTo-Json))
    }
    
    # Make the API request
    try {
        $Response = Invoke-RestMethod @ApiParams
    }
    catch [System.Exception] {
        Write-Error "Failed to invoke Alpaca API: $($_.Exception)"
        return $null
    }
    
    return $Response
}
