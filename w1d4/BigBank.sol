// SPDX-License-Identifier: MIT

// https://decert.me/challenge/063c14be-d3e6-41e0-a243-54e35b1dde58
// Author: chenyuqing

pragma solidity ^0.8.26;
import "./Bank.sol";

contract BigBank is Bank {

    constructor() {}

    function getOwnerAddress() public view returns(address) {
        return address(admin);
    }

    function transferOwner(address newOwner) public {
        require(msg.sender == admin, "not bigbank owner");
        require(newOwner != address(0), "new owner = address(0)");
        admin = newOwner;
    }

    modifier onlyValidValue(uint256 _amount) {
        require(_amount > 0.001 ether, "amount is less than 0.001 ether");
        _;
    }

    function deposit() public payable override onlyValidValue(msg.value) {
        balances[msg.sender] += msg.value;

        top3user(msg.sender);
        emit Deposit(msg.sender, msg.value);
    }

}