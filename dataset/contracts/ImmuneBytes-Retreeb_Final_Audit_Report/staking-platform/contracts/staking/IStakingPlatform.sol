// SPDX-License-Identifier: MIT
pragma solidity =0.8.9;

/// @author RetreebInc
/// @title Interface Staking Platform with fixed APY and lockup
interface IStakingPlatform {
    /**
     * @notice function that start the staking
     * @dev set `startPeriod` to the current current `block.timestamp`
     * set `lockupPeriod` which is `block.timestamp` + `lockupDuration`
     * and `endPeriod` which is `startPeriod` + `stakingDuration`
     */
    function startStaking() external;

    /**
     * @notice function that allows a user to deposit tokens
     * @dev user must first approve the amount to deposit before calling this function,
     * cannot exceed the `maxAmountStaked`
     * @param amount, the amount to be deposited
     * @dev `endPeriod` to equal 0 (Staking didn't started yet),
     * or `endPeriod` more than current `block.timestamp` (staking not finished yet)
     * @dev totalStaked + amount must be less than `stakingMax`
     * @dev that the amount deposit should be at least 1E18 (1token)
     */
    function deposit(uint amount) external;

    /**
     * @notice function that allows a user to withdraw its initial deposit
     * @dev must be called only when `block.timestamp` >= `endPeriod`
     * @dev `block.timestamp` higher than `lockupPeriod` (lockupPeriod finished)
     * withdraw reset all states variable for the `msg.sender` to 0, and claim rewards
     * if rewards to claim
     */
    function withdraw() external;

    /**
     * @notice function that allows a user to withdraw its initial deposit
     * @dev must be called only when `block.timestamp` >= `endPeriod`
     * @dev `block.timestamp` higher than `lockupPeriod` (lockupPeriod finished)
     * @param amount, amount to withdraw
     * withdraw reset all states variable for the `msg.sender` to 0, and claim rewards
     * if rewards to claim
     */
    function withdrawAmount(uint amount) external;

    /**
     * @notice function that returns the amount of total Staked tokens
     * for a specific user
     * @param stakeHolder, address of the user to check
     * @return uint amount of the total deposited Tokens by the caller
     */
    function amountStaked(address stakeHolder) external view returns (uint);

    /**
     * @notice function that returns the amount of total Staked tokens
     * on the smart contract
     * @return uint amount of the total deposited Tokens
     */
    function totalDeposited() external view returns (uint);

    /**
     * @notice function that returns the amount of pending rewards
     * that can be claimed by the user
     * @param stakeHolder, address of the user to be checked
     * @return uint amount of claimable rewards
     */
    function rewardOf(address stakeHolder) external view returns (uint);

    /**
     * @notice function that claims pending rewards
     * @dev transfer the pending rewards to the `msg.sender`
     */
    function claimRewards() external;

    /**
     * @dev Emitted when `amount` tokens are deposited into
     * staking platform
     */
    event Deposit(address indexed owner, uint amount);

    /**
     * @dev Emitted when user withdraw deposited `amount`
     */
    event Withdraw(address indexed owner, uint amount);

    /**
     * @dev Emitted when `stakeHolder` claim rewards
     */
    event Claim(address indexed stakeHolder, uint amount);

    /**
     * @dev Emitted when staking has started
     */
    event StartStaking(uint startPeriod, uint endingPeriod);
}
