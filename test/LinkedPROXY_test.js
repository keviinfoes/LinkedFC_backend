const LinkedFactory = artifacts.require("LinkedFactory")
const LinkedFactoryTKN = artifacts.require("LinkedFactoryTKN")
const LinkedFactoryCOL = artifacts.require("LinkedFactoryCOL")
const LinkedFactoryCUS = artifacts.require("LinkedFactoryCUS")
const LinkedFactoryORCL = artifacts.require("LinkedFactoryORCL")
const LinkedFactoryTAX = artifacts.require("LinkedFactoryTAX")
const LinkedFactoryDEFCON = artifacts.require("LinkedFactoryDEFCON")
const LinkedFactoryEXC = artifacts.require("LinkedFactoryEXC")

const LinkedPROXY = artifacts.require("LinkedPROXY")
const LinkedTKN = artifacts.require("LinkedTKN")
const LinkedCOL = artifacts.require("LinkedCOL")
const LinkedCUS = artifacts.require("LinkedCUS")
const LinkedORCL = artifacts.require("LinkedORCL")
const LinkedTAX = artifacts.require("LinkedTAX")
const LinkedDEFCON = artifacts.require("LinkedDEFCON")
const LinkedEXC = artifacts.require("LinkedEXC")
const truffleAssert = require('truffle-assertions')
const BN = require('bn.js')

//Console log the addresses of the deployed contracts
contract('LinkedPROXY', async accounts => {
	let Factory
	let FactoryTKN
	let FactoryCOL
	let FactoryCUS
	let FactoryORCL
	let FactoryTAX
	let FactoryDEFCON
	let FactoryEXC
	let PROXY
	let TOKEN
	let COLLATERAL
	let CUSTODIAN
	let ORACLE
	let TAXATION
	let DEFCON
	let EXCHANGE
	before(async() => {
		Factory = await LinkedFactory.deployed()
		FactoryTKN = await LinkedFactoryTKN.deployed()
		FactoryCOL = await LinkedFactoryCOL.deployed()
		FactoryCUS = await LinkedFactoryCUS.deployed()
		FactoryORCL = await LinkedFactoryORCL.deployed()
		FactoryTAX = await LinkedFactoryTAX.deployed()
		FactoryDEFCON = await LinkedFactoryDEFCON.deployed()
		FactoryEXC = await LinkedFactoryEXC.deployed()
		await Factory.initialize(FactoryTKN.address,
							FactoryCOL.address,
						 	FactoryCUS.address,
						 	FactoryORCL.address,
						 	FactoryTAX.address,
						 	FactoryDEFCON.address,
						 	FactoryEXC.address
						)
		await FactoryTKN.initialize(Factory.address)
		await FactoryCOL.initialize(Factory.address)
		await FactoryCUS.initialize(Factory.address)
		await FactoryORCL.initialize(Factory.address)
		await FactoryTAX.initialize(Factory.address)
		await FactoryDEFCON.initialize(Factory.address)
		await FactoryEXC.initialize(Factory.address)
		
		await Factory.createAsset()
		let asset_1 = await Factory.assets(0)
		PROXY = await LinkedPROXY.at(asset_1[0])
		TOKEN = await LinkedTKN.at(asset_1[1])
		COLLATERAL = await LinkedCOL.at(asset_1[2])
		CUSTODIAN = await LinkedCUS.at(asset_1[3])
		ORACLE = await LinkedORCL.at(asset_1[4])
		TAXATION = await LinkedTAX.at(asset_1[5])
		DEFCON = await LinkedDEFCON.at(asset_1[6])
		EXCHANGE = await LinkedEXC.at(asset_1[7])
	})
	describe('Initialize', function () {
		//Initialize proxy contract and check successful initialization
		it("should initialize proxy contract", async () => {
			let active = await PROXY.initialized.call()
			let token = await PROXY.token.call()
			let collateral = await PROXY.collateral.call()
			let custodian = await PROXY.custodian.call()
			let oracle = await PROXY.oracle.call()
			let tax = await PROXY.tax.call()
			let defcon = await PROXY.defcon.call()
			let exchange = await PROXY.exchange.call()
			let dev = await PROXY.dev.call()

			//PRINT ADDRESSES
			//console.log("PROXY address: " + PROXY.address);
			//console.log("TOKEN address: " + TOKEN.address);
			//console.log("COLLATERAL address: " + COLLATERAL.address);
			//console.log("CUSTODIAN address: " + CUSTODIAN.address);
			//console.log("ORACLE address: " + ORACLE.address);
			//console.log("TAXATION address: " + TAXATION.address);
			//console.log("DEFCON address: " + DEFCON.address);
			//console.log("EXCHANGE address: " + EXCHANGE.address);
			//

			assert.equal(active, true, "Initialized is not called")
			assert.equal(token, TOKEN.address, "Token initialized address does not match")
			assert.equal(collateral, COLLATERAL.address, "Collateral initialized address does not match")
			assert.equal(custodian, CUSTODIAN.address, "Custodian initialized address does not match")
			assert.equal(oracle, ORACLE.address, "Oracle initialized address does not match")
			assert.equal(tax, TAXATION.address, "Taxation initialized address does not match")
			assert.equal(defcon, DEFCON.address, "Defcon initialized address does not match")
			assert.equal(exchange, EXCHANGE.address, "Exchange initialized address does not match")
			assert.equal(dev, accounts[0], "Dev initialized address does not match")
		})
		//Initialize other contracts and check successful initialization
		it("should initialize other system contracts", async () => {
			let activeTKN = await TOKEN.initialized.call()
			assert.equal(activeTKN, true, "Initialized TOKEN is not called")
			let activeCOL = await COLLATERAL.initialized.call()
			assert.equal(activeCOL, true, "Initialized COLLATERAL is not called")
			let activeCUS = await CUSTODIAN.initialized.call()
			assert.equal(activeCUS, true, "Initialized CUSTODIAN is not called")
			let activeORC = await ORACLE.initialized.call()
			assert.equal(activeORC, true, "Initialized ORACLE is not called")
			let activeTAX = await TAXATION.initialized.call()
			assert.equal(activeTAX, true, "Initialized TAXATION is not called")
			let activeDEFCON = await DEFCON.initialized.call()
			assert.equal(activeDEFCON, true, "Initialized DEFCON is not called")
			let activeEXC = await EXCHANGE.initialized.call()
			assert.equal(activeEXC, true, "Initialized EXCHANGE is not called")
		})
		//readAddress check
		it("should return address of contracts", async () => {
			let readAddressOutput = await PROXY.readAddress.call()
			assert.equal(TOKEN.address, readAddressOutput[0], "Readaddress TOKEN is not called")
			assert.equal(COLLATERAL.address, readAddressOutput[1], "Readaddress COLLATERAL is not called")
			assert.equal(CUSTODIAN.address, readAddressOutput[2], "Readaddress CUSTODIAN is not called")
			assert.equal(ORACLE.address, readAddressOutput[3], "Readaddress ORACLE is not called")
			assert.equal(TAXATION.address, readAddressOutput[4], "Readaddress TAXATION is not called")
			assert.equal(DEFCON.address, readAddressOutput[5], "Readaddress DEFCON is not called")
			assert.equal(EXCHANGE.address, readAddressOutput[6], "Readaddress EXCHANGE is not called")
		})
	})

	describe('Oracle', function () {
		//Change oracle and check succes
		it("should change price oracle", async () => {
			await PROXY.changeOracle('0x79C4077CB6af3112aCF4B298f4B5B40b7f596b7D')
			let newOracle = await PROXY.oracle.call()
			assert.equal(newOracle, '0x79C4077CB6af3112aCF4B298f4B5B40b7f596b7D', "changeOracle is not called")
			await PROXY.changeOracle(ORACLE.address)
		})
	})
	describe('Pause contracts', function () {
		//readAddress check
		it("should pause the system", async () => {
			await PROXY.pause()
			let paused = await PROXY.checkPause.call()
			assert.equal(paused, true, "Pause is not called")
			let priceUpdate = await truffleAssert.reverts(ORACLE.updateRate(10000))
			await PROXY.unpause()
			let unpaused = await PROXY.checkPause.call()
			assert.equal(unpaused, false, "unPause is not called")
		})
	})
})

