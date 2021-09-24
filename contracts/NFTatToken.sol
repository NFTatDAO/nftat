// contracts/OurToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20Snapshot.sol";


contract NFTatToken is ERC20Snapshot {
    // wei
    constructor (uint256 initialSupply) ERC20("NFTatToken", "NFTT") {
        _mint(msg.sender, initialSupply);
    }
}
