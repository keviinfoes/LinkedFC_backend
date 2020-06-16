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

const expect = require('chai').use(require('chai-bn')(web3.utils.BN)).expect

function when(name) {
	return 'when (' + name + ')'
}
contract('LinkedTKN', async accounts => {
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
	let alice = accounts[0];
	let bob = accounts[1];
	let charles = accounts[3]
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


	describe('totalSupply()', function () {
			it('should have initial supply of 0', async () => {
				let totalSupply = await TOKEN.gettotalSupply.call()
				assert.equal(totalSupply, 0, "Initial supply: initial supply not zero")
			})
			it('should return the correct supply after mint (open CP)', async () => {
				let amount = new BN("20000000000000000000000")
				let amountETH = 2000000000000000000
				await COLLATERAL.openCP(amount.toLocaleString('fullwide', { useGrouping: false }), {value: amountETH})
				let totalSupply = await TOKEN.gettotalSupply.call()
				assert.equal(amount.toString(), totalSupply.toString(), "Initial supply: supply not equal after open CP")
				//Add multiple blocks for testing
				await ORACLE.updateRate(20000)
				await ORACLE.updateRate(21000)
				await ORACLE.updateRate(22000)
				let balance = await TOKEN.balanceOf.call(alice)
				let totalSupplyNew = await TOKEN.gettotalSupply.call()
				assert.equal(balance.toString(), totalSupplyNew.toString(), "Initial supply: balance - supply not equal after blocks")
				let totalCOL = await COLLATERAL.dataTotalCP.call()
				let BNtotalCOL = new BN(totalCOL[2])
				let totalTKN = await TOKEN.gettotalSupply.call()
				let BNtotalTKN = new BN(totalTKN)
				let totalDEV = await TOKEN.balanceOfDev.call()
				let BNtotalDEV = new BN(totalDEV)
				let subtotalTKN = BNtotalTKN.add(BNtotalDEV)
				assert.equal(BNtotalCOL.toString(), subtotalTKN.toString(), "Initial supply: total TKN - total COL not equal after burn")
			})
			//PROBLEM TOTAL NOT EQUAL TO CHANGE CP TOKENS
			it('should return the correct supply after burn', async () => {
				//Create two collateral positions for bob (one to burn)
				let amount = 20000000000000000000000
				let amountETH = 2000000000000000000
				let base = 10**18
				let BNbase = new BN(web3.utils.toBN(base))
				await COLLATERAL.openCP(amount.toLocaleString('fullwide', { useGrouping: false }), {from: bob, value: amountETH})
				await COLLATERAL.openCP(amount.toLocaleString('fullwide', { useGrouping: false }), {from: bob, value: amountETH})
				//After withdraw (burn) call - test total coll
				await COLLATERAL.withdrawETHCP(amountETH.toLocaleString('fullwide', { useGrouping: false }), 0, {from: bob})
				let cpAlice0 = await COLLATERAL.cPosition.call(alice, 0, {from: alice})
				let BNcpAlice0 = new BN(cpAlice0[1])
				let cpBOB0 = await COLLATERAL.cPosition.call(bob, 0, {from: bob})
				let BNcpBOB0 = new BN(cpBOB0[1])
				let cpBOB1 = await COLLATERAL.cPosition.call(bob, 1, {from: bob})
				let BNcpBOB1 = new BN(cpBOB1[1])
				let cpTotal = BNcpAlice0.add(BNcpBOB0.add(BNcpBOB1))
				let totalNORMcol = await COLLATERAL.tldata.call()
				assert.equal(cpTotal.toString(), totalNORMcol[2].toString(), "Initial supply: total COL - total individual COL not equal after burn")
				//After withdraw (burn) call - test total tokens
				let balanceAlice = await TOKEN._balances.call(alice)
				let BNbalanceAlice = new BN(balanceAlice)
				let balanceBob = await TOKEN._balances.call(bob)
				let BNbalanceBob = new BN(balanceBob)
				let balanceTotal = BNbalanceAlice.add(BNbalanceBob)
				let totalNORMtoken = await TOKEN.totalSupply.call()
				assert.equal(balanceTotal.toString(), totalNORMtoken.toString(), "Initial supply: total TKN - total individual TKN not equal after burn")
				//Check total collateral contract == total token contract after burn
				let totalCOL = await COLLATERAL.dataTotalCP.call()
				let BNtotalCOL = new BN(totalCOL[2])
				let totalTKN = await TOKEN.gettotalSupply.call()
				let BNtotalTKN = new BN(totalTKN)
				let totalDEV = await TOKEN.balanceOfDev.call()
				let BNtotalDEV = new BN(totalDEV)
				let subtotalTKN = BNtotalTKN.add(BNtotalDEV)
				assert.equal(BNtotalCOL.toString(), subtotalTKN.toString(), "Initial supply: total TKN - total COL not equal after burn")
				assert(totalDEV > 0, "Initial supply: total DEV is negative after burn")
			})
			it('should return the correct supply after transaction', async () => {
				let balanceBob = await TOKEN._balances.call(bob)
				await TOKEN.transfer(alice, balanceBob, {from: bob})
				let balanceAlice = await TOKEN._balances.call(alice)
				let totalTKN = await TOKEN.totalSupply.call()
				assert.equal(balanceAlice.toString(), totalTKN.toString(), "Initial supply: total TKN - total inidividual TKN COL not equal after transfer")
			})
		})
		describe('balanceOf(_owner)', function () {
			it('should return the correct balances after mint', async () => {
				let base = 10**18
				let BNbase = new BN(web3.utils.toBN(base))
				let normFeeOLD = new BN(await TAXATION.viewNormRateFee.call())
				let balanceAliceOLD = await TOKEN.balanceOf(alice)
				let NORMbalanceAliceOLD = balanceAliceOLD.mul(normFeeOLD).div(BNbase)
				let amount = new BN("20000000000000000000000")
				let amountETH = 2000000000000000000
				await COLLATERAL.openCP(amount.toLocaleString('fullwide', { useGrouping: false }), {value: amountETH})
				let normFee = new BN(await TAXATION.viewNormRateFee.call())
				let cpAlice1 = await COLLATERAL.cPosition.call(alice, 1, {from: alice})
				let balanceAlice = await TOKEN.balanceOf(alice)
				let NORMbalanceAlice = balanceAlice.mul(normFee).div(BNbase)
				let NORMdiff = NORMbalanceAlice.sub(NORMbalanceAliceOLD)
				let NORMdiffcheck = amount.mul(normFee).div(BNbase)
				assert.equal(NORMdiff.toString(), NORMdiffcheck.toString(), "balanceOf: Balance after mint not equal")
			})
			it('should return the correct balances after transaction', async () => {
				let base = 10**18
				let BNbase = new BN(web3.utils.toBN(base))
				let normFeeOLD = new BN(await TAXATION.viewNormRateFee.call())
				let balanceAliceOLD = await TOKEN.balanceOf(alice)
				let NORMbalanceAliceOLD = balanceAliceOLD.mul(normFeeOLD).div(BNbase)
				let amount = new BN("20000000000000000000000")
				await TOKEN.transfer(bob, amount.toLocaleString('fullwide', { useGrouping: false }))
				let normFee = new BN(await TAXATION.viewNormRateFee.call())
				let cpAlice1 = await COLLATERAL.cPosition.call(alice, 1, {from: alice})
				let balanceAlice = await TOKEN.balanceOf(alice)
				let NORMbalanceAlice = balanceAlice.mul(normFee).div(BNbase)
				let NORMdiff = NORMbalanceAliceOLD.sub(NORMbalanceAlice)
				let NORMdiffcheck = amount
				assert.equal(NORMdiff.toString(), NORMdiffcheck.toString(), "balanceOf: Balance after transfer not equal")
			})
			it('should return the correct balances after burn', async () => {
				let base = 10**18
				let BNbase = new BN(web3.utils.toBN(base))
				//Read balance and collateral position data
				let normFeeOLD = new BN(await TAXATION.viewNormRateFee.call())
				let balanceAliceOLD = new BN(await TOKEN._balances.call(alice))
				let amountREL = await COLLATERAL.cPosition.call(alice, 0)
				let BNamountNORM = new BN(amountREL[1])
				//Burn transaction
				let amountETH = 2000000000000000000;
				await COLLATERAL.withdrawETHCP(amountETH.toLocaleString('fullwide', { useGrouping: false }), 0)
				//Read balance after burn
				let balanceAliceNEW = new BN(await TOKEN._balances.call(alice))
				//Calculate input value burn
				let normReward = new BN(await TAXATION.viewNormRateReward.call())
				let amountRELnew = BNamountNORM.mul(BNbase).div(normReward)
				//Calculate burn and check match with actual burn
				let normFeeNEW = new BN(await TAXATION.viewNormRateFee.call())
				let amountNORMfee = amountRELnew.mul(normFeeNEW).div(BNbase)
				let balanceDIFF = balanceAliceOLD.sub(balanceAliceNEW)
				assert.equal(amountNORMfee.toString(), balanceDIFF.toString(), "balanceOf: Balance after burn not equal")
			})
		})
		describe('allowance(_owner, _spender)', function () {
			describeIt(when('_owner != _spender'), alice, bob)
			describeIt(when('_owner == _spender'), alice, alice)
			let initialAllowances = [[accounts[0], accounts[1], 0]]
			it('should have correct initial allowance', async function () {
				for (let i = 0; i < initialAllowances.length; i++) {
					let owner = initialAllowances[i][0]
					let spender = initialAllowances[i][1]
					let expectedAllowance = initialAllowances[i][2]
					let BNexpectedAllowance = new BN(expectedAllowance)
						expect(await TOKEN.allowance.call(owner, spender)).to.be.bignumber.equal(BNexpectedAllowance)
				}
			})
			it('should return the correct allowance', async function () {
				let amount = 20000000000000000000000
				await TOKEN.approve(bob, amount.toLocaleString('fullwide', { useGrouping: false }), { from: alice })
				await TOKEN.approve(charles, (amount * 2).toLocaleString('fullwide', { useGrouping: false }), { from: alice })
				await TOKEN.approve(charles, (amount * 3).toLocaleString('fullwide', { useGrouping: false }), { from: bob })
				await TOKEN.approve(alice, (amount * 4).toLocaleString('fullwide', { useGrouping: false }), { from: bob })
				await TOKEN.approve(alice, (amount * 5).toLocaleString('fullwide', { useGrouping: false }), { from: charles })
				await TOKEN.approve(bob, (amount * 6).toLocaleString('fullwide', { useGrouping: false }), { from: charles })
				expect(await TOKEN.allowance.call(alice, bob)).to.be.bignumber.equal((amount).toLocaleString('fullwide', { useGrouping: false }))
				expect(await TOKEN.allowance.call(alice, charles)).to.be.bignumber.equal((amount * 2).toLocaleString('fullwide', { useGrouping: false }))
				expect(await TOKEN.allowance.call(bob, charles)).to.be.bignumber.equal((amount * 3).toLocaleString('fullwide', { useGrouping: false }))
				expect(await TOKEN.allowance.call(bob, alice)).to.be.bignumber.equal((amount * 4).toLocaleString('fullwide', { useGrouping: false }))
				expect(await TOKEN.allowance.call(charles, alice)).to.be.bignumber.equal((amount * 5).toLocaleString('fullwide', { useGrouping: false }))
				expect(await TOKEN.allowance.call(charles, bob)).to.be.bignumber.equal((amount * 6).toLocaleString('fullwide', { useGrouping: false }))
			})
			function describeIt(name, from, to) {
				describe(name, function () {
					let amount = 20000000000000000000000
					it('should return the correct allowance', async function () {
						await TOKEN.approve(to, amount.toLocaleString('fullwide', { useGrouping: false }), { from: from })
						expect(await TOKEN.allowance.call(from, to)).to.be.bignumber.equal(amount.toLocaleString('fullwide', { useGrouping: false }))
					})
				})
			}
		})
		// NOTE: assumes that approve should always succeed
		describe('approve(_spender, _value)', function () {
			let amount = 20000000000000000000000
			describeIt(when('_spender != sender'), alice, bob)
			describeIt(when('_spender == sender'), alice, alice)
			function describeIt(name, from, to) {
				describe(name, function () {
					it('should return true when approving 0', async function () {
						assert.isTrue(await TOKEN.approve.call(to, 0, { from: from }))
					})
					it('should return true when approving', async function () {
						assert.isTrue(await TOKEN.approve.call(to, (amount * 3).toLocaleString('fullwide', { useGrouping: false }), { from: from }))
					})
					it('should return true when updating approval', async function () {
						assert.isTrue(await TOKEN.approve.call(to, (amount * 2).toLocaleString('fullwide', { useGrouping: false }), { from: from }))
						await TOKEN.approve(to, (amount * 2).toLocaleString('fullwide', { useGrouping: false }), { from: from })
						// test decreasing approval
						assert.isTrue(await TOKEN.approve.call(to, (amount).toLocaleString('fullwide', { useGrouping: false }), { from: from }))
						// test not-updating approval
						assert.isTrue(await TOKEN.approve.call(to, (amount * 2).toLocaleString('fullwide', { useGrouping: false }), { from: from }))
						// test increasing approval
						assert.isTrue(await TOKEN.approve.call(to, (amount * 3).toLocaleString('fullwide', { useGrouping: false }), { from: from }))
					})
					it('should return true when revoking approval', async function () {
						await TOKEN.approve(to, (amount * 3).toLocaleString('fullwide', { useGrouping: false }), { from: from })
						assert.isTrue(await TOKEN.approve.call(to, (amount * 3).toLocaleString('fullwide', { useGrouping: false }), { from: from }))
					})
					it('should update allowance accordingly', async function () {
						await TOKEN.approve(to, (amount).toLocaleString('fullwide', { useGrouping: false }), { from: from })
						expect(await TOKEN.allowance(from, to)).to.be.bignumber.equal((amount).toLocaleString('fullwide', { useGrouping: false }))

						await TOKEN.approve(to, (amount * 3).toLocaleString('fullwide', { useGrouping: false }), { from: from })
						expect(await TOKEN.allowance(from, to)).to.be.bignumber.equal((amount * 3).toLocaleString('fullwide', { useGrouping: false }))

						await TOKEN.approve(to, 0, { from: from })
						expect(await TOKEN.allowance(from, to)).to.be.bignumber.equal('0')
					})
					it('should fire Approval event', async function () {
						await testApprovalEvent(from, to, (amount).toLocaleString('fullwide', { useGrouping: false }))
						if (from != to) {
							await testApprovalEvent(to, from, (amount * 2).toLocaleString('fullwide', { useGrouping: false }))
						}
					})
					it('should fire Approval when allowance was set to 0', async function () {
						await TOKEN.approve(to, (amount * 3).toLocaleString('fullwide', { useGrouping: false }), { from: from })
						await testApprovalEvent(from, to, 0)
					})
					it('should fire Approval even when allowance did not change', async function () {
						// even 0 -> 0 should fire Approval event
						await testApprovalEvent(from, to, 0)

						await TOKEN.approve(to, (amount * 3).toLocaleString('fullwide', { useGrouping: false }), { from: from })
						await testApprovalEvent(from, to, (amount * 3).toLocaleString('fullwide', { useGrouping: false }))
					})
				})
			}
			async function testApprovalEvent(from, to, amount) {
				let result = await TOKEN.approve(to, amount, { from: from })
				let log = result.logs[0]
				assert.equal(log.event, 'Approval')
				assert.equal(log.args.owner, from)
				assert.equal(log.args.spender, to)
				let amountBN = new BN(amount)
				expect(log.args.value).to.be.bignumber.equal(amountBN)
			}
		})
		let credit = async function (to, amount, amountETH) {
					await ORACLE.updateRate(20000)
					return await COLLATERAL.openCP(amount, { from: to, value: amountETH})
		}
		let amountETH = 2000000000000000000
		let amount = 20000000000000000000000
		describe('transfer(_to, _value)', function () {
			describeIt(when('_to != sender'), alice, bob)
			describeIt(when('_to == sender'), alice, alice)
			function describeIt(name, from, to) {
				describe(name, function () {
					it('should return true when called with amount of 0', async function () {
						await credit(from,
												(amount * 3).toLocaleString('fullwide', { useGrouping: false }),
												(amountETH * 3).toLocaleString('fullwide', { useGrouping: false })
												);
						assert.isTrue(await TOKEN.transfer.call(to, 0, { from: from }))
					})
					it('should return true when transfer can be made, false otherwise', async function () {
						await credit(from,
												(amount * 3).toLocaleString('fullwide', { useGrouping: false }),
												(amountETH * 3).toLocaleString('fullwide', { useGrouping: false })
												);
						assert.isTrue(await TOKEN.transfer.call(to, (amount).toLocaleString('fullwide', { useGrouping: false }), { from: from }))
						assert.isTrue(await TOKEN.transfer.call(to, (amount * 2).toLocaleString('fullwide', { useGrouping: false }), { from: from }))
						assert.isTrue(await TOKEN.transfer.call(to, (amount * 3).toLocaleString('fullwide', { useGrouping: false }), { from: from }))

						await TOKEN.transfer(to, (amount).toLocaleString('fullwide', { useGrouping: false }), { from: from })
						assert.isTrue(await TOKEN.transfer.call(to, (amount).toLocaleString('fullwide', { useGrouping: false }), { from: from }))
						assert.isTrue(await TOKEN.transfer.call(to, (amount * 2).toLocaleString('fullwide', { useGrouping: false }), { from: from }))
					})
					it('should revert when trying to transfer something while having nothing', async function () {
						//Transfer all balance to other address
						let balance = await TOKEN._balances.call(from)
						await TOKEN.transfer(accounts[4], balance.toLocaleString('fullwide', { useGrouping: false }), {from: from})
						//Test transfer nothing
						await truffleAssert.reverts(TOKEN.transfer(to, (amount).toLocaleString('fullwide', { useGrouping: false }), { from: from }))
					})
					it('should revert when trying to transfer more than balance', async function () {
						await credit(from,
												(amount * 3).toLocaleString('fullwide', { useGrouping: false }),
												(amountETH * 3).toLocaleString('fullwide', { useGrouping: false })
												)
						let balance = await TOKEN._balances.call(from)
						await truffleAssert.reverts(TOKEN.transfer(to, (balance * 2).toLocaleString('fullwide', { useGrouping: false }), { from: from }))
						await TOKEN.transfer('0x0000000000000000000000000000000000000001', (balance/2).toLocaleString('fullwide', { useGrouping: false }), { from: from })
						await truffleAssert.reverts(TOKEN.transfer(to, (balance).toLocaleString('fullwide', { useGrouping: false }), { from: from }))
					})

					it('should not affect totalSupply', async function () {
						await credit(from,
												(amount * 3).toLocaleString('fullwide', { useGrouping: false }),
												(amountETH * 3).toLocaleString('fullwide', { useGrouping: false })
												)
						let supply1 = await TOKEN.totalSupply.call()
						await TOKEN.transfer(to, (amount * 3).toLocaleString('fullwide', { useGrouping: false }), { from: from })
						let supply2 = await TOKEN.totalSupply.call()
						expect(supply2).to.be.be.bignumber.equal(supply1)
					})
					it('should update balances accordingly', async function () {
						await credit(from,
												(amount * 3).toLocaleString('fullwide', { useGrouping: false }),
												(amountETH * 3).toLocaleString('fullwide', { useGrouping: false })
												);
						let fromBalance1 = await TOKEN._balances.call(from)
						let toBalance1 = await TOKEN._balances.call(to)
						await TOKEN.transfer(to, (amount).toLocaleString('fullwide', { useGrouping: false }), { from: from })
						let fromBalance2 = await TOKEN._balances.call(from)
						let toBalance2 = await TOKEN._balances.call(to)
						if (from == to) {
							expect(fromBalance2).to.be.bignumber.equal(fromBalance1)
						}
						else {
							let change = fromBalance1.sub(fromBalance2)
							expect(fromBalance2).to.be.bignumber.equal(fromBalance1.sub(change))
							expect(toBalance2).to.be.bignumber.equal(toBalance1.add(change))
						}
						await TOKEN.transfer(to, (amount * 2).toLocaleString('fullwide', { useGrouping: false }), { from: from })
						let fromBalance3 = await TOKEN._balances.call(from)
						let toBalance3 = await TOKEN._balances.call(to)
						if (from == to) {
							expect(fromBalance3).to.be.bignumber.equal(fromBalance2)
						}
						else {
							let change2 = fromBalance2.sub(fromBalance3)
							expect(fromBalance3).to.be.bignumber.equal(fromBalance2.sub(change2))
							expect(toBalance3).to.be.bignumber.equal(toBalance2.add(change2))
						}
					})
					it('should fire Transfer event', async function () {
						await testTransferEvent(from, to,
																		(amount * 3).toLocaleString('fullwide', { useGrouping: false }),
																		(amountETH * 3).toLocaleString('fullwide', { useGrouping: false }))
					})
					it('should fire Transfer event when transferring amount of 0', async function () {
						await testTransferEvent(from, to, 0)
					})
				})
			}
			async function testTransferEvent(from, to, amount, amountETH) {
				if (amount > 0) {
					await COLLATERAL.openCP((amount*2).toLocaleString('fullwide', { useGrouping: false }),
																	{ from: from, value: (amountETH*2).toLocaleString('fullwide', { useGrouping: false })})
				}
				let result = await TOKEN.transfer(to, amount, { from: from })
				let log = result.logs[0]
				let amountBN = new BN(amount)
				assert.equal(log.event, 'Transfer')
				assert.equal(log.args.from, from)
				assert.equal(log.args.to, to)
				expect(log.args.value).to.be.bignumber.equal(amountBN)
			}
		})
		describe('transferFrom(_from, _to, _value)', function () {
			describeIt(when('_from != _to and _to != sender'), alice, bob, charles)
			describeIt(when('_from != _to and _to == sender'), alice, bob, bob)
			describeIt(when('_from == _to and _to != sender'), alice, alice, bob)
			describeIt(when('_from == _to and _to == sender'), alice, alice, alice)
			it('should revert when trying to transfer while not allowed at all', async function () {
				await credit(alice,
									(amount * 3).toLocaleString('fullwide', { useGrouping: false }),
									(amountETH * 3).toLocaleString('fullwide', { useGrouping: false })
									);
				let alowance = await TOKEN.allowance.call(alice, bob)
				await TOKEN.decreaseAllowance(bob, alowance, {from: alice});
				await truffleAssert.reverts(TOKEN.transferFrom(alice, bob, (amount).toLocaleString('fullwide', { useGrouping: false }), { from: bob }))
				await truffleAssert.reverts(TOKEN.transferFrom(alice, charles, (amount).toLocaleString('fullwide', { useGrouping: false }), { from: bob }))
			})
			it('should fire Transfer event when transferring amount of 0 and sender is not approved', async function () {
				await testTransferEvent(alice, bob, bob, 0, 0)
			})
			function describeIt(name, from, via, to) {
				describe(name, function () {
					beforeEach(async function () {
						// by default approve sender (via) to transfer
						await TOKEN.approve(via, (amount * 3).toLocaleString('fullwide', { useGrouping: false }), { from: from })
					})
					it('should return true when called with amount of 0 and sender is approved', async function () {
						assert.isTrue(await TOKEN.transferFrom.call(from, to, 0, { from: via }))
					})
					it('should return true when called with amount of 0 and sender is not approved', async function () {
						assert.isTrue(await TOKEN.transferFrom.call(to, from, 0, { from: via }))
					})
					it('should return true when transfer can be made, false otherwise', async function () {
						await credit(from,
										(amount * 3).toLocaleString('fullwide', { useGrouping: false }),
										(amountETH * 3).toLocaleString('fullwide', { useGrouping: false })
										)
						assert.isTrue(await TOKEN.transferFrom.call(from, to, (amount).toLocaleString('fullwide', { useGrouping: false }), { from: via }))
						assert.isTrue(await TOKEN.transferFrom.call(from, to, (amount * 2).toLocaleString('fullwide', { useGrouping: false }), { from: via }))
						assert.isTrue(await TOKEN.transferFrom.call(from, to, (amount * 3).toLocaleString('fullwide', { useGrouping: false }), { from: via }))

						await TOKEN.transferFrom(from, to, (amount).toLocaleString('fullwide', { useGrouping: false }), { from: via })
						assert.isTrue(await TOKEN.transferFrom.call(from, to, (amount).toLocaleString('fullwide', { useGrouping: false }), { from: via }))
						assert.isTrue(await TOKEN.transferFrom.call(from, to, (amount * 2).toLocaleString('fullwide', { useGrouping: false }), { from: via }))
					})
					it('should revert when trying to transfer something while _from having nothing', async function () {
						let balance_from = await TOKEN._balances.call(from)
						await TOKEN.transfer(accounts[4], balance_from, {from: from})
						await truffleAssert.reverts(TOKEN.transferFrom(from, to, (amount).toLocaleString('fullwide', { useGrouping: false }), { from: via }))
					})
					it('should revert when trying to transfer more than balance of _from', async function () {
						await credit(from,
										(amount * 3).toLocaleString('fullwide', { useGrouping: false }),
										(amountETH * 3).toLocaleString('fullwide', { useGrouping: false })
										);
						let balance_from = await TOKEN._balances.call(from)
						let send = balance_from * 2
						await truffleAssert.reverts(TOKEN.transferFrom(from, to, (send).toLocaleString('fullwide', { useGrouping: false }), { from: via }))
					})
					it('should revert when trying to transfer more than allowed', async function () {
					await credit(from,
									(amount * 4).toLocaleString('fullwide', { useGrouping: false }),
									(amountETH * 4).toLocaleString('fullwide', { useGrouping: false })
									);
					await truffleAssert.reverts(TOKEN.transferFrom(from, to, (amount * 4).toLocaleString('fullwide', { useGrouping: false }), { from: via }))
					})
					it('should not affect totalSupply', async function () {
						await credit(from,
										(amount * 3).toLocaleString('fullwide', { useGrouping: false }),
										(amountETH * 3).toLocaleString('fullwide', { useGrouping: false })
										);
						let supply1 = await TOKEN.totalSupply.call()
						await TOKEN.transferFrom(from, to, (amount * 3).toLocaleString('fullwide', { useGrouping: false }), { from: via })
						let supply2 = await TOKEN.totalSupply.call()
						expect(supply2).to.be.be.bignumber.equal(supply1)
					})
					it('should update balances accordingly', async function () {
						await credit(from,
										(amount * 3).toLocaleString('fullwide', { useGrouping: false }),
										(amountETH * 3).toLocaleString('fullwide', { useGrouping: false })
										);
						let fromBalance1 = await TOKEN._balances.call(from)
						let viaBalance1 = await TOKEN._balances.call(via)
						let toBalance1 = await TOKEN._balances.call(to)
						await TOKEN.transferFrom(from, to, (amount).toLocaleString('fullwide', { useGrouping: false }), { from: via })
						let fromBalance2 = await TOKEN._balances.call(from)
						let viaBalance2 = await TOKEN._balances.call(via)
						let toBalance2 = await TOKEN._balances.call(to)
						if (from == to) {
							expect(fromBalance2).to.be.bignumber.equal(fromBalance1)
						}
						else {
							let change = fromBalance1.sub(fromBalance2)
							expect(fromBalance2).to.be.bignumber.equal(fromBalance1.sub(change))
							expect(toBalance2).to.be.bignumber.equal(toBalance1.add(change))
						}
						if (via != from && via != to) {
							expect(viaBalance2).to.be.bignumber.equal(viaBalance1)
						}
						await TOKEN.transferFrom(from, to, (amount * 2).toLocaleString('fullwide', { useGrouping: false }), { from: via })
						let fromBalance3 = await TOKEN._balances.call(from)
						let viaBalance3 = await TOKEN._balances.call(via)
						let toBalance3 = await TOKEN._balances.call(to)
						if (from == to) {
							expect(fromBalance3).to.be.bignumber.equal(fromBalance2)
						}
						else {
							let change2 = fromBalance2.sub(fromBalance3)
							expect(fromBalance3).to.be.bignumber.equal(fromBalance2.sub(change2))
							expect(toBalance3).to.be.bignumber.equal(toBalance2.add(change2))
						}
						if (via != from && via != to) {
							expect(viaBalance3).to.be.bignumber.equal(viaBalance2)
						}
					})
					it('should update allowances accordingly', async function () {
						await credit(from,
									(amount * 3).toLocaleString('fullwide', { useGrouping: false }),
									(amountETH * 3).toLocaleString('fullwide', { useGrouping: false })
									);
						let viaAllowance1 = await TOKEN.allowance.call(from, via)
						let toAllowance1 = await TOKEN.allowance.call(from, to)
						let amountBN = new BN('20000000000000000000000')
						await TOKEN.transferFrom(from, to, (amount * 2).toLocaleString('fullwide', { useGrouping: false }), { from: via })
						let viaAllowance2 = await TOKEN.allowance.call(from, via)
						let toAllowance2 = await TOKEN.allowance.call(from, to)
						expect(viaAllowance2).to.be.bignumber.equal(viaAllowance1.sub((amountBN.mul(new BN('2')))))
						if (to != via) {
							expect(toAllowance2).to.be.bignumber.equal(toAllowance1)
						}
						await TOKEN.transferFrom(from, to, (amount).toLocaleString('fullwide', { useGrouping: false }), { from: via })
						let viaAllowance3 = await TOKEN.allowance.call(from, via)
						let toAllowance3 = await TOKEN.allowance.call(from, to)
						expect(viaAllowance3).to.be.bignumber.equal(viaAllowance2.sub((amountBN)))
						if (to != via) {
							expect(toAllowance3).to.be.bignumber.equal(toAllowance1)
						}
					})
					it('should fire Transfer event', async function () {
						await testTransferEvent(from, via, to,
						 												(amount * 3).toLocaleString('fullwide', { useGrouping: false }),
																		(amountETH * 3).toLocaleString('fullwide', { useGrouping: false })
																	)
					})
					it('should fire Transfer event when transferring amount of 0', async function () {
						await testTransferEvent(from, via, to, 0, 0)
					})
				})
			}
			async function testTransferEvent(from, via, to, amount, amountETH) {
				if (amount > 0) {
					await COLLATERAL.openCP((amount*2).toLocaleString('fullwide', { useGrouping: false }),
																	{ from: from, value: (amountETH*2).toLocaleString('fullwide', { useGrouping: false })});
				}
				let result = await TOKEN.transferFrom(from, to, amount, { from: via })
				let log = result.logs[1]
				let amountBN = new BN(amount)
				assert.equal(log.event, 'Transfer')
				assert.equal(log.args.from, from)
				assert.equal(log.args.to, to)
				expect(log.args.value).to.be.bignumber.equal(amountBN)
			}
	})
	describe('devclaim', function () {
		it('should return devclaim as difference between total collateral and tokens', async () => {
			let devaddress = await PROXY.readAddress.call()
			let devclaim = await TOKEN.balanceOfDev.call()
			let totalSupplyCOL = await COLLATERAL.dataTotalCP.call()
			let totalSupplyTKN = await TOKEN.gettotalSupply.call()
			let totalSupplyDIF = totalSupplyCOL[2].sub(totalSupplyTKN)
			assert.equal(totalSupplyDIF.toString(), devclaim.toString(), "devclaim: claim is not the difference in totalsupply");
		})
		it('should add devclaim to balance of dev', async () => {
			let devaddress = await PROXY.readAddress.call()
			let totalSupply = await TOKEN.totalSupply.call()
			let devbalance = await TOKEN._balances.call(devaddress[7])
			await TOKEN.devClaim()
			let totalSupplyNEW = await TOKEN.totalSupply.call()
			let devbalanceNEW = await TOKEN._balances.call(devaddress[7])
			let totalDIF = totalSupplyNEW.sub(totalSupply)
			let balanceDIF = devbalanceNEW.sub(devbalance)
			assert.equal(totalDIF.toString(), balanceDIF.toString(), "decvlaim: balance is not added to dev correctly")
			let devclaim = await TOKEN.balanceOfDev.call()
			let totalSupplyTKN = await TOKEN.gettotalSupply.call()
			let totalSupplyCOL = await COLLATERAL.dataTotalCP.call()
			let totalCheck = totalSupplyCOL[2].sub(totalSupplyTKN)
			assert.equal(totalCheck.toString(), devclaim.toString(), "decvlaim: new claim is not difference totalsupply")
		})
	})
	describe('update fee', function () {
		it('should update the fee from 0 to 1 finney', async () => {
			let amount = 1000000000000000
			await TOKEN.ethFee(amount)
			let fee = await TOKEN.FEE_ETH.call()
			assert.equal(fee.toString(), amount.toString(), "update fee: ETH transaction fee not updated")	
		})
		it('should fail transfer fee paid < 1 finney and succeed fee > 1', async () => {
			await TOKEN.transfer(accounts[1], 10, {value: 1000000000000000})
			await truffleAssert.reverts(TOKEN.transfer(accounts[0], 10))
		})	
	})
})
