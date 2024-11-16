// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {EnumerableSet} from "../../libraries/LibEnumerableSet.sol";
import {UintQueueLibrary} from "../../libraries/LibUintQueueLibrary.sol";


using EnumerableSet for EnumerableSet.UintSet;
using UintQueueLibrary for UintQueueLibrary.UintQueue;

struct Version {
    uint256 version;
}
struct Map {
    uint[][] map;
}
struct AppStorage {
    Version version;
}
