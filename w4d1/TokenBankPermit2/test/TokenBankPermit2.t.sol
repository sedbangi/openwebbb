// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {TokenBank} from "../src/TokenBank.sol";

contract TokenBankTest is Test {
    TokenBank public tb;
    IPermit2 permitted;

    function setUp() public {
        tb = new TokenBank(permitted);
    } 

    function testdepositWithPermit2() public {
        vm.startPrank(attacker);
        
    }
}