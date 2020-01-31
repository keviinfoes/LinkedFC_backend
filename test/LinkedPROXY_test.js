const LinkedPROXY = artifacts.require("LinkedPROXY");
const LinkedTKN = artifacts.require("LinkedTKN");
const LinkedCOL = artifacts.require("LinkedCOL");
const LinkedCUS = artifacts.require("LinkedCUS");
const LinkedORCL = artifacts.require("LinkedORCL");
const LinkedTAX = artifacts.require("LinkedTAX");
const LinkedDEFCON = artifacts.require("LinkedDEFCON");
const LinkedEXC = artifacts.require("LinkedEXC");
const truffleAssert = require('truffle-assertions');
const BN = require('bn.js');

//Console log the addresses of the deployed contracts
contract('LinkedPROXY', async accounts => {
	let PROXY;
	let TOKEN;	
	let COLLATERAL;
	let CUSTODIAN;
	let ORACLE;
	let TAXATION;
	let DEFCON;
	let EXCHANGE;
		
	before(async() => {
		PROXY = await LinkedPROXY.deployed();
		TOKEN = await LinkedTKN.deployed();	
		COLLATERAL = await LinkedCOL.deployed();
		CUSTODIAN = await LinkedCUS.deployed();
		ORACLE = await LinkedORCL.deployed();
		TAXATION = await LinkedTAX.deployed();
		DEFCON = await LinkedDEFCON.deployed();
		EXCHANGE = await LinkedEXC.deployed();
		await PROXY.initialize(TOKEN.address,
						 COLLATERAL.address,
						 CUSTODIAN.address,
						 ORACLE.address,
						 TAXATION.address,
						 DEFCON.address,
						 EXCHANGE.address,
						 accounts[0]
						);	
		await TOKEN.initialize(PROXY.address);	
		await COLLATERAL.initialize(PROXY.address);
		await CUSTODIAN.initialize(PROXY.address);
		await ORACLE.initialize(PROXY.address);
		await TAXATION.initialize(PROXY.address);
		await DEFCON.initialize(PROXY.address);
		await EXCHANGE.initialize(PROXY.address);
	});
	describe('Initialize', function () {
		//Initialize proxy contract and check successful initialization
		it("Proxy contract initialized", async () => {
			let active = await PROXY.initialized.call();
			let token = await PROXY.token.call();
			let collateral = await PROXY.collateral.call();
			let custodian = await PROXY.custodian.call();
			let oracle = await PROXY.oracle.call();
			let tax = await PROXY.tax.call();
			let defcon = await PROXY.defcon.call();
			let exchange = await PROXY.exchange.call();
			let dev = await PROXY.dev.call();
			
			/* PRINT ADDRESSES
			console.log("PROXY address: " + PROXY.address);
			console.log("TOKEN address: " + TOKEN.address);
			console.log("COLLATERAL address: " + COLLATERAL.address);
			console.log("CUSTODIAN address: " + CUSTODIAN.address);
			console.log("ORACLE address: " + ORACLE.address);
			console.log("TAXATION address: " + TAXATION.address);
			console.log("DEFCON address: " + DEFCON.address);
			console.log("EXCHANGE address: " + EXCHANGE.address);
			*/

			assert.equal(active, true, "Initialized is not called");
			assert.equal(token, TOKEN.address, "Token initialized address does not match");
			assert.equal(collateral, COLLATERAL.address, "Collateral initialized address does not match");
			assert.equal(custodian, CUSTODIAN.address, "Custodian initialized address does not match");
			assert.equal(oracle, ORACLE.address, "Oracle initialized address does not match");
			assert.equal(tax, TAXATION.address, "Taxation initialized address does not match");
			assert.equal(defcon, DEFCON.address, "Defcon initialized address does not match");
			assert.equal(exchange, EXCHANGE.address, "Exchange initialized address does not match");
			assert.equal(dev, accounts[0], "Dev initialized address does not match");		
		});
		//Initialize other contracts and check successful initialization
		it("Other contracts initialized", async () => {
			let activeTKN = await TOKEN.initialized.call();
			assert.equal(activeTKN, true, "Initialized TOKEN is not called");
			let activeCOL = await COLLATERAL.initialized.call();
			assert.equal(activeCOL, true, "Initialized COLLATERAL is not called");
			let activeCUS = await CUSTODIAN.initialized.call();
			assert.equal(activeCUS, true, "Initialized CUSTODIAN is not called");
			let activeORC = await ORACLE.initialized.call();
			assert.equal(activeORC, true, "Initialized ORACLE is not called");
			let activeTAX = await TAXATION.initialized.call();
			assert.equal(activeTAX, true, "Initialized TAXATION is not called");
			let activeDEFCON = await DEFCON.initialized.call();
			assert.equal(activeDEFCON, true, "Initialized DEFCON is not called");
			let activeEXC = await EXCHANGE.initialized.call();
			assert.equal(activeEXC, true, "Initialized EXCHANGE is not called");
		});
		//readAddress check 
		it("Read address check", async () => {
			let readAddressOutput = await PROXY.readAddress.call();
			assert.equal(TOKEN.address, readAddressOutput[0], "Readaddress TOKEN is not called");
			assert.equal(COLLATERAL.address, readAddressOutput[1], "Readaddress COLLATERAL is not called");
			assert.equal(CUSTODIAN.address, readAddressOutput[2], "Readaddress CUSTODIAN is not called");
			assert.equal(ORACLE.address, readAddressOutput[3], "Readaddress ORACLE is not called");
			assert.equal(TAXATION.address, readAddressOutput[4], "Readaddress TAXATION is not called");
			assert.equal(DEFCON.address, readAddressOutput[5], "Readaddress DEFCON is not called");
			assert.equal(EXCHANGE.address, readAddressOutput[6], "Readaddress EXCHANGE is not called");		
		});
	});

	describe('Oracle', function () {
		//Change oracle and check succes
		it("Change oracle", async () => {
			await PROXY.changeOracle('0x79C4077CB6af3112aCF4B298f4B5B40b7f596b7D');
			let newOracle = await PROXY.oracle.call();
			assert.equal(newOracle, '0x79C4077CB6af3112aCF4B298f4B5B40b7f596b7D', "changeOracle is not called");	
			await PROXY.changeOracle(ORACLE.address);			
		});
	});
	describe('Pause contracts', function () {
		//readAddress check 
		it("Pause contract check", async () => {
			await PROXY.pause();
			let paused = await PROXY.checkPause.call();
			assert.equal(paused, true, "Pause is not called");
			let priceUpdate = await truffleAssert.reverts(ORACLE.updateRate(10000));		
			await PROXY.unpause()
			let unpaused = await PROXY.checkPause.call();
			assert.equal(unpaused, false, "unPause is not called");	
		});
	});
})

