<#
.SYNOPSIS
Retrieves assets from Alpaca based on various filter criteria.

.DESCRIPTION
The Get-AlpacaAsset function fetches assets from the Alpaca platform. It supports filtering assets by status, asset class, exchange, and attributes, with support for pagination and ordering.

.PARAMETER SymbolOrAssetId
Specifies the symbol or asset ID of the asset to fetch. If provided, all other filter criteria may not be used.

.PARAMETER Status
Specifies the status of assets to fetch. Valid values are 'All' and 'Active'.

.PARAMETER AssetClass
Specifies the asset class of assets to fetch. Valid values are 'All', 'USEquity', and 'Crypto'.

.PARAMETER Exchange
Specifies the exchange of assets to fetch. Valid values include various exchange abbreviations such as 'AMEX', 'ARCA', 'BATS', etc.

.PARAMETER Attributes
Specifies additional attributes of assets to fetch. This parameter can accept a single attribute or an array of attributes.

.PARAMETER Paper
If provided, fetches assets from the paper trading environment instead of the live trading environment.

.EXAMPLE
PS> Get-AlpacaAsset -SymbolOrAssetId AAPL

This example retrieves the asset with the symbol 'AAPL'.

.EXAMPLE
PS> Get-AlpacaAsset -Status Active -AssetClass USEquity -Exchange NYSE

This example retrieves active US equities listed on the New York Stock Exchange.

.LINK
https://docs.alpaca.markets/reference/get-v2-assets-1

.LINK
https://docs.alpaca.markets/reference/get-v2-assets-symbol_or_asset_id-1

#>

function Get-AlpacaAsset {
    [CmdletBinding()]
    Param (
        [Parameter(ParameterSetName='BySymbolOrAssetId')]
        [string]$SymbolOrAssetId,

        [Parameter(ParameterSetName='ByCriteria')]
        [ValidateSet("All", "Active")]
        [string]$Status,

        [Parameter(ParameterSetName='ByCriteria')]
        [ValidateSet("All", "USEquity", "USOption", "Crypto")]
        [string]$AssetClass,

        [Parameter(ParameterSetName='ByCriteria')]
        [ValidateSet("AMEX", "ARCA", "BATS", "NYSE", "NASDAQ", "NYSEARCA", "OTC")]
        [string]$Exchange,

        [Parameter(ParameterSetName='ByCriteria')]
        [ValidateScript(
            {
                foreach ($attr in $_) {
                    if ($attr -notin @("ptp_no_exception", "ptp_with_exception", "ipo", "options_enabled")) {
                        throw "Unsupported attribute: $($attr). Supported values are 'ptp_no_exception', 'ptp_with_exception', 'ipo', 'options_enabled'."
                    }
                }
                $true
            }
        )]
        [string[]]$Attributes,

        [Parameter(Mandatory = $false)]
        [switch]$Paper
    )

    if ($PSCmdlet.ParameterSetName -eq 'ByCriteria') {
        $QueryParameters = @{}

        if ($Status) {
            $QueryParameters.Add('status', $Status.ToLower())
        }

        if ($AssetClass -and ($AssetClass -ne "All")) {
            $QueryParameters.Add('asset_class', $(
                    switch ($AssetClass) {
                        "USEquity" { 'us_equity' }
                        "USOption" { 'us_option' }
                        "Crypto" { 'crypto' }
                    }
                ))
        }

        if ($Exchange) {
            $QueryParameters.Add('exchange', $Exchange.ToUpper())
        }

        if ($Attributes) {
            $AttributesString = $Attributes -join ','
            $QueryParameters.Add('attributes', $AttributesString)
        }

        $Endpoint = "assets"
    }
    elseif ($PSCmdlet.ParameterSetName -eq 'BySymbolOrAssetId') {
        $Endpoint = "assets/$($SymbolOrAssetId.ToUpper())"
    }

    $ApiParams = @{
        ApiName     = "Trading"
        Endpoint    = $Endpoint
        Method      = "Get"
    }

    if ($QueryParameters) {
        $ApiParams.Add(
            'QueryString',
            ('?' + (
                ($QueryParameters.GetEnumerator() | ForEach-Object {
                    "$($_.Key)=$($_.Value)" }
                ) -join '&'
            ))
        )
    }

    if ($Paper) {
        $ApiParams.Add('Paper', $true)
        Write-Verbose "Paper trading mode enabled."
    }

    Try {
        Write-Verbose "Invoking Alpaca API..."
        $Response = Invoke-AlpacaApi @ApiParams
        return $Response
    }
    Catch [System.Exception] {
        Write-Error "API call failed: $($_.Exception)"
        return $null
    }
}
