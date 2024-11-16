// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

// import {modifiersFacet} from "../shared/utils/modifiersFacet.sol";

contract adminFacet {
    function getContractVersion() external view returns (uint256) {
        return 1;
    }
}
