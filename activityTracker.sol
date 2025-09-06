// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract DailyActivity {
    struct Log {
        uint256 timestamp;
        string activity;
    }

    mapping(address => Log[]) public logs;
    mapping(address => uint256) public reputation;

    event ActivityLogged(address indexed user, string activity, uint256 time);

    function logActivity(string calldata _activity) external {
        logs[msg.sender].push(Log(block.timestamp, _activity));
        reputation[msg.sender] += 1; // +1 point per log
        emit ActivityLogged(msg.sender, _activity, block.timestamp);
    }

    function getLogs(address _user) external view returns (Log[] memory) {
        return logs[_user];
    }

    function getReputation(address _user) external view returns (uint256) {
        return reputation[_user];
    }
}
