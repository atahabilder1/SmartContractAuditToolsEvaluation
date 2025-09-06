// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "./setup/InvariantTargetContract.sol";

contract InvariantWarper is InvariantTargetContract {
    constructor(address hyper_, address asset_, address quote_) InvariantTargetContract(hyper_, asset_, quote_) {}

    function warper(uint amount) external {
        ctx.customWarp(block.timestamp + bound(amount, 1, 365 days));
    }

    function warpAfterMaturity(uint amount) external {
        amount = bound(amount, 1 days, 700 days);
        uint tau = HyperTau(address(__hyper__)).computeCurrentTau(__poolId__);
        ctx.customWarp(block.timestamp + tau + amount);
    }
}

interface HyperTau {
    function computeCurrentTau(uint64 poolId) external view returns (uint);
}
