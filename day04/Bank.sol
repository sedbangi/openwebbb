// SPDX-License-Identifier: MIT

// https://decert.me/challenge/063c14be-d3e6-41e0-a243-54e35b1dde58
// Author: chenyuqing

pragma solidity ^0.8.26;
import "./IBank.sol";

contract Bank is IBank {
    address public admin;
    mapping(address=>uint256) public balances;
    address[3] public h3users;

    constructor() {
        admin = msg.sender;
    }

    receive() external payable {
        deposit();
    }

    function deposit() public payable virtual {
        require(msg.value > 0, "deposit amount must be greater than 0");
        balances[msg.sender] += msg.value;

        top3user(msg.sender);
        emit Deposit(msg.sender, msg.value);
    }


    function withdraw() public {
        uint256 bal = address(this).balance;
        require(bal > 0, "fund = 0");

        payable(admin).transfer(bal);
        emit Withdraw(admin, bal);
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

    function top3user(address _user) public {
        for(uint8 i = 0; i < h3users.length; i++) {
            if (h3users[i] == _user) {
                h3users[i] = _user;
                sortUser();
                return;
            }
        }

        if (balances[_user] > balances[h3users[2]]) {
            h3users[2] = _user;
            sortUser();
        }
    }

    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }

}