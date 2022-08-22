// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

// import "erc721a/contracts/ERC721A.sol";
import "erc721a/contracts/extensions/ERC721AQueryable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./interfaces/IHI-PLANET.sol";
import "./interfaces/IHI-PLANET-UTIL.sol";

// import "./ERC2981.sol";

// 최종적으로 이거 사용하기
// TODO: 그리고 정확하게 minting time 정해놓기
contract HIPLANET is ERC721AQueryable, Ownable, ReentrancyGuard, IHIPLANET {
    using Strings for uint256;
    using SafeMath for uint256;

    IHI_PLANET_UTIL internal proxy;

    mapping(address => uint256) public wlClaimed;
    mapping(address => uint256) public ogClaimed;

    constructor(address _proxy) ERC721A("HI-PLANET", "HI-PLANET") {
        proxy = IHI_PLANET_UTIL(_proxy);
        // proxy.init();
    }

    modifier mintCompliance(uint256 _mintAmount) {
        uint256 _totalSupply = totalSupply();
        Config memory config = proxy.getConfig();

        require(
            _mintAmount > 0 && _mintAmount < config.maxMintAmountPerTx + 1,
            "HI-PLANET: Invalid mint amount per tx!"
        );

        require(
            _totalSupply + _mintAmount < config.maxSupply + 1,
            "HI-PLANET: Max supply exceeded!"
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
            "HI-PLANET: Contract call from another contract is not allowed"
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

        Config memory config = proxy.getConfig();

        if (!config.revealed) {
            return proxy.getTokenURI(_tokenId, config.hiddenURI);
        } else if (_tokenId <= config.maxSupply) {
            return proxy.getTokenURI(_tokenId, config.baseURI);
        } else {
            return " ";
        }
    }

    // // 이거는 필수

    function publicSaleMint(
        uint8 _mintAmount,
        address crossmintTo,
        address receiver
    ) public payable onlyAccounts mintCompliance(_mintAmount) {
        MintPolicy memory publicPolicy = proxy.getPublicPolicy();
        Config memory config = proxy.getConfig();
        uint256 _price = proxy.publicSaleBulkMintDiscount(
            _mintAmount,
            publicPolicy.price
        );

        require(msg.value >= _price * _mintAmount, "Not ennough ether!");
        require(!config.paused, "HI-PLANET: Contract is paused");
        require(
            !publicPolicy.paused,
            "HI-PLANET: The public sale is not enabled!"
        );

        bool isMintTimeCompliance = getMintTimeCompliance(
            publicPolicy.startTime,
            publicPolicy.endTime
        );

        require(
            isMintTimeCompliance,
            "HI-PLANET: Minting time is not yet started or done!"
        );

        crossmintTo;
        _safeMint(receiver, _mintAmount);
    }

    function getIsValidMerkleProof(
        bytes32[] calldata _merkleProof,
        bytes32 _merkleRoot,
        address _to
    ) public pure returns (bool) {
        return
            MerkleProof.verify(
                _merkleProof,
                _merkleRoot,
                keccak256(abi.encodePacked(_to))
            );
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
        mintPriceCompliance(proxy.getPresalePolicy().price, _mintAmount)
    {
        Config memory config = proxy.getConfig();
        MintPolicy memory presalePolicy = proxy.getPresalePolicy();
        bool _isValidMerkleProof = getIsValidMerkleProof(
            _merkleProof,
            presalePolicy.merkleRoot,
            receiver
        );
        require(_isValidMerkleProof, "HI-PLANET: invalid merkle proof(wl)");

        bool isMintTimeCompliance = getMintTimeCompliance(
            presalePolicy.startTime,
            presalePolicy.endTime
        );

        require(
            isMintTimeCompliance,
            "HI-PLANET: Minting time is not yet started or done!"
        );

        require(!config.paused, "HI-PLANET: Contract is paused");
        require(!presalePolicy.paused, "HI-PLANET: Presale is OFF");
        require(
            wlClaimed[receiver] + _mintAmount <
                presalePolicy.maxMintAmountLimit + 1,
            "HI-PLANET: You can't mint so much tokens(wl)"
        );

        crossmintTo;
        wlClaimed[receiver] += _mintAmount;
        _safeMint(receiver, _mintAmount);
    }

    function ogSaleMint(bytes32[] calldata _merkleProof)
        public
        payable
        onlyAccounts
        mintCompliance(1)
    {
        Config memory config = proxy.getConfig();
        MintPolicy memory ogsalePolicy = proxy.getOgsalePolicy();
        address reciver = msg.sender;
        uint8 _mintAmount = 1;

        bool _isValidMerkleProof = getIsValidMerkleProof(
            _merkleProof,
            ogsalePolicy.merkleRoot,
            reciver
        );
        require(_isValidMerkleProof, "HI-PLANET: invalid merkle proof(wl)");

        bool isMintTimeCompliance = getMintTimeCompliance(
            ogsalePolicy.startTime,
            ogsalePolicy.endTime
        );

        require(
            isMintTimeCompliance,
            "HI-PLANET: Minting time is not yet started or done!"
        );

        require(!config.paused, "HI-PLANET: Contract is paused");
        require(!ogsalePolicy.paused, "HI-PLANET: og sale is OFF");
        require(
            ogClaimed[reciver] + _mintAmount <
                ogsalePolicy.maxMintAmountLimit + 1,
            "HI-PLANET: You can't mint so much tokens(og)"
        );

        ogClaimed[reciver] += _mintAmount;
        _safeMint(reciver, _mintAmount);
    }

    // 특정 숫자가 되면 예를들어서

    function airdrop(address _to, uint256 _amount) public onlyOwner {
        Config memory config = proxy.getConfig();
        require(
            totalSupply() + _amount <= config.maxSupply,
            "HI-PLANET: Max supply exceeded!"
        );
        _safeMint(_to, _amount);
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

    function _baseURI() internal view override returns (string memory) {
        Config memory config = proxy.getConfig();
        return config.baseURI;
    }

    function withdraw() public onlyOwner nonReentrant {
        (bool success, ) = payable(owner()).call{value: address(this).balance}(
            ""
        );
        require(success, "HI-PLANET: Transfer failed.");
    }

    function setProxy(address _proxy) public onlyOwner {
        proxy = IHI_PLANET_UTIL(_proxy);
    }

    function getTimeGap(uint256 tokenId) public view returns (uint256) {
        TokenOwnership memory ownership = explicitOwnershipOf(tokenId);
        return block.timestamp - ownership.startTimestamp;
    }

    function getMintTimeCompliance(uint256 _mintStart, uint256 _mintEnd)
        internal
        view
        returns (bool)
    {
        return block.timestamp > _mintStart && block.timestamp < _mintEnd;
    }

    function getTokenStakingBegin(uint256 tokenId)
        public
        view
        returns (uint256)
    {
        TokenOwnership memory ownership = explicitOwnershipOf(tokenId);
        return ownership.startTimestamp;
    }

    function getProxy() public view onlyOwner returns (address) {
        return proxy.getAddress();
    }

    function _beforeTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual override {
        MarketConfig memory marketConfig = proxy.getMarketConfig();
        if (from != address(0)) {
            require(
                marketConfig.activatedTime < block.timestamp ||
                    marketConfig.activatedTime == 0,
                "HI-PLANET: Secondary market is not activated(time not yet come)"
            );
            require(
                marketConfig.activated,
                "HI-PLANET: Secondary market is not activated(contract owner blocked)"
            );
        }
        // from;
        to;
        startTokenId;
        quantity;
    }
}
