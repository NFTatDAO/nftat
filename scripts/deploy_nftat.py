from brownie import NFTatToken, NFTat, config, network
from scripts.helpful_scripts import get_account, get_contract, fund_with_link
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
    if len(NFTatToken) == 0:
        nftat_token = NFTatToken.deploy(INIT_SUPPLY, {"from": account})
        print(nftat_token.address)
    nftat = NFTat.deploy(
        MIN_STAKED,
        Web3.toHex(text=config["networks"][network.show_active()]["job_id"]),
        get_contract("oracle"),
        get_contract("link_token"),
        config["networks"][network.show_active()]["fee"],
        {"from": account},
    )
    print("NFTat Deployed!")
    tx = fund_with_link(nftat)
    tx.wait(1)
    return nftat


def main():
    deploy_nftat()
