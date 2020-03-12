pragma solidity 0.5.11;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./ICOL.sol"; 
import "./IPROXY.sol";

/**
 *   Tax contract for the linked stablecoin.
 *   Contains the stability tax data.
 */
contract LinkedTAX {
    using SafeMath for uint256;
    
        //Proxy address for system contracts
        IPROX public proxy;
        bool public initialized;
        //Variables for the normalisation calculation
        uint256 public baseRateReward;
	uint256 public baseRateFee;
        uint256 public additionReward;
        uint256 public additionFee;
        uint256 public liquidationCorrection;
	
        /**
         * @dev Set proxy address
         */
        function initialize(address proxyAddress) external returns (bool success) {
                require (initialized == false);
                require (proxyAddress != address(0));
                initialized = true;
                proxy = IPROX(proxyAddress);
                baseRateReward = 1000000006609610000;             //initial 1.00000000660961 * 10^18 ~= 1.5% per year 
                baseRateFee = 1000000008791120000;             //initial 1.00000000879112 * 10^18 ~= 2% per year
                return true;
        }
        
        /**
         *  @dev Throws if called by any account other than the owner.
         */
        modifier owners() {
                require(msg.sender == proxy.owner(), "Proxy: pause is active");
                _;
        }

        /**
	 * @dev Update the normalisation rate for the stability fee decuction.
         */
        function viewNormRateReward() external view returns (uint256) {
                uint256 startBlockNum = proxy.startBlock();
	        uint256 newBlockNum = block.number;
	        uint256 blockDiff = newBlockNum.sub(startBlockNum);
                uint256 tempnormRate = baseRateReward.rpow(blockDiff, 10**18).add(additionReward).sub(liquidationCorrection);            
                return tempnormRate;
        }
    
        function viewNormRateFee() external view returns (uint256) {
                uint256 startBlockNum = proxy.startBlock();
	        uint256 newBlockNum = block.number;
	        uint256 blockDiff = newBlockNum.sub(startBlockNum);
                uint256 tempnormRate = baseRateFee.rpow(blockDiff, 10**18).add(additionFee);            
                return tempnormRate;
        }

        function updateNormRate(uint256 _baseRateReward, uint256 _baseRateFee) owners external returns (bool success) {
                proxy.updateStartBlock(block.number); 
                additionReward = additionReward.add(baseRateReward.sub(10**18));
                additionFee = additionFee.add(baseRateFee.sub(10**18));
                baseRateReward = _baseRateReward;
                baseRateFee = _baseRateFee;
                return true;
        }

        function adjustLiqCorrection(uint256 amount) external returns (bool success) {
                address collateral = proxy.readAddress()[1];
                require(msg.sender == collateral, "Proxy: pause is active");
                liquidationCorrection = liquidationCorrection.add(amount);
                return true;
        }        
}