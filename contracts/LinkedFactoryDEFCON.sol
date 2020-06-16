pragma solidity 0.5.11;

import './LinkedDEFCON.sol';

/** 
 *   Stable coin Linked - factory contract for the DEFCON contract
 */
contract LinkedFactoryDEFCON {
    
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
  function createDEFCONcontract() public returns (address){
    require(msg.sender == mainFactory, 'factory: no access');  
    LinkedDEFCON _defcon = new LinkedDEFCON();
    return address(_defcon);
  }  
  
  function initDEFCONcontract(address payable defcon, address payable init) public {
    require(msg.sender == mainFactory, 'factory: no access');  
    LinkedDEFCON _defcon = LinkedDEFCON(defcon);
    _defcon.initialize(init);
  }
}

  