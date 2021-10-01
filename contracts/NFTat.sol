// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol"; 
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "./NFTatPixel.sol";


contract NFTat is ReentrancyGuard, Ownable, ChainlinkClient, ERC721URIStorage {
    using Chainlink for Chainlink.Request;
    uint256 public s_minimumStaked;
    bytes32 public s_subjectiveOracleJobId;
    address public s_subjectiveOracleAddress;
    uint256 public s_subjectiveOracleFee;
    uint256 public s_nftCounter;
    bool private isOpen;
    mapping(bytes32 => uint256) public requestIdToTattoodPersonId;
    NFTatPixel public s_pixelsContract;
    uint public s_timeInterval;
    struct TattoodPerson {
        uint256 stakedAmount;
        bool tattood;
        address addressOfTattoodPerson;
    }
    mapping(uint256 => TattoodPerson) public s_tokenIdToTattoodPerson;


    constructor(uint256 _minStaked, 
    bytes32 _subjectiveOracleJobId, 
    address _subjectiveOracleAddress, 
    address _link, 
    uint256 _subjectiveOracleFee) 
    ERC721("NFTat", "NFTAT") {
        if (_link == address(0)) {
            setPublicChainlinkToken();
        } else {
            setChainlinkToken(_link);
        }
        s_timeInterval = 12 days;
        s_minimumStaked = _minStaked;
        s_subjectiveOracleJobId = _subjectiveOracleJobId;
        s_subjectiveOracleAddress = _subjectiveOracleAddress;
        s_subjectiveOracleFee = _subjectiveOracleFee;
        s_nftCounter = 0;
        isOpen = false;
        NFTatPixel newPixelContract = new NFTatPixel(s_timeInterval);
        s_pixelsContract = newPixelContract;
    }

    function setOpen(bool _isOpen) public onlyOwner {
        isOpen = _isOpen;
    }

    // stakeTat
    /** @notice Create Tatoo Staker
     */ 
    function stakeTat() 
    nonReentrant onlyOwner public payable {
        require(msg.sender == owner() || isOpen, "Still in beta, sorry!");
        require(msg.value >= s_minimumStaked, "You didn't send enough ether to stake!");
        TattoodPerson memory newTatoodPerson = TattoodPerson(msg.value, false, msg.sender);
        s_tokenIdToTattoodPerson[s_nftCounter] = newTatoodPerson;
        s_pixelsContract.mintSet(msg.sender);
        _safeMint(msg.sender, s_nftCounter);
        // update the counter
        s_nftCounter = s_nftCounter + 1;
    }

    function batchOne() public onlyOwner {
        s_pixelsContract.mintBatchOne(msg.sender);
    }
    function batchTwo() public onlyOwner {
        s_pixelsContract.mintBatchTwo(msg.sender);
    }
    function batchThree() public onlyOwner {
        s_pixelsContract.mintBatchThree(msg.sender);
    }
    function batchFour() public onlyOwner {
        s_pixelsContract.mintBatchFour(msg.sender);
    }

    function updateVotes(uint256 tattoodPersonId) public onlyOwner returns (bytes32 requestId) {
        require(s_tokenIdToTattoodPerson[tattoodPersonId].tattood != false, "This person has already been tattood!");
        Chainlink.Request memory request = buildChainlinkRequest(s_subjectiveOracleJobId, address(this), this.fulfill.selector);
        sendChainlinkRequestTo(s_subjectiveOracleAddress, request, s_subjectiveOracleFee);
        requestIdToTattoodPersonId[requestId] = tattoodPersonId;
    }

    function fulfill(bytes32 _requestId, bool _tattoodStatus) public recordChainlinkFulfillment(_requestId){
        require(_tattoodStatus, "The person was not tattood!");
        uint256 tattoodPersonId = requestIdToTattoodPersonId[_requestId];
        address tattoodPerson = s_tokenIdToTattoodPerson[tattoodPersonId].addressOfTattoodPerson;
        s_tokenIdToTattoodPerson[tattoodPersonId].tattood = _tattoodStatus;
        uint256 returnStakedAmount = s_tokenIdToTattoodPerson[tattoodPersonId].stakedAmount;
        (bool success, ) = payable(tattoodPerson).call{value: returnStakedAmount}("");
        require(success, "You don't have enough ether to pay the fee!");
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        // 0th pixel is background
        // 1st pixel is circle
        // the next 225 are the pixels
        string memory svg = getSVG(tokenId);
        if (!s_tokenIdToTattoodPerson[tokenId].tattood){
            return formatTokenURI(svgToImageURI(svg), "false");
        }
        return formatTokenURI(svgToImageURI(svg), "true");
    }

    function getSVG(uint256 tokenId) public view returns (string memory) {
        string memory startSVG = "<svg xmlns='http://www.w3.org/2000/svg' height='900' width='900' ";
        string memory background = "style='background-color:black'>";
        string memory baseCircle = "";
        string memory allPixels = "";
        string memory endSVG = "</svg>";
        bool isGrayScale = true;

        for(uint i = tokenId * 227; i < (tokenId * 227) + 227; i++) {
            // Pixel memory pixel = s_pixelsContract.s_tokenIdToPixel(i);
            if (s_pixelsContract.getIsBackground(i)) {
                if (!compareStrings(s_pixelsContract.getColor(i),("grayscale"))) {
                    isGrayScale = false;
                    background = string(abi.encodePacked("style='background-color:",s_pixelsContract.getColor(i), "'>"));
                } else {
                    background = string(abi.encodePacked(background, "<filter id='grayscale'><feColorMatrix type='matrix' values='0.3333 0.3333 0.3333 0 0 0.3333 0.3333 0.3333 0 0 0.3333 0.3333 0.3333 0 0 0 0 0 1 0'/></filter>"));
                }
            } else if (s_pixelsContract.getIsBaseCircle(i)) {
                baseCircle = s_pixelsContract.getBigCircleSVG(i, isGrayScale);
            } else {
                allPixels = string(abi.encodePacked(allPixels, s_pixelsContract.getBaseSVG(i, isGrayScale)));
            }
        }
        return string(abi.encodePacked(startSVG, background, baseCircle, allPixels, endSVG));
    }

    function formatTokenURI(string memory imageURI, string memory _tattood) public pure returns (string memory) {
        return string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                "NFTat", // You can add whatever name here
                                '", "description":"A tattoooooooo", "attributes":[{"trait_type": "tattood", "value": ', _tattood,'}], "image":"',imageURI,'"}'
                            )
                        )
                    )
                )
            );
    }

    function svgToImageURI(string memory svg) public pure returns (string memory) {
        string memory baseURL = "data:image/svg+xml;base64,";
        string memory svgBase64Encoded = Base64.encode(bytes(string(abi.encodePacked(svg))));
        return string(abi.encodePacked(baseURL,svgBase64Encoded));
    }

    function compareStrings(string memory a, string memory b) public pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }
}
