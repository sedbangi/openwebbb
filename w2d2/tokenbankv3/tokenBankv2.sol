// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {TokenBank} from "./tokenBank.sol";
import "./ITokenReceiver.sol";
import "./IERC20.sol";

contract TokenBankV2 is TokenBank {
    IERC20 public token;

    constructor(IERC20 _token) {
        token = _token;
    }
    function tokensReceived(address from, uint256 amount) external returns (bool) {
        require(msg.sender == address(token), "Only the token contract can call this function");
        balances[address(token)][from] += amount;
        return true;
    }
}