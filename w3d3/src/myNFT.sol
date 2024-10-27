// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract MyNFT is ERC721Enumerable {
    uint256 public tokenId;
    address public owner;

    constructor() ERC721("TimNFT", "TMNFT") {
        owner = msg.sender;
    }

    function mint(address to) external {
        require(msg.sender == owner, "only admin can mint");
        _safeMint(to, tokenId);
        tokenId++;
    }
}
