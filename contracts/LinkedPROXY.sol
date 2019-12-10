/** 
*   Stable coin Linked - proxy contracts.
*   contians the reference to the different contracts in 
*   the linked system.
*   
**/

pragma solidity ^0.5.0;

import "@openzeppelin/contracts/ownership/Ownable.sol";
import "@openzeppelin/contracts/lifecycle/Pausable.sol";

contract LinkedPROXY is Ownable, Pausable {
    
    address payable public token;
    address payable public collateral;
    address payable public custodian;
    address payable public oracle;
    address payable public tax;
    address payable public defcon;
    address payable public dev;
    bool public initialized;
    bool public defconActive;
    
    function initialize(address payable _token,
                        address payable _collateral,
                        address payable _custodian,
                        address payable _oracle,
                        address payable _tax,
                        address payable _defcon,
                        address payable _dev) 
        onlyOwner public returns (bool succes) {
            	require(initialized != true);
            	token = _token;
            	collateral = _collateral;
            	custodian = _custodian;
            	oracle = _oracle;
            	tax = _tax;
            	defcon = _defcon; 
            	dev = _dev;
            	initialized = true;
            	return true;                
    }
    
    function changeOracle(address payable _oracle) 
        onlyOwner public returns (bool success) {
           	oracle = _oracle;
           	return true;
    }
    
    function readAddress() public view returns (address payable[7] memory){
            	address payable[7] memory _address;
            	_address[0] = token;
            	_address[1] = collateral;
            	_address[2] = custodian;
            	_address[3] = oracle;
            	_address[4] = tax;
            	_address[5] = defcon;
            	_address[6] = dev;
            	return _address; 
    }
    
    function checkPause() public view returns (bool) {
        	return paused();
    }
    
    function activateDefcon() onlyOwner public returns (bool) {
        	defconActive = true;
        	return defconActive;
    }
}