contract('LinkedCOL', async accounts => {
	let Factory
	let FactoryTKN
	let FactoryCOL
	let FactoryCUS
	let FactoryORCL
	let FactoryTAX
	let FactoryDEFCON
	let FactoryEXC
	let PROXY
	let TOKEN
	let COLLATERAL
	let CUSTODIAN
	let ORACLE
	let TAXATION
	let DEFCON
	let EXCHANGE
	before(async() => {
		Factory = await LinkedFactory.deployed()
		FactoryTKN = await LinkedFactoryTKN.deployed()
		FactoryCOL = await LinkedFactoryCOL.deployed()
		FactoryCUS = await LinkedFactoryCUS.deployed()
		FactoryORCL = await LinkedFactoryORCL.deployed()
		FactoryTAX = await LinkedFactoryTAX.deployed()
		FactoryDEFCON = await LinkedFactoryDEFCON.deployed()
		FactoryEXC = await LinkedFactoryEXC.deployed()
		await Factory.initialize(FactoryTKN.address,
							FactoryCOL.address,
						 	FactoryCUS.address,
						 	FactoryORCL.address,
						 	FactoryTAX.address,
						 	FactoryDEFCON.address,
						 	FactoryEXC.address
						)
		await FactoryTKN.initialize(Factory.address)
		await FactoryCOL.initialize(Factory.address)
		await FactoryCUS.initialize(Factory.address)
		await FactoryORCL.initialize(Factory.address)
		await FactoryTAX.initialize(Factory.address)
		await FactoryDEFCON.initialize(Factory.address)
		await FactoryEXC.initialize(Factory.address)
		
		await Factory.createAsset()
		let asset_1 = await Factory.assets(0)
		PROXY = await LinkedPROXY.at(asset_1[0])
		TOKEN = await LinkedTKN.at(asset_1[1])
		COLLATERAL = await LinkedCOL.at(asset_1[2])
		CUSTODIAN = await LinkedCUS.at(asset_1[3])
		ORACLE = await LinkedORCL.at(asset_1[4])
		TAXATION = await LinkedTAX.at(asset_1[5])
		DEFCON = await LinkedDEFCON.at(asset_1[6])
		EXCHANGE = await LinkedEXC.at(asset_1[7])

		await ORACLE.updateRate(20000);
	})
	describe('Open CP', async () => {
		//Initialize other contracts and check successful initialization
		it("should open collateral position account[0]", async () => {
			let amount = 20000000000000000000000
			let amountETH = 2000000000000000000
			await COLLATERAL.openCP(amount.toLocaleString('fullwide', { useGrouping: false }), {value: amountETH})
			let CP = await COLLATERAL.individualCPdata.call(accounts[0], 0)
			assert.equal(CP[0], amountETH, "Collateral in CP false account 0")
			assert.equal(CP[1], amount, "Tokens in CP false")
			let balance = await TOKEN.balanceOf.call(accounts[0])
			assert.equal(balance, amount, "Balance token is different from CP account 0")
		})
		it("should open collateral position account[1]", async () => {
			let amount = 40000000000000000000000
			let amountETH = 4000000000000000000
			await COLLATERAL.openCP(amount.toLocaleString('fullwide', { useGrouping: false }), {from: accounts[1], value: amountETH})
			let CP = await COLLATERAL.individualCPdata.call(accounts[1], 0)
			assert.equal(CP[0], amountETH, "Collateral in CP false account 1")
			assert.equal(CP[1], amount, "Tokens in CP false")
			let balance = await TOKEN.balanceOf.call(accounts[1])
			assert.equal(balance, amount, "Balance token is different from CP account 1")
		})
		it("should transfer collateral position account[0] to account[1]", async () => {
			let initial = await COLLATERAL.individualCPdata.call(accounts[0], 0)
			await COLLATERAL.transfer(accounts[1], 0)
			let user_0 = await COLLATERAL.individualCPdata.call(accounts[0], 0)
			let user_1 = await COLLATERAL.individualCPdata.call(accounts[1], 1)
			assert.equal(user_0[0], 0, "Transfer: CP sender not deducted")
			assert.equal(user_0[1], 0, "Transfer: CP sender not deducted")
			assert.equal(initial[0].toString(), user_1[0].toString(), "Transfer: receiver not added")
		})
	})
	describe('Change CP', async () => {
		it("should deposit ETH in collateral position", async () => {
			let amountETH = 4000000000000000000
			let Position = await COLLATERAL.individualCPdata.call(accounts[1], 0)
			await COLLATERAL.depositETHCP(0, {from: accounts[1], value: amountETH})
			let check = Number(Position[0]) + Number(amountETH)
			let NEWPosition = await COLLATERAL.individualCPdata.call(accounts[1], 0)
			assert.equal(check.toString(), NEWPosition[0].toString(), "Change CP: deposit ETH not added")
		})
		it("should deposit tokens in collateral position", async () => {
			let amountTOKEN = new BN("200000000000000000000")
			let Position = await COLLATERAL.cPosition.call(accounts[1], 0)
			let BNPosition = new BN(Position[1].toString())
			await COLLATERAL.depositTokenCP(amountTOKEN.toLocaleString('fullwide', { useGrouping: false }), 0, {from: accounts[1]})
			let Base = await PROXY.base.call()
			let BNBase = new BN(Base.toString())
			let RateReward = await TAXATION.viewNormRateReward.call()
			let BNRateReward = new BN(RateReward.toString())
			let Check = amountTOKEN.mul(BNRateReward).div(BNBase)
			let NewPositionCheck = BNPosition.sub(Check)
			let NEWPosition = await COLLATERAL.cPosition.call(accounts[1], 0)
			assert.equal(NEWPosition[1].toString(), NewPositionCheck.toString(), "Change CP: deposit Token not deducted")
		})
		it("should withdraw ETH from collateral position", async () => {
			let amountETH = 2000000000000000000
			let Position = await COLLATERAL.individualCPdata.call(accounts[1], 0)
			await COLLATERAL.withdrawETHCP(amountETH.toLocaleString('fullwide', { useGrouping: false }), 0, {from: accounts[1]})
			let check = Number(Position[0]) - Number(amountETH)
			let NEWPosition = await COLLATERAL.individualCPdata.call(accounts[1], 0)
			assert.equal(check.toString(), NEWPosition[0].toString(), "Change CP: withdraw ETH not deducted")
		})
		it("should withdraw tokens from collateral position", async () => {
			let amountTOKEN = new BN("200000000000000000000")
			let Position = await COLLATERAL.cPosition.call(accounts[1], 0)
			let BNPosition = new BN(Position[1].toString())
			await COLLATERAL.withdrawTokenCP(amountTOKEN.toLocaleString('fullwide', { useGrouping: false }), 0, {from: accounts[1]})
			let Base = await PROXY.base.call()
			let BNBase = new BN(Base.toString())
			let RateReward = await TAXATION.viewNormRateReward.call()
			let BNRateReward = new BN(RateReward.toString())
			let Check = amountTOKEN.mul(BNRateReward).div(BNBase)
			let NewPositionCheck = BNPosition.add(Check)
			let NEWPosition = await COLLATERAL.cPosition.call(accounts[1], 0)
			assert.equal(NEWPosition[1].toString(), NewPositionCheck.toString(), "Change CP: withdraw Token not added")
		})
	})
	describe('Close CP', function () {
		it("should close collateral positions", async () => {
			let Position = await COLLATERAL.individualCPdata.call(accounts[1], 0)
			let amount = 20000000000000000000000
			let amountETH = 2000000000000000000
			await COLLATERAL.openCP(amount.toLocaleString('fullwide', { useGrouping: false }), {from: accounts[1], value: amountETH})
			await COLLATERAL.withdrawETHCP(Position[0], 0, {from: accounts[1]})
			let PositionNew = await COLLATERAL.individualCPdata.call(accounts[1], 0)
			assert.equal(PositionNew[0], 0, "Close CP: ETH in position not zero")
  		})
	})
	describe('Liquidate CP', function () {
		it("should liquidate collateral positions 140% ", async () => {
			let amount = 20000000000000000000000
			let amountETH = 2000000000000000000
			let amount2 = 40000000000000000000000
			let amountETH2 = 4000000000000000000
			await COLLATERAL.openCP(amount.toLocaleString('fullwide', { useGrouping: false }), {value: amountETH})
			await COLLATERAL.openCP(amount2.toLocaleString('fullwide', { useGrouping: false }), {from: accounts[1], value: amountETH2})
			let index = await COLLATERAL.index.call(accounts[0])
			await ORACLE.updateRate(14000)
			await COLLATERAL.liquidateCP(accounts[0], (index - 1), {from: accounts[1]})
			let position = await COLLATERAL.cPosition.call(accounts[0], (index - 1))
			assert.equal(position[0].toString(), 0, "Liquidate CP: liquidation failed")
			assert.equal(position[1].toString(), 0, "Liquidate CP: liquidation failed")
		})
		
		it("should increase liquidation correction for debt calculation (<100%)", async () => {
			await ORACLE.updateRate(20000)
			let amount = 20000000000000000000000
			let amountETH = 2000000000000000000
			let amount2 = 40000000000000000000000
			let amountETH2 = 4000000000000000000
			await COLLATERAL.openCP(amount.toLocaleString('fullwide', { useGrouping: false }), {value: amountETH})
			await COLLATERAL.openCP(amount2.toLocaleString('fullwide', { useGrouping: false }), {from: accounts[1], value: amountETH2})
			let index = await COLLATERAL.index.call(accounts[0])
			await ORACLE.updateRate(9000)
			let correctionOLD = await TAXATION.liquidationCorrection.call()
			assert.equal(correctionOLD, 0, "Liquidate CP: start correction not zero")
			await COLLATERAL.liquidateCP(accounts[0], (index - 1), {from: accounts[1]})
			let position = await COLLATERAL.cPosition.call(accounts[0], (index - 1))
			let correction = await TAXATION.liquidationCorrection.call()
			assert(correction, "Liquidate CP: liquidation correction not added")
			assert.equal(position[0].toString(), 0, "Liquidate CP: liquidation failed")
		})
		it("should have no effect on balance totals", async () => {
			let totalCP = await COLLATERAL.dataTotalCP.call()
			let totalDEBT = totalCP[2]
			let totalTKN = await TOKEN.gettotalSupply.call()
			let totalDEV = await TOKEN.balanceOfDev.call()
			let subtotalTKN = totalTKN.add(totalDEV)
			assert.equal(subtotalTKN.toString(), totalDEBT.toString(), "Liquidate CP: balance not equal")
		})
	})
})

