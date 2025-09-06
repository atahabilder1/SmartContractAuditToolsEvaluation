// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity 0.8.15;

import {IRootManager} from "../../interfaces/IRootManager.sol";

import {FxBaseChildTunnel} from "./tunnel/FxBaseChildTunnel.sol";

import {SpokeConnector} from "../SpokeConnector.sol";

// address constant MUMBAI_FX_CHILD = 0xCf73231F28B7331BBe3124B907840A94851f9f11;
// address constant GOERLI_CHECKPOINT_MANAGER = 0x2890bA17EfE978480615e330ecB65333b880928e;
// address constant GOERLI_FX_ROOT = 0x3d1d3E34f7fB6D26245E6640E1c50710eFFf15bA;

// address constant MAINNET_FX_CHILD = 0x8397259c983751DAf40400790063935a11afa28a;
// address constant MAINNET_CHECKPOINT_MANAGER = 0x86E4Dc95c7FBdBf52e33D563BbDB00823894C287;
// address constant MAINNET_FX_ROOT = 0xfe5e5D361b2ad62c541bAb87C45a0B9B018389a2;

contract PolygonSpokeConnector is SpokeConnector, FxBaseChildTunnel {
  // ============ Constructor ============
  constructor(
    uint32 _domain,
    uint32 _mirrorDomain,
    address _amb,
    address _rootManager,
    address _mirrorConnector,
    uint256 _mirrorGas,
    uint256 _processGas,
    uint256 _reserveGas,
    uint256 _delayBlocks,
    address _merkle,
    address _watcherManager
  )
    SpokeConnector(
      _domain,
      _mirrorDomain,
      _amb,
      _rootManager,
      _mirrorConnector,
      _mirrorGas,
      _processGas,
      _reserveGas,
      _delayBlocks,
      _merkle,
      _watcherManager
    )
    FxBaseChildTunnel(_amb)
  {}

  // ============ Private fns ============

  function _verifySender(address _expected) internal pure override returns (bool) {
    // NOTE: Always return false here because we cannot verify sender except in
    // _processMessageFromRoot, where it is exposed in plaintext
    return false;
  }

  function _sendMessage(bytes memory _data) internal override {
    _sendMessageToRoot(_data);
  }

  function _processMessageFromRoot(
    uint256, /* stateId */
    address sender,
    bytes memory data
  ) internal override validateSender(sender) {
    // make sure the sender is the mirror connector
    require(sender == mirrorConnector, "!sender");
    // get the data (should be the aggregate root)
    require(data.length == 32, "!length");
    // update the aggregate root on the domain
    receiveAggregateRoot(bytes32(data));

    emit MessageProcessed(data, msg.sender);
  }

  function _processMessage(bytes memory _data) internal override {}

  function _setMirrorConnector(address _mirrorConnector) internal override {
    super._setMirrorConnector(_mirrorConnector);

    setFxRootTunnel(_mirrorConnector);
  }
}
