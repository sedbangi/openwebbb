// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {TimTom} from "../src/Token.sol"; 

contract TimTomTest is Test {
    TimTom timTom;

    address owner = address(0x1);
    address user = address(0x2);

    function setUp() public {
        timTom = new TimTom(owner);
    }

    function testInitialSupply() public {
        uint256 initialSupply = 80000 * 10 ** timTom.decimals();
        assertEq(timTom.totalSupply(), initialSupply);
    }

    function testMint() public {
        uint256 amount = 1000 * 10 ** timTom.decimals();
        vm.prank(owner);
        timTom.mint(user, amount);
        assertEq(timTom.balanceOf(user), amount);
    }

    function testBurn() public {
        uint256 amount = 100 * 10 ** timTom.decimals();
        vm.prank(owner);
        timTom.mint(user, amount);
        vm.prank(user);
        timTom.burn(amount);
        assertEq(timTom.balanceOf(user), 0);
    }

    function testPermitTransferFrom() public {
        uint256 amount = 500 * 10 ** timTom.decimals();
        uint256 deadline = block.timestamp + 1 hours;

        vm.prank(owner);
        timTom.mint(user, amount);

        // sign a signature
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(owner, 
            keccak256(abi.encodePacked(
                "\x19\x01",
                timTom.DOMAIN_SEPARATOR(),
                keccak256(abi.encode(
                    // timTom.PERMIT_TYPEHASH(),
                    owner,
                    address(this), // spender
                    amount,
                    deadline
                ))
            ))
        );

        //call permitTransferFrom
        vm.prank(user);
        timTom.permitTransferFrom(owner, address(this), user, amount, deadline, v, r, s);
        
        // verify 
        assertEq(timTom.balanceOf(address(this)), amount);
        assertEq(timTom.balanceOf(owner), 80000 * 10 ** timTom.decimals() - amount);
    }
}