contract('LinkedCOL', async accounts => {	
	let PROXY;
	let TOKEN;	
	let COLLATERAL;
	let CUSTODIAN;
	let ORACLE;
	let TAXATION;
	let DEFCON;
	let EXCHANGE;
		
	before(async() => {
		PROXY = await LinkedPROXY.deployed();
		TOKEN = await LinkedTKN.deployed();	
		COLLATERAL = await LinkedCOL.deployed();
		CUSTODIAN = await LinkedCUS.deployed();
		ORACLE = await LinkedORCL.deployed();
		TAXATION = await LinkedTAX.deployed();
		DEFCON = await LinkedDEFCON.deployed();
		EXCHANGE = await LinkedEXC.deployed();
		await PROXY.initialize(TOKEN.address,
						 COLLATERAL.address,
						 CUSTODIAN.address,
						 ORACLE.address,
						 TAXATION.address,
						 DEFCON.address,
						 EXCHANGE.address,
						 accounts[0]
						);
			
		await TOKEN.initialize(PROXY.address);	
		await COLLATERAL.initialize(PROXY.address);
		await CUSTODIAN.initialize(PROXY.address);
		await ORACLE.initialize(PROXY.address);
		await TAXATION.initialize(PROXY.address);
		await DEFCON.initialize(PROXY.address);
		await EXCHANGE.initialize(PROXY.address);
		await ORACLE.updateRate(20000);
	});
	describe('Open CP', async () => {
		//Initialize other contracts and check successful initialization
		it("Open Collateral Position account 0", async () => {	
			let amount = 20000000000000000000000;
			let amountETH = 2000000000000000000;
			await COLLATERAL.openCP(amount.toLocaleString('fullwide', { useGrouping: false }), {value: amountETH});
			let CP = await COLLATERAL.individualCPdata.call(accounts[0], 0);
			assert.equal(CP[0], amountETH, "Collateral in CP false account 0");
			assert.equal(CP[1], amount, "Tokens in CP false");
			let balance = await TOKEN.balanceOf.call(accounts[0]);
			assert.equal(balance, amount, "Balance token is different from CP account 0");
		});
		it("Open Collateral Position account 1", async () => {	
			let amount = 40000000000000000000000;
			let amountETH = 4000000000000000000;
			await COLLATERAL.openCP(amount.toLocaleString('fullwide', { useGrouping: false }), {from: accounts[1], value: amountETH});
			let CP = await COLLATERAL.individualCPdata.call(accounts[1], 0);
			assert.equal(CP[0], amountETH, "Collateral in CP false account 1");
			assert.equal(CP[1], amount, "Tokens in CP false");
			let balance = await TOKEN.balanceOf.call(accounts[1]);
			assert.equal(balance, amount, "Balance token is different from CP account 1");
		});
		it("Transfer Collateral Position account 0 -> 1", async () => {	
			let initial = await COLLATERAL.individualCPdata.call(accounts[0], 0);
			await COLLATERAL.transfer(accounts[1], 0);
			let user_0 = await COLLATERAL.individualCPdata.call(accounts[0], 0);
			let user_1 = await COLLATERAL.individualCPdata.call(accounts[1], 1);
			assert.equal(user_0[0], 0, "Transfer: CP sender not deducted");
			assert.equal(user_0[1], 0, "Transfer: CP sender not deducted");
			assert.equal(initial[0].toString(), user_1[0].toString(), "Transfer: receiver not added");
		});
	});	
	describe('Change CP', async () => {	
		it("Deposit ETH Collateral Position", async () => {	
			let amountETH = 4000000000000000000;
			let Position = await COLLATERAL.individualCPdata.call(accounts[1], 0);
			await COLLATERAL.depositETHCP(0, {from: accounts[1], value: amountETH});
			let check = Number(Position[0]) + Number(amountETH);
			let NEWPosition = await COLLATERAL.individualCPdata.call(accounts[1], 0);
			assert.equal(check.toString(), NEWPosition[0].toString(), "Change CP: deposit ETH not added");
		});
		it("Deposit Token Collateral Position", async () => {	
			let amountTOKEN = new BN("200000000000000000000");
			let Position = await COLLATERAL.cPosition.call(accounts[1], 0);
			let BNPosition = new BN(Position[1].toString());
			await COLLATERAL.depositTokenCP(amountTOKEN.toLocaleString('fullwide', { useGrouping: false }), 0, {from: accounts[1]});
			let Base = await PROXY.base.call();
			let BNBase = new BN(Base.toString());
			let RateReward = await TAXATION.viewNormRateReward.call();
			let BNRateReward = new BN(RateReward.toString());
			let Check = amountTOKEN.mul(BNRateReward).div(BNBase);
			let NewPositionCheck = BNPosition.sub(Check);
			let NEWPosition = await COLLATERAL.cPosition.call(accounts[1], 0);
			assert.equal(NEWPosition[1].toString(), NewPositionCheck.toString(), "Change CP: deposit Token not deducted");
		});
		it("Withdraw ETH Collateral Position", async () => {	
			let amountETH = 2000000000000000000;
			let Position = await COLLATERAL.individualCPdata.call(accounts[1], 0);
			await COLLATERAL.withdrawETHCP(amountETH.toLocaleString('fullwide', { useGrouping: false }), 0, {from: accounts[1]});
			let check = Number(Position[0]) - Number(amountETH);
			let NEWPosition = await COLLATERAL.individualCPdata.call(accounts[1], 0);
			assert.equal(check.toString(), NEWPosition[0].toString(), "Change CP: withdraw ETH not deducted");
		});
		it("Withdraw Token Collateral Position", async () => {	
			let amountTOKEN = new BN("200000000000000000000");
			let Position = await COLLATERAL.cPosition.call(accounts[1], 0);
			let BNPosition = new BN(Position[1].toString());
			await COLLATERAL.withdrawTokenCP(amountTOKEN.toLocaleString('fullwide', { useGrouping: false }), 0, {from: accounts[1]});
			let Base = await PROXY.base.call();
			let BNBase = new BN(Base.toString());
			let RateReward = await TAXATION.viewNormRateReward.call();
			let BNRateReward = new BN(RateReward.toString());
			let Check = amountTOKEN.mul(BNRateReward).div(BNBase);
			let NewPositionCheck = BNPosition.add(Check);
			let NEWPosition = await COLLATERAL.cPosition.call(accounts[1], 0);
			assert.equal(NEWPosition[1].toString(), NewPositionCheck.toString(), "Change CP: withdraw Token not added");
		});



	});
	describe('Close CP', function () {
		it("Close Collateral Position", async () => {
			let Position = await COLLATERAL.individualCPdata.call(accounts[1], 0);
			let amount = 20000000000000000000000;
			let amountETH = 2000000000000000000;
			await COLLATERAL.openCP(amount.toLocaleString('fullwide', { useGrouping: false }), {from: accounts[1], value: amountETH});
			await COLLATERAL.withdrawETHCP(Position[0], 0, {from: accounts[1]});
			let PositionNew = await COLLATERAL.individualCPdata.call(accounts[1], 0);
			assert.equal(PositionNew[0], 0, "Close CP: ETH in position not zero");
  		});
	});
});