contract('LinkedCUS', async accounts => {
	let Factory
	let FactoryTKN
	let FactoryCOL
	let FactoryCUS
	let FactoryORCL
	let FactoryTAX
	let FactoryDEFCON
	let FactoryEXC
	let PROXY
	let TOKEN
	let COLLATERAL
	let CUSTODIAN
	let ORACLE
	let TAXATION
	let DEFCON
	let EXCHANGE
	before(async() => {
		Factory = await LinkedFactory.deployed()
		FactoryTKN = await LinkedFactoryTKN.deployed()
		FactoryCOL = await LinkedFactoryCOL.deployed()
		FactoryCUS = await LinkedFactoryCUS.deployed()
		FactoryORCL = await LinkedFactoryORCL.deployed()
		FactoryTAX = await LinkedFactoryTAX.deployed()
		FactoryDEFCON = await LinkedFactoryDEFCON.deployed()
		FactoryEXC = await LinkedFactoryEXC.deployed()
		await Factory.initialize(FactoryTKN.address,
							FactoryCOL.address,
						 	FactoryCUS.address,
						 	FactoryORCL.address,
						 	FactoryTAX.address,
						 	FactoryDEFCON.address,
						 	FactoryEXC.address
						)
		await FactoryTKN.initialize(Factory.address)
		await FactoryCOL.initialize(Factory.address)
		await FactoryCUS.initialize(Factory.address)
		await FactoryORCL.initialize(Factory.address)
		await FactoryTAX.initialize(Factory.address)
		await FactoryDEFCON.initialize(Factory.address)
		await FactoryEXC.initialize(Factory.address)
		
		await Factory.createAsset()
		let asset_1 = await Factory.assets(0)
		PROXY = await LinkedPROXY.at(asset_1[0])
		TOKEN = await LinkedTKN.at(asset_1[1])
		COLLATERAL = await LinkedCOL.at(asset_1[2])
		CUSTODIAN = await LinkedCUS.at(asset_1[3])
		ORACLE = await LinkedORCL.at(asset_1[4])
		TAXATION = await LinkedTAX.at(asset_1[5])
		DEFCON = await LinkedDEFCON.at(asset_1[6])
		EXCHANGE = await LinkedEXC.at(asset_1[7])

		await ORACLE.updateRate(20000)
	})
	describe('Custodian Collateral', function () {
		it("should receive ETH in opening collateral position", async () => {
			let amount = 10000000000000000000000
			let amountETH = 2000000000000000000
			await COLLATERAL.openCP(amount.toLocaleString('fullwide', { useGrouping: false }), {value: amountETH})
			let balance = await web3.eth.getBalance(CUSTODIAN.address)
			assert.equal(balance, amountETH, "Custodian Collateral: ETH not received")
		})
	})
})

