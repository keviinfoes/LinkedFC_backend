pragma solidity 0.5.11;

import './LinkedEXC.sol';

/** 
 *   Stable coin Linked - factory contract for the DEFCON contract
 */
contract LinkedFactoryEXC {
    
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
  function createEXCcontract() public returns (address){
    require(msg.sender == mainFactory, 'factory: no access');  
    LinkedEXC _exchange = new LinkedEXC();
    return address(_exchange);
  }  

  function initEXCcontract(address payable exchange, address payable init) public {
    require(msg.sender == mainFactory, 'factory: no access');  
    LinkedEXC _exchange = LinkedEXC(exchange);
    _exchange.initialize(init);
  }
}

  