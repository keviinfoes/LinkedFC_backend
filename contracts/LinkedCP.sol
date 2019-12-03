/** 
 *  Collateral contract for the linkedFC stablecoin.
 *  This contract enables opening a collateral position
 *  and minting tokens.
 * 
 *  TODO    
 *          - ADD SHUTDOWN OPTION
 *          - ADD PAYMENT FOR ORACLE CONTRACT
 */

pragma solidity ^0.5.0;
 
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/lifecycle/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./LinkedICUST.soL";

contract LinkedCOL is Pausable {
    using SafeMath for uint256;
  
    IERC20 public token;
    ICUST public cust;
    address public owner;
    address public oracle;
    address payable public custodian;
    
    struct userCP {
        uint256 amountETH;
        uint256 amountToken;
        bool closed;
        uint256 liquidation;
        uint256 liqrange;
        uint256 liqid;
    }
    struct overviewCP {
        uint256 id;
        address account;
    }
    struct totalData {
        uint256 _totalCPs;
        uint256 _supplyCPETH;
        uint256 _supplyCPToken;
    }
    
    mapping (address => uint256) public index; 
    mapping (address => mapping (uint256 => userCP)) public CP; 
    mapping (uint256 => uint256) public _LiqRange;
    mapping (uint256 => mapping(uint256 => overviewCP)) public _LiqInfo;

    totalData public tldata;
    uint256 public rate; 
    uint256 public minCol;
    uint256 public liqPer;
    uint256 public remFund;

    event UpdateRate(uint256 Rate);
    event OpenCP(address account, uint256 id);
    event CloseCP(address account, uint256 id);
    event TransferCP(address sender, address receiver, uint256 id);
    
     /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
            require(msg.sender == owner, "Ownable: caller is not the owner");
            _;
    }   
 
    /**
    * constructor
    */
    constructor() public {
            owner = msg.sender;
            minCol = 150;
            liqPer = 110;
    }
  
    /**
    * Fallback function. Used to load the exchange with ether
    */
    function() external payable {}
  
    /**
    * Set oracle address
    */
    function changeContractAddress(address OracleAddress, address tokenAddress, address payable custodianAddress) 
        onlyOwner public returns (bool success) {
            require (OracleAddress != address(0));
            require (tokenAddress != address(0));
            require (custodianAddress != address(0));
            oracle = OracleAddress;
            token = IERC20(tokenAddress);
            custodian = custodianAddress;
            cust = ICUST(custodianAddress);
            return true;
    }
    /**
    *  Updates the rate for a peg to 1 USD based on the oracle contract.
    */
    function updateRate(uint newRate) whenNotPaused public returns (bool success) {
            require(msg.sender == oracle);
            rate = newRate;
            emit UpdateRate(newRate);
            return true;
    }
    
    /**
    *  Check balace of individual CPs
    */
    function balanceETHCP(address account, uint256 id) public view returns (uint256) {
            uint256 amountETH = CP[account][id].amountETH;
            return amountETH;
    }
    function balanceTokenCP(address account, uint256 id) public view returns (uint256) {
            uint256 amountToken = CP[account][id].amountToken;
            return amountToken;
    }
       
    /**
    *  Check variables of total CPs
    **/
    function dataTotalCP() public view returns (uint256[3] memory) {
            uint256[3] memory _totalData;
            _totalData[0] = tldata._totalCPs;
            _totalData[1] = tldata._supplyCPETH;
            _totalData[1] = tldata._supplyCPToken;
            return _totalData;
    }
    
    /**
    *  Check if CP liquidation is possible 
    */
    function liquidationCheckCP(address account, uint256 id) public view returns (bool) {
            if (rate < CP[account][id].liquidation) {
            return true;
            } else return false;
    }
    
    /**
    *  Open collateral position and generate tokens
    */
    function openCP(uint amount) whenNotPaused payable public returns (bool success) {
            uint256 _index = index[msg.sender];
            uint256 liq = amount.div(msg.value).mul(minCol).div(100);
            uint256 liqGroup = liq.div(1000);
            _liqArrayAdd(liqGroup, _index);
            _openCP(_index, amount, liq, liqGroup);
            emit OpenCP(msg.sender, _index);
            return true;
    }
    
    /**
    *  Close collateral position and generate ETH
    */
    function closeCP(uint id) whenNotPaused payable public returns (bool success) {
            uint256 amountETH = CP[msg.sender][id].amountETH;
            uint256 amountTokens = CP[msg.sender][id].amountToken;
            uint256 liqGroup = CP[msg.sender][id].liqrange;
            uint256 liqId = CP[msg.sender][id].liqid;
            uint256 lastLigId = _LiqRange[liqGroup];
            _liqArrayDelete(liqGroup, liqId, lastLigId);
            _closeCP(id, amountETH, amountTokens);
            assert(cust.transfer(msg.sender, amountETH));
            emit CloseCP(msg.sender, id);
            return true;
    }
    
    function transfer(address recipient, uint256 id) whenNotPaused public returns (bool) {
			_transfer(msg.sender, recipient, id);
			emit TransferCP(msg.sender, recipient, id);
			return true;
	}

    /**
    *  Deposit ETH in existing CP 
    */
    function despositETHCP(uint id) whenNotPaused payable public returns (bool success) {
            require(CP[msg.sender][id].amountETH > 0, "not an active collateral position");
            uint256 newAmountETH = CP[msg.sender][id].amountETH.add(msg.value);
            uint256 AmountTokens = CP[msg.sender][id].amountToken;
            uint256 liq = AmountTokens.div(newAmountETH).mul(minCol).div(100);
            uint256 liqGroup = CP[msg.sender][id].liqrange;
            uint256 liqId = CP[msg.sender][id].liqid;
            uint256 lastLigId = _LiqRange[liqGroup];
            uint256 newliqGroup = liq.div(1000);
            tldata._supplyCPETH = tldata._supplyCPETH.add(msg.value);
            _liqArrayDelete(liqGroup, liqId, lastLigId);
            _liqArrayAdd(newliqGroup, id);
            CP[msg.sender][id].liquidation = liq;
            CP[msg.sender][id].amountETH = CP[msg.sender][id].amountETH.add(msg.value);
            CP[msg.sender][id].liqrange = newliqGroup;
            CP[msg.sender][id].liqid = _LiqRange[newliqGroup];
            custodian.transfer(msg.value);
            return true;
    }
    /**
    *  Witdraw ETH from existing CP 
    */
    function withdrawETHCP(uint256 amount, uint id) whenNotPaused payable public returns (bool success) {
            require(CP[msg.sender][id].amountETH.sub(amount) >= 0, "not enough collateral");
            uint256 newAmountETH = CP[msg.sender][id].amountETH.sub(amount);
            uint256 AmountTokens = CP[msg.sender][id].amountToken;
            uint256 liq = AmountTokens.div(newAmountETH).mul(minCol).div(100);
            uint256 liqGroup = CP[msg.sender][id].liqrange;
            uint256 liqId = CP[msg.sender][id].liqid;
            uint256 lastLigId = _LiqRange[liqGroup];
            uint256 newliqGroup = liq.div(1000);
            require(rate > liq, "not enough collateral");
            tldata._supplyCPETH = tldata._supplyCPETH.sub(amount);
            _liqArrayDelete(liqGroup, liqId, lastLigId);
            _liqArrayAdd(newliqGroup, id);
            CP[msg.sender][id].liquidation = liq;
            CP[msg.sender][id].amountETH = newAmountETH;
            CP[msg.sender][id].liqrange = newliqGroup;
            CP[msg.sender][id].liqid = _LiqRange[newliqGroup];
            assert(cust.transfer(msg.sender, amount));
            return true;
    }
    /**
    *  Deposit(burn) tokens from existing CP 
    */
    function depositTokenCP(uint256 amount, uint id) whenNotPaused payable public returns (bool success) {
            require(token.balanceOf(msg.sender) >= amount);
            uint256 newAmountTokens = CP[msg.sender][id].amountToken.add(amount);
            uint256 AmountETH = CP[msg.sender][id].amountETH;
            uint256 liq = newAmountTokens.div(AmountETH.mul(minCol).div(100));
            uint256 liqGroup = CP[msg.sender][id].liqrange;
            uint256 liqId = CP[msg.sender][id].liqid;
            uint256 lastLigId = _LiqRange[liqGroup];
            uint256 newliqGroup = liq.div(1000);
            require(rate > liq, "not enough collateral");
            tldata._supplyCPToken = tldata._supplyCPToken.sub(amount);
            _liqArrayDelete(liqGroup, liqId, lastLigId);
            _liqArrayAdd(newliqGroup, id);
            CP[msg.sender][id].liquidation = liq;
            CP[msg.sender][id].amountToken = newAmountTokens;
            CP[msg.sender][id].liqrange = newliqGroup;
            CP[msg.sender][id].liqid = _LiqRange[newliqGroup];
            assert(cust.burn(msg.sender, amount));
            return true;
    }
    /**
    *  Witdraw(mint) tokens from existing CP 
    */
    function withdrawTokenCP(uint256 amount, uint id) whenNotPaused payable public returns (bool success) {
            uint256 newAmountTokens = CP[msg.sender][id].amountToken.sub(amount);
            uint256 AmountETH = CP[msg.sender][id].amountETH;
            require(newAmountTokens > 0, "not enough tokens");
            uint256 liq = newAmountTokens.div(AmountETH.mul(minCol).div(100));
            uint256 liqGroup = CP[msg.sender][id].liqrange;
            uint256 liqId = CP[msg.sender][id].liqid;
            uint256 lastLigId = _LiqRange[liqGroup];
            uint256 newliqGroup = liq.div(1000);
            require(rate > liq, "not enough collateral");
            tldata._supplyCPToken = tldata._supplyCPToken.add(amount);
            _liqArrayDelete(liqGroup, liqId, lastLigId);
            _liqArrayAdd(newliqGroup, id);
            CP[msg.sender][id].liquidation = liq;
            CP[msg.sender][id].amountToken = newAmountTokens;
            CP[msg.sender][id].liqrange = newliqGroup;
            CP[msg.sender][id].liqid = _LiqRange[newliqGroup];
            assert(cust.mint(msg.sender, amount));
            return true;
    }

    /**
    *  Liquidate(mint) existing CP - discount for liquidator rest to original holder
    *
    */
    function liquidateCP(address account, uint id) whenNotPaused payable public returns (bool success) {
            require(CP[account][id].liquidation.mul(100) > rate.mul(minCol), "above liquidation rate");
            uint256 amountETH = CP[account][id].amountETH;
            uint256 amountTokens = CP[account][id].amountToken;
            uint256 liqGroup = CP[account][id].liqrange;
            uint256 liqId = CP[account][id].liqid;
            uint256 lastLigId = _LiqRange[liqGroup];
            if (amountTokens.mul(100) >= amountETH.mul(rate.mul(liqPer))) {
                uint256 amountLiquidator = amountTokens.div(rate).mul(liqPer).div(100);
                uint256 rest = amountETH.sub(amountLiquidator);
                require(token.balanceOf(msg.sender) >= amountTokens, "not enough tokens");
                assert(cust.burn(msg.sender, amountTokens));
                assert(cust.transfer(msg.sender, amountLiquidator)); 
                assert(cust.transfer(account, rest)); 
            } else {
                uint256 availableToken = amountETH.mul(rate).mul(100).div(liqPer);
                require(token.balanceOf(msg.sender) >= availableToken, "not enough tokens");
                assert(cust.burn(msg.sender, amountTokens));
                assert(cust.transfer(msg.sender, amountETH)); 
                remFund =  amountTokens.sub(amountTokens);
            }
            _closeCP(id, amountETH, amountTokens);
            _liqArrayDelete(liqGroup, liqId, lastLigId);
            return true;
    }

    function _openCP(uint256 _index, uint256 amount, uint256 liq, uint256 liqGroup) internal {
    require(msg.value.mul(100) > amount.div(rate).mul(minCol), "not enough collateral");
            tldata = totalData({
                _totalCPs: tldata._totalCPs.add(1),
                _supplyCPETH: tldata._supplyCPETH.add(msg.value),
                _supplyCPToken: tldata._supplyCPToken.add(amount)
                });
            index[msg.sender] += 1;
            CP[msg.sender][_index].amountETH = msg.value;
            CP[msg.sender][_index].liquidation = liq;
            CP[msg.sender][_index].amountToken = amount;
            CP[msg.sender][_index].liqrange = liqGroup;
            CP[msg.sender][_index].liqid = _LiqRange[liqGroup];
            custodian.transfer(msg.value);
            assert(cust.mint(msg.sender, amount));
    }
    
    function _closeCP(uint256 id, uint256 amountETH, uint256 amountTokens) internal {
            require(token.balanceOf(msg.sender) >= amountTokens, "not enough tokens");
            tldata = totalData({
                _totalCPs: tldata._totalCPs.sub(1),
                _supplyCPETH: tldata._supplyCPETH.sub(amountETH),
                _supplyCPToken: tldata._supplyCPToken.sub(amountTokens)
                });
            CP[msg.sender][id] = userCP({
                amountETH: 0,
                amountToken: 0,
                closed: true,
                liquidation: 0,
                liqrange: 0,
                liqid: 0
            });
            assert(cust.burn(msg.sender, amountTokens));
    }
   
    function _liqArrayAdd(uint256 newliqGroup, uint256 id) internal {
            _LiqRange[newliqGroup] = _LiqRange[newliqGroup].add(1);
            _LiqInfo[newliqGroup][_LiqRange[newliqGroup]].id = id;
            _LiqInfo[newliqGroup][_LiqRange[newliqGroup]].account = msg.sender;
    }
    
    function _liqArrayDelete(uint256 _group, uint256 _id, uint256 _lastId) internal {
            overviewCP memory lastLigInfo = _LiqInfo[_group][_lastId];
            _LiqRange[_group] = _LiqRange[_group].sub(1);
            _LiqInfo[_group][_id] = lastLigInfo;
            delete _LiqInfo[_group][_lastId];
            CP[lastLigInfo.account][lastLigInfo.id].liqid = _id;
    }
 
    function _transfer(address sender, address recipient, uint256 id) internal {
            require(CP[sender][id].closed = false, "CP is closed");
            require(sender != address(0), "ERC20: transfer from the zero address");
			require(recipient != address(0), "ERC20: transfer to the zero address");
            CP[sender][id].closed = true;
            uint256 amountETH = CP[sender][id].amountETH;
            uint256 amountToken = CP[sender][id].amountToken;
            uint256 liq = CP[sender][id].liquidation;
            uint256 liqRange = CP[sender][id].liqrange;
            uint256 liqID = CP[sender][id].liqid;
            uint256 _index = index[recipient];
            _LiqInfo[liqRange][liqID].account = recipient;
            CP[sender][_index] = userCP({
                amountETH: 0,
                amountToken: 0,
                closed: true,
                liquidation: 0,
                liqrange: 0,
                liqid: 0
            });
            CP[recipient][_index] = userCP({
                amountETH: amountETH,
                amountToken: amountToken,
                closed: false,
                liquidation: liq,
                liqrange: liqRange,
                liqid: liqID
            });
    }
}
 