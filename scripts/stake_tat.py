from brownie import NFTatToken, NFTat, config, network, NFTatPixel, Contract
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
            "value": MIN_STAKED,
        }
    )
    tx.wait(1)
    nftat.batchOne(
        {
            "from": account,
        },
    )
    nftat.batchTwo(
        {
            "from": account,
        },
    )
    nftat.batchThree(
        {
            "from": account,
        },
    )
    tx = nftat.batchFour(
        {
            "from": account,
        },
    )
    tx.wait(1)
    print(nftat.s_pixelsContract())
    return nftat


def main():
    stake_tat()
