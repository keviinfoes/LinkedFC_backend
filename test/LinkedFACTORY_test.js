const LinkedFactory = artifacts.require("LinkedFactory")
const LinkedFactoryTKN = artifacts.require("LinkedFactoryTKN")
const LinkedFactoryCOL = artifacts.require("LinkedFactoryCOL")
const LinkedFactoryCUS = artifacts.require("LinkedFactoryCUS")
const LinkedFactoryORCL = artifacts.require("LinkedFactoryORCL")
const LinkedFactoryTAX = artifacts.require("LinkedFactoryTAX")
const LinkedFactoryDEFCON = artifacts.require("LinkedFactoryDEFCON")
const LinkedFactoryEXC = artifacts.require("LinkedFactoryEXC")
const LinkedPROXY = artifacts.require("LinkedPROXY");

const truffleAssert = require('truffle-assertions')
//const BN = require('bn.js')
//const expect = require('chai').use(require('chai-bn')(web3.utils.BN)).expect

contract('LinkedFactory', async accounts => {
	let Factory
	let FactoryTKN
	let FactoryCOL
	let FactoryCUS
	let FactoryORCL
	let FactoryTAX
	let FactoryDEFCON
	let FactoryEXC
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
	})
	describe('DeployFactory()', function () {
		it('should deploy and initialize main factory', async () => {
			let initialized = await Factory.initialized()
			let token_initialized = await Factory.token()
			let collateral_initialized = await Factory.collateral()
			let custodian_initialized = await Factory.custodian()
			let oracle_initialized = await Factory.oracle()
			let tax_initialized = await Factory.tax()
			let defcon_initialized = await Factory.defcon()
			let exchange_initialized = await Factory.exchange()
			assert.equal(initialized, true ,"DeployFactory(): Initialized main is not called")
			assert.equal(token_initialized, FactoryTKN.address, "DeployFactory(): Initialized main TKN is not set")
			assert.equal(collateral_initialized, FactoryCOL.address, "DeployFactory(): Initialized main COL is not set")
			assert.equal(custodian_initialized, FactoryCUS.address, "DeployFactory(): Initialized main CUS is not set")
			assert.equal(oracle_initialized, FactoryORCL.address, "DeployFactory(): Initialized main ORCL is not set")
			assert.equal(tax_initialized, FactoryTAX.address, "DeployFactory(): Initialized main TAX is not set")
			assert.equal(defcon_initialized, FactoryDEFCON.address, "DeployFactory(): Initialized main DEFCON is not set")
			assert.equal(exchange_initialized, FactoryEXC.address, "DeployFactory(): Initialized main EXC is not set")
		})
		it('should deploy and initialize other factories', async () => {
			let TKN_initialized = await FactoryTKN.initialized()
			let COL_initialized = await FactoryCOL.initialized()
			let CUS_initialized = await FactoryCUS.initialized()
			let ORCL_initialized = await FactoryORCL.initialized()
			let TAX_initialized = await FactoryTAX.initialized()
			let DEFCON_initialized = await FactoryDEFCON.initialized()
			let EXC_initialized = await FactoryEXC.initialized()
			let TKN_MAIN_initialized = await FactoryTKN.mainFactory()
			let COL_MAIN_initialized = await FactoryCOL.mainFactory()
			let CUS_MAIN_initialized = await FactoryCUS.mainFactory()
			let ORCL_MAIN_initialized = await FactoryORCL.mainFactory()
			let TAX_MAIN_initialized = await FactoryTAX.mainFactory()
			let DEFCON_MAIN_initialized = await FactoryDEFCON.mainFactory()
			let EXC_MAIN_initialized = await FactoryEXC.mainFactory()
			assert.equal(TKN_initialized, true, "DeployFactory(): Initialized TKN is not called")
			assert.equal(COL_initialized, true, "DeployFactory(): Initialized COL is not called")
			assert.equal(CUS_initialized, true, "DeployFactory(): Initialized CUS is not called")
			assert.equal(ORCL_initialized, true, "DeployFactory(): Initialized ORCL is not called")
			assert.equal(TAX_initialized, true, "DeployFactory(): Initialized TAX is not called")
			assert.equal(DEFCON_initialized, true, "DeployFactory(): Initialized DEFCON is not called")
			assert.equal(EXC_initialized, true, "DeployFactory(): Initialized EXC is not called")
			assert.equal(TKN_MAIN_initialized, Factory.address, "DeployFactory(): Initialized TKN MAIN is not set")
			assert.equal(COL_MAIN_initialized, Factory.address, "DeployFactory(): Initialized COL MAIN is not set")
			assert.equal(CUS_MAIN_initialized, Factory.address, "DeployFactory(): Initialized CUS MAIN is not set")
			assert.equal(ORCL_MAIN_initialized, Factory.address, "DeployFactory(): Initialized ORCL MAIN is not set")
			assert.equal(TAX_MAIN_initialized, Factory.address, "DeployFactory(): Initialized TAX MAIN is not set")
			assert.equal(DEFCON_MAIN_initialized, Factory.address, "DeployFactory(): Initialized DEFCON MAIN is not set")
			assert.equal(EXC_MAIN_initialized, Factory.address, "DeployFactory(): Initialized EXC MAIN is not set")
		})	
		it('should FAIL second initialize main and other factories', async () => {
			await truffleAssert.reverts(Factory.initialize(accounts[0], 
																accounts[0],
																accounts[0],
																accounts[0],
																accounts[0],
																accounts[0],
																accounts[0]
																))	
			await truffleAssert.reverts(FactoryTKN.initialize(accounts[0]))
			await truffleAssert.reverts(FactoryCOL.initialize(accounts[0]))
			await truffleAssert.reverts(FactoryCUS.initialize(accounts[0]))
			await truffleAssert.reverts(FactoryORCL.initialize(accounts[0]))
			await truffleAssert.reverts(FactoryTAX.initialize(accounts[0]))
			await truffleAssert.reverts(FactoryDEFCON.initialize(accounts[0]))
			await truffleAssert.reverts(FactoryEXC.initialize(accounts[0]))
		})		
	})
	describe('CreateAsset()', function () {
		it('should create new asset', async () => {
			await Factory.createAsset()
			let id = await Factory.id()
			assert.equal(id, 1, "CreateAsset(): Asset is not created")
		})
		it('should store data new asset', async () => {
			let asset_1 = await Factory.assets(0)
			const proxy_contract = await LinkedPROXY.at(asset_1[0])
			let system_addresses = await proxy_contract.readAddress()
			assert.equal(system_addresses[0], asset_1[1], "CreateAsset(): Asset is not stored TKN")
			assert.equal(system_addresses[1], asset_1[2], "CreateAsset(): Asset is not stored COL")
			assert.equal(system_addresses[2], asset_1[3], "CreateAsset(): Asset is not stored CUS")
			assert.equal(system_addresses[3], asset_1[4], "CreateAsset(): Asset is not stored ORCL")
			assert.equal(system_addresses[4], asset_1[5], "CreateAsset(): Asset is not stored TAX")
			assert.equal(system_addresses[5], asset_1[6], "CreateAsset(): Asset is not stored DEFCON")
			assert.equal(system_addresses[6], asset_1[7], "CreateAsset(): Asset is not stored EXC")
		})
	})
});
