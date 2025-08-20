// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract SpageroEscrow is ReentrancyGuard {
    struct Deal { address depositor; address payee; address arbiter; uint256 amount; bool active; }
    uint256 public nextId;
    mapping(uint256 => Deal) public deals;

    event Created(uint256 indexed id, address indexed depositor, address indexed payee, address arbiter, uint256 amount);
    event Released(uint256 indexed id);
    event Refunded(uint256 indexed id);

    function create(address payee, address arbiter) external payable returns (uint256 id) {
        require(msg.value > 0, "no funds");
        id = ++nextId;
        deals[id] = Deal(msg.sender, payee, arbiter, msg.value, true);
        emit Created(id, msg.sender, payee, arbiter, msg.value);
    }

    function release(uint256 id) external nonReentrant {
        Deal storage d = deals[id];
        require(d.active, "inactive");
        require(msg.sender == d.arbiter, "only arbiter");
        d.active = false;
        (bool ok, ) = d.payee.call{value: d.amount}("");
        require(ok, "payee transfer failed");
        emit Released(id);
    }

    function refund(uint256 id) external nonReentrant {
        Deal storage d = deals[id];
        require(d.active, "inactive");
        require(msg.sender == d.arbiter, "only arbiter");
        d.active = false;
        (bool ok, ) = d.depositor.call{value: d.amount}("");
        require(ok, "refund failed");
        emit Refunded(id);
    }
}
