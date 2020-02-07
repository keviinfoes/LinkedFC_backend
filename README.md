# LinkedFC
This repository contains a full collateralized stablecoin named linked. Linked is a stablecoin seeking minimal complexity and maximum decentralization. No additional governance tokens needed and an economic incentive for opening collateral positions.

The stability is maintained by the below forces:
1. If the price of the token < 1 USD: the collateral position holders will be incentivised to close their position for the the cheap token price. The buy pressure from closing the collateral positions will change the price upwards to 1 USD. Further note that because the system collateral > total token value, selling for less then 1 USD is irrational behavior.
2. If the price of the token > 1 USD: ETH holders will be incentivised to open collateral positions and flood the market with new tokens. This sell pressure from the new tokens will change the price downwards to 1 USD.

To test alpha v0.2 visit: [banq.link](https://banq.link).

## Description
The design of linked is:
- **Proxy contract**: overview of all the contracts below. For communication between contracts.
- **Token contract**: erc20 based contract. Adjusted for specific token purposes. 
- **Collateral contract**: logic for opening, closing, adjusting and transferring collateral positions.
- **Custodian contract**: logic for holding ETH collateral and minting/burning tokens.
- **Tax contract**: holds the rates for the stability tax and stability interest.
- **Oracle contract**: inputs the oracle price for ETH.
- **Defcon contract**: logic for emergency shutdown.
- **Exchange contract**: logic for exchaning eth and stability tokens.

## Key design decisions
The below key points are the basis for implementing linked:
  1. Maximize decentralization
  2. Minimize complexity:
      - no additional tokens
      - minimal code
      - single collateral (ETH)
  3. Incentivise collateralization
  
An increase in complexity ~= increase in user/contract risk. Minimizing complexity in design and implementation decreases the risk for users.
 
## Instructions deployment ropsten
1. Install dependencies: `npm install truffle -g` & `npm install @truffle/hdwallet-provider`
2. Clone this repository.
3. Go to the local repository: `cd [path_folder_clone]`
4. Compile the contracts: `truffle compile`
5. Add ropsten to the truffle-config.js file.
6. Deploy the compiled contracts: `truffle migrate --network Ropsten`
7. Now you can interact with the deployed contracts.

## POC deployed contract - Ropsten
- **Proxy contract**: 0x8BCcDa0e784BC60DDC545B40A752D486FC8250fB 
- **Token contract**: 0x1D42651aed782d3e0722310E31C46a522E2828d1
- **Collateral contract**: 0x3f67DdB5D43e85A2d4Bb28C67A8F0f010Af15dBd
- **Custodian contract**: 0x6ebdeb747d1a31D26f271598627cad8Aa91D3B2B
- **Tax contract**: 0xaa5163F5346651C2Bc618cD81Ce45229e765c8a3
- **Oracle contract**: 0x2CDA3512891aFF224a953D5BE459A4e21cA731Ae
- **Defcon contract**: 0xe0C8622F3A9ECeb4b697A3200ce4FAAFD138bAa9
- **Exchange contract**: 0x1524D19638E2B1B8b8B010196d5c705A74581738

## Front end
For the front end implementation see: [linked front end](https://github.com/keviinfoes/LinkedFC_frontend).

