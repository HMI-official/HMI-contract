// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

/**
 * @dev Interface of HI-PLANET.
 */
interface IHIPLANET {
    struct MintPolicy {
        uint256 price;
        uint256 startTime;
        uint256 endTime;
        string name;
        uint8 index;
        bool paused;
        bytes32 merkleRoot;
        uint8 maxMintAmountLimit;
    }
    // mapping(address => uint256) claimed;

    struct Config {
        bool revealed;
        uint16 maxSupply;
        string baseExtension;
        string baseURI;
        string hiddenURI;
        uint8 maxMintAmountPerTx;
        bool paused;
    }
    struct MarketConfig {
        bool activated;
        uint256 activatedTime;
    }
}
