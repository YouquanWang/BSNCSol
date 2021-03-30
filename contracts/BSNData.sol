pragma solidity ^0.6.9;
import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
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
  uint marketToTalMoney;
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
    uint marketProvide;
    bool isMarker;
    uint reward;
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
  struct UserDayMarket{
    uint amount;
    uint trueAmount;
    bool isSet;
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
  constructor (address _BUSD, address _windToken) public {
    curDayStartBlock = block.number;
    BUSD = _BUSD;
    windToken = _windToken;
    BUSDDecimals = IERC20(BUSD).decimals();
    marketToTalMoney = 1000 * (10 ** BUSDDecimals);
    Cycle memory _cycles = cycles[dayNum];
    _cycles.startBlock = curDayStartBlock;
    _cycles.dayMarketTotal = marketToTalMoney;
    cycles[dayNum] = _cycles;
    _addUser(msg.sender);
    users[msg.sender].marketProvide = marketToTalMoney.mul(denominator).div(proportion);
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
  function setUserReward (address _user, uint _amount) external platform {
    users[_user].reward = _amount;
  }
  function getUserInfo (address _user) external view returns(
    address userAddress,
    uint[] memory _recordIds,
    uint marketProvide,
    bool isMarker,
    address intro,
    uint reward
  ) {
    return (users[_user].userAddress,
    users[_user].records,
    users[_user].marketProvide,
    users[_user].isMarker,
    users[_user].intro,
    users[_user].reward
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
    uint reduce
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
    _cycle.reduce
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
  ) external platform {
    require(!blockIsInvests[_investBlock][_minute], 'This block has been invested');
    _addRecord(_investor, _investType, _minute, _investAmount, _investBlock, _investTime, _openBlock, _busdPerBeth);
    if (users[_investor].userAddress == address(0)) {
      _addUser(_investor);
    }
    if (_intro != address(0) && users[_investor].intro == address(0)) {
      users[_investor].intro = _intro;
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
      dayMinuteNum[dayNum][_minute] = dayMinuteNum[dayNum][_minute].add(_investAmount);
    }
    function _addUser (address _investor) private {
      User memory _user = users[_investor];
      _user.userAddress = _investor;
      users[_investor] = _user;
    }
   function changeCycle(uint _dayMarketTotal, uint _windToken) external platform {
      cycles[dayNum].endBlock = block.number;
      cycles[dayNum].isEnd = true;
      cycles[dayNum].windToken = _windToken;
      totalMarketWind = totalMarketWind.add(_windToken);
      cycles[dayNum].endMarketToTal = cycles[dayNum].dayMarketTotal.add(cycles[dayNum].marketAdd).sub(cycles[dayNum].marketReduce);
      proportion = proportion.mul(_dayMarketTotal).div(cycles[dayNum].endMarketToTal);
      dayNum = dayNum.add(1);
      if (dayNum == 4) {
        for (uint i = 0; i<poolAddress.length; i++) {
           IStakeInterface(poolAddress[i]).setOpen();
        }
      }
      curDayStartBlock = block.number.add(1);
      Cycle memory _newCycle = cycles[dayNum];
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
    function addPoolMoney (address _user, uint _amount, address _intro) external platform {
      if (users[_user].userAddress == address(0)) {
        _addUser(_user);
      }
      if (_intro != address(0) && _intro != _user && _intro != _user && users[_user].intro == address(0)) {
        users[_user].intro = _intro;
      }
      if (!users[_user].isMarker) {
        users[_user].isMarker = true;
        marketers.push(_user);
      }
      userDayMarkets[_user][dayNum].amount = users[_user].marketProvide;
      userDayMarkets[_user][dayNum].isSet = true;
      users[_user].marketProvide = users[_user].marketProvide.add(_amount.mul(denominator).div(proportion));
      cycles[dayNum.add(1)].marketAdd = cycles[dayNum.add(1)].marketAdd.add(_amount);
      marketToTalMoney = marketToTalMoney.add(_amount);
      userDayMarkets[_user][dayNum.add(1)].amount = users[_user].marketProvide;
      userDayMarkets[_user][dayNum.add(1)].trueAmount = userDayMarkets[_user][dayNum.add(1)].trueAmount.add(_amount);
      userDayMarkets[_user][dayNum.add(1)].isSet = true;
    }
    function withdrawPool (address _user, uint _amount) private returns(uint){
      require(users[_user].isMarker);
      require(users[_user].marketProvide.mul(proportion).div(denominator) >= _amount);
      uint trueAmount;
      UserDayMarket memory tomorrow = userDayMarkets[_user][dayNum.add(1)];
      if (tomorrow.isSet && _amount <= tomorrow.trueAmount) {
        tomorrow.amount = tomorrow.amount.sub(_amount.mul(denominator).div(proportion));
        tomorrow.trueAmount = tomorrow.trueAmount.sub(_amount);
        cycles[dayNum.add(1)].marketAdd = cycles[dayNum.add(1)].marketAdd.sub(_amount);
        users[_user].marketProvide = users[_user].marketProvide.sub(_amount.mul(denominator).div(proportion));
        marketToTalMoney = marketToTalMoney.sub(_amount);
        trueAmount = _amount;
        IERC20(BUSD).safeTransfer(_user, _amount);
      } else if (tomorrow.isSet && _amount > tomorrow.trueAmount) {
        tomorrow.amount = tomorrow.amount.sub(tomorrow.trueAmount.mul(denominator).div(proportion));
        uint rest = _amount.sub(tomorrow.trueAmount);
        cycles[dayNum.add(1)].marketAdd = cycles[dayNum.add(1)].marketAdd.sub(tomorrow.trueAmount);
        users[_user].marketProvide = users[_user].marketProvide.sub(_amount.mul(denominator).div(proportion));
        marketToTalMoney = marketToTalMoney.sub(_amount);
        cycles[dayNum].marketReduce = cycles[dayNum].marketReduce.add(rest);
        userDayMarkets[_user][dayNum].amount = userDayMarkets[_user][dayNum].amount.sub(rest.mul(denominator).div(proportion));
        trueAmount = rest.mul(proportion).div(denominator).add(tomorrow.trueAmount);
        tomorrow.trueAmount = 0;
        IERC20(BUSD).safeTransfer(_user, trueAmount);
      } else {
        users[_user].marketProvide = users[_user].marketProvide.sub(_amount.mul(denominator).div(proportion));
        marketToTalMoney = marketToTalMoney.sub(_amount);
        cycles[dayNum].marketReduce = cycles[dayNum].marketReduce.add(_amount);
        userDayMarkets[_user][dayNum].amount = users[_user].marketProvide;
        userDayMarkets[_user][dayNum].isSet = true;
        trueAmount = _amount.mul(proportion).div(denominator);
        IERC20(BUSD).safeTransfer(_user, trueAmount);
      }
      userDayMarkets[_user][dayNum.add(1)] = tomorrow;
      return trueAmount;
    }
   function withdrawPoolMoney (address _user, uint _amount) external platform returns(uint){
     uint trueAmount = withdrawPool(_user, _amount);
     return trueAmount;
   }
   function receiveDividends (address _user, uint amount, uint _dayNum, address _teamAddress, uint _teamAmount)  external platform  {
     if (!userDayMarkets[_user][_dayNum.add(1)].isSet) {
       userDayMarkets[_user][_dayNum.add(1)].amount = users[_user].marketProvide;
       userDayMarkets[_user][_dayNum.add(1)].isSet = true;
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
   }
}