contract('LinkedORCL', async accounts => {
	let Factory
	let FactoryTKN
	let FactoryCOL
	let FactoryCUS
	let FactoryORCL
	let FactoryTAX
	let FactoryDEFCON
	let FactoryEXC
	let PROXY
	let TOKEN
	let COLLATERAL
	let CUSTODIAN
	let ORACLE
	let TAXATION
	let DEFCON
	let EXCHANGE
	before(async() => {
		Factory = await LinkedFactory.deployed()
		FactoryTKN = await LinkedFactoryTKN.deployed()
		FactoryCOL = await LinkedFactoryCOL.deployed()
		FactoryCUS = await LinkedFactoryCUS.deployed()
		FactoryORCL = await LinkedFactoryORCL.deployed()
		FactoryTAX = await LinkedFactoryTAX.deployed()
		FactoryDEFCON = await LinkedFactoryDEFCON.deployed()
		FactoryEXC = await LinkedFactoryEXC.deployed()
		await Factory.initialize(FactoryTKN.address,
							FactoryCOL.address,
						 	FactoryCUS.address,
						 	FactoryORCL.address,
						 	FactoryTAX.address,
						 	FactoryDEFCON.address,
						 	FactoryEXC.address
						)
		await FactoryTKN.initialize(Factory.address)
		await FactoryCOL.initialize(Factory.address)
		await FactoryCUS.initialize(Factory.address)
		await FactoryORCL.initialize(Factory.address)
		await FactoryTAX.initialize(Factory.address)
		await FactoryDEFCON.initialize(Factory.address)
		await FactoryEXC.initialize(Factory.address)
		
		await Factory.createAsset()
		let asset_1 = await Factory.assets(0)
		PROXY = await LinkedPROXY.at(asset_1[0])
		TOKEN = await LinkedTKN.at(asset_1[1])
		COLLATERAL = await LinkedCOL.at(asset_1[2])
		CUSTODIAN = await LinkedCUS.at(asset_1[3])
		ORACLE = await LinkedORCL.at(asset_1[4])
		TAXATION = await LinkedTAX.at(asset_1[5])
		DEFCON = await LinkedDEFCON.at(asset_1[6])
		EXCHANGE = await LinkedEXC.at(asset_1[7])

		await ORACLE.updateRate(20000);
	})
	describe('Update price', function () {
		it("should update the price", async () => {
			await ORACLE.updateRate(20000)
			let price = await PROXY.rate.call()
			assert.equal(price, 20000, "Update price: updateRate is not called")
		})
	})
})

