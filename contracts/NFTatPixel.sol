// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./library/base64.sol";


contract NFTatPixel is ReentrancyGuard, ERC721URIStorage, Ownable {
    uint256 public s_tokenCounter;
    mapping(uint256 => Pixel) public s_tokenIdToPixel;
    uint256 public s_pixelInterval;
    uint256 public s_timeInterval;
    string public s_grayScaleFilter;
    mapping(uint256 => uint256) public s_tokenIdToStartTime;

    constructor(uint256 _timeInterval) ERC721("NFTatPixel", "NFTP") {
        s_tokenCounter = 0;
        s_pixelInterval = 60;
        s_timeInterval = _timeInterval;
        s_grayScaleFilter = "filter='url(#grayscale)' ";
    }

    struct Pixel {
        bool isBackground;
        bool isBaseCircle;
        uint256 xlocation;
        uint256 ylocation;
        string color;
    }

    function getIsBackground(uint256 _tokenId) public view returns (bool) {
        return s_tokenIdToPixel[_tokenId].isBackground;
    }

    function getIsBaseCircle(uint256 _tokenId) public view returns (bool) {
        return s_tokenIdToPixel[_tokenId].isBaseCircle;
    }

    function getXlocation(uint256 _tokenId) public view returns (uint256) {
        return s_tokenIdToPixel[_tokenId].xlocation;
    }

    function getYlocation(uint256 _tokenId) public view returns (uint256) {
        return s_tokenIdToPixel[_tokenId].ylocation;
    }

    function getColor(uint256 _tokenId) public view returns (string memory) {
        return s_tokenIdToPixel[_tokenId].color;
    }

    function changeColor(uint256 tokenId, string memory color) public {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );
        require(s_tokenIdToStartTime[tokenId] + s_timeInterval >= block.timestamp, "Time's up on changing colors!");
        // grayscale is a keyword
        // transparent is a keyword
        s_tokenIdToPixel[tokenId].color = color;
    }

    // right now it's just the nftat.sol that can call this
    function mintSet(address nftOwner) public onlyOwner {
        // we mint the 2 special tokens, background, and base circle
        uint256 tokenCounter = s_tokenCounter;
        // background
        Pixel memory backGroundPixel = Pixel(true, false, 0, 0, "grayscale");
        _safeMint(nftOwner, tokenCounter);
        s_tokenIdToPixel[tokenCounter] = backGroundPixel;
        s_tokenIdToStartTime[tokenCounter] = block.timestamp;
        tokenCounter = tokenCounter + 1;
        
        // circle
        Pixel memory circlePixel = Pixel(false, true, 0, 0, "white");
        _safeMint(nftOwner, tokenCounter);
        s_tokenIdToPixel[tokenCounter] = circlePixel;
        s_tokenIdToStartTime[tokenCounter] = block.timestamp;
        tokenCounter = tokenCounter + 1;
        s_tokenCounter = tokenCounter;
    }

    function mintBatchOne(address nftOwner) public onlyOwner {
        uint256 tokenCounter = s_tokenCounter;
        // // 225 makes it 15 x 15
        uint256 pixelInterval = s_pixelInterval;
        for(uint256 x = 0; x < 4; x++) {
            for(uint256 y = 0; y < 15; y++) {
                Pixel memory pixel = Pixel(false, false, (x * pixelInterval) + (pixelInterval/2), (y * pixelInterval) + (pixelInterval/2), "transparent");
                _safeMint(nftOwner, tokenCounter);
                s_tokenIdToPixel[tokenCounter] = pixel;
                s_tokenIdToStartTime[tokenCounter] = block.timestamp;
                tokenCounter = tokenCounter + 1;
            }
        }
        s_tokenCounter = tokenCounter;
    }

    function mintBatchTwo(address nftOwner) public onlyOwner {
        uint256 tokenCounter = s_tokenCounter;
        // // 225 makes it 15 x 15
        uint256 pixelInterval = s_pixelInterval;
        for(uint256 x = 4; x < 8; x++) {
            for(uint256 y = 0; y < 15; y++) {
                Pixel memory pixel = Pixel(false, false, (x * pixelInterval) + (pixelInterval/2), (y * pixelInterval) + (pixelInterval/2), "transparent");
                _safeMint(nftOwner, tokenCounter);
                s_tokenIdToPixel[tokenCounter] = pixel;
                s_tokenIdToStartTime[tokenCounter] = block.timestamp;
                tokenCounter = tokenCounter + 1;
            }
        }
        s_tokenCounter = tokenCounter;
    }

    function mintBatchThree(address nftOwner) public onlyOwner {
        uint256 tokenCounter = s_tokenCounter;
        // // 225 makes it 15 x 15
        uint256 pixelInterval = s_pixelInterval;
        for(uint256 x = 8; x < 12; x++) {
            for(uint256 y = 0; y < 15; y++) {
                Pixel memory pixel = Pixel(false, false, (x * pixelInterval) + (pixelInterval/2), (y * pixelInterval) + (pixelInterval/2), "transparent");
                _safeMint(nftOwner, tokenCounter);
                s_tokenIdToPixel[tokenCounter] = pixel;
                s_tokenIdToStartTime[tokenCounter] = block.timestamp;
                tokenCounter = tokenCounter + 1;
            }
        }
        s_tokenCounter = tokenCounter;
    }

    function mintBatchFour(address nftOwner) public onlyOwner {
        uint256 tokenCounter = s_tokenCounter;
        // // 225 makes it 15 x 15
        uint256 pixelInterval = s_pixelInterval;
        for(uint256 x = 12; x < 15; x++) {
            for(uint256 y = 0; y < 15; y++) {
                Pixel memory pixel = Pixel(false, false, (x * pixelInterval) + (pixelInterval/2), (y * pixelInterval) + (pixelInterval/2), "transparent");
                _safeMint(nftOwner, tokenCounter);
                s_tokenIdToPixel[tokenCounter] = pixel;
                s_tokenIdToStartTime[tokenCounter] = block.timestamp;
                tokenCounter = tokenCounter + 1;
            }
        }
        s_tokenCounter = tokenCounter;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        // we default all to not grayscale
        string memory svg = getSVG(tokenId, false);
        string memory imageURI = svgToImageURI(svg);
        return formatTokenURI(imageURI, tokenId);
    }

    function getBaseSVG(uint256 tokenId, bool isGrayScale) public view returns (string memory) {
        Pixel memory pixel = s_tokenIdToPixel[tokenId];
        string memory filter = "";
        string memory fill = string(abi.encodePacked("' fill='", pixel.color, "' "));
        if (isGrayScale) {
            filter = s_grayScaleFilter;
        }
        if (compareStrings(pixel.color, "transparent")) {
            fill = "style='fill-opacity: 0' ";
        }
        return string(abi.encodePacked("<circle ", filter, " cx='", uint2str(pixel.xlocation), "' cy='",uint2str(pixel.ylocation) ,"' r='",uint2str(s_pixelInterval / 2) ,"' fill='",pixel.color ,"' />"));
    }

    function getBigCircleSVG(uint256 tokenId, bool isGrayScale) public view returns (string memory) {
        Pixel memory pixel = s_tokenIdToPixel[tokenId];
        string memory filter = "";
        if (isGrayScale) {
            filter = s_grayScaleFilter;
        }
        return string(abi.encodePacked("<circle ", filter ," cx='450' cy='450' r='450' fill='", pixel.color ,"' />"));
    }

    function getSVG(uint256 tokenId, bool isGrayScale) public view returns (string memory) {
        string memory base = "<svg xmlns='http://www.w3.org/2000/svg' height='900' width='900' style='background-color:black'>";
        Pixel memory pixel = s_tokenIdToPixel[tokenId];
        string memory baseSvg = "";
        if (pixel.isBaseCircle) {
            baseSvg = getBigCircleSVG(tokenId, isGrayScale);
        } else {
            baseSvg = getBaseSVG(tokenId, false);
        }
        return string(abi.encodePacked(base, baseSvg, "</svg>"));
    }

    function formatTokenURI(string memory imageURI, uint256 tokenId) public view returns (string memory) {
        return string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                uint2str(s_tokenIdToPixel[tokenId].xlocation), ', ', uint2str(s_tokenIdToPixel[tokenId].ylocation),  // You can add whatever name here
                                '", "description":"A Pixel for an NFTat", "attributes": [{"trait_type": "xlocation", "value": ', uint2str(s_tokenIdToPixel[tokenId].xlocation),'}, {"trait_type": "ylocation", "value": ',uint2str(s_tokenIdToPixel[tokenId].ylocation),'}], "image":"',imageURI,'"}'
                            )
                        )
                    )
                )
            );
    }

    function svgToImageURI(string memory svg) public pure returns (string memory) {
        // example:
        // <svg width='500' height='500' viewBox='0 0 285 350' fill='none' xmlns='http://www.w3.org/2000/svg'><path fill='black' d='M150,0,L75,200,L225,200,Z'></path></svg>
        // data:image/svg+xml;base64,PHN2ZyB3aWR0aD0nNTAwJyBoZWlnaHQ9JzUwMCcgdmlld0JveD0nMCAwIDI4NSAzNTAnIGZpbGw9J25vbmUnIHhtbG5zPSdodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2Zyc+PHBhdGggZmlsbD0nYmxhY2snIGQ9J00xNTAsMCxMNzUsMjAwLEwyMjUsMjAwLFonPjwvcGF0aD48L3N2Zz4=
        string memory baseURL = "data:image/svg+xml;base64,";
        string memory svgBase64Encoded = Base64.encode(bytes(string(abi.encodePacked(svg))));
        return string(abi.encodePacked(baseURL,svgBase64Encoded));
    }

    // From: https://stackoverflow.com/a/65707309/11969592
    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    function compareStrings(string memory a, string memory b) public pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

}
