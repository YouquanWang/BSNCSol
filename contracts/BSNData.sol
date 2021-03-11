pragma solidity ^0.6.9;
import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
contract BSNData is Ownable {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;
  
  uint public orderId = 1;
  uint public perDayBlock = 28800;
  uint public dayNum = 1;
  uint public curDayStartBlock;
  address pool;
  address public windToken;
  uint marketToTalMoney;
  address public BUSD;
  uint public BUSDDecimals;
  // uint public tokenBethAddress = address('');
  // uint public tokenBusdAddress = address('');
   uint up = 1;
   uint down = 0;
  struct Cycle {
    uint startBlock;
    uint endBlock;
    uint windToken; // 当天发的wintoken总量
    uint totalInvest;
    uint marketToTalMoney; // 当天做市商总量
    uint marketAdd;
    uint dayMarketTotal; // 当天做市商初始余额
    bool isEnd;
  }
  mapping(uint => Cycle) cycles;

  struct User{
    address userAddress;
    // address introAddress;
    uint[] records;
    uint marketProvide;
    bool isMarker;
  }
  mapping(address => User) users;
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
  mapping(address => mapping(uint => uint)) userDayMarkets;
  /* 
   * accessAllowed
   * 调用合约权限设置
  */   
  mapping (address => bool) private accessAllowed;

  event AccessAllowedAddress(address indexed _addr, bool _access);
  event SetBUSDAddress(address _old, address _new);
  event SetPoolAddress(address _old, address _new);
  event SetWindTokenAddress(address _old, address _new);
  constructor (address _BUSD, address _pool, address _windToken) public {
    curDayStartBlock = block.number;
    marketToTalMoney = 0;
    Cycle memory _cycles = cycles[dayNum];
    _cycles.startBlock = curDayStartBlock;
    cycles[dayNum] = _cycles;
    BUSD = _BUSD;
    pool = _pool;
    windToken = _windToken;
    BUSDDecimals = IERC20(BUSD).decimals();
  }
  /* 
   * 验证 accessAllowed 权限
  */   
  modifier platform() {
    require(accessAllowed[msg.sender] == true, 'no access');
    _;
  }
   function setWindTokenAddress(address _windToken) onlyOwner public {
    emit SetWindTokenAddress(windToken, _windToken);
    windToken = _windToken;
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
  function setBUSDAddress(address _BUSD) onlyOwner public {
    emit SetBUSDAddress(BUSD, _BUSD);
    BUSD = _BUSD;
    BUSDDecimals = IERC20(BUSD).decimals();
  }
  function setPoolAddress(address _pool) onlyOwner public {
    emit SetPoolAddress(pool, _pool);
    pool = _pool;
  }
  function getMarketToTalMoney () external view returns(uint) {
    return marketToTalMoney;
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
  function getBlockRecords(uint _block, uint _minute) public view returns(uint[] memory ids) {
    return blocks[_block][_minute].records;
  }
  function getUserDayMarket (address _user, uint _dayNum) public view returns(uint _marketAmount) {
    return userDayMarkets[_user][_dayNum];
  }
  function getCurDayNum () external view returns(uint) {
    return dayNum;
  }
  function getUserInfo (address _user) external view returns(
    address userAddress,
    uint[] memory _recordIds,
    uint marketProvide,
    bool isMarker
  ) {
    return (users[_user].userAddress,
    users[_user].records,
    users[_user].marketProvide,
    users[_user].isMarker);
  }
  function getCurCycleData (uint _dayNum) external view returns(
    uint _windToken,
    uint totalInvest,
    uint _marketToTalMoney,
    uint marketAdd,
    uint dayMarketTotal
  ) {
    return (cycles[_dayNum].windToken,
    cycles[_dayNum].totalInvest,
    cycles[_dayNum].marketToTalMoney,
    cycles[_dayNum].marketAdd,
    cycles[_dayNum].dayMarketTotal);
  }
  function getCurDayStartBlock () external view returns(uint) {
    return curDayStartBlock;
  }
  function invest(
    address _investor,
    uint _investType,
    uint _minute,
    uint _investAmount,
    uint _investBlock,
    uint _investTime,
    uint _openBlock,
    uint _busdPerBeth
  ) external platform {
    require(!blockIsInvests[_investBlock][_minute], 'This block has been invested');
    _addRecord(_investor, _investType, _minute, _investAmount, _investBlock, _investTime, _openBlock, _busdPerBeth);
    if (users[_investor].userAddress == address(0)) {
      _addUser(_investor);
    }
    blockIsInvests[_investBlock][_minute] = true;
    _addBlock(_investBlock, _minute);
    orderId = orderId + 1;
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
    }
    // function _addUser (address _investor, address _intro) private {
    //   User memory _user = users[_investor];
    //   _user.userAddress = _investor;
    //   _user.introAddress = _intro;
    //   _user.marketProvide = 0;
    // }
    function _addUser (address _investor) private {
      User memory _user = users[_investor];
      _user.userAddress = _investor;
      users[_investor] = _user;
    }
   function changeCycle(uint _block, uint _dayMarketTotal, uint _windToken) external platform {
      cycles[dayNum].endBlock = _block;
      cycles[dayNum].isEnd = true;
      cycles[dayNum].windToken = _windToken;
      cycles[dayNum].marketToTalMoney = marketToTalMoney;
      // uint oldDay = dayNum;
      dayNum = dayNum.add(1);
      curDayStartBlock = _block.add(1);
      Cycle memory _newCycle = cycles[dayNum];
      _newCycle.startBlock = curDayStartBlock;
      _newCycle.dayMarketTotal = _dayMarketTotal;
      cycles[dayNum] = _newCycle;  
    }
    function transferPool(uint _amount) external platform {
      require(IERC20(BUSD).balanceOf(address(this)) >= _amount);
      IERC20(BUSD).safeTransfer(pool, _amount);
    }
    function win(uint _amount, address _user,uint _id) external platform {
      require(IERC20(BUSD).balanceOf(address(this)) >= _amount);
      records[_id].isOpen = true;
      IERC20(BUSD).safeTransfer(_user, _amount);
    }
    function fail (uint _id) external platform {
      records[_id].isOpen = true;
    }
    function addPoolMoney (address _user, uint _amount) external platform {
      if (users[_user].userAddress == address(0)) {
        _addUser(_user);
      }
      if (!users[_user].isMarker) {
        users[_user].isMarker = true;
        marketers.push(_user);
      }
      users[_user].marketProvide = users[_user].marketProvide.add(_amount);
      cycles[dayNum].marketAdd = cycles[dayNum].marketAdd.add(_amount);
      marketToTalMoney = marketToTalMoney.add(_amount);
      userDayMarkets[_user][dayNum] = users[_user].marketProvide;
    }
    function withdrawPool (address _user, uint _amount) private{
      require(users[_user].isMarker);
      require(users[_user].marketProvide >= _amount);
      users[_user].marketProvide = users[_user].marketProvide.sub(_amount);
      marketToTalMoney = marketToTalMoney.sub(_amount);
      userDayMarkets[_user][dayNum] = users[_user].marketProvide;
    }
   function withdrawPoolMoney (address _user, uint _amount, uint _trueAmount)  external platform  {
     withdrawPool(_user, _amount);
     IERC20(BUSD).safeTransfer(_user, _trueAmount);
   }
   function receiveDividends (address _user, uint amount, uint _dayNum, address _teamAddress, uint _teamAmount)  external platform  {
     if (userDayMarkets[_user][_dayNum.add(1)] <= 0) {
       userDayMarkets[_user][_dayNum.add(1)] = users[_user].marketProvide;
     }
     if (_teamAmount > 0) {
       IERC20(windToken).safeTransfer(_teamAddress, _teamAmount);
     }
     IERC20(windToken).safeTransfer(_user, amount);
   }
}