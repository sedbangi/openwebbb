// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0; 
interface IERC20WithCallback {
    function transferWithCallback(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}