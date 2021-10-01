import pytest
from brownie import network, exceptions, config, NFTatPixel, Contract
from brownie.network.gas.strategies import GasNowStrategy
from scripts.helpful_scripts import (
    get_account,
)
from scripts.deploy_nftat import deploy_nftat
from tests.test_data.test_data import (
    default_token_uri,
    big_svg,
    color_changed_svg,
    color_changed_token_uri,
    changed_back_svg,
)


def test_only_patrick_can_stake():
    account = get_account()
    bad_account = get_account(index=1)

    nftat = deploy_nftat()
    tx = nftat.stakeTat(
        {
            "from": account,
            "value": config["networks"][network.show_active()]["min_staked"],
            "gas_price": GasNowStrategy("fast"),
        },
    )
    tx.wait(1)
    assert tx is not None
    with pytest.raises(exceptions.VirtualMachineError):
        nftat.stakeTat(
            {
                "from": bad_account,
                "value": config["networks"][network.show_active()]["min_staked"],
            },
        )
    return nftat


def test_anyone_can_after_patrick_sets():
    account = get_account()
    bad_account = get_account(index=1)
    nftat = test_only_patrick_can_stake()
    nftat.setOpen(True, {"from": account})
    tx = nftat.stakeTat(
        {
            "from": bad_account,
            "value": config["networks"][network.show_active()]["min_staked"],
            "gas_price": GasNowStrategy("fast"),
        },
    )
    tx.wait(1)
    assert tx is not None


def test_initial_token_uri():
    nftat = test_only_patrick_can_stake()
    assert nftat.tokenURI(0) == default_token_uri


def test_nftat_pixels_original_mintset_is_correct():
    nftat = test_only_patrick_can_stake()
    nftat_pixel = Contract.from_abi(
        "NFTatPixel", nftat.s_pixelsContract(), NFTatPixel.abi
    )
    assert nftat_pixel.getColor(0) == "grayscale"
    assert nftat_pixel.getColor(226) == "transparent"
    assert nftat_pixel.getColor(227) == ""
    # 0 and 1 are "special" tokenURIs
    assert nftat_pixel.getXlocation(0) == nftat_pixel.getXlocation(1) == 0
    assert nftat_pixel.getXlocation(2) == 30
    assert nftat_pixel.getYlocation(2) == 30
    assert nftat_pixel.getXlocation(3) == 30
    assert nftat_pixel.getYlocation(3) == 90
    # assert (
    #     nftat_pixel.tokenURI(3)
    #     == "data:application/json;base64,eyJuYW1lIjoiTkZUYXRQaXhlbCIsICJkZXNjcmlwdGlvbiI6IkEgUGl4ZWwgZm9yIGFuIE5GVGF0IiwgImF0dHJpYnV0ZXMiOiBbeyJ0cmFpdF90eXBlIjogInhsb2NhdGlvbiIsICJ2YWx1ZSI6IDMwfSwgeyJ0cmFpdF90eXBlIjogInlsb2NhdGlvbiIsICJ2YWx1ZSI6IDkwfV0sICJpbWFnZSI6ImRhdGE6aW1hZ2Uvc3ZnK3htbDtiYXNlNjQsUEhOMlp5QjRiV3h1Y3owbmFIUjBjRG92TDNkM2R5NTNNeTV2Y21jdk1qQXdNQzl6ZG1jbklHaGxhV2RvZEQwbk9UQXdKeUIzYVdSMGFEMG5PVEF3SnlCemRIbHNaVDBuWW1GamEyZHliM1Z1WkMxamIyeHZjanBpYkdGamF5YytQR05wY21Oc1pTQWdZM2c5SnpNd0p5QmplVDBuT1RBbklISTlKek13SnlCbWFXeHNQU2QwY21GdWMzQmhjbVZ1ZENjZ0x6NDhMM04yWno0PSJ9"
    # )
    assert (
        nftat_pixel.getSVG(10, False)
        == "<svg xmlns='http://www.w3.org/2000/svg' height='900' width='900' style='background-color:black'><circle  cx='30' cy='510' r='30' fill='transparent' /></svg>"
    )
    assert nftat_pixel.s_tokenIdToPixel(10) == (False, False, 30, 510, "transparent")
    assert nftat_pixel.getIsBackground(0) is True
    assert nftat.getSVG(0) == big_svg


def test_compare_strings_and_grayscale():
    nftat = test_only_patrick_can_stake()
    nftat_pixel = Contract.from_abi(
        "NFTatPixel", nftat.s_pixelsContract(), NFTatPixel.abi
    )
    assert nftat.compareStrings(nftat_pixel.getColor(0), "grayscale")


def test_can_change_colors():
    nftat = test_only_patrick_can_stake()
    nftat_pixel = Contract.from_abi(
        "NFTatPixel", nftat.s_pixelsContract(), NFTatPixel.abi
    )
    account = get_account()
    alt_account = get_account(index=1)
    tx = nftat_pixel.transferFrom(account, alt_account, 10, {"from": account})
    tx.wait(1)
    tx = nftat_pixel.changeColor(10, "red", {"from": alt_account})
    tx.wait(1)
    assert nftat_pixel.getColor(10) == "red"


def test_only_owner_can_change_colors():
    nftat = test_only_patrick_can_stake()
    nftat_pixel = Contract.from_abi(
        "NFTatPixel", nftat.s_pixelsContract(), NFTatPixel.abi
    )
    account = get_account()
    alt_account = get_account(index=1)
    tx = nftat_pixel.transferFrom(account, alt_account, 10, {"from": account})
    tx.wait(1)
    with pytest.raises(exceptions.VirtualMachineError):
        tx = nftat_pixel.changeColor(10, "red", {"from": account})


def test_can_be_not_grayscale():
    account = get_account()
    nftat = test_only_patrick_can_stake()
    nftat_pixel = Contract.from_abi(
        "NFTatPixel", nftat.s_pixelsContract(), NFTatPixel.abi
    )
    # 0 is our special background
    tx = nftat_pixel.changeColor(0, "red", {"from": account})
    # 1 is our special circle
    tx = nftat_pixel.changeColor(1, "green", {"from": account})
    tx = nftat_pixel.changeColor(3, "blue", {"from": account})
    tx = nftat_pixel.changeColor(4, "blue", {"from": account})
    tx = nftat_pixel.changeColor(3, "transparent", {"from": account})
    tx.wait(1)
    assert nftat.getSVG(0) == color_changed_svg
    assert nftat.tokenURI(0) == color_changed_token_uri
    assert nftat_pixel.getColor(0) == "red"
    assert nftat_pixel.getColor(1) == "green"
    return nftat


def test_can_change_back_to_grayscale():
    account = get_account()
    nftat = test_can_be_not_grayscale()
    nftat_pixel = Contract.from_abi(
        "NFTatPixel", nftat.s_pixelsContract(), NFTatPixel.abi
    )
    tx = nftat_pixel.changeColor(0, "grayscale", {"from": account})
    tx.wait(1)
    print(nftat.getSVG(0))
    assert nftat.getSVG(0) == changed_back_svg
