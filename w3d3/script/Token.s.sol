// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {TimTom} from "../src/Token.sol"; 
contract DeployTimTom is Script {
    function run() external {
        address initialOwner = vm.envAddress("INITIAL_OWNER");

        vm.startBroadcast();
        TimTom timTom = new TimTom(initialOwner);
        vm.stopBroadcast();

        console.log("TimTom deployed to:", address(timTom));
    }
}
