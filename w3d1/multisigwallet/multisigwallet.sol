// SPDX-License-Identifier: MIT

// https://decert.me/challenge/f832d7a2-2806-4ad9-8560-a27ad8570c6f
// Author: chenyuqing

pragma solidity ^0.8.26;

contract MultiSigWallet {
    // definition of a transaction
    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
    }
    // define a transaction list
    Transaction[] public transactions;

    // define owner list
    address[] public owners;
    // owner records of who can sig 
    mapping(address => bool) public isOwner;
    // 2/3 threshold
    uint256 threshold;

    // mapping from transaction id => owner => bool
    mapping(uint256 => mapping(address => bool)) public approved;

    // events
    event Submit(uint256 transactionId);
    event Approve(address indexed addr, uint256 transactionId);
    event Execute(uint256 transactionId);

    // constructor
    constructor(address[] memory _owners, uint256 _threshold) {
        // check the threshold
        require(_owners.length > 0, "the number of owners must be greater than zero");
        require(_threshold > 0 && _threshold <= _owners.length, "invalid threshold");

        for(uint256 i; i < _owners.length; i++) {
            require(_owners[i] != address(0), "address owner = zero");
            require(!isOwner[_owners[i]], "owner is not unique");
            isOwner[_owners[i]] = true;
            owners.push(_owners[i]);
        }
        threshold = _threshold;
    }

    // function to receive ether
    receive() external payable {}

    modifier onlyOwner() {
        require(isOwner[msg.sender], "not owner");
        _;
    }

    modifier transactionExists(uint256 transactionId) {
        require(transactionId < transactions.length, "transaction doesn't exist");
        _;
    }

    modifier transactionNotExecute(uint256 transactionId) {
        require(!transactions[transactionId].executed, "transaction has been executed");
        _;
    }

    modifier transactionNotApproved(uint256 transactionId) {
        require(!approved[transactionId][msg.sender], "transaction has been approved");
        _;
    }

    /// submit a transaction -> approve the transaction -> reach the threshold -> execute the transaction

    // submit a transaction
    function submit(address to, uint256 value, bytes calldata data) 
        external 
        onlyOwner
    {
        transactions.push(
            Transaction({to: to, value: value, data: data, executed: false})    
        );
        emit Submit(transactions.length - 1);
    }

    // approve the transaction
    function approve(uint256 transactionId) 
        external 
        onlyOwner
        transactionExists(transactionId)
        transactionNotExecute(transactionId)
        transactionNotApproved(transactionId)
    {
        approved[transactionId][msg.sender] = true;
        emit Approve(msg.sender, transactionId);
    }

    // count the number of approvement to check if satisfy the threshold
    function _countApproval(uint256 transactionId) 
        private
        view 
        returns (uint256 count)
    {
        for(uint256 i; i < owners.length; i++) {
            if(approved[transactionId][owners[i]]) {
                count += 1;
            }
        }
    }

    // exectue the transaction 
    function execute(uint256 transactionId) 
        external
        onlyOwner
        transactionExists(transactionId)
        transactionNotExecute(transactionId)
    {
        require(_countApproval(transactionId) >= threshold, "approvals < threshold");
        
        Transaction storage transaction = transactions[transactionId];
                
        (bool ok, ) = transaction.to.call{value: transaction.value}(transaction.data);
        require(ok, "tx failed");
        transaction.executed = true;

        emit Execute(transactionId);
    }
}