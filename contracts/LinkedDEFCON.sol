/** 
 *  Emergency shutdown contract for the linked stablecoin 
 * 
 */

pragma solidity ^0.5.0;
 
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./LinkedIPROXY.sol";
import "./LinkedICOL.sol";
import "./LinkedICUST.sol";

contract LinkedDEFCON is Ownable {
    using SafeMath for uint256;
    
    //Proxy address for system contracts
    IPROX public proxy;
    bool public initialized;
    //Total pools for claims
    uint256 public rateClaim;
    uint256 public poolToken;
    uint256 public poolCP;
    //Mapping CP claimed;
    mapping (address => mapping (uint256 => bool)) public claimedCP;

    /**
     *  @dev Throws if called by any account other than the owner.
     */
    modifier onlyDefcon() {
            require(proxy.defconActive() == true, "Proxy: defcon is not active");
            _;
    }
    
    /**
    *   @dev Set proxy address
    */
    function initialize(address _proxy) onlyOwner public returns (bool success) {
            require (initialized == false);
            require (_proxy != address(0));
            initialized = true;
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
    
    /**
    * Claim ETH during defcon for token holders
    */
    function defconClaimUser() onlyDefcon public returns (bool success){
            IERC20 token = IERC20(proxy.readAddress()[0]);  
            ICUST custodian = ICUST(proxy.readAddress()[2]);
            uint256 amountTokens = token.balanceOf(msg.sender);
            uint256 amountClaim = amountTokens.div(rateClaim);
            assert(custodian.burn(msg.sender, amountTokens));
            assert(custodian.transfer(msg.sender, amountClaim)); 
            return true;
    }
    
    /**
    * Claim ETH during defcon for CP holders
    */
    function defconClaimCP(uint256 id) public returns (bool success){
            ICOL collateral = ICOL(proxy.readAddress()[1]);
            ICUST custodian = ICUST(proxy.readAddress()[2]);
            uint256[2] memory _CPData = collateral.individualCPdata(msg.sender, id);
            uint256[3] memory _CPTotalData = collateral.dataTotalCP();
            uint256 amountETH = _CPData[0];
            uint256 amountTotalETH = _CPTotalData[1];
            uint256 amountClaim = amountETH.mul(poolCP).div(amountTotalETH);
            require(claimedCP[msg.sender][id] == false, "Defcon: already claimed");
            claimedCP[msg.sender][id] == true;
            assert(custodian.transfer(msg.sender, amountClaim)); 
            return true;
    }
}