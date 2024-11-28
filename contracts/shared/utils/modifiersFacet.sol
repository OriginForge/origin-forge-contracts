// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {LibDiamond} from "../libraries/LibDiamond.sol";
import {AppStorage} from "../storage/facets/AppStorageFacet.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract modifiersFacet {
    AppStorage internal s;

    modifier onlyAdmin() {
        LibDiamond.enforceIsContractOwner();
        _;
    }

    modifier onlyEOA(address _address) {
        uint32 size;
        assembly {
            size := extcodesize(_address)
        }
        
        require(size == 0, "ModifiersFacet: not EOA");
        _;
    }


    
}
