pragma solidity 0.5.11;

import './LinkedTKN.sol';

/** 
 *   Stable coin Linked - factory contract for the TKN contract
 */
contract LinkedFactoryTKN {
    
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
  function createTKNcontract() public returns (address){
    require(msg.sender == mainFactory, 'factory: no access');  
    LinkedTKN _token = new LinkedTKN();
    return address(_token);
  }

  function initTKNcontract(address payable token, address payable init) public {
    require(msg.sender == mainFactory, 'factory: no access');  
    LinkedTKN _token = LinkedTKN(token);
    _token.initialize(init);
  }

}

  