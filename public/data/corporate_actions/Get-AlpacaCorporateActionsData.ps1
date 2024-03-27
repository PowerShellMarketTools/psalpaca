Function Get-AlpacaCorporateActionsData {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $false)]
        [string[]]$Symbols,

        [Parameter(Mandatory = $false)]
        [ValidateScript(
            {
                foreach ($type in $_) {
                    if ($type -notin @(
                        "reverse_split",
                        "forward_split",
                        "unit_split",
                        "cash_dividend",
                        "stock_dividend",
                        "spin_off",
                        "cash_merger",
                        "stock_merger",
                        "stock_and_cash_merger",
                        "redemption",
                        "name_change",
                        "worthless_removal"
                    )) {
                        throw "Unsupported type: $($type). Supported values are 'reverse_split', 'forward_split', 'unit_split', 'cash_dividend', 'stock_dividend', 'spin_off', 'cash_merger', 'stock_merger', 'stock_and_cash_merger', 'redemption', 'name_change', 'worthless_removal'."
                    }
                }
                $true
            }
        )]
        [string[]]$Types,
        
        [Parameter(Mandatory = $false)]
        [datetime]$Start,

        [Parameter(Mandatory = $false)]
        [datetime]$End,

        [Parameter(Mandatory = $false)]
        [datetime]$MaxResults,

        [Parameter(Mandatory = $false)]
        [ValidateSet("Ascending", "Descending")]
        [string]$Sort
    )

    $QueryParameters = @{}

    if ($Symbols) {
        $QueryParameters.Add('symbols', ($Symbols -join ','))
    }

    if ($Types) {
        $QueryParameters.Add('types', $Types -join ',')
    }

    if ($Start) {
        $QueryParameters.Add('start', (Get-Date $Start -Format 'yyyy-MM-dd'))
    }

    if ($End) {
        $QueryParameters.Add('end', (Get-Date $End -Format 'yyyy-MM-dd'))
    }

    if ($MaxResults) {
        $QueryParameters.Add('limit', $MaxResults)
    }

    if ($Sort) {
        $QueryParameters.Add('sort', $(
            switch ($Sort) {
                "Ascending" {'asc'}
                "Descending" {'desc'}
            }
        ))
    }

    $ApiParams = @{
        ApiName  = "Data"
        Endpoint = "corporate-actions"
        Method   = "Get"
    }

    if ($null -ne $QueryString) {
        $ApiParams.Add('QueryString', $QueryString)
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
