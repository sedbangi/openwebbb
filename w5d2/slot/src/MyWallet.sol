// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

// https://decert.me/challenge/163c68ab-8adf-4377-a1c2-b5d0132edc69
// chenyuqing

contract MyWallet {
    string public name;
    mapping (address => bool) privateapproved;
    address public owner;

    modifier auth {
        require (msg.sender == owner, "Not authorized");
        _;
    }
    constructor(string memory _name) {
        name = _name;
        owner = msg.sender;
    }
    function transferOwernship(address _addr) public auth {
        require(_addr!=address(0), "New owner is the zero address");
        require(owner != _addr, "New owner is the same as the old owner");
        // owner = _addr;
        // owner: slot 2
        assembly {
            sstore(2, _addr)
        }
    }
}