contract('LinkedCUS', async accounts => {
	let PROXY;
	let TOKEN;	
	let COLLATERAL;
	let CUSTODIAN;
	let ORACLE;
	let TAXATION;
	let DEFCON;
	let EXCHANGE;
		
	before(async() => {
		PROXY = await LinkedPROXY.deployed();
		TOKEN = await LinkedTKN.deployed();	
		COLLATERAL = await LinkedCOL.deployed();
		CUSTODIAN = await LinkedCUS.deployed();
		ORACLE = await LinkedORCL.deployed();
		TAXATION = await LinkedTAX.deployed();
		DEFCON = await LinkedDEFCON.deployed();
		EXCHANGE = await LinkedEXC.deployed();
		await PROXY.initialize(TOKEN.address,
						 COLLATERAL.address,
						 CUSTODIAN.address,
						 ORACLE.address,
						 TAXATION.address,
						 DEFCON.address,
						 EXCHANGE.address,
						 accounts[0]
						);
			
		await TOKEN.initialize(PROXY.address);	
		await COLLATERAL.initialize(PROXY.address);
		await CUSTODIAN.initialize(PROXY.address);
		await ORACLE.initialize(PROXY.address);
		await TAXATION.initialize(PROXY.address);
		await DEFCON.initialize(PROXY.address);
		await EXCHANGE.initialize(PROXY.address);
		await ORACLE.updateRate(20000);
	});
	describe('Custodian Collateral', function () {
		it("Received ETH", async () => {
			let amount = 10000000000000000000000;
			let amountETH = 2000000000000000000;
			await COLLATERAL.openCP(amount.toLocaleString('fullwide', { useGrouping: false }), {value: amountETH});
			let balance = await web3.eth.getBalance(CUSTODIAN.address);
			assert.equal(balance, amountETH, "Custodian Collateral: ETH not received");
		});
	});
});

