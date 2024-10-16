// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

interface IBank {
    function withdraw() external;
    function deposit() external payable;

    event Withdraw(address indexed owner, uint256 amount);
    event Deposit(address indexed user, uint256 amount);
}