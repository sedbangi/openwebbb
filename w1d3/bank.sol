// SPDX-License-Identifier: MIT

// https://decert.me/challenge/c43324bc-0220-4e81-b533-668fa644c1c3
// Author: chenyuqing

pragma solidity ^0.8.26;

contract Bank {
    address public owner;

    mapping(address => uint256) public balances;
    address[3] public h3users;

    event Withdraw(address indexed owner, uint256 amount);
    event Deposit(address indexed user, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    receive() external payable {
        deposit();
    }

    function deposit() public payable {
        require(msg.value > 0, "deposit amount must be greater than 0");
        balances[msg.sender] += msg.value;

        top3user(msg.sender);
        emit Deposit(msg.sender, msg.value);
    }


    function withdraw() public payable onlyOwner {
        uint256 bal = address(this).balance;
        require(bal > 0, "fund = 0");

        payable(owner).transfer(bal);
        emit Withdraw(owner, bal);
    }

    function sortUser() internal {
        for (uint i = 0; i < h3users.length - 1; i++) {
            for (uint j = i + 1; j < h3users.length; j++) {
                if (balances[h3users[i]] < balances[h3users[j]]) {
                    address temp = h3users[i];
                    h3users[i] = h3users[j];
                    h3users[j] = temp;
                }
            }
        }
    }

    function top3user(address user) public {
        for(uint8 i = 0; i < h3users.length; i++) {
            if (h3users[i] == user) {
                h3users[i] = user;
                sortUser();
                return;
            }
        }

        if (balances[user] > balances[h3users[2]]) {
            h3users[2] = user;
            sortUser();
        }

    }
}