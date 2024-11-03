// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// raise ETH and give out token
contract IDO {
    address public owner;
    IERC20 public token;

    // start time and end time settings 
    uint256 public immutable startTime;
    uint256 public immutable endTime;
    uint256 public constant DURATION = 10 days;
    // the total number of tokens to give out
    uint256 public constant TOKEN_NUM = 1000000;
    
    uint256 public totalETH;
    uint256 public LowtargetETH; // 100
    uint256 public HighTargetETH; // 200

    // presale price
    uint256 public price;
    // max eth for each address
    uint256 public maxETH; // 0.1 eth
    // min eth for each purchase
    uint256 public minETH; // 0.001
    

    mapping(address => uint256) public contributions;
    // bool public ended = false;

    event PreSale(address user, uint256 amount);
    event TokensClaimed(address user, uint256 amount);
    event Withdrawn(uint256 amount);
    event Refunded(address user, uint256 amount);

    constructor(address _token, uint256 _price, uint256 _maxETH, uint256 _minETH) {
        owner = msg.sender;
        token = IERC20(_token);

        startTime = block.timestamp();
        endTime = startTime + DURATION;
        
        price = _price;
        maxETH = _maxETH;
        minETH = _minETH;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    modifier onlyActive() {
        require(block.timestamp < endTime && totalETH < HighTargetETH, "Pre-sale is not active");
        _;
    }

    modifier onlyFailed() {
        require(block.timestamp > endTime && totalETH < LowtargetETH, "Pre-sale did not fail");
        _;
    }

    modifier onlySuccess() {
        require(block.timestamp < endTime && totalETH >= LowtargetETH, "Pre-sale was not successful");
        _;
    }

    function preSale() external onlyActive payable {
        require(msg.value > minETH, "Must send greater than", minETH, "ETH");
        require(contributions[msg.sender] + msg.value <= maxETH, "Exceeds maximum ETH limit");
        contributions[msg.sender] += msg.value;
        totalETH += msg.value;

        emit PreSale(msg.sender, msg.value);
    }

    function _estAmount(uint256 ethAmount) internal view returns (uint256) {
        // Calculate amount of tokens based on the ETH sent
        return TOKEN_NUM * (ethAmount / totalETH); // Assuming 1 token = 0.0001 ETH
    }
    // user can claim tokens base on their eth when the ido successes
    function claim() external onlySuccess {
        uint256 amount = _estAmount(contributions[msg.sender]);
        require(amount > 0, "No tokens to claim");
        contributions[msg.sender] = 0;

        // Transfer tokens to the user
        token.transfer(msg.sender, amount);
        emit TokensClaimed(msg.sender, amount);
    }

    function withdraw() external onlySuccess onlyOwner {
        require(address(this).balance > 0, "No ETH to withdraw");
        payable(owner).transfer(address(this).balance);
        emit Withdrawn(address(this).balance);
    }

    function refund() external onlyFailed {
        uint256 amount = contributions[msg.sender];
        require(amount > 0, "No contributions to refund");
        contributions[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
        emit Refunded(msg.sender, amount);
    }
}
