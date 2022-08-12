// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

// import "erc721a/contracts/ERC721A.sol";
import "erc721a/contracts/extensions/ERC721AQueryable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./interfaces/IHI-PLANET.sol";

// import "./ERC2981.sol";

// 최종적으로 이거 사용하기
// TODO: 그리고 정확하게 minting time 정해놓기
contract HiPlnaet is ERC721AQueryable, Ownable, ReentrancyGuard, IHIPLANET {
    using Strings for uint256;
    using SafeMath for uint256;

    address internal proxy;

    constructor() ERC721A("HI PLANET", "HMI") {}

    // 필수
    modifier mintCompliance(uint256 _mintAmount) {
        uint256 _totalSupply = totalSupply();

        require(
            _mintAmount > 0 && _mintAmount < config.maxMintAmountPerTx + 1,
            "HMI: Invalid mint amount per tx!"
        );

        require(
            _totalSupply + _mintAmount < config.maxSupply + 1,
            "HMI: Max supply exceeded!"
        );
        _;
    }

    modifier mintPriceCompliance(uint256 _price, uint256 _mintAmount) {
        require(msg.value >= _price * _mintAmount, "Not ennough ether!");
        _;
    }

    modifier onlyAccounts() {
        require(
            msg.sender == tx.origin,
            "HMI: Contract call from another contract is not allowed"
        );

        _;
    }

    // bytes32 _merkleRoot
    modifier isValidMerkleProof(
        bytes32[] calldata _merkleProof,
        bytes32 _merkleRoot,
        address _to
    ) {
        require(
            MerkleProof.verify(
                _merkleProof,
                _merkleRoot,
                keccak256(abi.encodePacked(_to))
            ) == true,
            "HMI:invalid merkle proof"
        );
        _;
    }

    modifier mintTimeCompliance(uint256 _mintStart, uint256 _mintEnd) {
        require(
            block.timestamp > _mintStart && block.timestamp < _mintEnd,
            "HMI: Minting time is not yet started!"
        );
        _;
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        virtual
        override(IERC721A, ERC721A)
        returns (string memory)
    {
        require(
            _exists(_tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        if (!config.revealed) {
            return getTokenURI(_tokenId, config.hiddenURI);
        } else if (_tokenId <= config.maxSupply) {
            return getTokenURI(_tokenId, config.baseURI);
        } else {
            return " ";
        }
    }

    // // 이거는 필수

    function publicSaleMint(
        uint8 _mintAmount,
        address crossmintTo,
        address receiver
    )
        public
        payable
        onlyAccounts
        mintCompliance(_mintAmount)
        mintPriceCompliance(
            publicSaleBulkMintDiscount(_mintAmount, publicPolicy.price),
            _mintAmount
        )
    {
        require(!config.paused, "HMI: Contract is paused");
        require(!publicPolicy.paused, "HMI: The public sale is not enabled!");
        require(
            publicPolicy.startTime < block.timestamp,
            "HMI: Minting comming soon!"
        );

        crossmintTo;
        _safeMint(receiver, _mintAmount);
    }

    function presaleMint(
        uint256 _mintAmount,
        address crossmintTo,
        address receiver,
        bytes32[] calldata _merkleProof
    )
        public
        payable
        onlyAccounts
        mintCompliance(_mintAmount)
        mintPriceCompliance(presalePolicy.price, _mintAmount)
        isValidMerkleProof(_merkleProof, presalePolicy.merkleRoot, receiver)
        mintTimeCompliance(presalePolicy.startTime, presalePolicy.endTime)
    {
        // uint8 _claimed = presalePolicy.claimed[receiver];
        require(!config.paused, "HMI: Contract is paused");
        require(!presalePolicy.paused, "HMI: Presale is OFF");
        require(
            presalePolicy.claimed[receiver] + _mintAmount <
                presalePolicy.maxMintAmountLimit + 1,
            "HMI: You can't mint so much tokens(wl)"
        );

        crossmintTo;
        // wlClaimed[receiver] += _mintAmount;
        _safeMint(receiver, _mintAmount);
    }

    function ogSaleMint(
        uint8 _mintAmount,
        bytes32[] calldata _merkleProof,
        address _to
    )
        public
        payable
        onlyAccounts
        mintCompliance(_mintAmount)
        isValidMerkleProof(_merkleProof, ogsalePolicy.merkleRoot, _to)
        mintTimeCompliance(ogsalePolicy.startTime, ogsalePolicy.endTime)
    {
        require(!config.paused, "HMI: Contract is paused");
        require(!ogsalePolicy.paused, "HMI: og sale is OFF");
        require(
            ogsalePolicy.claimed[_to] + _mintAmount <
                ogsalePolicy.maxMintAmountLimit + 1,
            "HMI: You can't mint so much tokens(og)"
        );

        ogsalePolicy.claimed[_to] += _mintAmount;
        _safeMint(_to, _mintAmount);
    }

    // 특정 숫자가 되면 예를들어서

    function airdrop(address _to, uint256 _amount) public onlyOwner {
        require(
            totalSupply() + _amount <= config.maxSupply,
            "HMI: Max supply exceeded!"
        );
        _safeMint(_to, _amount);
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

    function _baseURI() internal view override returns (string memory) {
        return config.baseURI;
    }

    function withdraw() public onlyOwner nonReentrant {
        (bool success, ) = payable(owner()).call{value: address(this).balance}(
            ""
        );
        require(success, "HMI: Transfer failed.");
    }

    function getTimeGap(uint256 tokenId) public view returns (uint256) {
        TokenOwnership memory ownership = explicitOwnershipOf(tokenId);
        return block.timestamp - ownership.startTimestamp;
    }

    function getTokenStakingBegin(uint256 tokenId)
        public
        view
        returns (uint256)
    {
        TokenOwnership memory ownership = explicitOwnershipOf(tokenId);
        return ownership.startTimestamp;
    }

    function _beforeTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual override {
        if (from != address(0)) {
            require(
                marketConfig.activatedTime < block.timestamp ||
                    marketConfig.activatedTime == 0,
                "HMI: Secondary market is not activated(time not yet come)"
            );
            require(
                marketConfig.activated,
                "HMI: Secondary market is not activated(contract owner blocked)"
            );
        }
        // from;
        to;
        startTokenId;
        quantity;
    }
}
