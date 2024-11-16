// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.22;

// import {AppStorage} from "../../shared/storage/structs/AppStorage.sol";
// import {IPoolRouter} from "../interfaces/IPoolRouter.sol";
// import {LibMeta} from "./LibMeta.sol";
// import {IERC20} from "../interfaces/IERC20.sol";

// library LibPayment {
//     function pay(uint payAmount) internal returns (uint, uint) {
//         require(payAmount > 5 ether, "LibPayment: payAmount too low");

//         AppStorage storage s = LibAppStorage.diamondStorage();
//         IPoolRouter poolRouter = IPoolRouter(s.contracts["pangearouter"]);

//         IPoolRouter.ExactInputSingleParams memory params = IPoolRouter
//             .ExactInputSingleParams({
//                 tokenIn: address(0),
//                 amountIn: payAmount,
//                 amountOutMinimum: payAmount,
//                 pool: s.contracts["gcpool"],
//                 to: address(this),
//                 unwrap: false
//             });

//         poolRouter.exactInputSingle{value: payAmount}(params);

//         return (payAmount, block.number);
//     }

//     function rePay(
//         address _sender,
//         uint rePayAmount
//     ) internal returns (uint, uint) {
//         require(rePayAmount > 5 ether, "LibPayment: rePayAmount too low");

//         AppStorage storage s = LibAppStorage.diamondStorage();

//         IPoolRouter poolRouter = IPoolRouter(s.contracts["pangearouter"]);

//         IPoolRouter.ExactInputSingleParams memory params = IPoolRouter
//             .ExactInputSingleParams({
//                 tokenIn: s.contracts["gctoken"],
//                 amountIn: rePayAmount,
//                 amountOutMinimum: 10,
//                 pool: s.contracts["gcpool"],
//                 to: _sender,
//                 unwrap: true
//             });

//         poolRouter.exactInputSingle(params);

//         return (rePayAmount, block.number);
//     }
// }
