pragma solidity 0.5.11;

import "@openzeppelin/contracts/ownership/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./ICOL.sol"; 
import "./IPROXY.sol";

/**
 *   Tax contract for the linked stablecoin.
 *   Contains the stability tax data.
 */
contract LinkedTAX is Ownable {
    using SafeMath for uint256;
    
    //Proxy address for system contracts
    IPROX public proxy;
    bool public initialized;
    //Variables for the normalisation calculation
	uint256 public baseRateReward;
	uint256 public baseRateFee;
	
	
    /**
     * @dev Set proxy address
     */
    function initialize(address proxyAddress) onlyOwner external returns (bool success) {
            require (initialized == false);
            require (proxyAddress != address(0));
            initialized = true;
            proxy = IPROX(proxyAddress);
            baseRateReward = 1000000006609610000;             //initial 1.00000000660961 * 10^18 ~= 1.5% per year 
            baseRateFee = 1000000008791120000;             //initial 1.00000000879112 * 10^18 ~= 2% per year
            return true;
    }
    
    /**
	 * @dev Update the normalisation rate for the stability fee decuction.
     */
    function viewNormRateReward() external view returns (uint256) {
            uint256 startBlockNum = proxy.startBlock();
	        uint256 newBlockNum = block.number;
	        uint256 blockDiff = newBlockNum.sub(startBlockNum);
            uint256 tempnormRate = baseRateReward.rpow(blockDiff, 10**18);            
            return tempnormRate;
    }
    
    function viewNormRateFee() external view returns (uint256) {
            uint256 startBlockNum = proxy.startBlock();
	        uint256 newBlockNum = block.number;
	        uint256 blockDiff = newBlockNum.sub(startBlockNum);
            uint256 tempnormRate = baseRateFee.rpow(blockDiff, 10**18);            
            return tempnormRate;
    }
}