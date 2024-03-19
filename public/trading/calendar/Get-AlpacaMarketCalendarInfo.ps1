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
