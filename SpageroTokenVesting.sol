// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/finance/VestingWallet.sol";

contract SpageroTokenVesting is VestingWallet {
    // Release ETH or any ERC20 using release(IERC20 token)
    constructor(
        address beneficiaryAddress,
        uint64 startTimestamp,
        uint64 durationSeconds
    ) VestingWallet(beneficiaryAddress, startTimestamp, durationSeconds) {}
}
