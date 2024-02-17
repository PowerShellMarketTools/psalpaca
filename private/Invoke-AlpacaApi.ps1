Function Invoke-AlpacaApi {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [ValidateSet("Broker", "Trading", "Data")]
        [string]$ApiName,

        [Parameter(Mandatory = $true)]
        [string]$Endpoint,

        [Parameter(Mandatory = $true)]
        [string]$Method,
        
        [Parameter(Mandatory = $false)]
        [hashtable]$Arguments,
        
        [bool]$Paper
    )

    # Load API configuration
    Write-Verbose -Message ("Loading config file data.")
    $Config = 

    Write-Verbose -Message ("Assigning ApiNameUriPart.")
    $ApiNameUriPart = switch ($ApiName) {
        "Trading" {
            switch ($DryRun) {
                $true { "paper-api" };
                $false { "api" }
            }
        };
        "Data" { "data" };
    }
    Write-Verbose -Message ("ApiNameUriPart = $($ApiNameUriPart)")

    Write-Verbose -Message ("Assigning DryRunUriPart.")
    $DryRunUriPart = switch ($DryRun) {
        $true { "alpaca" };
        $false { "alpaca" };
    }
    Write-Verbose -Message ("DryRunUriPart = $($DryRunUriPart)")

    $ApiVersion = switch ($ApiName) {
        "Trading" { "v2" };
        "Data" { "v1beta1" };
    }
    
    # Convert hashtable to query parameters
    Write-Verbose -Message ("Building query parameter string and URI.")
    $BaseUrl = "https://$($ApiNameUriPart).$($DryRunUriPart).markets/$($ApiVersion)/$($Endpoint)"
    if ($null -ne $Arguments) {
        $Query = ($Arguments.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)"}) -join "&"
        $Url = "$($BaseUrl)?$($Query)"
    }
    else {
        $Url = $BaseUrl
    }
    Write-Verbose -Message ("Full URI query string: $($Url)")

    # Prepare headers for authentication
    $Headers = @{
        "APCA-API-KEY-ID"     = $ApiKey
        "APCA-API-SECRET-KEY" = $ApiSecret
    }
    
    # Make the API request
    $Response = Invoke-RestMethod -Uri $Url -Headers $Headers -Method $Method -ContentType "application/json"
    
    return $Response
}
