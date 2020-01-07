/** 
 * 	Custodian contract for the linked stablecoin.
 * 	The custodian contract holds the ether and 
 *	minst/burns the tokens.
 */

pragma solidity ^0.5.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";

import "./LinkedIPROXY.sol";

contract LinkedCUS is Ownable {
    using SafeMath for uint256;
    
    //Proxy address for system contracts
    IPROX public proxy;
    bool public initialized;

    /**
    * @dev Fallback function. Makes the contract payable.
    */
    function() external payable {}
    
    /**
    * Set proxy address
    */
    function initialize(address _proxy) onlyOwner public returns (bool success) {
            require (initialized == false);
            require (_proxy != address(0));
            initialized = true;
            proxy = IPROX(_proxy);
            return true;
    }
    
    modifier whenNotPaused() {
            require(!proxy.checkPause(), "Pausable: paused");
            _;
    }
    
    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyCollateral() {
            address payable collateral = proxy.readAddress()[1]; 
            require(collateral == msg.sender, "Collateral contract not whitelisted");
            _;
    }
    
    /**
    * @dev mint new tokens or burn tokens for the buy/sell of the exchanges
    */
    function mint(address receiver, uint256 amount) onlyCollateral whenNotPaused public returns (bool success) {
            IERC20 token = IERC20(proxy.readAddress()[0]);
            token.mint(receiver, amount);
            return true;
    }
    function burn(address burner, uint256 amount) onlyCollateral public returns (bool success) {
            IERC20 token = IERC20(proxy.readAddress()[0]);
            token.burn(burner, amount);
            return true;
    }
    
    /**
    * @dev transfer function for ETH send by exchanges
    */
    function transfer(address payable receiver, uint256 amount) onlyCollateral public returns (bool success) {
            receiver.transfer(amount);
            return true;
    }
}