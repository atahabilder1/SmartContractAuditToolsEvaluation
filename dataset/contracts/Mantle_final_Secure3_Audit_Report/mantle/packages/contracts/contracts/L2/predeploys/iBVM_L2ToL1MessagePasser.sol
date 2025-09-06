// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @title iBVM_L2ToL1MessagePasser
 */
interface iBVM_L2ToL1MessagePasser {
    /**********
     * Events *
     **********/

    event L2ToL1Message(uint256 _nonce, address _sender, bytes _data);

    /********************
     * Public Functions *
     ********************/

    function passMessageToL1(bytes calldata _message) external;
}
