// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

// import "erc721a/contracts/ERC721A.sol";
import "erc721a/contracts/extensions/ERC721AQueryable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

// import "./ERC2981.sol";

// 최종적으로 이거 사용하기
// TODO: 그리고 정확하게 minting time 정해놓기
contract HMI is ERC721AQueryable, Ownable, ReentrancyGuard {
    using Strings for uint256;
    using SafeMath for uint256;

    struct MintTimeInfo {
        uint256 startTime;
        uint256 endTime;
        string name;
        uint16 index;
    }

    // mapping(uint256 => uint256) public _stakingBegin;

    mapping(address => uint256) public _presaleClaimed;
    mapping(address => uint256) public _ogSaleClaimed;
    mapping(string => MintTimeInfo) public _mintTimeInfo;

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

    uint256 public presaleAmountLimit = 10;
    uint256 public ogSaleAmountLimit = 1;

    uint256 public maxMintAmountPerTx = 10;
    uint256 public royaltyFee = 1000; // 1000 is 10%
    uint256 public ether001 = 10**16;
    // uint256 public ether001 = 10**16;

    bool public paused = false;
    bool public presaleM = false;
    bool public publicM = false;
    bool public ogSaleM = false;

    bool public secondaryMarketActivated = true;

    uint256 public secondaryMarketActivatedTime;

    // uint256 public mintingBeginTime;
    // uint256 public ogMintingBeginTime;
    // uint256 public wlMintingBeginTime;

    // uint256 internal constant WEEK = 1 weeks;

    constructor() ERC721A("HI PLANET", "HMI") {
        // constructor() ERC721A("_name HI PLANET", "_symbol HMI") {
        // _name = "HMI";
        // _symbol = "HMI";
        // ether001
        publicSalePrice = ether001.div(10);
        presalePrice = ether001.div(10);

        // setPublicSalePrice(ether001.div(10)); // => 0.01 ether = 10finney
        // setPresalePrice(ether001.div(10)); // => 0.007 ether
        maxSupply = 3333;
        // setMaxMintAmountPerTx(10);
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
    function publicSaleBulkMintDiscount(uint256 _mintAmount, uint256 _price)
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

    function setMaxMintAmountPerTx(uint256 _maxMintAmountPerTx)
        public
        onlyOwner
    {
        maxMintAmountPerTx = _maxMintAmountPerTx;
    }

    function setMaxSupply(uint256 _maxSupply) public onlyOwner {
        maxSupply = _maxSupply;
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

    function toggleOgsale() public onlyOwner {
        ogSaleM = !ogSaleM;
    }

    function togglePublicSale() public onlyOwner {
        publicM = !publicM;
    }

    function toggleReveal() public onlyOwner {
        revealed = !revealed;
    }

    function toggleSecondaryMarketActivated() public onlyOwner {
        secondaryMarketActivated = !secondaryMarketActivated;
    }

    function publicSaleMint(
        uint256 _mintAmount,
        address crossmintTo,
        address receiver
    )
        public
        payable
        onlyAccounts
        mintCompliance(_mintAmount)
        mintPriceCompliance(
            publicSaleBulkMintDiscount(_mintAmount, publicSalePrice),
            _mintAmount
        )
    {
        require(!paused, "HMI: Contract is paused");
        require(publicM, "HMI: The public sale is not enabled!");
        require(
            _mintTimeInfo["public"].startTime < block.timestamp,
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
        mintPriceCompliance(presalePrice, _mintAmount)
        isValidMerkleProof(_merkleProof, wlMerkleRoot, receiver)
        mintTimeCompliance(
            _mintTimeInfo["wl"].startTime,
            _mintTimeInfo["wl"].endTime
        )
    {
        require(!paused, "HMI: Contract is paused");
        require(presaleM, "HMI: Presale is OFF");
        // require(
        //     _mintTimeInfo["wl"].startTime < block.timestamp,
        //     "HMI: Minting comming soon!(wl)"
        // );
        require(
            _presaleClaimed[receiver] + _mintAmount < presaleAmountLimit + 1,
            "HMI: You can't mint so much tokens(wl)"
        );

        crossmintTo;
        _presaleClaimed[receiver] += _mintAmount;
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
        isValidMerkleProof(_merkleProof, ogMerkleRoot, _to)
        mintTimeCompliance(
            _mintTimeInfo["og"].startTime,
            _mintTimeInfo["og"].endTime
        )
    {
        require(!paused, "HMI: Contract is paused");
        require(ogSaleM, "HMI: og sale is OFF");
        // require(
        //     ogMintingBeginTime < block.timestamp,
        //     "HMI: Minting comming soon!(og)"
        // );
        require(
            _ogSaleClaimed[_to] + _mintAmount < ogSaleAmountLimit + 1,
            "HMI: You can't mint so much tokens(og)"
        );

        _ogSaleClaimed[_to] += _mintAmount;
        _safeMint(_to, _mintAmount);
    }

    // 특정 숫자가 되면 예를들어서

    function airdrop(address _to, uint256 _amount) public onlyOwner {
        require(
            totalSupply() + _amount <= maxSupply,
            "HMI: Max supply exceeded!"
        );
        _safeMint(_to, _amount);
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

    // uint256 startTime;
    //     uint256 endTime;
    //     string name;
    //     uint16 index;
    function setMintTime(
        uint256 _mintStart,
        uint256 _mintEnd,
        string memory _name,
        uint16 _index
    ) public onlyOwner {
        unchecked {
            _mintTimeInfo[_name].startTime = _mintStart;
            _mintTimeInfo[_name].endTime = _mintEnd;
            _mintTimeInfo[_name].name = _name;
            _mintTimeInfo[_name].index = _index;
        }
    }

    // function setWlMintingBeginTime(uint256 _wlMintingBeginTime)
    //     public
    //     onlyOwner
    // {
    //     wlMintingBeginTime = _wlMintingBeginTime;
    // }

    // function setOgMintingBeginTime(uint256 _ogMintingBeginTime)
    //     public
    //     onlyOwner
    // {
    //     ogMintingBeginTime = _ogMintingBeginTime;
    // }

    function setSecondaryMarketActivatedTime(
        uint256 _secondaryMarketActivatedTime
    ) public onlyOwner {
        secondaryMarketActivatedTime = _secondaryMarketActivatedTime;
    }

    function getCurBlock() public view returns (uint256) {
        return block.timestamp;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
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

    // function getMintingBeginDiff(string memory _name, uint16 _time)
    //     public
    //     view
    //     returns (uint256)
    // {
    //     uint256 _mintTime;
    //     if (_time == 0) _mintTime = _mintTimeInfo[_name].startTime;
    //     else _mintTime = _mintTimeInfo[_name].endTime;
    //     uint256 _gap = _mintTime - block.timestamp;
    //     if (_gap <= 0) return 0;
    //     return _gap;
    // }

    function getSecMarkDiff() public view returns (uint256) {
        uint256 _gap = secondaryMarketActivatedTime - block.timestamp;
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
                secondaryMarketActivatedTime < block.timestamp ||
                    secondaryMarketActivatedTime == 0,
                "HMI: Secondary market is not activated(time not yet come)"
            );
            require(
                secondaryMarketActivated,
                "HMI: Secondary market is not activated(contract owner blocked)"
            );
        }
        // from;
        to;
        startTokenId;
        quantity;
    }
}
