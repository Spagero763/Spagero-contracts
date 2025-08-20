// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract SpageroNFT721 is ERC721URIStorage, Ownable, ReentrancyGuard {
    uint256 public immutable maxSupply;
    uint256 public mintPrice;
    uint256 private _nextId;
    string public baseURI;

    constructor(string memory name_, string memory symbol_, uint256 maxSupply_, uint256 mintPriceWei_, string memory baseURI_)
        ERC721(name_, symbol_) Ownable(msg.sender)
    {
        maxSupply = maxSupply_;
        mintPrice = mintPriceWei_;
        baseURI = baseURI_;
    }

    function setMintPrice(uint256 newPrice) external onlyOwner { mintPrice = newPrice; }
    function setBaseURI(string calldata newBase) external onlyOwner { baseURI = newBase; }

    function _baseURI() internal view override returns (string memory) { return baseURI; }

    function mint(uint256 quantity) external payable nonReentrant {
        require(quantity > 0, "qty=0");
        require(msg.value == mintPrice * quantity, "bad value");
        require(_nextId + quantity <= maxSupply, "sold out");
        for (uint256 i = 0; i < quantity; i++) {
            _nextId++;
            _safeMint(msg.sender, _nextId);
        }
    }

    function withdraw(address payable to) external onlyOwner {
        (bool ok, ) = to.call{value: address(this).balance}("");
        require(ok, "withdraw failed");
    }
}
