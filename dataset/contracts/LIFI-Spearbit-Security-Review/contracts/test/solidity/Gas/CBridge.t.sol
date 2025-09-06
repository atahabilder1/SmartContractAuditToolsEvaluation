pragma solidity 0.8.13;

import { DSTest } from "ds-test/test.sol";
import { console } from "../utils/Console.sol";
import { DiamondTest, LiFiDiamond } from "../utils/DiamondTest.sol";
import { Vm } from "forge-std/Vm.sol";
import { CBridgeFacet } from "lifi/Facets/CBridgeFacet.sol";
import { ICBridge } from "lifi/Interfaces/ICBridge.sol";
import { ILiFi } from "lifi/Interfaces/ILiFi.sol";
import { ERC20 } from "solmate/tokens/ERC20.sol";

contract CBridgeGasTest is DSTest, DiamondTest {
    address internal constant CBRIDGE_ROUTER = 0x5427FEFA711Eff984124bFBB1AB6fbf5E3DA1820;
    address internal constant USDC_ADDRESS = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address internal constant WHALE = 0x72A53cDBBcc1b9efa39c834A540550e23463AAcB;

    ILiFi.LiFiData internal lifiData = ILiFi.LiFiData("", "", address(0), address(0), address(0), address(0), 0, 0);

    Vm internal immutable vm = Vm(HEVM_ADDRESS);
    ICBridge internal immutable cBridgeRouter = ICBridge(CBRIDGE_ROUTER);
    LiFiDiamond internal diamond;
    CBridgeFacet internal cBridge;
    ERC20 internal usdc;
    ERC20 internal dai;

    function setUp() public {
        diamond = createDiamond();
        cBridge = new CBridgeFacet();
        usdc = ERC20(USDC_ADDRESS);

        bytes4[] memory functionSelectors = new bytes4[](1);
        functionSelectors[0] = cBridge.startBridgeTokensViaCBridge.selector;

        addFacet(diamond, address(cBridge), functionSelectors);

        cBridge = CBridgeFacet(address(diamond));
    }

    function testDirectBridge() public {
        uint256 amount = 100 * 10**usdc.decimals();

        vm.startPrank(WHALE);
        usdc.approve(address(cBridgeRouter), amount);
        cBridgeRouter.send(WHALE, USDC_ADDRESS, amount, 137, 1, 5000);
        vm.stopPrank();
    }

    function testLifiBridge() public {
        uint256 amount = 100 * 10**usdc.decimals();

        vm.startPrank(WHALE);
        usdc.approve(address(cBridge), amount);
        CBridgeFacet.CBridgeData memory data = CBridgeFacet.CBridgeData(
            CBRIDGE_ROUTER,
            5000,
            137,
            1,
            amount,
            WHALE,
            USDC_ADDRESS
        );
        cBridge.startBridgeTokensViaCBridge(lifiData, data);
        vm.stopPrank();
    }
}
