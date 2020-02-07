pragma solidity 0.5.11;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./IPROXY.sol";
import "./ICOL.sol"; 
import "./ITAX.sol";

/** 
 *  Exchange contract for the linked stablecoin.
 *
 *  The exchange takes the oracle price input for ETH in USD. Then fixes the price between the
 *  stablecoin and Ether on 1 stablecoin for 1 USD (in ETH).
 * 
 */
contract LinkedEXC is Ownable {
    using SafeMath for uint256;
 
    //Proxy address for system contracts
    IPROX public proxy;
    bool public initialized;
    //Exchange variables
    mapping (address => uint256) private _claimsTKN;
    mapping (address => uint256) private _claimsETH;

    /**
     * @dev Fallback function. Makes the contract payable.
     */
    function() external payable {}

    /**
     * Set proxy address
     */
    function initialize(address proxyAddress) onlyOwner external returns (bool success) {
            require (initialized == false);
            require (proxyAddress != address(0));
            initialized = true;
            proxy = IPROX(proxyAddress);
            return true;
    }
    
    function totalReserve() external view returns (uint256[2] memory) {
	        IERC20 token = IERC20(proxy.readAddress()[0]);
	        uint256 ethReserve = address(this).balance;
	        uint256 tokenReserve = token.balanceOf(address(this));
	        uint256[2] memory _totalReserve = [ethReserve, tokenReserve];
	        return _totalReserve;
	}
    
    function claimOfTKN(address account) public view returns (uint256) {
		    ITAX tax = ITAX(proxy.readAddress()[4]);
        	uint256 normRateFee = tax.viewNormRateFee();
        	uint256 tempClaim = _claimsTKN[account].mul(proxy.base()).div(normRateFee);
		    return tempClaim;
	}

    function claimOfETH(address account) public view returns (uint256) {
		return _claimsETH[account];
	}

    /**
     * Deposit tokens (sell) and receive a claim for buying ETH  
     */
    function depositTKN(address receiver, uint256 amount) external returns (bool) {
            _depositTKN(receiver, amount);
            return true;
    }
    
    /**
     * Deposit ETH (sell) and receive a claim for buying tokens
     */
    function depositETH() external payable returns (bool) {
            _depositETH();
            return true;
    }
    
    /**
     * Withraw tokens (buy)) with a claim after deposit of ETH
     */
    function withdrawTKN(uint256 amount) external payable returns (bool) {
            _withdrawTKN(amount);
            return true;
    }
    
    /**
     * Withraw ETH (buy) with a claim after deposit of tokens
     */
    function withdrawETH(uint256 amount) external returns (bool) {
            _withdrawETH(amount);
            return true;
    }
    
    /**
     *  @dev Internal functions called by the above functions.
     */
    function _depositTKN(address receiver, uint256 amount) internal {
            IERC20 token = IERC20(proxy.readAddress()[0]);
            ITAX tax = ITAX(proxy.readAddress()[4]);
            require(msg.sender == address(token), "Exchange: not the token contract");
            uint256 normRateFee = tax.viewNormRateFee();
            //normalise amount in claim
            _claimsTKN[receiver] = _claimsTKN[receiver].add(amount.mul(normRateFee).div(proxy.base()));
    }
    
    function _depositETH() internal {
            require(msg.value > 0, "Exchange: no value send");
            _claimsETH[msg.sender] = _claimsETH[msg.sender].add(msg.value);
    }
    
    function _withdrawTKN(uint256 amount) internal {
            IERC20 token = IERC20(proxy.readAddress()[0]);
            ITAX tax = ITAX(proxy.readAddress()[4]);
            require(amount <= token.balanceOf(address(this)), "Exchange: not enough tokens in reserve");
            uint256 rateUSD = proxy.rate();
            uint256 tokensExc = claimOfTKN(msg.sender);
            uint256 normRateFee = tax.viewNormRateFee();
            if (tokensExc > 0) {
                if (amount >= tokensExc) {
                    uint256 rest = amount.sub(tokensExc);
                    uint256 _amountETH = rest.div(rateUSD);
                    _claimsTKN[msg.sender] = _claimsTKN[msg.sender].sub(tokensExc.mul(normRateFee).div(proxy.base()));
                    _claimsETH[msg.sender] = _claimsETH[msg.sender].sub(_amountETH);
                    assert(token.transfer(msg.sender, amount)); 
                } else {
                    _claimsTKN[msg.sender] = _claimsTKN[msg.sender].sub(amount.mul(normRateFee).div(proxy.base()));
                    assert(token.transfer(msg.sender, amount)); 
                }
            } else {
                uint256 _amountETH = amount.div(rateUSD);
                _claimsETH[msg.sender] = _claimsETH[msg.sender].sub(_amountETH);
                assert(token.transfer(msg.sender, amount)); 
            }
    }
    
    function _withdrawETH(uint256 amount) internal {
            ITAX tax = ITAX(proxy.readAddress()[4]);
            require(amount <= address(this).balance, "Exchange: not enough ether in reserve");
            uint256 normRateFee = tax.viewNormRateFee();
            uint256 rateUSD = proxy.rate();
            uint256 ethExc = claimOfETH(msg.sender);
            if (ethExc > 0) {
                if (amount >= ethExc) {
                    uint256 rest = amount.sub(ethExc);
                    uint256 _amountTKN = rest.mul(rateUSD);
                    _claimsTKN[msg.sender] = _claimsTKN[msg.sender].sub(_amountTKN.mul(normRateFee).div(proxy.base()));
                    _claimsETH[msg.sender] = _claimsETH[msg.sender].sub(ethExc);
                    msg.sender.transfer(amount);
                } else {
                    _claimsETH[msg.sender] = _claimsETH[msg.sender].sub(amount);
                    msg.sender.transfer(amount);
                }
                
            } else {
                uint256 _amountTKN = amount.mul(rateUSD);
                _claimsTKN[msg.sender] = _claimsTKN[msg.sender].sub(_amountTKN.mul(normRateFee).div(proxy.base()));
                msg.sender.transfer(amount);
            }
    }
}