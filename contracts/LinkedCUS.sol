pragma solidity 0.5.11;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./IPROXY.sol";

/** 
 * 	Custodian contract for the linked stablecoin.
 * 	The custodian contract holds the ether and 
 *	minst/burns the tokens.
 */
contract LinkedCUS {
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
    function initialize(address proxyAddress) external returns (bool success) {
            require (initialized == false);
            require (proxyAddress != address(0));
            initialized = true;
            proxy = IPROX(proxyAddress);
            return true;
    }
    
    modifier whenNotPaused() {
            require(!proxy.checkPause(), "Pausable: paused");
            _;
    }
    
    /**
     * @dev Throws if called by any account other than the collateral address.
     */
    modifier onlyCollateral() {
            address payable collateral = proxy.readAddress()[1]; 
            address payable defcon = proxy.readAddress()[5];
            require(    
                        collateral == msg.sender || 
                        (defcon == msg.sender && proxy.defconActive() == true), 
                        "Collateral contract not whitelisted");
            _;
    }
    
    /**
     * @dev mint new tokens or burn tokens for the buy/sell of the exchanges
     */
    function mint(address receiver, uint256 amount) onlyCollateral whenNotPaused external returns (bool success) {
            IERC20 token = IERC20(proxy.readAddress()[0]);
            assert(token.mint(receiver, amount));
            return true;
    }
    function burn(address burner, uint256 amount) onlyCollateral external returns (bool success) {
            IERC20 token = IERC20(proxy.readAddress()[0]);
	    assert(token.burn(burner, amount));
            return true;
    }
    
    /**
     * @dev transfer function for ETH send by exchanges
     */
    function transfer(address payable receiver, uint256 amount) onlyCollateral external returns (bool success) {
            receiver.transfer(amount);
            return true;
    }
}