pragma solidity ^0.6.12;
// SPDX-License-Identifier: Unlicensed
interface IERC20 {

    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}



/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
 
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;

        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

     /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// pragma solidity >=0.5.0;

interface IPancakeV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}


// pragma solidity >=0.5.0;

interface IPancakeV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// pragma solidity >=0.6.2;

interface IPancakeV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}



// pragma solidity >=0.6.2;

interface IPancakeV2Router02 is IPancakeV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}


contract Sensei is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee;

    mapping (address => bool) private _isExcluded;
    address[] private _excluded;

    // Affiliation feature: members and influencers addresses
    mapping (address => int) private _influencers;
    mapping (address => address) private _members;
    mapping (address => uint256) private txAmountMember;

    uint256 private constant MAX = ~uint256(0);

    uint256 private _tTotal = 111000000 * 10**3 * 10**7;

    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    string constant private _name = "Sensei";
    string constant private _symbol = "SENSEI";
    uint8 constant private _decimals = 7;

    uint256 public _taxFee = 4;
    uint256 private _previousTaxFee = _taxFee;

    uint256 public _liquidityFee = 2;
    uint256 private _previousLiquidityFee = _liquidityFee;

    uint256 public _marketingFee = 1;
    uint256 private _previousMarketingFee = _marketingFee;

    uint256 public _stakingFee = 0;
    uint256 private _previousStakingFee = _stakingFee;

    uint256 public _burnFee = 2;
    uint256 private _previousBurnFee = _burnFee;

    uint256 public _tresorFee = 1;
    uint256 private _previousTresorFee = _tresorFee;

    uint256 public _influRewardsPercentOnTFee = 50;

    IPancakeV2Router02 public pancakeV2Router;
    address public pancakeV2Pair;
    address payable public _marketingWalletAddress;
    address payable public _tresorWalletAddress;
    address payable public _burnWalletAddress;
    address payable public _stakingWalletAddress;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;

    bool public _affilationEnabled = true;

    uint256 public _maxTxAmount = 333000 * 10**3 * 10**7; // 333 000 000 (+ 3 decimals)
    uint256 private numTokensSellToAddToLiquidity = 55500 * 10**3 * 10**7;  // 55 500 000 (+ 3 decimals)

    event Burn(address indexed sender, uint amount);
    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiquidity
    );

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor () public {
        _marketingWalletAddress = 0xEcfa9566331212490670EA15DdBa2685327a763B;
        _burnWalletAddress = 0x93887353448E51624c0861e3A055621c2f0E7f4A;
        _tresorWalletAddress = 0x81A86F040CDA219d9c52dC690aD58A70903cAB68;
        _stakingWalletAddress = 0xD2A7d8632ACdb40152afb4507E0f984Cb641D798;

        _rOwned[0x69B2580c517bf9D6107344e17d0F7f0ef830E024] = _rTotal.div(100).mul(3); // Wallet future development - 3%
        _rOwned[0x0c145A374A92184C5094d9c629E181FfeE92dE22] = _rTotal.div(10000).mul(553); // Wallet future team - 5.53%
        _rOwned[0x9A5e0f0736EF2B25cbA9839C7bB83069965A7B05] = _rTotal.div(1000).mul(84); // Wallet future advisor - 8.4%
        _rOwned[0x991136F1cCfcaB42a27F1ff16af5284444f21183] = _rTotal.div(100).mul(12); // Wallet future marketing - 12%
        _rOwned[0xfED3051B554A9FCf8eDFbAd7a597f54c7d61814c] = _rTotal.div(100); // Team member Anubis - 1%
        _rOwned[0xBeC16697926f43a9c6de7817a8BCce335F366BcD] = _rTotal.div(1000).mul(5); // Team member - 0.5%
        _rOwned[0xa6Ec04eBc379F2f663F410eB445584f7b0a5f885] = _rTotal.div(1000).mul(5); // Team member - 0.5%
        _rOwned[0xaBd5fe6a52F8a33c58a19254D6A1fcF4709C2526] = _rTotal.div(1000).mul(4); // Team member - 0.4%
        _rOwned[0x3184bF7c88b72C470EC61EB8aeC7bD4278649986] = _rTotal.div(1000).mul(4); // Team member - 0.4%
        _rOwned[0x1DfEDFEdfC4C428A0F9850ea89430CD906C4E69e] = _rTotal.div(1000).mul(5); // Team member - 0.5%
        _rOwned[0x1FDe37b4fE004A28e57f7DCDfbCD8FfaB9a2b28C] = _rTotal.div(1000).mul(5); // Team member - 0.5%
        _rOwned[0x17aFC584ACb4Af95904209d56c100c1FCfF9AD19] = _rTotal.div(1000).mul(2); // Team member - 0.2%
        _rOwned[0x986c1EF8C97190A3b65f17DB3b00732b45389D47] = _rTotal.div(1000); // Team member - 0.1%
        _rOwned[0x07E9732929e78a896bDcc568332a72929C0765Cf] = _rTotal.div(10000); // Team member - 0.01%
        _rOwned[0x2b055675cB9156D1e393a2BD8a89E0960EF5A061] = _rTotal.div(10000); // Team member - 0.01%
        _rOwned[0x2c7c3D35A800353219dF66cAa46F5Fa4d491AF5e] = _rTotal.div(10000).mul(5); // Team member - 0.05%
        _rOwned[0xbfe92F7AF15441eBB41aC49902Bf1C073EA05285] = _rTotal.div(10000).mul(25); // Team member - 0.25%
        _rOwned[0xD6cC5aD9440E0339F2C7b7D192633bD0Fb1D8EA0] = _rTotal.div(10000).mul(25); // Team member - 0.25%
        _rOwned[0x10cD8079755bC23b7E644F60627478e62E8817D5] = _rTotal.div(1000).mul(5); // Team member - 0.5%
        _rOwned[0xb79B40D3798A84509Cb802adDD24D2422C9B73C6] = _rTotal.div(1000).mul(5); // Team member - 0.5%
        _rOwned[0xfAE1a77863339c650306edDd72441485bf8b5cEB] = _rTotal.div(1000).mul(3); // Team member - 0.3%
        _rOwned[0x38BFcf71AD5ec5123092E561Cc9DfC36769cDC81] = _rTotal.div(1000); // Team member - 0.1%
        _rOwned[0x1289F1098Aa55d7acC5d0813ce40C1632111537B] = _rTotal.div(100).mul(65); // Supply left 65% - Owner

        //PCS Router v1 TESTNET address: 0xD99D1c33F9fC3444f8101754aBC46c52416550D1
        //PCS Router v2 MAINNET address: 0x10ED43C718714eb63d5aA57B78B54704E256024E
        IPancakeV2Router02 _pancakeV2Router = IPancakeV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
         // Create a pancakeswap pair for this new token
        pancakeV2Pair = IPancakeV2Factory(_pancakeV2Router.factory())
            .createPair(address(this), _pancakeV2Router.WETH());
        // set the rest of the contract variables
        pancakeV2Router = _pancakeV2Router;

        //exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;

        emit Transfer(address(0), 0x69B2580c517bf9D6107344e17d0F7f0ef830E024, _tTotal.div(100).mul(3)); // Wallet future development - 3%
        emit Transfer(address(0), 0x0c145A374A92184C5094d9c629E181FfeE92dE22, _tTotal.div(10000).mul(553)); // Wallet future team - 5.53%
        emit Transfer(address(0), 0x9A5e0f0736EF2B25cbA9839C7bB83069965A7B05, _tTotal.div(1000).mul(84)); // Wallet future advisor - 8.4%
        emit Transfer(address(0), 0x991136F1cCfcaB42a27F1ff16af5284444f21183, _tTotal.div(100).mul(12)); // Wallet future marketing - 12%

        emit Transfer(address(0), 0xfED3051B554A9FCf8eDFbAd7a597f54c7d61814c, _tTotal.div(100)); // Team member Anubis - 1%
        emit Transfer(address(0), 0xBeC16697926f43a9c6de7817a8BCce335F366BcD, _tTotal.div(1000).mul(5)); // Team member - 0.5%
        emit Transfer(address(0), 0xa6Ec04eBc379F2f663F410eB445584f7b0a5f885, _tTotal.div(1000).mul(5)); // Team member - 0.5%
        emit Transfer(address(0), 0xaBd5fe6a52F8a33c58a19254D6A1fcF4709C2526, _tTotal.div(1000).mul(4)); // Team member - 0.4%
        emit Transfer(address(0), 0x3184bF7c88b72C470EC61EB8aeC7bD4278649986, _tTotal.div(1000).mul(4)); // Team member - 0.4%
        emit Transfer(address(0), 0x1DfEDFEdfC4C428A0F9850ea89430CD906C4E69e, _tTotal.div(1000).mul(5)); // Team member - 0.5%
        emit Transfer(address(0), 0x1FDe37b4fE004A28e57f7DCDfbCD8FfaB9a2b28C, _tTotal.div(1000).mul(5)); // Team member - 0.5%
        emit Transfer(address(0), 0x17aFC584ACb4Af95904209d56c100c1FCfF9AD19, _tTotal.div(1000).mul(2)); // Team member - 0.2%
        emit Transfer(address(0), 0x986c1EF8C97190A3b65f17DB3b00732b45389D47, _tTotal.div(1000)); // Team member - 0.1%
        emit Transfer(address(0), 0x07E9732929e78a896bDcc568332a72929C0765Cf, _tTotal.div(10000)); // Team member - 0.01%
        emit Transfer(address(0), 0x2b055675cB9156D1e393a2BD8a89E0960EF5A061, _tTotal.div(10000)); // Team member - 0.01%
        emit Transfer(address(0), 0x2c7c3D35A800353219dF66cAa46F5Fa4d491AF5e, _tTotal.div(10000).mul(5)); // Team member - 0.05%

        emit Transfer(address(0), 0xbfe92F7AF15441eBB41aC49902Bf1C073EA05285, _tTotal.div(10000).mul(25)); // Team member - 0.25%
        emit Transfer(address(0), 0xD6cC5aD9440E0339F2C7b7D192633bD0Fb1D8EA0, _tTotal.div(10000).mul(25)); // Team member - 0.25%
        emit Transfer(address(0), 0x10cD8079755bC23b7E644F60627478e62E8817D5, _tTotal.div(1000).mul(5)); // Team member - 0.5%
        emit Transfer(address(0), 0xb79B40D3798A84509Cb802adDD24D2422C9B73C6, _tTotal.div(1000).mul(5)); // Team member - 0.5%
        emit Transfer(address(0), 0xfAE1a77863339c650306edDd72441485bf8b5cEB, _tTotal.div(1000).mul(3)); // Team member - 0.3%
        emit Transfer(address(0), 0x38BFcf71AD5ec5123092E561Cc9DfC36769cDC81, _tTotal.div(1000)); // Team member Tika - 0.1%

        emit Transfer(address(0), 0x1289F1098Aa55d7acC5d0813ce40C1632111537B, _tTotal.div(100).mul(65)); // Supply left 65% - Owner
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function deliver(uint256 tAmount) public {
        address sender = _msgSender();
        require(!_isExcluded[sender], "Excluded addresses cannot call this function");
        (uint256[3] memory rValues,) =  _getValues(tAmount);
        uint256 rAmount = rValues[0];

        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256[3] memory rValues,) =  _getValues(tAmount);
            uint256 rAmount = rValues[0];

            return rAmount;
        } else {
            (uint256[3] memory rValues,) =  _getValues(tAmount);
            uint256 rTransferAmount = rValues[1];

            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    function excludeFromReward(address account) public onlyOwner() {
        // require(account != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 'We can not exclude Pancake router.');
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner() {
        require(_isExcluded[account], "Account is not excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256[3] memory rValues, uint256[7] memory tValues) =  _getValues(tAmount);
        uint256 rAmount = rValues[0];
        uint256 rTransferAmount = rValues[1];
        uint256 rFee = rValues[2];
        uint256 tTransferAmount = tValues[0];
        uint256 tFee = tValues[1];
        uint256 tLiquidity = tValues[2];
        uint256 tMarketing = tValues[3];
        uint256 tBurn = tValues[4];
        uint256 tTresor = tValues[5];
        uint256 tStaking = tValues[6];

        decreaseROwned(sender, rAmount);
        decreaseTOwned(sender, tAmount);
        increaseTOwned(recipient, tTransferAmount);
        increaseROwned(recipient, rTransferAmount);
        _takeLiquidity(tLiquidity);
        _takeMarketing(tMarketing);
        _takeBurn(tBurn);
        _takeTresor(tTresor);
        _takeStaking(tStaking);

        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setTaxFeePercent(uint256 taxFee) external onlyOwner() {
        require(taxFee <= 6, "Max fee 6%");
        _previousTaxFee = _taxFee;
        _taxFee = taxFee;
    }

    function setLiquidityFeePercent(uint256 liquidityFee) external onlyOwner() {
        require(liquidityFee <= 5, "Max fee 5%");
        _previousLiquidityFee = _liquidityFee;
        _liquidityFee = liquidityFee;
    }

    function setMaxTxAmount(uint256 maxTxAmount) external onlyOwner() {
        _maxTxAmount = maxTxAmount;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

     //to receive BNB from pancakeV2Router when swapping
    receive() external payable {}

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        if (_affilationEnabled && isMember(tx.origin) && txAmountMember[tx.origin] < 2) {
            // If it's an investor's first 2 transactions, then split fee between affiliate and influencer
            uint256 currentRate =  _getRate();
            uint256 rHolderFee = tFee.mul(currentRate);

            address influencerAddress = getInfluencerForMember(tx.origin);

            uint256 currentTxAmount = txAmountMember[tx.origin];
            if (currentTxAmount > 0) {
                txAmountMember[tx.origin] = currentTxAmount + 1;
            } else {
                txAmountMember[tx.origin] = 1;
            }

            uint256 rInfluRewardsAmount = calculateInfluenceurRewards(rHolderFee);
            _rOwned[influencerAddress] = _rOwned[influencerAddress].add(rInfluRewardsAmount);
            _rOwned[tx.origin] = _rOwned[tx.origin].add(rHolderFee.sub(rInfluRewardsAmount));
            if(_isExcluded[influencerAddress]) {
                _tOwned[influencerAddress] = _tOwned[influencerAddress].add(calculateInfluenceurRewards(tFee));
            }
            if(_isExcluded[tx.origin]) {
                _tOwned[tx.origin] = _tOwned[tx.origin].add(tFee.sub(calculateInfluenceurRewards(tFee)));
            }
        } else {
            // Reflect fee between holders as usual
            _rTotal = _rTotal.sub(rFee);
            _tFeeTotal = _tFeeTotal.add(tFee);
        }
    }

    function _getValues(uint256 tAmount) private view returns (uint256[3] memory, uint256[7] memory) {
        uint256[7] memory tValues = _getTValues(tAmount);
        uint256[3] memory rValues = _getRValues(tAmount, tValues[1], tValues[2], tValues[3], tValues[4], tValues[5], tValues[6], _getRate());

        return (rValues, tValues);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256[7] memory) {
        uint256[7] memory tValues = [0, calculateTaxFee(tAmount), calculateLiquidityFee(tAmount), calculateMarketingFee(tAmount), calculateBurnFee(tAmount), calculateTresorFee(tAmount), calculateStakingFee(tAmount)];
        tValues[0] = _getTTransferAmount(tAmount, tValues);

        return tValues;
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tLiquidity, uint256 tMarketing, uint256 tBurn, uint256 tTresor, uint256 tStaking, uint256 currentRate) private pure returns (uint256[3] memory) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rMarketing = tMarketing.mul(currentRate);
        uint256 rBurn = tBurn.mul(currentRate);
        uint256 rTresor = tTresor.mul(currentRate);
        uint256 rStaking = tStaking.mul(currentRate);

        uint256[7] memory tempRValues = [rAmount, rLiquidity, rFee, rMarketing, rBurn, rTresor, rStaking];
        uint256[3] memory rValues = [rAmount, _getRTransferAmount(tempRValues), rFee];

        return rValues;
    }

    function _getTTransferAmount(uint256 tAmount, uint256[7] memory tValues) private pure returns(uint256) {
        return tAmount.sub(tValues[1]).sub(tValues[2]).sub(tValues[3]).sub(tValues[4]).sub(tValues[5]).sub(tValues[6]);
    }

    function _getRTransferAmount(uint256[7] memory rValues) private pure returns(uint256) {
        return rValues[0].sub(rValues[2]).sub(rValues[1]).sub(rValues[3]).sub(rValues[4]).sub(rValues[5]).sub(rValues[6]);
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _takeLiquidity(uint256 tLiquidity) private {
        uint256 currentRate =  _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
    }

    function _takeMarketing(uint256 tMarketing) private {
        uint256 currentRate =  _getRate();
        uint256 rMarketing = tMarketing.mul(currentRate);
        _rOwned[_marketingWalletAddress] = _rOwned[_marketingWalletAddress].add(rMarketing);
        if(_isExcluded[_marketingWalletAddress])
            _tOwned[_marketingWalletAddress] = _tOwned[_marketingWalletAddress].add(tMarketing);
    }

    function _takeBurn(uint256 tBurn) private {
        uint256 currentRate =  _getRate();
        uint256 rBurn = tBurn.mul(currentRate);
        _rOwned[_burnWalletAddress] = _rOwned[_burnWalletAddress].add(rBurn);
        if(_isExcluded[_burnWalletAddress]) {
            _tOwned[_burnWalletAddress] = _tOwned[_burnWalletAddress].add(tBurn);
        }
    }

    function _takeTresor(uint256 tTresor) private {
        uint256 currentRate =  _getRate();
        uint256 rTresor = tTresor.mul(currentRate);
        _rOwned[_tresorWalletAddress] = _rOwned[_tresorWalletAddress].add(rTresor);
        if(_isExcluded[_tresorWalletAddress])
            _tOwned[_tresorWalletAddress] = _tOwned[_tresorWalletAddress].add(tTresor);
    }

    function _takeStaking(uint256 tStaking) private {
        uint256 currentRate =  _getRate();
        uint256 rStaking = tStaking.mul(currentRate);
        _rOwned[_stakingWalletAddress] = _rOwned[_stakingWalletAddress].add(rStaking);
        if(_isExcluded[_stakingWalletAddress])
            _tOwned[_stakingWalletAddress] = _tOwned[_stakingWalletAddress].add(tStaking);
    }

    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxFee).div(
            10**2
        );
    }

    function calculateLiquidityFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_liquidityFee).div(
            10**2
        );
    }

    function calculateMarketingFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_marketingFee).div(
            10**2
        );
    }

    function calculateBurnFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_burnFee).div(
            10**2
        );
    }

    function calculateTresorFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_tresorFee).div(
            10**2
        );
    }

    function calculateStakingFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_stakingFee).div(
            10**2
        );
    }

    function calculateInfluenceurRewards(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_influRewardsPercentOnTFee).div(
            10**2
        );
    }

    function removeAllFee() private {
        _previousTaxFee = _taxFee;
        _previousLiquidityFee = _liquidityFee;
        _previousMarketingFee = _marketingFee;
        _previousTresorFee = _tresorFee;
        _previousBurnFee = _burnFee;
        _previousStakingFee = _stakingFee;

        _taxFee = 0;
        _liquidityFee = 0;
        _marketingFee = 0;
        _tresorFee = 0;
        _burnFee = 0;
        _stakingFee = 0;
    }

    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
        _liquidityFee = _previousLiquidityFee;
        _marketingFee = _previousMarketingFee;
        _tresorFee = _previousTresorFee;
        _burnFee = _previousBurnFee;
        _stakingFee = _previousStakingFee;
    }

    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if(from != owner() && to != owner()) {
            require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
        }
        // is the token balance of this contract address over the min number of
        // tokens that we need to initiate a swap + liquidity lock?
        // also, don't get caught in a circular liquidity event.
        // also, don't swap & liquify if sender is pancakeswap pair.
        uint256 contractTokenBalance = balanceOf(address(this));

        if(contractTokenBalance >= _maxTxAmount)
        {
            contractTokenBalance = _maxTxAmount;
        }

        bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            from != pancakeV2Pair &&
            swapAndLiquifyEnabled
        ) {
            contractTokenBalance = numTokensSellToAddToLiquidity;
            //add liquidity
            swapAndLiquify(contractTokenBalance);
        }

        //indicates if fee should be deducted from transfer
        bool takeFee = true;

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        }

        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from,to,amount,takeFee);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        // split the contract balance into halves
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        swapTokensForBnb(half); // <- this breaks the BNB -> SENSEI swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to pancakeswap
        addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForBnb(uint256 tokenAmount) private {
        // generate the pancakeSwap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancakeV2Router.WETH();

        _approve(address(this), address(pancakeV2Router), tokenAmount);

        // make the swap
        pancakeV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(pancakeV2Router), tokenAmount);

        // add the liquidity
        pancakeV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee) private {
        if(!takeFee)
            removeAllFee();

        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }

        if(!takeFee)
            restoreAllFee();
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256[3] memory rValues, uint256[7] memory tValues) =  _getValues(tAmount);
        uint256 rAmount = rValues[0];
        uint256 rTransferAmount = rValues[1];
        uint256 rFee = rValues[2];
        uint256 tTransferAmount = tValues[0];
        uint256 tFee = tValues[1];
        uint256 tLiquidity = tValues[2];
        uint256 tMarketing = tValues[3];
        uint256 tBurn = tValues[4];
        uint256 tTresor = tValues[5];
        uint256 tStaking = tValues[6];

        decreaseROwned(sender, rAmount);
        increaseROwned(recipient, rTransferAmount);
        _takeLiquidity(tLiquidity);
        _takeMarketing(tMarketing);
        _takeBurn(tBurn);
        _takeTresor(tTresor);
        _takeStaking(tStaking);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256[3] memory rValues, uint256[7] memory tValues) =  _getValues(tAmount);
        uint256 rAmount = rValues[0];
        uint256 rTransferAmount = rValues[1];
        uint256 rFee = rValues[2];
        uint256 tTransferAmount = tValues[0];
        uint256 tFee = tValues[1];
        uint256 tLiquidity = tValues[2];
        uint256 tMarketing = tValues[3];
        uint256 tBurn = tValues[4];
        uint256 tTresor = tValues[5];
        uint256 tStaking = tValues[6];

        decreaseROwned(sender, rAmount);
        increaseTOwned(recipient, tTransferAmount);
        increaseROwned(recipient, rTransferAmount);

        _takeLiquidity(tLiquidity);
        _takeMarketing(tMarketing);
        _takeBurn(tBurn);
        _takeTresor(tTresor);
        _takeStaking(tStaking);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256[3] memory rValues, uint256[7] memory tValues) =  _getValues(tAmount);
        uint256 rAmount = rValues[0];
        uint256 rTransferAmount = rValues[1];
        uint256 rFee = rValues[2];
        uint256 tTransferAmount = tValues[0];
        uint256 tFee = tValues[1];
        uint256 tLiquidity = tValues[2];
        uint256 tMarketing = tValues[3];
        uint256 tBurn = tValues[4];
        uint256 tTresor = tValues[5];
        uint256 tStaking = tValues[6];

        decreaseTOwned(sender, tAmount);
        decreaseROwned(sender, rAmount);
        increaseROwned(recipient, rTransferAmount);
        _takeLiquidity(tLiquidity);
        _takeMarketing(tMarketing);
        _takeBurn(tBurn);
        _takeTresor(tTresor);
        _takeStaking(tStaking);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function decreaseTOwned(address sender, uint256 tAmount) private {
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
    }

    function decreaseROwned(address sender, uint256 rAmount) private {
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
    }

    function increaseROwned(address recipient, uint256 rTransferAmount) private {
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
    }

    function increaseTOwned(address recipient, uint256 tTransferAmount) private {
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
    }

    function getMarketingWalletAddress() public view returns (address) {
        return _marketingWalletAddress;
    }

    function setMarketingWalletAddress(address payable newAdress)  external onlyOwner() {
        _marketingWalletAddress = newAdress;
    }

    function getStakingWalletAddress() public view returns (address) {
        return _stakingWalletAddress;
    }

    function _setStakingWallet(address payable stakingWalletAddress) external onlyOwner() {
        _stakingWalletAddress = stakingWalletAddress;
    }

    function getTresorWalletAddress() public view returns (address) {
        return _tresorWalletAddress;
    }

    function setTresorWalletAddress(address payable newAdress)  external onlyOwner() {
        _tresorWalletAddress = newAdress;
    }

    function getBurnWalletAddress() public view returns (address) {
        return _burnWalletAddress;
    }

    function setBurnWalletAddress(address payable newAdress)  external onlyOwner() {
        _burnWalletAddress = newAdress;
    }

    function setNumTokensSellToAddToLiquidity(uint256 _numTokensSellToAddToLiquidity) external onlyOwner() {
        numTokensSellToAddToLiquidity = _numTokensSellToAddToLiquidity;
    }

    function getNumTokensSellToAddToLiquidity() public view returns (uint256) {
        return numTokensSellToAddToLiquidity;
    }

    function setMarketingFeePercent(uint256 marketingFee) external onlyOwner() {
        require(marketingFee <= 2, "Max fee 2%");
        _previousMarketingFee = _marketingFee;
        _marketingFee = marketingFee;
    }

    function setStakingFeePercent(uint256 stakingFee) external onlyOwner() {
        require(stakingFee <= 3, "Max fee 3%");
        _previousStakingFee = _stakingFee;
        _stakingFee = stakingFee;
    }

    function setBurnFeePercent(uint256 burnFee) external onlyOwner() {
        require(burnFee <= 4, "Max fee 4%");
        _previousBurnFee = _burnFee;
        _burnFee = burnFee;
    }

    function setTresorFeePercent(uint256 tresorFee) external onlyOwner() {
        require(tresorFee <= 2, "Max fee 2%");
        _previousTresorFee = _tresorFee;
        _tresorFee = tresorFee;
    }

    function setRouterAddress(address newRouter) public onlyOwner() {
        IPancakeV2Router02 _newPancakeRouter = IPancakeV2Router02(newRouter);
        // create the pair if it doesn't exist yet
        if (IPancakeV2Factory(_newPancakeRouter.factory()).getPair(address(this), _newPancakeRouter.WETH()) == address(0)) {
            pancakeV2Pair = IPancakeV2Factory(_newPancakeRouter.factory()).createPair(address(this), _newPancakeRouter.WETH());
        } else {
            pancakeV2Pair = IPancakeV2Factory(_newPancakeRouter.factory()).getPair(address(this), _newPancakeRouter.WETH());
        }
        pancakeV2Router = _newPancakeRouter;
    }

    function getInfluRewardsPercent() public view returns (uint256) {
        return _influRewardsPercentOnTFee;
    }

    function setInfluRewardsPercent(uint256 percent) public onlyOwner() {
        require(percent <= 100, "Max 100%");
        _influRewardsPercentOnTFee = percent;
    }

     /* Referal functions
     * 
     * addInfluencer: reference an influencer by the owner
     * registerMember: for member to register with their influencer address in parameter -> burn amount will be divided by 2 (see changes in function _getTBasics)
     * registerMemberByOwner: owner can register a member in case member has trouble doing it by himself
     * totalMembersForInfluencer: returns the number of members referenced by an influencer address in parameter
     * isMember: checks if address is member, for internal calls
     * getInfluencerForMember: returns the influencer address for a member sent in parameter
     * 
     * Note: using standard arithmetic operators, SafeMath is not reqired anymore from Solidity 0.8
     * 
     */

    function registerMember(address _influencer) external {
        require(!isMember(_msgSender()), "Member already registered");
        _members[_msgSender()] = _influencer;
        _influencers[_influencer] += 1;
    }

    function registerMemberByOwner(address _member, address _influencer) external onlyOwner() {
        require(!isMember(_member), "Member already registered");
        _members[_member] = _influencer;
        _influencers[_influencer] += 1;
    }

    function totalMembersForInfluencer(address _influencer) external view returns (int) {
        return _influencers[_influencer];
    }

    function isMember(address _member) public view returns (bool) {
        if (_members[_member] == address(0)) return false;
        return true;
    }

    function getInfluencerForMember(address _member) public view returns (address) {
        return _members[_member];
    }

    function getTxCountAffiliateMember(address _address) public view returns (uint256) {
        return txAmountMember[_address];
    }

    function setIsAffilationEnabled(bool isEnabled) public onlyOwner() {
        _affilationEnabled = isEnabled;
    }
}