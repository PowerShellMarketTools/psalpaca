<#
.SYNOPSIS
Retrieves account activities from Alpaca based on various filter criteria.

.DESCRIPTION
The Get-AlpacaAccountActivities function fetches account activities from the Alpaca platform. It supports filtering activities by type, date, and more, with support for pagination and ordering.

.PARAMETER ActivityType
Specifies the specific type of activity to fetch. This parameter is mandatory. Valid values include various activity types such as 'FILL', 'TRANS', etc.

.PARAMETER Date
Filters activities to a specific date.

.PARAMETER Until
Filters activities to those before the specified DateTime.

.PARAMETER After
Filters activities to those after the specified DateTime.

.PARAMETER Direction
Determines the order of the returned activities based on their date. Valid values are 'Ascending' and 'Descending'. Defaults to 'Descending'.

.PARAMETER MaxResults
Defines the maximum number of activities to return in one response.

.PARAMETER Paper
If provided, fetches activities from the paper trading environment instead of the live trading environment.

.EXAMPLE
PS> Get-AlpacaAccountActivities -ActivityType FILL -Direction Ascending -Paper

This example retrieves fill activities in ascending order from the paper trading environment.

.EXAMPLE
PS> Get-AlpacaAccountActivities -ActivityType DIV -Until '2023-12-31'

This example retrieves dividend activities that occurred before December 31, 2023.

.NOTES
Author: Your Name
API Reference: Check the Alpaca API documentation for more details about the parameters and their values.

.LINK
https://docs.alpaca.markets/reference/getaccountactivitiesbyactivitytype-1

.LINK
https://docs.alpaca.markets/reference/getaccountactivities-2

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

        [Parameter(Mandatory = $false)]
        [datetime]$Date,

        [Parameter(Mandatory = $false)]
        [datetime]$Until,

        [Parameter(Mandatory = $false)]
        [datetime]$After,

        [Parameter(Mandatory = $false)]
        [ValidateSet("Ascending", "Descending")]
        [string]$Direction,

        [Parameter(Mandatory = $false)]
        [int]$MaxResults,

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

    $QueryParameters = @{}

    if ($Direction) {
        $QueryParameters.Add('direction', $(
                switch ($Direction) {
                    "Ascending" { "asc" };
                    "Descending" { "desc" }
                }
            )
        )
    }

    if ($MaxResults) {
        $QueryParameters.Add('page_size', $MaxResults)
    }

    if ($Date) {
        $QueryParameters.Add('date', (Get-Date $Date -Format 'yyyy-MM-dd'))
    }

    if ($Until) {
        $QueryParameters.Add('until', (Get-Date $Until -Format 'yyyy-MM-dd'))
    }

    if ($After) {
        $QueryParameters.Add('after', (Get-Date $After -Format 'yyyy-MM-dd'))
    }

    if ($ActivityType -notin @("All", "TradeActivity", "NonTradeActivity")) {
        $QueryString = '?' + ($QueryParameters.GetEnumerator() | ForEach-Object { "$($_.Key)=$([System.Web.HttpUtility]::UrlEncode($_.Value))" } ) -join "&"
        Write-Verbose "Query String: $($QueryString)"
    }

    try {
        if ($ActivityType -in @("All", "TradeActivity", "NonTradeActivity")) {
            $Endpoint = "account/activities"
        }
        else {
            $Endpoint = "account/activities/$($ActivityType)"
        }

        $Response = Invoke-AlpacaApi -ApiName "Trading" -Endpoint $Endpoint -Method "GET" -QueryString $queryString -Paper:$Paper
        Write-Verbose "API Response received"
        return $Response
    }
    catch {
        Write-Error "Failed to fetch account activities: $($_.Exception.Message)"
    }
}
