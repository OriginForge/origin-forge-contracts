// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { LibDiamond } from "../../libraries/LibDiamond.sol";
import "../structs/BondingCurveStorage.sol";

contract BondingCurveStorageFacet {
    BondingCurveStorage internal bcs;
    
    function bondingCurveStorage() internal pure returns (BondingCurveStorage storage ds){
      bytes32 position = keccak256("diamond.originforge.bondingCurve");
      assembly {
        ds.slot := position
      }
    }

}