contract('LinkedORCL', async accounts => {
	let PROXY;
	let TOKEN;	
	let COLLATERAL;
	let CUSTODIAN;
	let ORACLE;
	let TAXATION;
	let DEFCON;
	let EXCHANGE;
		
	before(async() => {
		PROXY = await LinkedPROXY.deployed();
		TOKEN = await LinkedTKN.deployed();	
		COLLATERAL = await LinkedCOL.deployed();
		CUSTODIAN = await LinkedCUS.deployed();
		ORACLE = await LinkedORCL.deployed();
		TAXATION = await LinkedTAX.deployed();
		DEFCON = await LinkedDEFCON.deployed();
		EXCHANGE = await LinkedEXC.deployed();
		await PROXY.initialize(TOKEN.address,
						 COLLATERAL.address,
						 CUSTODIAN.address,
						 ORACLE.address,
						 TAXATION.address,
						 DEFCON.address,
						 EXCHANGE.address,
						 accounts[0]
						);
			
		await TOKEN.initialize(PROXY.address);	
		await COLLATERAL.initialize(PROXY.address);
		await CUSTODIAN.initialize(PROXY.address);
		await ORACLE.initialize(PROXY.address);
		await TAXATION.initialize(PROXY.address);
		await DEFCON.initialize(PROXY.address);
		await EXCHANGE.initialize(PROXY.address);
		await ORACLE.updateRate(20000);
	});
	describe('Update price', function () {
		it("Simple price update", async () => {
			await ORACLE.updateRate(20000);
			let price = await PROXY.rate.call();
			assert.equal(price, 20000, "Update price: updateRate is not called");		
		});	
	});
});