contract('LinkedTAX', async accounts => {
	let Factory
	let FactoryTKN
	let FactoryCOL
	let FactoryCUS
	let FactoryORCL
	let FactoryTAX
	let FactoryDEFCON
	let FactoryEXC
	let PROXY
	let TOKEN
	let COLLATERAL
	let CUSTODIAN
	let ORACLE
	let TAXATION
	let DEFCON
	let EXCHANGE
	before(async() => {
		Factory = await LinkedFactory.deployed()
		FactoryTKN = await LinkedFactoryTKN.deployed()
		FactoryCOL = await LinkedFactoryCOL.deployed()
		FactoryCUS = await LinkedFactoryCUS.deployed()
		FactoryORCL = await LinkedFactoryORCL.deployed()
		FactoryTAX = await LinkedFactoryTAX.deployed()
		FactoryDEFCON = await LinkedFactoryDEFCON.deployed()
		FactoryEXC = await LinkedFactoryEXC.deployed()
		await Factory.initialize(FactoryTKN.address,
							FactoryCOL.address,
						 	FactoryCUS.address,
						 	FactoryORCL.address,
						 	FactoryTAX.address,
						 	FactoryDEFCON.address,
						 	FactoryEXC.address
						)
		await FactoryTKN.initialize(Factory.address)
		await FactoryCOL.initialize(Factory.address)
		await FactoryCUS.initialize(Factory.address)
		await FactoryORCL.initialize(Factory.address)
		await FactoryTAX.initialize(Factory.address)
		await FactoryDEFCON.initialize(Factory.address)
		await FactoryEXC.initialize(Factory.address)
		
		await Factory.createAsset()
		let asset_1 = await Factory.assets(0)
		PROXY = await LinkedPROXY.at(asset_1[0])
		TOKEN = await LinkedTKN.at(asset_1[1])
		COLLATERAL = await LinkedCOL.at(asset_1[2])
		CUSTODIAN = await LinkedCUS.at(asset_1[3])
		ORACLE = await LinkedORCL.at(asset_1[4])
		TAXATION = await LinkedTAX.at(asset_1[5])
		DEFCON = await LinkedDEFCON.at(asset_1[6])
		EXCHANGE = await LinkedEXC.at(asset_1[7])

		await ORACLE.updateRate(20000)
	})
	describe('Stability calculations', function () {
		it("should add stabilityReward per block < normRate", async () => {
			//Open CP with 1 billion
			await ORACLE.updateRate(100000000000)
			let amount = 100000000000000000000000000000
			let amountETH = 2000000000000000000
			await COLLATERAL.openCP(amount.toLocaleString('fullwide', { useGrouping: false }), {value: amountETH})
			let CP = await COLLATERAL.individualCPdata.call(accounts[0], 0)
			//Add 1 block for adjustment in reward
			await ORACLE.updateRate(100000000001)
			let CP1 = await COLLATERAL.individualCPdata.call(accounts[0], 0)
			let Reward = (CP[1] - CP1[1]) / 10**20
			let Norm = await TAXATION.baseRateReward.call()
			let CheckNorm = Norm - 1 * 10**18
			//console.log(Reward)
			assert(Reward < CheckNorm, "Stability calculations: fee calculation error")
		})
		it("should add stabilityFee per block < normRate", async () => {
			await ORACLE.updateRate(100000000000)
			let amount = 100000000000000000000000000000
			let amountETH = 2000000000000000000
			await COLLATERAL.openCP(amount.toLocaleString('fullwide', { useGrouping: false }), {from: accounts[1], value: amountETH})
			let Balance = await TOKEN.balanceOf.call(accounts[1])
			//Add 1 block for adjustment in reward
			await ORACLE.updateRate(100000000001)
			let BalanceNew = await TOKEN.balanceOf.call(accounts[1])
			let Fee = (Balance - BalanceNew) / 10**20
			let Norm = await TAXATION.baseRateFee.call()
			let CheckNorm = Norm - 1 * 10**18
			//console.log(Fee);
			assert(Fee < CheckNorm, "Stability calculations: fee calculation error")
		})
		it("should adjust the rate reward from 1.5% to 2%", async () => {
			let base = 10**18
			let BNbase = new BN(base.toString())
			let raterewardOLD = await TAXATION.baseRateReward.call()
			let ratefee = await TAXATION.baseRateFee.call()
			await TAXATION.updateNormRate(ratefee, ratefee)
			let raterewardNEW = await TAXATION.baseRateReward.call()
			let additionrewardNEW = await TAXATION.additionReward.call()
			let checkAddition = raterewardOLD.sub(BNbase)
			assert.equal(raterewardNEW.toString(), ratefee.toString(), "Taxation: update ratereward failed")
			assert.equal(additionrewardNEW.toString(), checkAddition.toString(), "Taxation: update ratereward addition failed")
			await TAXATION.updateNormRate(raterewardOLD, ratefee)
		})
		it("should adjust the rate fee from 2% to 1.5% ", async () => {
			let ratereward = await TAXATION.baseRateReward.call();
			await TAXATION.updateNormRate(ratereward, ratereward);
			let ratefeeNEW = await TAXATION.baseRateFee.call();
			assert.equal(ratefeeNEW.toString(), ratereward.toString(), "Taxation: update ratefee failed");
		})
	})
})
contract('LinkedEXC', async accounts => {
	let Factory
	let FactoryTKN
	let FactoryCOL
	let FactoryCUS
	let FactoryORCL
	let FactoryTAX
	let FactoryDEFCON
	let FactoryEXC
	let PROXY
	let TOKEN
	let COLLATERAL
	let CUSTODIAN
	let ORACLE
	let TAXATION
	let DEFCON
	let EXCHANGE
	before(async() => {
		Factory = await LinkedFactory.deployed()
		FactoryTKN = await LinkedFactoryTKN.deployed()
		FactoryCOL = await LinkedFactoryCOL.deployed()
		FactoryCUS = await LinkedFactoryCUS.deployed()
		FactoryORCL = await LinkedFactoryORCL.deployed()
		FactoryTAX = await LinkedFactoryTAX.deployed()
		FactoryDEFCON = await LinkedFactoryDEFCON.deployed()
		FactoryEXC = await LinkedFactoryEXC.deployed()
		await Factory.initialize(FactoryTKN.address,
							FactoryCOL.address,
						 	FactoryCUS.address,
						 	FactoryORCL.address,
						 	FactoryTAX.address,
						 	FactoryDEFCON.address,
						 	FactoryEXC.address
						)
		await FactoryTKN.initialize(Factory.address)
		await FactoryCOL.initialize(Factory.address)
		await FactoryCUS.initialize(Factory.address)
		await FactoryORCL.initialize(Factory.address)
		await FactoryTAX.initialize(Factory.address)
		await FactoryDEFCON.initialize(Factory.address)
		await FactoryEXC.initialize(Factory.address)
		
		await Factory.createAsset()
		let asset_1 = await Factory.assets(0)
		PROXY = await LinkedPROXY.at(asset_1[0])
		TOKEN = await LinkedTKN.at(asset_1[1])
		COLLATERAL = await LinkedCOL.at(asset_1[2])
		CUSTODIAN = await LinkedCUS.at(asset_1[3])
		ORACLE = await LinkedORCL.at(asset_1[4])
		TAXATION = await LinkedTAX.at(asset_1[5])
		DEFCON = await LinkedDEFCON.at(asset_1[6])
		EXCHANGE = await LinkedEXC.at(asset_1[7])

		await ORACLE.updateRate(20000)
	})
	describe('Deposit', function () {
		it("should deposit ETH in exchange", async () => {
			let amountETH = 2000000000000000000
			await EXCHANGE.depositETH({value: amountETH})
			let balance = await web3.eth.getBalance(EXCHANGE.address)
			let ClaimETH = await EXCHANGE.claimOfETH.call(accounts[0])
			assert.equal(balance, amountETH, "Deposit: Balance exchange contract not equal")
			assert.equal(ClaimETH, amountETH, "Deposit: Balance claim not equal")
		});
		it("should deposit tokens in exchange", async () => {
			await ORACLE.updateRate(20000)
			let amount = 20000000000000000000000
			let amountETH = 2000000000000000000
			await COLLATERAL.openCP(amount.toLocaleString('fullwide', { useGrouping: false }), {value: amountETH})
			let amountSell = 10000000000000000000000
			await TOKEN.depositExchange(amountSell.toLocaleString('fullwide', { useGrouping: false }))
			let normRateAfter = await TAXATION.viewNormRateFee.call()
			let ClaimTokens = await EXCHANGE.claimOfTKN.call(accounts[0])
			let normClaimTokens = ClaimTokens * normRateAfter / 10**18
			assert.equal(amountSell.toString(), normClaimTokens.toString(), "Deposit: Tokens not deposited")
			})
	})
	describe('Withdraw', function () {
		it("should withdraw ETH from exchange", async () => {
			let amount = 20000000000000000000000
			let amountETH = 2000000000000000000
			await COLLATERAL.openCP(amount.toLocaleString('fullwide', { useGrouping: false }), {value: amountETH})
			let amountSell = 10000000000000000000000
			await TOKEN.depositExchange(amountSell.toLocaleString('fullwide', { useGrouping: false }))
			await EXCHANGE.depositETH({value: amountETH})
			let balance = await web3.eth.getBalance(accounts[0])
			amountETHBuy = 200000000000000000
			let total = await EXCHANGE.totalReserve.call()
			await EXCHANGE.withdrawETH(amountETHBuy.toLocaleString('fullwide', { useGrouping: false }))
			let balanceNew = await web3.eth.getBalance(accounts[0])
			let balanceDiff = balanceNew - balance
			let balanceDiffCheck = 190000000000000000
			let balanceDiffCheckmax = 200000000000000000
			//Check total reserve
			let totalNEW = await EXCHANGE.totalReserve.call()
			let totalChange = total[0] - totalNEW[0]
			assert(balanceDiff > balanceDiffCheck, "Withdraw ETH: balance change is not 0.2ETH minus gas")
			assert(balanceDiff < balanceDiffCheckmax, "Withdraw ETH: balance change is not 0.2ETH minus gas")
			assert.equal(totalChange, amountETHBuy, "Withdraw ETH: total cchange is not 0.2ETH")
		})
		it("should withdraw tokens from exchange", async () => {
			let base = 10**20
			let BNbase = new BN(web3.utils.toBN(base))
			let total = await EXCHANGE.totalReserve.call()
			let BNtotal = new BN(total[1])
			let totalrounded = BNtotal.div(BNbase)
			let amountTKNBuy = "5000000000000000000000"
			let BNamountTKNBuy = new BN(amountTKNBuy)
			let BNamountTKNBuycheck = BNamountTKNBuy.div(BNbase)
			await EXCHANGE.withdrawTKN(amountTKNBuy.toLocaleString('fullwide', { useGrouping: false }))
			let totalNEW = await EXCHANGE.totalReserve.call()
			let BNtotalNew = new BN(totalNEW[1])
			let totalNEWrounded = BNtotalNew.div(BNbase)
			let totalDiff = totalrounded.sub(totalNEWrounded)
			assert.equal(BNamountTKNBuycheck.toString(), totalDiff.toString(), "Withdraw tokens: change in total balance exchange not equal")
		})
	})
})
contract('LinkedDEFCON', async accounts => {
	let Factory
	let FactoryTKN
	let FactoryCOL
	let FactoryCUS
	let FactoryORCL
	let FactoryTAX
	let FactoryDEFCON
	let FactoryEXC
	let PROXY
	let TOKEN
	let COLLATERAL
	let CUSTODIAN
	let ORACLE
	let TAXATION
	let DEFCON
	let EXCHANGE
	before(async() => {
		Factory = await LinkedFactory.deployed()
		FactoryTKN = await LinkedFactoryTKN.deployed()
		FactoryCOL = await LinkedFactoryCOL.deployed()
		FactoryCUS = await LinkedFactoryCUS.deployed()
		FactoryORCL = await LinkedFactoryORCL.deployed()
		FactoryTAX = await LinkedFactoryTAX.deployed()
		FactoryDEFCON = await LinkedFactoryDEFCON.deployed()
		FactoryEXC = await LinkedFactoryEXC.deployed()
		await Factory.initialize(FactoryTKN.address,
							FactoryCOL.address,
						 	FactoryCUS.address,
						 	FactoryORCL.address,
						 	FactoryTAX.address,
						 	FactoryDEFCON.address,
						 	FactoryEXC.address
						)
		await FactoryTKN.initialize(Factory.address)
		await FactoryCOL.initialize(Factory.address)
		await FactoryCUS.initialize(Factory.address)
		await FactoryORCL.initialize(Factory.address)
		await FactoryTAX.initialize(Factory.address)
		await FactoryDEFCON.initialize(Factory.address)
		await FactoryEXC.initialize(Factory.address)
		
		await Factory.createAsset()
		let asset_1 = await Factory.assets(0)
		PROXY = await LinkedPROXY.at(asset_1[0])
		TOKEN = await LinkedTKN.at(asset_1[1])
		COLLATERAL = await LinkedCOL.at(asset_1[2])
		CUSTODIAN = await LinkedCUS.at(asset_1[3])
		ORACLE = await LinkedORCL.at(asset_1[4])
		TAXATION = await LinkedTAX.at(asset_1[5])
		DEFCON = await LinkedDEFCON.at(asset_1[6])
		EXCHANGE = await LinkedEXC.at(asset_1[7])
		
		let amount = 20000000000000000000000
		let amountETH = 2000000000000000000
		let amountSell = 10000000000000000000000
		await ORACLE.updateRate(20000)
		//Create position 1 for defcon test
		await TOKEN.approve(accounts[1], amount.toLocaleString('fullwide', { useGrouping: false }))
		await COLLATERAL.openCP(amount.toLocaleString('fullwide', { useGrouping: false }), {value: amountETH})
		//Create position 2 and send tokens to exchange for defcon test
		await COLLATERAL.openCP(amount.toLocaleString('fullwide', { useGrouping: false }), {value: amountETH})
		await TOKEN.depositExchange(amountSell.toLocaleString('fullwide', { useGrouping: false }))
	})
	describe('pause()', function () {
		describe('oracle contract', function () {
			it("should not be able to update price rate", async () => {
					await PROXY.activateDefcon()
					await truffleAssert.reverts(ORACLE.updateRate(20100))	
			})
		})
		describe('token contract', function () {
			it("should not be able to transfer tokens", async () => {
					let amount = 20000000000000000000000
					await truffleAssert.reverts(TOKEN.transfer(accounts[1], 
																amount.toLocaleString('fullwide', { useGrouping: false })))
			})
			it("should not be able to transferFrom tokens", async () => {
					let amount = 20000000000000000000000
					await truffleAssert.reverts(TOKEN.transferFrom(accounts[0], 
											   						accounts[1],
																	amount.toLocaleString('fullwide', { useGrouping: false }),
																	{from: accounts[1]}))
			})
		})
		describe('collateral contract', function () {
			it("should not be able to open collateral position", async () => {
					let amount = 20000000000000000000000
					let amountETH = 2000000000000000000
					await truffleAssert.reverts(
						COLLATERAL.openCP(amount.toLocaleString('fullwide', { useGrouping: false }), {value: amountETH})
					)
			})
			it("should not be able to transfer collateral position", async () => {
					await truffleAssert.reverts(
						COLLATERAL.transfer(accounts[1],
											"0"
					))
			})
			it("should not be able to deposit ETH to collateral position", async () => {
					let amountETH = 2000000000000000000
					await truffleAssert.reverts(
						COLLATERAL.depositETHCP("0",
												{value: amountETH}
					))
			})
			it("should not be able to deposit Tokens (burn) to collateral position", async () => {
					let amount = 20000000000000000000000
					await truffleAssert.reverts(
						COLLATERAL.depositTokenCP(
							amount.toLocaleString('fullwide', { useGrouping: false }),
							"0"						
					))	
			})
			it("should not be able to withdraw ETH from collateral position", async () => {
					let amountETH = 200
					await truffleAssert.reverts(
						COLLATERAL.withdrawETHCP(amountETH,
												"0")
					)					
			})
			it("should not be able to withdraw Tokens from collateral position", async () => {
					let amountTKN = 200
					await truffleAssert.reverts(
						COLLATERAL.withdrawTokenCP(amountTKN,
											"0")
					)				
			})	
		})
		describe('exchange contract', function () {
			it("should not be able to deposit exchange tokens", async () => {
					let amountTKN = 200
					await truffleAssert.reverts(
						TOKEN.depositExchange(amountTKN.toLocaleString('fullwide', { useGrouping: false }))
					)		
			})
		})
	});
	describe('setDefcon()', function () {
			it("should return true if defcon is active", async () => {
					let active = await PROXY.defconActive.call()
					assert.equal(active, true, "defcon: Activation failed")
			})
			
			it("should add total ETH and Tokens to defcon contract", async () => {
					await DEFCON.setDefcon()
					let balanceETH = await web3.eth.getBalance(CUSTODIAN.address)
					let balanceETHdefcon = await DEFCON.totalETH.call()
					assert.equal(balanceETH.toString(), balanceETHdefcon.toString(), "defcon: ETH store failed")
			})
			it("should add total Tokens to defcon contract", async () => {
					let balanceTKN = await TOKEN.totalSupply.call()
					let balanceTKNdefcon = await DEFCON.userTokensnorm.call()
					assert.equal(balanceTKN.toString(), balanceTKNdefcon.toString(), "defcon: ETH store failed")
			})
			it("should store safe token amount based on the current price rate", async () => {
					let rate = await PROXY.rate.call()
					let BNrate = new BN(rate.toString())
					let balanceETHdefcon = await DEFCON.totalETH.call()
					let checkSafe =  balanceETHdefcon.mul(BNrate)
					let safeDEFCON = await DEFCON.safe.call()
					assert.equal(safeDEFCON.toString(), checkSafe.toString(), "defcon: eth store safe failed")
			})
			it("should divide ETH over user and CP fair", async () => {
					let balanceETHusr = await DEFCON.totalETHusr.call()
					let balanceETHcp = await DEFCON.totalETHcp.call()
					let balanceETH = await web3.eth.getBalance(CUSTODIAN.address)
					let balanceETHcheck = balanceETHusr.add(balanceETHcp)
					assert.equal(balanceETH.toString(), balanceETHcheck.toString(), "defcon: eth division failed")
			})
	})
	describe('defconClaimUser()', function () {
			it("should withdraw ETH for user", async () => {
					let balanceETHusr = await web3.eth.getBalance(accounts[0])
					let BNold = new BN(balanceETHusr.toString())
					//Send transaction claim and calculate gascost
					let transaction = await DEFCON.defconClaimUser()
					let transaction2 = await web3.eth.getTransaction(transaction.receipt.transactionHash)
					let txt_cost = transaction.receipt.gasUsed * transaction2.gasPrice
					let BNtxt_cost = new BN(txt_cost)
					//Calculate balance ETH change user
					let balanceETHusrNEW = await web3.eth.getBalance(accounts[0])
					let BNnew = new BN(balanceETHusrNEW.toString())
					let balanceUSRdiff = BNnew.sub(BNold).add(BNtxt_cost)
					//Read claimed ETH user
					let claimedETH = await DEFCON.claimedETH.call()
					assert.equal(balanceUSRdiff.toString(), claimedETH.toString(), "defcon: withdraw ETH user failed")
			})
			it("should allow only one withdraw for user", async () => {
					await truffleAssert.reverts(DEFCON.defconClaimUser())	
			})
	})
	describe('defconClaimExc()', function () {
			it("should return portion of ETH to exchange holder", async () => {
					let balanceEXCusr = await web3.eth.getBalance(accounts[0])
					let BNold = new BN(balanceEXCusr.toString())
					let claimedETHold = await DEFCON.claimedETH.call()
					let transaction = await DEFCON.defconClaimExc()
					let transaction2 = await web3.eth.getTransaction(transaction.receipt.transactionHash)
					let txt_cost = transaction.receipt.gasUsed * transaction2.gasPrice
					let BNtxt_cost = new BN(txt_cost)
					//Calculate balance ETH change user
					let balanceEXCuserNEW = await web3.eth.getBalance(accounts[0])
					let BNnew = new BN(balanceEXCuserNEW.toString())
					let claimedETHnew = await DEFCON.claimedETH.call()
					let claimedETHdiff = claimedETHnew.sub(claimedETHold)
					let balanceUSRdiff = BNnew.sub(BNold).add(BNtxt_cost)
					assert.equal(balanceUSRdiff.toString(), claimedETHdiff.toString(), "defcon: withdraw ETH exchange failed")
			})
			it("should allow only one withdraw for exchange token owners", async () => {	
					await truffleAssert.reverts(DEFCON.defconClaimExc())	
			})
	})
	describe('defconClaimCP()', function () {
			it("should return ETH for collateral holder", async () => {
					let balanceCPusr = await web3.eth.getBalance(accounts[0])
					let BNold = new BN(balanceCPusr.toString())
					let claimedETHold = await DEFCON.claimedETH.call()
					let transaction = await DEFCON.defconClaimCP(0)
					let transaction2 = await web3.eth.getTransaction(transaction.receipt.transactionHash)
					let txt_cost = transaction.receipt.gasUsed * transaction2.gasPrice
					let BNtxt_cost = new BN(txt_cost)
					//Calculate balance ETH change user
					let balanceCPuserNEW = await web3.eth.getBalance(accounts[0])
					let BNnew = new BN(balanceCPuserNEW.toString())
					let claimedETHnew = await DEFCON.claimedETH.call()
					let claimedETHdiff = claimedETHnew.sub(claimedETHold)
					let balanceUSRdiff = BNnew.sub(BNold).add(BNtxt_cost)
					assert.equal(balanceUSRdiff.toString(), claimedETHdiff.toString(), "defcon: withdraw ETH CP failed")
			})
			it("should allow only one withdraw for CP owners", async () => {
					await truffleAssert.reverts(DEFCON.defconClaimCP(0))	
			})
	})
})
