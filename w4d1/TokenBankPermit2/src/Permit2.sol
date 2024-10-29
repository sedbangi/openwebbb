// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./IPermit2.sol";

contract Permit2 is IPermit2 {
    mapping(address => uint256) public nonces;

    function permitTransferFrom(
        PermitTransferFrom calldata permit,
        SignatureTransferDetails calldata transferDetails,
        address owner,
        bytes calldata signature
    ) external override {
        // Check that the signature is valid
        bytes32 hash = _hashPermit(permit, owner);
        address signer = ECDSA.recover(hash, signature);
        require(signer == owner, "Invalid signature");

        // Check nonce and deadline
        require(permit.nonce == nonces[owner], "Invalid nonce");
        require(block.timestamp <= permit.deadline, "Permit expired");

        // Ensure requested amount is within allowed limits
        require(transferDetails.requestedAmount <= permit.permitted.amount, "Amount exceeds allowed");

        // Update nonce
        nonces[owner]++;

        // Transfer tokens
        permit.permitted.token.transferFrom(owner, transferDetails.to, transferDetails.requestedAmount);
    }

    function _hashPermit(PermitTransferFrom calldata permit, address owner) internal pure returns (bytes32) {
        return keccak256(abi.encode(
            // EIP712 typehash
            keccak256("PermitTransferFrom(TokenPermissions permitted,uint256 nonce,uint256 deadline)"),
            keccak256(abi.encode(
                keccak256("TokenPermissions(IERC20 token,uint256 amount)"),
                permit.permitted.token,
                permit.permitted.amount
            )),
            permit.nonce,
            permit.deadline
        ));
    }
}
