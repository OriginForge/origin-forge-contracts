// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {EnumerableSet} from "../../libraries/LibEnumerableSet.sol";
import {UintQueueLibrary} from "../../libraries/LibUintQueueLibrary.sol";
import {Nation} from "./Nations.sol";

using EnumerableSet for EnumerableSet.UintSet;
using UintQueueLibrary for UintQueueLibrary.UintQueue;


struct OFStatus{
    // max supply = 100,000,000
    // teamReserve = 10% = 10,000,000
    // communityReserve = 10% = 10,000,000
    // partnerReserve = 10% = 10,000,000
    // distributionReserve = 70% = 70,000,000
    uint256 teamReserve; // team reserve
    uint256 communityReserve; // community Event, marketing, etc
    uint256 partnerReserve; // partner reserve
    
    uint256 distributionReserve; // liquidity reserve, bonding curve minting
        
    uint256 totalBurned;
    uint256 totalMaxSupply;
    
    // ================
    uint256[10] _gap;
}



// originForge Services for a OF Token State
struct Service{
    string serviceName;
    uint256 mintAmount;
    uint256 burnAmount;
    
    // ================
    uint256[10] _gap;
}

struct User{
    string nickname;
    uint256 userIndex;
    address userAddress;
    Nation nation;
    uint256 originNumber;
    // ================
    uint256[9] _gap;
}

struct NationInfo {
    string nationName;
    string nationCode;
    string nationFlag;
    uint256 userCount;

    // ================
    uint256[10] _gap;
}



struct AppStorage {
    OFStatus ofStatus;
    uint256 userCount;
    


    mapping(string => address) contractAddresses; // contract address for a service
    mapping(string => Service) services;
    
    // multi-index mapping
    mapping(address => User) usersByAddress;      // address
    mapping(uint256 => address) usersByIndex;     // index
    mapping(string => address) usersByNickname;   // nickname
    
    mapping(Nation => NationInfo) nations;
}




