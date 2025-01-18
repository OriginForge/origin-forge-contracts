// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {modifiersFacet} from "../shared/utils/modifiersFacet.sol";
import {IERC20} from "../shared/interfaces/IERC20.sol";
// ReentrancyGuard

contract bondingCurveFacet is modifiersFacet {

address public OF_TOKEN;

uint256 public constant FEE_DENOMINATOR = 10000; // 100%
uint256 public constant FEE_RATE = 100; // 1%

struct Curve {
    
    Step[] steps;
}

struct Step {
    uint256 range;
    uint256 price;
}


function buyOFToken(uint256 _amount) external {
}

function sellOFToken(uint256 _amount) external {
}


function estimateBuyPrice(uint256 _amount) external view returns (uint256) {

}

function estimateSellPrice(uint256 _amount) external view returns (uint256) {

}

function getCurrentStep() external view returns (uint256) {

}






}