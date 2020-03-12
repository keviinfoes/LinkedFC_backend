pragma solidity 0.5.11;
 
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./IPROXY.sol";
import "./ICOL.sol"; 
import "./ICUS.sol";
import "./IEXC.sol";

/** 
 *  Emergency shutdown contract for the linked stablecoin 
 * 
 */
contract LinkedDEFCON {
    using SafeMath for uint256;
    
    //Proxy address for system contracts
    IPROX public proxy;
    bool public initialized;
    //Totals CP and tokens
    uint256 public totalETH;
    uint256 public totalETHusr;
    uint256 public totalETHcp;
    uint256 public userTokens;
    uint256 public userTokensnorm;
    //Totals claimed
    uint256 public claimedETH;
    uint256 public claimedTKN;
    //Safety rate
    uint256 public safe;

    //Mapping claimed accounts ;
    mapping (address => bool) private claimedUSR;
    mapping (address => bool) private claimedEXC;
    mapping (address => bool) private claimedCP;

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
    function initialize(address proxyAddress) external returns (bool success) {
            require (initialized == false);
            require (proxyAddress != address(0));
            initialized = true;
            proxy = IPROX(proxyAddress);
            return true;
    }
    
    /**
     *  @dev Set variables for defcon
     */
    function setDefcon() onlyDefcon external returns (bool success) {
            IERC20 token = IERC20(proxy.readAddress()[0]);
            ICUS custodian = ICUS(proxy.readAddress()[2]);
            //Call devclaim to add tokens to total
            token.devClaim();
            //Set total ETH to divide
            totalETH = address(custodian).balance;
            //Set normalised total tokens Users
            userTokensnorm = token.totalSupply();
            //Set non-normalised total tokens Users
            userTokens = token.gettotalSupply();
            //Calculate rate and divide ether
            uint256 rate = proxy.rate();
            safe = totalETH.mul(rate);
            if (safe > userTokens) {
                totalETHusr = userTokens.div(rate);
                totalETHcp = totalETH.sub(totalETHusr);
            } else {
                totalETHusr = totalETH;
                totalETHcp = 0;
            } 
            return true;
    }
    
    /**
     *  @dev Claim ETH during defcon for token holders
     */
    function defconClaimUser() onlyDefcon external returns (bool success){
            require(claimedUSR[msg.sender] == false, "Defcon: already claimed");
            IERC20 token = IERC20(proxy.readAddress()[0]);  
            ICUS custodian = ICUS(proxy.readAddress()[2]);
            uint256 amountTokens = token._balances(msg.sender);
            uint256 amountClaim = amountTokens.mul(totalETHusr).div(userTokensnorm);
            claimedUSR[msg.sender] = true;
            claimedTKN = claimedTKN.add(amountTokens);
            claimedETH = claimedETH.add(amountClaim);
            assert(custodian.transfer(msg.sender, amountClaim)); 
            return true;
    }

     function defconClaimExc() onlyDefcon external returns (bool success){  
            require(claimedEXC[msg.sender] == false, "Defcon: already claimed");
            ICUS custodian = ICUS(proxy.readAddress()[2]);
            IEXC exchange = IEXC(proxy.readAddress()[6]);
            uint256 amountTokens = exchange._claimsTKN(msg.sender);
            uint256 amountClaim = amountTokens.mul(totalETHusr).div(userTokensnorm);
            claimedEXC[msg.sender] = true;
            claimedTKN = claimedTKN.add(amountTokens);
            claimedETH = claimedETH.add(amountClaim);
            assert(custodian.transfer(msg.sender, amountClaim)); 
            return true;
    }
    
    /**
     *  @dev Claim ETH during defcon for CP holders
     */
    function defconClaimCP(uint256 id) onlyDefcon external returns (bool success){
            require(claimedCP[msg.sender] == false, "Defcon: already claimed");
	    ICOL collateral = ICOL(proxy.readAddress()[1]);
            ICUS custodian = ICUS(proxy.readAddress()[2]);
            uint256[5] memory _CPData = collateral.cPosition(msg.sender, id); 
            uint256[3] memory _CPTotal = collateral.tldata();
            uint256 amounTotalCPeth = _CPTotal[1];
            uint256 amountclaim = _CPData[0].mul(totalETHcp).div(amounTotalCPeth);
            require(amountclaim > 0, "claim is zero");
            claimedCP[msg.sender] = true;
            claimedETH = claimedETH.add(amountclaim);
            assert(custodian.transfer(msg.sender, amountclaim)); 
            return true;
    }
}