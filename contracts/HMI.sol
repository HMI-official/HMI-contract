// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
//FIXME: 꼭 에어드랍 1개 하고 creator fee 설정하기 매우 중요
import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

// import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

// 이제 가격 테스트
// import "./NOV-utils.sol";

/**
  @title NOV minting website NFT contract opensource
  @author Abe(hanjk13262@gmail.com)
  @dev ERC721A contract for minting NFT tokens
*/

// TODO: 블록 넘버 지나야 민팅되는거 테스트 // DONE

// TODO: 화이트리스트만 민팅되도록 테스트 // DONE

// TODO: phase 2에서 가격설정하기

// TODO: 실제 사이트에서 민팅테스트 해보기 /TESTNET에서

contract NOV is ERC721A, Ownable, ReentrancyGuard {
    using Strings for uint256;
    using SafeMath for uint256;

    uint256 public maxPublicMintAmountPerWallet = 1;
    uint256 public maxPresaleMintAmountPerWallet = 2;
    // 이거가 가장 중요한 역할
    // phase를 나누는 기준
    // 5000개 10000개
    uint256 public maxSupply;

    // string internal baseURI;
    string public notRevealedUri =
        "ipfs://QmcXG9QgbBocXuXHA3HukSDGF9aAEi88niNMspwvqRmaNp";

    // 아래꺼는 안되는거
    // "ipfs://QmcXG9QgbBocXuXHA3HukSDGF9aAEi88niNMspwvqRmaNp.json";
    // ipfs://QmcXG9QgbBocXuXHA3HukSDGF9aAEi88niNMspwvqRmaNp/1.json
    //이렇게 하니까 된다
    string public baseExtension = ".json";

    bool public paused = false;
    bool public revealed = false;
    bytes32 public merkleRoot;
    uint256 public presaleBlockNum;
    uint256 public publicBlockNum;

    bool public presaleM = false;
    bool public publicM = false;

    // uint256 public publicM

    // uint256 public publicSalePrice = 0; //1 클레이
    // uint256 public publicSalePrice = 10**18; //1 클레이

    // uint256 _price = 10**16; // 0.01 klay
    // uint256 _price = 0; // 0.01 klay
    // TODO: 그냥 하나 더 만들어놓자 예비용으로
    // 이미 토큰 가지고있으면 그거 인증하고 whitelist되거나 할인해주는거
    // 아~ 그런데 아애 화리에 들어가면 그걸로 할인해줄 수 있겠네 그러면 문제될건 없지
    //
    // 1 => 5000 / 2 => 10000
    struct PhaseInfo {
        uint256 phase;
        uint256 phaseMaxSupply;
        string tokenURI;
        uint256 publicSalePrice;
        uint256 presalePrice;
    }

    uint256 public totalPhaseNumber = 2;
    uint256 public currentPhase = 1;

    // 이 2개 초기화시키기
    // mapping(address => uint256) public _presaleClaimed;
    // mapping(address => uint256) public _publicSaleClaimed;
    // 민팅전 확인사항
    // TODO:  1) totalsupply 2) currentPhase 3) setPhaseInfo URI
    //        4) publicM     5) presaleM     6) paused    7) 블록넘버

    //FIXME: 이거 테스트해보기
    // phase => wallet address => minted amount
    mapping(uint256 => mapping(address => uint256))
        public _presaleClaimedByPhase;

    mapping(uint256 => mapping(address => uint256))
        public _publicSaleClaimedByPhase;

    mapping(uint256 => PhaseInfo) public _phaseInfo;

    // constructor(string memory _revealedURI)
    constructor() ERC721A("Nov(Official)", "NOV") ReentrancyGuard() {
        setMaxSupply(5000);
        // phase 1, maxsupply 5, tokenURI "", publicSalePrice 0, presalePrice 0
        setPhaseInfo(1, 5000, "phase1-token-uri", 0, 0);
        // phase 1, maxsupply 5, tokenURI "", publicSalePrice 1 klay, presalePrice 2klay
        setPhaseInfo(2, 10000, "phase2-token-uri", 10, 20);
        // setMaxMintAmountPerTx(1);
        // 7월 12일 오후 8시
        setPresaleBlockNum(95728266);
        // 7월 13일 오후 9시
        setPublicBlockNum(95818266);
    }

    // 필수
    modifier mintCompliance(
        uint256 _mintAmount,
        uint256 _maxMintAmountPerWallet,
        uint256 _maxSupplyByPhase
    ) {
        uint256 _totalSupply = totalSupply();
        require(_mintAmount <= _maxMintAmountPerWallet, "Invalid mint amount!");
        require(
            _totalSupply + _mintAmount <= _maxSupplyByPhase,
            "Max supply exceeded!"
        );
        require(
            _totalSupply + _mintAmount <= maxSupply,
            "Max supply exceeded!"
        );
        _;
    }
    // 필수
    modifier mintPriceCompliance(uint256 _mintAmount, uint256 cost) {
        // 여기 조건문 하나 만들어야 할 듯
        // 만약 cost가 0인경우에는 아무것도 하지 않는다.
        // 이거는 약간 복잡할꺼같으니까 그냥 민팅 fn 내부에 넣기
        require(msg.value >= cost * _mintAmount, "Insufficient funds!");
        _;
    }

    // // 필수
    modifier onlyAccounts() {
        require(msg.sender == tx.origin, "Not allowed origin");
        _;
    }

    // 여기는 세모  FIXME:
    function toggleReveal() public onlyOwner {
        revealed = !revealed;
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

    // 여기를 잘 수정해야 할듯  FIXME:
    function setPhaseInfo(
        uint256 _phase,
        uint256 _phaseMaxSupply,
        string memory _tokenURI,
        uint256 _publicSalePriceForKlay,
        uint256 _presalePriceForKlay
    ) public onlyOwner {
        uint256 _klay = 10**18;
        _phaseInfo[_phase].phase = _phase;
        _phaseInfo[_phase].phaseMaxSupply = _phaseMaxSupply;
        _phaseInfo[_phase].tokenURI = _tokenURI;
        _phaseInfo[_phase].publicSalePrice = _klay * _publicSalePriceForKlay;
        _phaseInfo[_phase].presalePrice = _klay * _presalePriceForKlay;
        // _phaseInfo[_phase].price = _klay * _priceMultiple;
        // 화이트리스트 가격이랑 public 가격이랑 나누기
        // uint256 public publicSalePrice = 10**18; //1 클레이
    }

    function setTotalPhaseNumber(uint256 _totalPhaseNumber) public onlyOwner {
        totalPhaseNumber = _totalPhaseNumber;
    }

    function setCurrentPhase(uint256 _currentPhase) public onlyOwner {
        currentPhase = _currentPhase;
    }

    function setMaxPublicMintAmountPerWallet(uint256 _maxMintAmountPerWallet)
        public
        onlyOwner
    {
        maxPublicMintAmountPerWallet = _maxMintAmountPerWallet;
    }

    function setMaxPresaleMintAmountPerWallet(uint256 _maxMintAmountPerWallet)
        public
        onlyOwner
    {
        maxPresaleMintAmountPerWallet = _maxMintAmountPerWallet;
    }

    //   여기 약간 중요해 phase 나눌때
    function setMaxSupply(uint256 _maxSupply) public onlyOwner {
        maxSupply = _maxSupply;
    }

    // 필수
    function setMerkleRoot(bytes32 _merkleroot) public onlyOwner {
        merkleRoot = _merkleroot;
    }

    // 필수?
    function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
        notRevealedUri = _notRevealedURI;
    }

    // 필수
    function setPresaleBlockNum(uint256 _presaleBlockNum) public onlyOwner {
        presaleBlockNum = _presaleBlockNum;
    }

    // 필수 FIXME: 이거 재사용해야할 수도 있어
    function setPublicBlockNum(uint256 _publicBlockNum) public onlyOwner {
        publicBlockNum = _publicBlockNum;
    }

    //필수
    function airdrop(uint256 _mintAmount, address _to) public onlyOwner {
        require(
            totalSupply() + _mintAmount <= maxSupply,
            "airdrop amount exceeds max supply"
        );
        _safeMint(_to, _mintAmount);
    }

    // FIXME:
    // isValidMerkleProof(_proof)
    function presaleMint()
        external
        payable
        mintCompliance(
            1,
            maxPresaleMintAmountPerWallet,
            _phaseInfo[currentPhase].phaseMaxSupply
        )
        onlyAccounts
        nonReentrant
    {
        require(!paused, "NOV: Contract is paused");
        require(presaleM, "NOV: Presale Minting is OFF");
        require(
            _phaseInfo[currentPhase].presalePrice * 1 <= msg.value,
            "NOV: Not enough Klay sent"
        );
        require(
            presaleBlockNum <= block.number,
            "NOV: Presale Minting Block Number is not enough"
        );
        require(
            _presaleClaimedByPhase[currentPhase][msg.sender] <
                maxPresaleMintAmountPerWallet,
            // _presaleClaimed[msg.sender] == 0,
            "NOV: You already claimed your presale tokens"
        );
        // _presaleClaimed[msg.sender] += 1;
        // 테스트중
        _presaleClaimedByPhase[currentPhase][msg.sender] += 1;
        _safeMint(msg.sender, 1);
    }

    // FIXME:
    function publicSaleMint()
        external
        payable
        mintCompliance(
            1,
            maxPublicMintAmountPerWallet,
            _phaseInfo[currentPhase].phaseMaxSupply
        )
        onlyAccounts
        nonReentrant
    {
        require(!paused, "NOV: Contract is paused");
        require(publicM, "NOV: PublicSale is OFF");
        require(
            _phaseInfo[currentPhase].publicSalePrice * 1 <= msg.value,
            "NOV: Not enough Klay sent"
        );
        require(
            publicBlockNum <= block.number,
            "NOV: PublicSale Minting Block Number is not enough"
        );
        require(
            _publicSaleClaimedByPhase[currentPhase][msg.sender] <
                maxPublicMintAmountPerWallet,
            // _presaleClaimed[msg.sender] == 0,
            "NOV: You already claimed your public sale tokens"
        );
        _publicSaleClaimedByPhase[currentPhase][msg.sender] += 1;
        _safeMint(msg.sender, 1);
    }

    // 유지
    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

    function getPhaseMaxSupply(uint256 _phase) public view returns (uint256) {
        return _phaseInfo[_phase].phaseMaxSupply;
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
            if (_tokenId <= _phaseInfo[_phase].phaseMaxSupply) {
                return getTokenURI(_tokenId, _phaseInfo[_phase].tokenURI);
            }
        }
        return " ";
    }

    function withdraw() public onlyOwner nonReentrant {
        (bool success, ) = payable(owner()).call{value: address(this).balance}(
            ""
        );
        require(success, "Transfer failed.");
    }

    function getBlockNumber() public view returns (uint256) {
        return block.number;
    }

    function getPresaleBlockNum() public view returns (uint256) {
        return presaleBlockNum;
    }

    function getPublicBlockNum() public view returns (uint256) {
        return publicBlockNum;
    }
}
