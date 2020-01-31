pragma solidity 0.5.11;

/**
 * @dev Interface of the Exchange contract  
 */
interface IEXC {
     function sellTKN(address receiver, uint256 amount) external returns (bool);
}