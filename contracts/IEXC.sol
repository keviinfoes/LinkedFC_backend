pragma solidity 0.5.11;

/**
 * @dev Interface of the Exchange contract  
 */
interface IEXC {
     function depositTKN(address receiver, uint256 amount) external returns (bool);
     function _claimsTKN(address owner) external view returns (uint256);
}