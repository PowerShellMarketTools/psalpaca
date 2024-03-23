<#
.SYNOPSIS
Retrieves orders from Alpaca Trading based on various filter criteria.

.DESCRIPTION
The Get-AlpacaOrder function fetches orders from the Alpaca Trading platform. It allows filtering orders by status, symbol, date, and more. The function supports pagination through the 'Limit' parameter and can return orders in ascending or descending order based on creation time.

.PARAMETER Status
Specifies the status of the orders to fetch. Valid values are 'All', 'Open', and 'Closed'. Defaults to 'Open'.

.PARAMETER Limit
Defines the maximum number of orders to return. Must be between 50 and 500. Defaults to 50.

.PARAMETER After
Filters orders to those created after the specified DateTime.

.PARAMETER Until
Filters orders to those created before the specified DateTime.

.PARAMETER Sort
Determines the sort order of the returned orders based on their creation time. Valid values are 'Ascending' and 'Descending'. Defaults to 'Descending'.

.PARAMETER Nested
If set to $true, includes nested orders in the response.

.PARAMETER Symbols
Filters orders to those that match the specified array of symbols.

.PARAMETER Paper
If provided, fetches orders from the paper trading environment instead of the live trading environment.

.EXAMPLE
PS> Get-AlpacaOrder -Status Open -Limit 100 -Sort Ascending -Paper

This example retrieves up to 100 open orders sorted in ascending order of creation from the paper trading environment.

.EXAMPLE
PS> Get-AlpacaOrder -Symbols AAPL,MSFT -After '2021-01-01' -Until '2021-12-31'

This example fetches orders for AAPL and MSFT that were created in the year 2021.

.EXAMPLE
PS> Get-AlpacaOrder -Status Closed -Sort Descending -Limit 50

This example retrieves the last 50 closed orders sorted in descending order based on the creation time.

.NOTES
Author: Your Name
API Reference: Check the Alpaca API documentation for more details about the parameters and their values.

.LINK
https://docs.alpaca.markets/reference/getallorders

#>

function Get-AlpacaOrder {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $false)]
        [ValidateSet('All', 'Open', 'Closed')]
        [string]$Status,

        [Parameter(Mandatory = $false)]
        [ValidateRange(50, 500)]
        [int]$Limit,

        [Parameter(Mandatory = $false)]
        [datetime]$After,

        [Parameter(Mandatory = $false)]
        [datetime]$Until,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Ascending', 'Descending')]
        [string]$Sort = 'Descending',

        [Parameter(Mandatory = $false)]
        [bool]$Nested,

        [Parameter(Mandatory = $false)]
        [string[]]$Symbols,

        [Parameter(Mandatory = $false)]
        [switch]$Paper
    )

    # Validate parameters
    if ($After -and $Until) {
        Write-Error "After and Until cannot be used together."
        return
    }

    # Build query string
    $QueryParameters = @{
        status    = $Status.ToLower()
        limit     = $Limit
        direction = if ($Sort -eq 'Ascending') { 'asc' } else { 'desc' }
    }

    if ($After) {
        $QueryParameters.Add('after', (Get-Date $After -Format "yyyy-MM-dd"))
    }

    if ($Until) {
        $QueryParameters.Add('until', (Get-Date $Until -Format "yyyy-MM-dd"))
    }

    if ($Nested) {
        $QueryParameters.Add('nested', $true)
    }

    if ($Symbols) {
        $QueryParameters.Add('symbols', ($Symbols -join ','))
    }

    # Construct API parameters
    $ApiParams = @{
        ApiName  = "Trading"
        Endpoint = "orders"
        Method   = "Get"
    }

    if ($null -ne $QueryParameters) {
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
        $Response = Invoke-AlpacaApi @apiParams
        return $Response
    }
    Catch [System.Exception] {
        Write-Error "API call failed: $($_.Exception)"
        return $null
    }
}
