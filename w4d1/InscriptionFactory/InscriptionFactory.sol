// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// https://decert.me/challenge/ac607bb0-53b5-421f-a9df-f3db4a1495f2
// chenyuqing

// proxy and upgradable
// two part, one is data, the other is logic
// Usually, the factory contract deals with the logical part

import "./InscriptionToken.sol";

contract InscriptionFactory {
    struct TokenInfo {
        address tokenAddress;
        uint256 perMint;
    }

    mapping(address => TokenInfo) public tokens;

    // deploy a new InscriptionToken
    function deployInscription(
        string memory symbol,
        uint256 totalSupply,
        uint256 perMint
    ) external returns (address) {
        InscriptionToken token = new InscriptionToken(symbol, symbol, totalSupply, perMint, msg.sender);
        
        tokens[address(token)] = TokenInfo({
            tokenAddress: address(token),
            perMint: perMint
        });
        
        return address(token);
    }

    // call to mint a specified Token
    function mintInscription(address tokenAddr) external {
        require(tokens[tokenAddr].tokenAddress != address(0), "Token not found");
        
        InscriptionToken(tokenAddr).mint(msg.sender);
    }
}
