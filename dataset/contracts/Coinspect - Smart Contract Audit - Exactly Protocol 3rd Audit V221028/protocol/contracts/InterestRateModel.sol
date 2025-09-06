// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.16;

import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";
import { FixedPointMathLib } from "solmate/src/utils/FixedPointMathLib.sol";

contract InterestRateModel {
  using FixedPointMathLib for uint256;
  using FixedPointMathLib for int256;

  uint256 public immutable fixedCurveA;
  int256 public immutable fixedCurveB;
  uint256 public immutable fixedMaxUtilization;

  uint256 public immutable floatingCurveA;
  int256 public immutable floatingCurveB;
  uint256 public immutable floatingMaxUtilization;

  constructor(
    uint256 fixedCurveA_,
    int256 fixedCurveB_,
    uint256 fixedMaxUtilization_,
    uint256 floatingCurveA_,
    int256 floatingCurveB_,
    uint256 floatingMaxUtilization_
  ) {
    fixedCurveA = fixedCurveA_;
    fixedCurveB = fixedCurveB_;
    fixedMaxUtilization = fixedMaxUtilization_;

    floatingCurveA = floatingCurveA_;
    floatingCurveB = floatingCurveB_;
    floatingMaxUtilization = floatingMaxUtilization_;

    // reverts if it's an invalid curve (such as one yielding a negative interest rate).
    fixedRate(0, 0);
    floatingRate(0, 0);
  }

  /// @notice Gets the rate to borrow a certain amount at a certain maturity with supply/demand values in the fixed rate
  /// pool and assets from the backup supplier.
  /// @param maturity maturity date for calculating days left to maturity.
  /// @param amount the current borrow's amount.
  /// @param borrowed ex-ante amount borrowed from this fixed rate pool.
  /// @param supplied deposits in the fixed rate pool.
  /// @param backupAssets backup supplier assets.
  /// @return rate of the fee that the borrower will have to pay (represented with 1e18 decimals).
  function fixedBorrowRate(
    uint256 maturity,
    uint256 amount,
    uint256 borrowed,
    uint256 supplied,
    uint256 backupAssets
  ) external view returns (uint256) {
    if (block.timestamp >= maturity) revert AlreadyMatured();

    uint256 potentialAssets = supplied + backupAssets;
    uint256 utilizationBefore = borrowed.divWadDown(potentialAssets);
    uint256 utilizationAfter = (borrowed + amount).divWadUp(potentialAssets);

    if (utilizationAfter > 1e18) revert UtilizationExceeded();

    return fixedRate(utilizationBefore, utilizationAfter).mulDivDown(maturity - block.timestamp, 365 days);
  }

  /// @notice Returns the interest rate integral from utilizationBefore to utilizationAfter.
  /// @dev Minimum and maximum checks to avoid negative rate.
  /// @param utilizationBefore ex-ante utilization rate, with 18 decimals precision.
  /// @param utilizationAfter ex-post utilization rate, with 18 decimals precision.
  /// @return the interest rate, with 18 decimals precision.
  function floatingBorrowRate(uint256 utilizationBefore, uint256 utilizationAfter) external view returns (uint256) {
    if (utilizationAfter > 1e18) revert UtilizationExceeded();

    return floatingRate(Math.min(utilizationBefore, utilizationAfter), Math.max(utilizationBefore, utilizationAfter));
  }

  /// @notice Returns the interest rate integral from `u0` to `u1`, using the analytical solution (ln).
  /// @dev Uses the fixed rate curve parameters.
  /// Handles special case where delta utilization tends to zero, using l'hôpital's rule.
  /// @param utilizationBefore ex-ante utilization rate, with 18 decimals precision.
  /// @param utilizationAfter ex-post utilization rate, with 18 decimals precision.
  /// @return the interest rate, with 18 decimals precision.
  function fixedRate(uint256 utilizationBefore, uint256 utilizationAfter) internal view returns (uint256) {
    int256 r = int256(
      utilizationAfter - utilizationBefore < 2.5e9
        ? fixedCurveA.divWadDown(fixedMaxUtilization - utilizationBefore)
        : fixedCurveA.mulDivDown(
          uint256(
            int256((fixedMaxUtilization - utilizationBefore).divWadDown(fixedMaxUtilization - utilizationAfter)).lnWad()
          ),
          utilizationAfter - utilizationBefore
        )
    ) + fixedCurveB;
    assert(r >= 0);
    return uint256(r);
  }

  /// @notice Returns the interest rate integral from `u0` to `u1`, using the analytical solution (ln).
  /// @dev Uses the floating rate curve parameters.
  /// Handles special case where delta utilization tends to zero, using l'hôpital's rule.
  /// @param utilizationBefore ex-ante utilization rate, with 18 decimals precision.
  /// @param utilizationAfter ex-post utilization rate, with 18 decimals precision.
  /// @return the interest rate, with 18 decimals precision.
  function floatingRate(uint256 utilizationBefore, uint256 utilizationAfter) internal view returns (uint256) {
    int256 r = int256(
      utilizationAfter - utilizationBefore < 2.5e9
        ? floatingCurveA.divWadDown(floatingMaxUtilization - utilizationBefore)
        : floatingCurveA.mulDivDown(
          uint256(
            int256((floatingMaxUtilization - utilizationBefore).divWadDown(floatingMaxUtilization - utilizationAfter))
              .lnWad()
          ),
          utilizationAfter - utilizationBefore
        )
    ) + floatingCurveB;
    assert(r >= 0);
    return uint256(r);
  }
}

error AlreadyMatured();
error UtilizationExceeded();
