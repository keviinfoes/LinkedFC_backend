pragma solidity ^0.5.0;

/**
 * @dev Interface of the Proxy contract  
 *
 */
interface IPROX {
    function defconActive() external view returns (bool);
    function checkPause() external view returns (bool);
    function readAddress() external view returns (address payable[7] memory);
    function startBlock() external view returns (uint256);
}
