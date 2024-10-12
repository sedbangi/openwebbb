// SPDX-License-Identifier: MIT

// https://decert.me/challenge/063c14be-d3e6-41e0-a243-54e35b1dde58
// Author: chenyuqing

pragma solidity ^0.8.26;
import "./IBank.sol";

contract Admin {
    address public admin;

    constructor() {
        admin = msg.sender;
    }

    receive() external payable {}

    function adminWithdraw(IBank _bank) public {
        require(msg.sender == admin, "only admin can withdraw");
        IBank(_bank).withdraw();
    }

    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }
    
     function getOwnerAddress() public view returns(address) {
        return address(admin);
    }
}