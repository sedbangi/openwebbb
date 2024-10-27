// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/MyNFT.sol";
import "../src/NFTMarket.sol";
import {TimTom} from "../src/Token.sol"; 

contract NFTMarketTest is Test {
    NFTMarket nftMarket;
    MyNFT nft;
    TimTom token;

    address user = address(0x1);
    address seller = address(0x2);


    function setUp() public {
        address initialOwner = vm.envAddress("INITIAL_OWNER");
        token = new TimTom(initialOwner);
        nft = new MyNFT();
        nftMarket = new NFTMarket(token, nft);

        // Mint some tokens to the seller
        token.mint(seller, 1000 * 10 ** token.decimals());

        // Mint an NFT to the seller
        vm.prank(seller);
        nft.mint(seller);
    }
    
    function testListNFT() public {
        uint256 tokenId = 0; // The first minted NFT

        // Seller lists the NFT
        vm.prank(seller);
        nftMarket.list(tokenId, 100);

        // Check the listing
        // NFTMarket.InfoList memory listing = nftMarket.listings[tokenId];
        // assertEq(listing.seller, seller);
        // assertEq(listing.price, 100);

        // (address sellerAddr, uint256 price) = (nftMarket.listings(tokenId).seller, nftMarket.listings(tokenId).price);
        (address sellerAddr, uint256 price) = nftMarket.listings(tokenId);
        assertEq(sellerAddr, seller);
        assertEq(price, 100);
    }

    function testBuyNFT() public {
        uint256 tokenId = 0; // The first minted NFT

        // Seller lists the NFT
        vm.prank(seller);
        nftMarket.list(tokenId, 100);

        // Buyer must approve the NFTMarket to spend tokens
        token.approve(address(nftMarket), 100);

        // Buyer buys the NFT
        vm.prank(user);
        nftMarket.buyNFT(tokenId);

        // Check that the NFT has been transferred
        assertEq(nft.ownerOf(tokenId), user);
    }

    function testBuyNFTWithPermit() public {
        uint256 tokenId = 0; // The first minted NFT
        uint256 deadline = block.timestamp + 1 hours;

        // Seller lists the NFT
        vm.prank(seller);
        nftMarket.list(tokenId, 100);

        // User must approve the market to spend tokens
        token.approve(address(nftMarket), 100);

        // Create a permit signature
        bytes32 hashMessage = keccak256(
            abi.encode(keccak256("Permit(address buyer,uint256 tokenId,uint256 deadline)"),
            user, 
            tokenId, 
            deadline));
        
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(user, hashMessage);

        // User buys the NFT using permit
        vm.prank(user);
        nftMarket.buyNFTwithPermit(tokenId, deadline, v, r, s);

        // Check that the NFT has been transferred
        assertEq(nft.ownerOf(tokenId), user);
    }
}
