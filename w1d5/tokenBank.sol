// SPDX-License-Identifier: MIT

// https://decert.me/challenge/eeb9f7d8-6fd0-4c38-b09c-75a29bd53af3
// Author: chenyuqing

pragma solidity ^0.8.26;

contract TokenBank {
    address public owner;
    uint256 public totalSupply;
    mapping(address=>uint256) balanceOf;

    event Deposit(address indexed account, uint256 amount);
    event Withdraw(address indexed account, uint256 amount);
  

    constructor() {
        owner = msg.sender;
    }

    receive() external payable {
        deposit();
    }

    function _mint(address _from, uint256 _amount) internal {
        totalSupply += _amount;
        balanceOf[_from] += _amount;
    }

    function _burn(address _to, uint256 _amount) internal {
        totalSupply -= _amount;
        balanceOf[_to] -= _amount;
    }

    function deposit() public payable {
        _mint(msg.sender, msg.value);
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external {
        require(balanceOf[msg.sender] >= amount, "out of amount");
        _burn(msg.sender, amount);
        payable(msg.sender).transfer(amount);
        emit Withdraw(msg.sender, amount);
    }

    function getBalByAddr(address addr) external view returns(uint256) {
        return balanceOf[addr];
    }
}
