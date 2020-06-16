pragma solidity 0.5.11;

import "./ICOL.sol"; 
import "./IPROXY.sol";

/**
 *   Simple oracle contract for the linked stablecoin.
 *  
 */
contract LinkedORCL {

    //Proxy address for system contracts
    IPROX public proxy;
    bool public initialized;

    /**
     *  @dev Throws if called by any account other than the owner.
     */
    modifier owners() {
            require(msg.sender == proxy._owner(), "Proxy: pause is active");
            _;
    }

    /**
     * Set proxy address
     */
    function initialize(address proxyAddress) external returns (bool success) {
            require (initialized == false);
            require (proxyAddress != address(0));
            initialized = true;
            proxy = IPROX(proxyAddress);
            return true;
    }
    
    /**
     * @dev Manualy update the contract to check the exchange contract
     */
    function updateRate(uint256 newRate) owners external {
            assert(proxy.updateRate(newRate));
    }
}