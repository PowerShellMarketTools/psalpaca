# PSAlpaca PowerShell Module

## Overview
PSAlpaca is a PowerShell module designed to provide easy access to the Alpaca API for algorithmic trading. Alpaca offers commission-free trading and is widely used for building trading bots and automated trading systems. The PSAlpaca module encapsulates the Alpaca API's functionalities, enabling PowerShell users to manage their portfolios, place orders, and retrieve market data directly from their scripts with minimal setup.

## Features
- **Broker API Endpoints Support**: Manage accounts, view account activities, and access brokerage services, facilitating a wide range of account management functionalities.
- **Trading API Endpoints Support**: Execute trades with comprehensive support for various order types, including market, limit, stop, and stop-limit orders. This feature allows for detailed order management and execution strategies.
- **Data API Endpoints Support**: Access real-time and historical market data to inform trading decisions. This includes market prices, volumes, and other essential market statistics, enabling effective market analysis and strategy development.

## Installation
To install PSAlpaca, use the following PowerShell command:

```powershell
Install-Module -Name PSAlpaca -Repository PSGallery
```

Ensure you have the latest version of PowerShellGet installed to avoid any compatibility issues.

## Configuration
Before using PSAlpaca, you need to configure it with your Alpaca API key and secret. These credentials can be obtained by creating an account on the Alpaca website.

```powershell
Set-PSAlpacaConfiguration -ApiKey "your_api_key" -ApiSecret "your_api_secret" -AlpacaCredential (Get-Credential) -SaveProfile
```

## Documentation
For a detailed description of all commands, their parameters, and usage examples, please refer to the [PSAlpaca Wiki](https://github.com/PowerShellMarketTools/psalpaca/wiki). The wiki includes comprehensive examples, troubleshooting tips, and best practices for using the PSAlpaca module effectively.

## Contributing
Contributions to PSAlpaca are welcome! Whether it's submitting bug reports, suggesting new features, or contributing code, your input is valuable to us. Please refer to the CONTRIBUTING.md file for guidelines on how to contribute.

## License
PSAlpaca is released under the MIT License. See the [LICENSE](https://github.com/PowerShellMarketTools/psalpaca/blob/main/LICENSE) file for more details.

## Disclaimer
PSAlpaca is not affiliated with Alpaca Markets Inc. It is an independent project developed to facilitate access to the Alpaca trading platform via PowerShell. Users are responsible for complying with Alpaca's terms of service and ensuring that their trading activities are lawful.
