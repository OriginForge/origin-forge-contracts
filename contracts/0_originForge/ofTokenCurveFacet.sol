// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {modifiersFacet} from "../shared/utils/modifiersFacet.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";


contract ofTokenCurveFacet is modifiersFacet, ReentrancyGuard{
    using SafeERC20 for IERC20;
    using SafeCast for uint256;
    
    uint256 private constant TRADE_FEE = 100; // 1%
    uint256 private constant FEE_DENOMINATOR = 10000; // 100%

    uint256 public ofTokenCurveSupply;
    uint256 public ofTokenCurveMaxSupply;

    struct BondStep {
        uint256 rangeTo;
        uint256 price;
    }

    struct Trade {
        uint256 tradeId;
        bool tradeType; // true: mint, false: burn
        address user;
        string nickname;
        uint256 inputAmount;
        uint256 outputAmount;
        uint256 tradeTime;
    }

    uint256 public tradeCount;
    BondStep[] public bondSteps;
    mapping(uint256 => Trade) public tradeHistory;
    
    event BC_Mint(
        address indexed user,
        uint256 inputAmount,
        uint256 mintedAmount,
        uint256 tradeFeeAmount,
        uint256 timestamp
    );

    event BC_Burn(
        address indexed user,
        uint256 burnAmount,
        uint256 tradeFeeAmount,
        uint256 refundAmount,
        uint256 timestamp
    );

    uint256 public tradeFee = 100; // 1% default
    

    function bc_set_steps(BondStep[] memory _bondSteps) public onlyAdmin{
        bondSteps = _bondSteps;
    }

    function bc_mint() public payable nonReentrant returns (uint256) {
        (uint256 actualPaymentAmount, uint256 bondTokenAmount, uint256 feeAmount) = bc_estimate_mint_for_token(msg.value);

        require(msg.value >= actualPaymentAmount, "Insufficient payment");
        require(bondTokenAmount > 0, "No bond tokens minted");

        address bank = s.contractAddresses['bank'];
        require(bank != address(0), "Invalid bank address");

        (bool feeSuccess, ) = bank.call{value: feeAmount}("");
        require(feeSuccess, "Failed to send fee to bank");
        
        ofTokenCurveSupply += bondTokenAmount;

        tradeCount++;
        tradeHistory[tradeCount] = Trade({
            tradeId: tradeCount,
            tradeType: true, // mint
            user: msg.sender,
            nickname: s.usersByAddress[msg.sender].nickname,
            inputAmount: msg.value,
            outputAmount: bondTokenAmount,
            tradeTime: block.timestamp
        });

        emit BC_Mint(msg.sender, msg.value, bondTokenAmount, feeAmount, block.timestamp);
        return bondTokenAmount;
    }

    function bc_burn(uint256 _amount, uint256 _minRefundExpected) public nonReentrant returns (uint256) {
        require(_amount > 0, "Amount must be greater than 0");
        require(ofTokenCurveSupply >= _amount, "Insufficient supply");
        
        address ofTokenAddress = s.contractAddresses['ofToken'];
        address bank = s.contractAddresses['bank'];
        require(ofTokenAddress != address(0) && bank != address(0), "Invalid addresses");

        uint256 tradeFeeInToken = (_amount * tradeFee) / FEE_DENOMINATOR;
        uint256 actualBurnAmount = _amount - tradeFeeInToken;

        uint256 refundAmount = bc_estimate_burn_for_token(actualBurnAmount);
        require(refundAmount > 0, "No refund amount");
        require(refundAmount >= _minRefundExpected, "Refund amount too low");
        
        require(address(this).balance >= refundAmount, "Insufficient contract balance");

        ofTokenCurveSupply -= _amount;

        tradeCount++;
        tradeHistory[tradeCount] = Trade({
            tradeId: tradeCount,
            tradeType: false, // burn
            user: msg.sender,
            nickname: s.usersByAddress[msg.sender].nickname,
            inputAmount: _amount,
            outputAmount: refundAmount,
            tradeTime: block.timestamp
        });

        IERC20(ofTokenAddress).safeTransferFrom(msg.sender, address(this), _amount);
        
        IERC20(ofTokenAddress).safeTransfer(bank, tradeFeeInToken);
        
        IERC20(ofTokenAddress).safeTransfer(address(0), actualBurnAmount);

        (bool success, ) = msg.sender.call{value: refundAmount}("");
        require(success, "Failed to send refund");

        emit BC_Burn(
            msg.sender,
            _amount,
            tradeFeeInToken,
            refundAmount,
            block.timestamp
        );

        return refundAmount;
    }

    function bc_estimate_mint_for_token(uint256 _amount) public view returns (uint256 actualPaymentAmount, uint256 bondTokenAmount, uint256 feeAmount){
        BondStep[] memory steps = bondSteps;
        uint256 currentSupply = ofTokenCurveSupply;

        
        feeAmount = Math.ceilDiv(_amount * TRADE_FEE, FEE_DENOMINATOR);
        uint256 reserveLeft = _amount - feeAmount;

        uint initialReserve = reserveLeft;
    
        bondTokenAmount = 0;

        for(uint256 i = getCurrentStep(); i < steps.length; ++i){
            uint256 price = steps[i].price;
            uint256 supplyLeft = steps[i].rangeTo - currentSupply;

            if(price == 0) continue;

            uint256 tokensInStep;
            {
                if(price > 0) {
                    tokensInStep = Math.ceilDiv(reserveLeft * 1e18, price);
                } else {
                    continue;
                }
            }

            if(tokensInStep > supplyLeft){
                if(supplyLeft == 0) continue;
             
                bondTokenAmount += supplyLeft;
                uint256 usedReserve = Math.ceilDiv(supplyLeft * price, 1e18);

                if(usedReserve <= reserveLeft){
                    reserveLeft -= usedReserve;
                    currentSupply += supplyLeft;
                } else {
                    uint256 maxTokens = Math.ceilDiv(reserveLeft * 1e18, price);
                    bondTokenAmount += maxTokens;
                    currentSupply += maxTokens;
                    reserveLeft = 0;
                    break;
                }
            }  else {
                bondTokenAmount += tokensInStep;
                currentSupply += tokensInStep;
                reserveLeft = 0;
                break;
            }

            if(currentSupply > ofTokenCurveMaxSupply) {
                uint256 excess = currentSupply - ofTokenCurveMaxSupply;
                bondTokenAmount -= excess;
                currentSupply = ofTokenCurveMaxSupply;

                reserveLeft = initialReserve - Math.ceilDiv(bondTokenAmount * price, 1e18);
                break;
            }
        }
    
        uint256 _usedReserve = initialReserve - reserveLeft;
        actualPaymentAmount = _usedReserve + tradeFee;

        return (actualPaymentAmount, bondTokenAmount, tradeFee);
    }

    function bc_estimate_burn_for_token(uint256 _amount) public view returns (uint256) {
        require(_amount <= ofTokenCurveSupply, "Amount exceeds supply");
        
        uint256 currentSupply = ofTokenCurveSupply;
        uint256 refundAmount = 0;
        uint256 remainingTokens = _amount;
        
        for(uint256 i = getCurrentStep(); i >= 0 && remainingTokens > 0; i--) {
            uint256 supplyInStep;
            if(i == 0) {
                supplyInStep = currentSupply;
            } else {
                supplyInStep = currentSupply - bondSteps[i-1].rangeTo;
            }
                
            uint256 tokensToProcess = remainingTokens < supplyInStep ? remainingTokens : supplyInStep;
            refundAmount += (tokensToProcess * bondSteps[i].price) / 1e18;
            
            remainingTokens -= tokensToProcess;
            currentSupply -= tokensToProcess;
            
            if(i == 0) break;
        }
        
        return refundAmount;
    }

    

    function getCurrentStep() public view returns(uint256 step){
        for(uint256 i = 0; i < bondSteps.length; i++){
            if( ofTokenCurveSupply <= bondSteps[i].rangeTo ){
                return i;
            }
        }
    }

    


    // front call

    function bc_get_trade_history_byPage(uint256 _page, uint256 _TRADES_PER_PAGE) public view returns (
        Trade[] memory trades,
        uint256 currentPage,
        uint256 totalPages
    ) {
        require(_page > 0, "Page must be greater than 0");
        
        totalPages = (tradeCount + _TRADES_PER_PAGE - 1) / _TRADES_PER_PAGE;
        require(_page <= totalPages, "Page exceeds total pages");
        
        currentPage = _page;
        
        uint256 startIndex = (_page - 1) * _TRADES_PER_PAGE;
        uint256 endIndex = Math.min(startIndex + _TRADES_PER_PAGE - 1, tradeCount - 1);
        
        // 현재 페이지의 거래 내역 조회
        uint256 size = endIndex - startIndex + 1;
        trades = new Trade[](size);
        
        for (uint256 i = 0; i < size; i++) {
            trades[i] = tradeHistory[tradeCount - 1 - (startIndex + i)];
        }
        
        return (trades, currentPage, totalPages);
    }

    // 전체 페이지 수를 조회하는 함수
    function bc_get_total_pages(uint256 _TRADES_PER_PAGE) public view returns (uint256) {
        return (tradeCount + _TRADES_PER_PAGE - 1) / _TRADES_PER_PAGE;
    }

    // 관리자용 수수료 설정 함수
    function setTradeFee(uint256 _newFee) external onlyAdmin {
        require(_newFee < FEE_DENOMINATOR, "Fee too high");
        tradeFee = _newFee;
    }



}