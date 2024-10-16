// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// https://decert.me/challenge/4578ff5b-4dcb-4c28-8b5f-7456ed1ab0a4
// Author: chenyuqing

import "forge-std/Test.sol";
import {Bank} from "../src/Bank.sol";

contract BankTest is Test {
    Bank private bank;
    address private user = 0x95684300DB905a3452Deb06deBD19e4De7706152;
    event Deposit(address indexed user, uint amount);

    function setUp() public {
        bank = new Bank();
    }

    function test_depositETH() public {
        uint256 amount = 1 ether;
        // initial balance of user
        uint256 initBal = bank.balanceOf(user);
        assertEq(initBal, 0);

        // deposit 1 ether to user
        vm.deal(user, amount);
        vm.prank(user);
        // 1. assert to check the output of the event
        vm.expectEmit(true, true, true, true);
        emit Deposit(user, amount);
        
        // 2. assert to check the balance of user
        bank.depositETH{value: amount}();
        uint256 newBal = bank.balanceOf(user);
        assertEq(newBal, initBal + amount);

    }
}