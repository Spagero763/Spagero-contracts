// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SpageroSimpleAirdrop is Ownable {
    IERC20 public immutable token;
    mapping(address => uint256) public allowance;
    event Seed(address indexed user, uint256 amount);
    event Claimed(address indexed user, uint256 amount);

    constructor(IERC20 token_) Ownable(msg.sender) { token = token_; }

    function seed(address[] calldata users, uint256[] calldata amounts) external onlyOwner {
        require(users.length == amounts.length, "length mismatch");
        for (uint256 i; i < users.length; i++) {
            allowance[users[i]] = amounts[i];
            emit Seed(users[i], amounts[i]);
        }
    }

    function claim() external {
        uint256 amt = allowance[msg.sender];
        require(amt > 0, "nothing to claim");
        allowance[msg.sender] = 0;
        require(token.transfer(msg.sender, amt), "transfer failed");
        emit Claimed(msg.sender, amt);
    }

    function recover(address to, uint256 amount) external onlyOwner {
        require(token.transfer(to, amount), "transfer failed");
    }
}
