pragma solidity ^0.5.0;

/**
 * @dev Interface of the tax contract  
 *
 */
interface ITAX {
    function claimInterest(address receiver, uint256 id) external returns (bool);
}
