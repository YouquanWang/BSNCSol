// File: @openzeppelin\contracts\math\SafeMath.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

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

// File: node_modules\@openzeppelin\contracts\GSN\Context.sol



pragma solidity ^0.6.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin\contracts\access\Ownable.sol



pragma solidity ^0.6.0;

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

// File: @openzeppelin\contracts\token\ERC20\IERC20.sol



pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint);
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



// File: node_modules\@openzeppelin\contracts\utils\Address.sol



pragma solidity ^0.6.2;

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
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
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

// File: @openzeppelin\contracts\token\ERC20\SafeERC20.sol



pragma solidity ^0.6.0;




/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// File: @openzeppelin\contracts\utils\ReentrancyGuard.sol



pragma solidity ^0.6.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}




interface IUniswapV2Pair {
  function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}
interface IUniswapV2Factory {
  function getPair(address tokenA, address tokenB) external view returns (address pair);
}
library UniswapV2Library {
    using SafeMath for uint;
    function sortTokens(address tokenA, address tokenB) public pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'ZERO_ADDRESS');
    }
}
interface IOracle {
  function getMarket(uint256 blocknum) external view returns (uint256);
}
interface IWindToken {
  function mint(address _to, uint256 _amount) external returns (bool);
  function totalSupply() external view returns (uint256);
}
interface IBSNInterface {
  function invest(
    address _investor,
    uint _investType,
    uint _minute,
    uint _investAmount,
    uint _investBlock,
    uint _investTime,
    uint _openBlock,
    uint _busdPerBeth,
    address _intro
  ) external returns(bool);
  function getOrderById (uint _id) external view returns (
    address investor,
    uint investType,
    uint minute,
    uint investAmount,
    uint investBlock,
    uint investTime,
    uint openBlock,
    uint busdPerBeth,
    uint dayNum,
    bool isOpen);
    function getBlockRecords(uint _block, uint _minute) external view returns(uint[] memory ids);
    function win(uint _amount, address _user,uint _id, uint _investAmount) external;
    function fail (uint _id, uint _investAmount) external;
    function getUserInfo (address _user) external view returns(
    address userAddress,
    uint[] memory records,
    uint marketProvide,
    bool isMarker,
    address intro,
    uint reward,
    address[] memory children
  );
  function addPoolMoney (address _user, uint _amount, address _intro) external returns(bool);
  function withdrawPoolMoney (address _user, uint _amount)  external returns(uint);
  function getCurCycleData (uint _dayNum) external view returns(
    uint windToken,
    uint totalInvest,
    uint totalPay,
    uint marketAdd,
    uint dayMarketTotal,
    uint marketReduce,
    uint poolAmount,
    uint income,
    uint reduce,
    uint proportion
  );
  function getUserDayMarket (address _user, uint _dayNum) external view returns(uint _marketAmount, uint _trueAmount ,bool _isSet);
  function getCurDayStartBlock () external view returns(uint);
  function changeCycle(uint _dayMarketTotal, uint _windToken) external;
  function transferPool(uint _amount) external;
  function getCurDayNum () external view returns(uint);
  function receiveDividends (address _user, uint amount, uint _dayNum, address _teamAddress, uint _teamAmount) external returns(bool);
  function getIsDividend(address _user, uint _dayNum) external view returns(bool isSet);
  function getDayMinuteNum(uint _dayNum, uint _minute) external view returns(uint _amount);
  function getSingleMarketInvest(uint _minute, uint _dayNum) external view returns(uint _amount);
  function setSingleMarketInvest(uint _minute, uint _dayNum, uint _amount) external;
  function getPoolAddress () external view returns(address[] memory _poolAddress);
  function getProportion () external view returns(uint, uint);
  function setUserReward (address _intro, uint _amount, address _user) external;
  function getPoolRatio () external view returns(uint ratio);
  function getPoolInfo(address _poolAddress) external view returns (uint _ratio, bool _isAdd);
  function getTotalMarketWind () external view returns(uint);
  function withdrawTotalBack (address _user) external;
}

