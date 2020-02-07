pragma solidity 0.5.11;

import "@openzeppelin/contracts/ownership/Ownable.sol";

import "./ICOL.sol"; 
import "./IPROXY.sol";

/**
 *   Simple oracle contract for the linked stablecoin.
 *  
 */
contract LinkedORCL is Ownable {

    //Proxy address for system contracts
    IPROX public proxy;
    bool public initialized;

    /**
     * Set proxy address
     */
    function initialize(address proxyAddress) onlyOwner external returns (bool success) {
            require (initialized == false);
            require (proxyAddress != address(0));
            initialized = true;
            proxy = IPROX(proxyAddress);
            return true;
    }
    
    /**
     * @dev Manualy update the contract to check the exchange contract
     */
    function updateRate(uint256 newRate) onlyOwner external {
            assert(proxy.updateRate(newRate));
    }
}