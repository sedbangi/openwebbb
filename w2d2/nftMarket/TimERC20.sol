// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ITokenReceiver.sol";

contract TimERC20 {
    string public name; 
    string public symbol; 
    uint8 public decimals; 

    uint256 public totalSupply; 

    mapping (address => uint256) balances; 

    mapping (address => mapping (address => uint256)) allowances; 

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        // write your code here
        // set name,symbol,decimals,totalSupply
        name = "TimCoin";
        symbol = "TMT";
        decimals = 18;
        totalSupply = 100000000 ether;
        balances[msg.sender] = totalSupply;  
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        // write your code here
        require(_owner != address(0), "address = zero");
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        // write your code here
        require(_to != address(0), "address = zero");
        require(balances[msg.sender] >= _value, "ERC20: transfer amount exceeds balance");
        balances[_to] += _value;
        balances[msg.sender] -= _value;

        emit Transfer(msg.sender, _to, _value);  
        return true;   
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        // write your code here
        require(balances[_from] >= _value, "ERC20: transfer amount exceeds balance");
        require(allowances[_from][msg.sender] >= _value, "ERC20: transfer amount exceeds allowance");
        require(_to != address(0), "_to = zero address");

        allowances[_from][msg.sender] -= _value;
        balances[_from] -= _value;
        balances[_to] += _value;
        
        emit Transfer(_from, _to, _value); 
        return true; 
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        // write your code here
        require(balances[msg.sender] >= 0, "ERC20: transfer amount exceeds balance");
        require(_spender != address(0), "_spender = zero address");

        allowances[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value); 
        return true; 
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {   
        // write your code here 
        return allowances[_owner][_spender];    
    }

    // callback function, nft
    function transferWithCallback(address _to, uint256 _value, bytes calldata data) external returns (bool) {
        require(_value > 0, "value must be greater than zero");
        bool suc = transfer(_to, _value);
        require(suc, "transfer failed");

        if (isContract(_to)) {
            ITokenReceiver receiver = ITokenReceiver(_to);
            receiver.tokensReceived(msg.sender, _value, data);
        }
        return true;
    }

    function isContract(address addr) public view returns(bool) {
         return addr.code.length != 0;
    }
}