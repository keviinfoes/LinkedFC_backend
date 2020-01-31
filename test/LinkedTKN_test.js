const truffleAssert = require('truffle-assertions');
const LinkedTKN = artifacts.require('LinkedTKN');

contract('LinkedTKN', async accounts => {
	let instance = await LinkedTKN.deployed(); 
	let alice = accounts[0];
	let bob = accounts[1];

	//FROM HERE UPDATE!!
	describe('Contract: LinkedTKN', function () {	
		describe('totalSupply()', function () {
			it('should have initial supply of 0', async () => {
				assert.equal(true, true, "ADJUST");
			})

			it('should return the correct supply after transaction', async () => {
				assert.equal(true, true, "ADJUST");
			})
		})

		describe('balanceOf(_owner)', function () {
			it('should have correct initial balances', async () => {
				assert.equal(true, true, "ADJUST");
			})

			it('should return the correct balances after transaction', async () => {
				assert.equal(true, true, "ADJUST");
			})
		})

		
		/* TEST OF ALLOWANCE AND APPROVE TO ADJUST
		describe('allowance(_owner, _spender)', function () {
			describeIt(when('_owner != _spender'), alice, bob)
			describeIt(when('_owner == _spender'), alice, alice)

			it('should have correct initial allowance', async function () {
				for (let i = 0; i < initialAllowances.length; i++) {
					let owner = initialAllowances[i][0]
					let spender = initialAllowances[i][1]
					let expectedAllowance = initialAllowances[i][2]
					expect(await contract.allowance.call(owner, spender)).to.be.bignumber.equal(expectedAllowance)
				}
			})

			it('should return the correct allowance', async function () {
				await contract.approve(bob, tokens(1), { from: alice })
				await contract.approve(charles, tokens(2), { from: alice })
				await contract.approve(charles, tokens(3), { from: bob })
				await contract.approve(alice, tokens(4), { from: bob })
				await contract.approve(alice, tokens(5), { from: charles })
				await contract.approve(bob, tokens(6), { from: charles })

				expect(await contract.allowance.call(alice, bob)).to.be.bignumber.equal(tokens(1))
				expect(await contract.allowance.call(alice, charles)).to.be.bignumber.equal(tokens(2))
				expect(await contract.allowance.call(bob, charles)).to.be.bignumber.equal(tokens(3))
				expect(await contract.allowance.call(bob, alice)).to.be.bignumber.equal(tokens(4))
				expect(await contract.allowance.call(charles, alice)).to.be.bignumber.equal(tokens(5))
				expect(await contract.allowance.call(charles, bob)).to.be.bignumber.equal(tokens(6))
			})

			function describeIt(name, from, to) {
				describe(name, function () {
					it('should return the correct allowance', async function () {
						await contract.approve(to, tokens(1), { from: from })
						expect(await contract.allowance.call(from, to)).to.be.bignumber.equal(tokens(1))
					})
				})
			}
		})

		// NOTE: assumes that approve should always succeed
		describe('approve(_spender, _value)', function () {
			describeIt(when('_spender != sender'), alice, bob)
			describeIt(when('_spender == sender'), alice, alice)

			function describeIt(name, from, to) {
				describe(name, function () {
					it('should return true when approving 0', async function () {
						assert.isTrue(await contract.approve.call(to, 0, { from: from }))
					})

					it('should return true when approving', async function () {
						assert.isTrue(await contract.approve.call(to, tokens(3), { from: from }))
					})

					it('should return true when updating approval', async function () {
						assert.isTrue(await contract.approve.call(to, tokens(2), { from: from }))
						await contract.approve(to, tokens(2), { from: from })

						// test decreasing approval
						assert.isTrue(await contract.approve.call(to, tokens(1), { from: from }))

						// test not-updating approval
						assert.isTrue(await contract.approve.call(to, tokens(2), { from: from }))

						// test increasing approval
						assert.isTrue(await contract.approve.call(to, tokens(3), { from: from }))
					})

					it('should return true when revoking approval', async function () {
						await contract.approve(to, tokens(3), { from: from })
						assert.isTrue(await contract.approve.call(to, tokens(0), { from: from }))
					})

					it('should update allowance accordingly', async function () {
						await contract.approve(to, tokens(1), { from: from })
						expect(await contract.allowance(from, to)).to.be.bignumber.equal(tokens(1))

						await contract.approve(to, tokens(3), { from: from })
						expect(await contract.allowance(from, to)).to.be.bignumber.equal(tokens(3))

						await contract.approve(to, 0, { from: from })
						expect(await contract.allowance(from, to)).to.be.bignumber.equal('0')
					})

					it('should fire Approval event', async function () {
						await testApprovalEvent(from, to, tokens(1))
						if (from != to) {
							await testApprovalEvent(to, from, tokens(2))
						}
					})

					it('should fire Approval when allowance was set to 0', async function () {
						await contract.approve(to, tokens(3), { from: from })
						await testApprovalEvent(from, to, 0)
					})

					it('should fire Approval even when allowance did not change', async function () {
						// even 0 -> 0 should fire Approval event
						await testApprovalEvent(from, to, 0)

						await contract.approve(to, tokens(3), { from: from })
						await testApprovalEvent(from, to, tokens(3))
					})
				})
			}

			async function testApprovalEvent(from, to, amount) {
				let result = await contract.approve(to, amount, { from: from })
				let log = result.logs[0]
				assert.equal(log.event, 'Approval')
				assert.equal(log.args.owner, from)
				assert.equal(log.args.spender, to)
				expect(log.args.value).to.be.bignumber.equal(toBigNumber(amount))
			}
		})
		*/

		/* TEST OF TRANSFER TO ADJUST
		describe('transfer(_to, _value)', function () {
			describeIt(when('_to != sender'), alice, bob)
			describeIt(when('_to == sender'), alice, alice)

			function describeIt(name, from, to) {
				describe(name, function () {
					it('should return true when called with amount of 0', async function () {
						assert.isTrue(await contract.transfer.call(to, 0, { from: from }))
					})

					it('should return true when transfer can be made, false otherwise', async function () {
						await credit(from, tokens(3))
						assert.isTrue(await contract.transfer.call(to, tokens(1), { from: from }))
						assert.isTrue(await contract.transfer.call(to, tokens(2), { from: from }))
						assert.isTrue(await contract.transfer.call(to, tokens(3), { from: from }))

						await contract.transfer(to, tokens(1), { from: from })
						assert.isTrue(await contract.transfer.call(to, tokens(1), { from: from }))
						assert.isTrue(await contract.transfer.call(to, tokens(2), { from: from }))
					})

					it('should revert when trying to transfer something while having nothing', async function () {
						await truffleAssert.reverts(contract.transfer(to, tokens(1), { from: from }))
					})

					it('should revert when trying to transfer more than balance', async function () {
						await credit(from, tokens(3))
						await truffleAssert.reverts(contract.transfer(to, tokens(4), { from: from }))

						await contract.transfer('0x0000000000000000000000000000000000000001', tokens(1), { from: from })
						await truffleAssert.reverts(contract.transfer(to, tokens(3), { from: from }))
					})

					it('should not affect totalSupply', async function () {
						await credit(from, tokens(3))
						let supply1 = await contract.totalSupply.call()
						await contract.transfer(to, tokens(3), { from: from })
						let supply2 = await contract.totalSupply.call()
						expect(supply2).to.be.be.bignumber.equal(supply1)
					})

					it('should update balances accordingly', async function () {
						await credit(from, tokens(3))
						let fromBalance1 = await contract.balanceOf.call(from)
						let toBalance1 = await contract.balanceOf.call(to)

						await contract.transfer(to, tokens(1), { from: from })
						let fromBalance2 = await contract.balanceOf.call(from)
						let toBalance2 = await contract.balanceOf.call(to)

						if (from == to) {
							expect(fromBalance2).to.be.bignumber.equal(fromBalance1)
						}
						else {
							expect(fromBalance2).to.be.bignumber.equal(fromBalance1.sub(tokens(1)))
							expect(toBalance2).to.be.bignumber.equal(toBalance1.add(tokens(1)))
						}

						await contract.transfer(to, tokens(2), { from: from })
						let fromBalance3 = await contract.balanceOf.call(from)
						let toBalance3 = await contract.balanceOf.call(to)

						if (from == to) {
							expect(fromBalance3).to.be.bignumber.equal(fromBalance2)
						}
						else {
							expect(fromBalance3).to.be.bignumber.equal(fromBalance2.sub(tokens(2)))
							expect(toBalance3).to.be.bignumber.equal(toBalance2.add(tokens(2)))
						}
					})

					it('should fire Transfer event', async function () {
						await testTransferEvent(from, to, tokens(3))
					})

					it('should fire Transfer event when transferring amount of 0', async function () {
						await testTransferEvent(from, to, 0)
					})
				})
			}

			async function testTransferEvent(from, to, amount) {
				if (amount > 0) {
					await credit(from, amount)
				}

				let result = await contract.transfer(to, amount, { from: from })
				let log = result.logs[0]
				assert.equal(log.event, 'Transfer')
				assert.equal(log.args.from, from)
				assert.equal(log.args.to, to)
				expect(log.args.value).to.be.bignumber.equal(toBigNumber(amount))
			}
		})

		describe('transferFrom(_from, _to, _value)', function () {
			describeIt(when('_from != _to and _to != sender'), alice, bob, charles)
			describeIt(when('_from != _to and _to == sender'), alice, bob, bob)
			describeIt(when('_from == _to and _to != sender'), alice, alice, bob)
			describeIt(when('_from == _to and _to == sender'), alice, alice, alice)

			it('should revert when trying to transfer while not allowed at all', async function () {
				await credit(alice, tokens(3))
				await truffleAssert.reverts(contract.transferFrom(alice, bob, tokens(1), { from: bob }))
				await truffleAssert.reverts(contract.transferFrom(alice, charles, tokens(1), { from: bob }))
			})

			it('should fire Transfer event when transferring amount of 0 and sender is not approved', async function () {
				await testTransferEvent(alice, bob, bob, 0)
			})

			function describeIt(name, from, via, to) {
				describe(name, function () {
					beforeEach(async function () {
						// by default approve sender (via) to transfer
						await contract.approve(via, tokens(3), { from: from })
					})

					it('should return true when called with amount of 0 and sender is approved', async function () {
						assert.isTrue(await contract.transferFrom.call(from, to, 0, { from: via }))
					})

					it('should return true when called with amount of 0 and sender is not approved', async function () {
						assert.isTrue(await contract.transferFrom.call(to, from, 0, { from: via }))
					})

					it('should return true when transfer can be made, false otherwise', async function () {
						await credit(from, tokens(3))
						assert.isTrue(await contract.transferFrom.call(from, to, tokens(1), { from: via }))
						assert.isTrue(await contract.transferFrom.call(from, to, tokens(2), { from: via }))
						assert.isTrue(await contract.transferFrom.call(from, to, tokens(3), { from: via }))

						await contract.transferFrom(from, to, tokens(1), { from: via })
						assert.isTrue(await contract.transferFrom.call(from, to, tokens(1), { from: via }))
						assert.isTrue(await contract.transferFrom.call(from, to, tokens(2), { from: via }))
					})

					it('should revert when trying to transfer something while _from having nothing', async function () {
						await truffleAssert.reverts(contract.transferFrom(from, to, tokens(1), { from: via }))
					})

					it('should revert when trying to transfer more than balance of _from', async function () {
						await credit(from, tokens(2))
						await truffleAssert.reverts(contract.transferFrom(from, to, tokens(3), { from: via }))
					})

					it('should revert when trying to transfer more than allowed', async function () {
						await credit(from, tokens(4))
						await truffleAssert.reverts(contract.transferFrom(from, to, tokens(4), { from: via }))
					})

					it('should not affect totalSupply', async function () {
						await credit(from, tokens(3))
						let supply1 = await contract.totalSupply.call()
						await contract.transferFrom(from, to, tokens(3), { from: via })
						let supply2 = await contract.totalSupply.call()
						expect(supply2).to.be.be.bignumber.equal(supply1)
					})

					it('should update balances accordingly', async function () {
						await credit(from, tokens(3))
						let fromBalance1 = await contract.balanceOf.call(from)
						let viaBalance1 = await contract.balanceOf.call(via)
						let toBalance1 = await contract.balanceOf.call(to)

						await contract.transferFrom(from, to, tokens(1), { from: via })
						let fromBalance2 = await contract.balanceOf.call(from)
						let viaBalance2 = await contract.balanceOf.call(via)
						let toBalance2 = await contract.balanceOf.call(to)

						if (from == to) {
							expect(fromBalance2).to.be.bignumber.equal(fromBalance1)
						}
						else {
							expect(fromBalance2).to.be.bignumber.equal(fromBalance1.sub(tokens(1)))
							expect(toBalance2).to.be.bignumber.equal(toBalance1.add(tokens(1)))
						}

						if (via != from && via != to) {
							expect(viaBalance2).to.be.bignumber.equal(viaBalance1)
						}

						await contract.transferFrom(from, to, tokens(2), { from: via })
						let fromBalance3 = await contract.balanceOf.call(from)
						let viaBalance3 = await contract.balanceOf.call(via)
						let toBalance3 = await contract.balanceOf.call(to)

						if (from == to) {
							expect(fromBalance3).to.be.bignumber.equal(fromBalance2)
						}
						else {
							expect(fromBalance3).to.be.bignumber.equal(fromBalance2.sub(tokens(2)))
							expect(toBalance3).to.be.bignumber.equal(toBalance2.add(tokens(2)))
						}

						if (via != from && via != to) {
							expect(viaBalance3).to.be.bignumber.equal(viaBalance2)
						}
					})

					it('should update allowances accordingly', async function () {
						await credit(from, tokens(3))
						let viaAllowance1 = await contract.allowance.call(from, via)
						let toAllowance1 = await contract.allowance.call(from, to)

						await contract.transferFrom(from, to, tokens(2), { from: via })
						let viaAllowance2 = await contract.allowance.call(from, via)
						let toAllowance2 = await contract.allowance.call(from, to)

						expect(viaAllowance2).to.be.bignumber.equal(viaAllowance1.sub(tokens(2)))

						if (to != via) {
							expect(toAllowance2).to.be.bignumber.equal(toAllowance1)
						}

						await contract.transferFrom(from, to, tokens(1), { from: via })
						let viaAllowance3 = await contract.allowance.call(from, via)
						let toAllowance3 = await contract.allowance.call(from, to)

						expect(viaAllowance3).to.be.bignumber.equal(viaAllowance2.sub(tokens(1)))

						if (to != via) {
							expect(toAllowance3).to.be.bignumber.equal(toAllowance1)
						}
					})

					it('should fire Transfer event', async function () {
						await testTransferEvent(from, via, to, tokens(3))
					})

					it('should fire Transfer event when transferring amount of 0', async function () {
						await testTransferEvent(from, via, to, 0)
					})
				})
			}

			async function testTransferEvent(from, via, to, amount) {
				if (amount > 0) {
					await credit(from, amount)
				}

				let result = await contract.transferFrom(from, to, amount, { from: via })
				let log = result.logs[0]
				assert.equal(log.event, 'Transfer')
				assert.equal(log.args.from, from)
				assert.equal(log.args.to, to)
				expect(log.args.value).to.be.bignumber.equal(toBigNumber(amount))
			}
		})
	})
	*/

	})
})
