pragma solidity 0.5.11;

import './LinkedCUS.sol';

/** 
 *   Stable coin Linked - factory contract for the CUS contract
 */
contract LinkedFactoryCUS {
    
  address public mainFactory;
  bool public initialized;
  
  function initialize(address _mainFactory) 
    external returns (bool succes) {
    require(initialized != true);
    initialized = true;
    mainFactory = _mainFactory;
    return true;
  }
  
  /**
    * @dev Deploy a TrustlessFund contract.
  */
  function createCUScontract() public returns (address){
    require(msg.sender == mainFactory, 'factory: no access');  
    LinkedCUS _custodian  = new LinkedCUS();
    return address(_custodian);
  }  

  function initCUScontract(address payable custodian, address payable init) public {
    require(msg.sender == mainFactory, 'factory: no access');  
    LinkedCUS _custodian = LinkedCUS(custodian);
    _custodian.initialize(init);
  }
}

  