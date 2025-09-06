// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import { LibDiamond } from "../Libraries/LibDiamond.sol";

/// @title Periphery Registry Facet
/// @author LI.FI (https://li.fi)
/// @notice A simple registry to track LIFI periphery contracts
contract PeripheryRegistryFacet {
    /// Storage ///
    bytes32 internal constant NAMESPACE = hex"ddb1a97e204589b19d70796e7a3363c86670116d11313290b7a7eb064a8f3da1"; //keccak256("com.lifi.facets.periphery_registry");
    struct Storage {
        mapping(string => address) contracts;
    }

    /// @notice Registers a periphery contract address with a specified name
    /// @param _name the name to register the contract address under
    /// @param _contractAddress the address of the contract to register
    function registerPeripheryContract(string calldata _name, address _contractAddress) external {
        LibDiamond.enforceIsContractOwner();
        Storage storage s = getStorage();
        s.contracts[_name] = _contractAddress;
    }

    /// @notice Returns the registered contract address by its name
    /// @param _name the registered name of the contract
    function getPeripheryContract(string calldata _name) external view returns (address) {
        return getStorage().contracts[_name];
    }

    /// @dev fetch local storage
    function getStorage() private pure returns (Storage storage s) {
        bytes32 namespace = NAMESPACE;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            s.slot := namespace
        }
    }
}
