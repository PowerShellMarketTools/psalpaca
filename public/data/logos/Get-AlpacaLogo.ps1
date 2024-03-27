<#
.SYNOPSIS
    Retrieves the image of the company logo for the given symbol from the Alpaca API.

.DESCRIPTION
    This function retrieves the image of the company logo for the given symbol from the Alpaca API.

.PARAMETER Symbol
    Specifies the symbol for which the company logo image is to be retrieved.

.PARAMETER Placeholder
    Specifies whether to retrieve a placeholder image if the company logo is not available.

.EXAMPLE
    Get-AlpacaLogo -Symbol "AAPL"
    Retrieves the company logo image for the symbol "AAPL".

#>
Function Get-AlpacaLogo {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string]$Symbol,

        [Parameter(Mandatory = $false)]
        [switch]$Placeholder
    )

    Write-Verbose "Retrieving the company logo image for symbol $Symbol from Alpaca API..."

    $ApiParams = @{
        ApiName  = "Data"
        Endpoint = "logos/$Symbol"
        Method   = "Get"
        QueryString = "?placeholder=$($Placeholder.IsPresent)"
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
