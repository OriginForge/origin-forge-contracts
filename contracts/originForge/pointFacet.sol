// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract point {
    // 1분당 기본 마이닝 파워 (20 * 10^18)
    uint256 constant public BASE_MINING_POWER = 20 * 10**18;
    // 기본 최대 채굴 가능 시간 (1분)
    uint256 constant public BASE_MAX_MINING_TIME = 1 minutes;

    // 유저 정보 구조체
    struct UserInfo {
        uint256 point; // 유저의 포인트
        address userWallet; // 유저의 지갑 주소
        uint256 miningPower; // 유저의 마이닝 파워
        uint256 maxMiningTime; // 유저의 최대 채굴 시간
    }

    // 마이닝 정보 구조체 
    struct MiningInfo {
        uint256 lastMiningTime;
        uint256 accumulatedPoints;
        bool isMining;
    }

    // 유저 정보와 마이닝 정보를 저장하는 매핑
    mapping(string => UserInfo) private users;
    mapping(string => MiningInfo) private userMining;

    // 채굴 시작
    function startMining(string memory _userId) external {
        require(!userMining[_userId].isMining, "Already mining");
        require(users[_userId].userWallet != address(0), "User not registered");

        userMining[_userId].lastMiningTime = block.timestamp;
        userMining[_userId].isMining = true;
    }

    // 분당 마이닝 포인트 계산
    function getPointsPerMinute(string memory _userId) public view returns (uint256) {
        return BASE_MINING_POWER + users[_userId].miningPower;
    }

    // 채굴된 포인트 확인
    function getMinedPoints(string memory _userId) public view returns (uint256) {
        if (!userMining[_userId].isMining) return 0;

        uint256 timePassed = block.timestamp - userMining[_userId].lastMiningTime;
        uint256 userMaxMiningTime = users[_userId].maxMiningTime > 0 ? users[_userId].maxMiningTime : BASE_MAX_MINING_TIME;
        
        if (timePassed > userMaxMiningTime) {
            timePassed = userMaxMiningTime;
        }

        // 분당 포인트 * (경과시간/1분)으로 계산
        return getPointsPerMinute(_userId) * timePassed / 1 minutes;
    }

    // 포인트 출금
    function withdrawPoints(string memory _userId) public {
        require(userMining[_userId].isMining, "Not mining");
        
        uint256 points = getMinedPoints(_userId);
        require(points > 0, "No points to withdraw");

        // 포인트 업데이트
        users[_userId].point += points;
        
        // 마이닝 정보 초기화
        userMining[_userId].lastMiningTime = block.timestamp;
        userMining[_userId].accumulatedPoints = 0;
    }

    // 채굴 상태 확인
    function getMiningStatus(string memory _userId) external view returns (
        bool isMining,
        uint256 lastMiningTime,
        uint256 currentPoints,
        uint256 pointsPerMinute
    ) {
        MiningInfo memory info = userMining[_userId];
        return (
            info.isMining,
            info.lastMiningTime,
            getMinedPoints(_userId),
            getPointsPerMinute(_userId)
        );
    }

    // 유저의 현재 포인트 확인
    function getUserPoints(string memory _userId) external view returns (uint256) {
        return users[_userId].point;
    }

    // 유저 등록 함수 추가
    function registerUser(string memory _userId, address _wallet) external {
        require(users[_userId].userWallet == address(0), "User already registered");
        users[_userId].userWallet = _wallet;
        users[_userId].point = 0;
        users[_userId].miningPower = 0;
        users[_userId].maxMiningTime = BASE_MAX_MINING_TIME;
    }

    // 마이닝 파워 증가 함수
    function increaseMiningPower(string memory _userId, uint256 _amount) external {
        require(users[_userId].userWallet != address(0), "User not registered");
        
        // 기존 채굴중이면 포인트 출금 처리
        if (userMining[_userId].isMining) {
            withdrawPoints(_userId);
        }
        
        users[_userId].miningPower += _amount;
        
        // 마이닝 재시작
        userMining[_userId].lastMiningTime = block.timestamp;
        userMining[_userId].isMining = true;
    }

    // 최대 채굴 시간 설정 함수
    function setMaxMiningTime(string memory _userId, uint256 _maxTime) external {
        require(users[_userId].userWallet != address(0), "User not registered");
        require(_maxTime > 0, "Max time must be greater than 0");
        
        // 기존 채굴중이면 포인트 출금 처리
        if (userMining[_userId].isMining) {
            withdrawPoints(_userId);
        }
        
        users[_userId].maxMiningTime = _maxTime;
        
        // 마이닝 재시작
        userMining[_userId].lastMiningTime = block.timestamp;
        userMining[_userId].isMining = true;
    }
}