pragma solidity 0.5.11;

/**
 * @dev Interface of the Custodian contract transfer function 
 *
 */
interface ICUS {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function mint(address payable receiver, uint256 amount) external returns (bool);
    function burn(address payable receiver, uint256 amount) external returns (bool);
}
