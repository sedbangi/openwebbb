// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;
import "./hw1.sol";

contract hw2 {
    address public privateKey;
    address public publicKey;
    bytes32 public hashValue;
    function getMessageHash(string memory message)
        public
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(message));
    }

        // Function to split signature into 3 parameters needed by ecrecover
    function _split(bytes memory sig)
        internal
        pure
        returns (bytes32 r, bytes32 s, uint8 v)
    {
        require(sig.length == 65, "invalid signature length");

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
        // implicitly return (r, s, v)
    }

    // Recovers the signer
    function recover(bytes32 ethSignedMessageHash, bytes memory sig)
        public
        pure
        returns (address)
    {
        (bytes32 r, bytes32 s, uint8 v) = _split(sig);
        return ecrecover(ethSignedMessageHash, v, r, s);
    }

    function getEthSignedMessageHash(bytes32 messageHash)
        public
        pure
        returns (bytes32)
    {
        /*
        This is the actual hash that is signed, keccak256 of
        \x19Ethereum Signed Message\n + len(msg) + msg
        */
        return keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash)
        );
    }

    bool public signed;

    function checkSignature(address signer, bytes memory sig) external {
        // string memory message = "secret";
        // Write code here
        bytes32 messageHash = getMessageHash(hashValue);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        
        require(recover(ethSignedMessageHash, sig) == signer, "invalide sig");
        signed = true;
    }
}