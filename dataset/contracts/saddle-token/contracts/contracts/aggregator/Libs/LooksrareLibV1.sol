// SPDX-License-Identifier: MIT
pragma solidity >=0.8.16;

error InvalidChain();

library LooksrareLibV1 {
    function _tradeHelper(
        uint256 value,
        bytes memory tradeData,
        address asset,
        uint256 tokenId,
        bool revertTxFail
    ) external returns (bool) {
        address looksrareExchange;

        if (block.chainid == 1) {
            // mainnet
            looksrareExchange = 0x59728544B08AB483533076417FbBB2fD0B17CE3a;
        } else if (block.chainid == 5 || block.chainid == 31337) {
            looksrareExchange = 0xD112466471b5438C1ca2D218694200e49d81D047;
        } else if (block.chainid == 4) {
            looksrareExchange = 0x1AA777972073Ff66DCFDeD85749bDD555C0665dA;
        } else {
            revert InvalidChain();
        }

        (bool success, ) = address(looksrareExchange).call{ value: value }(tradeData);

        if (!success && revertTxFail) {
            // Copy revert reason from call
            assembly {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }
        }

        // return back nft
        (bool success2, ) = asset.call(abi.encodeWithSelector(0x23b872dd, address(this), msg.sender, tokenId));

        if (!success2 && revertTxFail) {
            // Copy revert reason from call
            assembly {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }
        }

        return success && success2;
    }
}
