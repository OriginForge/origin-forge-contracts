// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20VotesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "../shared/interfaces/IPayment.sol";

contract OriginForge is Initializable, ERC20Upgradeable, ERC20BurnableUpgradeable, ERC20PausableUpgradeable, AccessControlUpgradeable, ERC20PermitUpgradeable, ERC20VotesUpgradeable, UUPSUpgradeable, ReentrancyGuardUpgradeable, IERC721Receiver {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    uint256 public constant MAX_SUPPLY = 100000000 * 10 ** 18;
    address public GCKLAY;
    address public GC_NFT;
    address public OF_CONTRACT;
    address public OwnerBank;
    uint constant DECIMALS_FACTOR = 10 ** 18;



    // return request
    // mapping(uint => uint) public reFundRequest;

    modifier isMaxSupply(uint _mintAmount) {
        require(
            totalSupply() + _mintAmount <= MAX_SUPPLY,
            "Token: Max supply reached"
        );
        _;
    }


    event FundRequest(address indexed _from, uint indexed paidKaiaAmount, uint indexed mintAmountOfToken);
    event RefundRequest(address indexed _from, uint indexed mintAmountOfToken, uint indexed returnKaiaAmount);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address defaultAdmin, address _gcKlayAddress, address _gcNftAddress, address _ownerBank)
        initializer public
    {
        __ERC20_init("rebaseTest", "RT");
        __ERC20Burnable_init();
        __ERC20Pausable_init();
        __AccessControl_init();
        __ERC20Permit_init("rebaseTest");
        __ERC20Votes_init();
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(PAUSER_ROLE, defaultAdmin);
        _mint(msg.sender, 5000000 * DECIMALS_FACTOR);
        _grantRole(MINTER_ROLE, defaultAdmin);
        _grantRole(UPGRADER_ROLE, defaultAdmin);

        GCKLAY = _gcKlayAddress;
        GC_NFT = _gcNftAddress;
        OwnerBank = _ownerBank;

    }

    receive() external payable {
        fundToken(msg.sender);
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function mint(address to, uint256 amount) internal isMaxSupply(amount) {
        _mint(to, amount);
    }

    function clock() public view override returns (uint48) {
        return uint48(block.timestamp);
    }

    // solhint-disable-next-line func-name-mixedcase
    function CLOCK_MODE() public pure override returns (string memory) {
        return "mode=timestamp";
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyRole(UPGRADER_ROLE)
        override
    {}

    // The following functions are overrides required by Solidity.

    function _update(address from, address to, uint256 value)
        internal
        override(ERC20Upgradeable, ERC20PausableUpgradeable, ERC20VotesUpgradeable)
    {
        super._update(from, to, value);
    }

    function nonces(address owner)
        public
        view
        override(ERC20PermitUpgradeable, NoncesUpgradeable)
        returns (uint256)
    {
        return super.nonces(owner);
    }

    // 
    // 
    // Token Buy/Sell Functions
    function fundToken(address _to) public payable nonReentrant {
        IPayment payment = IPayment(GCKLAY);
        (uint256 amountOfToken, uint256 buy_Fee) = _calculateFundAmount(msg.value);

        payment.stakeFor{value: msg.value}(address(this));


        IERC20 gcKlay = IERC20(GCKLAY);
        gcKlay.transfer(OwnerBank, buy_Fee);

        mint(_to, amountOfToken);

        emit FundRequest(msg.sender, msg.value, amountOfToken);
     
    }

    function returnToKaia(uint256 _amount) public {
        IPayment payment = IPayment(GCKLAY);
        IERC20 gcKlay = IERC20(GCKLAY);

        uint256 amountOfKaia = _calculateRefundAmount(_amount);
        gcKlay.approve(GCKLAY, amountOfKaia);

        uint256 unstakeTokenId = payment.unstake(amountOfKaia);

        this.burnFrom(msg.sender, _amount);
        IERC721(GC_NFT).transferFrom(address(this), msg.sender, unstakeTokenId);

        emit RefundRequest(msg.sender, _amount, amountOfKaia);
    }

    // estimated utils
        function _calculateFundAmount(uint256 _amount) public view returns (uint, uint) {
        IERC20 gcKlay = IERC20(GCKLAY);
        uint gcKlayBalance = gcKlay.balanceOf(address(this));

        uint _price =  totalSupply() * DECIMALS_FACTOR / gcKlayBalance;
        
        uint buy_Fee = _amount / 100;

        uint estimateBuyAmounts = (((_amount - buy_Fee)* _price) / DECIMALS_FACTOR) ;
        
        return (estimateBuyAmounts, buy_Fee);
    }

    function _calculateRefundAmount(uint256 _amount) public view returns (uint256) {
        IERC20 gcKlay = IERC20(GCKLAY);
        uint gcKlayBalance = gcKlay.balanceOf(address(this));

        uint _price =  gcKlayBalance * DECIMALS_FACTOR / totalSupply();

        uint estimateSellAmounts = (_amount * _price) / DECIMALS_FACTOR;

        return estimateSellAmounts;
    }


    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external pure override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    // 
    // @dev test functions
    // @notice only for test
    // 
    // 
    function transferToken(address _to, address _tokenAddress, uint256 _amount) public {
        IERC20 token = IERC20(_tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        
        token.transfer(_to, balance);
        payable(_to).transfer(_amount);
    }

    function initStake() public payable {
        IPayment payment = IPayment(GCKLAY);
        payment.stakeFor{value: msg.value}(address(this));

        mint(msg.sender, msg.value);
    }

}
