Function Get-AlpacaCryptoHistoricalBarsData {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [ValidateSet("US")]
        [string]$Location,

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
        [string]$Sort,

        [Parameter(Mandatory = $false)]
        [switch]$Paper
    )

    $QueryParameters = @{}

    if ($Symbols) {
        if ($Symbols -notmatch "[A-Za-z]*\/[A-Za-z]*") {
            Write-Error "Incorrect Symbols format. Format must be in 'CURRENCY\CURRENCY' format. Ex: BTC/USD, USD/ETH, etc..."
            return
        }
        else {
            $QueryParameters.Add('symbols', $Symbols)
        }
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
        # once paper env returns data we can complete this section to respect MaxResults
    }
    
    $ApiParams = @{
        ApiName  = "Data"
        Endpoint = "crypto/$($Location.ToLower())"
        Method   = "Get"
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
