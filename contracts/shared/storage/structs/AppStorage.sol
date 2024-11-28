// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {EnumerableSet} from "../../libraries/LibEnumerableSet.sol";
import {UintQueueLibrary} from "../../libraries/LibUintQueueLibrary.sol";


using EnumerableSet for EnumerableSet.UintSet;
using UintQueueLibrary for UintQueueLibrary.UintQueue;


struct User {
    string userId;
    string userNickName;
    // 유저가 등록한 지갑
    address userWallet;
    // 등록한 지갑과 연결되어있는 대리 지갑
    address delegateAccount;
    // 유저의 SBT ID
    uint256 userSBTId;
    // User의 OriginValue
    uint256 originValue;
}

struct DelegateAccount {
    string userId;
    address connectedWallet;
    bool isConnected;
}

struct SBT {
    uint256 tokenId;
    string image;
    string seed;
    string baseEgg;
    string[10] colorSet;
}

struct AppStorage {
    mapping(string => address) contractNames;
    mapping(string => User) users;
    mapping(uint256 => SBT) sbt;
}
