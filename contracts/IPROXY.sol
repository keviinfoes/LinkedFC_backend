pragma solidity 0.5.11;

/**
 * @dev Interface of the Proxy contract  
 *
 */
interface IPROX {
    function startBlock() external view returns (uint256);
    function rate() external view returns (uint256);
    function base() external view returns (uint256);
    function readAddress() external view returns (address payable[8] memory);
    function updateRate(uint newRate) external returns (bool success);
    function checkPause() external view returns (bool);
    function defconActive() external view returns (bool);
    function _owner() external view returns (address);
    function updateStartBlock(uint256 newBlock) external returns (bool);
}
