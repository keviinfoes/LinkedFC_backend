pragma solidity 0.5.11;

import "@openzeppelin/contracts/math/SafeMath.sol";
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
contract LinkedEXC {
    using SafeMath for uint256;
 
    //Proxy address for system contracts
    IPROX public proxy;
    bool public initialized;
    //Exchange variables
    mapping (address => uint256) public _claimsTKN;
    mapping (address => uint256) public _claimsETH;


    /**
     *  @dev Throws if called by any account other than the owner.
     */
    modifier notpaused() {
            require(proxy.checkPause() != true, "Proxy: pause is active");
            _;
    }

    /**
     *  @dev Throws if called by any account other than the owner.
     */
    modifier paused() {
            require(proxy.checkPause() == true, "Proxy: pause is active");
            _;
    }

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
    function depositTKN(address receiver, uint256 amount) notpaused external returns (bool) {
            _depositTKN(receiver, amount);
            return true;
    }
    
    /**
     * Deposit ETH (sell) and receive a claim for buying tokens
     */
    function depositETH() notpaused external payable returns (bool) {
            _depositETH();
            return true;
    }
    
    /**
     * Withraw tokens (buy)) with a claim after deposit of ETH
     */
    function withdrawTKN(uint256 amount) notpaused external payable returns (bool) {
            _withdrawTKN(amount);
            return true;
    }
    
    /**
     * Withraw ETH (buy) with a claim after deposit of tokens
     */
    function withdrawETH(uint256 amount) notpaused external returns (bool) {
            _withdrawETH(amount);
            return true;
    }
    
        /**
     * Withraw ETH (buy) with a claim after deposit of tokens
     */
    function withdrawETHpause() paused external returns (bool) {
            _withdrawETHpause();
            return true;
    }

    /**
     *  @dev Internal functions called by the above functions.
     * 
     * 
     */
    function _depositTKN(address receiver, uint256 amount) internal {
            IERC20 token = IERC20(proxy.readAddress()[0]);
            require(msg.sender == address(token), "Exchange: not the token contract");
            //transfer function deposits normalised amount 
            _claimsTKN[receiver] = _claimsTKN[receiver].add(amount);
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
            uint256 normRateFee = tax.viewNormRateFee();
            //transfer function deposits normalised amount 
            uint256 tokensExc = claimOfTKN(msg.sender).mul(normRateFee).div(proxy.base());
            if (tokensExc > 0) {
                if (amount >= tokensExc) {
                    uint256 rest = (amount.mul(proxy.base()).div(normRateFee)).sub(tokensExc);
                    uint256 _amountETH = rest.div(rateUSD);
                    _claimsTKN[msg.sender] = _claimsTKN[msg.sender].sub(tokensExc);
                    _claimsETH[msg.sender] = _claimsETH[msg.sender].sub(_amountETH);
                    assert(token.transfer(msg.sender, amount)); 
                } else {
                    _claimsTKN[msg.sender] = _claimsTKN[msg.sender].sub(amount);
                    assert(token.transfer(msg.sender, amount)); 
                }
            } else {
                uint256 _amountETH = (amount.mul(proxy.base()).div(normRateFee)).div(rateUSD);
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

    function _withdrawETHpause() internal {
            uint256 amount = _claimsETH[msg.sender];
            _claimsETH[msg.sender] = 0;
            msg.sender.transfer(amount);
    }
}