contract('LinkedTAX', async accounts => {
	let PROXY;
	let TOKEN;	
	let COLLATERAL;
	let CUSTODIAN;
	let ORACLE;
	let TAXATION;
	let DEFCON;
	let EXCHANGE;

		
	before(async() => {
		PROXY = await LinkedPROXY.deployed();
		TOKEN = await LinkedTKN.deployed();	
		COLLATERAL = await LinkedCOL.deployed();
		CUSTODIAN = await LinkedCUS.deployed();
		ORACLE = await LinkedORCL.deployed();
		TAXATION = await LinkedTAX.deployed();
		DEFCON = await LinkedDEFCON.deployed();
		EXCHANGE = await LinkedEXC.deployed();
		await PROXY.initialize(TOKEN.address,
						 COLLATERAL.address,
						 CUSTODIAN.address,
						 ORACLE.address,
						 TAXATION.address,
						 DEFCON.address,
						 EXCHANGE.address,
						 accounts[0]
						);
		await TOKEN.initialize(PROXY.address);
		await COLLATERAL.initialize(PROXY.address);
		await CUSTODIAN.initialize(PROXY.address);
		await ORACLE.initialize(PROXY.address);
		await TAXATION.initialize(PROXY.address);
		await DEFCON.initialize(PROXY.address);
		await EXCHANGE.initialize(PROXY.address);
		await ORACLE.updateRate(20000);
	});
	describe('Stability calculations', function () {
		it("StabilityReward per block < normRate", async () => {
			//Open CP with 1 billion
			await ORACLE.updateRate(100000000000);
			let amount = 100000000000000000000000000000;
			let amountETH = 2000000000000000000;
			await COLLATERAL.openCP(amount.toLocaleString('fullwide', { useGrouping: false }), {value: amountETH});
			let CP = await COLLATERAL.individualCPdata.call(accounts[0], 0);
			//Add 1 block for adjustment in reward
			await ORACLE.updateRate(100000000001);
			let CP1 = await COLLATERAL.individualCPdata.call(accounts[0], 0);
			let Reward = (CP[1] - CP1[1]) / 10**20;
			let Norm = await TAXATION.baseRateReward.call();
			let CheckNorm = Norm - 1 * 10**18;
			//console.log(Reward)
			assert(Reward < CheckNorm, "Stability calculations: fee calculation error");
		});
		it("StabilityFee per block < normRate", async () => {
			await ORACLE.updateRate(100000000000);
			let amount = 100000000000000000000000000000;
			let amountETH = 2000000000000000000;
			await COLLATERAL.openCP(amount.toLocaleString('fullwide', { useGrouping: false }), {from: accounts[1], value: amountETH});
			let Balance = await TOKEN.balanceOf.call(accounts[1]);
			//Add 1 block for adjustment in reward
			await ORACLE.updateRate(100000000001);
			let BalanceNew = await TOKEN.balanceOf.call(accounts[1]);
			let Fee = (Balance - BalanceNew) / 10**20;
			let Norm = await TAXATION.baseRateFee.call();
			let CheckNorm = Norm - 1 * 10**18;
			//console.log(Fee);
			assert(Fee < CheckNorm, "Stability calculations: fee calculation error");
	  	});
	});
});

