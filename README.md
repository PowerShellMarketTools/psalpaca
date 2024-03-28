# PSAlpaca PowerShell Module

## Overview
PSAlpaca is a PowerShell module designed to provide easy access to the Alpaca API, enabling PowerShell users to manage their portfolios, place orders, and retrieve market data directly from their scripts with minimal setup.

## Features
- **Trading API Endpoints Support**: Execute trades with comprehensive support for various order types, including market, limit, stop, and stop-limit orders. This feature allows for detailed order management and execution strategies.
- **Data API Endpoints Support**: Access real-time and historical market data to inform trading decisions. This includes market prices, volumes, and other essential market statistics, enabling effective market analysis and strategy development.
- **A Note about the 'Brokers' Endpoint**: Alpaca does provide a 'Brokers' API, which is not targeted towards individual / retail traders. Therefore it has not been included in the module at this time.

## Installation
To install PSAlpaca, use the following PowerShell command:

```powershell
Install-Module -Name PSAlpaca -Repository PSGallery
```

Ensure you have the latest version of PowerShellGet installed to avoid any compatibility issues.

## Configuration
Before using PSAlpaca, you need to configure it with your Alpaca API key and secret. These credentials can be obtained by creating an account on the Alpaca website.

```powershell
Set-AlpacaApiConfiguration -ApiKey "your_api_key" -ApiSecret "your_api_secret" -SaveProfile
```

## Documentation
For a detailed description of all commands, their parameters, and usage examples, please refer to the [PSAlpaca Wiki](https://github.com/PowerShellMarketTools/psalpaca/wiki). The wiki includes comprehensive examples, troubleshooting tips, and best practices for using the PSAlpaca module effectively.

## Contributing
Contributions to PSAlpaca are welcome! Whether it's submitting bug reports, suggesting new features, or contributing code, your input is valuable to us. Please refer to [CONTRIBUTING](https://github.com/PowerShellMarketTools/psalpaca/blob/main/CONTRIBUTING.md) file for guidelines on how to contribute.

## License
PSAlpaca is released under the MIT License. See the [LICENSE](https://github.com/PowerShellMarketTools/psalpaca/blob/main/LICENSE) file for more details.

## Disclaimer
The PowerShellMarketTools owner and community of contributors is not affiliated with Alpaca Markets Inc. Use of this module is **at your own risk**. This module is provided **as is** with no guaruntee that it is free of bugs or other issues that may result in financial loss. Users are additionally responsible for safeguarding their own API Key and Secret.
