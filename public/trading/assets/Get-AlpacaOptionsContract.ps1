<#
.SYNOPSIS
Retrieves options contracts from the Alpaca API based on specified criteria or symbol.

.DESCRIPTION
This cmdlet allows users to retrieve options contracts from the Alpaca API either by specifying a symbol or using various criteria such as underlying symbols, status, expiration date, strike price, etc.

.PARAMETER SymbolOrId
Specifies the symbol or ID of the options contract to retrieve. This parameter is mutually exclusive with the criteria-based parameters.

.PARAMETER UnderlyingSymbols
Specifies an array of underlying symbols for filtering options contracts.

.PARAMETER Status
Specifies the status of options contracts to filter by. Valid values are "Active" or "Inactive".

.PARAMETER ExpirationDate
Specifies the expiration date of options contracts to filter by.

.PARAMETER ExpirationBefore
Specifies the maximum expiration date of options contracts to filter by.

.PARAMETER ExpirationAfter
Specifies the minimum expiration date of options contracts to filter by.

.PARAMETER RootSymbol
Specifies the root symbol of options contracts to filter by.

.PARAMETER Type
Specifies the type of options contracts to filter by. Valid values are "Call" or "Put".

.PARAMETER Style
Specifies the style of options contracts to filter by. Valid values are "American" or "European".

.PARAMETER StrikePriceGreaterThan
Specifies the minimum strike price of options contracts to filter by.

.PARAMETER StrikePriceLessThan
Specifies the maximum strike price of options contracts to filter by.

.PARAMETER MaxResults
Specifies the maximum number of results to return. Must be between 100 and 10000.

.PARAMETER Paper
Indicates whether to use paper trading mode.

.EXAMPLE
Get-AlpacaOptionsContract -SymbolOrId "AAPL"

Retrieves the options contract with the symbol "AAPL".

.EXAMPLE
Get-AlpacaOptionsContract -UnderlyingSymbols "AAPL,GOOGL" -Status "Active" -MaxResults 500

Retrieves active options contracts with underlying symbols AAPL or GOOGL and limits the results to 500.

.LINK
https://docs.alpaca.markets/reference/get-options-contracts

.LINK
https://docs.alpaca.markets/reference/get-option-contract-symbol_or_id

#>

Function Get-AlpacaOptionsContract {
    [CmdletBinding()]
    Param (
        [Parameter(ParameterSetName = 'BySymbolOrId')]
        [string]$SymbolOrId,

        [Parameter(ParameterSetName = 'ByCriteria')]
        [string[]]$UnderlyingSymbols,

        [Parameter(ParameterSetName = 'ByCriteria')]
        [ValidateSet("Active", "Inactive")]
        [string]$Status,

        [Parameter(ParameterSetName = 'ByCriteria')]
        [datetime]$ExpirationDate,

        [Parameter(ParameterSetName = 'ByCriteria')]
        [datetime]$ExpirationBefore,

        [Parameter(ParameterSetName = 'ByCriteria')]
        [datetime]$ExpirationAfter,

        [Parameter(ParameterSetName = 'ByCriteria')]
        [string]$RootSymbol,

        [Parameter(ParameterSetName = 'ByCriteria')]
        [ValidateSet("Call", "Put")]
        [string]$Type,

        [Parameter(ParameterSetName = 'ByCriteria')]
        [ValidateSet("American", "European")]
        [string]$Style,

        [Parameter(ParameterSetName = 'ByCriteria')]
        [double]$StrikePriceGreaterThan,

        [Parameter(ParameterSetName = 'ByCriteria')]
        [double]$StrikePriceLessThan,

        [Parameter(ParameterSetName = 'ByCriteria')]
        [int]$MaxResults,

        [Parameter(Mandatory = $false)]
        [switch]$Paper
    )

    if ($PSCmdlet.ParameterSetName -eq 'BySymbolOrAssetId') {
        $Endpoint = "options/contracts/$($SymbolOrId.ToUpper())"
    }
    elseif ($PSCmdlet.ParameterSetName -eq 'ByCriteria') {
        $QueryParameters = @{}

        if ($UnderlyingSymbols) {
            $UnderlyingSymbolsString = $UnderlyingSymbols -join ','
            $QueryParameters.Add('underlying_symbols', $UnderlyingSymbolsString)
        }

        if ($Status) {
            $QueryParameters.Add('status', $Status.ToLower())
        }

        if ($ExpirationDate) {
            if (($ExpirationBefore) -or ($ExpirationAfter)) {
                Write-Error "Cannot specify ExpirationBefore or ExpirationAfter with ExpirationDate."
            }
            else {
                $QueryParameters.Add('expiration_date', (Get-Date $ExpirationDate -Format 'yyyy-MM-dd'))
            }
        }
        elseif (($ExpirationBefore) -or ($ExpirationAfter)) {
            if ($ExpirationDate) {
                Write-Error "Cannot specify ExpirationDate with ExpirationBefore or ExpirationAfter."
            }
            else {
                if ($ExpirationBefore) {
                    $QueryParameters.Add('expiration_date_gte', (Get-Date $ExpirationBefore -Format 'yyyy-MM-dd'))
                }
                if ($ExpirationAfter) {
                    $QueryParameters.Add('expiration_date_gte', (Get-Date $ExpirationAfter -Format 'yyyy-MM-dd'))
                }
            }
        }

        if ($RootSymbol) {
            $QueryParameters.Add('root_symbol', $RootSymbol.ToUpper())
        }

        if ($Type) {
            $QueryParameters.Add('type', $Type.ToLower())
        }

        if ($Style) {
            $QueryParameters.Add('style', $Style.ToLower())
        }

        if ($StrikePriceGreaterThan) {
            $StrikePriceGreaterThanLocaleAmount = "{0:C2}" -f $StrikePriceGreaterThan
            $QueryParameters.Add('', $StrikePriceGreaterThanLocaleAmount)
        }

        if ($StrikePriceLessThan) {
            $StrikePriceLessThanLocaleAmount = "{0:C2}" -f $StrikePriceGreaterThan
            $QueryParameters.Add('', $StrikePriceLessThanLocaleAmount)
        }

        if ($MaxResults) {
            if (($MaxResults -lt 100) -or ($MaxResults -gt 10000)) {
                Write-Error "MaxResults must be between 100 and 10000."
            }
            else {
                $MaxResults.Add('limit', [int]$MaxResults)
            }
        }
        else {
            $QueryParameters.Add('limit', 100)
        }

        $Endpoint = "options/contracts"

        $QueryString = ('?' + ($QueryParameters.GetEnumerator() | ForEach-Object { "$($_.Key)=$([System.Web.HttpUtility]::UrlEncode($_.Value))" } ) -join "&").Replace(' ', '&')
        Write-Verbose "Query String: $($QueryString)"
    }

    $ApiParams = @{
        ApiName  = "Trading"
        Endpoint = $Endpoint
        Method   = "Get"
    }

    if ($QueryParameters) {
        $ApiParams.Add('QueryString', ('?' + ($QueryParameters.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" } ) -join "&").Replace(' ', '&'))
    }

    if ($Paper) {
        $ApiParams.Add('Paper', $true)
        Write-Verbose "Paper trading mode enabled."
    }

    Try {
        Invoke-AlpacaApi @ApiParams
    }
    Catch [System.Exception] {
        Write-Error $_.Exception
    }
}
