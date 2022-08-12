// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "./interfaces/IHI-PLANET.sol";

contract HiPlanetUtil is IHIPLANET, ReentrancyGuard {
    using Strings for uint256;
    using SafeMath for uint256;

    uint256 internal ether001 = 10**16;
    uint8 constant PUBLIC_INDEX = 0;
    uint8 constant PRESALE_INDEX = 1;
    uint8 constant OG_INDEX = 2;

    MarketConfig public marketConfig;
    Config public config =
        Config({
            revealed: false,
            maxSupply: 3333,
            baseExtension: ".json",
            baseURI: "",
            hiddenURI: "ipfs://QmcXG9QgbBocXuXHA3HukSDGF9aAEi88niNMspwvqRmaNp",
            maxMintAmountPerTx: 10,
            paused: false
        });

    MintPolicy public publicPolicy;
    MintPolicy public presalePolicy;
    MintPolicy public ogsalePolicy;

    function initPolicy() internal {
        publicPolicy.price = ether001.div(10);
        publicPolicy.startTime = 0;
        publicPolicy.endTime = 0;
        publicPolicy.name = "publicM";
        publicPolicy.index = 0;
        publicPolicy.paused = true;

        presalePolicy.price = ether001.div(10);
        presalePolicy.startTime = 0;
        presalePolicy.endTime = 0;
        presalePolicy.name = "presaleM";
        presalePolicy.index = 1;
        presalePolicy.paused = true;
        presalePolicy.maxMintAmountLimit = 10;

        ogsalePolicy.price = 0;
        ogsalePolicy.startTime = 0;
        ogsalePolicy.endTime = 0;
        ogsalePolicy.name = "ogsaleM";
        ogsalePolicy.index = 2;
        ogsalePolicy.paused = true;
        ogsalePolicy.maxMintAmountLimit = 1;
    }

    address internal owner;

    constructor() {
        initPolicy();
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function publicSaleBulkMintDiscount(uint8 _mintAmount, uint256 _price)
        public
        pure
        returns (uint256)
    {
        // if user minted 10 tokens, discount is 20%
        if (_mintAmount == 10) return _price.mul(8).div(10);
        // if user minted more than 5 tokens, discount is 10%
        if (_mintAmount > 4) return _price.mul(9).div(10);
        return _price;
    }

    function setMaxMintAmountPerTx(uint8 _maxMintAmountPerTx) public onlyOwner {
        config.maxMintAmountPerTx = _maxMintAmountPerTx;
    }

    function setMaxSupply(uint16 _maxSupply) public onlyOwner {
        config.maxSupply = _maxSupply;
    }

    // 이거는 필수
    function togglePause() public onlyOwner {
        config.paused = !config.paused;
    }

    function togglePresale() public onlyOwner {
        config.paused = !config.paused;
    }

    function toggleOgsale() public onlyOwner {
        ogsalePolicy.paused = !ogsalePolicy.paused;
    }

    function togglePublicSale() public onlyOwner {
        publicPolicy.paused = !publicPolicy.paused;
    }

    function toggleReveal() public onlyOwner {
        config.revealed = !config.revealed;
    }

    function toggleMarketActicated() public onlyOwner {
        marketConfig.activated = !marketConfig.activated;
    }

    function setWlMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
        presalePolicy.merkleRoot = _merkleRoot;
    }

    function setOgMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
        ogsalePolicy.merkleRoot = _merkleRoot;
    }

    function setBaseURI(string memory _tokenBaseURI) public onlyOwner {
        config.baseURI = _tokenBaseURI;
    }

    function setMintTime(
        uint8 _policyIndex,
        uint256 _mintStart,
        uint256 _mintEnd
    ) public onlyOwner {
        require(_policyIndex < 3, "HMI: Invalid index");
        // PUBLIC_INDEX || 0
        // PRESALE_INDEX || 1
        // OG_INDEX || 2
        unchecked {
            if (_policyIndex == PUBLIC_INDEX) {
                publicPolicy.startTime = _mintStart;
                publicPolicy.endTime = _mintEnd;
                return;
            } else if (_policyIndex == PRESALE_INDEX) {
                presalePolicy.startTime = _mintStart;
                presalePolicy.endTime = _mintEnd;
                return;
            } else if (_policyIndex == OG_INDEX) {
                ogsalePolicy.startTime = _mintStart;
                ogsalePolicy.endTime = _mintEnd;
                return;
            }
        }
    }

    function setMarketActivatedTime(uint256 _activatedTime) public onlyOwner {
        marketConfig.activatedTime = _activatedTime;
    }

    function getCurBlock() public view returns (uint256) {
        return block.timestamp;
    }

    function getMintTimeDiff(uint8 _policyIndex)
        public
        view
        returns (uint256, uint256)
    {
        uint256 startGap;
        uint256 endGap;

        if (_policyIndex == PUBLIC_INDEX) {
            startGap = publicPolicy.startTime - block.timestamp;
            endGap = publicPolicy.endTime - block.timestamp;
        } else if (_policyIndex == PRESALE_INDEX) {
            startGap = presalePolicy.startTime - block.timestamp;
            endGap = presalePolicy.endTime - block.timestamp;
        } else if (_policyIndex == OG_INDEX) {
            startGap = ogsalePolicy.startTime - block.timestamp;
            endGap = ogsalePolicy.endTime - block.timestamp;
        }
        if (startGap < 0) startGap = 0;
        if (endGap < 0) endGap = 0;

        return (startGap, endGap);
    }

    function getSecMarkDiff() public view returns (uint256) {
        uint256 _gap = marketConfig.activatedTime - block.timestamp;
        if (_gap <= 0) return 0;
        return _gap;
    }

    function getTokenURI(uint256 _tokenId, string memory _tokenURI)
        public
        view
        returns (string memory)
    {
        return
            string(
                abi.encodePacked(
                    _tokenURI,
                    "/",
                    _tokenId.toString(),
                    config.baseExtension
                )
            );
    }
}
