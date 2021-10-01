from brownie import NFTatPixel, config, network, Contract
from scripts.helpful_scripts import get_account
from brownie.network.gas.strategies import GasNowStrategy
from brownie.network import gas_price
from web3 import Web3

INIT_SUPPLY = Web3.toWei(1_000_000, "ether")

MIN_STAKED = Web3.toWei(0.1, "ether")


def deploy_nftat():
    """
    Deploys the NFTatToken contract and prints the address.
    """
    gas_price(GasNowStrategy("fast"))
    account = get_account()
    nftat_pixel = Contract.from_abi(
        "NFTatPixel",
        config["networks"][network.show_active()]["nftat_pixel"],
        NFTatPixel.abi,
    )
    MY_TOKEN_ID = 0
    MY_COLOR = "blue"
    tx = nftat_pixel.change_color(MY_TOKEN_ID, MY_COLOR, {"from": account})
    tx.wait(1)


def main():
    deploy_nftat()
