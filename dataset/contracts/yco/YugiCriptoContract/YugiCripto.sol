// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;
 /*🃏👾🃏👾https://yugicripto.com/
                             ==(W{==========-      /===-                        
                              ||  (.--.)         /===-_---~~~~~~~~~------____  
                              | \_,|**|,__      |===-~___                _,-' `
                 -==\\        `\ ' `--'   ),    `//~\\   ~~~~`---.___.-~~      
             ______-==|        /`\_. .__/\ \    | |  \\           _-~`         
       __--~~~  ,-/-==\\      (   | .  |~~~~|   | |   `\        ,'             
    _-~       /'    |  \\     )__/==0==-\<>/   / /      \      /               
  .'        /       |   \\      /~\___/~~\/  /' /        \   /'                
 /  ____  /         |    \`\.__/-~~   \  |_/'  /          \/'                  
/-'~    ~~~~~---__  |     ~-/~         ( )   /'        _--~`                   
                  \_|      /        _) | ;  ),   __--~~                        
                    '~~--_/      _-~/- |/ \   '-~ \                            
                   {\__--_/}    / \\_>-|)<__\      \                           
                   /'   (_/  _-~  | |__>--<__|      |                          
                  |   _/) )-~     | |__>--<__|      |                          
                  / /~ ,_/       / /__>---<__/      |                          
                 o-o _//        /-~_>---<__-~      /                           
                 (^(~          /~_>---<__-      _-~                            
                ,/|           /__>--<__/     _-~                               
             ,//('(          |__>--<__|     /  -yugicripto     .----_          
            ( ( '))          |__>--<__|    |                 /' _---_~\        
         `-)) )) (           |__>--<__|    |               /'  /     ~\`\      
        ,/,'//( (             \__>--<__\    \            /'  //        ||      
      ,( ( ((, ))              ~-__>--<_~-_  ~--____---~' _/'/        /'       
    `~/  )` ) ,/|                 ~-_~>--<_/-__       __-~ _/                  
  ._-~//( )/ )) `                    ~~-'_/_/ /~~~~~~~__--~                    
   ;'( ')/ ,)(                              ~~~~~~~~~~                         
  ' ') '( (/                              ~~~~~~~~~~~~~~~~                                     
    '   '  `                            ~~~~~~~~~~~~~~~~~~~~~~~~
                        _____           |& & &||& & &|  ~~~~~~~~~~~~~~~~~~~~~~~~
                _____  |G  WW|          |____8||& & &| ~~~~~~~~~~~~~~~~~~~~~~~~
        _____  |U  ww| | o {)|                 |____6|
 _____ |Y  ww| | o {(| |o o%%| _____
|BSC &|| o {)| |o o%%| | |%%%||I _  | 🃏👾 🃏👾👾🃏👾🃏👾👾✅Tokeconomics 
|& & &||o o% | | |%%%| |_%%%R|| (*) | 🃏👾 🃏👾 ✅ All market transactions charge 8% for token maintenance 
|& & &|| | % | |_%%%I|        |(*'*)| 🃏👾 🃏👾 ✅ All market transactions charge 2% for pool repurchase
|& & &||__%%P|                |**|**| 🃏👾 🃏👾 ✅ Option repurchase with or without auto burn
|___0T|                       |____C| 🃏👾 🃏👾 ✅ Audited contract
                                      🃏👾 🃏👾 ✅ Anti dump control
                                      🃏👾 🃏👾 ✅ https://yugicripto.com/
  */
