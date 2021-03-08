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

// File: contracts\BSN.sol

pragma solidity ^0.6.9;





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
    uint _busdPerBeth
  ) external;
  function getMarketToTalMoney () external view returns(uint);
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
    function win(uint _amount, address _user,uint _id) external;
    function fail (uint _id) external;
    function getUserInfo (address _user) external view returns(
    address userAddress,
    uint[] memory records,
    uint marketProvide,
    bool isMarker
  );
  function addPoolMoney (address _user, uint _amount) external;
  function withdrawPoolMoney (address _user, uint _amount, uint _trueAmount)  external;
  function getCurCycleData () external view returns(
    uint[] memory _recordIds,
    uint totalInvest,
    uint totalPay,
    uint marketAdd,
    uint dayMarketTotal
  );
  function getCurDayStartBlock () external view returns(uint);
  function changeCycle(uint _block, uint _dayMarketTotal) external;
  function transferPool(uint _amount) external;
  function getCurDayNum () external view returns(uint);
}
contract BSN is Ownable {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;
  
  address factory;
  address public BETH;
  address public BUSD;
  address public windToken;
  address public oracle;
  uint public BUSDDecimals;
  uint public windTokenDecimals;
  address public BSNData;
  // uint public singleInvestAmount;
  uint[] public marketTypeIds;
  struct MarketType{
    uint minute;
    uint duration;
    uint minAmount;
    uint maxAmount;
    mapping(uint => uint) singleMarketInvest;
    bool isExist;
  }
  uint up = 1;
  uint down = 0;
  mapping(uint => MarketType) public marketTypes;
  mapping(uint => mapping(uint => uint)) dayMinuteNum;
  mapping (address => bool) private accessAllowed;
  event AccessAllowedAddress(address indexed _addr, bool _access);
  event SetPairAddress(address _BETH, address _BUSD);
  event SetFactoryAddress(address _old, address _new);
  event SetOracleAddress(address _old, address _new);
  event SetBSNDataAddress(address _old, address _new);
  event SetWindTokenAddress(address _old, address _new);
  event Invest(address _user, uint _startBlock, uint _openBlock);
  constructor (address _BSNData,address _oracle, address _factory, address _BETH, address _BUSD, address _windToken) public {
    BSNData = _BSNData;
    oracle = _oracle;
    factory = _factory;
    BETH = _BETH;
    BUSD = _BUSD;
    BUSDDecimals = IERC20(BUSD).decimals();
    windToken = _windToken;
    windTokenDecimals = IERC20(windToken).decimals();
    // singleInvestAmount = 100 * (10 ** BUSDDecimals);
  }
  
  /* 
   * 验证 accessAllowed 权限
  */   
  modifier platform() {
    require(accessAllowed[msg.sender] == true, 'no access');
    _;
  }
   /* 添加 accessAllowed 权限
  */ 
  function allowAccess(address _addr) onlyOwner public {
    accessAllowed[_addr] = true;
    emit AccessAllowedAddress(_addr, true);
  }
   /* 
   * 删除 accessAllowed 权限
  */ 
  function denyAccess(address _addr) onlyOwner public {
    accessAllowed[_addr] = false;
    emit AccessAllowedAddress(_addr, false);
  }
  function setPairAddress(address _BETH, address _BUSD) onlyOwner public {
    BETH = _BETH;
    BUSD = _BUSD;
    BUSDDecimals = IERC20(BUSD).decimals();
    // singleInvestAmount = 100 * (10 ** BUSDDecimals);
    emit SetPairAddress(BETH, BUSD);
  }
  function setFactoryAddress(address _factory) onlyOwner public {
    emit SetFactoryAddress(factory, _factory);
    factory = _factory;
  }
  function setOracleAddress(address _oracle) onlyOwner public {
    emit SetOracleAddress(oracle, _oracle);
    oracle = _oracle;
  }
  function setBSNDataAddress(address _BSNData) onlyOwner public {
    emit SetBSNDataAddress(BSNData, _BSNData);
    BSNData = _BSNData;
  }
  function setWindTokenAddress(address _windToken) onlyOwner public {
    emit SetWindTokenAddress(windToken, _windToken);
    windToken = _windToken;
    windTokenDecimals = IERC20(windToken).decimals();
  }
  function addMarketType(uint _minute, uint _duration, uint _minAmount, uint _maxAmount, uint _singleMarketInvest) onlyOwner public{
    require(_maxAmount > _minAmount);
    if (!marketTypes[_minute].isExist) {
      marketTypeIds.push(_minute);
      marketTypes[_minute].isExist = true;
    }
    uint dayNum = IBSNInterface(BSNData).getCurDayNum();
    marketTypes[_minute].minute = _minute;
    marketTypes[_minute].duration = _duration;
    marketTypes[_minute].minAmount = _minAmount.mul(10 ** BUSDDecimals);
    marketTypes[_minute].maxAmount = _maxAmount.mul(10 ** BUSDDecimals);
    marketTypes[_minute].singleMarketInvest[dayNum] = _singleMarketInvest.mul(10 ** BUSDDecimals);
  }
  function invest(uint _investType, uint _minute, uint _investAmount) public {
    require(marketTypes[_minute].isExist);
    require(_investAmount >= marketTypes[_minute].minAmount);
    require(_investAmount <= marketTypes[_minute].maxAmount);
    require(_investType == up || _investType == down);
    uint curDayAmount = getCurCycleIncome();
    uint marketInvest = IBSNInterface(BSNData).getMarketToTalMoney();
    if (marketInvest > curDayAmount) {
       require(marketInvest.sub(curDayAmount) < marketInvest.mul(10).div(100));
    }
    changeCycle(block.number);
    // require(_investAmount <= marketTypes[_minute].minute.mul(singleInvestAmount));
    IERC20(BUSD).safeTransferFrom(msg.sender, BSNData, _investAmount);
    uint dayNum = IBSNInterface(BSNData).getCurDayNum();
    dayMinuteNum[dayNum][_minute] = dayMinuteNum[dayNum][_minute].add(_investAmount);
    uint price = getEthUsd();
    uint openBlock = marketTypes[_minute].duration.add(block.number);
    IBSNInterface(BSNData).invest(msg.sender, uint(_investType), _minute, _investAmount, block.number, block.timestamp, openBlock ,price);
    emit Invest(msg.sender, block.number, openBlock);
  }
  function changeCycle (uint _block) private {
    uint curBlock = IBSNInterface(BSNData).getCurDayStartBlock();
    if (_block >= curBlock.add(28800)) {
      uint curDayAmount = getCurCycleIncome();
      uint marketInvest = IBSNInterface(BSNData).getMarketToTalMoney();
      uint dayNum = IBSNInterface(BSNData).getCurDayNum();
      for(uint i = 0; i < marketTypeIds.length; i++) {
        uint total = dayMinuteNum[dayNum][marketTypeIds[i]];
        if (total > marketTypes[marketTypeIds[i]].singleMarketInvest[dayNum].mul(24)){
          marketTypes[marketTypeIds[i]].singleMarketInvest[dayNum.add(1)] = marketTypes[marketTypeIds[i]].singleMarketInvest[dayNum].add(10000 * 10 ** BUSDDecimals);
        }
        if (marketInvest > curDayAmount && marketInvest.sub(curDayAmount) > marketInvest.mul(5).div(100)) {
          marketTypes[marketTypeIds[i]].singleMarketInvest[dayNum.add(1)] = marketTypes[marketTypeIds[i]].singleMarketInvest[dayNum].div(2);
        }
      }
      uint _dayMarketTotal;
      uint amount;
      if (curDayAmount < marketInvest) {
         _dayMarketTotal = curDayAmount;
         amount = marketInvest.sub(curDayAmount);
      } else {
        _dayMarketTotal = marketInvest;
        amount = curDayAmount.sub(marketInvest);
        if (amount > 0) {
          IBSNInterface(BSNData).transferPool(amount);
        }
      }
       if (dayNum <= 60) {
          uint amountMarket = marketInvest.div(100);
          amount = amount > amountMarket ? amount : amountMarket;  
       }
       uint windTokenAmount = amount.mul(100).mul(10 ** windTokenDecimals).div(10 ** BUSDDecimals);
      IWindToken(windToken).mint(BSNData, windTokenAmount);
      IBSNInterface(BSNData).changeCycle(_block, _dayMarketTotal);
    }
  }
  function openAward (uint _orderId) public {
    (address investor,uint investType,uint minute,uint _investAmount,uint investBlock,,uint openBlock,uint busdPerBeth,uint investDayNum,bool isOpen) = IBSNInterface(BSNData).getOrderById(_orderId);
    require(msg.sender == investor);
    require(!isOpen);
    uint openBlockPrice = getBlockPrice(openBlock);
    require(openBlockPrice > 0);
    (uint upTotal, uint downTotal) = getBlockUpAndDown(investBlock, minute);
    uint singleMarketInvest = marketTypes[minute].singleMarketInvest[investDayNum];
    if (busdPerBeth == openBlockPrice) {
      uint orderId = _orderId;
      IBSNInterface(BSNData).win(_investAmount, msg.sender, orderId);
    }
    if (investType == up) {
      uint orderId = _orderId;
      uint investAmount = _investAmount;
      if(busdPerBeth > openBlockPrice) {
        IBSNInterface(BSNData).fail(orderId);
        uint windTokenAmount = investAmount.mul(20).mul(10 ** windTokenDecimals).div(10 ** BUSDDecimals);
        IWindToken(windToken).mint(msg.sender, windTokenAmount);
      } 
      if(busdPerBeth < openBlockPrice) {
        uint income = investAmount.mul(downTotal.add(singleMarketInvest)).div(upTotal.add(singleMarketInvest)).mul(85).div(100);
        uint back = income.add(investAmount);
        IBSNInterface(BSNData).win(back, msg.sender, orderId);
      }
    } else {
      uint orderId = _orderId;
      uint investAmount = _investAmount;
      if(busdPerBeth > openBlockPrice) {
        uint income = investAmount.mul(upTotal.add(singleMarketInvest)).div(downTotal.add(singleMarketInvest)).mul(85).div(100);
        uint back = income.add(investAmount);
        IBSNInterface(BSNData).win(back, msg.sender, orderId);
      } 
      if(busdPerBeth < openBlockPrice) {
        IBSNInterface(BSNData).fail(orderId);
        uint windTokenAmount = investAmount.mul(20).mul(10 ** windTokenDecimals).div(10 ** BUSDDecimals);
        IWindToken(windToken).mint(msg.sender, windTokenAmount);
      }
    }
  }
  function getWin (uint _orderId) public view returns(bool isWin, uint back){
    (,uint investType,uint minute,uint _investAmount,uint investBlock,,uint openBlock,uint busdPerBeth,uint investDayNum,) = IBSNInterface(BSNData).getOrderById(_orderId);
    uint openBlockPrice = getBlockPrice(openBlock);
    (uint upTotal, uint downTotal) = getBlockUpAndDown(investBlock, minute);
    uint singleMarketInvest = marketTypes[minute].singleMarketInvest[investDayNum];
    uint investAmount = _investAmount;
    if (investType == up && busdPerBeth > openBlockPrice) {
       back = investAmount.mul(20).mul(10 ** windTokenDecimals).div(10 ** BUSDDecimals);
       isWin = false;
    }
    if (investType == up && busdPerBeth < openBlockPrice) {
       uint income = investAmount.mul(downTotal.add(singleMarketInvest)).div(upTotal.add(singleMarketInvest)).mul(85).div(100);
        back = income.add(investAmount);
        isWin = true;
         return (isWin, back);
    }
    if(investType == down && busdPerBeth > openBlockPrice) {
      uint income = investAmount.mul(upTotal.add(singleMarketInvest)).div(downTotal.add(singleMarketInvest)).mul(85).div(100);
      back = income.add(investAmount);
      isWin = true;
    }
    if(investType == down && busdPerBeth < openBlockPrice) {
       back = investAmount.mul(20).mul(10 ** windTokenDecimals).div(10 ** BUSDDecimals);
       isWin = false;
    }
  }
  function addMarketPool(uint _amount) public {
    require(_amount >= 100 * (10 ** BUSDDecimals));
    IERC20(BUSD).safeTransferFrom(msg.sender, BSNData, _amount);
    IBSNInterface(BSNData).addPoolMoney(msg.sender,_amount);
  }
  function markerRedeem (uint _amount) public {
    require(_amount > 0);
     (, , uint marketProvide,) = IBSNInterface(BSNData).getUserInfo(msg.sender);
     require(marketProvide >= _amount);
     uint curDayAmount = getCurCycleIncome();
     uint marketInvest = IBSNInterface(BSNData).getMarketToTalMoney();
     uint trueAmount;
     if (curDayAmount < marketInvest) {
      trueAmount = _amount.mul(marketInvest.sub(curDayAmount)).div(marketInvest);
     } else {
       trueAmount = _amount;
     }
     IBSNInterface(BSNData).withdrawPoolMoney(msg.sender, _amount , trueAmount);
  }
  function getEthUsd () public view returns(uint rate) {
    (address token0,) = UniswapV2Library.sortTokens(BETH, BUSD);
    (uint reserve0, uint reserve1,) = IUniswapV2Pair(IUniswapV2Factory(factory).getPair(BETH, BUSD)).getReserves();
    (uint reserveA, uint reserveB) = BETH == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    rate = reserveB.mul(10**10).div(reserveA);
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
  function getCurCycleIncome ()  public view returns (uint){
    (uint[] memory recordIds,uint totalInvest,uint totalPay,uint marketAdd,uint dayMarketTotal) = IBSNInterface(BSNData).getCurCycleData();
    uint totalWin = 0;
    for(uint i = 0; i < recordIds.length; i++) {
       (,uint investType,uint minute,uint _investAmount,uint investBlock,,uint openBlock,uint busdPerBeth,uint investDayNum,) = IBSNInterface(BSNData).getOrderById(recordIds[i]);
       (uint upTotal, uint downTotal) = getBlockUpAndDown(investBlock, minute);
       uint openBlockPrice = getBlockPrice(openBlock);
       if (openBlockPrice == 0) {
         continue;
       }
       uint back;
       uint singleMarketInvest = marketTypes[minute].singleMarketInvest[investDayNum];
       if (busdPerBeth == openBlockPrice) {
         back = back.add(_investAmount);
       }
       if (investType == up) {
         uint investAmount = _investAmount;
        if(busdPerBeth < openBlockPrice) {
          uint income = investAmount.mul(downTotal.add(singleMarketInvest)).div(upTotal.add(singleMarketInvest)).mul(85).div(100);
          back = income.add(investAmount);
        }
      } else {
      uint investAmount = _investAmount;
      if(busdPerBeth > openBlockPrice) {
        uint income = investAmount.mul(upTotal.add(singleMarketInvest)).div(downTotal.add(singleMarketInvest)).mul(85).div(100);
        back = income.add(investAmount);
      } 
    }
     totalWin = totalWin.add(back);
    }
    uint amount = dayMarketTotal.add(totalInvest).add(marketAdd).sub(totalPay).sub(totalWin);
    return amount;
  }
  function getMarketTypeIds () public view returns(uint[] memory _marketTypeIds) {
    return marketTypeIds;
  }
}