contract('LinkedEXC', async accounts => {
	let PROXY;
	let TOKEN;	
	let COLLATERAL;
	let CUSTODIAN;
	let ORACLE;
	let TAXATION;
	let DEFCON;
	let EXCHANGE;
		
	before(async() => {
		PROXY = await LinkedPROXY.deployed();
		TOKEN = await LinkedTKN.deployed();	
		COLLATERAL = await LinkedCOL.deployed();
		CUSTODIAN = await LinkedCUS.deployed();
		ORACLE = await LinkedORCL.deployed();
		TAXATION = await LinkedTAX.deployed();
		DEFCON = await LinkedDEFCON.deployed();
		EXCHANGE = await LinkedEXC.deployed();
		await PROXY.initialize(TOKEN.address,
						 COLLATERAL.address,
						 CUSTODIAN.address,
						 ORACLE.address,
						 TAXATION.address,
						 DEFCON.address,
						 EXCHANGE.address,
						 accounts[0]
						);
			
		await TOKEN.initialize(PROXY.address);	
		await COLLATERAL.initialize(PROXY.address);
		await CUSTODIAN.initialize(PROXY.address);
		await ORACLE.initialize(PROXY.address);
		await TAXATION.initialize(PROXY.address);
		await DEFCON.initialize(PROXY.address);
		await EXCHANGE.initialize(PROXY.address);
		await ORACLE.updateRate(20000);
	});
	describe('Deposit', function () {
		it("ETH deposit", async () => {
			let amountETH = 2000000000000000000;
			await EXCHANGE.sellETH({value: amountETH})
			let balance = await web3.eth.getBalance(EXCHANGE.address); 
			let ClaimETH = await EXCHANGE.claimOfETH.call(accounts[0]);
			assert.equal(balance, amountETH, "Deposit: Balance exchange contract not equal");
			assert.equal(ClaimETH, amountETH, "Deposit: Balance claim not equal")
		});
		it("Tokens deposit", async () => {
			await ORACLE.updateRate(20000);
			let amount = 20000000000000000000000;
			let amountETH = 2000000000000000000;
			await COLLATERAL.openCP(amount.toLocaleString('fullwide', { useGrouping: false }), {value: amountETH});
			let amountSell = 10000000000000000000000;
			await TOKEN.depositExchange(amountSell.toLocaleString('fullwide', { useGrouping: false }));
			let ClaimTokens = await EXCHANGE.claimOfTKN.call(accounts[0]);
			assert.equal(amountSell, ClaimTokens, "Depositr: Tokens not deposited");
	  	});
	});
	describe('Withdraw', function () {
		it("Remove claim ETH withdraw", async () => {
			let amountETH = 2000000000000000000;
			await EXCHANGE.removeClaimETH(amountETH.toLocaleString('fullwide', { useGrouping: false }))
			let balance = await web3.eth.getBalance(EXCHANGE.address); 
			let ClaimETH = await EXCHANGE.claimOfETH.call(accounts[0]);
			assert.equal(balance, 0, "Remove claim: Balance exchange contract not equal");
			assert.equal(ClaimETH, 0, "Remove claim: Balance claim not equal")
		});
		it("Remove claim Tokens", async () => {
			//Claim adjusted for fee
			let Claim = 9999999824177602100000;
			await EXCHANGE.removeClaimTKN(Claim.toLocaleString('fullwide', { useGrouping: false }))
			let ClaimNew = await EXCHANGE.claimOfTKN.call(accounts[0]);
			assert(ClaimNew < 10000000000, "Remove claim: Balance exchange contract not equal");	
			//Test fee on low claim value
			for (i=1; i < 100; i++)	{
				await ORACLE.updateRate(20000);
			}
			let ClaimBlock1 = await EXCHANGE.claimOfTKN.call(accounts[0]);
			assert(ClaimBlock1 < ClaimNew, "Remove claim: Balance exchange contract not equal");
			//Test withdraw small amount
			let ClaimSmall = 1319461;
			await EXCHANGE.removeClaimTKN(ClaimSmall.toLocaleString('fullwide', { useGrouping: false }))
			let ClaimSmallNew = await EXCHANGE.claimOfTKN.call(accounts[0]);
			assert.equal(ClaimSmallNew, 0, "Remove claim: Small amount remove to zero not possible")
		}); 
		it("Withdraw ETH", async () => {
			let amount = 20000000000000000000000;
			let amountETH = 2000000000000000000;
			await COLLATERAL.openCP(amount.toLocaleString('fullwide', { useGrouping: false }), {value: amountETH});
			let amountSell = 10000000000000000000000;
			await TOKEN.depositExchange(amountSell.toLocaleString('fullwide', { useGrouping: false }));
			await EXCHANGE.sellETH({value: amountETH})
			let balance = await web3.eth.getBalance(accounts[0]);
			amountETHBuy = 200000000000000000;
			let total = await EXCHANGE.totalReserve.call();
			await EXCHANGE.buyETH(amountETHBuy.toLocaleString('fullwide', { useGrouping: false }));
			let balanceNew = await web3.eth.getBalance(accounts[0]);
			let balanceDiff = balanceNew - balance;
			let balanceDiffCheck = 190000000000000000;
			let balanceDiffCheckmax = 200000000000000000;
			//Check total reserve
			let totalNEW = await EXCHANGE.totalReserve.call();
			let totalChange = total[0] - totalNEW[0];
			assert(balanceDiff > balanceDiffCheck, "Withdraw ETH: balance change is not 0.2ETH minus gas");
			assert(balanceDiff < balanceDiffCheckmax, "Withdraw ETH: balance change is not 0.2ETH minus gas");
			assert.equal(totalChange, amountETHBuy, "Withdraw ETH: total cchange is not 0.2ETH");
		}); 
		it("Withdraw tokens", async () => {
			let claimETH = await EXCHANGE.claimOfETH.call(accounts[0]);
			let base = 10**20;
			let BNbase = new BN(web3.utils.toBN(base));
			let total = await EXCHANGE.totalReserve.call();
			let BNtotal = new BN(total[1]);
			let totalrounded = BNtotal.div(BNbase);
			let amountTKNBuy = "5000000000000000000000";
			let BNamountTKNBuy = new BN(amountTKNBuy);
			let BNamountTKNBuycheck = BNamountTKNBuy.div(BNbase);
			await EXCHANGE.buyTKN(amountTKNBuy.toLocaleString('fullwide', { useGrouping: false }));
			let claimETHNEW = await EXCHANGE.claimOfETH.call(accounts[0]);
			let totalNEW = await EXCHANGE.totalReserve.call();
			let BNtotalNew = new BN(totalNEW[1]);
			let totalNEWrounded = BNtotalNew.div(BNbase);
			let totalDiff = totalrounded.sub(totalNEWrounded);
			let ClaimETHChange = claimETH - claimETHNEW;
			let ClaimETHChangeCheck = amountTKNBuy / 20000;
			assert.equal(ClaimETHChange.toString(), ClaimETHChangeCheck.toString(), "Withdraw tokens: change in ETH claim not equal");
			assert.equal(BNamountTKNBuycheck.toString(), totalDiff.toString(), "Withdraw tokens: change in total balance exchange not equal");
		});  
	});
});

