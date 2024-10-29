// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract AnyToken is ERC20, ERC20Burnable, Ownable, ERC20Permit {
    constructor(address initialOwner, string memory name, string memory sybol)
        ERC20(name,sybol)
        Ownable(initialOwner)
        ERC20Permit(name)
    {
        _mint(msg.sender, 80000 * 10 ** decimals());
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    // Signature + TransferFrom
    function permitTransferFrom(
        address owner,
        address to,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s) 
        external 
    {
        ERC20Permit(address(msg.sender)).permit(owner, spender, value, deadline, v, r, s);
        bool ok = transferFrom(owner, to, value);
        require(ok, "token transfer failed");
    }
}
