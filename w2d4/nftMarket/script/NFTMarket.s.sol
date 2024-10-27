// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/MyNFT.sol";
import "../src/NFTMarket.sol";
import {TimTom} from "../src/Token.sol"; 

contract DeployNFTMarket is Script {
    function run() external {
        // Deploy the ERC20 token for transactions
        address initialOwner = vm.envAddress("INITIAL_OWNER");
        TimTom token = new TimTom(initialOwner);
        
        // Deploy the NFT contract
        MyNFT nft = new MyNFT();

        // Start deploying the NFTMarket contract
        vm.startBroadcast();
        NFTMarket nftMarket = new NFTMarket(token, nft);
        vm.stopBroadcast();

        // Output the contract addresses
        console.log("Token deployed to:", address(token));
        console.log("NFT deployed to:", address(nft));
        console.log("NFTMarket deployed to:", address(nftMarket));
    }
}
