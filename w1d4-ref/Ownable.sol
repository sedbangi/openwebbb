// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IBigBank} from "./IBigBank.sol";

// Ownable contract to manage ownership and interact with BigBank
contract Ownable {
    address public owner; // Owner's address

    IBigBank public bigBank;

    // Constructor to set the initial owner
    constructor() {
        owner = msg.sender;
    }

    // Modifier to restrict function access to owner only
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    // Function to set the BigBank contract address
    function setBigBankAddress(address _bigBankAddress) public onlyOwner {
        bigBank = IBigBank(_bigBankAddress);
    }

    // Function to withdraw from BigBank
    function withdraw(uint256 amount) public onlyOwner {
        require(address(bigBank) != address(0), "BigBank address not set");
        bigBank.withdraw(amount);
    }

    // Fallback function to receive ETH
    receive() external payable {}
}
