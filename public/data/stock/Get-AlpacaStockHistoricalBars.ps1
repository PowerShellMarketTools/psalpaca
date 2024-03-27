<#
.SYNOPSIS
    Retrieves historical bars data for stocks from the Alpaca API.

.DESCRIPTION
    This function retrieves historical bars data for stocks from the Alpaca API based on the specified symbols, timeframe, timeframe interval, start date, end date, and other optional parameters.

.PARAMETER Symbols
    Specifies the symbols of the stocks for which historical data is to be retrieved. Should be in the format 'SYMBOL', e.g., AAPL, GOOGL, MSFT, etc.

.PARAMETER Timeframe
    Specifies the number of intervals to include in the response.

.PARAMETER TimeframeInterval
    Specifies the interval of time for each data point. Valid values are "Minute", "Hour", "Day", "Week", "Month".

.PARAMETER Start
    Specifies the start date for the historical data. Optional.

.PARAMETER End
    Specifies the end date for the historical data. Optional.

.PARAMETER MaxResults
    Specifies the maximum number of results to return. Optional.

.PARAMETER Adjustment
    Specifies the type of adjustments to be applied to the data. Valid values are "Raw", "Split", "Dividend", "All". Optional.

.PARAMETER AsOfDate
    Specifies the date to retrieve data as of that date. Optional.

.PARAMETER Feed
    Specifies the feed for retrieving data. Valid values are "IEX", "OTP", "SIP". Optional.

.PARAMETER Currency
    Specifies the currency for retrieving data. Optional.

.PARAMETER Sort
    Specifies the sorting order of the results. Optional.

.EXAMPLE
    Get-AlpacaStockHistoricalBars -Symbols "AAPL" -Timeframe 1 -TimeframeInterval "Hour" -Start "2023-01-01" -End "2023-01-07"
    Retrieves hourly historical bars data for AAPL stock from January 1st, 2023, to January 7th, 2023.
#>

Function Get-AlpacaStockHistoricalBars {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string]$Symbols,

        [Parameter(Mandatory = $true)]
        [int]$Timeframe,

        [Parameter(Mandatory = $true)]
        [ValidateSet(
            "Minute",
            "Hour",
            "Day",
            "Week",
            "Month"
        )]
        [string]$TimeframeInterval,

        [Parameter(Mandatory = $false)]
        [datetime]$Start,

        [Parameter(Mandatory = $false)]
        [datetime]$End,

        [Parameter(Mandatory = $false)]
        [int]$MaxResults,

        [Parameter(Mandatory = $false)]
        [ValidateSet(
            "Raw",
            "Split",
            "Dividend",
            "All"
        )]
        [string]$Adjustment,

        [Parameter(Mandatory = $false)]
        [datetime]$AsOfDate,

        [Parameter(Mandatory = $false)]
        [ValidateSet("IEX", "OTP", "SIP")]
        [string]$Feed,

        [Parameter(Mandatory = $false)]
        [string]$Currency,

        [Parameter(Mandatory = $false)]
        [string]$Sort
    )

    $QueryParameters = @{}

    if ($Symbols) {
        $QueryParameters.Add('symbols', $Symbols)
    }

    if ($Timeframe -and $TimeframeInterval) {
        $TimeframeValue = switch ($TimeframeInterval) {
            "Minute" { "$($Timeframe)T" }
            "Hour" { "$($Timeframe)H" }
            "Day" { "$($Timeframe)D" }
            "Week" { "$($Timeframe)W" }
            "Month" { "$($Timeframe)M" }
        }
        $QueryParameters.Add('timeframe', $TimeframeValue)
    }
    else {
        Write-Error "Both Timeframe and TimeframeInterval must be specified."
    }

    if ($Start) {
        $QueryParameters.Add('start', (Get-Date $Start -Format "yyyy-MM-dd"))
    }

    if ($End) {
        $QueryParameters.Add('end', (Get-Date $End -Format "yyyy-MM-dd"))
    }

    if ($MaxResults) {
        $QueryParameters.Add('limit', $MaxResults)
    }
    
    $ApiParams = @{
        ApiName  = "Data"
        Endpoint = "stocks/bars"
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
        bars     = @()
        raw_data = @()
    }

    Try {
        $Response = Invoke-AlpacaApi @ApiParams
        if ($Response.bars.$($Symbols)) {
            $ResponseData.bars += $Response.bars.$($Symbols)
        }
        if ($Response) {
            $ResponseData.raw_data += $Response
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
            if ($Response.bars.$($Symbols)) {
                $ResponseData.bars += $Response.bars.$($Symbols)
            }
            if ($Response) {
                $ResponseData.raw_data += $Response
            }
        }
        Catch [System.Exception] {
            Write-Error "API call failed: $($_.Exception)"
            return $null
            break
        }
        
    }
    
    if ($ResponseData.bars.Count -gt 0) {
        return $ResponseData
    }
    else {
        Write-Verbose "No data found."
        return $null
    }
}
