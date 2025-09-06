// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "../bridges/Bridge.sol";

contract Mock_Bridge is Bridge {
    constructor(address[] memory _bonders) public Bridge(_bonders) {}

    function _transferFromBridge(address _recipient, uint256 _amount) internal override {}
    function _transferToBridge(address _from, uint256 _amount) internal override {}
    function _requireIsGovernance() internal override {}

    function getChainId() public override view returns (uint256) {
        return 1;
    }
}
