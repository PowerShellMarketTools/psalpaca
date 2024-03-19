<#
.SYNOPSIS
Retrieves market calendar information from the Alpaca Trading API for specified date range and date type.

.DESCRIPTION
The Get-AlpacaMarketCalendarInfo cmdlet is used to retrieve market calendar information from the Alpaca Trading API. It provides details about trading and settlement dates within the specified date range and date type.

.PARAMETER Start
Specifies the start date of the date range for which market calendar information is to be retrieved. If not specified, the default behavior is to retrieve information from the current date.

.PARAMETER End
Specifies the end date of the date range for which market calendar information is to be retrieved. If not specified, the default behavior is to retrieve information until the end of the current year.

.PARAMETER DateType
Specifies the type of dates to retrieve. Valid values are "Trading" or "Settlement". If not specified, an error is thrown, and you must specify DateType as one of: Trading | Settlement.

.PARAMETER Paper
Indicates whether to retrieve market calendar information for paper trading. If this switch is provided, the information for the paper trading account is retrieved.

.EXAMPLE
Get-AlpacaMarketCalendarInfo -Start "2024-01-01" -End "2024-12-31" -DateType "Trading"

This example retrieves trading market calendar information from January 1, 2024, to December 31, 2024.

.EXAMPLE
Get-AlpacaMarketCalendarInfo -Start "2024-01-01" -End "2024-12-31" -DateType "Settlement" -Paper

This example retrieves settlement market calendar information for paper trading from January 1, 2024, to December 31, 2024.

.LINK
https://docs.alpaca.markets/reference/getcalendar-1

#>

Function Get-AlpacaMarketCalendarInfo {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $false)]
        [datetime]$Start,

        [Parameter(Mandatory = $false)]
        [datetime]$End,

        [Parameter(Mandatory = $false)]
        [ValidateSet("Trading", "Settlement")]
        [string]$DateType,

        [Parameter(Mandatory = $false)]
        [switch]$Paper
    )

    if (-not $DateType) {
        Write-Error "You must specify DateType as one of: Trading | Settlement"
        return
    }

    $QueryParameters = @{}

    if ($Start) {
        $QueryParameters.Add('start', (Get-Date $Start.ToUniversalTime() -Format 'yyyy-MM-dd'))
    }

    if ($End) {
        $QueryParameters.Add('end', (Get-Date $End.ToUniversalTime() -Format 'yyyy-MM-dd'))
    }

    if (($Start) -or ($End)) {
        $QueryString = ('?' + ($QueryParameters.GetEnumerator() | ForEach-Object { "$($_.Key)=$([System.Web.HttpUtility]::UrlEncode($_.Value))" } ) -join "&").Replace(' ','&')
        Write-Verbose "Query String: $($QueryString)"
    }

    $ApiParams = @{
        ApiName  = "Trading"
        Endpoint = "calendar"
        Method   = "Get"
    }

    if ($null -ne $QueryString) {
        $ApiParams.Add('QueryString', $QueryString)
    }

    if ($Paper) {
        $ApiParams.Add('Paper', $true)
    }

    Write-Verbose "Invoking Alpaca API with parameters: $($ApiParams | Format-List | Out-String)"

    Try {
        Invoke-AlpacaApi @ApiParams
    }
    Catch [System.Exception] {
        Write-Error $_.Exception
    }
}
