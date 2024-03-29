// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "./interfaces/IHI-PLANET-UTIL.sol";

contract HIPLANET_UTIL is IHI_PLANET_UTIL, ReentrancyGuard {
    using Strings for uint256;
    using SafeMath for uint256;

    uint256 internal ether001 = 10**16;
    uint8 constant PUBLIC_INDEX = 0;
    uint8 constant PRESALE_INDEX = 1;
    uint8 constant OG_INDEX = 2;

    MarketConfig public marketConfig =
        MarketConfig({activated: false, activatedTime: 1662674400 + 1 weeks});
    // 1663279200

    Config public config =
        Config({
            revealed: false,
            maxSupply: 3333,
            baseExtension: ".json",
            baseURI: "",
            hiddenURI: "ipfs://bafybeihxtk5h3smwgv3gmvwp4s26djiwmwf4m3izpwhmwpfym5bxspzxni",
            maxMintAmountPerTx: 10,
            paused: false
        });

    MintPolicy public publicPolicy;
    MintPolicy public presalePolicy;
    MintPolicy public ogsalePolicy;

    function initPolicy() internal {
        // WL(0.09ETH), Public(0.12ETH)
        // publicPolicy.price = ether001.div(10);
        publicPolicy.price = ether001.mul(12);
        publicPolicy.startTime = 1662674400;
        publicPolicy.endTime = 1666735200;
        publicPolicy.name = "publicM";
        publicPolicy.index = 0;
        publicPolicy.paused = true;

        // presalePolicy.price = ether001.div(10);
        presalePolicy.price = ether001.mul(9);
        presalePolicy.startTime = 1662501600;
        presalePolicy.endTime = 1662588000;
        presalePolicy.name = "presaleM";
        presalePolicy.index = 1;
        presalePolicy.paused = true;
        presalePolicy.maxMintAmountLimit = 5;

        ogsalePolicy.price = 0;
        ogsalePolicy.startTime = 1662328800;
        ogsalePolicy.endTime = 1662415200;
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
        require(
            msg.sender == owner,
            "HI-PLANET: Only owner can call this function"
        );
        _;
    }

    function publicSaleBulkMintDiscount(uint8 _mintAmount, uint256 _price)
        public
        pure
        returns (uint256)
    {
        unchecked {
            // if user minted 10 tokens, discount is 20%
            if (_mintAmount == 10) return _price.mul(8).div(10);
            // if user minted more than 5 tokens, discount is 10%
            if (_mintAmount > 4) return _price.mul(9).div(10);
            return _price;
        }
    }

    // 이거는 필수
    function togglePause() public onlyOwner {
        config.paused = !config.paused;
    }

    function togglePresale() public onlyOwner {
        presalePolicy.paused = !presalePolicy.paused;
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

    function setPublicsalePolicy(
        uint256 _price,
        uint256 _startTime,
        uint256 _endTime,
        bool _paused
    ) public onlyOwner returns (bool) {
        publicPolicy.price = _price;
        publicPolicy.startTime = _startTime;
        publicPolicy.endTime = _endTime;
        publicPolicy.paused = _paused;
        return true;
    }

    function setPresalePolicy(
        uint256 _price,
        uint256 _startTime,
        uint256 _endTime,
        bool _paused,
        uint8 _maxMintAmountLimit
    ) public onlyOwner returns (bool) {
        presalePolicy.price = _price;
        presalePolicy.startTime = _startTime;
        presalePolicy.endTime = _endTime;
        presalePolicy.paused = _paused;
        presalePolicy.maxMintAmountLimit = _maxMintAmountLimit;
        return true;
    }

    function setOgsalePolicy(
        uint256 _price,
        uint256 _startTime,
        uint256 _endTime,
        bool _paused,
        uint8 _maxMintAmountLimit
    ) public onlyOwner returns (bool) {
        ogsalePolicy.price = _price;
        ogsalePolicy.startTime = _startTime;
        ogsalePolicy.endTime = _endTime;
        ogsalePolicy.paused = _paused;
        ogsalePolicy.maxMintAmountLimit = _maxMintAmountLimit;
        return true;
    }

    function setConfig(
        uint16 _maxSupply,
        uint8 _maxMintAmountPerTx,
        string memory _baseURI,
        string memory _hiddenURI
    ) public onlyOwner returns (bool) {
        config.maxSupply = _maxSupply;
        config.maxMintAmountPerTx = _maxMintAmountPerTx;
        config.baseURI = _baseURI;
        config.hiddenURI = _hiddenURI;
        return true;
    }

    function setMaxMintAmountPerTx(uint8 _maxMintAmountPerTx) public onlyOwner {
        config.maxMintAmountPerTx = _maxMintAmountPerTx;
    }

    function setMaxSupply(uint16 _maxSupply) public onlyOwner {
        config.maxSupply = _maxSupply;
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

    function setHiddenURI(string memory _tokenHiddenURI) public onlyOwner {
        config.hiddenURI = _tokenHiddenURI;
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
        require(_policyIndex < 3, "HMI: Invalid index");
        uint256 startGap = 0;
        uint256 endGap = 0;
        bool success;
        uint256 _now = block.timestamp;

        if (_policyIndex == PUBLIC_INDEX) {
            (success, startGap) = (publicPolicy.startTime).trySub(_now);
            (success, endGap) = (publicPolicy.endTime).trySub(_now);
        } else if (_policyIndex == PRESALE_INDEX) {
            (success, startGap) = (presalePolicy.startTime).trySub(_now);
            (success, endGap) = (presalePolicy.endTime).trySub(_now);
        } else if (_policyIndex == OG_INDEX) {
            (success, startGap) = (ogsalePolicy.startTime).trySub(_now);
            (success, endGap) = (ogsalePolicy.endTime).trySub(_now);
        }

        return (startGap, endGap);
    }

    function getSecMarketDiff() external view returns (uint256) {
        (bool _bool, uint256 _gap) = (marketConfig.activatedTime).trySub(
            block.timestamp
        );
        _bool;
        return _gap;
    }

    function getTokenURI(uint256 _tokenId, string memory _tokenURI)
        external
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

    function getConfig() external view returns (Config memory) {
        unchecked {
            return config;
        }
    }

    function getPublicPolicy() external view returns (MintPolicy memory) {
        unchecked {
            return publicPolicy;
        }
    }

    function getPresalePolicy() external view returns (MintPolicy memory) {
        unchecked {
            return presalePolicy;
        }
    }

    function getOgsalePolicy() external view returns (MintPolicy memory) {
        unchecked {
            return ogsalePolicy;
        }
    }

    function getMarketConfig() external view returns (MarketConfig memory) {
        unchecked {
            return marketConfig;
        }
    }

    function getAddress() external view returns (address) {
        return address(this);
    }

    function getMaxSupply() external view returns (uint16) {
        return config.maxSupply;
    }

    function paused() external view returns (bool) {
        return config.paused;
    }

    function publicM() external view returns (bool) {
        return !publicPolicy.paused;
    }

    function presaleM() external view returns (bool) {
        return !presalePolicy.paused;
    }

    function ogsaleM() external view returns (bool) {
        return !ogsalePolicy.paused;
    }

    function price() external view returns (uint256) {
        return publicPolicy.price;
    }

    function wlPrice() external view returns (uint256) {
        return presalePolicy.price;
    }
}
