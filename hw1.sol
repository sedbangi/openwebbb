// SPDX-License-Identifier: MIT

// https://decert.me/challenge/45779e03-7905-469e-822e-3ec3746d9ece

pragma solidity ^0.8.26;

contract computePow {
    string public nickname = "chenyuqing";
    uint256 public startAt;
    uint8 public size = 4;

    function compute() external returns(uint256) {
        
        while(true) {
            startAt = block.timestamp;
            uint256 nonce =  uint(keccak256(abi.encodePacked(block.timestamp, msg.sender)));
            bytes32 hashValue = this.getHash(nonce);
            bool suc = this.verifyZeros(hashValue);
            if(suc) {
                uint256 endAt = block.timestamp - startAt;
                return endAt;
            }
        }
    }

    function verifyZeros(bytes32 hashValue) external view returns (bool) {
        for(uint i = 0; i < size - 1; i++) {
            if (hashValue[i] != bytes32("0")) {
                return false;
            }
        }
        return true;
    }


    function getHash(uint256 nonce)
        external
        view
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(nickname, nonce));
    }
}