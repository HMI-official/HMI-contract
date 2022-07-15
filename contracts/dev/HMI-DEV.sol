// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "erc721a/contracts/ERC721A.sol";
import "erc721a/contracts/extensions/ERC721AQueryable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./ERC2981.sol";

// 최종적으로 이거 사용하기
contract HMI is ERC721A, ERC721AQueryable, Ownable, ReentrancyGuard, ERC2981 {
    using Strings for uint256;
    using SafeMath for uint256;

    struct PhaseInfo {
        uint256 phase;
        uint256 phaseMaxSupply;
        string tokenURI;
        uint256 publicSalePrice;
        uint256 presalePrice;
        bool revealed;
    }

    mapping(address => uint256) public _presaleClaimed;
    mapping(uint256 => PhaseInfo) public _phaseInfo;

    bytes32 public merkleRoot;
    uint256 public maxSupply;

    // uint256[4] public tokenNumberByPhase;
    string public baseExtension = ".json";

    // 1 ether = 100000000000000000
    uint256 public presalePrice;
    // uint256 public whiteListSaleStartTime;
    uint256 public publicSalePrice;

    uint256 presaleAmountLimit = 15;
    uint256 public maxMintAmountPerTx = 5;
    uint256 public royaltyFee = 1000; // 1000 is 10%
    uint256 ether001 = 10**16;

    bool public paused = false;
    bool public presaleM = false;
    bool public publicM = false;
    uint256 public currentPhase = 1;
    uint256 public totalPhaseNumber = 2;

    constructor() ERC721A("_name HI PLANET", "_symbol HMI") {
        // _name = "HMI";
        // _symbol = "HMI";
        // ether001
        setPublicSalePrice(ether001); // => 0.01 ether
        setPresalePrice(ether001.mul(7).div(10)); // => 0.007 ether
        maxSupply = 3333;
        setMaxMintAmountPerTx(5);
    }

    // FIXME: modifiers
    modifier mintCompliance(uint256 _mintAmount) {
        require(
            _mintAmount > 0 && _mintAmount < maxMintAmountPerTx + 1,
            "Invalid mint amount!"
        );
        require(
            totalSupply() + _mintAmount < maxSupply + 1,
            "Max supply exceeded!"
        );
        _;
    }

    modifier mintPriceCompliance(uint256 price, uint256 _mintAmount) {
        require(msg.value >= price * _mintAmount, "Not ennough ether!");
        _;
    }

    modifier onlyAccounts() {
        require(msg.sender == tx.origin, "Not allowed origin");
        _;
    }

    modifier isValidMerkleProof(bytes32[] calldata _merkleProof) {
        require(
            MerkleProof.verify(
                _merkleProof,
                merkleRoot,
                keccak256(abi.encodePacked(msg.sender))
            ) == true,
            "Not allowed origin"
        );
        _;
    }

    function setMaxMintAmountPerTx(uint256 _maxMintAmountPerTx)
        public
        onlyOwner
    {
        maxMintAmountPerTx = _maxMintAmountPerTx;
    }

    function setCurrentPhase(uint256 _currentPhase) public onlyOwner {
        currentPhase = _currentPhase;
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

    function tokenURI(uint256 _tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(_tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        // 애초에 5000개에서 maxSupply막아버리면 의미 없고,
        // phase2에 uri안넣어둬도 의미 없어 so 그래서 그냥 내가 정해주면 될 듯
        for (uint256 i = 0; i < totalPhaseNumber; i++) {
            uint256 _phase = i + 1;
            bool _revealed = _phaseInfo[_phase].revealed;

            if (_revealed) {
                return _phaseInfo[_phase].tokenURI;
            }
            uint256 _phaseMaxSupply = _phaseInfo[_phase].phaseMaxSupply;

            string memory _tokenURI = _phaseInfo[_phase].tokenURI;

            if (_tokenId <= _phaseMaxSupply) {
                return getTokenURI(_tokenId, _tokenURI);
            }
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

    function togglePublicSale() public onlyOwner {
        publicM = !publicM;
    }

    function publicSaleMint(uint256 _mintAmount)
        public
        payable
        mintCompliance(_mintAmount)
        mintPriceCompliance(publicSalePrice, _mintAmount)
        onlyAccounts
    {
        require(!paused, "HMI: Contract is paused");
        require(publicM, "HMI: The public sale is not enabled!");
        _safeMint(msg.sender, _mintAmount);
    }

    function presaleMint(uint256 _mintAmount, bytes32[] calldata _merkleProof)
        public
        payable
        mintCompliance(_mintAmount)
        mintPriceCompliance(presalePrice, _mintAmount)
        isValidMerkleProof(_merkleProof)
        onlyAccounts
    {
        // require(msg.sender == account, "HMI:  Not allowed");
        require(!paused, "HMI: Contract is paused");
        require(presaleM, "HMI: Presale is OFF");
        require(
            _presaleClaimed[msg.sender] + _mintAmount <= presaleAmountLimit,
            "HMI: You can't mint so much tokens"
        );

        _presaleClaimed[msg.sender] += _mintAmount;
        _safeMint(msg.sender, _mintAmount);
    }

    // 특정 숫자가 되면 예를들어서

    function airdrop(address _to, uint256 _amount) public onlyOwner {
        require(totalSupply() + _amount <= maxSupply, "Max supply exceeded!");
        _safeMint(_to, _amount);
    }

    function setRoyaltyFee(uint256 _fee) public onlyOwner {
        royaltyFee = _fee;
    }

    function setMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function setTotalPhaseNumber(uint256 _totalPhaseNumber) public onlyOwner {
        totalPhaseNumber = _totalPhaseNumber;
    }

    // 여기를 잘 수정해야 할듯  FIXME:
    function setPhaseInfo(
        uint256 _phase,
        uint256 _phaseMaxSupply,
        string memory _tokenURI,
        uint256 _publicSalePriceForEther,
        uint256 _presalePriceForEther,
        bool _revealed
    ) public onlyOwner {
        // uint256 ether001 = 10**16;
        // 100 ether001 = 0.01 ether
        _phaseInfo[_phase].phase = _phase;
        _phaseInfo[_phase].phaseMaxSupply = _phaseMaxSupply;
        _phaseInfo[_phase].tokenURI = _tokenURI;
        _phaseInfo[_phase].publicSalePrice = ether001.mul(
            _publicSalePriceForEther
        );
        _phaseInfo[_phase].presalePrice = ether001.mul(_presalePriceForEther);
        _phaseInfo[_phase].revealed = _revealed;
    }

    function setRevealed(uint256 _phase, bool _revealed) public onlyOwner {
        _phaseInfo[_phase].revealed = _revealed;
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

    function withdraw() public onlyOwner nonReentrant {
        (bool success, ) = payable(owner()).call{value: address(this).balance}(
            ""
        );
        require(success, "Transfer failed.");
    }

    function getTotalPhaseInfo(uint256 _phase)
        public
        view
        returns (PhaseInfo memory)
    {
        return _phaseInfo[_phase];
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
