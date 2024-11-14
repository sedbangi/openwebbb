// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@uniswap/v2-periphery/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-periphery/interfaces/IERC20.sol";
import "./IWETH.sol";
import "./IDex.sol";


contract myDex is IDex {
    IWETH public weth;
    IUniswapV2Router02 public router02;

    constructor(address _weth, address _router02) {
        weth = IWETH(_weth);
        router02 = IUniswapV2Router02(_router02);
    }
    // receive the ETH
    receive() external payable {}

    /**
     * @dev 卖出ETH，兑换成 buyToken
     *      msg.value 为出售的ETH数量
     * @param buyToken 兑换的目标代币地址
     * @param minBuyAmount 要求最低兑换到的 buyToken 数量
     */
    function sellETH(address buyToken, uint256 minBuyAmount) external payable {
        require(msg.value > 0, "the amount of eth is 0");

        weth.transfer(address(this), msg.value);
        weth.approve(address(router02), msg.value);

        address[] memory path = new address[](2);
        path[0] = address(weth);
        path[1] = buyToken;

        // swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        router02.swapExactETHForTokens(
            minBuyAmount, 
            path, 
            msg.sender, 
            block.timestamp    
        );
    }

    /**
     * @dev 买入ETH，用 sellToken 兑换
     * @param sellToken 出售的代币地址
     * @param sellAmount 出售的代币数量
     * @param minBuyAmount 要求最低兑换到的ETH数量
     */
    function buyETH(address sellToken, uint256 sellAmount, uint256 minBuyAmount) external{
        IERC20(sellToken).approve(address(router02), sellAmount);

        address [] memory path = new address[](2);
        path[0] = sellToken;            
        path[1] = address(weth);

        // swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        router02.swapExactTokensForETH(
            sellAmount,
            minBuyAmount,
            path,
            msg.sender,
            block.timestamp
        );
    }
}