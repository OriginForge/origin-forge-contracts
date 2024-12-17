// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {EnumerableSet} from "../../libraries/LibEnumerableSet.sol";
import {UintQueueLibrary} from "../../libraries/LibUintQueueLibrary.sol";


using EnumerableSet for EnumerableSet.UintSet;
using UintQueueLibrary for UintQueueLibrary.UintQueue;


struct User {
    string userNickName;
    // 유저가 등록한 지갑
    address userAddress;
    // 유저의 SBT ID
    uint256 userSBTId;
    // User의 OriginValue
    uint256 originValue;
//     // Point
//     uint256 point;
}



struct SBT {
    uint256 tokenId;
    string image;
    string seed;
    string baseEgg;
    string[] colorSet;
        
    // game status
    uint256 level;
    uint256 exp;

    // 장착한 아이템
    uint256[] equippedItems;

}


struct Item {
    uint256 itemId;
    // language
    string[] itemName;
    string[] itemDescription;
    string itemImage;
    // 능력치
    uint256 ability;
    // 아이템 타입
    string assetType; // gif, png
}

// struct Level {
//     uint256 level;
//     uint256 requiredExp;
// }

struct AppStorage {
    mapping(string => address) contractNames;
    mapping(address => User) users;
    mapping(uint256 => SBT) sbt;
    mapping(string => bool) isUseNickName;
    mapping(string => address) nickNameToAddress;

    // mapping(uint256 => Level) levels;
    // mapping(uint256 => Item) items;
}
