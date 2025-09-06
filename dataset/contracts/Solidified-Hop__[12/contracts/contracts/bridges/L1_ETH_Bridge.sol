pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "./L1_Bridge.sol";

/**
 * @dev A L1_Bridge that uses an ETH as the canonical token
 */

contract L1_ETH_Bridge is L1_Bridge {
    constructor (address[] memory bonders) public L1_Bridge(bonders) {}

    /* ========== Override Functions ========== */

    function _transferFromBridge(address recipient, uint256 amount) internal override {
        (bool success, ) = recipient.call{value: amount}(new bytes(0));
        require(success, 'L1_ERC20_BRG: ETH transfer failed');
    }

    function _transferToBridge(address /*from*/, uint256 amount) internal override {
        require(msg.value == amount, "L1_ERC20_BRG: Value does not match amount");
    }
}
