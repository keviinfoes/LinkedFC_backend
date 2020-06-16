pragma solidity 0.5.11;

import "@openzeppelin/contracts/lifecycle/Pausable.sol";

/** 
 *   Stable coin Linked - proxy contracts.
 *   contains the reference to the different contracts in 
 *   the linked system.  
 */
contract LinkedPROXY is Pausable {
    
        address public _owner;
        //System address variables
        address payable public token;
        address payable public collateral;
        address payable public custodian;
        address payable public oracle;
        address payable public tax;
        address payable public defcon;
        address payable public exchange;
        address payable public dev;
        //Initiation variables 
        bool public initialized;
        uint256 public startBlock;
        //Prime variables
        uint256 public rate;
        uint256 public base;
        bool public defconActive;
    
        event UpdateRate(uint256 Rate);
    
        /**
        * @dev Throws if called by any account other than the owner.
        */
        modifier onlyOwner() {
                require(msg.sender == _owner, "Ownable: caller is not the owner");
                _;
        }


        function initialize(address payable tokenAddress,
                        address payable collateralAddress,
                        address payable custodianAddress,
                        address payable oracleAddress,
                        address payable taxAddress,
                        address payable defconAddress,
                        address payable exchangeAddress,
                        address payable devAddress) 
             external returns (bool succes) {
                require(initialized != true);
                token = tokenAddress;
                collateral = collateralAddress;
                custodian = custodianAddress;
                oracle = oracleAddress;
                tax = taxAddress;
                defcon = defconAddress;
                exchange = exchangeAddress;
                dev = devAddress;
                initialized = true;
                startBlock = block.number;
                base = 10**18;
                _owner = devAddress;
                return true;                
        }
    
        function changeOracle(address payable oracleAddress) 
            onlyOwner external returns (bool success) {
                oracle = oracleAddress;
                return true;
        }
    
        function readAddress() external view returns (address payable[8] memory){
                address payable[8] memory _address;
                _address[0] = token;
                _address[1] = collateral;
                _address[2] = custodian;
                _address[3] = oracle;
                _address[4] = tax;
                _address[5] = defcon;
                _address[6] = exchange;
                _address[7] = dev;
                return _address; 
        }
    
        function checkPause() external view returns (bool) {
                return paused();
        }
    
        /**
         *  @dev Updates the rate for a peg to 1 USD based on the oracle contract.
         */
        function updateRate(uint256 newRate) whenNotPaused external returns (bool success) {
                require(msg.sender == oracle, "Proxy: not the oracle address");
                rate = newRate;
                
                emit UpdateRate(newRate);
                return true;
        }
    
        function updateStartBlock(uint256 newBlock) whenNotPaused external returns (bool success) {
                require(msg.sender == tax, "Proxy: not the tax address");
                require(newBlock > startBlock, "Proxy: newBlock lower then current startblock");
                startBlock = newBlock;
                return true;
        }
        
        /**
         *  @dev Activate defcon for emergency shutdown.
         */
        function activateDefcon() onlyOwner external returns (bool) {
                defconActive = true;
	        Pausable.pause();
                return defconActive;
        }
}