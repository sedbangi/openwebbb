// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract InscriptionToken is ERC20, Ownable {
    uint256 public perMint;

    constructor(
        string memory name,
        string memory symbol,
        uint256 totalSupply,
        uint256 _perMint,
        address owner
    ) ERC20(name, symbol) {
        perMint = _perMint;
        _mint(owner, totalSupply);
        transferOwnership(owner);
    }

    function mint(address to) external onlyOwner {
        _mint(to, perMint);
    }
}
