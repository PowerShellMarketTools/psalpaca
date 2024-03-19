<#
.SYNOPSIS
Sets the account configurations on Alpaca Trading.

.DESCRIPTION
This function updates various account settings for an Alpaca trading account, such as day trading margin call settings, enabling fractional trading, setting maximum margin multipliers, and more.

.PARAMETER DayTradingMarginCallCheck
Specifies the condition under which day trading margin call checks are applied. Valid values are 'Both', 'Entry', 'Exit'.

.PARAMETER FractionalTrading
Indicates whether fractional trading is enabled. Accepts $true or $false.

.PARAMETER MaxMarginMultiplier
Specifies the maximum margin multiplier. Accepts values 1 or 2.

.PARAMETER NoShorting
Indicates whether short selling is disabled. Accepts $true or $false.

.PARAMETER PatternDayTraderCheck
Specifies the condition under which pattern day trader checks are applied. Valid values are 'Entry', 'Exit'.

.PARAMETER PtpNoExceptionEntryCheck
Indicates whether the platform checks for no exceptions on entry. Accepts $true or $false.

.PARAMETER SuspendTrading
Indicates whether trading is suspended. Accepts $true or $false.

.PARAMETER TradeConfirmEmail
Specifies the condition under which trade confirmations are emailed. Valid values are 'all', 'none'.

.PARAMETER Paper
Indicates whether the operation should be performed in paper trading mode. Does not require a value.

.EXAMPLE
PS> Set-AlpacaAccountConfiguration -Paper

This command operates in paper trading mode without changing any specific account settings, effectively showing the current configurations.

.EXAMPLE
PS> Set-AlpacaAccountConfiguration -DayTradingMarginCallCheck 'Entry' -FractionalTrading $true

This command sets the day trading margin call check to apply at entry and enables fractional trading for the account.

.EXAMPLE
PS> Set-AlpacaAccountConfiguration -MaxMarginMultiplier 2 -NoShorting $true -PatternDayTraderCheck 'Exit'

This command sets the maximum margin multiplier to 2, disables short selling, and sets the pattern day trader check to apply at exit.

.EXAMPLE
PS> Set-AlpacaAccountConfiguration -PtpNoExceptionEntryCheck $false -SuspendTrading $true -TradeConfirmEmail 'all' -Paper

This command disables the no-exception entry check, suspends trading, sets trade confirm email to 'all', and operates in paper trading mode.

.EXAMPLE
PS> Set-AlpacaAccountConfiguration -SuspendTrading $false -TradeConfirmEmail 'none'

This command enables trading if previously suspended and sets the account to not send trade confirmation emails.

.NOTES
Ensure that you have the necessary permissions and have authenticated with the Alpaca API before using this function.

.LINK
https://docs.alpaca.markets/reference/patchaccountconfig-1

#>

function Set-AlpacaAccountConfiguration {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='High')]
    Param (
        [Parameter(Mandatory = $false)]
        [ValidateSet('Both', 'Entry', 'Exit')]
        [string]$DayTradingMarginCallCheck,

        [Parameter(Mandatory = $false)]
        [bool]$FractionalTrading,

        [Parameter(Mandatory = $false)]
        [ValidateSet(1, 2, 4)]
        [int]$MaxMarginMultiplier,

        [Parameter(Mandatory = $false)]
        [bool]$NoShorting,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Entry', 'Exit')]
        [string]$PatternDayTraderCheck,

        [Parameter(Mandatory = $false)]
        [bool]$PtpNoExceptionEntryCheck,

        [Parameter(Mandatory = $false)]
        [bool]$SuspendTrading,

        [Parameter(Mandatory = $false)]
        [ValidateSet('all', 'none')]
        [string]$TradeConfirmEmail,

        [Parameter(Mandatory = $false)]
        [switch]$Paper
    )

    $ApiParams = @{
        ApiName  = "Trading"
        Endpoint = "account/configurations"
        Method   = "PATCH"
    }

    $Body = @{}

    if ($DayTradingMarginCallCheck) { $Body.Add('dtbp_check', $DayTradingMarginCallCheck.ToLower()) }
    if ($FractionalTrading) { $Body.Add('fractional_trading', $FractionalTrading) }
    if ($MaxMarginMultiplier) { $Body.Add('max_margin_multiplier', $MaxMarginMultiplier) }
    if ($NoShorting) { $Body.Add('no_shorting', $NoShorting) }
    if ($PatternDayTraderCheck) { $Body.Add('pdt_check', $PatternDayTraderCheck.ToLower()) }
    if ($PtpNoExceptionEntryCheck) { $Body.Add('ptp_no_exception_entry', $PtpNoExceptionEntryCheck) }
    if ($SuspendTrading) { $Body.Add('suspend_trade', $SuspendTrading) }
    if ($TradeConfirmEmail) { $Body.Add('trade_confirm_email', $TradeConfirmEmail.ToLower()) }

    $ApiParams.Add('BodyArguments', $Body)

    if ($Paper) {
        $ApiParams.Add('Paper', $true)
        Write-Verbose "Paper trading mode enabled."
    }

    if ($PSCmdlet.ShouldProcess("Alpaca Trading API", "Set account configurations")) {
        Try {
            Write-Verbose "Invoking Alpaca API to set account configurations..."
            $Response = Invoke-AlpacaApi @ApiParams
            return $Response
        }
        Catch [System.Exception] {
            Write-Error "API call failed: $($_.Exception)"
            return $null
        }
    }
}
