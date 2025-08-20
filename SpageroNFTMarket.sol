// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract SpageroNFTMarket is ReentrancyGuard {
    struct Listing { address seller; address nft; uint256 tokenId; uint256 price; }
    mapping(bytes32 => Listing) public listings;

    event Listed(address indexed seller, address indexed nft, uint256 indexed tokenId, uint256 price);
    event Cancelled(address indexed seller, address indexed nft, uint256 indexed tokenId);
    event Purchased(address indexed buyer, address indexed nft, uint256 indexed tokenId, uint256 price);

    function _key(address nft, uint256 tokenId) private pure returns (bytes32) {
        return keccak256(abi.encodePacked(nft, tokenId));
    }

    function list(address nft, uint256 tokenId, uint256 price) external {
        require(price > 0, "price=0");
        IERC721 token = IERC721(nft);
        require(token.ownerOf(tokenId) == msg.sender, "not owner");
        require(token.isApprovedForAll(msg.sender, address(this)) || token.getApproved(tokenId) == address(this),
            "market not approved");
        bytes32 k = _key(nft, tokenId);
        listings[k] = Listing(msg.sender, nft, tokenId, price);
        emit Listed(msg.sender, nft, tokenId, price);
    }

    function cancel(address nft, uint256 tokenId) external {
        bytes32 k = _key(nft, tokenId);
        Listing memory l = listings[k];
        require(l.seller != address(0), "not listed");
        require(l.seller == msg.sender, "not seller");
        delete listings[k];
        emit Cancelled(msg.sender, nft, tokenId);
    }

    function buy(address nft, uint256 tokenId) external payable nonReentrant {
        bytes32 k = _key(nft, tokenId);
        Listing memory l = listings[k];
        require(l.seller != address(0), "not listed");
        require(msg.value == l.price, "bad value");
        delete listings[k];
        (bool ok, ) = payable(l.seller).call{value: msg.value}("");
        require(ok, "pay seller failed");
        IERC721(l.nft).safeTransferFrom(l.seller, msg.sender, l.tokenId);
        emit Purchased(msg.sender, nft, tokenId, msg.value);
    }
}
