/** 
 *  Exchange contract for the linked stablecoin.
 *
 *  The exchange takes the oracle price input for ETH in USD. Then fixes the price between the
 *  stablecoin and Ether on 1 stablecoin for 1 USD (in ETH).
 * 
**/

pragma solidity ^0.5.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./LinkedICOL.sol";
import "./LinkedIPROXY.sol";

contract LinkedEXC is Ownable {
    using SafeMath for uint256;
 
    //Proxy address for system contracts
    IPROX public proxy;
    bool public initialized;
    //Exchange variables
    uint256 base;
    mapping (address => uint256) private _claimsTKN;
    mapping (address => uint256) private _claimsETH;

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
            base = 10**18;
            return true;
    }
    
    function totalReserve() public view returns (uint256[2] memory) {
	        IERC20 token = IERC20(proxy.readAddress()[0]);
	        uint256 ethReserve = address(this).balance;
	        uint256 tokenReserve = token.balanceOf(address(this));
	        uint256[2] memory _totalReserve = [ethReserve, tokenReserve];
	        return _totalReserve;
	}
    
    function claimOfTKN(address account) public view returns (uint256) {
		    return _claimsTKN[account];
	}
	function claimOfETH(address account) public view returns (uint256) {
		    return _claimsETH[account];
	}

    /**
    * Read the current ETH price rate
    */
    function rate() public view returns (uint256) {
            ICOL collateral = ICOL(proxy.readAddress()[1]);   
            return collateral.rate();
    }
    
    /**
    * Deposit tokens (sell) and receive a claim for buying ETH  
    */
    function sellTKN(address receiver, uint256 amount) public returns (bool) {
            _sellTKN(receiver, amount);
            return true;
    }
    
    /**
    * Withraw tokens (buy)) with a claim after deposit of ETH
    */
    function buyTKN(uint256 amount) public payable returns (bool) {
            _buyTKN(amount);
            return true;
    }
    
    /**
    * Deposit ETH (sell) and receive a claim for buying tokens
    */
    function sellETH() public payable returns (bool) {
            _sellETH();
            return true;
    }
    
    /**
    * Withraw ETH (buy) with a claim after deposit of tokens
    */
    function buyETH(uint256 amount) public returns (bool) {
            _buyETH(amount);
            return true;
    }
    
    /**
    * Remove token claim to retreive tokens
    */
    function removeClaimTKN(uint256 amount) public returns (bool) {
            _removeClaimTKN(amount);
            return true;
    }
    
    /**
    * Remove ETH claim to retreive ETH
    */
    function removeClaimETH(uint256 amount) public returns (bool) {
            _removeClaimETH(amount);
            return true;
    }
    
    /**
    *  @dev Internal functions called by the above functions.
    */
    function _sellTKN(address receiver, uint256 amount) internal {
            IERC20 token = IERC20(proxy.readAddress()[0]);
            require(msg.sender == address(token), "Exchange: not the token contract");
            uint256 normRate = token.updateNormRate();
            //normalise amount in claim
            _claimsTKN[receiver] = _claimsTKN[receiver].add(amount.mul(normRate).div(base));
    }
    
    function _sellETH() internal {
            require(msg.value > 0, "Exchange: no value send");
            _claimsETH[msg.sender] = _claimsETH[msg.sender].add(msg.value);
    }
    
    function _buyTKN(uint256 amount) internal {
            IERC20 token = IERC20(proxy.readAddress()[0]);
            uint256 rateUSD = rate();
            uint256 _amountETH = amount.div(rateUSD);
            require(amount <= token.balanceOf(address(this)), "Exchange: not enough tokens in reserve");
            _claimsETH[msg.sender] = _claimsETH[msg.sender].sub(_amountETH);
            assert(token.transfer(msg.sender, amount));
    }

    function _buyETH(uint256 amount) internal {
            IERC20 token = IERC20(proxy.readAddress()[0]);
            uint256 normRate = token.updateNormRate();
            uint256 rateUSD = rate();
            uint256 _amountTKN = amount.mul(rateUSD);
            require(amount <= address(this).balance, "Exchange: not enough ether in reserve");
            _claimsTKN[msg.sender] = _claimsTKN[msg.sender].sub(_amountTKN.mul(normRate).div(base));
            msg.sender.transfer(amount);
    }
    
    function _removeClaimTKN(uint256 amount) internal {
            IERC20 token = IERC20(proxy.readAddress()[0]);
            uint256 normRate = token.updateNormRate();
            _claimsTKN[msg.sender] = _claimsTKN[msg.sender].sub(amount.mul(normRate).div(base));
            assert(token.transfer(msg.sender, amount));
    }
    
    function _removeClaimETH(uint256 amount) internal {
            _claimsETH[msg.sender] = _claimsETH[msg.sender].sub(amount);
            msg.sender.transfer(amount);
    }
}