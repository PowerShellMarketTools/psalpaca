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
        Verbosity           = "Detailed"
        StackTraceVerbosity = "Full"
        CIFormat            = "GithubActions"
    }
}
