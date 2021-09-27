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
    mapping(bytes32 => uint256) public requestIdToTattoodPersonId;
    NFTatPixel public s_pixelsContract;


    uint public s_interval;
    TattoodPerson[] public s_tattoodPeople;

    struct TattoodPerson {
        uint256 stakedAmount;
        bool tattooed;
        address addressOfTattooedPerson;
        string twitterHandle;
    }

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
        s_interval = 1 weeks;
        s_minimumStaked = _minStaked;
        s_subjectiveOracleJobId = _subjectiveOracleJobId;
        s_subjectiveOracleAddress = _subjectiveOracleAddress;
        s_subjectiveOracleFee = _subjectiveOracleFee;
        s_nftCounter = 0;
        NFTatPixel newPixelContract = new NFTatPixel(s_interval);
        s_pixelsContract = newPixelContract;
    }

    // stakeTat
    /** @notice Create Tatoo Staker
     */ 
    function stakeTat(string memory _twitterHandle) 
    nonReentrant public payable {
        require(msg.value > s_minimumStaked, "You didn't send enough ether to stake!");
        TattoodPerson memory newTatoodPerson = TattoodPerson(msg.value, false, msg.sender, _twitterHandle);
        s_tattoodPeople.push(newTatoodPerson);
    }

    function setMinimumStaked(uint256 _minStaked) public onlyOwner {
        s_minimumStaked = _minStaked;
    }

    function setInterval(uint256 _interval) public onlyOwner {
        s_interval = _interval;
    }

    function setSubjectiveOrcacleJobId(bytes32 _subjectiveOracleJobId) public onlyOwner {
        s_subjectiveOracleJobId = _subjectiveOracleJobId;
    }

    function updateVotes(uint256 tattoodPersonId) public onlyOwner returns (bytes32 requestId) {
        require(s_tattoodPeople[tattoodPersonId].tattooed != false, "This person has already been tattood!");
        Chainlink.Request memory request = buildChainlinkRequest(s_subjectiveOracleJobId, address(this), this.fulfill.selector);
        sendChainlinkRequestTo(s_subjectiveOracleAddress, request, s_subjectiveOracleFee);
        requestIdToTattoodPersonId[requestId] = tattoodPersonId;
    }

    function fulfill(bytes32 _requestId, bool _tattoodStatus) public recordChainlinkFulfillment(_requestId){
        require(_tattoodStatus, "The person was not tattood!");
        uint256 tattoodPersonId = requestIdToTattoodPersonId[_requestId];
        address tattooedPerson = s_tattoodPeople[tattoodPersonId].addressOfTattooedPerson;
        s_tattoodPeople[tattoodPersonId].tattooed = _tattoodStatus;
        uint256 returnStakedAmount = s_tattoodPeople[tattoodPersonId].stakedAmount;
        (bool success, ) = payable(tattooedPerson).call{value: returnStakedAmount}("");
        require(success, "You don't have enough ether to pay the fee!");
        _safeMint(tattooedPerson, s_nftCounter);
        // update the counter
        s_nftCounter = s_nftCounter + 1;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        // 0th pixel is background
        // 1st pixel is circle
        // the next 225 are the pixels
        string memory startSVG = "<svg xmlns='http://www.w3.org/2000/svg' height='900' width='900' ";
        string memory background = ">";
        string memory baseCircle = "";
        string memory allPixels = "";
        string memory endSVG = "</svg>";
        bool isGreyScale = true;
        string memory filter = "filter='url(#grayscale)'";

        for(uint i = tokenId * 227; i < (tokenId * 227) + 227; i++) {
            // Pixel memory pixel = s_pixelsContract.s_tokenIdToPixel(i);
            if (s_pixelsContract.getIsBackground(i)) {
                if (compareStrings(s_pixelsContract.getColor(i),("greyscale"))) {
                    isGreyScale = false;
                    background = string(abi.encodePacked("style='background-color:",s_pixelsContract.getColor(i), "'>"));
                    filter = "";
                } else {
                    background = string(abi.encodePacked(background, "<filter id='greyscale'><feColorMatrix type='matrix' values='0.3333 0.3333 0.3333 0 0 0.3333 0.3333 0.3333 0 0 0.3333 0.3333 0.3333 0 0 0 0 0 1 0'/></filter>"));
                }
            } else if (s_pixelsContract.getIsBaseCircle(i)) {
                baseCircle = string(abi.encodePacked("<circle cx='450' ", filter, "cy='450' r='450' fill='",s_pixelsContract.getColor(i),"' />"));
            } else {
                allPixels = string(abi.encodePacked(allPixels, s_pixelsContract.getBaseSVG(i)));
            }
        }
        return svgToImageURI(string(abi.encodePacked(startSVG, background, baseCircle, allPixels, endSVG)));
    }

    function svgToImageURI(string memory svg) public pure returns (string memory) {
        // example:
        // <svg width='500' height='500' viewBox='0 0 285 350' fill='none' xmlns='http://www.w3.org/2000/svg'><path fill='black' d='M150,0,L75,200,L225,200,Z'></path></svg>
        // data:image/svg+xml;base64,PHN2ZyB3aWR0aD0nNTAwJyBoZWlnaHQ9JzUwMCcgdmlld0JveD0nMCAwIDI4NSAzNTAnIGZpbGw9J25vbmUnIHhtbG5zPSdodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2Zyc+PHBhdGggZmlsbD0nYmxhY2snIGQ9J00xNTAsMCxMNzUsMjAwLEwyMjUsMjAwLFonPjwvcGF0aD48L3N2Zz4=
        string memory baseURL = "data:image/svg+xml;base64,";
        string memory svgBase64Encoded = Base64.encode(bytes(string(abi.encodePacked(svg))));
        return string(abi.encodePacked(baseURL,svgBase64Encoded));
    }

    function compareStrings(string memory a, string memory b) public view returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }
}
