<#
.SYNOPSIS
    Retrieves news articles from the Alpaca API.

.DESCRIPTION
    This function retrieves latest news articles across stocks and crypto from the Alpaca API based on the specified parameters.

.PARAMETER Start
    Specifies the inclusive start of the interval. Format: RFC-3339 or YYYY-MM-DD. If missing, the default value is the beginning of the current day.

.PARAMETER End
    Specifies the inclusive end of the interval. Format: RFC-3339 or YYYY-MM-DD. If missing, the default value is the current time.

.PARAMETER Sort
    Specifies the sorting of articles by updated date. Valid values are "desc" (descending) and "asc" (ascending).

.PARAMETER Symbols
    Specifies the comma-separated list of symbols to query news for.

.PARAMETER Limit
    Limit of news items to be returned for given page.

.PARAMETER IncludeContent
    Boolean indicator to include content for news articles (if available).

.PARAMETER ExcludeContentless
    Boolean indicator to exclude news articles that do not contain content.

.EXAMPLE
    Get-AlpacaNewsArticle -Symbols "AAPL,MSFT" -Limit 10 -Start "2023-01-01" -End "2023-01-07" -Sort "desc"
    Retrieves the latest news articles for symbols AAPL and MSFT from January 1st, 2023, to January 7th, 2023, sorted by descending order.
#>
Function Get-AlpacaNewsArticle {
    [CmdletBinding()]
    Param (
        [Parameter()]
        [datetime]$Start,

        [Parameter()]
        [datetime]$End,

        [Parameter()]
        [string]$Sort,

        [Parameter()]
        [string[]]$Symbols,

        [Parameter()]
        [int]$Limit,

        [Parameter()]
        [bool]$IncludeContent,

        [Parameter()]
        [bool]$ExcludeContentless
    )

    $QueryParameters = @{}

    if ($Start) {
        $QueryParameters.Add('start', (Get-Date $Start -Format "yyyy-MM-dd"))
    }

    if ($End) {
        $QueryParameters.Add('end', (Get-Date $End -Format "yyyy-MM-dd"))
    }

    if ($Sort) {
        $QueryParameters.Add('sort', $Sort)
    }

    if ($Symbols) {
        $QueryParameters.Add('symbols', $Symbols -join ',')
    }

    if ($Limit) {
        $QueryParameters.Add('limit', $Limit)
    }

    if ($IncludeContent) {
        $QueryParameters.Add('include_content', $IncludeContent)
    }

    if ($ExcludeContentless) {
        $QueryParameters.Add('exclude_contentless', $ExcludeContentless)
    }

    $ApiParams = @{
        ApiName  = "Data"
        Endpoint = "news"
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

    $ResponseData = @{
        articles = @()
        raw_data = @()
    }

    Try {
        $Response = Invoke-AlpacaApi @ApiParams
        if ($Response) {
            $ResponseData.articles += $Response
        }
    }
    Catch [System.Exception] {
        Write-Error "API call failed: $($_.Exception)"
        return $null
    }

    while ($Response.next_page_token) {
        Write-Verbose "Found next_page_token '$($Response.next_page_token)' : requerying Alpaca API"
        $ApiParams.QueryString = $ApiParams.QueryString -replace 'page_token=.*?(?=&|$)', "page_token=$($Response.next_page_token)"
        Try {
            $Response = Invoke-AlpacaApi @ApiParams
            if ($Response) {
                $ResponseData.articles += $Response
            }
        }
        Catch [System.Exception] {
            Write-Error "API call failed: $($_.Exception)"
            return $null
            break
        }
    }

    if ($ResponseData.articles.Count -gt 0) {
        return $ResponseData
    }
    else {
        Write-Verbose "No data found."
        return $null
    }
}
