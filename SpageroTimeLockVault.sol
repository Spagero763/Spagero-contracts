// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract SpageroTimeLockVault {
    address public immutable owner;
    uint256 public immutable unlockTime;

    constructor(uint256 unlockTimestamp) payable {
        owner = msg.sender;
        unlockTime = unlockTimestamp;
    }

    receive() external payable {}

    function withdraw(address payable to, uint256 amount) external {
        require(msg.sender == owner, "only owner");
        require(block.timestamp >= unlockTime, "locked");
        (bool ok, ) = to.call{value: amount}("");
        require(ok, "transfer failed");
    }
}
