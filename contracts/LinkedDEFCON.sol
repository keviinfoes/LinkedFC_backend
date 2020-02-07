pragma solidity 0.5.11;
 
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./IPROXY.sol";
import "./ICOL.sol"; 
import "./ICUS.sol";

/** 
 *  Emergency shutdown contract for the linked stablecoin 
 * 
 */
contract LinkedDEFCON is Ownable {
    using SafeMath for uint256;
    
    //Proxy address for system contracts
    IPROX public proxy;
    bool public initialized;
    
    //Totals CP and tokens
    uint256 public totalETH;
    uint256 public cpTokens;
    uint256 public userTokens;
    uint256 public totalTokens;

    //Mapping CP claimed;
    mapping (address => mapping (uint256 => bool)) private claimedCP;

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
    function initialize(address proxyAddress) onlyOwner external returns (bool success) {
            require (initialized == false);
            require (proxyAddress != address(0));
            initialized = true;
            proxy = IPROX(proxyAddress);
            return true;
    }
    
    function setDefcon() onlyDefcon external returns (bool success) {
            IERC20 token = IERC20(proxy.readAddress()[0]);
            ICOL collateral = ICOL(proxy.readAddress()[1]);            
            ICUS custodian = ICUS(proxy.readAddress()[2]);
            //Call devclaim to add tokens tot total
            token.devClaim();
            //Set total ETH to divide
            totalETH = address(custodian).balance;
            //Set normalised total tokens CP
            uint256[3] memory _totalData = collateral.dataTotalCP();
            cpTokens = _totalData[2];
            //Set normalised total tokens Users
            userTokens = token.gettotalSupply();
            totalTokens = userTokens.add(cpTokens);
            return true;
    }
    
    /**
     * Claim ETH during defcon for token holders
     */
    function defconClaimUser() onlyDefcon external returns (bool success){
            IERC20 token = IERC20(proxy.readAddress()[0]);  
            ICUS custodian = ICUS(proxy.readAddress()[2]);
            uint256 amountTokens = token.balanceOf(msg.sender);
            uint256 amountClaim = amountTokens.mul(totalETH).div(totalTokens);
            assert(custodian.burn(msg.sender, amountTokens));
            assert(custodian.transfer(msg.sender, amountClaim)); 
            return true;
    }
    
    /**
     * Claim ETH during defcon for CP holders
     */
    function defconClaimCP(uint256 id) external returns (bool success){
            require(claimedCP[msg.sender][id] == false, "Defcon: already claimed");
	        claimedCP[msg.sender][id] = true;
	        ICOL collateral = ICOL(proxy.readAddress()[1]);
            ICUS custodian = ICUS(proxy.readAddress()[2]);
            uint256[2] memory _CPData = collateral.individualCPdata(msg.sender, id);
            uint256 amountTokens = _CPData[1];
            uint256 amountClaim = amountTokens.mul(totalETH).div(totalTokens);
            assert(custodian.transfer(msg.sender, amountClaim)); 
            return true;
    }
}