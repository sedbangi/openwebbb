// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";

contract NFTMarket {
    address public owner;
    IERC721 public mynft;
    IERC20 public token;

    // info of nft 
    struct InfoList {
        address seller;
        uint256 price;
    }
    // the info of tokenid which lists on market
    mapping(uint256 => InfoList) public listings;

    constructor(IERC20 _token, IERC721 _nft) {
        owner = msg.sender;
        token = _token;
        mynft = _nft;
    }

    // list on market
    function list(uint256 tokenId, uint256 price) external {
        // only the owner of nft can do the listing
        require(mynft.ownerOf(tokenId) == msg.sender, "only the owner can do the listing");
        require(price > 0, "price must be greater than zero");

        listings[tokenId] = InfoList({
            seller: msg.sender,
            price: price
        });
    }

    function buyNFT(uint256 tokenId) public {
        InfoList memory infonft = listings[tokenId];
        require(infonft.price > 0, "nft is not for sale");

        require(token.balanceOf(msg.sender) >= infonft.price, "not enough token balance");
        token.transferFrom(msg.sender, infonft.seller, infonft.price);

        mynft.safeTransferFrom(infonft.seller, msg.sender, tokenId);

        delete listings[tokenId];
    }


}