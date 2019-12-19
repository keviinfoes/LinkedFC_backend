/** 
 *  Collateral contract for the linkedFC stablecoin.
 *  This contract enables opening a collateral position
 *  and minting tokens.
 * 
 */

pragma solidity ^0.5.0;
 
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./LinkedIPROXY.sol";
import "./LinkedICUST.sol";
import "./LinkedITAX.sol";

pragma solidity ^0.5.0;

contract LinkedCOL is Ownable {
    using SafeMath for uint256;
    
    struct userCP {
        uint256 amountETH;
        uint256 amountToken;
        uint256 liquidation;
        uint256 liqrange;
        uint256 liqid;
        bool closed;
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

    //Proxy address for system contracts
    IPROX public proxy;
    ITAX public tax;
    bool public initialized;
    //Collateral data
    totalData public tldata;
    uint256 public rate; 
    uint256 public minCol;
    uint256 public liqPer;
    uint256 public remFund;
    uint256 public base;

    event UpdateRate(uint256 Rate);
    event OpenCP(address account, uint256 id);
    event CloseCP(address account, uint256 id);
    event TransferCP(address sender, address receiver, uint256 id);

    /**
    * Set proxy address
    */
    function initialize(address _proxy) onlyOwner public returns (bool success) {
            require (initialized == false);
            require (_proxy != address(0));
            initialized = true;
            proxy = IPROX(_proxy);
            address _tax = proxy.readAddress()[4];
            tax = ITAX(_tax);
            minCol = 150;
            liqPer = 110;
            base = 10**18;
            return true;
    }
    
    modifier whenNotPaused() {
            require(!proxy.checkPause(), "Pausable: paused");
            _;
    }
  
    /**
    * @dev Fallback function. Makes the contract payable.
    */
    function() external payable {}
  
    /**
    *  @dev Updates the rate for a peg to 1 USD based on the oracle contract.
    */
    function updateRate(uint256 newRate) whenNotPaused public returns (bool success) {
            require(msg.sender == proxy.readAddress()[3], "Coll: not the oracle address");
            rate = newRate;
            emit UpdateRate(newRate);
            return true;
    }
    
    /**
    *  @dev Check balace of individual CPs - used by tax contract
    */
    function individualCPdata(address account, uint256 id) public view returns (uint256[3] memory) {
            uint256[3] memory _CPData;
            uint256 normRate = tax.viewNormRate();
            _CPData[0] = CP[account][id].amountETH;
            _CPData[1] = CP[account][id].amountToken.mul(base).div(normRate);
            //ADD CPData[2] == [open == 0 & closed == 1]
            return _CPData;
    }
       
    /**
    *  @dev Check variables of total CPs
    **/
    function dataTotalCP() public view returns (uint256[3] memory) {
            uint256[3] memory _totalData;
            uint256 normRate = tax.viewNormRate();
            _totalData[0] = tldata._totalCPs;
            _totalData[1] = tldata._supplyCPETH;
            _totalData[2] = tldata._supplyCPToken.mul(base).div(normRate);
            return _totalData;
    }
    
    /**
    *  @dev Open collateral position and generate tokens
    */
    function openCP(uint amount) whenNotPaused payable public returns (bool success) {
            uint256 normRate = tax.updateNormRate();
            uint256 normAmount = amount.mul(normRate).div(base);
            uint256 _index = index[msg.sender];
            uint256 liq = normAmount.div(msg.value).mul(minCol).div(100);
            uint256 liqGroup = liq.div(1000);
            _liqArrayAdd(liqGroup, _index);
            _openCP(_index, amount, normAmount, liq, liqGroup);
            emit OpenCP(msg.sender, _index);
            return true;
    }
    
    /**
    *  @dev Transfer collateral position to new user
    */
    function transfer(address recipient, uint256 id) whenNotPaused public returns (bool) {
			_transfer(msg.sender, recipient, id);
			emit TransferCP(msg.sender, recipient, id);
			return true;
	}

    /**
    *  @dev Deposit ETH in existing CP 
    */
    function depositETHCP(uint id) whenNotPaused payable public returns (bool success) {
            require(CP[msg.sender][id].amountETH > 0, "not an active collateral position");
            address payable custodian = proxy.readAddress()[2];
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
    *  @dev Witdraw ETH from existing CP || close CP when all of ETH is withdrawn
    */
    function withdrawETHCP(uint256 amount, uint id) whenNotPaused payable public returns (bool success) {
            require(CP[msg.sender][id].amountETH.sub(amount) >= 0, "not enough collateral");
            ICUST custodian = ICUST(proxy.readAddress()[2]);
            uint256 normRate = tax.updateNormRate();
            uint256 newAmountETH = CP[msg.sender][id].amountETH.sub(amount);
            uint256 amountNormTokens = CP[msg.sender][id].amountToken;
            uint256 amountTokens = amountNormTokens.mul(base).div(normRate); 
            uint256 liqGroup = CP[msg.sender][id].liqrange;
            uint256 liqId = CP[msg.sender][id].liqid;
            uint256 lastLigId = _LiqRange[liqGroup];
            _liqArrayDelete(liqGroup, liqId, lastLigId);
            if (newAmountETH == 0) {
                _closeCP(id, amount, amountTokens, amountNormTokens);
                //emit CloseCP(msg.sender, id);
            } else {
                uint256 liq = amountNormTokens.div(newAmountETH).mul(minCol).div(100);
                uint256 newliqGroup = liq.div(1000);
                _liqArrayAdd(newliqGroup, id);
                CP[msg.sender][id].liquidation = liq;
                CP[msg.sender][id].liqrange = newliqGroup;
                CP[msg.sender][id].liqid = _LiqRange[newliqGroup];
                CP[msg.sender][id].amountETH = newAmountETH;
                tldata._supplyCPETH = tldata._supplyCPETH.sub(amount);
            }
            assert(custodian.transfer(msg.sender, amount));
            return true;
    }
    
    /**
    *  @dev Burn tokens from existing CP holder 
    */
    function depositTokenCP(uint256 amount, uint id) whenNotPaused payable public returns (bool success) {
            ICUST custodian = ICUST(proxy.readAddress()[2]);
            IERC20 token = IERC20(proxy.readAddress()[0]);
            uint256 normRate = tax.updateNormRate();
            uint256 normAmount = amount.mul(normRate).div(base);
            uint256 newAmountTokens = CP[msg.sender][id].amountToken.sub(normAmount);
            uint256 AmountETH = CP[msg.sender][id].amountETH;
            uint256 liq = newAmountTokens.div(AmountETH).mul(minCol).div(100);
            uint256 liqId = CP[msg.sender][id].liqid;
            uint256 lastLigId = _LiqRange[CP[msg.sender][id].liqrange];
            uint256 newliqGroup = liq.div(1000);
            require(token.balanceOf(msg.sender) >= amount);
            require(rate > liq, "not enough collateral");
            tldata._supplyCPToken = tldata._supplyCPToken.sub(amount);
            _liqArrayDelete(CP[msg.sender][id].liqrange, liqId, lastLigId);
            _liqArrayAdd(newliqGroup, id);
            CP[msg.sender][id].liquidation = liq;
            CP[msg.sender][id].amountToken = newAmountTokens;
            CP[msg.sender][id].liqrange = newliqGroup;
            CP[msg.sender][id].liqid = _LiqRange[newliqGroup];
            assert(custodian.burn(msg.sender, amount));
            return true;
    }
    /**
    *  @dev Mint new tokens from existing CP 
    */
    function withdrawTokenCP(uint256 amount, uint id) whenNotPaused payable public returns (bool success) {
            ICUST custodian = ICUST(proxy.readAddress()[2]);
            uint256 normRate = tax.updateNormRate();
            uint256 newAmountTokens = CP[msg.sender][id].amountToken.add(amount.mul(normRate).div(base));
            uint256 AmountETH = CP[msg.sender][id].amountETH;
            uint256 liq = newAmountTokens.div(AmountETH).mul(minCol).div(100);
            uint256 liqGroup = CP[msg.sender][id].liqrange;
            uint256 liqId = CP[msg.sender][id].liqid;
            uint256 lastLigId = _LiqRange[liqGroup];
            uint256 newliqGroup = liq.div(1000);
            require(newAmountTokens > 0, "not enough tokens");
            require(rate > liq, "not enough collateral");
            tldata._supplyCPToken = tldata._supplyCPToken.add(amount);
            _liqArrayDelete(liqGroup, liqId, lastLigId);
            _liqArrayAdd(newliqGroup, id);
            CP[msg.sender][id].liquidation = liq;
            CP[msg.sender][id].amountToken = newAmountTokens;
            CP[msg.sender][id].liqrange = newliqGroup;
            CP[msg.sender][id].liqid = _LiqRange[newliqGroup];
            assert(custodian.mint(msg.sender, amount));
            return true;
    }

    /**
    *  @dev Liquidate existing CP if rate < 150% - discount for liquidator rest to original holder.
    *       If ETH is insufficient for the liquidation then the rest of the tokens will be reegistered 
    *       in the removal fund. For later removal - possible by ETH fee on token transfers.
    */
    function liquidateCP(address account, uint id) whenNotPaused payable public returns (bool success) {
            ICUST custodian = ICUST(proxy.readAddress()[2]);
            IERC20 token = IERC20(proxy.readAddress()[0]);
            uint256 normRate = tax.updateNormRate();
            uint256 amountETH = CP[account][id].amountETH;
            uint256 amountNormTokens = CP[account][id].amountToken;
            uint256 amountTokens = amountNormTokens.mul(base).div(normRate);
            uint256 liqGroup = CP[account][id].liqrange;
            uint256 liqId = CP[account][id].liqid;
            uint256 lastLigId = _LiqRange[liqGroup];
            require(CP[account][id].liquidation >= rate, "above liquidation rate");
            if (amountETH.mul(rate) >= amountNormTokens.mul(liqPer).div(100)) {
                uint256 amountLiquidator = amountTokens.div(rate).mul(liqPer).div(100);
                uint256 rest = amountETH.sub(amountLiquidator);
                require(token.balanceOf(msg.sender) >= amountTokens, "Collateral: > 110% | not enough tokens");
                _closeCP(id, amountETH, amountTokens, amountNormTokens);
                _liqArrayDelete(liqGroup, liqId, lastLigId);
                assert(custodian.transfer(msg.sender, amountLiquidator)); 
                assert(custodian.transfer(account, rest)); 
                return true;
            } else {
                uint256 availableToken = amountETH.mul(rate).mul(100).div(liqPer);
                require(token.balanceOf(msg.sender) >= availableToken, "Collateral: < 110% | not enough tokens");
                remFund =  amountTokens.sub(availableToken);
                _closeCP(id, amountETH, amountTokens, amountNormTokens);
                _liqArrayDelete(liqGroup, liqId, lastLigId);
                assert(custodian.transfer(msg.sender, amountETH)); 
                return false;
            }
    }

    /**
    *  @dev Internal functions called by the above functions.
    */
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
   
    function _openCP(uint256 _index, uint256 amount, uint256 normAmount, uint256 liq, uint256 liqGroup) internal {
            ICUST cust = ICUST(proxy.readAddress()[2]);
            address payable custodian = proxy.readAddress()[2];
            require(msg.value.mul(100) > amount.div(rate).mul(minCol), "not enough collateral");
            tldata = totalData({
                _totalCPs: tldata._totalCPs.add(1),
                _supplyCPETH: tldata._supplyCPETH.add(msg.value),
                _supplyCPToken: tldata._supplyCPToken.add(normAmount)
                });
            index[msg.sender] += 1;
            CP[msg.sender][_index].amountETH = msg.value;
            CP[msg.sender][_index].liquidation = liq;
            CP[msg.sender][_index].amountToken = normAmount;
            CP[msg.sender][_index].liqrange = liqGroup;
            CP[msg.sender][_index].liqid = _LiqRange[liqGroup];
            custodian.transfer(msg.value);
            assert(cust.mint(msg.sender, amount));
    }
    
    function _closeCP(uint256 id, uint256 amountETH, uint256 amountTokens, uint256 amountNormTokens) internal {
            ICUST custodian = ICUST(proxy.readAddress()[2]);
            IERC20 token = IERC20(proxy.readAddress()[0]);
            require(token.balanceOf(msg.sender) >= amountTokens, "not enough tokens");
            tldata = totalData({
                _totalCPs: tldata._totalCPs.sub(1),
                _supplyCPETH: tldata._supplyCPETH.sub(amountETH),
                _supplyCPToken: tldata._supplyCPToken.sub(amountNormTokens)
                });
            CP[msg.sender][id] = userCP({
                amountETH: 0,
                amountToken: 0,
                closed: true,
                liquidation: 0,
                liqrange: 0,
                liqid: 0
            });
            assert(custodian.burn(msg.sender, amountTokens));
    }
 
    function _transfer(address sender, address recipient, uint256 id) internal {
            uint256 amountETH = CP[sender][id].amountETH;
            uint256 amountToken = CP[sender][id].amountToken;
            uint256 liq = CP[sender][id].liquidation;
            uint256 liqRange = CP[sender][id].liqrange;
            uint256 liqID = CP[sender][id].liqid;
            uint256 _index = index[recipient];
            require(CP[sender][id].closed == false, "CP is closed");
            require(sender != address(0), "ERC20: transfer from the zero address");
			require(recipient != address(0), "ERC20: transfer to the zero address");
            _LiqInfo[liqRange][liqID].account = recipient;
            CP[sender][id] = userCP({
                amountETH: 0,
                amountToken: 0,
                closed: true,
                liquidation: 0,
                liqrange: 0,
                liqid: 0
            });
            index[recipient] += 1;
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