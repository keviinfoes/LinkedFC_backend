pragma solidity 0.5.11;

import './LinkedCOL.sol';

/** 
 *   Stable coin Linked - factory contract for the COL contract
 */
contract LinkedFactoryCOL {
    
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
  function createCOLcontract() public returns (address){
    require(msg.sender == mainFactory, 'factory: no access');  
    LinkedCOL _collateral = new LinkedCOL();
    return address(_collateral);
  }  
  
  function initCOLcontract(address payable collateral, address payable init) public {
    require(msg.sender == mainFactory, 'factory: no access');  
    LinkedCOL _collateral = LinkedCOL(collateral);
    _collateral.initialize(init);
  }
}

  