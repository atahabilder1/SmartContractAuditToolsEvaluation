/*
  _____ _ _      ____  _             
 |  ___| (_)_ __/ ___|| |_ __ _ _ __ 
 | |_  | | | '_ \___ \| __/ _` | '__|
 |  _| | | | |_) |__) | || (_| | |   
 |_|   |_|_| .__/____/ \__\__,_|_|   
           |_|                       
*/
//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.7;

import "./Interfaces.sol";
import "./Libraries.sol";
import "./BaseErc20.sol";
import "./Taxable.sol";
import "./Dividends.sol";
import "./AntiSniper.sol";

contract FlipStar is BaseErc20, Taxable, Dividends, AntiSniper {
    using SafeMath for uint256;

    mapping (address => bool) public excludedFromSelling;

    constructor () {
        //owner = msg.sender;
        owner = 0x29830c9534B169d9f53a0B101A4B14A8a3819C20;
        symbol = "FLIP";
        name = "FlipStar";
        decimals = 18;

        //address pancakeSwap = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3; // TESTNET
        address pancakeSwap = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // MAINNET
        IDEXRouter router = IDEXRouter(pancakeSwap);
        address WBNB = router.WETH();
        address pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        exchanges[pair] = true;
        exchanges[pancakeSwap] = true;
        minimumTimeBetweenSwaps = 5 minutes;
        minimumTokensBeforeSwap = 1000 * 10 ** decimals;
        distributorGas  = 500000;
        
        maxHoldPercentage = 150;
        maxSellPercentage = 10;
        enableSniperBlocking = true;
        enableBlockLogProtection = true;
        enableHighTaxCountdown = true;
        //configurePinkAntiBot(0xbb06F5C7689eA93d9DeACCf4aF8546C4Fe0Bf1E5); // TESTNET
        configurePinkAntiBot(0x8EFDb3b642eb2a20607ffe0A56CFefF6a95Df002); // MAINNET

        taxDistributor = new TaxDistributor(pancakeSwap, pair, WBNB);
        dividendDistributor = new DividendDistributor(address(taxDistributor));

        taxDistributor.createWalletTax("Development", 100, 100, 0x66A4E962Ad91F457190e720BE5d764fd41172E97);
        taxDistributor.createWalletTax("Marketing", 100, 100, 0xFee915C14EA243B31F84A08De6B9476fFc2835aC);
        taxDistributor.createWalletTax("Lotto", 100, 100, 0xf8485507d30A3387eA6dFbae129DAf6DF7Eb8244);
        taxDistributor.createDividendTax("Liquidity", 200, 300, address(dividendDistributor));
        taxDistributor.createLiquidityTax("Rewards", 500, 600);

        excludedFromTax[owner] = true;
        excludedFromTax[address(taxDistributor)] = true;
        excludedFromTax[address(dividendDistributor)] = true;

        excludedFromDividends[pair] = true;
        excludedFromDividends[address(this)] = true;
        excludedFromDividends[address(taxDistributor)] = true;
        excludedFromDividends[address(dividendDistributor)] = true;

        _allowed[address(taxDistributor)][pancakeSwap] = 2**256 - 1;
        _totalSupply = _totalSupply.add(100_000_000 * 10 ** decimals);
        _balances[owner] = _balances[owner].add(_totalSupply);
        
        emit Transfer(address(0), owner, _totalSupply);
    }


    // Overrides

    function launch() public override(AntiSniper, BaseErc20) onlyOwner {
        return super.launch();
    }

    function isAlwaysExempt(address who) override(Taxable, Dividends, BaseErc20) internal returns (bool) {
        return super.isAlwaysExempt(who);
    }

    function preTransfer(address from, address to, uint256 value) override(AntiSniper, BaseErc20) internal {
        require(excludedFromSelling[from] == false, "address is not allowed to sell");
        super.preTransfer(from, to, value);
    }
    
    function calculateTransferAmount(address from, address to, uint256 value) override(AntiSniper, Taxable, BaseErc20) internal returns (uint256) {
        return super.calculateTransferAmount(from, to, value);
    }
    
    function postTransfer(address from, address to) override(Taxable, Dividends, BaseErc20) internal {
        super.postTransfer(from, to);
    }


    // Admin methods

    function setExchange(address who, bool isExchange) public onlyOwner {
        exchanges[who] = isExchange;
        excludedFromDividends[who] = isExchange;
    }

    function setExcludedFromSelling(address who, bool isExcluded) public onlyOwner {
        require(who != address(this) && who != address(taxDistributor) && who != address(dividendDistributor) && exchanges[who] == false, "this address cannot be excluded");
        excludedFromSelling[who] = isExcluded;
    }
}
