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
    uint256 public _blockTax = 3; // 3% per year
    uint256 public _blockYear = 2000000; // ~2 million blocks per year

    /**
    * @dev Set proxy address
    */
    function initialize(address _proxy) onlyOwner public returns (bool success) {
            require (initialized == false);
            require (_proxy != address(0));
            proxy = IPROX(_proxy);
            initialized = true;
            return true;
    }
    
    /**
    * @dev balanceOf claim for individuald CP holder
    */
    function balanceOfInterest(address claimer, uint256 idCP) public view returns (uint256) {
            ICOL collateral = ICOL(proxy.readAddress()[1]);
            uint256[3] memory cpDetails = collateral.individualCPdata(claimer, idCP);
            uint256 balanceTokens = cpDetails[1];
            uint256 blockDiff = block.number.sub(cpDetails[2]);
            uint256 balanceClaim = blockDiff.mul(balanceTokens).div(_blockYear).div(100).mul(_blockTax);
            return balanceClaim;
    }
    
    /**
    * @dev claim tax reserve to taxAuthority address
    */
    function claimTaxReserve() onlyOwner public returns (bool success) {
            IERC20 token = IERC20(proxy.readAddress()[0]);
            token.taxClaim();
            return true;
    }
    
    /**
    * @dev claim interest by CP holders
    */
    function claimInterest(address receiver, uint256 id) public returns (bool success) {
            IERC20 token = IERC20(proxy.readAddress()[0]);
            uint256 interest = balanceOfInterest(receiver, id);
            require (token.balanceOf(address(this)).sub(interest) > 0);
            assert(token.transfer(msg.sender, interest));
            return true;
    }
}