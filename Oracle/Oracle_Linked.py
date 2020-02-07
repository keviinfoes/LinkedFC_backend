#Price Oracle for the  Banq Linked stablecoin - Ropsten
from web3 import Web3
from coinbase.wallet.client import Client

#Coinbase API
client = Client("[API_ACCOUNT]", "[API_SECRET]")

#Web3 data
Web3_provider = "https://ropsten.infura.io/v3/[INFURA ID]"
PubKey = "[PUBLIC KEY]"
PrivKey = "[PRIVATE. KEY]"
web3 = Web3(Web3.HTTPProvider(Web3_provider))

#Connect to the Linked collateral contract - To view current USD price
abi_LinkedPROXY = '''[{"constant":true,"inputs":[],"name":"initialized","outputs":[{"internalType":"bool","name":"","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"defcon","outputs":[{"internalType":"address payable","name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"rate","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"readAddress","outputs":[{"internalType":"address payable[8]","name":"","type":"address[8]"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"custodian","outputs":[{"internalType":"address payable","name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[],"name":"unpause","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"internalType":"address","name":"account","type":"address"}],"name":"isPauser","outputs":[{"internalType":"bool","name":"","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"internalType":"address payable","name":"oracleAddress","type":"address"}],"name":"changeOracle","outputs":[{"internalType":"bool","name":"success","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"startBlock","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"base","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"paused","outputs":[{"internalType":"bool","name":"","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"internalType":"uint256","name":"newRate","type":"uint256"}],"name":"updateRate","outputs":[{"internalType":"bool","name":"success","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[],"name":"renouncePauser","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[],"name":"renounceOwnership","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"oracle","outputs":[{"internalType":"address payable","name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"internalType":"address","name":"account","type":"address"}],"name":"addPauser","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[],"name":"pause","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"internalType":"address payable","name":"tokenAddress","type":"address"},{"internalType":"address payable","name":"collateralAddress","type":"address"},{"internalType":"address payable","name":"custodianAddress","type":"address"},{"internalType":"address payable","name":"oracleAddress","type":"address"},{"internalType":"address payable","name":"taxAddress","type":"address"},{"internalType":"address payable","name":"defconAddress","type":"address"},{"internalType":"address payable","name":"exchangeAddress","type":"address"},{"internalType":"address payable","name":"devAddress","type":"address"}],"name":"initialize","outputs":[{"internalType":"bool","name":"succes","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"internalType":"address","name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"isOwner","outputs":[{"internalType":"bool","name":"","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"dev","outputs":[{"internalType":"address payable","name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"tax","outputs":[{"internalType":"address payable","name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[],"name":"activateDefcon","outputs":[{"internalType":"bool","name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"checkPause","outputs":[{"internalType":"bool","name":"","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"exchange","outputs":[{"internalType":"address payable","name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"collateral","outputs":[{"internalType":"address payable","name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"defconActive","outputs":[{"internalType":"bool","name":"","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"internalType":"address","name":"newOwner","type":"address"}],"name":"transferOwnership","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"token","outputs":[{"internalType":"address payable","name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"uint256","name":"Rate","type":"uint256"}],"name":"UpdateRate","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"address","name":"account","type":"address"}],"name":"Paused","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"address","name":"account","type":"address"}],"name":"Unpaused","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"account","type":"address"}],"name":"PauserAdded","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"account","type":"address"}],"name":"PauserRemoved","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"previousOwner","type":"address"},{"indexed":true,"internalType":"address","name":"newOwner","type":"address"}],"name":"OwnershipTransferred","type":"event"}]'''
address_LinkedPROXY = web3.toChecksumAddress("0x8BCcDa0e784BC60DDC545B40A752D486FC8250fB")
contract_LinkedPROXY = web3.eth.contract(address_LinkedPROXY, abi=abi_LinkedPROXY)

#Connect to the Linked oracle contract - To change current USD price
abi_LinkedORCL = '''[{"constant":true,"inputs":[],"name":"initialized","outputs":[{"internalType":"bool","name":"","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"internalType":"uint256","name":"newRate","type":"uint256"}],"name":"updateRate","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[],"name":"renounceOwnership","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"internalType":"address","name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"isOwner","outputs":[{"internalType":"bool","name":"","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"internalType":"address","name":"proxyAddress","type":"address"}],"name":"initialize","outputs":[{"internalType":"bool","name":"success","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"proxy","outputs":[{"internalType":"contract IPROX","name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"internalType":"address","name":"newOwner","type":"address"}],"name":"transferOwnership","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"previousOwner","type":"address"},{"indexed":true,"internalType":"address","name":"newOwner","type":"address"}],"name":"OwnershipTransferred","type":"event"}]'''
address_LinkedORCL = web3.toChecksumAddress("0x2CDA3512891aFF224a953D5BE459A4e21cA731Ae")
contract_LinkedORCL = web3.eth.contract(address_LinkedORCL, abi=abi_LinkedORCL)

#Set variables for the node
indexBlockNumber = web3.eth.blockNumber

def handle_event(block_filter):
    if block_filter != None:
        #Print current blocknumber and current USD rate
        print("New Block Ropsten: {}".format(block_filter.number))
        USD = contract_LinkedPROXY.functions.rate().call()
        print("Current USD rate: {}".format(USD))

        #API call retrieve new USD rate
        ETH_rates = client.get_exchange_rates(currency='ETH')
        USD_rate = int(float(ETH_rates.rates["USD"]) * 100)
        print("Coinbase new ETH - USD rate: {}".format(USD_rate))

        #Send transaction to change USD rate
        nonce = web3.eth.getTransactionCount(web3.toChecksumAddress(PubKey))
        contract_txn = contract_LinkedORCL.functions.updateRate(USD_rate).buildTransaction({'gas': 100000, 'nonce': nonce})
        signed_txnDeposit = web3.eth.account.signTransaction(contract_txn, PrivKey)
        txt_hash = web3.eth.sendRawTransaction(signed_txnDeposit.rawTransaction)
        
        try:
            receipt = web3.eth.waitForTransactionReceipt(txt_hash, 1200)
            print("Oracle transactions new USD rate mined: {}".format(receipt.transactionHash))
        except:
            print("error receiving transaction receipt")
        finally:
            print("try except finished, continue loop")

def main():
    global indexBlockNumber
    while True:
        TEMPindexBlockNumber = web3.eth.blockNumber
        if TEMPindexBlockNumber > indexBlockNumber:
            block_filter = web3.eth.getBlock(TEMPindexBlockNumber - 10)
            handle_event(block_filter)
            indexBlockNumber += 1
            time.sleep(1200)
    else:
        print("Error: Loop terminated")

if __name__ == '__main__':
    main()
