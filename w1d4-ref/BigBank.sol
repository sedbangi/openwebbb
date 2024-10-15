// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {OriginalBank} from "./Bank.sol";

// BigBank contract inheriting from OriginalBank
contract BigBank is OriginalBank {
    // Define minimum deposit amount
    uint256 private constant MIN_DEPOSIT = 1_000_000_000_000_000; // 0.001 ETH in wei

    // Event for ownership transfer
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    // Modifier to check if deposit amount is greater than minimum required
    modifier minDepositRequired() {
        require(msg.value > MIN_DEPOSIT, "Deposit must be greater 0.001 ether");
        _;
    }

    // Override deposit function with minDepositRequired modifier
    function deposit() public payable override minDepositRequired {
        super.deposit();
    }

    // Function to transfer ownership to a new address
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner cannot be the zero address");
        require(newOwner != owner, "New owner cannot be the current owner");
        address oldOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
