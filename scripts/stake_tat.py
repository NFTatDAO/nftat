from brownie import NFTatToken, NFTat, config, network
from scripts.helpful_scripts import get_account, get_contract
from brownie.network.gas.strategies import GasNowStrategy
from brownie.network import gas_price
from web3 import Web3
from scripts.deploy_nftat import MIN_STAKED


def stake_tat():
    """
    Deploys the NFTatToken contract and prints the address.
    """
    gas_price(GasNowStrategy("fast"))
    account = get_account()
    nftat = NFTat[-1]
    tx = nftat.stakeTat(
        {
            "from": account,
            "value": 1000500000000000000,
            "gas_price": GasNowStrategy("fast"),
        }
    )
    tx.wait(1)
    print("NFTat Deployed!")
    return nftat


def main():
    stake_tat()
