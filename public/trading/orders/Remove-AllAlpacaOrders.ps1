function Remove-AllAlpacaOrders {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $false)]
        [switch]$Paper
    )

    $ApiParams = @{
        ApiName = "Trading"
        Endpoint = "orders"
        Method = "DELETE"
    }
    
    if ($Paper) {
        $ApiParams.Add('Paper', $true)
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
