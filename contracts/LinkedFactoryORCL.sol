pragma solidity 0.5.11;

import './LinkedORCL.sol';

/** 
 *   Stable coin Linked - factory contract for the ORCL contract
 */
contract LinkedFactoryORCL {
    
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
  function createORCLcontract() public returns (address){
    require(msg.sender == mainFactory, 'factory: no access');  
    LinkedORCL _oracle  = new LinkedORCL();
    return address(_oracle);
  }  
  
  function initORCLcontract(address payable oracle, address payable init) public {
    require(msg.sender == mainFactory, 'factory: no access');  
    LinkedORCL _oracle = LinkedORCL(oracle);
    _oracle.initialize(init);
  }
}

  