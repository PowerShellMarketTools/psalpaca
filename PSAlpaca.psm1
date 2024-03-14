# AlpacaBot.psm1

Write-Verbose "Starting to process AlpacaBot module..."

# Get a list of all .ps1 files under the 'Private' directory
Write-Verbose "Retrieving .ps1 files from the 'Private' directory..."
$PrivateFunctionFiles = Get-ChildItem -Path "$($PSScriptRoot)\private" -Filter '*.ps1' -Recurse

# Dot-source each .ps1 file from the 'Private' directory to import functions into the current scope
foreach ($PrivateFunctionFile in $PrivateFunctionFiles) {
    Write-Verbose "Importing $($PrivateFunctionFile.FullName)..."
    . "$($PrivateFunctionFile.FullName)"
}

# Get a list of all .ps1 files under the 'Public' directory
Write-Verbose "Retrieving .ps1 files from the 'Public' directory..."
$PublicFunctionFiles = Get-ChildItem -Path "$($PSScriptRoot)\public" -Recurse -Depth 3 | Where-Object {$_.Extension -eq ".ps1"}

# List to keep track of all function names that need to be exported
$FunctionsToExport = @()

# Dot-source each .ps1 file from the 'Public' directory and keep track of function names for export
foreach ($PublicFunctionFile in $PublicFunctionFiles) {
    Write-Verbose "Importing $($PublicFunctionFile.FullName) and preparing it for export..."
    . "$($PublicFunctionFile.FullName)"
    # Assuming that each .ps1 file has only one function and the function name matches the filename without the extension
    $FunctionName = "$($PublicFunctionFile.BaseName)"
    $FunctionsToExport += "$($FunctionName)"
    Write-Verbose "Function to export: $($FunctionName)"
}

# Export the functions from 'Public' to make them accessible from the CLI
Write-Verbose "Exporting functions: $($FunctionsToExport -join ', ')..."
Export-ModuleMember -Function $FunctionsToExport

Write-Verbose "PSAlpaca module processing complete."
