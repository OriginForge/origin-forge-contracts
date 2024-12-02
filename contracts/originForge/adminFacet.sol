// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {modifiersFacet} from "../shared/utils/modifiersFacet.sol";
// import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {User} from "../shared/storage/structs/AppStorage.sol";

interface IVRF {
    function requestRandomWords() external returns (uint256 requestId);
}
contract adminFacet is modifiersFacet {
    // using Strings for *;

    // admin set Functions
    //
    // 
    function admin_setContractAddress(string memory _contractName, address _contractAddress) external onlyAdmin {
        s.contractNames[_contractName] = _contractAddress;
    }

    // user Register
    function admin_setRegisterUser(string memory _userId, string memory _userNickName, address _delegateAccount) external onlyAdmin  {
        string memory userId = lower(_userId);
        IVRF vrf = IVRF(s.contractNames["originValueVRF"]);
        uint256 requestId = vrf.requestRandomWords(); 
        address userWallet;
        bytes memory userIdBytes = bytes(_userId);
        
        // userId가 0x로 시작하는 경우
        if(userIdBytes.length == 42 && userIdBytes[0] == "0" && (userIdBytes[1] == 'x' || userIdBytes[1] == 'X')) {
             uint160 addr = 0;
             for (uint256 i = 2; i < 42; i++) {
                uint8 b = uint8(userIdBytes[i]);
                if (b >= 48 && b <= 57) {
                    addr = addr * 16 + (b - 48); // '0'-'9'
                    } else if (b >= 65 && b <= 70) {
                        addr = addr * 16 + (b - 55); // 'A'-'F'
                    } else if (b >= 97 && b <= 102) {
                        addr = addr * 16 + (b - 87); // 'a'-'f'
                    } else {
                        revert("Invalid character in address string");
                    }
                }

            // string _userId을 address로 변환
            userWallet = address(addr);
        } 
            
        
        s.users[userId] = User({
            userId: userId,
            userNickName: _userNickName,
            userWallet: userWallet,
            delegateAccount: _delegateAccount,
            userSBTId: 0,
            originValue: requestId
        });
        
    }


    // admin get Functions
    //
    // 
    function getContractAddress(string memory _contractName) external view returns (address) {
        return s.contractNames[_contractName];
    }


    function get_User(string memory _userId) external view returns (User memory) {
        return s.users[lower(_userId)];
    }


    

    // utils...
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



}
