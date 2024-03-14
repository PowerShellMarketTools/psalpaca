<#
.SYNOPSIS
Retrieves account activities from Alpaca based on various filter criteria.

.DESCRIPTION
The Get-AlpacaAccountActivities function fetches account activities from the Alpaca platform. It supports filtering activities by type, date, and more, with support for pagination and ordering.

.PARAMETER MultitypeFilter
Specifies the general category of activities to fetch. Valid values are 'All', 'TradeActivity', and 'NonTradeActivity'.

.PARAMETER ActivityType
Specifies the specific type of activity to fetch. Includes various activity types such as 'FILL', 'TRANS', etc.

.PARAMETER Date
Filters activities to a specific date.

.PARAMETER Until
Filters activities to those before the specified DateTime.

.PARAMETER After
Filters activities to those after the specified DateTime.

.PARAMETER Direction
Determines the order of the returned activities based on their date. Valid values are 'Ascending' and 'Descending'. Defaults to 'Descending'.

.PARAMETER PageSize
Defines the maximum number of activities to return in one response.

.PARAMETER PageToken
Used for pagination; specifies the token for the page of results to retrieve.

.PARAMETER Paper
If provided, fetches activities from the paper trading environment instead of the live trading environment.

.EXAMPLE
PS> Get-AlpacaAccountActivities -ActivityType FILL -Direction Ascending -Paper

This example retrieves fill activities in ascending order from the paper trading environment.

.EXAMPLE
PS> Get-AlpacaAccountActivities -MultitypeFilter TradeActivity -After '2023-01-01' -PageSize 100

This example fetches up to 100 trade activities that occurred after January 1, 2023.

.EXAMPLE
PS> Get-AlpacaAccountActivities -ActivityType DIV -Until '2023-12-31'

This example retrieves dividend activities that occurred before December 31, 2023.

.NOTES
Author: Your Name
API Reference: Check the Alpaca API documentation for more details about the parameters and their values.

.LINK
https://docs.alpaca.markets/api-documentation/api-v2/account-activities/

#>

function Get-AlpacaAccountActivities {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [ValidateSet(
            "All", "TradeActivity", "NonTradeActivity",
            "FILL", "TRANS", "MISC", "ACATC", "ACATS", "CSD", "CSW", "DIV",
            "DIVCGL", "DIVCGS", "DIVFEE", "DIVFT", "DIVNRA", "DIVROC", "DIVTW",
            "DIVTXEX", "INT", "INTNRA", "INTTW", "JNL", "JNLC", "JNLS", "MA",
            "NC", "OPASN", "OPEXP", "OPXRC", "PTC", "PTR", "REORG", "SC",
            "SSO", "SSP", "CFEE", "FEE"
        )]
        [string]$ActivityType,

        [datetime]$Date,

        [datetime]$Until,

        [datetime]$After,

        [ValidateSet("asc", "desc")]
        [string]$Direction = 'desc',

        [Parameter(Mandatory = $false)]
        [int]$MaxResults = 100,

        [Parameter(Mandatory = $false)]
        [switch]$Paper
    )

    if ($Date -and ($Until -or $After)) {
        Write-Error "Cannot specify 'Date' along with 'Until' or 'After'."
        return
    }

    if ($ActivityType -in "All", "TradeActivity", "NonTradeActivity") {
        if ($Date -or $Until -or $After -or $Direction -or $MaxResults) {
            Write-Error "When 'ActivityType' is set to 'All', 'TradeActivity', or 'NonTradeActivity', no other parameters except 'Paper' should be specified."
            return
        }
    }

    $queryParameters = @{
        'activity_type' = $ActivityType
        'direction' = $Direction.ToLower()
        'page_size' = $MaxResults
    }

    if ($Date) {
        $queryParameters['date'] = $Date.ToString("o")  # ISO 8601 format
    }

    if ($Until) {
        $queryParameters['until'] = $Until.ToString("o")
    }

    if ($After) {
        $queryParameters['after'] = $After.ToString("o")
    }

    $queryString = '?' + ($queryParameters.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" } -join "&")

    Write-Verbose "Query String: $queryString"

    try {
        $endpoint = "account/activities"
        
        $Response = Invoke-AlpacaApi -ApiName "Trading" -Endpoint $endpoint -Method "GET" -QueryString $queryString -Paper:$Paper
        Write-Verbose "API Response received"
        return $Response
    }
    catch {
        Write-Error "Failed to fetch account activities: $($_.Exception.Message)"
    }
}
