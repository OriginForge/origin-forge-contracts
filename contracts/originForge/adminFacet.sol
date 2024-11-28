// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {modifiersFacet} from "../shared/utils/modifiersFacet.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract adminFacet is modifiersFacet {
    using Strings for *;

    

    // admin set Functions
    //
    // 
    function admin_setContractAddress(string memory _contractName, address _contractAddress) external onlyAdmin {
        s.contractNames[_contractName] = _contractAddress;
    }

    // user Register
    function admin_setRegisterUser(address _userWallet, address _delegateAccount, string memory _userId, string memory _userNickName) external onlyAdmin {
        string memory userId = lower(_userId);
        

    }




    // admin get Functions
    //
    // 
    function getContractAddress(string memory _contractName) external view returns (address) {
        return s.contractNames[_contractName];
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
