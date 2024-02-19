function Get-AlpacaAccount {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $false)]
        [switch]$Paper
    )

    $ApiParams = @{
        ApiName = "Trading"
        Endpoint = "account"
        Method = "Get"
    }

    if ($Paper) {
        $ApiParams.Add('Paper', $true)
    }

    Try {
        Invoke-AlpacaApi @ApiParams
    }
    Catch [System.Exception] {
        Write-Error $_.Exception
    }
}
