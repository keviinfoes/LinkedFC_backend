/**
*   Oracle contract for the linked stablecoin.
*   The contract uses the decentralized oracle chainlink
**/

pragma solidity ^0.5.0;

import "@openzeppelin/contracts/ownership/Ownable.sol";

import "./LinkedICOL.sol";
import "./LinkedIPROXY.sol";

contract LinkedORCL is Ownable{

    //Proxy address for system contracts
    IPROX public proxy;
    bool public initialized;
    //Oracle variables
    uint256 public currentPrice;

    /**
    * Set proxy address
    */
    function initialize(address _proxy) onlyOwner public returns (bool success) {
            require (initialized == false);
            require (_proxy != address(0));
            proxy = IPROX(_proxy);
            initialized = true;
            return true;
    }
    
    /**
    * @dev Manualy update the contract to check the exchange contract
    */
    function UpdateRate(uint newRate) onlyOwner public {
            ICOL collateral = ICOL(proxy.readAddress()[1]);
            assert(collateral.updateRate(newRate));
    }
}