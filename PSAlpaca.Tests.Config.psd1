@{
    Run          = @{
        Path = "./"
    }
    Should       = @{
        ErrorAction = "Continue"
    }
    CodeCoverage = @{
        Enabled = $true
    }
    Output       = @{
        Verbosity           = "Normal"
        StackTraceVerbosity = "Full"
        CIFormat            = "GithubActions"
    }
}
