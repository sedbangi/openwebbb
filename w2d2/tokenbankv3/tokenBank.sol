// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC20.sol";

contract TokenBank {

    /// @dev A mapping to store balances for each token address and user address.
    mapping(address => mapping(address => uint256)) private balances;

    function deposit(address token, uint256 amount) public {
        require(amount > 0, "Amount must be greater than zero");
        require(
            IERC20(token).transferFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );
        balances[token][msg.sender] += amount;

        // Emit an event for successful deposits (optional)
        // emit Deposit(msg.sender, token, amount);
    }

    function withdraw(address token, uint256 amount) public {
        require(amount > 0, "Amount must be greater than zero");
        require(balances[token][msg.sender] >= amount, "Insufficient balance");
        balances[token][msg.sender] -= amount;

        require(IERC20(token).transfer(msg.sender, amount), "Transfer failed");

        // Emit an event for successful withdrawals (optional)
        // emit Withdrawal(msg.sender, token, amount);
    }

    function balanceOf(address token, address account) public view returns (uint256) {
        return balances[token][account];
    }
}
