// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

// File: SpageroEscrow.sol


pragma solidity ^0.8.24;


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
