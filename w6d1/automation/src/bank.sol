// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// https://decert.me/challenge/072fccb4-a976-4cf9-933c-c4ef14e0f6eb
// chenyuqing

import {AutomationCompatibleInterface} from "@chainlink/contracts/src/v0.8/automation/AutomationCompatible.sol";

contract Bank is AutomationCompatibleInterface {
    address public owner;
    mapping(address => uint256) public balanceOf;
    uint256 public thresh;

    constructor(uint256 _thresh) {
        owner = msg.sender;
        thresh = _thresh;
    }

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    receive() external payable {}

    function deposit() public payable {
        require(msg.value > 0, "deposit amount must be greater than 0");
        balanceOf[msg.sender] += msg.value;

        emit Deposit(msg.sender, msg.value);
    }

    function withdraw() public {
        require(msg.sender == owner, "only the owner can withdraw.");
        payable(owner).transfer(address(this).balance);

        emit Withdraw(msg.sender, address(this).balance);
    }

    function setThresh(uint256 newThresh) public {
        require(msg.sender == owner, "only the owner can set new thresh.");
        thresh = newThresh;
    }

    function checkUpkeep(bytes calldata ) 
        external 
        view 
        override 
        returns (bool upkeepNeeded, bytes memory){
            upkeepNeeded = (address(this).balance > thresh);
    }

    function performUpkeep(bytes calldata ) external override {
        if (address(this).balance > thresh) {
            uint256 halfbal = address(this).balance / 2;
            (bool suc, ) = payable(owner).call{value: halfbal}("");
            require(suc, "tx failed"); 
        }
    }

    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }
}