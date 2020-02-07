pragma solidity 0.5.11;

/**
 * @dev Interface of the Collateral contract  
 */
interface ICOL {
	function dataTotalCP() external view returns (uint256[3] memory);
	function individualCPdata(address account, uint256 id) external view returns (uint256[2] memory);
}