interface IStakeInterface {
  function platformStake(uint256 amount, address _user) external;
}
contract BSN is Ownable, ReentrancyGuard {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;
  
  address factory;  // 交易对工厂地址
  address public BETH; // BETH代币地址
  address public BUSD; // BUSD代币地址
  address public windToken; // windToken代币地址
  address teamAddress; // 团队收币地址
  uint public BUSDDecimals;
  uint public windTokenDecimals;
  uint public dayBlockNum = 28800;
  uint public longTail = 183;
  bool isStop = false;
  address public BSNData; // 数据合约地址
  // uint public singleInvestAmount;
  uint[] public marketTypeIds;
  struct MarketType{
    uint minute;
    uint duration;
    uint minAmount;
    uint maxAmount;
    bool isExist;
  }
  address oracle;
  uint constant up = 1;
  uint constant down = 0;
  uint public addMarketMin;
  uint public addMarketMax;
  bool public isHaveWinUsd = false;
  // uint public failRate = 20;
  uint public successRate = 2;
  uint public incomeRate = 90;
  mapping(uint => MarketType) public marketTypes;
  event SetPairAddress(address _BETH, address _BUSD);
  event SetFactoryAddress(address _old, address _new);
  event SetOracleAddress(address _old, address _new);
  event SetBSNDataAddress(address _old, address _new);
  event SetWindTokenAddress(address _old, address _new);
  event Invest(address indexed _user, uint _startBlock, uint _openBlock);
  event OpenAward(uint _amount, uint _windAmount, uint _orderId, address indexed _user);
  event SetAddMarketLimit(uint _min, uint _max);
  event SetHaveWinUsd(bool _old, bool _new);
  event AddPoolMoney(address indexed _user, uint _amount, uint _dayNum, uint _time);
  event ShareBonus(uint _amount, uint _dayNum, uint _busdAmount);
  event MarkerRedeem(address indexed _user, uint _amount, uint _trueAmount, uint _time, uint _block);
  event SetTeamAddress(address _old, address _new);
  event SetRate(uint _old, uint _new);
  event SetLongTail(uint _old, uint _new);
  event SetDayBlockNum(uint _old, uint _new);
  event SetIsStop(bool _old, bool _new);
  event GetReward(address indexed _user, uint _windToken, uint _time);
  event ReceiveDividends(uint _dayNum, uint _canReceive, address indexed _user);
  event SetIncomeRate(uint _old, uint _new);
  constructor (address _BSNData,address _oracle, address _factory, address _BETH, address _BUSD, address _windToken, address _teamAddress) public {
    BSNData = _BSNData;
    oracle = _oracle;
    factory = _factory;
    BETH = _BETH;
    BUSD = _BUSD;
    teamAddress = _teamAddress;
    BUSDDecimals = IERC20(BUSD).decimals();
    windToken = _windToken;
    windTokenDecimals = IERC20(windToken).decimals();
    addMarketMin = 10000 * (10 ** BUSDDecimals);
    addMarketMax = 1000000 * (10 ** BUSDDecimals);
  }
  
  function setHaveWinUsd (bool _have) onlyOwner external {
    emit SetHaveWinUsd(isHaveWinUsd, _have);
    isHaveWinUsd = _have;
  }
  function setIsStop (bool _stop) onlyOwner external {
    emit SetIsStop(isStop, _stop);
    isStop = _stop;
  }
  modifier stop () {
    require(isStop == false, 'is stop');
    _;
  }
  function setDayBlockNum (uint _dayBlockNum) onlyOwner external {
    emit SetDayBlockNum(dayBlockNum, _dayBlockNum);
    dayBlockNum = _dayBlockNum;
  }
  function setPairAddress(address _BETH, address _BUSD) onlyOwner external {
    BETH = _BETH;
    BUSD = _BUSD;
    BUSDDecimals = IERC20(BUSD).decimals();
    // singleInvestAmount = 100 * (10 ** BUSDDecimals);
    emit SetPairAddress(BETH, BUSD);
  }
  function setFactoryAddress(address _factory) onlyOwner external {
    emit SetFactoryAddress(factory, _factory);
    factory = _factory;
  }
  function setTeamAddress(address _teamAddress) onlyOwner external {
    emit SetTeamAddress(teamAddress, _teamAddress);
    teamAddress = _teamAddress;
  }
  function setOracleAddress(address _oracle) onlyOwner external {
    emit SetOracleAddress(oracle, _oracle);
    oracle = _oracle;
  }
  function setBSNDataAddress(address _BSNData) onlyOwner external {
    emit SetBSNDataAddress(BSNData, _BSNData);
    BSNData = _BSNData;
  }
  function setAddMarketLimit(uint _min, uint _max) onlyOwner external {
    require(_max > _min);
    emit SetAddMarketLimit(_min, _max);

    addMarketMin = _min.mul(10 ** BUSDDecimals);
    addMarketMax = _max.mul(10 ** BUSDDecimals);
  }
  function setLongTail(uint _longTail) onlyOwner external {
    emit SetLongTail(longTail, _longTail);
    longTail = _longTail;
  }
  function setRate(uint _successRate) onlyOwner external {
    emit SetRate(successRate, _successRate);
    successRate = _successRate;
  }
  function setIncomeRate(uint _incomeRate) onlyOwner external {
    emit SetIncomeRate(incomeRate, _incomeRate);
    incomeRate = _incomeRate;
  }
  function setWindTokenAddress(address _windToken) onlyOwner external {
    emit SetWindTokenAddress(windToken, _windToken);
    windToken = _windToken;
    windTokenDecimals = IERC20(windToken).decimals();
  }
  function addMarketType(uint _minute, uint _duration, uint _minAmount, uint _maxAmount, uint _dayNum, uint _singleMarketInvest) onlyOwner external{
    require(_maxAmount > _minAmount);
    if (!marketTypes[_minute].isExist) {
      marketTypeIds.push(_minute);
      marketTypes[_minute].isExist = true;
    }
    marketTypes[_minute].minute = _minute;
    marketTypes[_minute].duration = _duration;
    marketTypes[_minute].minAmount = _minAmount.mul(10 ** BUSDDecimals);
    marketTypes[_minute].maxAmount = _maxAmount.mul(10 ** BUSDDecimals);
    IBSNInterface(BSNData).setSingleMarketInvest(_minute, _dayNum, _singleMarketInvest.mul(10 ** BUSDDecimals));
  }
  function invest(uint _investType, uint _minute, uint _investAmount, address _intro) external stop nonReentrant {
    require(marketTypes[_minute].isExist);
    require(_investAmount >= marketTypes[_minute].minAmount);
    require(_investAmount <= marketTypes[_minute].maxAmount);
    require(_investType == up || _investType == down);
    (uint curDayAmount, uint curDayMarketTotal) = getCurCycleIncome();
    if (curDayMarketTotal > curDayAmount) {
       require(curDayMarketTotal.sub(curDayAmount) < curDayMarketTotal.mul(10).div(100));
    }
    // require(_investAmount <= marketTypes[_minute].minute.mul(singleInvestAmount));
    IERC20(BUSD).safeTransferFrom(msg.sender, BSNData, _investAmount);
    uint price = getEthUsd();
    uint openBlock = marketTypes[_minute].duration.add(block.number);
    bool isSet = IBSNInterface(BSNData).invest(msg.sender, uint(_investType), _minute, _investAmount, block.number, block.timestamp, openBlock ,price, _intro);
    emit Invest(msg.sender, block.number, openBlock);
    if(isSet) {
      changeCycle(block.number);
    }
  }
  function changeCycle (uint _block) private {
    uint curBlock = IBSNInterface(BSNData).getCurDayStartBlock();
    if (_block >= curBlock.add(dayBlockNum)) {
      (uint curDayAmount, uint curDayMarketTotal) = getCurCycleIncome();
      uint dayNum = IBSNInterface(BSNData).getCurDayNum();
      for(uint i = 0; i < marketTypeIds.length; i++) {
        uint total = IBSNInterface(BSNData).getDayMinuteNum(dayNum, marketTypeIds[i]);
        uint singleMarketInvest = IBSNInterface(BSNData).getSingleMarketInvest(marketTypeIds[i], dayNum);
        IBSNInterface(BSNData).setSingleMarketInvest(marketTypeIds[i], dayNum.add(1), singleMarketInvest);
        if (total > singleMarketInvest.mul(24)){
          uint limitAmount = curDayMarketTotal.mul(20).div(100).div(marketTypeIds.length) > singleMarketInvest.add(5000 * (10 ** BUSDDecimals)) ? singleMarketInvest.add(5000 * (10 ** BUSDDecimals)) : curDayMarketTotal.mul(20).div(100).div(marketTypeIds.length);
          IBSNInterface(BSNData).setSingleMarketInvest(marketTypeIds[i], dayNum.add(1), limitAmount);
        }
        if (curDayMarketTotal > curDayAmount && curDayMarketTotal.sub(curDayAmount) > curDayMarketTotal.mul(5).div(100)) {
         IBSNInterface(BSNData).setSingleMarketInvest(marketTypeIds[i], dayNum.add(1), singleMarketInvest.div(2));
        }
      }
      uint _dayMarketTotal;
      uint amount;
      uint busdAmount;
      if (curDayAmount <= curDayMarketTotal) {
         _dayMarketTotal = curDayAmount;
         amount = curDayMarketTotal.sub(curDayAmount).div(2);
      } else {
        _dayMarketTotal = curDayMarketTotal;
        amount = curDayAmount.sub(_dayMarketTotal).div(2);
        busdAmount = curDayAmount.sub(curDayMarketTotal);
        IBSNInterface(BSNData).transferPool(busdAmount);
      }
       if (dayNum <= 3) {
          uint amountMarket = curDayMarketTotal.div(100);
          amount = amount > amountMarket ? amount : amountMarket;
       }
       uint windTokenAmount = isHaveWinUsd ? amount.mul(getPerUsdtWind()).mul(10 ** windTokenDecimals).div(10 ** BUSDDecimals).div(10 ** 10) : amount.mul(100).mul(10 ** windTokenDecimals).div(10 ** BUSDDecimals);
       if (dayNum > longTail) {
         uint totalWindToken = IWindToken(windToken).totalSupply();
         uint fission = dayNum.sub(longTail).div(90);
         windTokenAmount = windTokenAmount > totalWindToken.div(100).div(2 ** fission) ? totalWindToken.div(100).div(2 ** fission) : windTokenAmount;
       }
       uint teamAmount = windTokenAmount.div(9);
       IWindToken(windToken).mint(teamAddress, teamAmount);
       IWindToken(windToken).mint(BSNData, windTokenAmount);
      IBSNInterface(BSNData).changeCycle(_dayMarketTotal, windTokenAmount);
      emit ShareBonus(windTokenAmount, dayNum, busdAmount);
    }
  }
  function openAward (uint _orderId) external nonReentrant {
    (address investor,,,uint investAmount,,,uint openBlock,,,bool isOpen) = IBSNInterface(BSNData).getOrderById(_orderId);
    require(msg.sender == investor);
    require(!isOpen);
    uint openBlockPrice = getBlockPrice(openBlock);
    require(openBlockPrice > 0);
    (uint back, uint winTokenAmount) = getWin(_orderId);
    if (back > 0) {
      IBSNInterface(BSNData).win(back, msg.sender, _orderId, investAmount);
    } else {
      IBSNInterface(BSNData).fail(_orderId, investAmount);
    }
    uint teamAmount = 0;
    uint introAmount = 0;
    if (winTokenAmount > 0) {
      (,,,,address intro,,) = IBSNInterface(BSNData).getUserInfo(msg.sender);
      uint dayNum = IBSNInterface(BSNData).getCurDayNum();
      if (intro != address(0)) {
        (,,,,,uint introReward,) = IBSNInterface(BSNData).getUserInfo(intro);
        introAmount = winTokenAmount.div(2);
        IBSNInterface(BSNData).setUserReward(intro, introReward.add(introAmount), msg.sender);
       }
       teamAmount = (winTokenAmount.add(introAmount)).div(9);
       IWindToken(windToken).mint(teamAddress, teamAmount);
       if (dayNum <= 3) {
         _stakePool(winTokenAmount, msg.sender);
       } else {
         IWindToken(windToken).mint(msg.sender, winTokenAmount); 
       }
    }
    emit OpenAward(back, winTokenAmount, _orderId, msg.sender);
    changeCycle(block.number);
  }
  function getReward () external nonReentrant {
     (,,,,, uint reward,) = IBSNInterface(BSNData).getUserInfo(msg.sender);
     require(reward > 0);
     IBSNInterface(BSNData).setUserReward(msg.sender,0, address(0));
     IWindToken(windToken).mint(msg.sender, reward); 
     emit GetReward(msg.sender, reward, block.timestamp);
  }
  function getWin (uint _orderId) public view returns(uint back, uint winTokenAmount){
    (,uint investType,uint minute,uint _investAmount,uint investBlock,,uint openBlock,uint busdPerBeth,uint investDayNum,) = IBSNInterface(BSNData).getOrderById(_orderId);
    uint openBlockPrice = getBlockPrice(openBlock);
    (uint upTotal, uint downTotal) = getBlockUpAndDown(investBlock, minute);
    uint singleMarketInvest = IBSNInterface(BSNData).getSingleMarketInvest(minute, investDayNum);
    uint investAmount = _investAmount;
    if (busdPerBeth == openBlockPrice) {
      back = investAmount;
      winTokenAmount = 0;
    }
    if (investType == up && busdPerBeth > openBlockPrice) {
      //  winTokenAmount = isHaveWinUsd ? investAmount.mul(failRate).mul(getPerUsdtWind()).mul(10 ** windTokenDecimals).div(10 ** BUSDDecimals).div(10 ** 12) : investAmount.mul(failRate).mul(10 ** windTokenDecimals).div(10 ** BUSDDecimals);
       back = 0;
       winTokenAmount= 0;
    }
    if (investType == up && busdPerBeth < openBlockPrice) {
        back = investAmount.mul(downTotal.add(singleMarketInvest)).mul(incomeRate).div(upTotal.add(singleMarketInvest)).div(100).add(investAmount);
        winTokenAmount = isHaveWinUsd ? investAmount.mul(successRate).mul(getPerUsdtWind()).mul(10 ** windTokenDecimals).div(10 ** BUSDDecimals).div(10 ** 12) : investAmount.mul(successRate).mul(10 ** windTokenDecimals).div(10 ** BUSDDecimals);
    }
    if(investType == down && busdPerBeth > openBlockPrice) {
       back = investAmount.mul(upTotal.add(singleMarketInvest)).mul(incomeRate).div(downTotal.add(singleMarketInvest)).div(100).add(investAmount);
       winTokenAmount = isHaveWinUsd ? investAmount.mul(successRate).mul(getPerUsdtWind()).mul(10 ** windTokenDecimals).div(10 ** BUSDDecimals).div(10 ** 12) : investAmount.mul(successRate).mul(10 ** windTokenDecimals).div(10 ** BUSDDecimals);
    }
    if(investType == down && busdPerBeth < openBlockPrice) {
      //  winTokenAmount = isHaveWinUsd ? investAmount.mul(failRate).mul(getPerUsdtWind()).mul(10 ** windTokenDecimals).div(10 ** BUSDDecimals).div(10 ** 12) : investAmount.mul(failRate).mul(10 ** windTokenDecimals).div(10 ** BUSDDecimals);
       winTokenAmount = 0;
       back = 0;
    }
  }
  function addMarketPool(uint _amount, address _intro) external nonReentrant {
    require(_amount >= addMarketMin);
    require(_amount <= addMarketMax);
    IERC20(BUSD).safeTransferFrom(msg.sender, BSNData, _amount);
    bool isSet = IBSNInterface(BSNData).addPoolMoney(msg.sender,_amount,_intro);
    uint dayNum = IBSNInterface(BSNData).getCurDayNum();
    emit AddPoolMoney(msg.sender, _amount, dayNum, block.timestamp);
    if (isSet) {
      changeCycle(block.number);
    }
  }
  function markerRedeem (uint _amount) external nonReentrant {
     require(_amount > 0);
     uint trueAmount = IBSNInterface(BSNData).withdrawPoolMoney(msg.sender, _amount);
     emit MarkerRedeem(msg.sender, _amount, trueAmount, block.timestamp, block.number);
  }
  function receiveDividends (uint _dayNum) external nonReentrant {
    bool isSetDividend = IBSNInterface(BSNData).getIsDividend(msg.sender, _dayNum);
    require(!isSetDividend);
    uint _canReceive = getDividends(_dayNum);
    bool isSet = IBSNInterface(BSNData).receiveDividends(msg.sender, _canReceive, _dayNum, teamAddress, 0);
    emit ReceiveDividends(_dayNum, _canReceive, msg.sender);
    if (isSet) {
      changeCycle(block.number);
    }
  }
  function withdrawTotalBack () external {
    IBSNInterface(BSNData).withdrawTotalBack(msg.sender);
  }
  function getDividends (uint _dayNum) public view returns(uint canReceive) {
    uint dayNum = IBSNInterface(BSNData).getCurDayNum();
    require(_dayNum < dayNum);
    require(_dayNum >= 1);
    (,uint denominator) = IBSNInterface(BSNData).getProportion();
    (uint dayMarketProvide,,bool isSet)= IBSNInterface(BSNData).getUserDayMarket(msg.sender, _dayNum);
    if (!isSet) {
      for (uint i = _dayNum; i >= 1; i--) {
        (uint _dayMarketProvide,,bool _isSet) = IBSNInterface(BSNData).getUserDayMarket(msg.sender, i);
        if (_isSet) {
          dayMarketProvide = _dayMarketProvide;
          break;
        }
      }
    }
    (uint _windToken,,uint _marketToTalMoney,,,,,,,uint proportion) = IBSNInterface(BSNData).getCurCycleData(_dayNum);
    dayMarketProvide = dayMarketProvide.mul(proportion).div(denominator);
    canReceive = _marketToTalMoney > 0 ? _windToken.mul(dayMarketProvide).div(_marketToTalMoney) : 0;
  }
  function getEthUsd () public view returns(uint rate) {
    (address token0,) = UniswapV2Library.sortTokens(BETH, BUSD);
    (uint reserve0, uint reserve1,) = IUniswapV2Pair(IUniswapV2Factory(factory).getPair(BETH, BUSD)).getReserves();
    (uint reserveA, uint reserveB) = BETH == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    rate = reserveB.mul(10**10).div(reserveA);
  }
  function getPerUsdtWind () public view returns(uint rate) {
    (address token0,) = UniswapV2Library.sortTokens(BUSD, windToken);
    (uint reserve0, uint reserve1,) = IUniswapV2Pair(IUniswapV2Factory(factory).getPair(BUSD, windToken)).getReserves();
    (uint reserveA, uint reserveB) = BUSD == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    rate = reserveB.mul(10 ** BUSDDecimals).mul(10 ** 10).div(reserveA).div(windTokenDecimals);
  }
  function getBlockUpAndDown (uint _block, uint _minute) public view returns(uint upTotal, uint downTotal) {
    uint[] memory records = IBSNInterface(BSNData).getBlockRecords(_block, _minute);
    uint _upTotal = 0;
    uint _downTotal = 0;
    for(uint i = 0; i < records.length; i++) {
      (,uint investType,,uint investAmount,,,,,,) = IBSNInterface(BSNData).getOrderById(records[i]);
      if (investType == up) {
        _upTotal = _upTotal.add(investAmount);
      } else {
        _downTotal = _downTotal.add(investAmount);
      }
    }
    return (_upTotal, _downTotal);
  }
  function getBlockPrice(uint _block) public view returns(uint price) {
    uint _price = IOracle(oracle).getMarket(_block);
    return _price;
  }
  function getCurCycleIncome ()  public view returns (uint curAmount, uint curDayMarketTotal){
    uint dayNum = IBSNInterface(BSNData).getCurDayNum();
    (,,,uint marketAdd, uint dayMarketTotal, uint marketReduce,,uint income,uint reduce,uint proportion) = IBSNInterface(BSNData).getCurCycleData(dayNum);
    (,,,,,,,,,uint proportionYes) = IBSNInterface(BSNData).getCurCycleData(dayNum.sub(1));
    curAmount = dayMarketTotal.add(income).add(marketAdd.mul(proportion).div(proportionYes)).sub(reduce).sub(marketReduce);
    curDayMarketTotal = dayMarketTotal.add(marketAdd.mul(proportion).div(proportionYes)).sub(marketReduce);
  }
  function getMarketTypeIds () external view returns(uint[] memory _marketTypeIds) {
    return marketTypeIds;
  }
  function _stakePool (uint256 amount, address _user) private {
    address[] memory poolAddress = IBSNInterface(BSNData).getPoolAddress();
    uint ratio = IBSNInterface(BSNData).getPoolRatio();
    for(uint i = 0; i<poolAddress.length; i++) {
      (uint _ratio,) = IBSNInterface(BSNData).getPoolInfo(poolAddress[i]);
      IStakeInterface(poolAddress[i]).platformStake(amount.mul(_ratio).div(ratio), _user);
      IWindToken(windToken).mint(poolAddress[i], amount.mul(_ratio).div(ratio));
    }
  }
}