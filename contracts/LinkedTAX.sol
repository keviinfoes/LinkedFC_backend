/**
*   Oracle contract for the linked stablecoin.
*   The contract uses the decentralized oracle chainlink
**/

pragma solidity ^0.5.0;

import "@openzeppelin/contracts/ownership/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./LinkedICOL.sol";
import "./LinkedIPROXY.sol";

/** 
*
*   Stable coin Linked - stability tax distribution contract.
*   
**/

contract LinkedTAX is Ownable {
    using SafeMath for uint256;
    
    //Proxy address for system contracts
    IPROX public proxy;
    bool public initialized;
    //Variables for the normalisation calculation
    uint256 public normRate;
	uint256 public baseRate;
	
    /**
    * @dev Set proxy address
    */
    function initialize(address _proxy) onlyOwner public returns (bool success) {
            require (initialized == false);
            require (_proxy != address(0));
            initialized = true;
            proxy = IPROX(_proxy);
            baseRate = 1000000006609610000;             // 1.00000000660961 * 10^18 ~= 1.5% per year 
            return true;
    }
    
    /**
	* @dev Update the normalisation rate for the stability fee decuction.
    **/
    function viewNormRate() public view returns (uint256) {
            uint256 startBlockNum = proxy.startBlock();
	        uint256 newBlockNum = block.number;
	        uint256 blockDiff = newBlockNum.sub(startBlockNum);
            uint256 tempnormRate = baseRate.rpow(blockDiff, 10**18);            
            return tempnormRate;
    }
    
    /**
	* @dev Update the normalisation rate for the stability fee decuction.
    **/
    function updateNormRate() public returns (uint256) {
            _updateNormRate();
            return normRate;
    }
    
    /**
	* @dev Update the normalisation rate for the stability fee decuction. 
	* Uses the `safe` rpow for power calculation.
    **/
	function _updateNormRate() internal {
	        uint256 startBlockNum = proxy.startBlock();
	        uint256 newBlockNum = block.number;
	        uint256 blockDiff = newBlockNum.sub(startBlockNum);
            normRate = baseRate.rpow(blockDiff, 10**18); // 10^18 because baserate is in 10^18 representation 
	}
}