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
    
    event BC_Mint();
    event BC_Burn(); 


    function bc_set_steps(BondStep[] memory _bondSteps) public onlyAdmin{
        bondSteps = _bondSteps;
    }


    function bc_mint() public payable nonReentrant returns (uint256){

    }

    function bc_burn(uint256 _amount) public nonReentrant returns (uint256){

    }
    

    function bc_estimate_mint_for_token(uint256 _amount) public view returns (uint256){

    }

    function bc_estimate_burn_for_token(uint256 _amount) public view returns (uint256){

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

}