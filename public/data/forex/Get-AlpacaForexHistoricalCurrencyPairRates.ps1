<#
.SYNOPSIS
    Retrieves historical rates data for currency pairs from the Alpaca API.

.DESCRIPTION
    This function retrieves historical rates data for currency pairs from the Alpaca API based on the specified currency pairs, timeframe, and timeframe interval.

.PARAMETER CurrencyPairs
    Specifies the currency pairs for which historical rates data is to be retrieved. Should be a comma-separated string of currency pairs, e.g., "EUR/USD,USD/JPY".

.PARAMETER Timeframe
    Specifies the sampling interval of the currency rates. Valid values include "5Sec", "1Min", and "1Day".

.PARAMETER Start
    Specifies the inclusive start of the interval. Format: RFC-3339 or YYYY-MM-DD. If missing, the default value is the beginning of the current day.

.PARAMETER End
    Specifies the inclusive end of the interval. Format: RFC-3339 or YYYY-MM-DD. If missing, the default value is the current time.

.PARAMETER Limit
    Specifies the maximum number of data points to return in the response. Default value is 1000.

.PARAMETER Sort
    Specifies whether to sort data in ascending or descending order. Valid values are "asc" and "desc".

.EXAMPLE
    Get-AlpacaForexHistoricalCurrencyPairRates -CurrencyPairs "EUR/USD,USD/JPY" -Timeframe "1Min" -Start "2023-01-01" -End "2023-01-07"
    Retrieves historical rates data for the specified currency pairs sampled every minute from January 1st, 2023, to January 7th, 2023.

#>
Function Get-AlpacaForexHistoricalCurrencyPairRates {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string]$CurrencyPairs,

        [Parameter(Mandatory = $true)]
        [ValidateSet(
            "5Sec",
            "1Min",
            "1Day"
        )]
        [string]$Timeframe,

        [Parameter(Mandatory = $false)]
        [datetime]$Start,

        [Parameter(Mandatory = $false)]
        [datetime]$End,

        [Parameter(Mandatory = $false)]
        [int]$Limit = 1000,

        [Parameter(Mandatory = $false)]
        [ValidateSet(
            "asc",
            "desc"
        )]
        [string]$Sort
    )

    $QueryParameters = @{
        'currency_pairs' = $CurrencyPairs
        'timeframe'      = $Timeframe
        'limit'          = $Limit
    }

    if ($Start) {
        $QueryParameters.Add('start', (Get-Date $Start -Format "yyyy-MM-dd"))
    }

    if ($End) {
        $QueryParameters.Add('end', (Get-Date $End -Format "yyyy-MM-dd"))
    }

    if ($Sort) {
        $QueryParameters.Add('sort', $Sort)
    }

    $ApiParams = @{
        ApiName  = "Data"
        Endpoint = "forex/rates"
        Method   = "Get"
    }

    if ($null -ne $QueryParameters) {
        $ApiParams.Add(
            'QueryString',
            ('?' + (
                ($QueryParameters.GetEnumerator() | ForEach-Object {
                    "$($_.Key)=$([System.Web.HttpUtility]::UrlEncode($_.Value))" }
                ) -join '&'
            ))
        )
    }

    $ResponseData = @{
        rates    = @()
        raw_data = @()
    }

    Try {
        $Response = Invoke-AlpacaApi @ApiParams
        if ($Response) {
            $ResponseData.rates += $Response
        }
    }
    Catch [System.Exception] {
        Write-Error "API call failed: $($_.Exception)"
        return $null
    }

    while ($Response.next_page_token) {
        Write-Verbose "Found next_page_token '$($Response.next_page_token)' : requerying Alpaca API"
        if ($ApiParams.QueryString -notmatch 'page_token=') {
            $ApiParams.QueryString += "&page_token=$($Response.next_page_token)"
        }
        else {
            $ApiParams.QueryString = $ApiParams.QueryString -replace 'page_token=.*?(?=&|$)', "page_token=$($Response.next_page_token)"
        }
        Try {
            $Response = Invoke-AlpacaApi @ApiParams
            if ($Response) {
                $ResponseData.rates += $Response
            }
        }
        Catch [System.Exception] {
            Write-Error "API call failed: $($_.Exception)"
            return $null
            break
        }
    }

    if ($ResponseData.rates.Count -gt 0) {
        return $ResponseData
    }
    else {
        Write-Verbose "No data found."
        return $null
    }
}
