pragma solidity ^0.5.0;

/**
 * @dev Interface of the Proxy contract  
 *
 */
interface IPROX {
    function defcon() external returns (bool);
    function checkPause() external returns (bool);
    function readAddress() external returns (address payable[6] memory);
}