/*
contract('LinkedDEFCON', async accounts => {
	let PROXY;
	let TOKEN;	
	let COLLATERAL;
	let CUSTODIAN;
	let ORACLE;
	let TAXATION;
	let DEFCON;
	let EXCHANGE;
		
	before(async() => {
		PROXY = await LinkedPROXY.deployed();
		TOKEN = await LinkedTKN.deployed();	
		COLLATERAL = await LinkedCOL.deployed();
		CUSTODIAN = await LinkedCUS.deployed();
		ORACLE = await LinkedORCL.deployed();
		TAXATION = await LinkedTAX.deployed();
		DEFCON = await LinkedDEFCON.deployed();
		EXCHANGE = await LinkedEXC.deployed();
		await PROXY.initialize(TOKEN.address,
						 COLLATERAL.address,
						 CUSTODIAN.address,
						 ORACLE.address,
						 TAXATION.address,
						 DEFCON.address,
						 EXCHANGE.address,
						 accounts[0]
						);
			
		await TOKEN.initialize(PROXY.address);	
		await COLLATERAL.initialize(PROXY.address);
		await CUSTODIAN.initialize(PROXY.address);
		await ORACLE.initialize(PROXY.address);
		await TAXATION.initialize(PROXY.address);
		await DEFCON.initialize(PROXY.address);
		await EXCHANGE.initialize(PROXY.address);
		await ORACLE.updateRate(20000);
	});
	describe('DEFCON', function () {
		it("TO DO: Activate shutdown", async () => {
    			assert.equal(true, true, "DEFCON: Activation failed");
		});
		it("TO DO: Pending shutdown", async () => {
			assert.equal(true, true, "DEFCON: Shutdown error");
	  });
	});
});
*/

