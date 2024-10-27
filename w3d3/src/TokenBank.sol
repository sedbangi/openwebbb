// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";


contract TokenBank {
    IERC20 public immutable token1;
    IERC20 public immutable token2;

    mapping(address => uint256) public balanceOf;

    event Deposit(address indexed user, IERC20 indexed token, uint256 amount);
    event Withdraw(address indexed user, IERC20 indexed token, uint256 amount);

    constructor(IERC20 _token1, IERC20 _token2) {
        token1 = IERC20(_token1);
        token2 = IERC20(_token2);
    }

    // deposit with permit 
    function permitDeposit(IERC20 token, uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
        ERC20Permit(address(token)).permit(
            msg.sender, 
            address(this), 
            amount, 
            deadline, 
            v,
            r,
            s);
        deposit(token, amount);
    }

    // deposit without permit
    function deposit(IERC20 token, uint256 amount) public {
        require(amount > 0, "Amount must be greater than 0");
        token.transferFrom(msg.sender, address(this), amount);

        balanceOf[msg.sender] += amount;
        emit Deposit(msg.sender, token, amount);
    }

    function withdraw(IERC20 token, uint256 amount) public {
        require(amount > 0, "amount must be greater than 0");
        require(balanceOf[msg.sender] >= amount, "Insufficient balances");

        balanceOf[msg.sender] -= amount;
        token.transfer(msg.sender, amount);
        emit Withdraw(msg.sender, token, amount);  
    }

}