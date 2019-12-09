pragma solidity ^0.5.0;

/**
 * @dev Interface of the Collateral contract  
 */
interface ICOL {
    	function rate() external returns (uint256);
        function updateRate(uint newRate) external returns (bool success);
	function dataTotalCP() external view returns (uint256[3] memory);
	function individualCPdata(address account, uint256 id) external returns (uint256[3] memory);
}