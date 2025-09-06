// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.0;

import {IPropertyChecker} from "./IPropertyChecker.sol";
import {Clone} from "clones-with-immutable-args/Clone.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerklePropertyChecker is IPropertyChecker, Clone {
    // Immutable params

    /**
     * @return Returns the lower bound of IDs allowed
     */
    function getMerkleRoot() public pure returns (bytes32) {
        return bytes32(_getArgUint256(0));
    }

    function hasProperties(uint256[] calldata ids, bytes calldata params) external pure returns (bool isAllowed) {
        isAllowed = true;
        bytes32 root = getMerkleRoot();
        (bytes[] memory proofList) = abi.decode(params, (bytes[]));
        for (uint256 i; i < ids.length; i++) {
            bytes32[] memory proof = abi.decode(proofList[i], (bytes32[]));
            if (!MerkleProof.verify(proof, root, keccak256(abi.encodePacked(ids[i])))) {
                return false;
            }
        }
    }
}
