// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import { MintParams } from "seadrop/lib/SeaDropStructs.sol";

import { SeaDrop } from "seadrop/SeaDrop.sol";

import { ERC721SeaDrop } from "seadrop/ERC721SeaDrop.sol";

import { SeaDropErrorsAndEvents } from "seadrop/lib/SeaDropErrorsAndEvents.sol";

contract TestHelper is Test, SeaDropErrorsAndEvents {
    SeaDrop seadrop = new SeaDrop();
    ERC721SeaDrop token;

    address creator = makeAddr("creator");
    /// @notice Internal constants for EIP-712: Typed structured
    ///         data hashing and signing
    bytes32 internal constant _SIGNED_MINT_TYPEHASH =
        keccak256(
            "SignedMint(address nftContract,address minter,address feeRecipient,MintParams mintParams)MintParams(uint256 mintPrice,uint256 maxTotalMintableByWallet,uint256 startTime,uint256 endTime,uint256 dropStageIndex,uint256 feeBps,bool restrictFeeRecipients)"
        );
    bytes32 internal constant _EIP_712_DOMAIN_TYPEHASH =
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
    bytes32 internal constant _NAME_HASH = keccak256("SeaDrop");
    bytes32 internal constant _VERSION_HASH = keccak256("1.0");
    uint256 internal immutable _CHAIN_ID = block.chainid;
    bytes32 internal immutable _DOMAIN_SEPARATOR = _deriveDomainSeparator();

    struct FuzzInputs {
        uint40 numMints;
        address minter;
        address feeRecipient;
        address[10] allowList;
    }

    modifier validateArgs(FuzzInputs memory args) {
        vm.assume(args.numMints > 0 && args.numMints <= 10);
        vm.assume(args.minter != address(0) && args.feeRecipient != address(0));
        vm.assume(
            args.feeRecipient.code.length == 0 && args.feeRecipient > address(9)
        );
        vm.assume(
            args.minter != args.feeRecipient &&
                args.minter != creator &&
                args.feeRecipient != creator
        );
        _;
    }

    function makeAddrAndKey(string memory name)
        internal
        returns (address addr, uint256 privateKey)
    {
        privateKey = uint256(keccak256(abi.encodePacked(name)));
        addr = vm.addr(privateKey);
        vm.label(addr, name);
    }

    function makeAddr(string memory name) internal returns (address addr) {
        (addr, ) = makeAddrAndKey(name);
    }

    function _getSignatureComponents(
        string memory name,
        address nftContract,
        address minter,
        address feeRecipient,
        MintParams memory mintParams
    )
        internal
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        bytes32 digest = _getDigest(
            nftContract,
            minter,
            feeRecipient,
            mintParams
        );
        (, uint256 pk) = makeAddrAndKey(name);
        (v, r, s) = vm.sign(pk, digest);
    }

    function _getDigest(
        address nftContract,
        address minter,
        address feeRecipient,
        MintParams memory mintParams
    ) internal view returns (bytes32 digest) {
        digest = keccak256(
            abi.encodePacked(
                bytes2(0x1901),
                _DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        _SIGNED_MINT_TYPEHASH,
                        nftContract,
                        minter,
                        feeRecipient,
                        mintParams
                    )
                )
            )
        );
    }

    function _encodeSignature2098(
        bytes32 r,
        bytes32 s,
        uint8 v
    ) internal pure returns (bytes memory) {
        uint256 yParity;
        if (v == 27) {
            yParity = 0;
        } else {
            yParity = 1;
        }
        uint256 yParityAndS = (yParity << 255) | uint256(s);
        return abi.encodePacked(r, yParityAndS);
    }

    function _deriveDomainSeparator() internal view returns (bytes32) {
        // prettier-ignore
        return keccak256(
            abi.encode(
                _EIP_712_DOMAIN_TYPEHASH,
                _NAME_HASH,
                _VERSION_HASH,
                block.chainid,
                address(seadrop)
            )
        );
    }
}
