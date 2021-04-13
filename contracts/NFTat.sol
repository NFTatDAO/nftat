pragma solidity ^0.6.6;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./HexToIPFS.sol";

contract NFTat is ERC721, VRFConsumerBase, Ownable {
    using SafeMath for uint256;
    using Strings for string;

    uint256 tokenCount;
    mapping(uint256 => bool) tokenIdToPixelBool;
    mapping(uint256 => uint256) tokenIdToColor;
    mapping(uint256 => uint256) tokenIdToSize;
    mapping(uint256 => uint256) tokenIdToUnlockTime;
    mapping(uint256 => address) tokenIdToStaker;


    bytes32 internal keyHash;
    uint256 internal fee;
    uint256 public stakeAmount;
    uint256 public randomResult;
    address public VRFCoordinator;
    address public LinkToken;
    uint256 public colorChangeDuration;
    // enum NFTatState {VOTING, WAITING}
    // NFTatState public nftatstate;

    constructor(address _VRFCoordinator, address _LinkToken, bytes32 _keyhash, uint256 _colorChangeDuration)
        public
        VRFConsumerBase(_VRFCoordinator, _LinkToken)
        ERC721("NFTat", "NFTAT")
    {   
        // nftatstate = NFTatState.WAITING;
        VRFCoordinator = _VRFCoordinator;
        LinkToken = _LinkToken;
        keyHash = _keyhash;
        fee = 0.1 * 10**18; // 0.1 LINK
        stakeAmount = 10 * 10 ** 18; // 10 LINK
        colorChangeDuration = colorChangeDuration; // time in seconds 2628000 == about one month
    }

    function newTatoo(uint256 userProvidedSeed) public {
        LINK.transferFrom(msg.sender, address(this), stakeAmount);
        bytes32 requestId = requestRandomness(keyHash, fee, userProvidedSeed);
        requestIdToTatStaker(requestId) = msg.sender;
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        // min 8 x 8
        // max 64 x 64
        _safeMint(address(this), tokenCount);
        tokenIdToPixelBool(tokenCount) = false;
        uint256 boardSize = ((randomness % 56) + 9) ** 2;
        tokenIdToSize(tokenId) = boardSize;
        tokenIdToUnlockTime(tokenId) = now + colorChangeDuration;
        tokenIdToStaker(tokenId) = requestIdToTatStaker(requestId);

        tokenCount = tokenCount + 1;
        for (uint256 i; i<(randomness % 56) + 9; i++){
            _safeMint(requestIdToTatStaker(requestId), tokenCount);
            tokenIdToPixelBool(tokenCount) = true;
            tokenCount = tokenCount + 1;
        }
    }

    function isPixel(tokenId) public view {
        return tokenIdToPixelBool(tokenId);
    } 

    function changeColor(uint256 tokenId, uint256 color) public {
        require(tokenIdToPixelBool(tokenId) == true, "This must be a pixel!");
        require(_isApprovedOrOwner(msg.sender, tokenId), "You need to own this NFT!");
        require(color <= 16777215, "Invalid color specified");
        tokenIdToColor(tokenId) = color;
    }

    function claimNFTat(uint256 tokenId) public {
        require(tokenIdToUnlockTime(tokenId) > now, "Must wait until the time is up!");
        require(isNFTatStaker(msg.sender, tokenId), "Must be the staker of this NFT.");
    }

    function isNFTatStaker(address staker, uint256 tokenId) public view {

    }
}
