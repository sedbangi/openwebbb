// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "./IPermit2.sol";

// https://decert.me/challenge/1fa3ecbc-a3cd-43ae-908e-661aac97bdc0
// chenyuqing

// permit2 from uniswapV2

contract TokenBank {

    // user -> token -> bal
    mapping(address=> mapping(address => uint256)) tokenBalByUser;

    event Deposit(address indexed user, IERC20 indexed token, uint256 amount);
    event Withdraw(address indexed user, IERC20 indexed token, uint256 amount);

    // IPermit2 
    IPermit2 public immutable PERMIT2;

    constructor(IPermit2 _permit) {
        PERMIT2 = _permit;
    }

    // deposti with permit2
    function depositWithPermit2(
        IERC20 token,
        uint256 amount,
        uint256 nonce,
        uint256 deadline,
        bytes calldata signature
        ) external 
    {
        // Transfer tokens from the caller to ourselves.
        PERMIT2.permitTransferFrom(
            // The permit message. Spender will be inferred as the caller (us).
            IPermit2.PermitTransferFrom({
                permitted: IPermit2.TokenPermissions({
                    token: token,
                    amount: amount
                }),
                nonce: nonce,
                deadline: deadline
            }),
            // The transfer recipient and amount.
            IPermit2.SignatureTransferDetails({
                to: address(this),
                requestedAmount: amount
            }),
            // The owner of the tokens, which must also be
            // the signer of the message, otherwise this call
            // will fail.
            msg.sender,
            // The packed signature that was the result of signing
            // the EIP712 hash of `permit`.
            signature
        );

        // Credit the caller.
        tokenBalByUser[msg.sender][token] += amount;
    }

    // deposit with permit 
    function permitDeposit(
        IERC20 token, 
        uint256 amount, 
        uint256 deadline, 
        uint8 v, 
        bytes32 r, 
        bytes32 s
        ) public 
    {
        ERC20Permit(address(token)).permit(
            msg.sender, 
            address(this), 
            amount, 
            deadline, 
            v,
            r,
            s);
        deposit(token, amount);
    }

    // deposit without permit
    function deposit(IERC20 token, uint256 amount) public {
        require(amount > 0, "Amount must be greater than 0");
        token.transferFrom(msg.sender, address(this), amount);

        balanceOf[msg.sender] += amount;
        emit Deposit(msg.sender, token, amount);
    }

    function withdraw(IERC20 token, uint256 amount) public {
        require(amount > 0, "amount must be greater than 0");
        require(balanceOf[msg.sender] >= amount, "Insufficient balances");

        balanceOf[msg.sender] -= amount;
        token.transfer(msg.sender, amount);
        emit Withdraw(msg.sender, token, amount);  
    }

}