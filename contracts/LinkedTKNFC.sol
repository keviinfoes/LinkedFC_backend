/** 
*   Stable coin - named LINKED [LKD]
*
*   Linked FC is a custodial stable coin with the goal of simplifying the implementation.
*   Current custodial stable coins use complex implementations.
*   For example by using bonds and other implementation to stabilize the system.
*   
**/

pragma solidity ^0.5.0;

import "@openzeppelin/contracts/ownership/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Detailed.sol";
import "@openzeppelin/contracts/access/roles/MinterRole.sol";
import "./LinkedIPROXY.sol";

contract LinkedTKN is IERC20, ERC20Detailed, Ownable, MinterRole {
	using SafeMath for uint256;

    	struct Balance { 
        	uint256 amount;
        	uint256 taxBlock;
    	}
    	struct Tax {
        	uint256 amountTax;
        	uint256 amountDev;
        	uint256 taxBlock;
    	}

    	//Proxy address for system contracts
    	IPROX public proxy;
    	bool public initialized;
	//Supply variables
	mapping (address => Balance) private _balances;
	mapping (address => mapping (address => uint256)) private _allowances;
    	uint256 private _totalSupply;
	//Stability tax variables
    	Tax private _tax;
    	uint256 public _feeETH = 0 finney; 
    	uint256 public _blockTax = 3; // 3% per year
    	uint256 public _devTax = 1; //1% per year (of the 3% total)
    	uint256 public _blockYear = 2000000; // ~2 million blocks per year

    	/**
    	* Set proxy address
    	*/
    	function initialize(address _proxy) onlyOwner public returns (bool success) {
            	require (initialized == false);
            	require (_proxy != address(0));
            	proxy = IPROX(_proxy);
            	address _custodian = proxy.readAddress()[2];
            	addMinter(_custodian);
            	initialized = true;
            	return true;
    	}
    
    	modifier whenNotPaused() {
        	require(!proxy.checkPause(), "Pausable: paused");
       	 	_;
    	}	
    
    	/**
    	* @dev Fallback function. Makes the contract payable.
    	*/
   	function() external payable {}
    
	/**
	 * @dev View supply variables
	 */
	function totalSupply() public view returns (uint256) {
			return _totalSupply;
	}
    
	/**
	 * @dev show balance of the address.
	 */
	function balanceOf(address account) public view returns (uint256) {
			uint256 blockDelta = block.number.sub(_balances[account].taxBlock);
			uint256 yearAmount = _balances[account].amount.div(100).mul(_blockTax);
			uint256 blockAmount = yearAmount.div(_blockYear);
			uint256 tax = blockDelta.mul(blockAmount);
			uint256 balance = _balances[account].amount.sub(tax);
			return balance;
	}
	
	function taxReserve() public view returns (uint256) {
			uint256 blockDelta = block.number.sub(_tax.taxBlock);
			uint256 yearAmount = _totalSupply.div(100).mul(_blockTax.sub(_devTax));
			uint256 blockAmount = yearAmount.div(_blockYear);
			uint256 tax = blockDelta.mul(blockAmount);
			uint256 balance = _tax.amountTax.add(tax);
			return balance;
	}
	
	function devReserve() public view returns (uint256) {
			uint256 blockDelta = block.number.sub(_tax.taxBlock);
			uint256 yearAmount = _totalSupply.div(100).mul(_devTax);
			uint256 blockAmount = yearAmount.div(_blockYear);
			uint256 dev = blockDelta.mul(blockAmount);
			uint256 balance = _tax.amountDev.add(dev);
			return balance;
	}
	
	/**
	 * @dev See `IERC20.transfer`.
	 *
	 * Requirements:
	 *
	 * - `recipient` cannot be the zero address.
	 * - the caller must have a balance of at least `amount`.
	 */
	function transfer(address recipient, uint256 amount) whenNotPaused public payable returns (bool) {
			_transfer(msg.sender, recipient, amount);
			return true;
	}

	/**
	 * @dev See `IERC20.allowance`.
	 */
	function allowance(address owner, address spender) whenNotPaused public view returns (uint256) {
			return _allowances[owner][spender];
	}

	/**
	 * @dev See `IERC20.approve`.
	 *
	 * Requirements:
	 *
	 * - `spender` cannot be the zero address.
	 */
	function approve(address spender, uint256 value) whenNotPaused public returns (bool) {
			_approve(msg.sender, spender, value);
			return true;
	}

	/**
	 * @dev See `IERC20.transferFrom`.
	 *
	 * Emits an `Approval` event indicating the updated allowance. This is not
	 * required by the EIP. See the note at the beginning of `ERC20`;
	 *
	 * Requirements:
	 * - `sender` and `recipient` cannot be the zero address.
	 * - `sender` must have a balance of at least `value`.
	 * - the caller must have allowance for `sender`'s tokens of at least
	 * `amount`.
	 */
	function transferFrom(address sender, address recipient, uint256 amount) whenNotPaused public payable returns (bool) {
			_transfer(sender, recipient, amount);
			_approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
			return true;
	}

	/**
	 * @dev Atomically increases the allowance granted to `spender` by the caller.
	 *
	 * This is an alternative to `approve` that can be used as a mitigation for
	 * problems described in `IERC20.approve`.
	 *
	 * Emits an `Approval` event indicating the updated allowance.
	 *
	 * Requirements:
	 *
	 * - `spender` cannot be the zero address.
	 */
	function increaseAllowance(address spender, uint256 addedValue) whenNotPaused public returns (bool) {
			_approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
			return true;
	}

	/**
	 * @dev Automically decreases the allowance granted to `spender` by the caller.
	 *
	 * This is an alternative to `approve` that can be used as a mitigation for
	 * problems described in `IERC20.approve`.
	 *
	 * Emits an `Approval` event indicating the updated allowance.
	 *
	 * Requirements:
	 *
	 * - `spender` cannot be the zero address.
	 * - `spender` must have allowance for the caller of at least
	 * `subtractedValue`.
	 */
	function decreaseAllowance(address spender, uint256 subtractedValue) whenNotPaused public returns (bool) {
			_approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
			return true;
	}
	
	/**
	* @dev Mint and burn functions - controlled by Minter (is custodian)
    	**/
    	function mint(address account, uint256 amount) whenNotPaused onlyMinter public returns (bool) {
            		_mint(account, amount);
            		return true;
    	}
    	function burn(address account, uint256 amount) whenNotPaused onlyMinter public returns (bool) {
            		_burn(account, amount);
            		return true;
    	}
    	function taxClaim(address receiver, uint256 amount) public returns (bool) {
            		_taxClaim(receiver, amount);
            		return true;
    	}
    	function devClaim() public returns (bool) {
            		_devClaim();
            		return true;
    	}

	/**
	 * @dev Moves tokens `amount` from `sender` to `recipient`.
	 *
	 * This is internal function is equivalent to `transfer`, and can be used to
	 * e.g. implement automatic token fees, slashing mechanisms, etc.
	 *
	 * Emits a `Transfer` event.
	 *
	 * Requirements:
	 *
	 * - `sender` cannot be the zero address.
	 * - `recipient` cannot be the zero address.
	 * - `sender` must have a balance of at least `amount`.
	 */
	function _transfer(address sender, address recipient, uint256 amount) internal {
			require(sender != address(0), "ERC20: transfer from the zero address");
			require(recipient != address(0), "ERC20: transfer to the zero address");
			require(msg.value >= _feeETH);
			address payable _custodian = proxy.readAddress()[2];
			uint256 _changeETH = msg.value.sub(_feeETH);
			//Send stability fee to custodian
			_custodian.transfer(_feeETH);
			//Set amount to balance minus tax
			_balances[sender].amount = balanceOf(sender);
			_balances[sender].taxBlock = block.number;
			_balances[recipient].taxBlock = block.number;
			//Send transaction
			_balances[sender].amount = _balances[sender].amount.sub(amount);
			_balances[recipient].amount = _balances[recipient].amount.add(amount);
			//Return ETH fee change
			msg.sender.transfer(_changeETH);
			emit Transfer(sender, recipient, amount, _feeETH);
	}

	/** 
	 * @dev Creates `amount` tokens and assigns them to `account`, increasing
	 * the total supply.
	 *
	 * Emits a `Transfer` event with `from` set to the zero address.
	 *
	 * Requirements
	 *
	 * - `to` cannot be the zero address.
	 */
	function _mint(address account, uint256 amount) internal {
			require(account != address(0), "ERC20: mint to the zero address");
			//Set amount to balance minus tax
			_balances[account].amount = balanceOf(account);
			_balances[account].taxBlock = block.number;
			_tax.amountTax = taxReserve();
			_tax.amountDev = devReserve();
			_tax.taxBlock = block.number;
			//Add minted amount
			_totalSupply = _totalSupply.add(amount);
			_balances[account].amount = _balances[account].amount.add(amount);
			emit Transfer(address(0), account, amount, 0);
	}

	 /**
	 * @dev Destoys `amount` tokens from `account`, reducing the
	 * total supply.
	 *
	 * Emits a `Transfer` event with `to` set to the zero address.
	 *
	 * Requirements
	 *
	 * - `account` cannot be the zero address.
	 * - `account` must have at least `amount` tokens.
	 */
	function _burn(address account, uint256 value) internal {
			require(account != address(0), "ERC20: burn from the zero address");
			//Set amount to balance minus tax
			_balances[account].amount = balanceOf(account);
			_balances[account].taxBlock = block.number;
			_tax.amountTax = taxReserve();
			_tax.amountDev = devReserve();
			_tax.taxBlock = block.number;
			//Remove burned amount
			_totalSupply = _totalSupply.sub(value);
			_balances[account].amount = _balances[account].amount.sub(value);
			emit Transfer(account, address(0), value, 0);
	}

	/**
	 * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
	 *
	 * This is internal function is equivalent to `approve`, and can be used to
	 * e.g. set automatic allowances for certain subsystems, etc.
	 *
	 * Emits an `Approval` event.
	 *
	 * Requirements:
	 *
	 * - `owner` cannot be the zero address.
	 * - `spender` cannot be the zero address.
	 */
	function _approve(address owner, address spender, uint256 value) internal {
			require(owner != address(0), "ERC20: approve from the zero address");
			require(spender != address(0), "ERC20: approve to the zero address");
			_allowances[owner][spender] = value;
			emit Approval(owner, spender, value);
	}
	
	/**
	 * @dev claim the tax reserve
	 */
	function _taxClaim(address receiver, uint256 value) internal {
			address payable tax = proxy.readAddress()[4];
			require(msg.sender == tax, "Token: not the tax contract");
			_tax.amountTax = taxReserve();
			_tax.amountDev = devReserve();
			_tax.taxBlock = block.number;
			_tax.amountTax = _tax.amountTax.sub(value);
			_balances[receiver].amount = _balances[receiver].amount.add(value);
	}
	
	/**
	 * @dev claim the dev reserve
	 */
	function _devClaim() internal {
	        	address payable dev = proxy.readAddress()[6];
	        	uint256 value = _tax.amountDev;
	        	_tax.amountDev = 0;
	        	require(msg.sender == dev, "Token: not the developer");
	        	_balances[dev].amount = balanceOf(dev);
	        	_balances[dev].amount = _balances[dev].amount.add(value);
	}
}  
