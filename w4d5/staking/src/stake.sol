// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

// https://decert.me/challenge/3144854f-5dc4-49d7-bb5c-b438f2cd6ac5
// chenyuqing

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract StakePool is Ownable {
    using SafeERC20 for IERC20;

    IERC20 public immutable RNT;
    IERC20 public immutable esRNT;
    
    uint256 public constant REWARD_RATE = 1 ether; // 每天每1 RNT 产生1 esRNT
    uint256 public constant LOCK_PERIOD = 30 days; // 30天的锁定周期

    struct StakeInfo {
        uint256 staked;
        uint256 unclaimed;
        uint256 lastUpdateTime;
    }

    struct LockInfo {
        address user;
        uint256 amount;
        uint256 locktime;
    }

    mapping(address => StakeInfo) public stakeInfobyUser;
    LockInfo[] public locks;

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event Claimed(address indexed user, uint256 amount);
    event Redeemed(address indexed user, uint256 esRNTAmount, uint256 rntReceived, uint256 burned);

    constructor(IERC20 _RNT, IERC20 _esRNT) {
        RNT = _RNT;
        esRNT = _esRNT;
        owner = msg.sender;
    }

    function _updateReward(address user) internal {
        StakeInfo storage info = stakeInfobyUser[user];
        uint256 timeDelta = block.timestamp - info.lastUpdateTime;
        if (info.staked > 0) {
            info.unclaimed += (info.staked * REWARD_RATE * timeDelta) / 1 days;
        }
        info.lastUpdateTime = block.timestamp;
    }

    function stake(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        StakeInfo storage info = stakeInfobyUser[msg.sender];

        _updateReward(msg.sender);

        RNT.safeTransferFrom(msg.sender, address(this), amount);
        info.staked += amount;

        emit Staked(msg.sender, amount);
    }

    function unstake(uint256 amount) external {
        StakeInfo storage info = stakeInfobyUser[msg.sender];
        require(amount > 0 && amount <= info.staked, "Invalid unstake amount");

        _updateReward(msg.sender);

        info.staked -= amount;
        RNT.safeTransfer(msg.sender, amount);

        emit Unstaked(msg.sender, amount);
    }

    function claim() external {
        _updateReward(msg.sender);
        
        StakeInfo storage info = stakeInfobyUser[msg.sender];
        uint256 reward = info.unclaimed;
        require(reward > 0, "No rewards to claim");

        info.unclaimed = 0;
        esRNT.safeTransfer(msg.sender, reward);

        locks.push(LockInfo({
            user: msg.sender,
            amount: reward,
            locktime: block.timestamp + LOCK_PERIOD
        }));

        emit Claimed(msg.sender, reward);
    }

    function redeem(uint256 esRNTAmount) external {
        require(esRNTAmount > 0, "Amount must be greater than 0");

        uint256 unlocked;
        uint256 remaining = esRNTAmount;

        for (uint256 i = 0; i < locks.length; i++) {
            if (locks[i].user == msg.sender && locks[i].amount > 0) {
                uint256 elapsed = block.timestamp > locks[i].locktime ? LOCK_PERIOD : block.timestamp - locks[i].locktime + LOCK_PERIOD;
                uint256 unlockable = (locks[i].amount * elapsed) / LOCK_PERIOD;

                if (unlockable >= remaining) {
                    unlocked += remaining;
                    locks[i].amount -= remaining;
                    remaining = 0;
                    break;
                } else {
                    unlocked += unlockable;
                    remaining -= unlockable;
                    locks[i].amount -= unlockable;
                }
            }
        }
        
        require(unlocked > 0, "No unlocked esRNT");
        
        esRNT.safeTransferFrom(msg.sender, address(this), esRNTAmount);
        esRNT.burn(esRNTAmount - unlocked);
        RNT.safeTransfer(msg.sender, unlocked);

        emit Redeemed(msg.sender, esRNTAmount, unlocked, esRNTAmount - unlocked);
    }


}
