<#
.SYNOPSIS
Retrieves corporate action announcements from Alpaca based on various filter criteria.

.DESCRIPTION
The Get-AlpacaCorporateActionAnnouncement function fetches corporate action announcements from the Alpaca platform. It supports filtering announcements by announcement ID, corporate action types, date range, symbol, CUSIP number, and date type.

.PARAMETER AnnouncementId
Specifies the ID of the corporate action announcement to fetch. If provided, all other filter criteria may not be used.

.PARAMETER CorporateActionTypes
Specifies the types of corporate actions to fetch. Valid values are 'Dividend', 'Merger', 'Spinoff', and 'Split'. This parameter accepts an array of corporate action types.

.PARAMETER Since
Specifies the start date of the date range for fetching corporate action announcements.

.PARAMETER Until
Specifies the end date of the date range for fetching corporate action announcements.

.PARAMETER Symbol
Specifies the symbol of the asset for which corporate action announcements are to be fetched.

.PARAMETER CusipNumber
Specifies the CUSIP number of the asset for which corporate action announcements are to be fetched.

.PARAMETER DateType
Specifies the type of date to filter the announcements. Valid values are 'DeclarationDate', 'ExDate', 'RecordDate', and 'PayableDate'.

.PARAMETER Paper
If provided, fetches corporate action announcements from the paper trading environment instead of the live trading environment.

.EXAMPLE
PS> Get-AlpacaCorporateActionAnnouncement -AnnouncementId "123456"

This example retrieves the corporate action announcement with the ID '123456'.

.EXAMPLE
PS> Get-AlpacaCorporateActionAnnouncement -CorporateActionTypes Dividend, Split -Since "2024-01-01" -Until "2024-03-01"

This example retrieves dividend and split corporate action announcements between January 1, 2024, and March 1, 2024.

.LINK
https://docs.alpaca.markets/reference/get-v2-corporate_actions-announcements-id-1

.LINK
https://docs.alpaca.markets/reference/get-v2-corporate_actions-announcements-1

#>

function Get-AlpacaCorporateActionAnnouncement {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $false, ParameterSetName = 'AnnouncementId')]
        [string]$AnnouncementId,

        [Parameter(Mandatory = $true, ParameterSetName = 'Announcements')]
        [ValidateScript(
            {
                foreach ($attr in $_) {
                    if ($attr -notin @("Dividend", "Merger", "Spinoff", "Split")) {
                        throw "Unsupported attribute: $($attr). Supported values are 'Dividend', 'Merger', 'Spinoff', 'Split'."
                    }
                }
                $true
            }
        )]
        [string[]]$CorporateActionTypes,

        [Parameter(Mandatory = $true, ParameterSetName = 'Announcements')]
        [datetime]$Since,

        [Parameter(Mandatory = $true, ParameterSetName = 'Announcements')]
        [datetime]$Until,

        [Parameter(Mandatory = $false, ParameterSetName = 'Announcements')]
        [string]$Symbol,

        [Parameter(Mandatory = $false, ParameterSetName = 'Announcements')]
        [string]$CusipNumber,

        [Parameter(Mandatory = $false, ParameterSetName = 'Announcements')]
        [ValidateSet("DeclarationDate", "ExDate", "RecordDate", "PayableDate")]
        [string]$DateType,

        [Parameter(Mandatory = $false)]
        [switch]$Paper
    )

    $QueryParameters = @{}

    if ($CorporateActionTypes) {
        $QueryParameters.Add('ca_types', ($CorporateActionTypes -join ','))
    }

    if ($Since) {
        $QueryParameters.Add('since', (Get-Date $Since -Format 'yyyy-MM-dd'))
    }

    if ($Until) {
        $QueryParameters.Add('until', (Get-Date $Until -Format 'yyyy-MM-dd'))
    }

    if ($Symbol) {
        $QueryParameters.Add('symbol', $Symbol)
    }

    if ($CusipNumber) {
        $QueryParameters.Add('cusip', $CusipNumber)
    }

    if ($DateType) {
        $QueryParameters.Add('date_type', $DateType)
    }

    $Endpoint = "corporate_actions/announcements"
    if ($AnnouncementId) {
        $Endpoint += "/$AnnouncementId"
    }

    $ApiParams = @{
        ApiName  = "Trading"
        Endpoint = $Endpoint
        Method   = "Get"
    }

    if ($QueryParameters.Count -gt 0) {
        $ApiParams.Add('QueryString', ('?' + ($QueryParameters.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" } ) -join "&").Replace(' ', '&'))
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
