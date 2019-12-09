/** 
 *  Emergency shutdown contract for the linked stablecoin 
 * 
 *  TODO - ADD EMERGENCY CLAIM FOR USERS
 */

pragma solidity ^0.5.0;
 
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";

import "./LinkedIPROXY.sol";
import "./LinkedICOL.sol";

contract LinkedDEFCON is Ownable {
    using SafeMath for uint256;
    
    //Proxy address for system contracts
    IPROX public proxy;
    bool public initialized;
    //Total pools for claims
    uint256 public rateClaim;
    uint256 public poolToken;
    uint256 public poolCP;
    
    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyDefcon() {
        require(proxy.defcon() == true, "Proxy: defcon is not active");
        _;
    }
    
    /**
    * Set proxy address
    */
    function initialize(address _proxy) onlyOwner public returns (bool success) {
            require (initialized == false);
            require (_proxy != address(0));
            proxy = IPROX(_proxy);
            return true;
    }
    
    function setDefcon() onlyDefcon public returns (bool success) {
            ICOL collateral = ICOL(proxy.readAddress()[1]);            
            uint256[3] memory _totalData = collateral.dataTotalCP();
            rateClaim = collateral.rate();
            poolToken = _totalData[1].div(rateClaim);
            poolCP = _totalData[2].sub(poolToken);
            return true;
    }
    
    
    
    
    //TODO  ADD BURN TOKENS AND TRANSFER ETH USER FUNCTION
    //      ADD DETERMINE AMOUNT -> CLOSE CP AND TRANSFER ETH ->
    
    /**
    * Claim ETH during defcon for token holders
    */
    function defconClaimUser() public pure returns (bool success){
            
            return true;
    }
    
    /**
    * Claim ETH during defcon for CP holders
    */
    function defconClaimCP() public pure returns (bool success){
            
            return true;
    }
}