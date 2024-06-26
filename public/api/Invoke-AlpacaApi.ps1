<#
.SYNOPSIS
Invokes the Alpaca API to perform various actions such as retrieving market data, executing trades, and accessing brokerage information.

.DESCRIPTION
The Invoke-AlpacaApi cmdlet is used to make HTTP requests to the Alpaca API for different purposes based on the provided parameters. It constructs the appropriate API endpoint URL, sets the necessary authentication headers, and sends the HTTP request with optional query parameters and request body. The response from the API is returned.

.PARAMETER ApiName
Specifies the type of Alpaca API to invoke. Valid values are "Broker", "Trading", or "Data".

.PARAMETER Endpoint
Specifies the specific endpoint of the Alpaca API to access.

.PARAMETER Method
Specifies the HTTP method to use for the API request, such as GET, POST, PUT, DELETE, etc.

.PARAMETER QueryString
Specifies the query string to append to the API endpoint URL. This parameter is optional.

.PARAMETER BodyArguments
Specifies the body of the API request as a hashtable. This parameter is optional.

.PARAMETER Paper
Indicates whether to use the paper trading environment. If this switch is provided, the requests are directed to the Alpaca paper trading environment.

.EXAMPLE
Invoke-AlpacaApi -ApiName "Data" -Endpoint "bars/day" -Method "GET" -QueryString "?symbol=AAPL&limit=5"

This example retrieves daily bars data for the AAPL symbol from the Alpaca Data API.

.EXAMPLE
Invoke-AlpacaApi -ApiName "Trading" -Endpoint "orders" -Method "POST" -BodyArguments @{symbol="AAPL"; qty=10; side="buy"}

This example places a buy order for 10 shares of AAPL stock using the Alpaca Trading API.

#>

Function Invoke-AlpacaApi {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [ValidateSet("Trading", "Data")]
        [string]$ApiName,

        [Parameter(Mandatory = $true)]
        [string]$Endpoint,

        [Parameter(Mandatory = $true)]
        [string]$Method,

        [Parameter(Mandatory = $false)]
        [string]$QueryString,
        
        [Parameter(Mandatory = $false)]
        [hashtable]$BodyArguments,
        
        [Parameter(Mandatory = $false)]
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
        "Data" { "data" }
    }
    Write-Verbose -Message "ApiNameUriPart = $($ApiNameUriPart)"

    $ApiVersion = switch ($ApiName) {
        "Trading" { "v2" }
        "Data" {
            if ($Endpoint -like "*stocks*") {
                "v2"
            }
            else {
                "v1beta3"
            } 
        }
    }

    # Construct base URL
    $BaseUri = "https://${ApiNameUriPart}.alpaca.markets/$ApiVersion/$Endpoint"
    Write-Verbose -Message "Base url is: $($BaseUri)"

    # Prepare headers for authentication
    $Headers = @{
        "APCA-API-KEY-ID"     = $Config.ApiKey
        "APCA-API-SECRET-KEY" = $Config.ApiSecret
    }

    if ($QueryString) {
        $Uri = "$($BaseUri)$($QueryString)"
    }
    else {
        $Uri = $BaseUri
    }

    Write-Verbose -Message ("Full Uri is: $($Uri)")

    $ApiParams = @{
        Uri         = $Uri
        Method      = $Method
        ContentType = "application/json"
    }

    if ($Headers) {
        $ApiParams.Add('Headers', $Headers)
    }

    if ($BodyArguments) {
        Write-Verbose -Message ("Body request: $($BodyArguments | Select-Object * | ConvertTo-Json -Depth 50 -Compress)")
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
