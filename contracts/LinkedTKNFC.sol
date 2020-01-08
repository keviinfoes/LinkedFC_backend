/** 
*   Stable coin token contract.
*
*   Linked FC is a custodial stable coin with the goal of simplifying the implementation.
*   Current custodial stable coins use complex implementations, for example by using additional governance tokens.
*   
**/

pragma solidity ^0.5.0;

import "@openzeppelin/contracts/ownership/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Detailed.sol";
import "@openzeppelin/contracts/access/roles/MinterRole.sol";
import "./LinkedIPROXY.sol";
import "./LinkedICOL.sol"; 
import "./LinkedIEXC.sol"; 

contract LinkedTKN is IERC20, ERC20Detailed, Ownable, MinterRole {
	using SafeMath for uint256;

    //Proxy address for system contracts
    IPROX public proxy;
    bool public initialized;
	//Supply variables
	mapping (address => uint256) private _balances;
	mapping (address => mapping (address => uint256)) private _allowances;
    uint256 public _totalSupply;
	//Variables for the normalisation calculation
	uint256 public normRate;
	uint256 public baseRate;
	uint256 public base;
	//Stability tax variables
	uint256 public _feeETH = 0 finney;

    /**
    * Set proxy address
    */
    function initialize(address _proxy) onlyOwner public returns (bool success) {
            require (initialized == false);
            require (_proxy != address(0));
            initialized = true;
            proxy = IPROX(_proxy);
            address _custodian = proxy.readAddress()[2];
            addMinter(_custodian);
            baseRate = 1000000008791120000;             // 1.00000000879112 * 10^18 ~= 2% per year 
            base = 10**18;
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
			uint256 startBlockNum = proxy.startBlock();
	        uint256 newBlockNum = block.number;
	        uint256 blockDiff = newBlockNum.sub(startBlockNum);
            uint256 tempNormRate = baseRate.rpow(blockDiff, base);
			uint256 total = _totalSupply.mul(base).div(tempNormRate);
			return total;
	}
    
	/**
	 * @dev show balance of the address.
	 */
	function balanceOf(address account) public view returns (uint256) {
		    uint256 startBlockNum = proxy.startBlock();
	        uint256 newBlockNum = block.number;
	        uint256 blockDiff = newBlockNum.sub(startBlockNum);
            uint256 tempNormRate = baseRate.rpow(blockDiff, base);
		    uint256 balance = _balances[account].mul(base).div(tempNormRate);
		    return balance;
	}
	function balanceOfDev() public view returns (uint256) {
	        ICOL collateral = ICOL(proxy.readAddress()[1]);
            uint256[3] memory _totalCP = collateral.dataTotalCP();
            uint256 _totalTokensCP = _totalCP[2];
            uint256 _totalTokens = totalSupply();
            uint256 diffTotal = _totalTokensCP.sub(_totalTokens);
            return diffTotal;
	}
	
	/**
	* @dev Update the normalisation rate for the stability fee decuction.
    **/
    function updateNormRate() public returns (uint256) {
            _updateNormRate();
            return normRate;
    }
    
	/**
	 * @dev See `IERC20.transfer`.
	 *
	 * Requirements:
	 *
	 * - `recipient` cannot be the zero address.
	 * - the caller must have a balance of at least `amount`.
	 */
	function transfer(address recipient, uint256 _amount) whenNotPaused public payable returns (bool) {
			_transfer(msg.sender, recipient, _amount);
			return true;
	}

	/**
	 * @dev See `IERC20.allowance`.
	 */
	function allowance(address owner, address spender) public view returns (uint256) {
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
	function transferFrom(address payable sender, address recipient, uint256 amount) whenNotPaused public payable returns (bool) {
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
    
    /**
	 * @dev See `IERC20.approve`.
	 *
	 * Requirements:
	 *
	 * - `spender` cannot be the zero address.
	*/
	function approveExchange(uint256 value) whenNotPaused public returns (bool) {
			IEXC exchange = IEXC(proxy.readAddress()[6]);
			_transfer(msg.sender, address(exchange), value);
			assert(exchange.sellTKN(msg.sender, value));
			return true;
	}
    
    /**
	* @dev Claim te amount for the developer.
    **/
    function devClaim() public returns (bool success) {
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
	function _transfer(address payable sender, address recipient, uint256 amount) internal {
			require(sender != address(0), "ERC20: transfer from the zero address");
			require(recipient != address(0), "ERC20: transfer to the zero address");
			require(msg.value >= _feeETH);
			address payable _custodian = proxy.readAddress()[2];
			uint256 _changeETH = msg.value.sub(_feeETH);
            _custodian.transfer(_feeETH);
            _updateNormRate();
            uint256 normAmount = amount.mul(normRate).div(base);
			_balances[sender] = _balances[sender].sub(normAmount);
			_balances[recipient] = _balances[recipient].add(normAmount);
			sender.transfer(_changeETH);
			emit Transfer(sender, recipient, amount, _feeETH);
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
            _updateNormRate();
            uint256 normAmount = amount.mul(normRate).div(base);
			_totalSupply = _totalSupply.add(normAmount);
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
		    _updateNormRate();
            uint256 normAmount = value.mul(normRate).div(base);
			_totalSupply = _totalSupply.sub(normAmount);
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
	function _approve(address owner, address spender, uint256 value) internal {
			require(owner != address(0), "ERC20: approve from the zero address");
			require(spender != address(0), "ERC20: approve to the zero address");
			_allowances[owner][spender] = value;
			emit Approval(owner, spender, value);
	}
	
	/**
	* @dev Update the normalisation rate for the stability fee decuction. 
	* Uses the `safe` rpow for power calculation.
    **/
	function _updateNormRate() internal {
	        uint256 startBlockNum = proxy.startBlock();
	        uint256 newBlockNum = block.number;
	        uint256 blockDiff = newBlockNum.sub(startBlockNum);
            normRate = baseRate.rpow(blockDiff, base); 
	}

	/**
	* @dev Update the normalisation rate for the stability fee decuction. 
	* Uses the `safe` rpow for power calculation.
    **/
	function _devClaim() internal {
            _updateNormRate();
            uint256 pendingClaim = balanceOfDev();
            address dev = proxy.readAddress()[7];
            uint256 normAmount = pendingClaim.mul(normRate).div(base);
            _totalSupply = _totalSupply.add(normAmount);
            _balances[dev] = _balances[dev].add(normAmount);
	}
} 
