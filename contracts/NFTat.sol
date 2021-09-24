// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol"; 


contract NFTat is ChainlinkClient {

    mapping(address => uint256)  stakerToAmountStaked;

    // initializer
    function initializeNFTat() public {
    }

    // stakeTat
    /** @notice Create tat Staker
     */ 
    function stakeTat(uint256 _amountStaked) public payable {
        require(msg.value >= _amountStaked, "You didn't send enough ether to stake!");
        stakerToAmountStaked[msg.sender] = _amountStaked;
    }



    // constructor(address _oracle, string memory _jobId, uint256 _fee, address _link) public {
    //     if (_link == address(0)) {
    //         setPublicChainlinkToken();
    //     } else {
    //         setChainlinkToken(_link);
    //     }
    //     // oracle = 0x2f90A6D021db21e1B2A077c5a37B3C7E75D15b7e;
    //     // jobId = "29fa9aa13bf1468788b7cc4a500a45b8";
    //     // fee = 0.1 * 10 ** 18; // 0.1 LINK
    //     // oracle = _oracle;
    //     // jobId = stringToBytes32(_jobId);
    //     // fee = _fee;
    // }
}
