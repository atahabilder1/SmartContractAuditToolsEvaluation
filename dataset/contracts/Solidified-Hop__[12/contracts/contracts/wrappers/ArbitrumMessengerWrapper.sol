// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "../interfaces/arbitrum/messengers/IGlobalInbox.sol";
import "./MessengerWrapper.sol";

/**
 * @dev A MessengerWrapper for Arbitrum - https://developer.offchainlabs.com/
 * @notice Deployed on layer-1
 */

contract ArbitrumMessengerWrapper is MessengerWrapper {

    IGlobalInbox public l1MessengerAddress;
    address public arbChain;
    byte public defaultSubMessageType;
    uint256 public defaultGasPrice;
    uint256 public defaultCallValue;

    constructor(
        address _l1BridgeAddress,
        address _l2BridgeAddress,
        uint256 _defaultGasLimit,
        IGlobalInbox _l1MessengerAddress,
        address _arbChain,
        byte _defaultSubMessageType,
        uint256 _defaultGasPrice,
        uint256 _defaultCallValue
    )
        public
    {
        l1BridgeAddress = _l1BridgeAddress;
        l2BridgeAddress = _l2BridgeAddress;
        defaultGasLimit = _defaultGasLimit;
        l1MessengerAddress = _l1MessengerAddress;
        arbChain = _arbChain;
        defaultSubMessageType = _defaultSubMessageType;
        defaultGasPrice = _defaultGasPrice;
        defaultCallValue = _defaultCallValue;
    }

    /** 
     * @dev Sends a message to the l2BridgeAddress from layer-1
     * @param _calldata The data that l2BridgeAddress will be called with
     */
    function sendCrossDomainMessage(bytes memory _calldata) public override onlyL1Bridge {
        bytes memory subMessageWithoutData = abi.encode(
            defaultGasLimit,
            defaultGasPrice,
            uint256(l2BridgeAddress),
            defaultCallValue
        );
        bytes memory subMessage = abi.encodePacked(
            subMessageWithoutData,
            _calldata
        );
        bytes memory prefixedSubMessage = abi.encodePacked(
            defaultSubMessageType,
            subMessage
        );
        l1MessengerAddress.sendL2Message(
            arbChain,
            prefixedSubMessage
        );
    }

    function verifySender(address l1BridgeCaller, bytes memory _data) public override {
        // ToDo: Verify sender with Arbitrum L1 messenger
        // Verify that sender is l2BridgeAddress
    }
}
