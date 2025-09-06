pragma solidity 0.7.6;

// SPDX-License-Identifier: GPL-3.0-only

import "../../interface/RocketStorageInterface.sol";
import "../../interface/minipool/RocketMinipoolInterface.sol";
import "../../interface/network/RocketNetworkFeesInterface.sol";
import "../../types/MinipoolDeposit.sol";
import "../../types/MinipoolStatus.sol";

// An individual minipool in the Rocket Pool network

contract RocketMinipool is RocketMinipoolInterface {

    // Main Rocket Pool storage contract
    RocketStorageInterface private rocketStorage = RocketStorageInterface(0);

    // Status
    MinipoolStatus private status;
    uint256 private statusBlock;
    uint256 private statusTime;

    // Deposit type
    MinipoolDeposit private depositType;

    // Node details
    address private nodeAddress;
    uint256 private nodeFee;
    uint256 private nodeDepositBalance;
    uint256 private nodeRefundBalance;
    bool private nodeDepositAssigned;
    bool private nodeWithdrawn;

    // User deposit details
    uint256 private userDepositBalance;
    bool private userDepositAssigned;
    uint256 private userDepositAssignedTime;

    // Staking details
    uint256 private stakingStartBalance;
    uint256 private stakingEndBalance;
    bool private validatorBalanceWithdrawn;

    // Status getters
    function getStatus() override public view returns (MinipoolStatus) { return status; }
    function getStatusBlock() override public view returns (uint256) { return statusBlock; }
    function getStatusTime() override public view returns (uint256) { return statusTime; }

    // Deposit type getter
    function getDepositType() override public view returns (MinipoolDeposit) { return depositType; }

    // Node detail getters
    function getNodeAddress() override public view returns (address) { return nodeAddress; }
    function getNodeFee() override public view returns (uint256) { return nodeFee; }
    function getNodeDepositBalance() override public view returns (uint256) { return nodeDepositBalance; }
    function getNodeRefundBalance() override public view returns (uint256) { return nodeRefundBalance; }
    function getNodeDepositAssigned() override public view returns (bool) { return nodeDepositAssigned; }
    function getNodeWithdrawn() override public view returns (bool) { return nodeWithdrawn; }

    // User deposit detail getters
    function getUserDepositBalance() override public view returns (uint256) { return userDepositBalance; }
    function getUserDepositAssigned() override public view returns (bool) { return userDepositAssigned; }
    function getUserDepositAssignedTime() override public view returns (uint256) { return userDepositAssignedTime; }

    // Staking detail getters
    function getStakingStartBalance() override public view returns (uint256) { return stakingStartBalance; }
    function getStakingEndBalance() override public view returns (uint256) { return stakingEndBalance; }
    function getValidatorBalanceWithdrawn() override public view returns (bool) { return validatorBalanceWithdrawn; }

    // Construct
    constructor(address _rocketStorageAddress, address _nodeAddress, MinipoolDeposit _depositType) {
        // Check parameters
        require(_rocketStorageAddress != address(0x0), "Invalid storage address");
        require(_nodeAddress != address(0x0), "Invalid node address");
        require(_depositType != MinipoolDeposit.None, "Invalid deposit type");
        // Initialise RocketStorage
        rocketStorage = RocketStorageInterface(_rocketStorageAddress);
        // Load contracts
        RocketNetworkFeesInterface rocketNetworkFees = RocketNetworkFeesInterface(getContractAddress("rocketNetworkFees"));
        // Set initial status
        status = MinipoolStatus.Initialized;
        statusBlock = block.number;
        statusTime = block.timestamp;
        // Set details
        depositType = _depositType;
        nodeAddress = _nodeAddress;
        nodeFee = rocketNetworkFees.getNodeFee();
    }

    // Get the withdrawal credentials for the minipool contract
    function getWithdrawalCredentials() override external view returns (bytes memory) {
        // Parameters
        uint256 credentialsLength = 32;
        uint256 addressLength = 20;
        uint256 addressOffset = credentialsLength - addressLength;
        byte withdrawalPrefix = 0x01;
        // Calculate & return
        bytes memory ret = new bytes(credentialsLength);
        bytes20 addr = bytes20(address(this));
        ret[0] = withdrawalPrefix;
        for (uint256 i = 0; i < addressLength; i++) {
            ret[i + addressOffset] = addr[i];
        }
        return ret;
    }

    // Receive the minipool's withdrawn eth2 validator balance
    // Only accepts calls from the eth1 system withdrawal contract
    receive() external payable {
        (bool success, bytes memory data) = getContractAddress("rocketMinipoolDelegate").delegatecall(abi.encodeWithSignature("receiveValidatorBalance()"));
        if (!success) { revert(getRevertMessage(data)); }
    }

    // Assign the node deposit to the minipool
    // Only accepts calls from the RocketNodeDeposit contract
    function nodeDeposit() override external payable {
        (bool success, bytes memory data) = getContractAddress("rocketMinipoolDelegate").delegatecall(abi.encodeWithSignature("nodeDeposit()"));
        if (!success) { revert(getRevertMessage(data)); }
    }

    // Assign user deposited ETH to the minipool and mark it as prelaunch
    // Only accepts calls from the RocketDepositPool contract
    function userDeposit() override external payable {
        (bool success, bytes memory data) = getContractAddress("rocketMinipoolDelegate").delegatecall(abi.encodeWithSignature("userDeposit()"));
        if (!success) { revert(getRevertMessage(data)); }
    }

    // Refund node ETH refinanced from user deposited ETH
    function refund() override external {
        (bool success, bytes memory data) = getContractAddress("rocketMinipoolDelegate").delegatecall(abi.encodeWithSignature("refund()"));
        if (!success) { revert(getRevertMessage(data)); }
    }

    // Progress the minipool to staking, sending its ETH deposit to the VRC
    // Only accepts calls from the minipool owner (node)
    function stake(bytes calldata _validatorPubkey, bytes calldata _validatorSignature, bytes32 _depositDataRoot) override external {
        (bool success, bytes memory data) = getContractAddress("rocketMinipoolDelegate").delegatecall(abi.encodeWithSignature("stake(bytes,bytes,bytes32)", _validatorPubkey, _validatorSignature, _depositDataRoot));
        if (!success) { revert(getRevertMessage(data)); }
    }

    // Mark the minipool as withdrawable and record its final balance
    // Only accepts calls from the RocketMinipoolStatus contract
    function setWithdrawable(uint256 _stakingStartBalance, uint256 _stakingEndBalance) override external {
        (bool success, bytes memory data) = getContractAddress("rocketMinipoolDelegate").delegatecall(abi.encodeWithSignature("setWithdrawable(uint256,uint256)", _stakingStartBalance, _stakingEndBalance));
        if (!success) { revert(getRevertMessage(data)); }
    }

    // Withdraw node balances & rewards from the minipool and close it
    // Only accepts calls from the minipool owner (node)
    function withdraw() override external {
        (bool success, bytes memory data) = getContractAddress("rocketMinipoolDelegate").delegatecall(abi.encodeWithSignature("withdraw()"));
        if (!success) { revert(getRevertMessage(data)); }
    }

    // Dissolve the minipool, returning user deposited ETH to the deposit pool
    // Only accepts calls from the minipool owner (node), or from any address if timed out
    function dissolve() override external {
        (bool success, bytes memory data) = getContractAddress("rocketMinipoolDelegate").delegatecall(abi.encodeWithSignature("dissolve()"));
        if (!success) { revert(getRevertMessage(data)); }
    }

    // Withdraw node balances from the minipool and close it
    // Only accepts calls from the minipool owner (node)
    function close() override external {
        (bool success, bytes memory data) = getContractAddress("rocketMinipoolDelegate").delegatecall(abi.encodeWithSignature("close()"));
        if (!success) { revert(getRevertMessage(data)); }
    }

    // Get the address of a Rocket Pool network contract
    function getContractAddress(string memory _contractName) private view returns (address) {
        return rocketStorage.getAddress(keccak256(abi.encodePacked("contract.address", _contractName)));
    }

    // Get a revert message from delegatecall return data
    function getRevertMessage(bytes memory _returnData) private pure returns (string memory) {
        if (_returnData.length < 68) { return "Transaction reverted silently"; }
        assembly {
            _returnData := add(_returnData, 0x04)
        }
        return abi.decode(_returnData, (string));
    }

}
