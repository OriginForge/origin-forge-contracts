// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {modifiersFacet} from "../shared/utils/modifiersFacet.sol";

contract pointFacet is modifiersFacet {
//  mapping(address => uint256) public points;
//     mapping(address => uint256) public lastClaimTime;
//     mapping(address => uint256) public userAcc;
//     address public owner;
    
//     uint256 public constant DECIMALS = 18;
//     uint256 public constant POINT_MULTIPLIER = 10**DECIMALS;
//     uint256 public constant MAX_CLAIMABLE_POINTS = 20 * POINT_MULTIPLIER; // 20 points with 18 decimals

//     event PointsClaimed(address indexed user, uint256 amount);
//     event PointsSpent(address indexed user, uint256 amount);
//     event AccUpdated(address indexed user, uint256 newAcc);

//     constructor() {
//         owner = msg.sender;
//     }

//     modifier onlyOwner() {
//         require(msg.sender == owner, "Only owner can execute this function");
//         _;
//     }

//     // acc도 18 decimals 적용 (예: 1 point/sec = 1000000000000000000)
//     function setUserAcc(address user, uint256 acc) public onlyOwner {
//         userAcc[user] = acc;
//         if (lastClaimTime[user] == 0) {
//             lastClaimTime[user] = block.timestamp;
//         }
//         emit AccUpdated(user, acc);
//     }

//     function calculateAvailablePoints(address user) public view returns (uint256) {
//         if (userAcc[user] == 0) {
//             return 0;
//         }

//         uint256 timePassed = lastClaimTime[user] == 0 ? 0 : block.timestamp - lastClaimTime[user];
//         uint256 pointsEarned = timePassed * userAcc[user];
        
//         return pointsEarned > MAX_CLAIMABLE_POINTS ? MAX_CLAIMABLE_POINTS : pointsEarned;
//     }

//     function claimPoints() public {
//         uint256 availablePoints = calculateAvailablePoints(msg.sender);
//         require(availablePoints > 0, "No points available to claim");
        
//         points[msg.sender] += availablePoints;
//         lastClaimTime[msg.sender] = block.timestamp;
        
//         emit PointsClaimed(msg.sender, availablePoints);
//     }

//     function spendPoints(uint256 amount) public {
//         uint256 currentPoints = getPoints(msg.sender);
//         require(currentPoints >= amount, "Insufficient points balance");
        
//         uint256 availablePoints = calculateAvailablePoints(msg.sender);
//         if (availablePoints > 0) {
//             points[msg.sender] += availablePoints;
//             lastClaimTime[msg.sender] = block.timestamp;
//         }
        
//         points[msg.sender] -= amount;
//         emit PointsSpent(msg.sender, amount);
//     }

//     function getPoints(address user) public view returns (uint256) {
//         return points[user] + calculateAvailablePoints(user);
//     }

//     // Helper function to convert points to human readable format
//     function getPointsReadable(address user) public view returns (uint256) {
//         return getPoints(user) / POINT_MULTIPLIER;
//     }

//     // Helper function to convert acc to human readable format
//     function getAccReadable(address user) public view returns (uint256) {
//         return userAcc[user] / POINT_MULTIPLIER;
//     }


}