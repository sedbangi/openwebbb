// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/TokenBank.sol"; 
import {TimTom} from "../src/Token.sol"; 

contract DeployTokenBank is Script {
    function run() external {
        address initialOwner1 = vm.envAddress("INITIAL_OWNER1");
        address initialOwner2 = vm.envAddress("INITIAL_OWNER2");
        // Deploy two ERC20 tokens as examples
        ERC20 token1 = new TimTom(initialOwner1);
        ERC20 token2 = new TimTom(initialOwner2);

        // Start deploying the TokenBank contract
        vm.startBroadcast();
        TokenBank tokenBank = new TokenBank(token1, token2);
        vm.stopBroadcast();

        // Output the contract address
        console.log("TokenBank deployed to:", address(tokenBank));
    }
}
