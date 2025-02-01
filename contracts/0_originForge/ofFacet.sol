// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {modifiersFacet} from "../shared/utils/modifiersFacet.sol";
import "../shared/storage/structs/AppStorage.sol";



contract ofFacet is modifiersFacet{

    event OF_RegisterUser(address indexed user, uint256 indexed index, string indexed nickname, Nation nation);

    // setter
    function of_setContractAddress(string memory serviceName, address contractAddress) public onlyAdmin {
        s.contractAddresses[serviceName] = contractAddress;
    }

    function of_registerUser(address _user, string memory _nickname, Nation _nation) public {
        require(s.usersByAddress[_user].userAddress == address(0), "User already exists");
        require(s.usersByNickname[_nickname] == address(0), "Nickname already taken");
        
        s.userCount++;
        
        User storage user = s.usersByAddress[_user];
        user.nickname = _nickname;
        user.userIndex = s.userCount;
        user.userAddress = _user;
        user.nation = Nation(_nation);
        user.originNumber = 0;

        s.usersByIndex[s.userCount] = _user;
        s.usersByNickname[_nickname] = _user;
        
        // Update nation user count
        s.nations[Nation(_nation)].userCount++;

        emit OF_RegisterUser(_user, s.userCount, _nickname, _nation);
    }

    function of_getOFStatus() public view returns (OFStatus memory) {
        return s.ofStatus;
    }

    //////////////////
    function of_getUserInfo(address _userAddress) public view returns (User memory) {
        return s.usersByAddress[_userAddress];
    }

    function of_getUserByIndex(uint256 _index) public view returns (User memory) {
        return s.usersByAddress[s.usersByIndex[_index]];
    }

    function of_getUserByNickname(string memory _nickname) public view returns (User memory) {
        return s.usersByAddress[s.usersByNickname[_nickname]];
    }
    ////////////////// 

    function of_getNationInfo(Nation _nation) public view returns (NationInfo memory) {
        return s.nations[_nation];
    }

    function of_getContractAddress(string memory _contractName) public view returns (address) {
        return s.contractAddresses[_contractName];
    }
}