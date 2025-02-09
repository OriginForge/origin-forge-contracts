// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

struct BondingCurveStep{
    uint256 rangeTo;
    uint256 price;
}

struct BondingCurveTrade{
    uint256 tradeId;
    bool tradeType; // true: mint, false: burn
    address user;
    string nickname;
    uint256 inputAmount;
    uint256 outputAmount;
    uint256 tradeTime;
    uint256 tradeBlock;
}

struct BondingCurveStorage{
    uint256 TRADE_FEE;
    uint256 FEE_DENOMINATOR;

    uint256 ofTokenCurveSupply;
    uint256 ofTokenCurveMaxSupply;

    uint256 ofTokenCurveTradeFee;
    uint256 ofTokenCurveTradeCount;
    uint256 tradeCount;
    
    BondingCurveStep[] bondSteps;
    mapping(uint256 => BondingCurveTrade) BondingCurveTradeHistory;
}
