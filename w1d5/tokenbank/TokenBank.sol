// SPDX-License-Identifier: MIT
// https://decert.me/challenge/eeb9f7d8-6fd0-4c38-b09c-75a29bd53af3
// Author: chenyuqing

pragma solidity 0.8.26;
import "./IERC20.sol";

contract TokenBank {
    IERC20 public token;

    mapping(address => uint256) public balances;

    constructor(IERC20 _token) {
        token = _token;
    }

    receive() external payable {}

    function deposit(uint256 amount) public {
        require(amount > 0, "Amount must be greater than 0");
        token.transferFrom(msg.sender, address(this), amount);

        balances[msg.sender] += amount;
    }

    function withdraw(uint256 amount) public {
        require(amount > 0, "amount must be greater than 0");
        require(balances[msg.sender] >= amount, "Insufficient balances");

        balances[msg.sender] -= amount;
        token.transfer(msg.sender, amount);
    }

}