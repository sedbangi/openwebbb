// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/TokenBank.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract MockERC20 is ERC20, ERC20Permit {
    constructor() ERC20("MockToken", "MTK") ERC20Permit("MockToken") {
        _mint(msg.sender, 10000 * 10 ** decimals());
    }
}

contract TokenBankTest is Test {
    TokenBank tokenBank;
    MockERC20 token1;
    MockERC20 token2;

    address user = address(0x1);
    
    function setUp() public {
        token1 = new MockERC20();
        token2 = new MockERC20();
        tokenBank = new TokenBank(token1, token2);
    }

    function testDeposit() public {
        uint256 amount = 100 * 10 ** token1.decimals();
        
        // User needs to approve the TokenBank first
        token1.approve(address(tokenBank), amount);
        
        // Deposit
        tokenBank.deposit(token1, amount);
        
        assertEq(tokenBank.balanceOf(user), amount);
    }

    function testWithdraw() public {
        uint256 amount = 50 * 10 ** token1.decimals();
        
        // User needs to approve the TokenBank first
        token1.approve(address(tokenBank), amount);
        tokenBank.deposit(token1, amount);
        
        // Withdraw
        tokenBank.withdraw(token1, amount);
        
        assertEq(tokenBank.balanceOf(user), 0);
    }

    function testPermitDeposit() public {
        uint256 amount = 100 * 10 ** token1.decimals();
        uint256 deadline = block.timestamp + 1 hours;

        // Sign and generate v, r, s
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(user, 
            keccak256(abi.encodePacked(
                "\x19\x01",
                token1.DOMAIN_SEPARATOR(),
                keccak256(abi.encode(
                    // token1.PERMIT_TYPEHASH(),
                    user,
                    address(tokenBank),
                    amount,
                    deadline
                ))
            ))
        );

        // Use permitDeposit function to deposit
        tokenBank.permitDeposit(token1, amount, deadline, v, r, s);
        
        assertEq(tokenBank.balanceOf(user), amount);
    }
}
