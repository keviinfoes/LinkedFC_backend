pragma solidity 0.5.11;

import './LinkedPROXY.sol';
import './LinkedFactoryTKN.sol';
import './LinkedFactoryCOL.sol';
import './LinkedFactoryCUS.sol';
import './LinkedFactoryTAX.sol';
import './LinkedFactoryORCL.sol';
import './LinkedFactoryDEFCON.sol';
import './LinkedFactoryEXC.sol';

/** 
 *   Stable coin Linked - factory contract.
 *   New linked assets can be deployed by this factory contract.
 *   This contract also holds the registry for the deployed contracts.
 */
contract LinkedFactory {

  /**
    * @notice Struct for assets
  */
  struct Asset {
      address asset;
      address token;
      address collateral;
      address custodian;
      address oracle;
      address tax;
      address defcon;
      address exchange;
    }

  /**
    * @notice Mappings for assets
  */
  mapping(uint => Asset) public assets;
 
  /**
    * @notice Variables initialization
  */
  bool public initialized;
  address public token;
  address public collateral;
  address public custodian;
  address public oracle;
  address public tax;
  address public defcon;
  address public exchange;
  
  /**
    * @notice Index for total assets used as ID
  */
  uint public id;

  /**
    * @notice Emits when an asset is created.
  */
  event CreateAsset(address proxy, address creator);

  //Set factory addresses
  function initialize(address tokenAddress,
                  address collateralAddress,
                  address custodianAddress,
                  address oracleAddress,
                  address taxAddress,
                  address defconAddress,
                  address exchangeAddress) 
     external returns (bool succes) {
        require(initialized != true);
        initialized = true;
        token = tokenAddress;
        collateral = collateralAddress;
        custodian = custodianAddress;
        oracle = oracleAddress;
        tax = taxAddress;
        defcon = defconAddress;
        exchange = exchangeAddress;
        return true;                
  }

  /**
    * @dev Given an id, return the corresponding asset address.
    * @param _id The id of the asset.
  */
  function getAsset(uint _id) public view returns(address) {
    return assets[_id].asset;
  }

  /**
    * @dev Deploy a TrustlessFund contract.
  */
  function createAsset() public {
    require(assets[id].asset == address(0), 'factory: is already in use');
    //Deploy contracts for linked asset
    LinkedPROXY _asset = new LinkedPROXY();
    //Adjust pauser from factory to creator msg.sender
    _asset.addPauser(msg.sender);
    _asset.renouncePauser();
    //Calls the factory for the different contracts and returns the address
    address _token = LinkedFactoryTKN(token).createTKNcontract();
    address _collateral = LinkedFactoryCOL(collateral).createCOLcontract();
    address _custodian = LinkedFactoryCUS(custodian).createCUScontract();
    address _oracle = LinkedFactoryORCL(oracle).createORCLcontract();
    address _tax = LinkedFactoryTAX(tax).createTAXcontract();
    address _defon = LinkedFactoryDEFCON(defcon).createDEFCONcontract();
    address _exchange = LinkedFactoryEXC(exchange).createEXCcontract();
    //Initialize linked asset proxy
    _asset.initialize(
      address(uint160(_token)),
      address(uint160(_collateral)),
      address(uint160(_custodian)),
      address(uint160(_oracle)),
      address(uint160(_tax)),
      address(uint160(_defon)),
      address(uint160(_exchange)),
      msg.sender
    );
    //Initialize other system contracts
    address payable init = address(uint160(address(_asset)));
    LinkedFactoryTKN(token).initTKNcontract(address(uint160(_token)), init);
    LinkedFactoryCOL(collateral).initCOLcontract(address(uint160(_collateral)), init);
    LinkedFactoryCUS(custodian).initCUScontract(address(uint160(_custodian)), init);
    LinkedFactoryORCL(oracle).initORCLcontract(address(uint160(_oracle)), init);
    LinkedFactoryTAX(tax).initTAXcontract(address(uint160(_tax)), init);
    LinkedFactoryDEFCON(defcon).initDEFCONcontract(address(uint160(_defon)), init);
    LinkedFactoryEXC(exchange).initEXCcontract(address(uint160(_exchange)), init);

    //Register deployment of linked asset here
    assets[id] = Asset({
      asset: address(_asset),
      token: address(_token),
      collateral: address(_collateral),
      custodian: address(_custodian),
      oracle: address(_oracle),
      tax: address(_tax),
      defcon: address(_defon),
      exchange: address(_exchange)
    });
    id++;
    emit CreateAsset(address(_asset), msg.sender);
  }
}

  