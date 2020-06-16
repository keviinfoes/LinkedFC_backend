pragma solidity 0.5.11;

import './LinkedTAX.sol';

/** 
 *   Stable coin Linked - factory contract for the TAX contract
 */
contract LinkedFactoryTAX {
    
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
  function createTAXcontract() public returns (address){
    require(msg.sender == mainFactory, 'factory: no access');  
    LinkedTAX _tax = new LinkedTAX();
    return address(_tax);
  }  

  function initTAXcontract(address payable taxation, address payable init) public {
    require(msg.sender == mainFactory, 'factory: no access');  
    LinkedTAX _taxation = LinkedTAX(taxation);
    _taxation.initialize(init);
  }
}

  