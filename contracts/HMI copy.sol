// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

// import "erc721a/contracts/ERC721A.sol";
import "erc721a/contracts/extensions/ERC721AQueryable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./interfaces/IHIPLANET.sol";

// import "./ERC2981.sol";

// 최종적으로 이거 사용하기
// TODO: 그리고 정확하게 minting time 정해놓기
contract HiPlnaet is ERC721AQueryable, Ownable, ReentrancyGuard, IHIPLANET {
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

    constructor() ERC721A("HI PLANET", "HMI") {
        // constructor() ERC721A("_name HI PLANET", "_symbol HMI") {
        // _name = "HMI";
        // _symbol = "HMI";
        // ether001
        initPolicy();
        // publicPolicy.price = ether001.div(10);
        // presalePolicy.price = ether001.div(10);

        // config.maxSupply = 3333;
        // setPublicSalePrice(ether001.div(10)); // => 0.01 ether = 10finney
        // setPresalePrice(ether001.div(10)); // => 0.007 ether
        // setMaxMintAmountPerTx(10);
    }

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

    // this function used when public minting is on
    // TODO:
    // 이거 지금은 테스트중이라 public인데 pure이랑 internal로 바꾸기
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
        require(!config.paused, "HMI: Contract is paused");
        require(!presalePolicy.paused, "HMI: Presale is OFF");
        require(
            presalePolicy.claimed[receiver] + _mintAmount <
                presalePolicy.maxMintAmountLimit + 1,
            "HMI: You can't mint so much tokens(wl)"
        );

        crossmintTo;
        presalePolicy.claimed[receiver] += _mintAmount;
        _safeMint(receiver, _mintAmount);
    }

    function ogSaleMint(
        uint256 _mintAmount,
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

    function setWlMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
        presalePolicy.merkleRoot = _merkleRoot;
    }

    function setOgMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
        ogsalePolicy.merkleRoot = _merkleRoot;
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
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

    function _baseURI() internal view override returns (string memory) {
        return config.baseURI;
    }

    function withdraw() public onlyOwner nonReentrant {
        (bool success, ) = payable(owner()).call{value: address(this).balance}(
            ""
        );
        require(success, "HMI: Transfer failed.");
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
