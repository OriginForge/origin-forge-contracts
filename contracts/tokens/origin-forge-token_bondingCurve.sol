// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;


import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20VotesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "../shared/interfaces/IPayment.sol";


contract OriginForge is Initializable, ERC20Upgradeable, ERC20BurnableUpgradeable, ERC20PausableUpgradeable, AccessControlUpgradeable, ERC20PermitUpgradeable, ERC20VotesUpgradeable, UUPSUpgradeable,  IERC721Receiver {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    
    uint256 constant maxSupply = 100_000_000 * 10 ** 18;
    uint256 constant bondingCurveMaxSupply = 50_000_000 * 10 ** 18;
    address public rebaseToken;
    uint256 public proceeds;
    uint256 public proceedsOfRebaseToken;


    modifier isMaxSupply(uint256 _amount) {
        require(totalSupply() + _amount <= maxSupply, "Max supply exceeded");
        _;
    }

    modifier isBondingCurveMaxSupply(uint256 _amount) {
        require(totalSupply() + _amount <= bondingCurveMaxSupply, "Bonding curve max supply exceeded");
        _;
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address defaultAdmin, address bondingCurveAddress)
        initializer public
    {
        __ERC20_init("ot", "ot");
        __ERC20Burnable_init();
        __ERC20Pausable_init();
        __AccessControl_init();
        __ERC20Permit_init("ot");
        __ERC20Votes_init();
        __UUPSUpgradeable_init();
        
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(PAUSER_ROLE, defaultAdmin);
        _grantRole(MINTER_ROLE, defaultAdmin);
        _grantRole(MINTER_ROLE, bondingCurveAddress);
        _grantRole(UPGRADER_ROLE, defaultAdmin);
    }

    receive() external payable {
        _feeRecieve();
    }

    fallback() external payable {
        _feeRecieve();
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

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function setRebaseToken(address _rebaseToken) external onlyRole(DEFAULT_ADMIN_ROLE) {
        rebaseToken = _rebaseToken;
    }

    function proceedToRebase() external onlyRole(DEFAULT_ADMIN_ROLE) {
        IPayment transRebase = IPayment(rebaseToken);
        transRebase.stakeFor{value: proceeds}(address(this));
        proceedsOfRebaseToken += proceeds;
        proceeds = 0;
    }

    function transferRebaseToken(address _to) external onlyRole(DEFAULT_ADMIN_ROLE) {
        IERC20 _rebaseToken = IERC20(rebaseToken);
        _rebaseToken.transfer(_to, _rebaseToken.balanceOf(address(this)));
    }

    function bondingCurveMint(address _to, uint256 _amount) external isBondingCurveMaxSupply(_amount) onlyRole(MINTER_ROLE) {
        mint(_to, _amount);
    }

    function bondingCurveBurn(address _from, uint256 _amount) external onlyRole(MINTER_ROLE) {
        burnFrom(_from, _amount);
    }   

    function _feeRecieve() internal {
        proceeds += msg.value;
    }
}