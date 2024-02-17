# AlpacaBot.psm1

# Get a list of all .ps1 files under the 'Private' directory
$PrivateFunctionFiles = Get-ChildItem -Path "$($PSScriptRoot)\private" -Filter '*.ps1' -Recurse

# Dot-source each .ps1 file from the 'Private' directory to import functions into the current scope
foreach ($PrivateFunctionFile in $PrivateFunctionFiles) {
    . "$($PrivateFunctionFile.FullName)"
}

# Get a list of all .ps1 files under the 'Public' directory
$PublicFunctionFiles = Get-ChildItem -Path "$($PSScriptRoot)\public" -Filter '*.ps1' -Recurse

# List to keep track of all function names that need to be exported
$FunctionsToExport = @()

# Dot-source each .ps1 file from the 'Public' directory and keep track of function names for export
foreach ($PublicFunctionFile in $PublicFunctionFiles) {
    . "$($PublicFunctionFile.FullName)"
    # Assuming that each .ps1 file has only one function and the function name matches the filename without the extension
    $FunctionName = "$($PublicFunctionFile.BaseName)"
    $FunctionsToExport += "$($FunctionName)"
}

# Export the functions from 'Public' to make them accessible from the CLI
Export-ModuleMember -Function $FunctionsToExport
