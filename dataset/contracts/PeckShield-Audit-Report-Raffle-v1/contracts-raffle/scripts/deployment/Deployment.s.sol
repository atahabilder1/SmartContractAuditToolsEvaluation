// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

// Scripting tool
import {Script} from "../../lib/forge-std/src/Script.sol";

// Core contracts
import {Raffle} from "../../contracts/Raffle.sol";

// Create2 factory interface
import {IImmutableCreate2Factory} from "../../contracts/interfaces/IImmutableCreate2Factory.sol";

import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

contract Deployment is Script {
    IImmutableCreate2Factory private constant IMMUTABLE_CREATE2_FACTORY =
        IImmutableCreate2Factory(0x0000000000FFe8B47B3e2130213B802212439497);

    error ChainIdInvalid(uint256 chainId);

    function run() external {
        uint256 chainId = block.chainid;
        uint256 deployerPrivateKey;

        address weth;
        bytes32 keyHash;
        uint64 subscriptionId;
        address vrfCoordinator;
        address owner;
        address protocolFeeRecipient;
        uint16 protocolFeeBp = 500;

        if (chainId == 1) {
            weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
            deployerPrivateKey = vm.envUint("MAINNET_KEY");
            keyHash = hex"8af398995b04c28e9951adb9721ef74c74f93e6a478f39e7e0777be13527e7ef";
            subscriptionId = 0;
            vrfCoordinator = 0x271682DEB8C4E0901D1a1550aD2e64D568E69909;
            owner = 0xBfb6669Ef4C4c71ae6E722526B1B8d7d9ff9a019;
            protocolFeeRecipient = 0x1838De7d4e4e42c8eB7b204A91e28E9fad14F536;
        } else if (chainId == 5) {
            weth = 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6;
            deployerPrivateKey = vm.envUint("TESTNET_KEY");
            keyHash = hex"79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15";
            subscriptionId = 11_238;
            vrfCoordinator = 0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D;
            owner = 0xF332533bF5d0aC462DC8511067A8122b4DcE2B57;
            protocolFeeRecipient = 0xdbBE0859791E44B52B98FcCA341DFb7577C0B077;
        } else if (chainId == 11155111) {
            weth = 0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9;
            deployerPrivateKey = vm.envUint("TESTNET_KEY");
            keyHash = hex"474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c";
            subscriptionId = 1_122;
            vrfCoordinator = 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625;
            owner = 0xF332533bF5d0aC462DC8511067A8122b4DcE2B57;
            protocolFeeRecipient = 0x50F0787Ed7C9091aBCa1D667fDBCcd85EA68C38C;
        } else {
            revert ChainIdInvalid(chainId);
        }

        vm.startBroadcast(deployerPrivateKey);

        if (chainId == 1) {
            IMMUTABLE_CREATE2_FACTORY.safeCreate2({
                salt: vm.envBytes32("RAFFLE_SALT"),
                initializationCode: abi.encodePacked(
                    type(Raffle).creationCode,
                    abi.encode(
                        weth,
                        keyHash,
                        subscriptionId,
                        vrfCoordinator,
                        owner,
                        protocolFeeRecipient,
                        protocolFeeBp
                    )
                )
            });
        } else {
            Raffle raffle = new Raffle(
                weth,
                keyHash,
                subscriptionId,
                vrfCoordinator,
                owner,
                protocolFeeRecipient,
                protocolFeeBp
            );
            VRFCoordinatorV2Interface(vrfCoordinator).addConsumer(subscriptionId, address(raffle));
        }

        vm.stopBroadcast();
    }
}
