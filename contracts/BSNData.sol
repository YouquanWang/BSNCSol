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

interface IStakeInterface {
  function platformStake(uint256 amount, address _user) external;
  function setOpen() external;
}
contract BSNData is Ownable {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;
  
  uint public orderId = 1;
  uint public dayNum = 1;
  uint private proportion = 10**18;
  uint public constant denominator = 10**18;
  uint public curDayStartBlock;
  uint public totalPool = 0;
  uint public totalMarketWind = 0;
  address public windToken;
  address public BUSD;
  uint public BUSDDecimals;
  mapping(uint => mapping(uint => uint)) public dayMinuteNum;
  mapping(address => mapping(uint => bool)) public isDividend;
  mapping(uint => mapping(uint => uint)) public singleMarketInvest;
  struct Cycle {
    uint startBlock;
    uint endBlock;
    uint windToken; // 当天发的wintoken总量
    uint totalInvest;
    uint endMarketToTal; // 当天做市商总量
    uint marketAdd;
    uint poolAmount;
    uint marketReduce;
    uint income;
    uint reduce;
    uint dayMarketTotal; // 当天做市商初始余额
    uint proportion;
    bool isEnd;
  }
  mapping(uint => Cycle) cycles;
  address[] poolAddress;
  struct Pool {
    uint ratio;
    address pool;
    bool isAdd;
  }
  mapping(address => Pool) public pools;
  struct User{
    address userAddress;
    address intro;
    uint[] records;
    address[] children;
    uint marketProvide;
    uint back;
    bool isMarker;
    uint reward;
  }
  mapping(address => User) public users;
  struct Record{
    address investor;
    uint investType;
    uint minute;
    uint investAmount;
    uint investBlock;
    uint investTime;
    uint openBlock;
    uint busdPerBeth;
    uint investDayNum;
    bool isOpen;
  }
  mapping(uint => Record) records;
  uint[] recordIds;
  address[] marketers;
  struct BlockInfo{
    uint[] records;
    bool isExist;
  }
  mapping(uint => mapping(uint => BlockInfo)) blocks;
  mapping(uint => mapping(uint => bool)) blockIsInvests;
  struct UserDayMarket{
    uint amount;
    uint trueAmount;
    uint proportion;
    bool isSet;
    bool isBack;
  }
  mapping(address => mapping(uint => UserDayMarket)) userDayMarkets;
  /* 
   * accessAllowed
   * 调用合约权限设置
  */   
  mapping (address => bool) private accessAllowed;

  event AccessAllowedAddress(address indexed _addr, bool _access);
  event SetBUSDAddress(address _old, address _new);
  event SetPool(address _old, uint _ratio);
  event SetWindTokenAddress(address _old, address _new);
  event SetUserReward(address indexed _user, address indexed _intro, uint _introAmount, uint _time);
  constructor (address _BUSD, address _windToken, uint firstAmount) public {
    curDayStartBlock = block.number;
    BUSD = _BUSD;
    windToken = _windToken;
    BUSDDecimals = IERC20(BUSD).decimals();
    cycles[dayNum.sub(1)].proportion = proportion;
    Cycle memory _cycles = cycles[dayNum];
    _cycles.startBlock = curDayStartBlock;
    _cycles.proportion = proportion;
    _cycles.dayMarketTotal = firstAmount.mul(10 ** BUSDDecimals);
    cycles[dayNum] = _cycles;
    _addUser(msg.sender);
    users[msg.sender].marketProvide = firstAmount.mul(10 ** BUSDDecimals).mul(denominator).div(proportion);
    users[msg.sender].isMarker = true;
    userDayMarkets[msg.sender][dayNum].isSet = true;
    userDayMarkets[msg.sender][dayNum].amount = users[msg.sender].marketProvide;
    marketers.push(msg.sender); 
  }
  /* 
   * 验证 accessAllowed 权限
  */   
  modifier platform() {
    require(accessAllowed[msg.sender] == true, 'no access');
    _;
  }
   function setWindTokenAddress(address _windToken) onlyOwner external {
    emit SetWindTokenAddress(windToken, _windToken);
    windToken = _windToken;
  }
   /* 添加 accessAllowed 权限
  */ 
  function allowAccess(address _addr) onlyOwner external {
    accessAllowed[_addr] = true;
    emit AccessAllowedAddress(_addr, true);
  }
   /* 
   * 删除 accessAllowed 权限
  */ 
  function denyAccess(address _addr) onlyOwner external {
    accessAllowed[_addr] = false;
    emit AccessAllowedAddress(_addr, false);
  }
  function setBUSDAddress(address _BUSD) onlyOwner external {
    emit SetBUSDAddress(BUSD, _BUSD);
    BUSD = _BUSD;
    BUSDDecimals = IERC20(BUSD).decimals();
  }
  function setPool(address _pool, uint _ratio) onlyOwner external {
    require(pools[_pool].isAdd);
    pools[_pool].pool = _pool;
    pools[_pool].ratio = _ratio;
    emit SetPool(_pool, _ratio);
  }
  function addPool(address _pool, uint _ratio) onlyOwner external {
    require(!pools[_pool].isAdd);
    pools[_pool].pool = _pool;
    pools[_pool].ratio = _ratio;
    pools[_pool].isAdd = true;
    poolAddress.push(_pool);
    emit SetPool(_pool, _ratio);
  }
  function getPoolRatio () public view returns(uint ratio) {
    for (uint i=0; i < poolAddress.length; i++) {
      ratio = ratio.add(pools[poolAddress[i]].ratio);
    }
  }
  function getPoolAddress () external view returns(address[] memory _poolAddress) {
    return poolAddress;
  }
  function getPoolInfo(address _poolAddress) external view returns (uint _ratio, bool _isAdd) {
    return (pools[_poolAddress].ratio, pools[_poolAddress].isAdd);
  }
  function getOrderById (uint _id) external view returns (
    address investor,
    uint investType,
    uint minute,
    uint investAmount,
    uint investBlock,
    uint investTime,
    uint openBlock,
    uint busdPerBeth,
    uint investDayNum,
    bool isOpen){
      Record memory _record = records[_id];
     return (
        _record.investor,
        _record.investType,
        _record.minute,
        _record.investAmount,
        _record.investBlock,
        _record.investTime,
        _record.openBlock,
        _record.busdPerBeth,
        _record.investDayNum,
        _record.isOpen
     );
  }
  function getTotalMarketWind () external view returns(uint){
    return totalMarketWind;
  }
  function getBlockRecords(uint _block, uint _minute) external view returns(uint[] memory ids) {
    return blocks[_block][_minute].records;
  }
  function getUserDayMarket (address _user, uint _dayNum) external view returns(uint _marketAmount, uint _trueAmount, bool _isSet) {
    return (userDayMarkets[_user][_dayNum].amount, userDayMarkets[_user][_dayNum].trueAmount, userDayMarkets[_user][_dayNum].isSet);
  }
  function getCurDayNum () external view returns(uint) {
    return dayNum;
  }
  function getAllrecord () external view returns(uint[] memory _recordIds){
    return recordIds;
  }
  function setUserReward (address _intro, uint _amount, address _user) external platform {
    if (_user != address(0)) {
      emit SetUserReward(_user, _intro, _amount.sub(users[_intro].reward), block.timestamp);
    }
    users[_intro].reward = _amount;
  }
  function getUserInfo (address _user) external view returns(
    address userAddress,
    uint[] memory _recordIds,
    uint marketProvide,
    bool isMarker,
    address intro,
    uint reward,
    address[] memory children
  ) {
    return (users[_user].userAddress,
    users[_user].records,
    users[_user].marketProvide,
    users[_user].isMarker,
    users[_user].intro,
    users[_user].reward,
    users[_user].children
    );
  }
  function getCurCycleData (uint _dayNum) external view returns(
    uint _windToken,
    uint totalInvest,
    uint _marketToTalMoney,
    uint marketAdd,
    uint dayMarketTotal,
    uint marketReduce,
    uint poolAmount,
    uint income,
    uint reduce,
    uint _proportion
  ) {
    Cycle memory _cycle = cycles[_dayNum];
    return (_cycle.windToken,
    _cycle.totalInvest,
    _cycle.endMarketToTal,
    _cycle.marketAdd,
    _cycle.dayMarketTotal,
    _cycle.marketReduce,
    _cycle.poolAmount,
    _cycle.income,
    _cycle.reduce,
    _cycle.proportion
    );
  }
  function getCurDayStartBlock () external view returns(uint) {
    return curDayStartBlock;
  }
  function getSingleMarketInvest(uint _minute, uint _dayNum) external view returns(uint _amount) {
    return singleMarketInvest[_minute][_dayNum];
  }
  function setSingleMarketInvest(uint _minute, uint _dayNum, uint _amount) external platform {
    singleMarketInvest[_minute][_dayNum] = _amount;
  }
  //  function setDayMinuteNum (address _user, uint _dayNum) external platform {

  //  }
   function getProportion () external view returns(uint, uint){
     return (proportion, denominator);
   }
   function getIsDividend(address _user, uint _dayNum) external view returns(bool isSet) {
     return isDividend[_user][_dayNum];
   }
   function getDayMinuteNum(uint _dayNum, uint _minute) external view returns(uint _amount){
     return  dayMinuteNum[_dayNum][_minute];
   }
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
  ) external platform returns(bool){
    require(!blockIsInvests[_investBlock][_minute], 'This block has been invested');
    _addRecord(_investor, _investType, _minute, _investAmount, _investBlock, _investTime, _openBlock, _busdPerBeth);
    if (users[_investor].userAddress == address(0)) {
      _addUser(_investor);
    }
    if (_intro != address(0) && _intro != _investor && users[_intro].intro != _investor && users[_investor].intro == address(0)) {
      users[_investor].intro = _intro;
      users[_intro].children.push(_investor);
    }
    blockIsInvests[_investBlock][_minute] = true;
    _addBlock(_investBlock, _minute);
    orderId = orderId + 1;
    return true;
  }
  function _addBlock(uint _block, uint _minute) private {
    if (!blocks[_block][_minute].isExist) {
      BlockInfo memory _blockInfo = blocks[_block][_minute];
      _blockInfo.isExist = true;
      blocks[_block][_minute] = _blockInfo;
    }
    blocks[_block][_minute].records.push(orderId);
  }
  function _addRecord (
    address _investor,
    uint _investType,
    uint _minute,
    uint _investAmount,
    uint _investBlock,
    uint _investTime,
    uint _openBlock,
    uint _busdPerBeth) private {
      Record memory _record = records[orderId];
      _record.investor = _investor;
      _record.investType = _investType;
      _record.minute = _minute;
      _record.investAmount = _investAmount;
      _record.investBlock = _investBlock;
      _record.investDayNum = dayNum;
      _record.investTime = _investTime;
      _record.openBlock = _openBlock;
      _record.busdPerBeth = _busdPerBeth;
      records[orderId] = _record;
      recordIds.push(orderId);
      users[_investor].records.push(orderId);
      cycles[dayNum].totalInvest = cycles[dayNum].totalInvest.add(_investAmount);
      dayMinuteNum[dayNum][_minute] = dayMinuteNum[dayNum][_minute].add(_investAmount);
    }
    function _addUser (address _investor) private {
      User memory _user = users[_investor];
      _user.userAddress = _investor;
      users[_investor] = _user;
    }
   function changeCycle(uint _dayMarketTotal, uint _windToken) external platform {
      (,uint curDayMarketTotal) = getCurCycleIncome();
      cycles[dayNum].endBlock = block.number;
      cycles[dayNum].isEnd = true;
      cycles[dayNum].windToken = _windToken;
      totalMarketWind = totalMarketWind.add(_windToken);
      cycles[dayNum].endMarketToTal = curDayMarketTotal;
      proportion = proportion.mul(_dayMarketTotal).div(cycles[dayNum].endMarketToTal);
      dayNum = dayNum.add(1);
      if (dayNum == 4) {
        for (uint i = 0; i<poolAddress.length; i++) {
           IStakeInterface(poolAddress[i]).setOpen();
        }
      }
      curDayStartBlock = block.number.add(1);
      Cycle memory _newCycle = cycles[dayNum];
      _newCycle.proportion = proportion;
      _newCycle.startBlock = curDayStartBlock;
      _newCycle.dayMarketTotal = _dayMarketTotal;
      cycles[dayNum] = _newCycle;  
    }
    function transferPool(uint _amount) external platform {
      require(IERC20(BUSD).balanceOf(address(this)) >= _amount);
      uint ratio = getPoolRatio();
      for(uint i = 0; i<poolAddress.length; i++) {
        uint _ratio = pools[poolAddress[i]].ratio;
        IERC20(BUSD).safeTransfer(poolAddress[i], _amount.mul(_ratio).div(ratio));
      }
      totalPool = totalPool.add(_amount);
      cycles[dayNum].poolAmount = _amount;
    }
    function win(uint _amount, address _user,uint _id, uint _investAmount) external platform {
      require(IERC20(BUSD).balanceOf(address(this)) >= _amount);
      records[_id].isOpen = true;
      cycles[dayNum].reduce = cycles[dayNum].reduce.add(_amount.sub(_investAmount));
      IERC20(BUSD).safeTransfer(_user, _amount);
    }
    function fail (uint _id, uint _investAmount) external platform {
      records[_id].isOpen = true;
      cycles[dayNum].income = cycles[dayNum].income.add(_investAmount);
    }
    function addPoolMoney (address _user, uint _amount, address _intro) external platform returns(bool){
      (uint _back, uint _dayNumber) = getCanBack(_user);
      if (_back > 0) {
        users[_user].back = users[_user].back.add(_back);
        userDayMarkets[_user][_dayNumber].isBack = true;
      }
      if (users[_user].userAddress == address(0)) {
        _addUser(_user);
      }
      if (_intro != address(0) && _intro != _user && users[_intro].intro != _user && users[_user].intro == address(0)) {
        users[_user].intro = _intro;
        users[_intro].children.push(_user);
      }
      if (!users[_user].isMarker) {
        users[_user].isMarker = true;
        marketers.push(_user);
      }
      if (!userDayMarkets[_user][dayNum].isSet) {
        userDayMarkets[_user][dayNum].amount = users[_user].marketProvide;
        userDayMarkets[_user][dayNum].isSet = true;
      }
      users[_user].marketProvide = users[_user].marketProvide.add(_amount.mul(denominator).div(proportion));
      cycles[dayNum.add(1)].marketAdd = cycles[dayNum.add(1)].marketAdd.add(_amount);
      userDayMarkets[_user][dayNum.add(1)].amount = users[_user].marketProvide;
      userDayMarkets[_user][dayNum.add(1)].trueAmount = userDayMarkets[_user][dayNum.add(1)].trueAmount.add(_amount);
      userDayMarkets[_user][dayNum.add(1)].isSet = true;
      userDayMarkets[_user][dayNum.add(1)].proportion = proportion;
      return true;
    }
    function getCurCycleIncome () public view returns (uint curAmount, uint curDayMarketTotal){
      Cycle memory _cycle = cycles[dayNum];
      curAmount = _cycle.dayMarketTotal.add(_cycle.income).add(_cycle.marketAdd.mul(proportion).div(cycles[dayNum.sub(1)].proportion)).sub(_cycle.reduce).sub(_cycle.marketReduce);
      curDayMarketTotal = _cycle.dayMarketTotal.add(_cycle.marketAdd.mul(proportion).div(cycles[dayNum.sub(1)].proportion)).sub(_cycle.marketReduce);
   }
    function getCanBack (address _user) public view returns(uint,uint){
      uint _dayNumber;
      uint backAmount = 0;
      if(!users[_user].isMarker || dayNum == 1) {
        return (backAmount, dayNum);
      }
      for(uint i = dayNum; i > 1; i--) {
        if (userDayMarkets[_user][i].isSet && userDayMarkets[_user][i].trueAmount > 0) {
          _dayNumber = i;
          break;
        }
      }
      UserDayMarket memory _userDayMarket = userDayMarkets[_user][_dayNumber];
      if (_userDayMarket.trueAmount > 0 && !_userDayMarket.isBack && _userDayMarket.proportion > cycles[_dayNumber].proportion) {
        backAmount = _userDayMarket.trueAmount.mul(_userDayMarket.proportion.sub(cycles[_dayNumber].proportion)).div(_userDayMarket.proportion);
        return (backAmount, _dayNumber);
      }
      return (backAmount, _dayNumber);
    }
    function withdrawPool (address _user, uint _amount) private returns(uint){
      require(users[_user].isMarker);
      require(users[_user].marketProvide.mul(proportion).div(denominator) >= _amount);
      uint trueAmount;
      UserDayMarket memory tomorrow = userDayMarkets[_user][dayNum.add(1)];
      if (tomorrow.isSet && _amount <= tomorrow.trueAmount) {
        tomorrow.amount = tomorrow.amount > _amount.mul(denominator).div(proportion) ? tomorrow.amount.sub(_amount.mul(denominator).div(proportion)) : 0;
        tomorrow.trueAmount = tomorrow.trueAmount.sub(_amount);
        cycles[dayNum.add(1)].marketAdd = cycles[dayNum.add(1)].marketAdd.sub(_amount);
        users[_user].marketProvide = users[_user].marketProvide > _amount.mul(denominator).div(proportion) ? users[_user].marketProvide.sub(_amount.mul(denominator).div(proportion)) : 0;
        trueAmount = _amount;
        IERC20(BUSD).safeTransfer(_user, _amount);
      } else if (tomorrow.isSet && _amount > tomorrow.trueAmount) {
        tomorrow.amount = tomorrow.amount.sub(tomorrow.trueAmount.mul(denominator).div(proportion));
        uint rest = _amount.sub(tomorrow.trueAmount);
        cycles[dayNum.add(1)].marketAdd = cycles[dayNum.add(1)].marketAdd.sub(tomorrow.trueAmount);
        users[_user].marketProvide = users[_user].marketProvide > _amount.mul(denominator).div(proportion) ? users[_user].marketProvide.sub(_amount.mul(denominator).div(proportion)) : 0;
        userDayMarkets[_user][dayNum].amount = userDayMarkets[_user][dayNum].amount > rest.mul(denominator).div(proportion) ? userDayMarkets[_user][dayNum].amount.sub(rest.mul(denominator).div(proportion)) : 0;
        (uint curAmount, uint curDayMarketTotal) = getCurCycleIncome();
        cycles[dayNum].marketReduce = cycles[dayNum].marketReduce.add(rest);
        if(curDayMarketTotal > curAmount) {
          uint _rest = rest.mul(curAmount).div(curDayMarketTotal);
          cycles[dayNum].income = cycles[dayNum].income.add(rest.sub(_rest));
          rest = _rest;
        }
        trueAmount = rest.add(tomorrow.trueAmount);
        tomorrow.trueAmount = 0;
        IERC20(BUSD).safeTransfer(_user, trueAmount);
      } else {
        users[_user].marketProvide = users[_user].marketProvide > _amount.mul(denominator).div(proportion) ? users[_user].marketProvide.sub(_amount.mul(denominator).div(proportion)) : 0;
        userDayMarkets[_user][dayNum].amount = users[_user].marketProvide;
        userDayMarkets[_user][dayNum].isSet = true;
        (uint curAmount, uint curDayMarketTotal) = getCurCycleIncome();
        trueAmount = _amount;
        if(curDayMarketTotal > curAmount) {
          uint _trueAmount = trueAmount.mul(curAmount).div(curDayMarketTotal);
          cycles[dayNum].income = cycles[dayNum].income.add(trueAmount).sub(_trueAmount);
          trueAmount = _trueAmount;
        }
        cycles[dayNum].marketReduce = cycles[dayNum].marketReduce.add(_amount);
        IERC20(BUSD).safeTransfer(_user, trueAmount);
      }
      userDayMarkets[_user][dayNum.add(1)] = tomorrow;
      return trueAmount;
    }
   function getTotalBack (address _user) external view returns(uint){
     (uint _back,) = getCanBack(_user);
     uint total = users[_user].back.add(_back);
     return total;
   }
   function withdrawTotalBack (address _user) external platform{
     (uint _back, uint _dayNumber) = getCanBack(_user);
     if (_back > 0) {
        users[_user].back = users[_user].back.add(_back);
        userDayMarkets[_user][_dayNumber].isBack = true;
      }
      uint total = users[_user].back;
      users[_user].back = 0;
      IERC20(BUSD).safeTransfer(_user, total);
   }
   function withdrawPoolMoney (address _user, uint _amount) external platform returns(uint){
     (uint _back, uint _dayNumber) = getCanBack(_user);
      if (_back > 0) {
        users[_user].back = users[_user].back.add(_back);
        userDayMarkets[_user][_dayNumber].isBack = true;
      }
     uint trueAmount = withdrawPool(_user, _amount);
     return trueAmount;
   }
   function receiveDividends (address _user, uint amount, uint _dayNum, address _teamAddress, uint _teamAmount)  external platform returns(bool) {
     if (!userDayMarkets[_user][dayNum].isSet) {
       userDayMarkets[_user][dayNum].amount = users[_user].marketProvide;
       userDayMarkets[_user][dayNum].isSet = true;
     }
     isDividend[_user][_dayNum] = true;
     if (_teamAmount > 0) {
       IERC20(windToken).safeTransfer(_teamAddress, _teamAmount);
     }
      if (_dayNum <= 3) {
         uint ratio = getPoolRatio();
          for(uint i = 0; i<poolAddress.length; i++) {
            uint _ratio = pools[poolAddress[i]].ratio;
             IStakeInterface(poolAddress[i]).platformStake(amount.mul(_ratio).div(ratio), _user);
             IERC20(windToken).safeTransfer(poolAddress[i], amount.mul(_ratio).div(ratio));
          }
       } else {
         IERC20(windToken).safeTransfer(_user,amount);
       }
       return true;
   }
}