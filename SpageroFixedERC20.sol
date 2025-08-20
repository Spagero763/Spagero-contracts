// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SpageroFixedERC20 is ERC20 {
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 initialSupply // whole tokens, 18 decimals
    ) ERC20(name_, symbol_) {
        _mint(msg.sender, initialSupply * 1e18);
    }
}
