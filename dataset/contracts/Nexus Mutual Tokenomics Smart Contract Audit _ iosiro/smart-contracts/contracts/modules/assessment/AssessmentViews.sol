// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.18;

import "../../abstract/MasterAwareV2.sol";
import "../../interfaces/IAssessment.sol";

contract AssessmentViews is MasterAwareV2 {

  enum Asset { ETH, DAI }

  constructor(address _master) {
    master = INXMMaster(_master);
  }

  function assessment() internal view returns (IAssessment) {
    return IAssessment(getInternalContractAddress(ID.AS));
  }

  function changeDependentContractAddress() external override {
    INXMMaster master = INXMMaster(master);
    internalContracts[uint(ID.AS)] = master.getLatestAddress("AS");
  }

}
