pragma solidity 0.5.11;

/**
 * @dev Interface of the tax contract  
 *
 */
interface ITAX {
    function viewNormRateReward() external view returns (uint256);
    function viewNormRateFee() external view returns (uint256);
}
