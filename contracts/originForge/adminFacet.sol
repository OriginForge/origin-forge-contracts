// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {modifiersFacet} from "../shared/utils/modifiersFacet.sol";
import {User, SBT} from "../shared/storage/structs/AppStorage.sol";
import {IERC721} from "../shared/interfaces/IERC721.sol";
interface IVRF {
    function requestRandomWords() external returns (uint256 requestId);
}

contract adminFacet is modifiersFacet {

    event UserRegistered(address indexed userAddress, string indexed userNickName, uint256 indexed userSBTId);
    event MintedSBT(address indexed userAddress, uint256 indexed userSBTId);

    function admin_setContractAddress(string memory _contractName, address _contractAddress) external onlyAdmin {
        s.contractNames[_contractName] = _contractAddress;
    }



    function userRegister(address _userAddress, string memory _userNickName) external {

        string memory _lowerNickName = lower(_userNickName);


        require(s.isUseNickName[_lowerNickName] == false, "NickName is already used");
        // _userNickname length check 2~15 characters and only allow english and numbers
        require(bytes(_lowerNickName).length >= 2 && bytes(_lowerNickName).length <= 15, "NickName length must be between 2 and 15");
        bytes memory b = bytes(_lowerNickName);
        
        for(uint i; i < b.length; i++) {
            require(
                (b[i] >= 0x30 && b[i] <= 0x39) || // numbers 0-9
                (b[i] >= 0x61 && b[i] <= 0x7A),   // lowercase a-z
                "NickName can only contain english letters and numbers"
            );
        }

        require(s.users[_userAddress].userAddress == address(0), "User already registered");
        IERC721 nft = IERC721(s.contractNames["nft"]);
        
        
        // IVRF vrf = IVRF(s.contractNames["originValueVRF"]);
        // uint256 requestId = vrf.requestRandomWords(); 
        uint256 requestId = ((uint256(keccak256(abi.encodePacked(_userAddress, _userNickName, block.timestamp)))) % 10**20) + 10**19;
        s.users[_userAddress].userAddress = _userAddress;
        s.users[_userAddress].userNickName = _lowerNickName;
        s.users[_userAddress].userSBTId = _get_nextId();
        s.users[_userAddress].originValue = requestId;
        // mapping settings
        s.isUseNickName[_lowerNickName] = true;
        s.nickNameToAddress[_lowerNickName] = _userAddress;

        emit UserRegistered(_userAddress, _lowerNickName, _get_nextId());
        // mint SBT
        nft.increaseTokenId();
    }


    function userSafeMintSBT(address _userAddress) external {
        
        require(s.users[_userAddress].userAddress != address(0), "User not registered");
        
        // nft contract 주소로 직접 호출
        (bool success, bytes memory data) = s.contractNames["nft"].call(
            abi.encodeWithSignature(
                "safeMint(address,uint256)", 
                _userAddress,
                s.users[_userAddress].userSBTId
            )
        );

        require(success, "NFT minting failed");
        
        emit MintedSBT(_userAddress, s.users[_userAddress].userSBTId);
    }


    function isUseNickName(string memory _userNickName) external view returns (bool) {
        return s.isUseNickName[lower(_userNickName)];
    }

    function getUser(address _userAddress) external view returns (User memory) {
        return s.users[_userAddress];
    }
    
    function getSBTImage(uint256 _userSBTId) external view returns (SBT memory) {
        return s.sbt[_userSBTId];
    }

    function getUserFromNickName(string memory _userNickName) external view returns (User memory) {
        return s.users[s.nickNameToAddress[lower(_userNickName)]];
    }

    


    // utils

    
    function lower(string memory _base) internal pure returns (string memory) {
        bytes memory _baseBytes = bytes(_base);
        for (uint i = 0; i < _baseBytes.length; i++) {
            _baseBytes[i] = _lower(_baseBytes[i]);
        }
        return string(_baseBytes);
    }

    function _lower(bytes1 _b1) private pure returns (bytes1) {
        if (_b1 >= 0x41 && _b1 <= 0x5A) {
            return bytes1(uint8(_b1) + 32);
        }

        return _b1;
    }

    function _get_nextId() internal view returns (uint256) {
        IERC721 nft = IERC721(s.contractNames["nft"]);
        return nft._nextTokenId();
    }



}

