// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./IHI-PLANET.sol";

/**
 * @dev Interface of HI-PLANET.
 */
interface IHI_PLANET_UTIL is IHIPLANET {
    /// @notice fnuction which calculate the total nft price by the mint amoint
    function externalSaleBulkMintDiscount(uint8 _mintAmount, uint256 _price)
        external
        pure
        returns (uint256);

    /// @notice fnuction which set max mint amount per tx
    function setMaxMintAmountPerTx(uint8 _maxMintAmountPerTx) external;

    /// @notice fnuction which set maxSupply
    function setMaxSupply(uint16 _maxSupply) external;

    /// @notice fnuction which toggle the paused state of the NFT contract
    function togglePause() external;

    /// @notice fnuction which set the presale paused state of the NFT contract
    function togglePresale() external;

    /// @notice fnuction which set the ogsale paused state of the NFT contract
    function toggleOgsale() external;

    /// @notice fnuction which set the publicsale start time of the NFT contract
    function togglePublicSale() external;

    /// @notice fnuction which toggle the state of token uri revealed
    function toggleReveal() external;

    /// @notice fnuction which set the wl merkle root of the NFT contract
    function setWlMerkleRoot(bytes32 _merkleRoot) external;

    /// @notice fnuction which set the og merkle root of the NFT contract
    function setOgMerkleRoot(bytes32 _merkleRoot) external;

    /// @notice fnuction which set base token uri of the NFT contract
    function setBaseURI(string memory _tokenBaseURI) external;

    /**
     *  @notice fnuction which set mint begin time and end time of the NFT contract
     *  in publicPolicy, presalePolicy, ogsalePolicy
     */
    function setMintTime(
        uint8 _policyIndex,
        uint256 _mintStart,
        uint256 _mintEnd
    ) external;

    /// @notice fnuction which toggle opensea or magic eden market activation
    function toggleMarketActicated() external;

    /// @notice fnuction which set opensea or magic eden market activation time
    function setMarketActivatedTime(uint256 _activatedTime) external;

    /// @notice fnuction which get current block number
    function getCurBlock() external view returns (uint256);

    /**
     *  @notice fnuction which get difference between
     *  current block number and the block number of the activated time
     */
    function getMintTimeDiff(uint8 _policyIndex)
        external
        view
        returns (uint256, uint256);

    function getSecMarkDiff() external view returns (uint256);
}
