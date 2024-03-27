Function Get-AlpacaStockSnapshots {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string[]]$Symbols,

        [Parameter(Mandatory = $false)]
        [ValidateSet("IEX", "OTP", "SIP")]
        [string]$Feed,

        [Parameter(Mandatory = $false)]
        [string]$Currency
    )

    $QueryParameters = @{}
    $QueryParameters.Add('symbols', ($Symbols -join ',').ToLower())

    if ($Feed) {
        $QueryParameters.Add('feed', $Feed.ToLower())
    }

    if ($Currency) {
        $QueryParameters.Add('currency', $Currency.ToUpper())
    }

    $ApiParams = @{
        ApiName  = "Data"
        Endpoint = "stocks/snapshots"
        Method   = "Get"
    }

    if ($QueryParameters.Count -gt 0) {
        $ApiParams.Add(
            'QueryString',
            ('?' + (
                ($QueryParameters.GetEnumerator() | ForEach-Object {
                    "$($_.Key)=$([System.Web.HttpUtility]::UrlEncode($_.Value))" }
                ) -join '&'
            ))
        )
    }

    Try {
        $Response = Invoke-AlpacaApi @ApiParams
        return $Response
    }
    Catch [System.Exception] {
        Write-Error "API call failed: $($_.Exception)"
        return $null
    }
}
