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
abi_LinkedCOLL = '''[{"anonymous":false,"inputs":[{"indexed":false,"internalType":"address","name":"account","type":"address"},{"indexed":false,"internalType":"uint256","name":"id","type":"uint256"}],"name":"CloseCP","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"address","name":"account","type":"address"},{"indexed":false,"internalType":"uint256","name":"id","type":"uint256"}],"name":"OpenCP","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"previousOwner","type":"address"},{"indexed":true,"internalType":"address","name":"newOwner","type":"address"}],"name":"OwnershipTransferred","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"address","name":"sender","type":"address"},{"indexed":false,"internalType":"address","name":"receiver","type":"address"},{"indexed":false,"internalType":"uint256","name":"id","type":"uint256"}],"name":"TransferCP","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"uint256","name":"Rate","type":"uint256"}],"name":"UpdateRate","type":"event"},{"payable":true,"stateMutability":"payable","type":"fallback"},{"constant":true,"inputs":[{"internalType":"address","name":"","type":"address"},{"internalType":"uint256","name":"","type":"uint256"}],"name":"CP","outputs":[{"internalType":"uint256","name":"amountETH","type":"uint256"},{"internalType":"uint256","name":"amountToken","type":"uint256"},{"internalType":"uint256","name":"liquidation","type":"uint256"},{"internalType":"uint256","name":"liqrange","type":"uint256"},{"internalType":"uint256","name":"liqid","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"internalType":"uint256","name":"","type":"uint256"},{"internalType":"uint256","name":"","type":"uint256"}],"name":"_LiqInfo","outputs":[{"internalType":"uint256","name":"id","type":"uint256"},{"internalType":"address","name":"account","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"internalType":"uint256","name":"","type":"uint256"}],"name":"_LiqRange","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"base","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"dataTotalCP","outputs":[{"internalType":"uint256[3]","name":"","type":"uint256[3]"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"internalType":"uint256","name":"id","type":"uint256"}],"name":"depositETHCP","outputs":[{"internalType":"bool","name":"success","type":"bool"}],"payable":true,"stateMutability":"payable","type":"function"},{"constant":false,"inputs":[{"internalType":"uint256","name":"amount","type":"uint256"},{"internalType":"uint256","name":"id","type":"uint256"}],"name":"depositTokenCP","outputs":[{"internalType":"bool","name":"success","type":"bool"}],"payable":true,"stateMutability":"payable","type":"function"},{"constant":true,"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"index","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"internalType":"address","name":"account","type":"address"},{"internalType":"uint256","name":"id","type":"uint256"}],"name":"individualCPdata","outputs":[{"internalType":"uint256[2]","name":"","type":"uint256[2]"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"internalType":"address","name":"_proxy","type":"address"}],"name":"initialize","outputs":[{"internalType":"bool","name":"success","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"initialized","outputs":[{"internalType":"bool","name":"","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"isOwner","outputs":[{"internalType":"bool","name":"","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"liqPer","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"internalType":"address","name":"account","type":"address"},{"internalType":"uint256","name":"id","type":"uint256"}],"name":"liquidateCP","outputs":[{"internalType":"bool","name":"success","type":"bool"}],"payable":true,"stateMutability":"payable","type":"function"},{"constant":true,"inputs":[],"name":"minCol","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"internalType":"uint256","name":"amount","type":"uint256"}],"name":"openCP","outputs":[{"internalType":"bool","name":"success","type":"bool"}],"payable":true,"stateMutability":"payable","type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"internalType":"address","name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"proxy","outputs":[{"internalType":"contract IPROX","name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"rate","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"remFund","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[],"name":"renounceOwnership","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"tax","outputs":[{"internalType":"contract ITAX","name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"tldata","outputs":[{"internalType":"uint256","name":"_totalCPs","type":"uint256"},{"internalType":"uint256","name":"_supplyCPETH","type":"uint256"},{"internalType":"uint256","name":"_supplyCPToken","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"internalType":"address","name":"recipient","type":"address"},{"internalType":"uint256","name":"id","type":"uint256"}],"name":"transfer","outputs":[{"internalType":"bool","name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"internalType":"address","name":"newOwner","type":"address"}],"name":"transferOwnership","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"internalType":"uint256","name":"newRate","type":"uint256"}],"name":"updateRate","outputs":[{"internalType":"bool","name":"success","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"internalType":"uint256","name":"amount","type":"uint256"},{"internalType":"uint256","name":"id","type":"uint256"}],"name":"withdrawETHCP","outputs":[{"internalType":"bool","name":"success","type":"bool"}],"payable":true,"stateMutability":"payable","type":"function"},{"constant":false,"inputs":[{"internalType":"uint256","name":"amount","type":"uint256"},{"internalType":"uint256","name":"id","type":"uint256"}],"name":"withdrawTokenCP","outputs":[{"internalType":"bool","name":"success","type":"bool"}],"payable":true,"stateMutability":"payable","type":"function"}]'''
address_LinkedCOLL = web3.toChecksumAddress("0x3AA50B60A7a54EA6950f9f074E81FbF86d893352")
contract_LinkedCOLL = web3.eth.contract(address_LinkedCOLL, abi=abi_LinkedCOLL)

#Connect to the Linked oracle contract - To change current USD price
abi_LinkedORCL = '''[{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"previousOwner","type":"address"},{"indexed":true,"internalType":"address","name":"newOwner","type":"address"}],"name":"OwnershipTransferred","type":"event"},{"constant":false,"inputs":[{"internalType":"uint256","name":"newRate","type":"uint256"}],"name":"UpdateRate","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"internalType":"address","name":"_proxy","type":"address"}],"name":"initialize","outputs":[{"internalType":"bool","name":"success","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"initialized","outputs":[{"internalType":"bool","name":"","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"isOwner","outputs":[{"internalType":"bool","name":"","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"internalType":"address","name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"proxy","outputs":[{"internalType":"contract IPROX","name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[],"name":"renounceOwnership","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"internalType":"address","name":"newOwner","type":"address"}],"name":"transferOwnership","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"}]'''
address_LinkedORCL = web3.toChecksumAddress("0xC66E42175D0C9Af6726DBE54Fb9A7dcd7128c5A6")
contract_LinkedORCL = web3.eth.contract(address_LinkedORCL, abi=abi_LinkedORCL)

#Set variables for the node
indexBlockNumber = web3.eth.blockNumber

def handle_event(block_filter):
    if block_filter != None:
        #Print current blocknumber and current USD rate
        print("New Block Ropsten: {}".format(block_filter.number))
        USD = contract_LinkedCOLL.functions.rate().call()
        print("Current USD rate: {}".format(USD))

        #API call retrieve new USD rate
        ETH_rates = client.get_exchange_rates(currency='ETH')
        USD_rate = int(float(ETH_rates.rates["USD"]) * 100)
        print("Coinbase new ETH - USD rate: {}".format(USD_rate))

        #Send transaction to change USD rate
        nonce = web3.eth.getTransactionCount(web3.toChecksumAddress(PubKey))
        contract_txn = contract_LinkedORCL.functions.UpdateRate(USD_rate).buildTransaction({'gas': 100000, 'nonce': nonce})
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
