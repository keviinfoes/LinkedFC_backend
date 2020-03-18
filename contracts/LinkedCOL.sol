pragma solidity 0.5.11;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";

import "./IPROXY.sol";
import "./ICUS.sol";
import "./ITAX.sol";

/** 
 *  Collateral contract for the linkedFC stablecoin.
 *  This contract enables opening a collateral position
 *  and minting tokens.
 * 
 */
contract LinkedCOL {
    using SafeMath for uint256;
    
    struct UserCP {
        uint256 amountETH;
        uint256 amountToken;
        uint256 liquidation;
        uint256 liqrange;
        uint256 liqid;
    }
    struct OverviewCP {
        uint256 id;
        address account;
    }
    struct TotalData {
        uint256 _totalCPs;
        uint256 _supplyCPETH;
        uint256 _supplyCPToken;
    }
    
    mapping (address => uint256) public index; 
    mapping (address => mapping (uint256 => UserCP)) public cPosition; 
    mapping (uint256 => uint256) public liqRange;
    mapping (uint256 => mapping(uint256 => OverviewCP)) public liqInfo;

    //Proxy address for system contracts
    IPROX public proxy;
    ITAX public tax;
    bool public initialized;
    //Collateral data
    TotalData public tldata;
    uint256 public minCol;
    uint256 public liqPer;

    event OpenCP(address account, uint256 id);
    event CloseCP(address account, uint256 id);
    event TransferCP(address sender, address receiver, uint256 id);

    /**
     * Set proxy address
     */
    function initialize(address proxyAddress) external returns (bool success) {
            require (initialized == false);
            require (proxyAddress != address(0));
            initialized = true;
            proxy = IPROX(proxyAddress);
            address taxAddress = proxy.readAddress()[4];
            tax = ITAX(taxAddress);
            minCol = 150;
            liqPer = 110;
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
     *  @dev Check balace of individual CPs - used by tax contract
     */
    function individualCPdata(address account, uint256 id) external view returns (uint256[2] memory) {
            uint256[2] memory _CPData;
            uint256 normRateReward = tax.viewNormRateReward();
            _CPData[0] = cPosition[account][id].amountETH;
            _CPData[1] = cPosition[account][id].amountToken.mul(proxy.base()).div(normRateReward);
            return _CPData;
    }
       
    /**
     *  @dev Check variables of total CPs
     */
    function dataTotalCP() public view returns (uint256[3] memory) {
            uint256[3] memory _totalData;
            uint256 normRateReward = tax.viewNormRateReward();
            _totalData[0] = tldata._totalCPs;
            _totalData[1] = tldata._supplyCPETH;
            _totalData[2] = tldata._supplyCPToken.mul(proxy.base()).div(normRateReward);
            return _totalData;
    }
    
    /**
     *  @dev Open collateral position and generate tokens
     */
    function openCP(uint amount) whenNotPaused payable external returns (bool success) {
            uint256[7] memory info = _getCPdata(msg.sender, 0);
            uint256 normAmount = amount.mul(info[1]).div(proxy.base());
            uint256 liq = normAmount.div(msg.value).mul(minCol).div(100);
            uint256 liqGroup = liq.div(1000);
            _liqArrayAdd(liqGroup, info[0]);
            _openCP(info[0], amount, normAmount, liq, liqGroup);
            return true;
    }
    
    /**
     *  @dev Transfer collateral position to new user
     */
    function transfer(address recipient, uint256 id) whenNotPaused external returns (bool success) {
			_transfer(msg.sender, recipient, id);
			emit TransferCP(msg.sender, recipient, id);
			return true;
	}

    /**
     *  @dev Deposit ETH in existing CP 
     */
    function depositETHCP(uint id) whenNotPaused payable external returns (bool success) {
            require(cPosition[msg.sender][id].amountETH > 0, "not an active collateral position");
            uint256[7] memory info = _getCPdata(msg.sender, id);
            address payable custodian = proxy.readAddress()[2];
            uint256 newAmountETH = info[2].add(msg.value);
            uint256 liq = info[3].div(newAmountETH).mul(minCol).div(100);
            uint256 newliqGroup = liq.div(1000);
            tldata._supplyCPETH = tldata._supplyCPETH.add(msg.value);
            _liqArrayDelete(info[4], info[5], info[6]);
            _liqArrayAdd(newliqGroup, id);
            cPosition[msg.sender][id].liquidation = liq;
            cPosition[msg.sender][id].amountETH = newAmountETH;
            cPosition[msg.sender][id].liqrange = newliqGroup;
            cPosition[msg.sender][id].liqid = liqRange[newliqGroup];
            custodian.transfer(msg.value);
            return true;
    }
    /**
     *  @dev Witdraw ETH from existing CP || close CP when all of ETH is withdrawn
     */
    function withdrawETHCP(uint256 amount, uint id) whenNotPaused payable external returns (bool success) {
            require(cPosition[msg.sender][id].amountETH.sub(amount) >= 0, "not enough collateral");
            ICUS custodian = ICUS(proxy.readAddress()[2]);
            IERC20 token = IERC20(proxy.readAddress()[0]);
            uint256[7] memory info = _getCPdata(msg.sender, id);
            uint256 newAmountETH = info[2].sub(amount);
            uint256 amountTokens = (info[3].mul(proxy.base())).div(info[1]); 
            _liqArrayDelete(info[4], info[5], info[6]);
            if (newAmountETH == 0) {
                require(token.balanceOf(msg.sender) >= amountTokens, "not enough tokens");
                _closeCP(id, msg.sender, amount, info[3]);
                assert(custodian.burn(msg.sender, amountTokens));
                emit CloseCP(msg.sender, id);
            } else {
                uint256 liq = info[3].div(newAmountETH).mul(minCol).div(100);
                uint256 newliqGroup = liq.div(1000);
                _liqArrayAdd(newliqGroup, id);
                cPosition[msg.sender][id].liquidation = liq;
                cPosition[msg.sender][id].liqrange = newliqGroup;
                cPosition[msg.sender][id].liqid = liqRange[newliqGroup];
                cPosition[msg.sender][id].amountETH = newAmountETH;
                tldata._supplyCPETH = tldata._supplyCPETH.sub(amount);
            }
            assert(custodian.transfer(msg.sender, amount));
            return true;
    }
    
    /**
     *  @dev Burn tokens from existing CP holder 
     */
    function depositTokenCP(uint256 amount, uint id) whenNotPaused payable external returns (bool success) {
            ICUS custodian = ICUS(proxy.readAddress()[2]);
            IERC20 token = IERC20(proxy.readAddress()[0]);
            uint256[7] memory info = _getCPdata(msg.sender, id);
            uint256 normAmount = amount.mul(info[1]).div(proxy.base());
            uint256 newAmountTokens = info[3].sub(normAmount);
            uint256 liq = newAmountTokens.div(info[2]).mul(minCol).div(100);
            uint256 newliqGroup = liq.div(1000);
            require(token.balanceOf(msg.sender) >= amount);
            require(proxy.rate() > liq.mul(proxy.base()).div(info[1]), "not enough collateral");
            tldata._supplyCPToken = tldata._supplyCPToken.sub(normAmount);
            _liqArrayDelete(info[4], info[5], info[6]);
            _liqArrayAdd(newliqGroup, id);
            cPosition[msg.sender][id].liquidation = liq;
            cPosition[msg.sender][id].amountToken = newAmountTokens;
            cPosition[msg.sender][id].liqrange = newliqGroup;
            cPosition[msg.sender][id].liqid = liqRange[newliqGroup];
            assert(custodian.burn(msg.sender, amount));
            return true;
    }
    /**
     *  @dev Mint new tokens from existing CP 
     */
    function withdrawTokenCP(uint256 amount, uint id) whenNotPaused payable external returns (bool success) {
            ICUS custodian = ICUS(proxy.readAddress()[2]);
            uint256[7] memory info = _getCPdata(msg.sender, id);
            uint256 normAmount = amount.mul(info[1]).div(proxy.base());
            uint256 newAmountTokens = info[3].add(normAmount);
            uint256 liq = newAmountTokens.div(info[2]).mul(minCol).div(100);
            uint256 newliqGroup = liq.div(1000);
            require(newAmountTokens > 0, "not enough tokens");
            require(proxy.rate() > liq, "not enough collateral");
            tldata._supplyCPToken = tldata._supplyCPToken.add(normAmount);
            _liqArrayDelete(info[4], info[5], info[6]);
            _liqArrayAdd(newliqGroup, id);
            cPosition[msg.sender][id].liquidation = liq;
            cPosition[msg.sender][id].amountToken = newAmountTokens;
            cPosition[msg.sender][id].liqrange = newliqGroup;
            cPosition[msg.sender][id].liqid = liqRange[newliqGroup];
            assert(custodian.mint(msg.sender, normAmount));
            return true;
    }

    /**
     *  @dev Liquidate existing CP if rate < 150% - discount for liquidator rest to original holder.
     *       If ETH is insufficient for the liquidation then the rest of the tokens will be reegistered 
     *       in the removal fund. For later removal - possible by ETH fee on token transfers.
    */
    function liquidateCP(address account, uint id) whenNotPaused payable external returns (bool success) {
            ICUS custodian = ICUS(proxy.readAddress()[2]);
            IERC20 token = IERC20(proxy.readAddress()[0]);
            uint256[7] memory info = _getCPdata(msg.sender, id);
            uint256 amountTokens = info[3].mul(proxy.base()).div(info[1]);
            require(cPosition[account][id].liquidation.mul(proxy.base()).div(info[1]) >= proxy.rate(), "above liquidation rate");
            if (info[2].mul(proxy.rate()) >= amountTokens.mul(liqPer).div(100)) {
                uint256 amountLiquidator = amountTokens.div(proxy.rate()).mul(liqPer).div(100);
                uint256 rest = info[2].sub(amountLiquidator);
                require(token.balanceOf(msg.sender) >= amountTokens, "Collateral: > 110% | not enough tokens");
                _liqArrayDelete(info[4], info[5], info[6]);
		_closeCP(id, account, info[2], info[3]); 
                assert(custodian.burn(msg.sender, amountTokens));
                assert(custodian.transfer(account, rest));
                assert(custodian.transfer(msg.sender, amountLiquidator)); 
                return true;
            } else {
                uint256 availableToken = info[2].mul(proxy.rate()).mul(100).div(liqPer);
                uint256 availableTokenNorm = availableToken.mul(info[1]).div(proxy.base());
                require(token.balanceOf(msg.sender) >= availableToken, "Collateral: < 110% | not enough tokens");
                //Adjust the normrate reward if token burn < debt burned to increase debt of other collateral holders
                _liqArrayDelete(info[4], info[5], info[6]);
		_closeCP(id, account, info[2], info[3]);
                if (availableTokenNorm < info[3]) {
                        uint256 tokendiff = amountTokens.sub(availableToken);
                        uint256[3] memory totalData = dataTotalCP();
                        uint256 newTotal = totalData[2].add(tokendiff);
                        uint256 totalNorm = tldata._supplyCPToken;
                        uint256 normRateReward = tax.viewNormRateReward();
                        //Calculate adjustment to normRatReward to increase debt of collateral holders  
                        uint256 newNormRateReward = totalNorm.mul(proxy.base()).div(newTotal);
                        uint256 normAdditionAdjust = normRateReward.sub(newNormRateReward);
                        assert(tax.adjustLiqCorrection(normAdditionAdjust));         
                }
                assert(custodian.burn(msg.sender, availableToken));
                assert(custodian.transfer(msg.sender, info[2])); 
                return true;
            }
    }
    
    /**
     *  @dev Internal functions called by the above functions.
     */
    function _getCPdata(address ownerCP, uint256 id) internal view returns (uint256[7] memory){
            uint256[7] memory _getCPData;
            uint256 _index = index[ownerCP];
            uint256 normRateReward = tax.viewNormRateReward();
            uint256 amountETH = cPosition[ownerCP][id].amountETH;
            uint256 amountTokens = cPosition[ownerCP][id].amountToken;
            uint256 liqGroup = cPosition[ownerCP][id].liqrange;
            uint256 liqId = cPosition[ownerCP][id].liqid;
            uint256 lastLigId = liqRange[liqGroup];
            _getCPData = [_index, 
                          normRateReward, 
                          amountETH, 
                          amountTokens,
                          liqGroup,
                          liqId,
                          lastLigId];
            return _getCPData;
    }
    
    function _liqArrayAdd(uint256 newliqGroup, uint256 id) internal {
            liqRange[newliqGroup] = liqRange[newliqGroup].add(1);
            liqInfo[newliqGroup][liqRange[newliqGroup]].id = id;
            liqInfo[newliqGroup][liqRange[newliqGroup]].account = msg.sender;
    }
    
    function _liqArrayDelete(uint256 _group, uint256 _id, uint256 _lastId) internal {
            OverviewCP memory lastLigInfo = liqInfo[_group][_lastId];
            liqRange[_group] = liqRange[_group].sub(1);
            liqInfo[_group][_id] = lastLigInfo;
            delete liqInfo[_group][_lastId];
            cPosition[lastLigInfo.account][lastLigInfo.id].liqid = _id;
    }
   
    function _openCP(uint256 _index, uint256 amount, uint256 normAmount, uint256 liq, uint256 liqGroup) internal {
            ICUS cust = ICUS(proxy.readAddress()[2]);
            address payable custodian = proxy.readAddress()[2];
            require(msg.value.mul(100) > amount.div(proxy.rate()).mul(minCol), "not enough collateral");
            tldata = TotalData({
                _totalCPs: tldata._totalCPs.add(1),
                _supplyCPETH: tldata._supplyCPETH.add(msg.value),
                _supplyCPToken: tldata._supplyCPToken.add(normAmount)
                });
            index[msg.sender] += 1;
            cPosition[msg.sender][_index].amountETH = msg.value;
            cPosition[msg.sender][_index].liquidation = liq;
            cPosition[msg.sender][_index].amountToken = normAmount;
            cPosition[msg.sender][_index].liqrange = liqGroup;
            cPosition[msg.sender][_index].liqid = liqRange[liqGroup];
            emit OpenCP(msg.sender, _index);
	    custodian.transfer(msg.value);
            assert(cust.mint(msg.sender, amount));
    }
    
    function _closeCP(uint256 id, address account, uint256 amountETH, uint256 amountNormTokens) internal {
            tldata = TotalData({
                _totalCPs: tldata._totalCPs.sub(1),
                _supplyCPETH: tldata._supplyCPETH.sub(amountETH),
                _supplyCPToken: tldata._supplyCPToken.sub(amountNormTokens)
                });
            cPosition[account][id] = UserCP({
                amountETH: 0,
                amountToken: 0,
                liquidation: 0,
                liqrange: 0,
                liqid: 0
            });
    }
 
    function _transfer(address sender, address recipient, uint256 id) internal {
            uint256[7] memory info = _getCPdata(msg.sender, id);
            uint256 liq = cPosition[sender][id].liquidation;
            require(sender != address(0), "ERC20: transfer from the zero address");
	    require(recipient != address(0), "ERC20: transfer to the zero address");
            cPosition[sender][id] = UserCP({
                amountETH: 0,
                amountToken: 0,
                liquidation: 0,
                liqrange: 0,
                liqid: 0
            });
	        uint256 tempindex = index[recipient];
            liqInfo[info[4]][info[5]].account = recipient;
            liqInfo[info[4]][info[5]].id = tempindex;
            index[recipient] += 1;
            cPosition[recipient][tempindex] = UserCP({
                amountETH: info[2],
                amountToken: info[3],
                liquidation: liq,
                liqrange: info[4],
                liqid: info[5]
            });      
    }
}