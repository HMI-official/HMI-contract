// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @title IStakeSystem
 * @author Abe
 * @dev StakeSystem interface.
 */

interface INOVURIHandler {
    /**
     * @notice This struct contains data related to a Staked Tokens
     *
     * @param phase - Array of tokenIds that are staked
     * @param uri - Array of tokenIds that are successfully staked
     */

    struct URIInfo {
        uint256 phase;
        string uri;
    }

    function setHiddenMetadataURI(string memory _hiddenMetadataURI) external;

    function setURI(string memory _uri, uint256 _parse) external;

    function setParseRevealed(bool _state, uint256 _parse) external;

    function setParse(uint256 _parse) external;

    function getURI(uint256 _parse) external view returns (string memory);

    function getHiddenURI(uint256 _ranTokenId)
        external
        view
        returns (string memory);

    function getRevealedURI(uint256 _phase, uint256 _ranTokenId)
        external
        view
        returns (string memory);

    function getRevealed(uint256 _parse) external view returns (bool);
}
