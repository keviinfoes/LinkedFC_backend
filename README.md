# LinkedFC
This repository contains a full collateralized stablecoin named linked. Linked is a stablecoin seeking minimal complexity and maximum decentralization. No additional governance tokens needed and an economic incentive for opening collateral positions.

The stability is maintained by the below forces:
1. If the price of the token < 1 USD: the collateral position holders will be incentivised to close their position for the the cheap token price. The buy pressure from closing the collateral positions will change the price upwards to 1 USD. Further note that because the system collateral > total token value, selling for less then 1 USD is irrational behavior.
2. If the price of the token > 1 USD: ETH holders will be incentivised to open collateral positions and flood the market with new tokens. This sell pressure from the new tokens will change the price downwards to 1 USD.

To test alpha v0.2 visit: [banq.link](banq.link).

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
- **Proxy contract**: 0x023493D0C4625c8502F2993A7B7db37798a2dCb1 
- **Token contract**: 0x6B2dF5E744ccCC94c5B1c01BF8349b543594157c
- **Collateral contract**: 0x3AA50B60A7a54EA6950f9f074E81FbF86d893352
- **Custodian contract**: 0xf2A89A8F5A1d09B00C56bEB6486fEED6087824c1
- **Tax contract**: 0xC9c0E917F7Fd6B02d0751112Dc7e2DbC1Bf49D2D
- **Oracle contract**: 0xC66E42175D0C9Af6726DBE54Fb9A7dcd7128c5A6
- **Defcon contract**: 0x55843c792f77ca62a688e7cC96FCc63A4b4b0BDe
- **Exchange contract**: 0x6417573b78b8d3E4Ba756c02b7Fc975348213333

## Front end
For the front end implementation see: [linked front end](https://github.com/keviinfoes/LinkedFC_frontend).

