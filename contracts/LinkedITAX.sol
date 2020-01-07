pragma solidity ^0.5.0;

/**
 * @dev Interface of the tax contract  
 *
 */
interface ITAX {
    function updateNormRate() external returns (uint256);
    function viewNormRate() external view returns (uint256);
}
