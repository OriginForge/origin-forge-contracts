// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

interface IPayment {
    function stakeFor(address recipient) external payable;
    function reFund(
        address _sender,
        uint _reFundAmount
    ) external returns (uint, uint);
    function unstake(uint256 amount) external returns (uint256);
}