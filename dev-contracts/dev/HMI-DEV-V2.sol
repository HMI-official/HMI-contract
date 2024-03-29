// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "erc721a/contracts/ERC721A.sol";
import "erc721a/contracts/extensions/ERC721AQueryable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./ERC2981.sol";

// 최종적으로 이거 사용하기
// TODO: 그리고 정확하게 minting time 정해놓기
contract HMI is ERC721A, ERC721AQueryable, Ownable, ReentrancyGuard, ERC2981 {
    using Strings for uint256;
    using SafeMath for uint256;

    mapping(uint256 => uint256) public _stakingBegin;

    mapping(address => uint256) public _presaleClaimed;
    mapping(address => uint256) public _ogSaleClaimed;

    // mapping(uint256 => PhaseInfo) public _phaseInfo;
    bool public revealed = false;

    bytes32 public wlMerkleRoot;
    bytes32 public ogMerkleRoot;

    uint256 public maxSupply;

    string public baseExtension = ".json";
    string public baseURI;
    string public hiddenURI =
        "ipfs://QmcXG9QgbBocXuXHA3HukSDGF9aAEi88niNMspwvqRmaNp";

    // 1 ether = 1000000000000000000
    uint256 public presalePrice;
    uint256 public publicSalePrice;

    uint256 public presaleAmountLimit = 5;
    uint256 public ogSaleAmountLimit = 1;

    uint256 public maxMintAmountPerTx = 5;
    uint256 public royaltyFee = 1000; // 1000 is 10%
    uint256 public ether001 = 10**16;
    // uint256 public ether001 = 10**16;

    bool public paused = false;
    bool public presaleM = false;
    bool public publicM = false;
    bool public ogSaleM = false;

    uint256 public mintingBeginTime;

    constructor() ERC721A("HI PLANET", "HMI") {
        // constructor() ERC721A("_name HI PLANET", "_symbol HMI") {
        // _name = "HMI";
        // _symbol = "HMI";
        // ether001
        setPublicSalePrice(ether001.div(10)); // => 0.01 ether = 10finney
        setPresalePrice(ether001.div(10)); // => 0.007 ether
        maxSupply = 3333;
        setMaxMintAmountPerTx(5);
    }

    // 필수
    modifier mintCompliance(uint256 _mintAmount) {
        uint256 _totalSupply = totalSupply();

        require(
            _mintAmount > 0 && _mintAmount < maxMintAmountPerTx + 1,
            "HMI: Invalid mint amount per tx!"
        );

        require(
            _totalSupply + _mintAmount < maxSupply + 1,
            "HMI: Max supply exceeded!"
        );
        _;
    }

    modifier mintPriceCompliance(uint256 price, uint256 _mintAmount) {
        require(msg.value >= price * _mintAmount, "Not ennough ether!");
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

    modifier mintingBeginCompliance(uint256 _mintingBegin) {
        require(_mintingBegin < block.timestamp, "HMI: Minting comming soon!");
        _;
    }

    function setMaxMintAmountPerTx(uint256 _maxMintAmountPerTx)
        public
        onlyOwner
    {
        maxMintAmountPerTx = _maxMintAmountPerTx;
    }

    function setMaxSupply(uint256 _maxSupply) public onlyOwner {
        maxSupply = _maxSupply;
    }

    function setPublicSalePrice(uint256 _cost) public onlyOwner {
        publicSalePrice = _cost;
    }

    function setPresalePrice(uint256 _cost) public onlyOwner {
        presalePrice = _cost;
    }

    function setOgSaleAmountLimit(uint256 _limit) public onlyOwner {
        ogSaleAmountLimit = _limit;
    }

    function setPresaleAmountLimit(uint256 _limit) public onlyOwner {
        presaleAmountLimit = _limit;
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

        if (!revealed) {
            return getTokenURI(_tokenId, hiddenURI);
        }

        if (_tokenId <= maxSupply) {
            return getTokenURI(_tokenId, baseURI);
        }
        return " ";
    }

    // 이거는 필수
    function togglePause() public onlyOwner {
        paused = !paused;
    }

    function togglePresale() public onlyOwner {
        presaleM = !presaleM;
    }

    function toggleOgSaleM() public onlyOwner {
        ogSaleM = !ogSaleM;
    }

    function togglePublicSale() public onlyOwner {
        publicM = !publicM;
    }

    function toggleReveal() public onlyOwner {
        revealed = !revealed;
    }

    function publicSaleMint(uint256 _mintAmount, address _to)
        public
        payable
        onlyAccounts
        mintCompliance(_mintAmount)
        mintPriceCompliance(publicSalePrice, _mintAmount)
    {
        require(!paused, "HMI: Contract is paused");
        require(publicM, "HMI: The public sale is not enabled!");
        _safeMint(_to, _mintAmount);
        // _safeMint(msg.sender, _mintAmount);
    }

    function presaleMint(
        uint256 _mintAmount,
        address _to,
        bytes32[] calldata _merkleProof
    )
        public
        payable
        onlyAccounts
        mintCompliance(_mintAmount)
        mintPriceCompliance(presalePrice, _mintAmount)
        isValidMerkleProof(_merkleProof, wlMerkleRoot, _to)
    {
        require(!paused, "HMI: Contract is paused");
        require(presaleM, "HMI: Presale is OFF");
        require(
            _presaleClaimed[_to] + _mintAmount < presaleAmountLimit + 1,
            "HMI: You can't mint so much tokens(wl)"
        );

        _presaleClaimed[_to] += _mintAmount;
        _safeMint(_to, _mintAmount);
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
        isValidMerkleProof(_merkleProof, ogMerkleRoot, _to)
    {
        require(!paused, "HMI: Contract is paused");
        require(ogSaleM, "HMI: og sale is OFF");
        require(
            _ogSaleClaimed[_to] + _mintAmount < ogSaleAmountLimit + 1,
            "HMI: You can't mint so much tokens(og)"
        );

        _ogSaleClaimed[_to] += _mintAmount;
        _safeMint(_to, _mintAmount);
    }

    // 특정 숫자가 되면 예를들어서

    function airdrop(address _to, uint256 _amount) public onlyOwner {
        require(totalSupply() + _amount <= maxSupply, "Max supply exceeded!");
        _safeMint(_to, _amount);
    }

    function setRoyaltyFee(uint256 _fee) public onlyOwner {
        royaltyFee = _fee;
    }

    function setWlMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
        wlMerkleRoot = _merkleRoot;
    }

    function setOgMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
        ogMerkleRoot = _merkleRoot;
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

    function setBaseURI(string memory _tokenBaseURI) public onlyOwner {
        baseURI = _tokenBaseURI;
    }

    function setMintingBeginTime(uint256 _mintingBeginTime) public onlyOwner {
        mintingBeginTime = _mintingBeginTime;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function withdraw() public onlyOwner nonReentrant {
        (bool success, ) = payable(owner()).call{value: address(this).balance}(
            ""
        );
        require(success, "Transfer failed.");
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
                    baseExtension
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

    // holding 하고있는 기간 등록하기

    function _afterTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual override {
        to;
        if (from == address(0)) {
            // bulk mint
            for (
                uint256 tokenId = startTokenId;
                tokenId < startTokenId + quantity;
                tokenId++
            ) {
                _setRoyalty(tokenId, owner(), royaltyFee);
            }
        }
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721A, IERC165, IERC721A)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
