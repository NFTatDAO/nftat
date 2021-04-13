pragma solidity ^0.6.6;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract HexToIPFS is Ownable {
    using SafeMath for uint256;
    using Strings for string;

    mapping(string => string) hexToIPFS;
    // NFTatState public nftatstate;

    constructor()
        public
    {   

    }
}