import "./ERC20.sol";
import "./Strings.sol";
import "./Authorized.sol";
import "./IPancake.sol";
import "./SwapHelper.sol";
contract YugiCriptoContract is Authorized, ERC20 {

  uint8     constant             decimal                   = 18;
  uint8     constant             decimalBUSD               = 18;  
  string    constant            _name                     = "YugiCripto";
  string    constant            _symbol                   = "$YCO";
  uint256   constant            _maxSupply                = 100_000_000 * (10 ** decimal);
  uint256   public              _maxTxAmount              = 10_000 * (10 ** decimal);
  
  uint256   public   immutable  feeAdministrationWallet   = 800; // 8% ADM
  uint256   public   immutable  feePool                   = 200; // 2% POOL
  uint256   public              totalBurned;

  // White list mapping to special wallet permissions
  mapping (address => bool) public exemptFee;
  mapping (address => bool) public exemptFeeReceiver;
  mapping (address => bool) public exemptStaker;
  mapping (address => bool) public exemptTxLimit;
  
  address  []   public    liquidityPool;
  address       public    administrationWallet;
  address       constant  DEAD = 0x000000000000000000000000000000000000dEaD;
  address       constant  ZERO = 0x0000000000000000000000000000000000000000;

  address       constant  BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
  address       constant  WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
  address       WBNB_BUSD_PAIR = 0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16;
  
  address       YUGICRIPTO_POOL;

  SwapHelper private swapHelper;
  bool private _noReentrancy = false;

  function getOwner() external view returns (address) { return owner(); }
  function getFeeTotal() public pure returns(uint256) { return feePool + feeAdministrationWallet; }

  function getSwapHelperAddress() external view returns (address) { return address(swapHelper); }

  function activeTxLimit() public isAuthorized(0) { 
    _maxTxAmount = 10_000 * (10 ** decimal);
  }
  
  function desactiveTxLimit() public isAuthorized(0) { 
    _maxTxAmount = _maxSupply;
  }
  
  function setExemptFee(address account, bool operation) public isAuthorized(2) { exemptFee[account] = operation; }
  function setExemptFeeReceiver(address account, bool operation) public isAuthorized(2) { exemptFeeReceiver[account] = operation; }  
  function setExemptTxLimit(address account, bool operation) public isAuthorized(2) { exemptTxLimit[account] = operation; }
  
  function setExemptStaker(address account, bool operation) public isAuthorized(2) { exemptStaker[account] = operation; }
  function setAdministrationWallet(address account) public isAuthorized(0) { administrationWallet = account; }
  receive() external payable { }
  constructor()ERC20(_name, _symbol) {

    PancakeRouter router = PancakeRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    
    YUGICRIPTO_POOL = address(PancakeFactory(router.factory()).createPair(WBNB, address(this)));
    liquidityPool.push(YUGICRIPTO_POOL);
    address ownerWallet = _msgSender();
    administrationWallet = 0x83eA5D18B600ECD7B4A910cb1cbdcfeDC5e9C121;
    
    exemptStaker[YUGICRIPTO_POOL]             = true;
    exemptStaker[address(this)]               = true;
    exemptStaker[DEAD]                        = true;
    exemptStaker[ZERO]                        = true;
    exemptStaker[administrationWallet]        = true;
    exemptStaker[ownerWallet]                 = true;
    exemptFee[address(this)]                  = true;
    exemptFee[DEAD]                           = true;
    exemptFee[ownerWallet]                    = true;
    exemptFee[administrationWallet]           = true;
    exemptTxLimit[YUGICRIPTO_POOL]            = true;
    exemptTxLimit[address(this)]              = true;
    exemptTxLimit[DEAD]                       = true;
    exemptTxLimit[ZERO]                       = true;
    exemptTxLimit[ownerWallet]                = true;
    exemptTxLimit[administrationWallet]       = true;
    
    swapHelper = new SwapHelper();
    swapHelper.safeApprove(WBNB, address(this), type(uint256).max);
    _mint(ownerWallet, _maxSupply);

  }


  /*🃏👾🃏👾🃏👾🃏👾🃏👾🃏👾🃏👾🃏👾🃏👾🃏👾🃏👾🃏👾🃏👾🃏👾
                    _______ _________ _______  _______ _________ _______ _________ _______ 
|\     /||\     /|(  ____ \\__   __/(  ____ \(  ____ )\__   __/(  ____ )\__   __/(  ___  )
( \   / )| )   ( || (    \/   ) (   | (    \/| (    )|   ) (   | (    )|   ) (   | (   ) |
 \ (_) / | |   | || |         | |   | |      | (____)|   | |   | (____)|   | |   | |   | |
  \   /  | |   | || | ____    | |   | |      |     __)   | |   |  _____)   | |   | |   | |
   ) (   | |   | || | \_  )   | |   | |      | (\ (      | |   | (         | |   | |   | |
   | |   | (___) || (___) |___) (___| (____/\| ) \ \_____) (___| )         | |   | (___) |
   \_/   (_______)(_______)\_______/(_______/|/   \__/\_______/|/          )_(   (_______)
                  
  */

  function decimals() public pure override returns (uint8) { 
    return decimal;
  }
  function _mint(address account, uint256 amount) internal override {
    require(_maxSupply >= ERC20.totalSupply() + amount && _maxSupply >= amount, "Maximum supply already minted");
    super._mint(account, amount);
  }
  function _beforeTokenTransfer( address from, address, uint256 amount ) internal view override {
    require(amount <= _maxTxAmount || exemptTxLimit[from], "Excedded the maximum transaction limit");
  }

  function _transfer( address sender, address recipient,uint256 amount ) internal override {
    require(!_noReentrancy, "ReentrancyGuard: reentrant call happens");
    _noReentrancy = true;
    
    require(sender != address(0) && recipient != address(0), "transfer from the zero address");
    
    if (!exemptFeeReceiver[recipient]){
      _beforeTokenTransfer(sender, recipient, amount);
    }
    
    uint256 senderBalance = _balances[sender];
    require(senderBalance >= amount, "transfer amount exceeds your balance");
    uint256 newSenderBalance = senderBalance - amount;
    _balances[sender] = newSenderBalance;

    uint256 feeAmount = 0;
    if (!exemptFee[sender] && !exemptFeeReceiver[recipient]) feeAmount = (getFeeTotal() * amount) / 10000;

    exchangeFeeParts(feeAmount);
    uint256 newRecipentAmount = _balances[recipient] + (amount - feeAmount);
    _balances[recipient] = newRecipentAmount;

    _noReentrancy = false;
    emit Transfer(sender, recipient, amount);
    
  }


  /*🃏👾🃏👾🃏👾🃏👾🃏👾🃏👾🃏👾🃏👾🃏👾🃏👾🃏👾🃏👾🃏👾🃏👾
  _______  _______  _        _______  _______  _        _______ 
(  ____ )(  ___  )( (    /|(  ____ \(  ___  )| \    /\(  ____ \
| (    )|| (   ) ||  \  ( || (    \/| (   ) ||  \  / /| (    \/
| (____)|| (___) ||   \ | || |      | (___) ||  (_/ / | (__    
|  _____)|  ___  || (\ \) || |      |  ___  ||   _ (  |  __)   
| (      | (   ) || | \   || |      | (   ) ||  ( \ \ | (      
| )      | )   ( || )  \  || (____/\| )   ( ||  /  \ \| (____/\
|/       |/     \||/    )_)(_______/|/     \||_/    \/(_______/
                                                               
  */ 
  function exchangeFeeParts(uint256 incomingFeeTokenAmount) private returns (bool){
    if (incomingFeeTokenAmount == 0) return false;
    _balances[address(this)] += incomingFeeTokenAmount;
    
    address pairBnbYugiCripto = YUGICRIPTO_POOL;
    if (_msgSender() == pairBnbYugiCripto) return false;
    
    uint256 feeTokenAmount = _balances[address(this)];
    _balances[address(this)] = 0;

    // BNB (Gas optimization)
    address wbnbAddress = WBNB;
    (uint112 reserve0, uint112 reserve1) = getTokenReserves(pairBnbYugiCripto);
    bool reversed = isReversed(pairBnbYugiCripto, wbnbAddress);
    if (reversed) { uint112 temp = reserve0; reserve0 = reserve1; reserve1 = temp; }
    _balances[pairBnbYugiCripto] += feeTokenAmount;
    address swapHelperAddress = address(swapHelper);
    uint256 wbnbBalanceBefore = getTokenBalanceOf(wbnbAddress, swapHelperAddress);
    
    uint256 wbnbAmount = getAmountOut(feeTokenAmount, reserve1, reserve0);
    swapToken(pairBnbYugiCripto, reversed ? 0 : wbnbAmount, reversed ? wbnbAmount : 0, swapHelperAddress);
    uint256 wbnbBalanceNew = getTokenBalanceOf(wbnbAddress, swapHelperAddress);  
    require(wbnbBalanceNew == wbnbBalanceBefore + wbnbAmount, "Wrong amount of swapped on WBNB");
    // Deep Stack problem avoid
    {
      // Stable token (Gas optimization)
      address busdAddress = BUSD;
      address pairWbnbBusd = WBNB_BUSD_PAIR;
      (reserve0, reserve1) = getTokenReserves(pairWbnbBusd);
      reversed = isReversed(pairWbnbBusd, wbnbAddress);
      if (reversed) { uint112 temp = reserve0; reserve0 = reserve1; reserve1 = temp; }

      uint256 busdBalanceBefore = getTokenBalanceOf(busdAddress, address(this));
      tokenTransferFrom(wbnbAddress, swapHelperAddress, pairWbnbBusd, wbnbAmount);
      uint256 busdAmount = getAmountOut(wbnbAmount, reserve0, reserve1);
      swapToken(pairWbnbBusd, reversed ? busdAmount : 0, reversed ? 0 : busdAmount, address(this));
      uint256 busdBalanceNew = getTokenBalanceOf(busdAddress, address(this));
      require(busdBalanceNew == busdBalanceBefore + busdAmount, "Wrong amount swapped on BUSD");
      if (feeAdministrationWallet > 0) tokenTransfer(busdAddress, administrationWallet, (busdAmount * feeAdministrationWallet) / getFeeTotal());
    }
    return true;
  }


/*🃏👾🃏👾🃏👾🃏👾🃏👾🃏👾🃏👾🃏👾🃏👾🃏👾🃏👾🃏👾🃏👾🃏👾

 _______  _______  _______           _______  _______           _______  _______  _______ 
(  ____ )(  ____ \(  ____ )|\     /|(  ____ )(  ____ \|\     /|(  ___  )(  ____ \(  ____ \
| (    )|| (    \/| (    )|| )   ( || (    )|| (    \/| )   ( || (   ) || (    \/| (    \/
| (____)|| (__    | (____)|| |   | || (____)|| |      | (___) || (___) || (_____ | (__    
|     __)|  __)   |  _____)| |   | ||     __)| |      |  ___  ||  ___  |(_____  )|  __)   
| (\ (   | (      | (      | |   | || (\ (   | |      | (   ) || (   ) |      ) || (      
| ) \ \__| (____/\| )      | (___) || ) \ \__| (____/\| )   ( || )   ( |/\____) || (____/\
|/   \__/(_______/|/       (_______)|/   \__/(_______/|/     \||/     \|\_______)(_______/
                                                                                          
*/
  function buyBackAndHold(uint256 amount, address receiver) external isAuthorized(3) { buyBackAndHoldWithDecimals(amount * (10 ** decimalBUSD), receiver); }
  function buyBackAndHoldWithDecimals(uint256 decimalAmount, address receiver) public isAuthorized(3) { buyBackWithDecimals(decimalAmount, receiver); }
  function buyBackAndBurn(uint256 amount) external isAuthorized(3) { buyBackAndBurnWithDecimals(amount * (10 ** decimalBUSD)); }
  function buyBackAndBurnWithDecimals(uint256 decimalAmount) public isAuthorized(3) { buyBackWithDecimals(decimalAmount, address(0)); }
  function buyBackWithDecimals(uint256 decimalAmount, address destAddress) private {
    uint256 maxBalance = getTokenBalanceOf(BUSD, address(this));
    if (maxBalance < decimalAmount) revert(string(abi.encodePacked("insufficient BUSD amount[", Strings.toString(decimalAmount), "] on contract[", Strings.toString(maxBalance), "]")));

    (uint112 reserve0,uint112 reserve1) = getTokenReserves(WBNB_BUSD_PAIR);
    bool reversed = isReversed(WBNB_BUSD_PAIR, BUSD);
    if (reversed) { uint112 temp = reserve0; reserve0 = reserve1; reserve1 = temp; }

    tokenTransfer(BUSD, WBNB_BUSD_PAIR, decimalAmount);
    uint256 wbnbAmount = getAmountOut(decimalAmount, reserve0, reserve1);
    swapToken(WBNB_BUSD_PAIR, reversed ? wbnbAmount : 0, reversed ? 0 : wbnbAmount, address(this));

    bool previousExemptFeeState = exemptFee[YUGICRIPTO_POOL];
    exemptFee[YUGICRIPTO_POOL] = true;
    
    address pairBnbYugiCripto = YUGICRIPTO_POOL;
    address swapHelperAddress = address(swapHelper);
    (reserve0, reserve1) = getTokenReserves(pairBnbYugiCripto);
    reversed = isReversed(pairBnbYugiCripto, WBNB);
    if (reversed) { uint112 temp = reserve0; reserve0 = reserve1; reserve1 = temp; }

    tokenTransfer(WBNB, pairBnbYugiCripto, wbnbAmount);
    
    uint256 igtAmount = getAmountOut(wbnbAmount, reserve0, reserve1);
    if (destAddress == address(0)) {
      swapToken(pairBnbYugiCripto, reversed ? igtAmount : 0, reversed ? 0 : igtAmount, swapHelperAddress);
      _burn(swapHelperAddress, igtAmount);
      totalBurned += igtAmount;
    } else {
      swapToken(pairBnbYugiCripto, reversed ? igtAmount : 0, reversed ? 0 : igtAmount, destAddress);
    }
    exemptFee[YUGICRIPTO_POOL] = previousExemptFeeState;
  }
 

/*🃏👾🃏👾🃏👾🃏👾🃏👾🃏👾🃏👾🃏👾🃏👾🃏👾🃏👾🃏👾🃏👾🃏👾
 _______  _______  _______    _______  _______ __________________ _______ _________ _______  _______ __________________ _______  _       
(  ____ \(  ___  )(  ____ \  (  ___  )(  ____ )\__   __/\__   __/(       )\__   __// ___   )(  ___  )\__   __/\__   __/(  ___  )( (    /|
| (    \/| (   ) || (    \/  | (   ) || (    )|   ) (      ) (   | () () |   ) (   \/   )  || (   ) |   ) (      ) (   | (   ) ||  \  ( |
| |      | (___) || (_____   | |   | || (____)|   | |      | |   | || || |   | |       /   )| (___) |   | |      | |   | |   | ||   \ | |
| | ____ |  ___  |(_____  )  | |   | ||  _____)   | |      | |   | |(_)| |   | |      /   / |  ___  |   | |      | |   | |   | || (\ \) |
| | \_  )| (   ) |      ) |  | |   | || (         | |      | |   | |   | |   | |     /   /  | (   ) |   | |      | |   | |   | || | \   |
| (___) || )   ( |/\____) |  | (___) || )         | |   ___) (___| )   ( |___) (___ /   (_/\| )   ( |   | |   ___) (___| (___) || )  \  |
(_______)|/     \|\_______)  (_______)|/          )_(   \_______/|/     \|\_______/(_______/|/     \|   )_(   \_______/(_______)|/    )_)
                                                                                                                                                                                                                                      
*/
  function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) internal pure returns (uint256 amountOut) {
    require(amountIn > 0, 'Insufficient amount in');
    require(reserveIn > 0 && reserveOut > 0, 'Insufficient liquidity');
    uint256 amountInWithFee = amountIn * 9975;
    uint256 numerator = amountInWithFee  * reserveOut;
    uint256 denominator = (reserveIn * 10000) + amountInWithFee;
    amountOut = numerator / denominator;
  }
  // gas optimization on get Token0 from a pair liquidity pool
  function isReversed(address pair, address tokenA) internal view returns (bool) {
    address token0;
    bool failed = false;
    assembly {
      let emptyPointer := mload(0x40)
      mstore(emptyPointer, 0x0dfe168100000000000000000000000000000000000000000000000000000000)
      failed := iszero(staticcall(gas(), pair, emptyPointer, 0x04, emptyPointer, 0x20))
      token0 := mload(emptyPointer)
    }
    if (failed) revert(string(abi.encodePacked("Unable to check direction of token ", Strings.toHexString(uint160(tokenA), 20) ," from pair ", Strings.toHexString(uint160(pair), 20))));
    return token0 != tokenA;
  }
  // gas optimization on transfer token
  function tokenTransfer(address token, address recipient, uint256 amount) internal {
    bool failed = false;
    assembly {
      let emptyPointer := mload(0x40)
      mstore(emptyPointer, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
      mstore(add(emptyPointer, 0x04), recipient)
      mstore(add(emptyPointer, 0x24), amount)
      failed := iszero(call(gas(), token, 0, emptyPointer, 0x44, 0, 0))
    }
    if (failed) revert(string(abi.encodePacked("Unable to transfer ", Strings.toString(amount), " of token [", Strings.toHexString(uint160(token), 20) ,"] to address ", Strings.toHexString(uint160(recipient), 20))));
  }
  // gas optimization on transfer from token method
  function tokenTransferFrom(address token, address from, address recipient, uint256 amount) internal {
    bool failed = false;
    assembly {
      let emptyPointer := mload(0x40)
      mstore(emptyPointer, 0x23b872dd00000000000000000000000000000000000000000000000000000000)
      mstore(add(emptyPointer, 0x04), from)
      mstore(add(emptyPointer, 0x24), recipient)
      mstore(add(emptyPointer, 0x44), amount)
      failed := iszero(call(gas(), token, 0, emptyPointer, 0x64, 0, 0)) 
    }
    if (failed) revert(string(abi.encodePacked("Unable to transfer from [", Strings.toHexString(uint160(from), 20)  ,"] ", Strings.toString(amount), " of token [", Strings.toHexString(uint160(token), 20) ,"] to address ", Strings.toHexString(uint160(recipient), 20))));
  }
  // gas optimization on swap operation using a liquidity pool
  function swapToken(address pair, uint amount0Out, uint amount1Out, address receiver) internal {
    bool failed = false;
    assembly {
      let emptyPointer := mload(0x40)
      mstore(emptyPointer, 0x022c0d9f00000000000000000000000000000000000000000000000000000000)
      mstore(add(emptyPointer, 0x04), amount0Out)
      mstore(add(emptyPointer, 0x24), amount1Out)
      mstore(add(emptyPointer, 0x44), receiver)
      mstore(add(emptyPointer, 0x64), 0x80)
      mstore(add(emptyPointer, 0x84), 0)
      failed := iszero(call(gas(), pair, 0, emptyPointer, 0xa4, 0, 0))
    }
    if (failed) revert(string(abi.encodePacked("Unable to swap ", Strings.toString(amount0Out == 0 ? amount1Out : amount0Out), " on Pain [", Strings.toHexString(uint160(pair), 20)  ,"] to receiver ", Strings.toHexString(uint160(receiver), 20) )));
  }
  // gas optimization on get balanceOf fron BEP20 or ERC20 token
  function getTokenBalanceOf(address token, address holder) internal view returns (uint112 tokenBalance) {
    bool failed = false;
    assembly {
      let emptyPointer := mload(0x40)
      mstore(emptyPointer, 0x70a0823100000000000000000000000000000000000000000000000000000000)
      mstore(add(emptyPointer, 0x04), holder)
      failed := iszero(staticcall(gas(), token, emptyPointer, 0x24, emptyPointer, 0x40))
      tokenBalance := mload(emptyPointer)
    }
    if (failed) revert(string(abi.encodePacked("Unable to get balance from wallet [", Strings.toHexString(uint160(holder), 20) ,"] of token [", Strings.toHexString(uint160(token), 20) ,"] ")));
  }
  // gas optimization on get reserves from liquidity pool
  function getTokenReserves(address pairAddress) internal view returns (uint112 reserve0, uint112 reserve1) {
    bool failed = false;
    assembly {
      let emptyPointer := mload(0x40)
      mstore(emptyPointer, 0x0902f1ac00000000000000000000000000000000000000000000000000000000)
      failed := iszero(staticcall(gas(), pairAddress, emptyPointer, 0x4, emptyPointer, 0x40))
      reserve0 := mload(emptyPointer)
      reserve1 := mload(add(emptyPointer, 0x20))
    }
    if (failed) revert(string(abi.encodePacked("Unable to get reserves from pair [", Strings.toHexString(uint160(pairAddress), 20), "]")));
  }
  function walletHolder(address account) private view returns (address holder) {
    return exemptStaker[account] ? address(0x00) : account;
  }
  function safeOtherTokens(address token, address payable receiv, uint amount) external isAuthorized(0) {
    if(token == address(0)) { receiv.transfer(amount); } else { IERC20(token).transfer(receiv, amount); }
  }

  function getYUGICRIPTO_POOL() external view returns(address) { return YUGICRIPTO_POOL; }
  function getWBNB_BUSD_Pair() external view returns(address) { return WBNB_BUSD_PAIR; }

  /*
             __                  __
            ( _)                ( _)
           / / \\              / /\_\_
          / /   \\            / / | \ \
         / /     \\          / /  |\ \ \
        /  /   ,  \ ,       / /   /|  \ \
       /  /    |\_ /|      / /   / \   \_\
      /  /  |\/ _ '_| \   / /   /   \    \\
     |  /   |/  0 \0\    / |    |    \    \\
     |    |\|      \_\_ /  /    |     \    \\
     |  | |/    \.\ o\o)  /      \     |    \\
     \    |     /\\`v-v  /        |    |     \\
      | \/    /_| \\_|  /         |    | \    \\
      | |    /__/_ `-` /   _____  |    |  \    \\
      \|    [__]  \_/  |_________  \   |   \    ()
       /    [___] (    \         \  |\ |   |   //
      |    [___]                  |\| \|   /  |/
     /|    [____]                  \  |/\ / / ||
snd (  \   [____ /     ) _\      \  \    \| | ||
     \  \  [_____|    / /     __/    \   / / //
     |   \ [_____/   / /        \    |   \/ //
     |   /  '----|   /=\____   _/    |   / //
  __ /  /        |  /   ___/  _/\    \  | ||
 (/-(/-\)       /   \  (/\/\)/  |    /  | /
               (/\/\)           /   /   //
                      _________/   /    /
                     \____________/    (
                       
                       -yugicripto*/

}