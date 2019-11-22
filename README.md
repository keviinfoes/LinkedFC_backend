# Linked
This repository contains a full collateralized stablecoin named linkedFC (LKC). Linked is a stablecoin with minimal complexity. No multiple coins needed in the implementation or a high stability fee. The stability is maintained by the collateral positions.

1. If the price of the token < 1 USD: the collateral position holders will be incentivised to close their position for the the cheap token price. The buy pressure from closing the collateral positions will change the price upwards to 1 USD. Because the system collateral > total token value, selling for less then 1 USD is irrational.
2. If the price of the token > 1 USD: ETH holders will be incentivised to open collateral positions and flood the market with new tokens. This sell pressure from the new tokens will change the price downwards to 1 USD.

## Description
The design of linked is:
- **Token contract - ERC20**: TBA. 
- **Collateral contract**: Multiple oracles can be added.

## Benefits
The use of multiple oracles mitigates the risk of the oracles. Because if one oracle exchange is broken it can be paused and other exchanges will be used, selected by the users of LKC. TKC holders will be able to vote on the variables.

The benefit of this implementation is that it is fully collaterized with minimal complexity. Only a token backed by collateral positions. The creators of the collateral position receive interest based on the taxes (inflation + fee) payed by the token holders.

## Instructions deployment ropsten
1. Install dependencies: `npm install truffle -g` & `npm install @truffle/hdwallet-provider`
2. Clone this repository.
3. Go to the local repository: `cd [path_folder_clone]`

4. Compile the contracts: `truffle compile`
5. Add ropsten to the truffle-config.js file.

6. Deploy the compiled contracts: `truffle migrate --network Ropsten`
7. Now you can interact with the deployed contracts.

## POC deployed contract - Ropsten
TBD

