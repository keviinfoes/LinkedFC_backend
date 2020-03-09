pragma solidity 0.5.11;

import "@openzeppelin/contracts/ownership/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Detailed.sol";
import "@openzeppelin/contracts/access/roles/MinterRole.sol";
import "./IPROXY.sol";
import "./ICOL.sol";
import "./ITAX.sol"; 
import "./IEXC.sol"; 

/** 
 *   Stable coin token contract. 
 *   Linked is a custodial stable coin with the goal of simplifying the implementation. 
 */
contract LinkedTKN is IERC20, ERC20Detailed, Ownable, MinterRole {
	using SafeMath for uint256;

    //Proxy address for system contracts
    IPROX public proxy;
    ITAX public tax;
    bool public initialized;
	//Supply variables
	mapping (address => uint256) public _balances;
	mapping (address => mapping (address => uint256)) private _allowances;
    	uint256 public totalSupply;
	//Additional transfer fee variable
	uint256 constant public FEE_ETH = 0 finney;

    /**
     * Set proxy address
     */
    function initialize(address proxyAddress) onlyOwner external returns (bool success) {
            require (initialized == false);
            require (proxyAddress != address(0));
            initialized = true;
            proxy = IPROX(proxyAddress);
            address _custodian = proxy.readAddress()[2];
            addMinter(_custodian);
            address taxAddress = proxy.readAddress()[4];
            tax = ITAX(taxAddress);
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
	function gettotalSupply() public view returns (uint256) {
			uint256 normRateFee = tax.viewNormRateFee();
			uint256 total = totalSupply.mul(proxy.base()).div(normRateFee);
			return total;
	}
    
	/**
	 * @dev show balance of the address.
	 */
	function balanceOf(address account) external view returns (uint256) {
		    uint256 normRateFee = tax.viewNormRateFee();
		    uint256 balance = _balances[account].mul(proxy.base()).div(normRateFee);
		    return balance;
	}
	function balanceOfDev() public view returns (uint256) {
	        ICOL collateral = ICOL(proxy.readAddress()[1]);
            uint256[3] memory _totalCP = collateral.dataTotalCP();
            uint256 _totalTokensCP = _totalCP[2];
            uint256 _totalTokens = gettotalSupply();
            uint256 diffTotal = _totalTokensCP.sub(_totalTokens);
            return diffTotal;
	}
	
	/**
	 * @dev See `IERC20.transfer`.
	 *
	 * Requirements:
	 *
	 * - `recipient` cannot be the zero address.
	 * - the caller must have a balance of at least `amount`. 
	 * 
	 * NOTE: amount is the normalised amount. Do not use the relative amount (after tax). 
	 */
	function transfer(address recipient, uint256 amount) whenNotPaused external payable returns (bool) {
			_transfer(msg.sender, recipient, amount);
			return true;
	}

	/**
	 * @dev See `IERC20.allowance`.
	 */
	function allowance(address ownerAddress, address spender) external view returns (uint256) {
			return _allowances[ownerAddress][spender];
	}

	/**
	 * @dev See `IERC20.approve`.
	 *
	 * Requirements:
	 *
	 * - `spender` cannot be the zero address.
	 */
	function approve(address spender, uint256 value) whenNotPaused external returns (bool) {
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
	function transferFrom(address payable sender, address recipient, uint256 amount) whenNotPaused external payable returns (bool) {
			_approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
			_transfer(sender, recipient, amount);
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
	function increaseAllowance(address spender, uint256 addedValue) whenNotPaused external returns (bool) {
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
	function decreaseAllowance(address spender, uint256 subtractedValue) whenNotPaused external returns (bool) {
			_approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
			return true;
	}
	
	/**
	 * @dev Mint and burn functions - controlled by Minter (is custodian)
     */
    function mint(address account, uint256 amount) whenNotPaused onlyMinter external returns (bool) {
            _mint(account, amount);
            return true;
    }
    function burn(address account, uint256 amount) whenNotPaused onlyMinter external returns (bool) {
            _burn(account, amount);
            return true;
    }
    
    /**
	 * @dev function to deposit tokens to the native exchange
	 * 
	 * NOTE: amount is the normalised amount. Do not use the relative amount (after tax).
	 * 
	 */
	function depositExchange(uint256 value) whenNotPaused external returns (bool) {
			IEXC exchange = IEXC(proxy.readAddress()[6]);
			_transfer(msg.sender, address(exchange), value);
			assert(exchange.depositTKN(msg.sender, value));
			return true;
	}
    
    /**
	 * @dev Claim te amount for the developer.
     */
    function devClaim() external returns (bool success) {
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
	 * 
	 * NOTE: amount is the normalised amount. Do not use the relative amount (after tax). 
	 */
	function _transfer(address payable sender, address recipient, uint256 amount) internal {
			require(sender != address(0), "ERC20: transfer from the zero address");
			require(recipient != address(0), "ERC20: transfer to the zero address");
			require(msg.value >= FEE_ETH);
			address payable _custodian = proxy.readAddress()[2];
			uint256 _changeETH = msg.value.sub(FEE_ETH);
			_balances[sender] = _balances[sender].sub(amount);
			_balances[recipient] = _balances[recipient].add(amount);
			emit Transfer(sender, recipient, amount, FEE_ETH);
			_custodian.transfer(FEE_ETH);
			sender.transfer(_changeETH);
	}

	/** 
	 * @dev Creates `normalised amount` tokens and assigns them to `account`, increasing
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
            uint256 normRateFee = tax.viewNormRateFee();
            uint256 normAmount = amount.mul(normRateFee).div(proxy.base());
			totalSupply = totalSupply.add(normAmount);
			_balances[account] = _balances[account].add(normAmount);
			emit Transfer(address(0), account, amount, 0);
	}

	/**
	 * @dev Destoys `normalised amount` tokens from `account`, reducing the
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
			uint256 normRateFee = tax.viewNormRateFee();
            		uint256 normAmount = value.mul(normRateFee).div(proxy.base());
			totalSupply = totalSupply.sub(normAmount);
			_balances[account] = _balances[account].sub(normAmount);
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
	function _approve(address ownerAddress, address spender, uint256 value) internal {
			require(ownerAddress != address(0), "ERC20: approve from the zero address");
			require(spender != address(0), "ERC20: approve to the zero address");
			_allowances[ownerAddress][spender] = value;
			emit Approval(ownerAddress, spender, value);
	}

	/**
	 * @dev Update the normalisation rate for the stability fee decuction. 
	 * Uses the `safe` rpow for power calculation.
     */
	function _devClaim() internal {
            uint256 normRateFee = tax.viewNormRateFee();
            uint256 pendingClaim = balanceOfDev();
            address dev = proxy.readAddress()[7];
            uint256 normAmount = pendingClaim.mul(normRateFee).div(proxy.base());
            totalSupply = totalSupply.add(normAmount);
            _balances[dev] = _balances[dev].add(normAmount);
	}
}