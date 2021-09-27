// contracts/NFTatToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTatToken is ERC20Snapshot, Ownable {
    // wei
    constructor (uint256 initialSupply) ERC20("NFTatToken", "NFTT") {
        _mint(msg.sender, initialSupply);
    }

    function snapshot() public returns (uint256) {
        _snapshot();
    }
}
