from brownie import NFTatToken, NFTat, config, network
from scripts.helpful_scripts import get_account, get_contract, fund_with_link
from brownie.network.gas.strategies import GasNowStrategy
from brownie.network import gas_price
from web3 import Web3
import time

INIT_SUPPLY = Web3.toWei(1_000_000, "ether")

MIN_STAKED = Web3.toWei(500, "ether")


def deploy_nftat():
    """
    Deploys the NFTatToken contract and prints the address.
    """
    gas_price(GasNowStrategy("fast"))
    nftat = NFTat[-1]
    account = get_account()
    nftat.updateVotes(0, {"from": account})
    time.sleep(180)
    print(nftat.s_tokenIdToTattoodPerson(0))
    print(nftat.balance)
    return nftat


def main():
    deploy_nftat()
