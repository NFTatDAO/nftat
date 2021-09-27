from brownie import NFTatToken, NFTat, config, network
from scripts.helpful_scripts import get_account, get_contract
from web3 import Web3

INIT_SUPPLY = Web3.toWei(1_000_000, "ether")

MIN_STAKED = Web3.toWei(1, "ether")


def main():
    """
    Deploys the NFTatToken contract and prints the address.
    """
    account = get_account()
    if len(NFTatToken) == 0:
        nftat_token = NFTatToken.deploy(INIT_SUPPLY, {"from": account})
        print(nftat_token.address)
    nftat = NFTat.deploy(
        MIN_STAKED,
        config["networks"][network.show_active()]["job_id"],
        get_contract("oracle"),
        get_contract("link_token"),
        config["networks"][network.show_active()]["fee"],
        {"from": account},
    )
    print("NFTat Deployed!")
    return nftat
